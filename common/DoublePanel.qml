import QtQuick 2.2
import 'qrc:///common' as Common

Rectangle {
    id: doublePanel
    property alias colorMainPanel: mainPanel.color
    property alias colorSubPanel: subPanel.color
    property alias itemMainPanel: mainPanelLoader.sourceComponent
    property alias itemSubPanel: subPanelLoader.sourceComponent

    property int globalMargins: units.fluentMargins(width, units.nailUnit)
    property int widthSubPanel: Math.min(6 * units.fingerUnit + 2 * globalMargins,width)
    property int availableWidth: width - widthSubPanel

    Common.UseUnits {
        id: units
    }

    state: 'normal'

    function canShowBothPanels() {
        return availableWidth>2*widthSubPanel;
    }

    states: [
        State {
            name: 'shaded'
            AnchorChanges {
                target: subPanel
                anchors.left: parent.left
                anchors.right: undefined
            }
            PropertyChanges {
                target: shade
                opacity: (canShowBothPanels())?0:0.5
            }
        },
        State {
            name: 'normal'
            AnchorChanges {
                target: subPanel
                anchors.left: undefined
                anchors.right: (canShowBothPanels())?mainPanel.left:parent.left
            }
            PropertyChanges {
                target: shade
                opacity: 0.0
            }
        }
    ]

    Rectangle {
        id: mainPanel

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: (canShowBothPanels())?availableWidth:parent.width

        Loader {
            id: mainPanelLoader
            anchors.fill: parent
            anchors.margins: globalMargins
        }

        Rectangle {
            id: shade
            anchors.fill: parent
            color: 'black'
            MouseArea {
                anchors.fill: parent
                enabled: (doublePanel.state=='shaded')
                onPressed: toggleSubPanel()
            }
        }
    }
    Rectangle {
        id: subPanel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: widthSubPanel

        Loader {
            id: subPanelLoader
            anchors.fill: parent
            anchors.margins: globalMargins
        }
    }

    transitions: Transition {
        NumberAnimation {
            target: shade
            properties: 'opacity'
            duration: 300
            easing.type: Easing.InOutQuad
        }
        AnchorAnimation {
            targets: subPanel
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    function toggleSubPanel() {
        state = (state == 'shaded')?'normal':'shaded';
    }
}
