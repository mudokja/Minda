from krwordrank.word import summarize_with_keywords
import re

print("호출: text_keyword.py")

def split_sentences(text):
    sentences = re.split(r'(?<!\d)\.(?!\d)(?=\s)|(?<=[?!])', text)
    # 각 문장 앞뒤의 공백 제거
    sentences = [sentence.strip() for sentence in sentences if sentence.strip() != '']
    return sentences

def get_keyword(texts):
    try:
        print(texts)
        keywords = summarize_with_keywords(texts, min_count=1, max_length=10,
            beta=0.85, max_iter=10, stopwords=None, verbose=True)  #min_count로 민감도 조절, 20보다 늘리면 에러
        print(keywords)
        return texts
    except Exception as e:
        print ({str(e)})