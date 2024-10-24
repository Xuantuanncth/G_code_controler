import sys
import os
import threading
import time
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine

import serial.tools.list_ports

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

    def __init__(self):
        """
        Initialize the SerialHandler object.

        Sets up initial values for serial connection, read thread, and running state.
        """
        super().__init__()
        self.serial = None
        self.read_thread = None
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
