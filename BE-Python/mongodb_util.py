from pymongo import MongoClient
import os

print("호출: mongodb_util")

def mongodb_connection():
    try:
        # 환경변수에서 호스트, 포트, 사용자 이름, 비밀번호를 불러옵니다.
        mongo_host = os.environ["MONGO_DB_HOST"]
        mongo_port = int(os.environ["MONGO_DB_PORT"])
        mongo_user = os.environ["MONGO_DB_USER"]
        mongo_pass = os.environ["MONGO_DB_PASSWORD"]
        mongo_db_name = os.environ["MONGO_DB_NAME"]  # 접근하려는 데이터베이스 이름

        # 인증 정보를 포함하여 MongoClient 객체를 생성합니다.
        mongo_client = MongoClient(
            host=mongo_host,
            port=mongo_port,
            username=mongo_user,
            password=mongo_pass,
            authSource=mongo_db_name  # 인증을 수행할 데이터베이스
        )
        return mongo_client
    except Exception as e:
        return {str(e)}