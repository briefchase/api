from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import json
import openai

#messages = [ {"role": "system", "content": "You are a bash terminal you must respond only as a bash terminal would:\n"} ]

# Initialize variables
config = None
app = Flask(__name__)
cors = CORS(app, resources={r"/query": {"origins": "*"}})  # This will allow all origins to make requests

# Handler for general reqests
@app.route('/')
def index():
    if config != None: return render_template('index.html')
    else: return config

# Used for setting the configuration details
@app.route('/set_config', methods=["POST"])
def configure():
    # Load the template JSON structure for comparison
    with open("config.template.json", "r") as f:
        template_structure = json.load(f)
    # Handle configuration request
    if not request.is_json:
        return jsonify({"status": "error", "message": "Request is not in JSON format"}), 400
    content = request.get_json()
    if set(content.keys()) == set(template_structure.keys()):
        config = content
        return jsonify({"status": "success", "message": "JSON structure matches the template and is saved"})
    else:
        return jsonify({"status": "error", "message": "JSON structure does not match the template"}), 400

# Used in the frontend
@app.route('/query')
def query():
    response = jsonify(message="hi")

if __name__ == '__main__':
    app.run(debug=True)