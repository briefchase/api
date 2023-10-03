from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import json
import openai

#openai.my_api_key = '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'
#messages = [ {"role": "system", "content": "You are a bash terminal you must respond only as a bash terminal would:\n"} ]

app = Flask(__name__)
cors = CORS(app, resources={r"/query": {"origins": "*"}})  # This will allow all origins to make requests

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/query')
def query():
    response = jsonify(message="hi")
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    return response

if __name__ == '__main__':
    app.run(debug=True)