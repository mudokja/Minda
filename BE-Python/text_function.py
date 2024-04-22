import torch
from kobert.pytorch_kobert import get_pytorch_kobert_model
from kobert.utils import get_tokenizer
from manage import BERTClassifier,BERTDataset
import numpy as np
import gluonnlp as nlp

device = torch.device("cpu")
bertmodel, vocab = get_pytorch_kobert_model()

max_len = 64
batch_size = 64

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

            print(out)
            test_eval = []
            for i in out: # out = model(token_ids, valid_length, segment_ids)
                logits = i
                logits = logits.detach().cpu().numpy()
                print(logits)
                if np.argmax(logits) == 0:
                    test_eval.append("공포가")
                elif np.argmax(logits) == 1:
                    test_eval.append("놀람이")
                elif np.argmax(logits) == 2:
                    test_eval.append("분노가")
                elif np.argmax(logits) == 3:
                    test_eval.append("슬픔이")
                elif np.argmax(logits) == 4:
                    test_eval.append("중립이")
                elif np.argmax(logits) == 5:
                    test_eval.append("행복이")
                elif np.argmax(logits) == 6:
                    test_eval.append("혐오가")
            return test_eval[0]
    except Exception as e:
        return "Error"+{str(e)}