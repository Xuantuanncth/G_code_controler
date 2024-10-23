import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

ApplicationWindow {
    visible: true
    width: 1170
    height: 805
    title: "G Code Control"
    color: "white"
    // border.color: "black"
    // border.width: 1

    property var comPorts: []
    property var debug_app:true
    property string selectedPort: ""

    // Left side for information display
    Rectangle {
        id: leftParent
        width: 830
        height: 800
        color: "white"
        anchors.left: parent.left

        // First section
        Rectangle {
            id: st1Child
            width: 830
            height: 540
            color: "#D9D9D9"
            radius: 8
            anchors.top:parent.top
            anchors.left: parent.left
            anchors.topMargin: 10
            anchors.leftMargin: 10

            // Title
            Text {
                id: name
                text: "G code control"
                font.pixelSize: 24
                color: "black"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 20
                anchors.leftMargin: 10
            }

            // About
            Text {
                id: about
                text: "About"
                font.pixelSize: 16
                font.italic: true
                color: "black"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 40
                anchors.rightMargin: 40
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        parent.scale = 1.2
                        parent.color = "blue"
                    }
                    onExited: {
                        parent.scale = 1
                        parent.color = "black"
                    }
                }
            }

            // Drawing Area
            Rectangle {
                id: draw
                width: 800
                height: 450
                radius: 8
                color: "white"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 80
                anchors.leftMargin: 10
            }
        }

        // Second section
        Rectangle {
            id: st2Child
            width: 830
            height: 236
            color: "#D9D9D9"
            radius: 8
            anchors.top: st1Child.bottom
            anchors.left: parent.left
            anchors.topMargin: 10
            anchors.leftMargin:10

            // Console Log Title
            Text {
                id: text_console
                text: "Console log"
                font.pixelSize: 16
                color: "black"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 10
            }

            // Console log area
            Rectangle {
                id: consoleLog
                width: 600
                height: 188
                color: "white"
                radius: 8
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 35
                anchors.leftMargin: 10

                Text {
                    id: consoleText
                    text: ""
                    font.pixelSize: 14
                    color: "black"
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 10
                    anchors.leftMargin: 10
                }
            }

            // Command Label
            Text {
                text: "Command"
                font.pixelSize: 16
                color: "black"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 10
                anchors.rightMargin: 80
            }

            // Command input area
            Rectangle {
                id: command
                width: 190
                height: 115
                radius: 8
                color: "white"
            
                anchors.top: parent.top
                anchors.left: consoleLog.right
                anchors.topMargin: 35
                anchors.leftMargin: 10

                TextEdit {
                    id: inputField
                    width: parent.width - 20
                    height: parent.height -20
                    anchors.centerIn:parent
                    font.pixelSize: 18
                    text:""
                    color:"black"
                    wrapMode: TextEdit.Wrap

                }
            }

            // Send Button
            Rectangle {
                id:button_send_command
                width: 150
                height: 50
                anchors.top: command.bottom
                anchors.horizontalCenter: command.horizontalCenter
                anchors.topMargin: 20

                radius: 8
                color: "white"

                // background: Rectangle {
                //     radius: 8
                //     color: "white"
                // }
                Text {
                    text: "Send"
                    font.pixelSize: 24
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                }
                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    onEntered: {
                        button_send_command.color = "#888888"  // Change button color on hover
                    }
                    onExited: {
                        button_send_command.color = "white"  // Revert button color when mouse leaves
                    }
                    onPressed: button_send_command.scale = 0.95
                    onReleased: button_send_command.scale = 1.0

                    onClicked: {
                        serial_communication.sendData(inputField.text)
                    }
                }
            }
        }
    }

    // Right side for control
    Rectangle {
        id: rightParent
        width: 320
        height: 800
        anchors.right: parent.right

        // COM Select Section
        Rectangle {
            id: comSelect
            width: 280
            height: 100
            radius: 8
            color: "#F6F3F3"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10

            // COM Text
            Text {
                id: text_COM
                text: "COM"
                font.pixelSize: 14
                color: "black"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 25
                anchors.leftMargin: 20
            }

            // COM Select Box
            ComboBox {
                id: portSelector
                width: 102
                height: 30
                model: comPorts

                background: Rectangle {
                    radius: 8
                    color: "white"
                }
                anchors.left: text_COM.right
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.leftMargin: 10

                onCurrentIndexChanged: {
                    selectedPort = comPorts[portSelector.currentIndex]
                }
            }

            // Connect Button
            Button {
                id: connect_button
                // highlighted : true
                width: 90
                height: 30
                background: Rectangle {
                    radius: 8
                    color: "#E4E4E4"
                }
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 20
                anchors.rightMargin: 10

                text: "Connect"
                font.bold: true
                font.pixelSize: 13
                MouseArea {
                    id: buttonMouseArea
                    anchors.fill: parent
                    onPressed: {
                        connect_button.background.color = "#CCCCCC"  // Change color when pressed
                        // console.log("Button pressed")
                    }
                    onReleased: {
                        connect_button.background.color = "#E4E4E4"  // Revert color when released
                        // console.log("Button released")
                        // Perform connect logic here
                    }
                    onClicked: {
                        if (selectedPort !== "") {
                            // Call Python function to connect to the COM port
                            connectToComPort(selectedPort)
                        } else {
                            console.log("No COM port selected")
                        }
                    }
                }

            }

            // File label text
            Text {
                id: file_label
                text: "File"
                font.pixelSize: 14
                color: "black"
                anchors.left: parent.left
                anchors.top: text_COM.top
                anchors.topMargin: 35
                anchors.leftMargin: 20
            }

            // File directory text
            Text {
                id: file_url
                text: ""
                font.pixelSize: 14
                color: "black"
                anchors.left: file_label.right
                anchors.top: text_COM.top
                anchors.topMargin: 35
                anchors.leftMargin: 20
            }

            // Open Button
            Button {
                width: 90
                height: 30

                background: Rectangle {
                    radius: 8
                    color: "#E4E4E4"
                }
                anchors.right: parent.right
                anchors.top: connect_button.bottom
                anchors.topMargin: 10
                anchors.rightMargin: 10

                text: "Open"
                font.bold: true
                font.pixelSize: 12

                onClicked: fileDialog.open()
            }
        }

        // Controls side
        Rectangle {
            id: control_side
            width: 280
            height: 100
            radius: 8
            color: "#D9D9D9"
            anchors.top: comSelect.bottom
            anchors.left: parent.left
            anchors.topMargin: 20
            anchors.leftMargin:10

            // Start Button
            Button {
                id: buttonStart
                width: 70
                height: 30
                flat: true

                background: Rectangle {
                    radius: 8
                    color: "white"
                }
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 10

                text: "Start"
                font.pixelSize: 14
                font.bold:true
            }

            // Go to Root Button
            Button {
                id: buttonGotoRoot
                width: 70
                height: 30

                background: Rectangle {
                    radius: 8
                    color: "white"
                }
                anchors.left: buttonStart.right
                anchors.top: parent.top
                anchors.leftMargin: 40
                anchors.topMargin: 10

                text: "Root"
                font.pixelSize: 14
            }

            // Speed Select Box
            ComboBox {
                id: speed_selectBox
                width: 90
                height: 30
                model: ["1x", "2x", "3x"]

                background: Rectangle {
                    radius: 8
                    color: "white"
                }
                anchors.left: parent.left
                anchors.top: buttonStart.bottom
                anchors.topMargin: 15
                anchors.leftMargin: 10
            }

            // Go to Root Button
            Button {
                id: button_setspeed
                width: 70
                height: 30

                background: Rectangle {
                    radius: 8
                    color: "white"
                }
                anchors.left: speed_selectBox.right
                anchors.top: buttonGotoRoot.bottom
                anchors.leftMargin: 20
                anchors.topMargin: 15

                text: "Set"
                font.pixelSize: 14
            }
        }

        // Grid layout at the bottom
        Rectangle {
            width: 300
            height: 300
            // anchors.left: parent.left
            anchors.top: control_side.bottom
            anchors.topMargin: 100

            GridLayout {
                id: gridLayout
                columns: 3
                rows: 3
                anchors.fill: parent

                Repeater {
                    model: 9
                    Rectangle {
                        width: 100
                        height: 100
                        // color: (index === 1 || index === 3 || index === 4 || index === 5 || index === 7) ? "red" : "transparent"
                        Image {
                            anchors.fill: parent  
                            source: (index === 1)  ? "./image/y_plus.png"   : 
                                    ((index === 3) ? "./image/x_minus.png"  : 
                                    ((index === 4) ? "./image/zero.png"     : 
                                    ((index === 5) ? "./image/x_plus.png"   : 
                                    (index === 7)  ? "./image/y_minus.png"  :
                                    "")))
                            fillMode: Image.PreserveAspectFit 
                        }

                        MouseArea {
                            anchors.fill:parent
                            hoverEnabled: true 
                            onPressed: {
                                if (index === 1 || index === 3 || index === 4 || index === 5 || index === 7) {
                                    parent.scale = 0.95  // Darken the background when mouse enters
                                }
                            }

                            onReleased: {
                                if (index === 1 || index === 3 || index === 4 || index === 5 || index === 7) {
                                    parent.scale = 1  // Revert the color when mouse leaves
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // Load available COM ports from Python
        loadComPorts()
    }
    
    /*!
        \qmlmethod void loadComPorts()
    
        Loads and populates the list of available COM ports.
    
        This function fetches the available COM ports using the Python backend,
        updates the comPorts property, and sets the model for the portSelector ComboBox.
        If debug mode is enabled, it also logs the available ports to the console.
    */
    function loadComPorts() {
        // This will be linked to a Python function to fetch available ports
        var availablePorts = serial_communication.fetchComPorts();
        if(debug_app){
            console.log("[DEBUG] LoadComPorts: ", availablePorts)
        }
        comPorts = availablePorts;
        portSelector.model = comPorts;
    }
    
    /*!
        \qmlmethod void connectToComPort(string portName)
    
        Initiates a connection to the specified COM port.
    
        This function calls the Python backend to establish a connection
        with the selected COM port.
    
        \param portName The name of the COM port to connect to.
    */
    function connectToComPort(portName) {
        // This will call Python to connect to the selected COM port
        serial_communication.connectComPort(portName);
    }
    
    /*!
        \qmltype Connections
        \inqmlmodule QtQuick 2.15
    
        \brief Handles messages received from the serial communication.
    
        This Connections object listens for the messageReceived signal
        from the serial_communication object and updates the consoleText
        with the received message.
    */
    Connections {
        target: serial_communication
        onMessageReceived: {
            consoleText.text = message
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select a File"
        folder: shortcuts.home  // Start folder
        onAccepted: {
            console.log("Selected file:", fileDialog.fileUrl)
            var fileUrl = fileDialog.fileUrl.toString()
            var fileParts = fileUrl.split("/")
            file_url.text = fileParts[fileParts.length - 1]
            // fileLoader.loadFile(fileDialog.fileUrl)
        }
        onRejected: {
            console.log("File selection canceled")
        }
    }
}
