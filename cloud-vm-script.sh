#!/bin/bash

# Non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Update system
apt update -y

# Install Apache + Flask
apt install -y apache2 python3-flask

# Enable Apache proxy modules
a2enmod proxy
a2enmod proxy_http

# Configure Apache reverse proxy
tee /etc/apache2/sites-available/000-default.conf > /dev/null <<EOF
<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://localhost:5000/
    ProxyPassReverse / http://localhost:5000/
</VirtualHost>
EOF

# Restart Apache
systemctl restart apache2

# Clean old logs
rm -f /tmp/app.log

# Create Flask app (UPDATED with students + JSON)
tee /tmp/app.py > /dev/null <<EOF
from flask import Flask, jsonify
import socket

app = Flask(__name__)

students = [
    {"id": 1, "name": "Ravi", "course": "CS"},
    {"id": 2, "name": "Anjali", "course": "IT"},
    {"id": 3, "name": "Kiran", "course": "ECE"}
]

@app.route("/")
def home():
    return jsonify({
        "source": "CLOUD VM",
        "hostname": socket.gethostname(),
        "data": students
    })

@app.route("/students")
def get_students():
    return jsonify(students)

# Health check endpoint (IMPORTANT for LB)
@app.route("/health")
def health():
    return "OK", 200

app.run(host="0.0.0.0", port=5000)
EOF

# Small delay
sleep 3

# Run Flask app
nohup python3 /tmp/app.py > /tmp/app.log 2>&1 &