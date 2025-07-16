from flask import Flask, render_template, request
from analysis import check_fake_news_with_search
from PIL import Image
import pytesseract
import os

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    result = None
    extracted_text = ""
    if request.method == "POST":
        if "image" in request.files:
            image_file = request.files["image"]
            if image_file.filename != "":
                image = Image.open(image_file.stream).convert('L')
                extracted_text = pytesseract.image_to_string(image, lang="vie")
                result = check_fake_news_with_search(extracted_text)
    return result

if __name__ == "__main__":
    app.run(debug=True)