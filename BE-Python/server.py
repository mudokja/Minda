import os
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import text_emotion
import text_keyword
import mongo_util
from pymongo import MongoClient

print("호출: server.py")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True, # cookie 포함 여부를 설정한다. 기본은 False
    allow_methods=["*"],    # 허용할 method를 설정할 수 있으며, 기본값은 'GET'이다.
    allow_headers=["*"],	# 허용할 http header 목록을 설정할 수 있으며 Content-Type, Accept, Accept-Language, Content-Language은 항상 허용된다.
)


mongo_client = mongo_util.mongo_connection()
print(type(mongo_client))
print(mongo_client.list_database_names())
mongo_db = mongo_client[os.environ["MONGO_DB_NAME"]]


# # 환경변수에서 호스트, 포트, 사용자 이름, 비밀번호를 불러옵니다.
# mongo_host = os.environ["MONGO_DB_HOST"]
# mongo_port = int(os.environ["MONGO_DB_PORT"])
# mongo_user = os.environ["MONGO_DB_USERNAME"]
# mongo_pass = os.environ["MONGO_DB_PASSWORD"]
# mongo_db_name = os.environ["MONGO_DB_NAME"]  # 접근하려는 데이터베이스 이름

# # 인증 정보를 포함하여 MongoClient 객체를 생성합니다.
# mongo_client = MongoClient(
#     host=mongo_host,
#     port=mongo_port,
#     username=mongo_user,
#     password=mongo_pass,
#     authSource=mongo_db_name  # 인증을 수행할 데이터베이스
# )

# print(type(mongo_client))
# print(mongo_client.list_database_names())

@app.get("/")
def read_root(): 
    return {"Hello": "World"}

@app.get("/api/ai/test")
def test_api():
    return "test success"

@app.get("/api/ai/analyze_text")
def analyze_text(text:str):
    try:
        return(text_emotion.predict_emotion(text))
    except Exception as e:
        return {str(e)}

@app.get("/api/ai/keyword")
def get_keyword(text:str):
    try:
        texts = text_keyword.split_sentences(text)
        # print()
        text_keyword.get_keyword(texts)
        return text
    except Exception as e:
        return {str(e)}