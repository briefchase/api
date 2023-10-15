# Use the Python 3.10 slim image based on Debian Bullseye
FROM python:3.10-slim-bullseye
# Set the working directory within the container
WORKDIR /usr/src/app
# Copy all files from the current directory to the container
COPY . .
# Add the flask app index to env
ENV FLASK_APP=src/index.py
# Upgrade pip and install required Python packages
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r src/requirements.txt
# Update package list and install jq
RUN apt-get update && apt-get install -y jq
# Expose port 9091
EXPOSE 9091
# Run Flask application with specified environment and options
CMD /bin/bash -c "source .env && flask run --host=0.0.0.0 --port=9091"
