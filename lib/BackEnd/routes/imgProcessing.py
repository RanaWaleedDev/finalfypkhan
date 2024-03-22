import tensorflow as tf
import numpy as np
from PIL import Image
from flask import Blueprint, jsonify, request
import json
from sklearn.metrics.pairwise import cosine_similarity
from scipy.signal import convolve2d

ASSETS_FOLDER_PATH = "../../assets"

bp_img = Blueprint('img', __name__, url_prefix="/img")

# Load a pre-trained CNN model
model = tf.keras.applications.VGG16(weights='imagenet', include_top=False)

# Define cosine similarity function
def cosine_similarity(features1, features2):
    dot_product = np.dot(features1, features2)
    norm1 = np.linalg.norm(features1)
    norm2 = np.linalg.norm(features2)
    print(dot_product / (norm1 * norm2))
    return dot_product / (norm1 * norm2)
        
def ssim_similarity(features1, features2):
    # Reshape the feature arrays into 2D arrays
    # features1 = features1.reshape(158, 158)
    # features2 = features2.reshape(158, 158)

    # Constants for SSIM calculation
    k1 = 0.01
    k2 = 0.03
    L = 255

    # Calculate means of the two feature arrays
    mu1 = np.mean(features1)
    mu2 = np.mean(features2)

    # Calculate variances of the two feature arrays
    var1 = np.var(features1)
    var2 = np.var(features2)

    # Calculate covariance of the two feature arrays
    covar = np.cov(features1.flatten(), features2.flatten())[0][1]

    # Calculate SSIM
    numerator = (2 * mu1 * mu2 + k1) * (2 * covar + k2)
    denominator = (mu1 ** 2 + mu2 ** 2 + k1) * (var1 + var2 + k2)
    ssim = numerator / denominator

    return ssim


@bp_img.route('/process', methods=['POST'])
def index():
    file1 = request.files['usr_image']
    # Get the news list from the request's data
    news_list_json = request.form.get('newsList')
    news_list = json.loads(news_list_json)

    img1 = Image.open(file1.stream)
    img1 = img1.resize((224, 224))
    # Load and preprocess the input image
    # Convert uint8List to PIL Image
    # img = Image.frombytes(mode='RGB', size=(224, 224), data=img)
    x = tf.keras.preprocessing.image.img_to_array(img1)
    x = tf.keras.applications.vgg16.preprocess_input(x)
    x = tf.expand_dims(x, axis=0)

    # Extract features from the input image
    features1 = model.predict(x)

    # Flatten the features into a 1D array
    features1 = features1.flatten()
    usefulNews = []

    for news in news_list:
        img2 = Image.open(ASSETS_FOLDER_PATH + "/" + news["photoUrl"])
        img2 = img2.resize((224, 244))

        y = tf.keras.preprocessing.image.img_to_array(img2)
        y = tf.keras.applications.vgg16.preprocess_input(y)
        y = tf.expand_dims(y, axis=0)

        # Extract features from the input image
        features2 = model.predict(y)

        # Flatten the features into a 1D array
        features2 = features2.flatten()
        cs = cosine_similarity(features1, features2)
        ssim = ssim_similarity(features1, features2)

        THERSHOLD = 0.1
        if cs > THERSHOLD and ssim > THERSHOLD:
            usefulNews.append(news)

    return {"status": 200, "newsList": usefulNews,}

