import QtQuick 2.2
import QtGraphicalEffects 1.0

Item {
    id: button
    signal clicked

    property alias text: continguts.text
    property alias fontSize: continguts.font.pixelSize
    property alias color: buttonRect.color
    property bool available: true

    height: (available)?units.fingerUnit:0
    width: (available)?continguts.paintedWidth + units.nailUnit * 2:0
    visible: available

    states: [
        State {
            name: ''
            PropertyChanges {
                target: buttonShadow
                glowRadius: Math.round(units.nailUnit / 2)
            }
        },
        State {
            name: 'pressing'
            PropertyChanges {
                target: buttonShadow
                glowRadius: Math.round(units.nailUnit / 4)
            }
        },

        State {
            name: 'pressed'
            PropertyChanges {
                target: buttonShadow
                glowRadius: units.nailUnit
            }
        }
    ]
    state: ''
    transitions: [
        Transition {
            NumberAnimation {
                target: buttonShadow
                properties: 'glowRadius'
                easing.type: Easing.InOutQuad
                duration: 200
            }
        }
    ]

    RectangularGlow {
        id: buttonShadow
        color: '#444444'
        anchors.fill: buttonRect
        glowRadius: Math.round(units.nailUnit / 2)
        cornerRadius: glowRadius + buttonRect.radius
        spread: 0.5
    }

    Rectangle {
        id: buttonRect
        anchors.fill: parent
        anchors.margins: Math.round(units.nailUnit / 2)

        color: 'gray'
        radius: units.nailUnit

        Text {
            id: continguts
            anchors.fill: parent
            font.pixelSize: units.readUnit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        MouseArea {
            anchors.fill: parent
            onPressed: button.state = 'pressing';

            onClicked: {
                button.state = 'pressed';
                button.clicked();
                button.state = '';
            }
            onExited: button.state = ''
            onCanceled: button.state = ''
        }
    }

}

