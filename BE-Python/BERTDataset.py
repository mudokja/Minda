import warnings
warnings.filterwarnings('ignore', category=UserWarning, message=".*LAMB is overriding existing optimizer.*")
import numpy as np
import gluonnlp as nlp
from torch.utils.data import Dataset

class BERTDataset(Dataset):
    # print("호출: BERTDataset ")
    def __init__(self, dataset, sent_idx, label_idx, bert_tokenizer, max_len, pad, pair):

        transform = nlp.data.BERTSentenceTransform(
            bert_tokenizer, max_seq_length=max_len, pad = pad, pair = pair)

        self.sentences = [transform([i[sent_idx]]) for i in dataset]
        self.labels = [np.int32(i[label_idx]) for i in dataset]

    def __getitem__(self, i):
        return (self.sentences[i] + (self.labels[i], ))

    def __len__(self):
        return (len(self.labels)) 