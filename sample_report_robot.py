#!/usr/bin/env python3

import os
import smtplib
import subprocess
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
def SendMail(To):
    msg = MIMEMultipart()
    msg['Subject'] = ''
    msg['From'] = ''
    msg['To'] = ''
    
    subprocess.check_output("cd /home/tom/Projects/proface/reporting ;./checkDiffOfJOBfiles.sh | ./ansi2html.sh > JOBdiff.html", shell=True)
    report = open('/home/tom/Projects/proface/reporting/JOBdiff.html','r')
    reportOpen = report.read()
    text = MIMEText(reportOpen, 'html')
    report.close()
    msg.attach(text)
    s = smtplib.SMTP('<smtp>', 587)
    s.ehlo()
    s.starttls()
    s.ehlo()
    s.login('<mail>', "<pass>")
    s.sendmail('<mail>', To, msg.as_string())
    s.quit()

SendMail('<recv mail>')
SendMail('<recv mail>')
