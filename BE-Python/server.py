import os
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
import text_emotion, text_keyword, text_chatbot
import mongo_util
from pydantic import BaseModel
import asyncio
import s3_util
from typing import List

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

#mongoDB 로드
mongo_client = mongo_util.mongo_connection()
mongo_db = mongo_client[os.environ["MONGO_DB_NAME"]]
mongo_collection=mongo_db['analyze']
#s3 로드
s3_connection = s3_util.s3_connection()

@app.get("/")
def read_root(): 
    return {"Hello": "World"}

@app.get("/custom/docs", include_in_schema=False)
async def custom_swagger_ui():
    html_content = open('pyswagger/swagger.html', 'r').read()
    return HTMLResponse(content=html_content)

@app.post("/api/ai/emotion")    #감정 추출 테스트 api
def analyze_text(diary_index:int, diary_content:str):
    try:
        print(diary_content)
        emotion=text_emotion.predict_emotion(diary_content)
        return emotion
    except Exception as e:
        return {str(e)}

@app.post("/api/ai/keyword")    #키워드 추출 테스트 api
def get_keyword(content:str):
    try:
        contents = text_keyword.split_sentences(content)
        noun_contents = text_keyword.noun_sentences(contents)
        return text_keyword.get_keyword(noun_contents)
    except Exception as e:
        return {str(e)}
    
@app.get("/api/ai/test/wordcloud")   #워드클라우드 생성 테스트 api
def get_image(content:str):
    try:
        contents = text_keyword.split_sentences(content)
        noun_contents = text_keyword.noun_sentences(contents)
        keywords = text_keyword.get_keyword(noun_contents)
        img_byte_arr = text_keyword.make_wordcloud(keywords)
        s3_link = s3_util.s3_save_wordcloud(img_byte_arr,s3_connection)
        return s3_link
    except Exception as e:
        return {str(e)}

class DiaryIndexList(BaseModel):
    diary_index_list: List[int]

@app.post("/api/ai/wordcloud") 
def get_image(data: DiaryIndexList):
    try:
        keywords_dict = {}
        for diary_index in data.diary_index_list:
            documents = mongo_collection.find({"diary_index": diary_index})
            for document in documents:
                keyword = document.get('keyword')
                if keyword:
                    for key, value in keyword.items():
                        if key in keywords_dict:
                            keywords_dict[key] += value
                        else:
                            keywords_dict[key] = value
        print(keywords_dict)
        img_byte_arr = text_keyword.make_wordcloud(keywords_dict)
        s3_link = s3_util.s3_save_wordcloud(img_byte_arr,s3_connection)
        return s3_link
    except Exception as e:
        return {"error": str(e)}

class DiaryEntry(BaseModel):
    diary_index: int
    diary_content: str

@app.post("/api/ai/analyze") #메인 기능
def analyze_diary(entry: DiaryEntry):
    try:
        analyze_dict = {} #몽고DB 저장 용 딕셔너리
        emotion_dict = {} #문장 별 감정 저장 용 딕셔터리
        diary_sentences = text_keyword.split_sentences(entry.diary_content)   #문장 별 분리
        diary_noun_sentences = text_keyword.noun_sentences(diary_sentences) #키워드 추출 용 어간 추출
        for index, sentence in enumerate(diary_sentences):  
            emotion_dict[str(index)] = text_emotion.predict_emotion(sentence).tolist()  #감정 분석
        analyze_dict['diary_index'] = entry.diary_index
        analyze_dict['sentence'] = diary_sentences  #분리된 문장 리스트
        analyze_dict['emotion'] = emotion_dict  #문장 별 감정 수치
        analyze_dict['keyword'] = text_keyword.get_keyword(diary_noun_sentences)    #키워드는 어간 추출 리스트 기반
        mongo_util.mongo_insert(mongo_collection,analyze_dict)
        return "success"
    except Exception as e:
        return {str(e)}
    
async def async_chat(input: str):
    loop = asyncio.get_running_loop()
    result = await loop.run_in_executor(None, text_chatbot.chat, input)
    return result
    
@app.get("/api/ai/chatbot")
async def chat_response(input: str):
    result = await async_chat(input)
    return result