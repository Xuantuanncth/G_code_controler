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
    property var connected_port: false
    property var debug_app:true
    property var is_running: false
    property var enable_button: true
    property var disabe_button: false
    property string selectedPort: ""
    property var gcodePath: []
    property var scaleFactor : 2
    property var v_TURN_LEFT: 1001
    property var v_TURN_RIGHT: 1002
    property var v_TURN_UP: 1003
    property var v_TURN_DOWN: 1004
    property var v_TURN_ZERO: 1005
    property var v_SET_ZERO: 1006

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

                    onClicked: {
                        about_information.open();
                    }
                }
            }

            // Drawing Area
            Rectangle {
                id: draw
                width: 800
                height: 450
                radius: 8
                // color: "white"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 80
                anchors.leftMargin: 10

                Canvas {
                    id: gcodeCanvas
                    width: parent.width - 300
                    height: parent.height - 20
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 10
                    anchors.leftMargin: 10

                    // Drawing G-code commands
                    // anchors.horizontalCenter: parent.horizontalCenter
                    anchors.centerIn: parent
                    contextType: "2d"

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, gcodeCanvas.width, gcodeCanvas.height)
                        // ctx.fillStyle = "lightblue"
                        
                        ctx.setTransform(1, 0, 0, 1, 0, 0)

                        ctx.strokeStyle = "blue"
                        ctx.lineWidth = 1
                        ctx.beginPath()

                        ctx.translate(0, gcodeCanvas.height);
                        ctx.scale(1, -1); //Put the root origin at the center of the canvas

                        // Debugging: Log length and first elements of gcodePath
                        console.log("gcodePath length: " + gcodePath.length)
                        // console.log("GcodePath: ",gcodePath)
                        if (gcodePath.length > 0) {
                            console.log("First command: " + gcodePath[0][0] + " X: " + gcodePath[0][1] + " Y: " + gcodePath[0][2])
                        }
                        var minX = 0, minY = 0  // Set limits for negative coordinates if necessary
                        for (var i = 0; i < gcodePath.length; i++) {
                            var cmd = gcodePath[i][0]
                            var x = gcodePath[i][1] != null ? Math.max(gcodePath[i][1], minX)*scaleFactor : null
                            var y = gcodePath[i][2] != null ? Math.max(gcodePath[i][2], minY)*scaleFactor : null
                            if (cmd === "G0" || cmd === "G1" || cmd === "G2" || cmd === "G3") {
                                if (x !== null && y !== null) {
                                    if (i === 0) {
                                        ctx.moveTo(x, y)
                                    } else {
                                        ctx.lineTo(x, y)
                                    }
                                }
                            }
                        }
                        ctx.stroke()
                    }
                }
                Canvas {
                    id: canvasGrid
                    property int gridSize: 20
                    width: parent.width - 300
                    height: parent.height - 20
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 10
                    anchors.leftMargin: 10
                    anchors.centerIn: parent

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, canvasGrid.width, canvasGrid.height);  // Clear canvas for each redraw

                        ctx.strokeStyle = "#cccccc";  // Grid line color
                        ctx.lineWidth = 1;

                        // Draw vertical grid lines
                        for (var x = 0; x < width; x += gridSize) {
                            ctx.beginPath();
                            ctx.moveTo(x, 0);
                            ctx.lineTo(x, height);
                            ctx.stroke();
                        }

                        // Draw horizontal grid lines
                        for (var y = 0; y < height; y += gridSize) {
                            ctx.beginPath();
                            ctx.moveTo(0, y);
                            ctx.lineTo(width, y);
                            ctx.stroke();
                        }
                    }

                    // Trigger repaint whenever the canvas size or gridSize changes
                    // onWidthChanged: canvas.requestPaint()
                    // onHeightChanged: canvas.requestPaint()
                    onGridSizeChanged: canvas.requestPaint()
                }

                Button {
                    id: btn_scaler_up
                    width: 50
                    height: 40

                    background: Rectangle {
                        color: "#E1E1E1"
                        radius: 8
                    }

                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 40
                    anchors.rightMargin: 40

                    Image {
                            source: "./image/arrow_up.png"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit 
                        }
                    MouseArea{
                        onPressed:{
                            btn_scaler_up.scale = 1.2
                        }

                        onClicked: {
                            
                            // scaleFactor /= 1.2
                            // gcodeCanvas.requestPaint()
                        }

                        onReleased: {
                            btn_scaler_up.scale = 1
                        }
                    }
                }
                Button {
                    id: btn_scaler_down
                    width: 50
                    height: 40

                    background: Rectangle {
                        color: "#E1E1E1"
                        radius: 8
                    }

                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 90
                    anchors.rightMargin: 40

                    Image {
                        source: "./image/arrow_down.png"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit 
                    }
                    MouseArea{
                        onPressed:{
                            btn_scaler_down.scale = 1.2
                        }

                        onClicked: {
                            
                            // scaleFactor /= 1.2
                            // gcodeCanvas.requestPaint()
                        }

                        onReleased: {
                            btn_scaler_down.scale = 1
                        }
                    }
                }
    
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
                anchors.topMargin: 10
                anchors.leftMargin: 10

                ScrollView {
                    id: scrollView
                    width: parent.width
                    height: parent.height
                    contentWidth: consoleText.width
                    contentHeight: consoleText.height

                    TextArea {
                        id: consoleText
                        text: ""
                        font.pixelSize: 14
                        color: "black"
                        wrapMode: TextArea.Wrap
                        readOnly: true

                        // onTextChanged: scrollView.contentY = scrollView.contentHeight - scrollView.height

                    }
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
                    selectByMouse: true

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
                        if(connected_port) {
                            serial_communication.sendData(inputField.text+'\r\n')
                        } else {
                            notifi_connectPort.open()
                        }
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
            height: 200
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
                        if ((selectedPort !== "") && (connected_port == false)) {
                            // Call Python function to connect to the COM port
                            connectToComPort(selectedPort)
                            connected_port = true
                            connect_button.text = "Disconnect"
                        } else if (connected_port == true) {
                            disconnectToComPort(selectedPort)
                            connect_button.text = "Connect"
                            connected_port = false
                        }
                        else {
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
                width: 100
                wrapMode: Text.Wrap
                anchors.left: file_label.right
                anchors.top: text_COM.top
                anchors.topMargin: 35
                anchors.leftMargin: 20
            }

            // Open Button
            Button {
                id: button_open_file
                width: 90
                height: 40

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
                
                MouseArea {
                    id: openFileMouseArea
                    anchors.fill: parent
                    onPressed: {
                        // console.log("Open button pressed")
                        button_open_file.background.color = "#CCCCCC"
                    }
                    onReleased: {
                        button_open_file.background.color = "#E4E4E4"
                    }

                    onClicked: fileDialog.open()
                }
            }
        }

        // Controls side
        Rectangle {
            id: control_side
            width: 280
            height: 200
            radius: 8
            color: "#D9D9D9"
            anchors.top: comSelect.bottom
            anchors.left: parent.left
            anchors.topMargin: 20
            anchors.leftMargin:10

            // Start Button
            Button {
                id: buttonStart
                width: 100
                height: 40
                // flat: true

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

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        buttonStart.background.color = "#CCCCCC"  // Change color when pressed
                        // console.log("Button pressed")
                    }
                    onReleased: {
                        buttonStart.background.color = "white"  // Revert color when released
                        // console.log("Button released")
                        // Perform start logic here
                    }
                    onClicked: {
                        if ((connected_port == true) && (is_running == false)) {
                            is_running = true
                            buttonStart.text = "Stop"
                            buttonStart.background.color = "red"
                            enabledOrDisabledButtons(disabe_button)
                            serial_communication.startSendGcode()
                        } else {
                            if( connected_port == false) {
                                notifi_connectPort.open()
                            }
                            is_running = false
                            buttonStart.text = "Start"
                            buttonStart.background.color = "white"
                            enabledOrDisabledButtons(enable_button)
                            console.log(gcode_reader.gcode_flags())
                        }
                    }
                }

            }

            // Go to Root Button
            Button {
                id: buttonGotoRoot
                width: 100
                height: 40

                background: Rectangle {
                    radius: 8
                    color: "white"
                }
                anchors.left: buttonStart.right
                anchors.top: parent.top
                anchors.leftMargin: 40
                anchors.topMargin: 10

                text: "Turn Zero"
                font.pixelSize: 14

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        buttonGotoRoot.background.color = "#CCCCCC"  // Change color when pressed
                        // console.log("Button pressed")
                    }
                    onReleased: {
                        buttonGotoRoot.background.color = "white"  // Revert color when released
                        // console.log("Button released")
                        // Perform goto root logic here
                    }

                    onClicked: {
                        // Perform goto root button click action here
                        if ((connected_port == true) && (is_running == fase)) {
                            //True case
                            console.log("Get device to root")
                            sendCommandToDevice(v_TURN_ZERO)
                        } else {
                            notifi_connectPort.open()
                        }
                    }
                }
            }

            Text {
                id: text_speed_label
                text: "Speed Run"
                font.pixelSize: 14
                color: "black"
                anchors.left: parent.left
                anchors.top: buttonStart.bottom
                anchors.topMargin: 10
                anchors.leftMargin: 20
            }

            // Speed Select Box
            ComboBox {
                id: speed_selectBox
                width: 100
                height: 40
                model: ["1x", "2x", "3x"]

                background: Rectangle {
                    radius: 8
                    color: "white"
                }
                anchors.left: parent.left
                anchors.top: text_speed_label.bottom
                anchors.topMargin: 10
                anchors.leftMargin: 10
            }

            // Go to Setspeed Button
            Button {
                id: button_setspeed
                width: 100
                height: 40

                background: Rectangle {
                    radius: 8
                    color: "white"
                }
                anchors.left: speed_selectBox.right
                anchors.top: text_speed_label.bottom
                anchors.leftMargin: 40
                anchors.topMargin: 10

                text: "Set Speed"
                font.pixelSize: 14
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        button_setspeed.background.color = "#CCCCCC"  // Change color when pressed
                        // console.log("Button pressed")
                    }
                    onReleased: {
                        button_setspeed.background.color = "white"  // Revert color when released
                        // console.log("Button released")
                        // Perform goto root logic here
                    }

                    onClicked: {
                        // Perform goto root button click action here
                        if ((connected_port == true) && (is_running == fase)) {
                            //True case
                            console.log("Set speed to device")
                        } else {
                            notifi_connectPort.open()
                        }
                    }
                }
            }
        }

        // Grid layout at the bottom
        Rectangle {
            id: control_direction
            width: 300
            height: 300
            // anchors.left: parent.left
            anchors.top: control_side.bottom
            anchors.topMargin: 50

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
                            onClicked: {
                                if (index === 1) {
                                    // Move up
                                    consoleText.text += "\n" + "Move up"
                                    sendCommandToDevice(v_TURN_UP)
                                } else if (index === 3) {
                                     // Move left
                                    consoleText.text += "\n" + "Move left"
                                    sendCommandToDevice(v_TURN_LEFT)
                                } else if (index === 4) {
                                    // Move to zero
                                    consoleText.text += "\n" + "Move to zero"
                                    sendCommandToDevice(v_SET_ZERO)
                                } else if (index === 5) {
                                     // Move right
                                    consoleText.text += "\n" + "Move right"
                                    sendCommandToDevice(v_TURN_RIGHT)
                                } else if (index === 7) {
                                     // Move down
                                    consoleText.text += "\n" + "Move down"
                                    sendCommandToDevice(v_TURN_DOWN)
                                } else {
                                    // Do nothing when clicked on the center button
                                    console.log("Clicked on center button")
                                }
                            }
                        }
                    }
                }
            }
        }

    }


    Popup {
        id: about_information
        width: 300
        height: 200
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2

        Rectangle {
            width: parent.width
            height: parent.height
            Rectangle {
                width: 25
                height: 25
                color: "red"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 0
                anchors.rightMargin: 0

                Text {
                    anchors.centerIn: parent
                    text: "X"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        about_information.close()
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: " This is the application of ABC"
                font.pixelSize: 16
                color: "black"
            }
        }
    }

    Popup {
        id: notifi_connectPort
        width: 300
        height: 200
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2

        Rectangle {
            width: parent.width
            height: parent.height

            Rectangle {
                width: 25
                height: 25
                color: "red"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 0
                anchors.rightMargin: 0

                Text {
                    anchors.centerIn: parent
                    text: "X"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    color: "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        notifi_connectPort.close()
                    }
                }
            }
        
            Text {
                anchors.centerIn: parent
                text: "Please connect port."
                wrapMode: Text.WordWrap
                font.pixelSize: 16
                color: "black"
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
    
    function disconnectToComPort(portName){
        serial_communication.disconnectComPort(portName);
    }

    function sendCommandToDevice(command){
        serial_communication.sendCommand(command);
    }

    function startRunning(){
        serial_communication.startRunning();
    }

    function enabledOrDisabledButtons(enable){
        buttonGotoRoot.enabled = enable
        button_setspeed.enabled = enable
        button_send_command.enabled = enable
        control_direction.enabled = enable
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
        function onMessageReceived(message) {
            console.log("Received message:", message)
            consoleText.text += "\n" + message
        }

        function onRunningFlag(flag){
            console.log("Running flag:", flag)
            is_running = false
            buttonStart.text = "Start"
            buttonStart.background.color = "white"
            enabledOrDisabledButtons(enable_button)

        }
    }

    Connections {
        target: gcode_reader
        function onDataParser(gcode_data) {
            console.log("Gcode data received done and Gcode length:", gcode_data.length)
            gcodePath = gcode_data
            gcodeCanvas.requestPaint()
            canvasGrid.requestPaint()
        }
    }

    Connections {
        target: notification
        function onNotification(message) {
            console.log("Notification:", message)
            notifi_connectPort.open()
        }
    }


    FileDialog {
        id: fileDialog
        title: "Select a File"
        folder: shortcuts.home 
        onAccepted: {
            console.log("Selected file:", fileDialog.fileUrl)
            var fileUrl = fileDialog.fileUrl.toString()
            var fileParts = fileUrl.split("/")
            file_url.text = fileParts[fileParts.length - 1]
            // fileLoader.loadFile(fileDialog.fileUrl)
            gcode_reader.load_gcode(fileDialog.fileUrl)

        }
        onRejected: {
            console.log("File selection canceled")
        }
    }
}
