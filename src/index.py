from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import json
import openai
import os

# Initialize variables
config = None  # Global config variable to store configuration settings
app = Flask(__name__)  # Create a Flask web server
# Enable CORS for '/query' path; allows all origins to make requests
cors = CORS(app, resources={r"/query": {"origins": "*"}})

# ENDPOINTS:

# Handler for the root URL
@app.route('/')
def index():
    if config != None:
        # Get the external URL endpoint for '/query'
        ask_url = get_endpoint() + '/query'
        # Render HTML template and append debug message
        return render_template('index.html', ASK_ENDPOINT=ask_url)
    else:
        # Return message if config is not set
        return "not configured"
# Handler for setting up configuration
@app.route('/set_config', methods=["POST"])
def configure():
    global config  # Refer to the global config variable
    # Load the template JSON to check structure
    with open("config.template.json", "r") as f:
        template_structure = json.load(f)
    # Check if incoming request is JSON
    if not request.is_json:
        return jsonify({"status": "error", "message": "Request is not in JSON format"}), 400
    content = request.get_json()
    # Validate JSON keys against template
    if set(content.keys()) == set(template_structure.keys()):
        config = content
        return jsonify({"status": "success", "message": "JSON structure matches the template and is saved"})
    else:
        return jsonify({"status": "error", "message": "JSON structure does not match the template"}), 400
# Handler for query-related requests
@app.route('/query', methods=['POST'])
def query():
    json_data = request.get_json()
    if json_data is None:
        return jsonify({"status": "error", "message": "Invalid JSON"}), 400
    question = json_data.get('message')
    if question is None:
        return jsonify({"status": "error", "message": "Missing 'question' key"}), 400
    response = jsonify(message=ask_model(question))
    return response

# UTILITIES:

# Function to get external URL
def get_endpoint():
    default_url = 'env_not_found'
    env_prefix = 'https://'
    # Get external URL from environment variable or use default
    url = env_prefix + os.environ.get('EXTERNAL_URL', default_url)
    return url
# Function for asking questions
def ask_model(inquiry):
    hi = "hi"  # Placeholder: to be implemented
    return inquiry

# Main execution starts here
if __name__ == '__main__':
    app.run(debug=True)
