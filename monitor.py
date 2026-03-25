import psutil

THRESHOLD = 75

def is_cpu_usage_gt75():
    cpu = psutil.cpu_percent(interval=1)
    print(f"CPU Usage: {cpu}%")
    return True if cpu > THRESHOLD else False