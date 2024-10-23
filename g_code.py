import sys
import os
from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine

import serial.tools.list_ports

class SerialHandler(QObject):
    messageReceived = pyqtSignal(str, arguments=['message'])
    def __init__(self):
        QObject.__init__(self)

    @pyqtSlot(result=list)
    def fetchComPorts(self):
        ports = serial.tools.list_ports.comports()
        for port in ports:
            print(f"Port: {port.device}, Description: {port.description}, HWID: {port.hwid}")
        return [port.device for port in ports]

    @pyqtSlot(str)
    def connectComPort(self, port_name):
        print(f"Connecting to {port_name}")
        try:
            # default baud rate is 115200, but you can change it as needed
            self._serial = serial.Serial(port_name, 115200)
            print(f"Connected to {port_name}")
        except Exception as e:
            print(f"Error: {e}")
    
    @pyqtSlot(str, result=str)
    def sendData(self, data):
        print(f"Sending data: {data}")
        try:
            self._serial.write(data.encode())
            print(f"Data sent successfully")
        except Exception as e:
            print(f"Error sending data: {e}")

    @pyqtSlot(result=str)
    def receiveData(self):
        print("Receiving data...")
        try:
            while self._serial.is_open():
                if self._serial.in_waiting > 0:
                    data = self._serial.readline().decode().strip()
                    print(f"Received data: {data}")
                    self.messageReceived.emit(data)
        except Exception as e:
            print(f"Error receiving data: {e}")

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

# Initialize the Qt Application
app = QGuiApplication(sys.argv)

# Set up the QML engine and load the main QML file
engine = QQmlApplicationEngine()
file_loader = FileLoader()

serial_handler = SerialHandler()

engine.rootContext().setContextProperty("serial_communication", serial_handler)

# Expose the FileLoader class to QML
engine.rootContext().setContextProperty("fileLoader", file_loader)

# Load the QML file
engine.load("display.qml")

# Exit the application when the QML window is closed
if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec_())
