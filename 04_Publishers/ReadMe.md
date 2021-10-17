```
pip install faker
```

```
pip install azure-eventhub
```

```
pip install azure.functions
```

Lets make the storage immutable and add/remove a lock on the storage during deploy
so data is bullet proof.
```bash
az deployment group create --name "eventHubDeployment" --resource-group "events-broker-rg" --template-file "04_Publishers\eventhub.bicep" --parameters namespace="griff" event="customer"
```

```
venv\scripts\activate
```

```
04_Publishers\customer_created.py
```

to get functions working remember to install all pre-reqs
also close and reopen vs code when done
add python packages requitred to requitements.txt file (e.g gaker)