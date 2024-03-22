from transformers import pipeline
from flask import Blueprint, jsonify, request

bp_lang = Blueprint('lang', __name__, url_prefix="/lang")

model_name = "deepset/roberta-base-squad2"
nlp = pipeline('question-answering', model=model_name, tokenizer=model_name)

@bp_lang.route('/process', methods=['POST'])
def index():
    _newsList = request.get_json()["newsList"]
    usefulNews = []
    for news in _newsList:
        # print(news)
        QA_input = {
            'question': request.get_json()["userQuery"],
            'context': news["description"]
        }
        res = nlp(QA_input)
        if res["score"] > 0.01:
            news["answer"] = res["answer"]
            usefulNews.append(
                news
            )
    return jsonify({"newsList": usefulNews,})

