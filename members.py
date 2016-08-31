# -*- encoding: utf-8 -*-
import os
import json
import ovh

client = ovh.Client(
    endpoint='ovh-eu',
    application_key=os.environ['AK'],
    application_secret=os.environ['AS'],
    consumer_key=os.environ['CK']
)

result = client.get('/email/domain/beta.gouv.fr/mailingList/membres/subscriber')

print json.dumps(result, indent=4) 
