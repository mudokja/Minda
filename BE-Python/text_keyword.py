from krwordrank.word import summarize_with_keywords
import re

print("호출: text_keyword.py")

# def split_sentences(text):
#     sentences = re.sub(r'([^\n\s\.\?!]+[^\n\.\?!]*[\.\?!])', r'\1\n', text).strip().split("\n")
#     return sentences

def split_sentences(text):
    # 소수점 등을 고려하여 문장 종료 패턴을 감지하되, 문장 끝 구두점을 유지합니다.
    # 패턴 설명:
    # - (?<!\d)\.(?!\d) : 숫자가 아닌 것 뒤의 점과 숫자가 아닌 것 앞의 점에 대해 매치합니다.
    # - [?!] : ? 또는 !에 매치합니다.
    # 구두점을 포함하여 문장을 나누기 위해 lookbehind와 lookahead를 사용합니다.
    sentences = re.split(r'(?<!\d)\.(?!\d)(?=\s)|(?<=[?!])', text)
    # 각 문장 앞뒤의 공백 제거
    # sentences = [sentence.strip() for sentence in sentences if sentence.strip() != '']
    return sentences

def get_keyword(texts):
    try:
        print(texts)
        keywords = summarize_with_keywords(texts, min_count=1, max_length=10,
            beta=0.85, max_iter=10, stopwords=None, verbose=True)  #min_count 20보다 늘리면 에러
        # keywords = summarize_with_keywords(texts) # with default arguments
        print(keywords)
        return texts
    except Exception as e:
        print ({str(e)})