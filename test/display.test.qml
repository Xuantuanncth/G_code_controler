import QtQuick 2.15
import QtTest 1.2
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

TestCase {
    id: testCase
    name: "DisplayTests"
    
    ApplicationWindow {
        id: mainWindow
        visible: true
        width: 1170
        height: 805
        title: "G Code Control"
    }
}

function test_window_title() {
    compare(mainWindow.title, "G Code Control", "Application window title should be 'G Code Control'")
}

function test_com_port_selection() {
    var comboBox = findChild(mainWindow, "selectBox")
    verify(comboBox, "COM port selection ComboBox not found")
    
    compare(comboBox.model.length, 4, "ComboBox should have 4 COM port options")
    compare(comboBox.model[0], "COM1", "First COM port option should be COM1")
    compare(comboBox.model[1], "COM2", "Second COM port option should be COM2")
    compare(comboBox.model[2], "COM3", "Third COM port option should be COM3")
    compare(comboBox.model[3], "COM4", "Fourth COM port option should be COM4")
    
    comboBox.currentIndex = 2
    compare(comboBox.currentText, "COM3", "Selected COM port should be COM3")
}

function test_connect_button_color_change() {
    var connectButton = findChild(mainWindow, "connect_button")
    verify(connectButton, "Connect button should exist")

    var buttonMouseArea = findChild(connectButton, "buttonMouseArea")
    verify(buttonMouseArea, "Mouse area for connect button should exist")

    compare(connectButton.background.color, "#E4E4E4", "Initial button color should be #E4E4E4")

    mousePress(buttonMouseArea)
    compare(connectButton.background.color, "#CCCCCC", "Button color should change to #CCCCCC when pressed")

    mouseRelease(buttonMouseArea)
    compare(connectButton.background.color, "#E4E4E4", "Button color should revert to #E4E4E4 when released")
}