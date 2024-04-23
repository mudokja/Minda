import os
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import text_emotion

print("server.py 호출")

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
        return text
    except Exception as e:
        return {str(e)}