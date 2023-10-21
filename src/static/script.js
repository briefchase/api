// DOM element references
const responsediv = document.getElementById('response');
const inputcontent = document.getElementById('input_content');
const cursorcontent = document.getElementById('cursor_content');
const hiddentextbox = document.getElementById('input_textbox');

// Listener for hidden text box value changes
hiddentextbox.addEventListener('input', function() {
    inputcontent.textContent = hiddentextbox.value;
    cursorcontent.textContent = ' '.repeat(hiddentextbox.value.length) + "_";
});

// Listener for Enter key press
hiddentextbox.addEventListener('keypress', function(event) {
    if (event.key === 'Enter') {
        let question = hiddentextbox.value;
        hiddentextbox.value = '';
        inputcontent.textContent = '';
        cursorcontent.textContent = '_';
        ask(question);
    }
});

// Function to ask question
async function ask(input) {
    const data = await send(input);
    if (data.error) {
        respond(data.error);
    } else {
        respond(data.message);
    }
}

// Function to display response
function respond(text) {
    responsediv.innerHTML = '';
    const letters = text.split('');
    letters.forEach((letter, index) => {
        setTimeout(() => {
            responsediv.innerHTML = `${responsediv.innerHTML.slice(0, index)}${letter}${responsediv.innerHTML.slice(index + 1)}`;
        }, index * 100);
    });
}

const HEADERS = { 'Content-Type': 'application/json' };
// Function to send fetch request and handle errors
async function send(text) {
    const url = ENV_URL;
    const payload = {
        method: 'POST',
        headers: HEADERS,
        body: JSON.stringify({ message: text })
    };
    let response;
    try {
        response = await fetch(url, payload);
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
