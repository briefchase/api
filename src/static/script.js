/* DOM REFERENCES */

const responseDisplayContent = document.getElementById('response_content');
const inputDisplayContent = document.getElementById('input_content');
const cursorDisplayContent = document.getElementById('cursor_content');
const textboxController = document.getElementById('input_controller');

/* LISTENERS */

// Secret text box value changes
textboxController.addEventListener('input', function() {
    inputDisplayContent.textContent = textboxController.value;
    cursorDisplayContent.textContent = ' '.repeat(textboxController.value.length) + "_";
    window.alert("change"); //DEBUG
});
// Enter key press
textboxController.addEventListener('keypress', function(event) {
    if (event.key === 'Enter') {
        let question = textboxController.value;
        textboxController.value = '';
        inputDisplayContent.textContent = '';
        cursorDisplayContent.textContent = '_';
        ask(question);
    }
});

/* HELPERS */

// Sends a message from the console
async function ask(input) {
    const data = await send(input, ask_url);
    if (data.error) {
        respond(data.error);
    } else {
        respond(data.message);
    }
}
// Displays the response
function respond(text) {
    responseDisplayContent.innerHTML = '';
    const letters = text.split('');
    letters.forEach((letter, index) => {
        setTimeout(() => {
            responseDisplayContent.innerHTML = `${responseDisplayContent.innerHTML.slice(0, index)}${letter}${responseDisplayContent.innerHTML.slice(index + 1)}`;
        }, index * 100);
    });
}

/* UTILITIES */

// Posts a text message to a specific endpoint in JSON format
const HEADERS = { 'Content-Type': 'application/json' };
async function send(text, endpoint) {
    const payload = {
        method: 'POST',
        headers: HEADERS,
        body: JSON.stringify({ message: text })
    };
    let response;
    try {
        response = await fetch(endpoint, payload);
        if (!response.ok) throw new Error(`Network response was not ok: ${response.status} ${response.statusText}`);
        return await response.json();
    } catch (error) {
        const errorObj = {
            error: `${error.constructor.name}: ${error.message}`,
            payload: JSON.stringify(payload),
        };
        if (response) {
            errorObj.responseStatus = `${response.status} ${response.statusText}`;
            errorObj.responseText = await response.text();
        }
        return errorObj;
    }
}
