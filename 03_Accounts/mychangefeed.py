from faker import Faker
import uuid
import datetime
import logging
from azure.eventhub import EventHubProducerClient, EventData
from azure.schemaregistry import SchemaRegistryClient
from azure.schemaregistry.serializer.avroserializer import AvroSerializer
from azure.identity import DefaultAzureCredential
from azure.cosmos import CosmosClient, PartitionKey

## Generate Fake Customer Data
faker = Faker()
guid = uuid.uuid4()
date = datetime.datetime.utcnow()
email = faker.email()
logging.info(f'Guid is {guid}')
logging.info(f'Date is {date}')
logging.info(f'Email is {email}')

data = {
    'id': str(guid),
    'date' : str(date),
    'email':  email
}

## Setup Schema Registry Connection Details
fully_qualified_namespace = 'dv-schemaregistry-ehns-eun-griff.servicebus.windows.net'
group_name = "myschemagroup"
format = "Avro"
##this is aprg with permissions on the schema registry that needs to be setup
token_credential =  token_credential = DefaultAzureCredential()
## Set Publisher Connection Details
conn_eventhub_publish = "Endpoint=sb://dv-events001-ehns-eun-griff.servicebus.windows.net/;SharedAccessKeyName=send;SharedAccessKey=PpvvgQjvZkA8cYgA/yozQ69dtoEGWlLxA8YPZabpfM0="

## Set Schema
schema_string = """{
"namespace": "example.avro",
"type": "record",
"name": "Customer.Created",
"fields": [
    {
        "name": "id",
        "type": [
            "string"
        ],
        "sensitive" : false
    },
    {
        "name": "date",
        "type": [
            "string"
        ],
        "sensitive" : false
    },
    {
        "name": "email",
        "type": [
            "string"
        ],
        "sensitive" : true  
    }
]
}"""

logging.info('Get schema reg client...')
schema_registry_client = SchemaRegistryClient(fully_qualified_namespace, token_credential)
logging.info('Get schema serialiazer...')
avro_serializer = AvroSerializer(client=schema_registry_client, group_name=group_name, auto_register_schemas=True)

# Schema would be automatically registered into Schema Registry and cached locally.
logging.info('Get payload...')
payload = avro_serializer.serialize(data, schema=schema_string)
logging.info(f'Encoded bytes are: {payload}')

eventhub_producer = EventHubProducerClient.from_connection_string(
    conn_str=conn_eventhub_publish,
    eventhub_name="demo"
)

print("Create cosmos client...")
endpoint = "https://dv-customer-cosdb-eun-griff.documents.azure.com:443/"
key = "dpsMr3BzCIQfK8oxfvQarvCRooqvgRSTJLndNKSOhyOrQIfPRI2CmT6gm58KVxvozSBvA61psqdbyWoBtebUzg=="
client = CosmosClient(endpoint, key)
print("Created cosmos client.")

print("Create database...")
database_name = 'customer'
database = client.create_database_if_not_exists(id=database_name)
print("Database created.")

print("Create container...")
container_name = 'customer_created'
container = database.create_container_if_not_exists(
    id=container_name, 
    partition_key=PartitionKey(path="/id")
)
print("Container created.")


with eventhub_producer, avro_serializer:
    try:
        container.create_item(body=data)
    except:
        raise ValueError('ERROR: Customer was not created.')
    print('SUCCESS: Customer was created.')
    response = container.query_items_change_feed(is_start_from_beginning=False,partition_key = str(guid))
    keys_to_remove = ["_rid", "_etag","_self","_attachments","_ts","_lsn"]
    for doc in response:
        for key in keys_to_remove:
            del doc[key]
        print('Start sending event hub packet')
        event_data_batch = eventhub_producer.create_batch()
        payload_bytes = avro_serializer.serialize(doc, schema=schema_string)
        event_data_batch.add(EventData(body=payload_bytes))
        eventhub_producer.send_batch(event_data_batch)
        print('Event hub packet sent.')

