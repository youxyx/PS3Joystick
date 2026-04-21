import os
import RPi.GPIO as GPIO
import time
GPIO.setmode(GPIO.BCM) # Broadcom pin-numbering scheme
GPIO.setup(21, GPIO.IN, pull_up_down=GPIO.PUD_UP)

while True:
    if not GPIO.input(21):
        print("enabling joystick")
        os.system("sudo systemctl start joystick")

    else:
        print("disabling joystick")
        os.system("sudo systemctl stop joystick")

    time.sleep(5)
