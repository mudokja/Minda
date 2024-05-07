import os
from dotenv import load_dotenv
from fastapi import FastAPI, Request, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
import text_emotion
import text_keyword
import mongo_util
from pydantic import BaseModel
from typing import Optional
from transformers import PreTrainedTokenizerFast, GPT2LMHeadModel
import torch

print("호출: server.py")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

app = FastAPI()

app.mount("/pyswagger", StaticFiles(directory="pyswagger"), name="pyswagger")

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

@app.get("/custom/docs", include_in_schema=False)
async def custom_swagger_ui():
    html_content = open('pyswagger/swagger.html', 'r').read()
    return HTMLResponse(content=html_content)

@app.post("/api/ai/emotion")
def analyze_text(diary_index:int, diary_content:str):
    try:
        print(diary_content)
        emotion=text_emotion.predict_emotion(diary_content)
        # dict = {}
        # dict['diary_index'] = diary_index
        # dict['emotion'] = emotion
        # mongo_util.mongo_insert(mongo_collection,dict)
        return emotion
    except Exception as e:
        return {str(e)}

@app.post("/api/ai/keyword")
def get_keyword(diary_index:int, diary_content:str):
    try:
        texts = text_keyword.split_sentences(diary_content)
        # return text_keyword.get_keyword(texts)
        return texts
    except Exception as e:
        return {str(e)}
    
class DiaryEntry(BaseModel):
    diary_index: int
    diary_content: str
    
@app.post("/api/ai/analyze") #메인 기능
async def analyze_diary(entry: DiaryEntry):
    try:
        analyze_dict = {} #몽고DB 저장 용 딕셔너리
        emotion_dict = {} #문장 별 감정 저장 용 딕셔터리
        diary_sentences = text_keyword.split_sentences(entry.diary_content)   #문장 별 분리
        # diary_noun_sentences = text_keyword.noun_sentences(diary_sentences) #키워드 추출 용 어간 추출
        for index, sentence in enumerate(diary_sentences):  
            emotion_dict[str(index)] = text_emotion.predict_emotion(sentence).tolist()  #감정 분석
        analyze_dict['diary_index'] = entry.diary_index
        analyze_dict['sentence'] = diary_sentences  #분리된 문장 리스트
        analyze_dict['emotion'] = emotion_dict  #문장 별 감정 수치
        analyze_dict['keyword'] = await text_keyword.get_keyword(diary_sentences)    #키워드는 어간 추출 리스트 기반
        mongo_util.mongo_insert(mongo_collection,analyze_dict)
        return "success"
    except Exception as e:
        return {str(e)}
    
@app.get("/api/ai/chatbot")
def chat_response(query: str = Query(default="", description="Input sentence for the chatbot")):
    try:
        print(input)
        # print(kogpt2_chatbot.chat(input))
        # return kogpt2_chatbot.predict(input)
        # print(chat_model.chat(quey))
    except Exception as e:
        return {str(e)}