import requests

def lambda_handler(event, context):
    response = requests.get('https://my-json-server.typicode.com/ruanbekker/fake-api/users/1').json()
    return {
        'statusCode': 200,
        'body': response
    }
