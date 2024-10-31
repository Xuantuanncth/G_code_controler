import sys
import os
import threading
import time
import re
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine

import serial.tools.list_ports

v_TURN_LEFT  = 1001
v_TURN_RIGHT = 1002
v_TURN_UP    = 1003
v_TURN_DOWN  = 1004
v_TURN_ZERO  = 1005
v_SET_ZERO   = 1006

v_Gcode_file = ""

debug_app = False

class SerialHandler(QObject):
    """
    A class to handle serial communication operations.

    This class provides methods for managing serial port connections,
    sending and receiving data, and listing available COM ports.
    It inherits from QObject to integrate with Qt's signal-slot mechanism.

    Attributes:
        messageReceived (pyqtSignal): Signal emitted when a message is received.
    """
    messageReceived = pyqtSignal(str, arguments=['message'])
    runningFlag = pyqtSignal(str, arguments=['flag'] )

    def __init__(self):
        """
        Initialize the SerialHandler object.

        Sets up initial values for serial connection, read thread, and running state.
        """
        super().__init__()
        self.serial = None
        self.read_thread = None
        self.send_thread = None
        self.running = False
        QObject.__init__(self)

    @pyqtSlot(result=list)
    def fetchComPorts(self):
        """
        Fetch and return a list of available COM ports.

        Returns:
            list: A list of strings representing available COM port names.
        """
        ports = serial.tools.list_ports.comports()
        for port in ports:
            print(f"Port: {port.device}, Description: {port.description}, HWID: {port.hwid}")
        return [port.device for port in ports]

    @pyqtSlot(str)
    def connectComPort(self, port_name):
        """
        Connect to a specified COM port.

        Args:
            port_name (str): The name of the COM port to connect to.

        Raises:
            Exception: If connection fails, the error is printed.
        """
        print(f"Connecting to {port_name}")
        try:
            # default baud rate is 115200, but you can change it as needed
            self.serial = serial.Serial(port_name, 115200)
            print(f"Connected to {port_name}")
            self.running = True
            self.read_thread = threading.Thread(target=self.receiveData)
            self.read_thread.daemon = True
            self.read_thread.start()
        except Exception as e:
            print(f"Error: {e}")

    @pyqtSlot(str)
    def disconnectComPort(self):
        """
        Disconnect from the currently connected COM port.

        Raises:
            Exception: If disconnection fails, the error is printed.
        """
        print("Disconnecting from serial port...")
        try:
            self.running = False
            self.serial.close()
            self.read_thread.join()
            print("Disconnected from serial port")
        except Exception as e:
            print(f"Error disconnecting: {e}")

    @pyqtSlot(str, result=str)
    def sendData(self, data):
        """
        Send data through the connected serial port.

        Args:
            data (str): The data to be sent.

        Raises:
            Exception: If sending data fails, the error is printed.
        """
        print(f"Sending data: {data}")
        try:
            if not data.endswith("\r\n"):
                data += "\r\n"  # Add newline characters if not already present
            self.serial.write(data.encode())
            print(f"Data sent successfully")
        except Exception as e:
            print(f"Error sending data: {e}")

    @pyqtSlot()
    def receiveData(self):
        """
        Continuously receive data from the serial port.

        This method runs in a separate thread, reading data from the serial port
        and emitting it via the messageReceived signal.
        """
        print("Receiving data...")
        print ("Serial port connected: ", self.serial.is_open, " Running: ", self.running)
        while self.running and self.serial.is_open: 
            if self.serial.in_waiting > 0:
                message = self.serial.readline().decode('utf-8').strip()
                print(f"Received data: {message}")
                self.messageReceived.emit(message)
            time.sleep(0.5)  # Added delay to avoid excessive CPU usage
        print("No serial port connected")

    @pyqtSlot(str)
    def sendCommand(self, command):
        v_direction = int(command)
        f_command = "G21G91G1"
        b_command = "F100"
        dir_cmd = ""
        typeOfCMD = 0

        if v_direction == v_TURN_LEFT:
            print("Turning left")
            dir_cmd = "X2"
        elif v_direction == v_TURN_RIGHT:
            dir_cmd = "X-2"
        elif v_direction == v_TURN_UP:
            dir_cmd = "Y2"
        elif v_direction == v_TURN_DOWN:
            dir_cmd = "Y-2"
        elif v_direction == v_SET_ZERO:
            typeOfCMD = 1
            st1_command = "G10 P0 L20 X0 Y0 Z0"
        elif v_direction == v_TURN_ZERO:
            typeOfCMD = 2
            st1_command = "G21G90 G0Z5"
            st2_command = "G90 G0 X0 Y0"
            st3_command = "G90 G0 Z0"

        if typeOfCMD == 0:
            _command = f_command + dir_cmd + b_command
            print(f"_command: {_command}")
            self.sendData(_command)
        elif typeOfCMD == 1:
            self.sendData(st1_command)
        else:
            self.sendData(st1_command)
            self.sendData(st2_command)
            self.sendData(st3_command)
        
    @pyqtSlot()
    def startSendGcode(self):
        try:
            self.send_thread = threading.Thread(target=self.sendGcodeFile)
            self.send_thread.daemon = True
            self.send_thread.start()
            print("G-code file loading started")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
    @pyqtSlot()
    def sendGcodeFile(self):
        try:
            with open(v_Gcode_file, 'r') as file:
                for line in file:
                    line = line.strip()
                    if line:
                        self.sendData(line)
                        time.sleep(0.5)  # Added delay to avoid excessive CPU usage
            print("Done loading G-code file")
            self.runningFlag.emit("done")
        except FileNotFoundError as e:
            print(f"Error: File not found: {v_Gcode_file}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
        
# Define a class to handle the file loading functionality
class FileLoader(QObject):
    """
    A class to handle file loading functionality.

    This class provides methods to load the content of a text file.
    It inherits from QObject to allow integration with Qt's object system.
    """

    def __init__(self):
        """
        Initialize the FileLoader object.

        This constructor calls the parent class (QObject) constructor.
        """
        QObject.__init__(self)

    @pyqtSlot(str, result=str)
    def loadFile(self, file_url):
        """
        Load the content of a predefined text file.

        This method attempts to open and read a file named 'example.txt'.
        It can be modified to load any specified text file.

        Returns:
            str: The content of the file if successfully loaded,
                 or an error message string if an exception occurs.
        """
        file_path = file_url.replace('file:///', '')

        if os.name == 'nt':  # Windows OS
            file_path = file_path.replace('/', '\\')

        try:
            with open(file_path, 'r') as file:
                content = file.read()
                return content
        except Exception as e:
            return f"Error loading file: {str(e)}"

class Parser_Gcode(QObject):

    dataParser = pyqtSignal(list, arguments=['gcode_data'])
    def __init__(self):
        QObject.__init__(self)

    @pyqtSlot(str)
    def load_gcode(self, file_path):
        gcode_data = []
        gcode_data = parse_gcode(file_path)
        if gcode_data:
            # print("G-code data: ", (gcode_data))
            self.dataParser.emit(gcode_data)
        else:
            self.dataParser.emit([])

class Test_notification(QObject):

    notification = pyqtSignal(str, arguments=['message'])
    def __init__(self):
        QObject.__init__(self)

    @pyqtSlot()
    def show_notification(self):
        print(f"Notification")
        counter_for_notification()
        self.notification.emit("Hello from Python!")
        # Implement notification display logic here

def counter_for_notification():
    for i in range(10):
        time.sleep(1)

def parse_gcode(file_url):
    global v_Gcode_file
    gcode_commands = []

    file_path = file_url.replace('file:///', '')

    if os.name == 'nt':  # Windows OS
        file_path = file_path.replace('/', '\\')
    v_Gcode_file = file_path
    print(f"Loading G-code from {file_path}")
    try:
        with open(file_path, 'r') as file:
            for line in file:
                line = line.split(';')[0].strip()  # Strip out comments
                if not line:
                    continue

                # Match G1 or G0 commands with X, Y coordinates
                match = re.match(r'(G0|G1)\s+X([-+]?[0-9]*\.?[0-9]+)?\s+Y([-+]?[0-9]*\.?[0-9]+)?', line)
                if match:
                    cmd = match.group(1)
                    x = float(match.group(2)) if match.group(2) else None
                    y = float(match.group(3)) if match.group(3) else None
                    # Add debug output to inspect the coordinates
                    # print(f"Command: {cmd}, X: {x}, Y: {y}")
                    gcode_commands.append([cmd, x, y])

            print("G-code commands loaded successfully")
            return gcode_commands
    except Exception as e:
        return f"Error loading file: {str(e)}"

if __name__ == "__main__":
    # Initialize the Qt Application
    app = QGuiApplication(sys.argv)

    # Set up the QML engine and load the main QML file
    engine = QQmlApplicationEngine()
    file_loader = FileLoader()
    gcode_handler = Parser_Gcode()
    serial_handler = SerialHandler()
    notification_handler = Test_notification()

    engine.rootContext().setContextProperty("serial_communication", serial_handler)

    # Expose the FileLoader class to QML
    engine.rootContext().setContextProperty("fileLoader", file_loader)

    # Expose the gcode class to QML
    engine.rootContext().setContextProperty('gcode_reader', gcode_handler)

    #test notification
    engine.rootContext().setContextProperty('notification', notification_handler)

    # Load the QML file
    engine.load("display.qml")

    # Exit the application when the QML window is closed
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())
