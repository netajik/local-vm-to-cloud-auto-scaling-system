from flask import Flask, jsonify
import requests
import socket
from monitor import is_cpu_usage_gt75

app = Flask(__name__)

CLOUD_URL = "http://35.232.7.156:80/students"

students = [
    {"id": 1, "name": "Ramu", "course": "CS"},
    {"id": 2, "name": "Ramesh", "course": "IT"},
    {"id": 3, "name": "Raju", "course": "ECE"}
]

@app.route("/")
def handle_request():
    print("REQUEST RECEIVED", flush=True)

    hostname = socket.gethostname()

    if is_cpu_usage_gt75():
        print("Routing to CLOUD", flush=True)
        try:
            response = requests.get(CLOUD_URL, timeout=5)
            return jsonify({
                "source": "CLOUD",
                "data": response.json()
            })
        except:
            return jsonify({"error": "Cloud not reachable"}), 500
    else:
        print("Serving LOCAL", flush=True)
        return jsonify({
            "source": "LOCAL",
            "hostname": hostname,
            "data": students
        })

# Optional: direct students endpoint
@app.route("/students")
def get_students():
    return jsonify(students)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)