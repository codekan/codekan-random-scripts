import socket
import sys
from datetime import datetime
import threading, time
from queue import Queue

remoteServer = input("Enter a remote host to scan: ")
remoteServerIP = socket.gethostbyname(remoteServer)
print ("Scanning: " + remoteServerIP)

port_start = int(input("Ab welchem Port soll gescannt werden?: "))
port_end = int(input("Bis zu welchem Port soll gescannt werden ")) + 1

def portscan(x1, x2):
    time_start = datetime.now()
    try:
        for port in range(x1, x2):                       # 1-50 scannt nur 1-49 darum oben auf port_end + 1                              
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            result = sock.connect_ex((remoteServerIP, port))                                      
            if result == 0:
                print(f"Port {port}:	 Open")                     
            elif result == 10061:                                        
                print(f"error 10061 - connection refused for port: {port}")     # das kommt wenn ein port geschlossen ist
            elif result == 10060:
                print("Error 10060 - Timeout - Maybe the device is offline or Stealth Mode is running") 
                sys.exit()
            else:                                
                print(f"das result ist neu: {result}")
            sock.close()

    except KeyboardInterrupt:
        print("You pressed Ctrl + C")
        sys.exit()

    except socket.gaierror:
        print('Hostname could not be resolved. Exiting')
        sys.exit()

    except socket.error:
        print("Couldn't connect to the server")
        sys.exit()

    except socket.herror:
        print("another error that i dont know anything of")

    time_end = datetime.now()
    total_time =  time_end - time_start 
    print('Scanning Completed in: ', total_time)  


portscan(port_start, port_end)
