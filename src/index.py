from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import json
import openai
import os
import logging
from io import StringIO

# Initialize variables
bot = openai.OpenAI()
config = None  # Global config variable to store configuration settings
chat = [{"role": "system", "content": "You (your name is console) are a bash console and you are interfacing with someone with the name of user. you must respond only how a bash terminal would respond"}]  # Global variable to store chat
app = Flask(__name__)  # Create a Flask web server
# Enable CORS for '/query' path; allows all origins to make requests
cors = CORS(app, resources={r"/query": {"origins": "*"}})
# Setup log capture
log_stream = StringIO()
logging.basicConfig(level=logging.INFO, stream=log_stream)
log_handler = logging.StreamHandler(log_stream)
app.logger.addHandler(log_handler)

# ENDPOINTS:

# Handler for the root URL
@app.route('/')
def index():
    if config is not None:
        # Get the external URL endpoint for '/query'
        ask_url = get_endpoint() + '/query'
        # Render HTML template and append debug message
        return render_template('index.html', ASK_ENDPOINT=ask_url)
    else:
        # Return message if config is not set
        return "not configured"

# Handler for setting up configuration
@app.route('/set_config', methods=["POST"])
def set_config():
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
        configure()
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
        return jsonify({"status": "error", "message": "Missing 'message' key"}), 400
    response = jsonify(message=ask_model(question))
    return response

# Handler to retrieve server logs
@app.route('/log', methods=['GET'])
def log_output():
    log_contents = log_stream.getvalue()
    return log_contents

# UTILITIES:


# Function to get external URL from env
def get_endpoint():
    default_url = 'env_not_found'
    env_prefix = 'https://'
    # Get external URL from environment variable or use default
    url = env_prefix + os.environ.get('EXTERNAL_URL', default_url)
    return url

# Function for asking questions
def ask_model(inquiry):
    global chat
    global client
    append_message("user", inquiry)
    completion = openai.chat.completions.create(model="gpt-3.5-turbo", messages=chat)
    reply = completion.choices[0].message
    log("=================="+reply+"==================")
    return reply

# Add a particular message to the stored chat
def append_message(role, message):
    global chat
    chat.append({"role": role, "content": message})

# Intitialize (use) config variables
def configure():
    global config
    openai.api_key = config.get("OPENAIKEY", "openaikey_not_found")
# Log a message to /log
def log(msg):
    app.logger.info("\n\n" + msg)  # Log output using Flask's logger
# Main execution starts here
if __name__ == '__main__':
    app.run(debug=True)
