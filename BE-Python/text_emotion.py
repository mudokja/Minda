import torch
from kobert.pytorch_kobert import get_pytorch_kobert_model
from kobert.utils import get_tokenizer
import numpy as np
import gluonnlp as nlp
import torch
from torch import nn
import gluonnlp as nlp
from BERTDataset import BERTDataset

print("호출: text_emotion.py ")
device = torch.device("cuda" if torch.cuda.is_available() else "cpu") #cuda사용가능하면 or cpu
bertmodel, vocab = get_pytorch_kobert_model(cachedir=".cache")

max_len = 64
batch_size = 64

class BERTClassifier(nn.Module):
    print("호출: BERTClassifier ")
    def __init__(self,
                 bert,
                 hidden_size = 768,
                 num_classes=7, #감정 개수로 변경
                 dr_rate=None,
                 params=None):
        super(BERTClassifier, self).__init__()
        self.bert = bert
        self.dr_rate = dr_rate
                 
        self.classifier = nn.Linear(hidden_size , num_classes)
        if dr_rate:
            self.dropout = nn.Dropout(p=dr_rate)
    
    def gen_attention_mask(self, token_ids, valid_length):
        attention_mask = torch.zeros_like(token_ids)
        for i, v in enumerate(valid_length):
            attention_mask[i][:v] = 1
        return attention_mask.float()

    def forward(self, token_ids, valid_length, segment_ids):
        attention_mask = self.gen_attention_mask(token_ids, valid_length)
        
        _, pooler = self.bert(input_ids = token_ids, token_type_ids = segment_ids.long(), attention_mask = attention_mask.float().to(token_ids.device))
        if self.dr_rate:
            out = self.dropout(pooler)
        else:
            out = pooler
        return self.classifier(out)
    
tokenizer = get_tokenizer()
tok = nlp.data.BERTSPTokenizer(tokenizer, vocab, lower = False)

model = BERTClassifier(bertmodel,dr_rate=0.5)
model.load_state_dict(torch.load("model_state_dict.pt",map_location=device))

def predict_emotion(predict_sentence):
    try:
        data = [predict_sentence, '0']
        dataset_another = [data]

        another_test = BERTDataset(dataset_another, 0, 1, tok, max_len, True, False) # 토큰화한 문장
        test_dataloader = torch.utils.data.DataLoader(another_test, batch_size = batch_size, num_workers = 5) # torch 형식 변환

        model.eval()

        for batch_id, (token_ids, valid_length, segment_ids, label) in enumerate(test_dataloader):
            token_ids = token_ids.long().to(device)
            segment_ids = segment_ids.long().to(device)

            valid_length = valid_length
            label = label.long().to(device)

            out = model(token_ids, valid_length, segment_ids)

            test_eval = []
            for i in out: # out = model(token_ids, valid_length, segment_ids)
                logits = i
                logits = logits.detach().cpu().numpy()
                # print(logits)
                if np.argmax(logits) == 0:
                    test_eval.append("중립")
                elif np.argmax(logits) == 1:
                    test_eval.append("분노, 혐오")
                elif np.argmax(logits) == 2:
                    test_eval.append("슬픔, 상처")
                elif np.argmax(logits) == 3:
                    test_eval.append("놀람, 당황")
                elif np.argmax(logits) == 4:
                    test_eval.append("불안, 공포")
                elif np.argmax(logits) == 5:
                    test_eval.append("행복, 기쁨")
            # return test_eval[0]   #가장 높은 하나의 값
            return logits   #가중치 값
    except Exception as e:
        return "Error"+{str(e)}