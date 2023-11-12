#!/usr/bin/python3

import psutil
import smtplib
from email.mime.text import MIMEText

# Set your threshold for resource usage in percent
THRESHOLD = 85

def get_cpu_info():
    return psutil.cpu_percent(interval=1)

def get_memory_info():
    virtual_memory = psutil.virtual_memory()
    return virtual_memory.percent

def get_disk_info():
    disk_usage = psutil.disk_usage('/')
    return disk_usage.percent

def send_notification(message):
    # Replace with your email configuration
    smtp_server = 'smtp.example.com'
    smtp_port = 587
    sender_email = 'your_email@example.com'
    sender_password = 'your_password'
    receiver_email = 'recipient@example.com'

    msg = MIMEText(message)
    msg['Subject'] = 'Resource Usage Warning'
    msg['From'] = sender_email
    msg['To'] = receiver_email

    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls()
    server.login(sender_email, sender_password)
    server.sendmail(sender_email, receiver_email, msg.as_string())
    server.quit()

if __name__ == "__main__":
    cpu_percent = get_cpu_info()
    memory_percent = get_memory_info()
    disk_percent = get_disk_info()

    if cpu_percent > THRESHOLD or memory_percent > THRESHOLD or disk_percent > THRESHOLD:
        message = "Resource Usage Alert:\n"
        if cpu_percent > THRESHOLD:
            message += f"CPU Usage: {cpu_percent}%\n"
        if memory_percent > THRESHOLD:
            message += f"Memory Usage: {memory_percent}%\n"
        if disk_percent > THRESHOLD:
            message += f"Disk Usage: {disk_percent}%\n"

        send_notification(message)
        print("Resource usage exceeds threshold. Notification sent.")
    else:
        print("Resource usage is within limits.")
