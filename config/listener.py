from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os

app = Flask(__name__)
# Allow all origins to make requests to the root route
cors = CORS(app, resources={r"/": {"origins": "*"}})

# Load the template JSON structure for comparison
with open("config.template.json", "r") as f:
    template_structure = json.load(f)

@app.route('/', methods=["POST"])
def index():
    # Check if the request payload is in JSON format
    if not request.is_json: 
        return jsonify({"status": "error", "message": "Request is not in JSON format"}), 400
    content = request.get_json()

    # Check if the received JSON keys match the template's keys
    if set(content.keys()) == set(template_structure.keys()):
        # Save to /config/config.json
        with open("/config/config.json", "w") as f:
            json.dump(content, f)
        return jsonify({"status": "success", "message": "JSON structure matches the template and is saved"})
    else:
        return jsonify({"status": "error", "message": "JSON structure does not match the template"}), 400

if __name__ == '__main__':
    app.run(debug=True)
