from krwordrank.word import summarize_with_keywords
from wordcloud import WordCloud
import matplotlib.pyplot as plt
from konlpy.tag import Okt 
from kiwipiepy import Kiwi
import io

print("호출: text_keyword.py")

kiwi=Kiwi()
okt = Okt()

krwordrank_cloud = WordCloud(
    font_path = "malgunbd.ttf",
    width = 800,
    height = 800,
    background_color="white"
)

def split_sentences(text):
    try:
        data = kiwi.split_into_sents(text)
        sentences = [item[0] for item in data]
        return sentences
    except Exception as e:
        print ({str(e)})

def noun_sentences(sentences):
    try:
        noun_sentences = []

        for sentence in sentences:
            if len(sentence) == 0:
                continue
            nouns = okt.nouns(sentence)
            if len(nouns) == 0:
                continue
            noun_sentences.append(' '.join(nouns) + '.')
        return noun_sentences
    except Exception as e:
        print ({str(e)})

def get_keyword(texts):
    try:
        keywords = summarize_with_keywords(texts, min_count=1, max_length=10,
            beta=0.85, max_iter=10, stopwords=None, verbose=True)  #min_count로 민감도 조절, 20보다 늘리면 에러
        return keywords
    except Exception as e:
        print ({str(e)})

def make_wordcloud(keywords):
    try:
        krwordrank_cloud_result = krwordrank_cloud.generate_from_frequencies(keywords)
        fig = plt.figure(figsize=(10, 10))
        plt.imshow(krwordrank_cloud_result, interpolation="bilinear")
        plt.axis('off')  # 눈금과 숫자(축 레이블) 숨김
        # plt.show()

        img_byte_arr = io.BytesIO()
        plt.savefig(img_byte_arr, format = 'JPEG')
        img_byte_arr.seek(0)
        plt.close(fig)

        return img_byte_arr
    except Exception as e:
        print ({str(e)})