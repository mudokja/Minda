from krwordrank.word import summarize_with_keywords
import re
from wordcloud import WordCloud
import matplotlib.pyplot as plt
from konlpy.tag import Okt 

print("호출: text_keyword.py")

def split_sentences(text):
    try:
        sentences = re.split(r'(?<!\d)\.(?!\d)(?=\s)|(?<=[?!])', text)
        # 각 문장 앞뒤의 공백 제거
        sentences = [sentence.strip() for sentence in sentences if sentence.strip() != '']
        return sentences
    except Exception as e:
        print ({str(e)})

def noun_sentences(sentences):
    try:
        okt = Okt()
        noun_sentences = []

        for sentence in sentences:
            if len(sentence) == 0:
                continue
            sentence_pos = okt.pos(sentence, stem=True)
            nouns = [word for word, pos in sentence_pos if pos == 'Noun']
            if len(nouns) == 1:
                continue
            noun_sentences.append(' '.join(nouns) + '.')

        return noun_sentences
    except Exception as e:
        print ({str(e)})

async def get_keyword(texts):
    try:
        # print(texts)
        keywords = summarize_with_keywords(texts, min_count=1, max_length=10,
            beta=0.85, max_iter=10, stopwords=None, verbose=True)  #min_count로 민감도 조절, 20보다 늘리면 에러
        print(keywords)
        # krwordrank_cloud = WordCloud(
        #     font_path = "malgunbd.ttf",
        #     width = 800,
        #     height = 800,
        #     background_color="white"
        # )
        # krwordrank_cloud = krwordrank_cloud.generate_from_frequencies(keywords)
        # fig = plt.figure(figsize=(10, 10))
        # plt.imshow(krwordrank_cloud, interpolation="bilinear")
        # plt.axis('off')  # 눈금과 숫자(축 레이블) 숨김
        # plt.show()
        # fig.savefig('image.png')
        return keywords
    except Exception as e:
        print ({str(e)})