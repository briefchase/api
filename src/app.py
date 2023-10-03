from flask import Flask, request, jsonify, render_template
import json
import openai

#openai.my_api_key = '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'
#messages = [ {"role": "system", "content": "You are a bash terminal you must respond only as a bash terminal would:\n"} ]

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/query', methods=['GET'])
def query():
    # #Access query parameters from the URL
    # query_parameters = request.args
    # # Convert the ImmutableMultiDict to a regular dictionary
    # json_data = query_parameters.to_dict()
    # # Optionally, convert the dictionary to a JSON string
    # json_string = json.dumps(json_data)
    # message = json_string
    # messages.append({"role": "user", "content": message},)
    # completion = openai.ChatCompletion.create(model="gpt-3.5-turbo", messages = messages)
    # reply = completion.choices[0].message.content
    return "hi"#jsonify(message="hi")

if __name__ == '__main__':
    app.run(debug=True)