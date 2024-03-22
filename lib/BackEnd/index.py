from flask import Flask, jsonify
from routes.langProcessing import bp_lang
from routes.imgProcessing import bp_img
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.register_blueprint(bp_lang)
app.register_blueprint(bp_img)


@app.route('/')
def index():
    return jsonify({"status": 200})

if __name__ == '__main__':
    app.run(debug=True)
 