import os
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import text_emotion
import text_keyword
import mongo_util

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

#mongoDB로드
mongo_client = mongo_util.mongo_connection()
mongo_db = mongo_client[os.environ["MONGO_DB_NAME"]]
mongo_collection=mongo_db['analyze']

@app.get("/")
def read_root(): 
    return {"Hello": "World"}

@app.get("/api/ai/test")
def test_api():
    return "test success"

@app.post("/api/ai/emotion")
def analyze_text(diary_index:int, diary_content:str):
    try:
        emotion=text_emotion.predict_emotion(diary_content)
        dict = {}
        dict['diary_index'] = diary_index
        dict['emotion'] = emotion
        mongo_util.mongo_insert(mongo_collection,dict)
        return emotion
    except Exception as e:
        return {str(e)}

@app.post("/api/ai/keyword")
def get_keyword(diary_index:int, diary_content:str):
    try:
        texts = text_keyword.split_sentences(diary_content)
        return text_keyword.get_keyword(texts)
    except Exception as e:
        return {str(e)}
    
@app.post("/api/ai/analyze") #메인 기능
def analyze_diary(diary_index:int, diary_content:str):
    try:
        analyze_dict = {} #몽고DB 저장 용 딕셔너리
        emotion_dict = {} #문장 별 감정 저장 용 딕셔터리
        diary_sentences = text_keyword.split_sentences(diary_content)   #문장 별 분리
        for index, sentence in enumerate(diary_sentences):
            emotion_dict[str(index)] = text_emotion.predict_emotion(sentence).tolist()
        analyze_dict['diary_index'] = diary_index
        analyze_dict['sentence'] = diary_sentences
        analyze_dict['emotion'] = emotion_dict
        analyze_dict['keyword'] = text_keyword.get_keyword(diary_sentences)
        mongo_util.mongo_insert(mongo_collection,analyze_dict)
        return str(analyze_dict)
    except Exception as e:
        return {str(e)}