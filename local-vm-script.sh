pkill -f app.py
nohup python3 app.py > app.log 2>&1 &
# tail -f app.log