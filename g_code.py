import sys
from PyQt5.QtCore import QObject, pyqtSlot
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine

# Define a class to handle the file loading functionality
class FileLoader(QObject):
    def __init__(self):
        QObject.__init__(self)

    @pyqtSlot(result=str)
    def loadFile(self):
        file_name = "example.txt"  # Replace with any text file path you want to load
        try:
            with open(file_name, 'r') as file:
                content = file.read()
                return content
        except Exception as e:
            return f"Error loading file: {str(e)}"

# Initialize the Qt Application
app = QGuiApplication(sys.argv)

# Set up the QML engine and load the main QML file
engine = QQmlApplicationEngine()
file_loader = FileLoader()

# Expose the FileLoader class to QML
engine.rootContext().setContextProperty("fileLoader", file_loader)

# Load the QML file
engine.load("display.qml")

# Exit the application when the QML window is closed
if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec_())
