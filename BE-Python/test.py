from krwordrank.word import summarize_with_keywords

def get_keyword(texts):
    # keywords = summarize_with_keywords(texts, min_count=5, max_length=10,
    #     beta=0.85, max_iter=10, stopwords=stopwords, verbose=True)
    keywords = summarize_with_keywords(texts) # with default arguments
    print(keywords)