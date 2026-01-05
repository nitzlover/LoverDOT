import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    
    property color bgDeep: "#0a0a0a"
    property color bgDark: "#121212"
    property color bgCard: "#1a1a1a"
    property color bgElevated: "#242424"
    property color borderColor: "#2a2a2a"
    property color textMuted: "#666666"
    property color textSecondary: "#888888"
    property color textPrimary: "#e0e0e0"
    property color accent: "#3d3d3d"

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() { }
        function onLoginFailed() {
            password.text = ""
            errorMessage.text = textConstants.loginFailed
            errorMessage.opacity = 1
        }
    }

    // Background
    Image {
        id: background
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        
        layer.enabled: true
        layer.effect: FastBlur {
            radius: 32
        }
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: bgDeep
        opacity: 0.7
    }

    // Login container
    Rectangle {
        id: loginContainer
        width: 400
        height: 450
        anchors.centerIn: parent
        color: "transparent"
        
        // Card background
        Rectangle {
            anchors.fill: parent
            radius: 16
            color: bgCard
            opacity: 0.95
            border.color: borderColor
            border.width: 1
            
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 8
                radius: 32
                samples: 64
                color: "#80000000"
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 24
            width: parent.width - 80

            // Logo/Icon
            Text {
                text: "󰣇"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 64
                color: textPrimary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Welcome text
            Text {
                text: "Welcome"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 24
                font.weight: Font.Bold
                color: textPrimary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Username field
            TextField {
                id: username
                width: parent.width
                height: 48
                placeholderText: "Username"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                color: textPrimary
                
                background: Rectangle {
                    radius: 8
                    color: bgElevated
                    border.color: username.activeFocus ? accent : borderColor
                    border.width: 1
                }
                
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        password.focus = true
                    }
                }
            }

            // Password field
            TextField {
                id: password
                width: parent.width
                height: 48
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                color: textPrimary
                
                background: Rectangle {
                    radius: 8
                    color: bgElevated
                    border.color: password.activeFocus ? accent : borderColor
                    border.width: 1
                }
                
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(username.text, password.text, sessionSelect.currentIndex)
                    }
                }
            }

            // Error message
            Text {
                id: errorMessage
                text: ""
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                color: "#cc6666"
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0
                
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            // Login button
            Button {
                id: loginButton
                width: parent.width
                height: 48
                text: "Login"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.Bold
                
                background: Rectangle {
                    radius: 8
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: loginButton.pressed ? bgElevated : accent }
                        GradientStop { position: 1.0; color: loginButton.pressed ? bgCard : bgElevated }
                    }
                    border.color: borderColor
                    border.width: 1
                }
                
                contentItem: Text {
                    text: loginButton.text
                    font: loginButton.font
                    color: textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    sddm.login(username.text, password.text, sessionSelect.currentIndex)
                }
            }

            // Session selector
            ComboBox {
                id: sessionSelect
                width: parent.width
                height: 40
                model: sessionModel
                textRole: "name"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                
                background: Rectangle {
                    radius: 8
                    color: bgElevated
                    border.color: borderColor
                    border.width: 1
                }
                
                contentItem: Text {
                    text: sessionSelect.displayText
                    font: sessionSelect.font
                    color: textSecondary
                    leftPadding: 12
                    verticalAlignment: Text.AlignVCenter
                }
                
                currentIndex: sessionModel.lastIndex
            }
        }
    }

    // Clock
    Text {
        id: clock
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 48
        font.weight: Font.Light
        color: textPrimary
        
        function updateTime() {
            text = Qt.formatDateTime(new Date(), "HH:mm")
        }
        
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.updateTime()
        }
        
        Component.onCompleted: updateTime()
    }

    // Date
    Text {
        anchors.top: clock.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        color: textSecondary
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
    }

    // Power buttons
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16
        
        PowerButton {
            icon: "󰐥"
            onClicked: sddm.powerOff()
        }
        
        PowerButton {
            icon: "󰜉"
            onClicked: sddm.reboot()
        }
        
        PowerButton {
            icon: "󰤄"
            onClicked: sddm.suspend()
        }
    }

    component PowerButton: Button {
        property string icon: ""
        width: 48
        height: 48
        
        background: Rectangle {
            radius: 24
            color: parent.pressed ? bgElevated : bgCard
            border.color: borderColor
            border.width: 1
        }
        
        contentItem: Text {
            text: parent.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
            color: textSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Component.onCompleted: username.focus = true
}
