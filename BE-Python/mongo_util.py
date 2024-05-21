from pymongo import MongoClient
import os
from urllib.parse import quote_plus
import json

print("호출: mongodb_util")

def mongo_connection():
    try:
        mongo_uri="mongodb://"+os.environ["MONGO_DB_USERNAME"]+":"+os.environ["MONGO_DB_PASSWORD"]+"@"+os.environ["MONGO_DB_HOST"]+":"+os.environ["MONGO_DB_PORT"]
        mongo_client = MongoClient(mongo_uri)
        return mongo_client
    except Exception as e:
        return {str(e)}
    
def mongo_insert(mongo_collection, dict):
    try:
        mongo_collection.insert_one(dict)
    except Exception as e:
        return {str(e)}