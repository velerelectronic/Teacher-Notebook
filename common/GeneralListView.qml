import QtQuick 2.5
import QtQuick.Layouts 1.1

Item {
    id: mainListView

    UseUnits {
        id: units
    }

    property Component toolBar: Rectangle {
        color: green
    }
    property Component headingBar: null
    property Component listDelegate: null
    property Component selectionBox: null

    property alias delegate: innerListView.delegate
    property alias model: innerListView.model

    property Component footerBar: null

    states: [
        State {
            name: 'show'

            PropertyChanges {
                target: selectionBoxLoader
                visible: false
            }
        },
        State {
            name: 'selection'

            PropertyChanges {
                target: selectionBoxLoader
                visible: true
            }
        }
    ]
    state: 'show'

    ColumnLayout {
        anchors.fill: parent

        Loader {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            sourceComponent: toolBar
        }

        ListView {
            id: innerListView

            Layout.fillHeight: true
            Layout.fillWidth: true

            spacing: units.nailUnit

            headerPositioning: ListView.OverlayHeader
            header: Loader {
                z: 2
                width: mainListView.width
                height: units.fingerUnit * 2

                sourceComponent: headingBar
            }

            clip: true

            delegate: Loader {
                z: 1
                width: mainListView.width
                height: units.fingerUnit * 2

                sourceComponent: listDelegate
            }

            footer: Loader {
                width: mainListView.width
                height: units.fingerUnit * 2

                sourceComponent: footerBar
            }

            Loader {
                id: selectionBoxLoader

                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: units.fingerUnit
                }
                height: units.fingerUnit * 2

                sourceComponent: selectionBox
            }

        }

    }

    function toggleSelection() {
        if (mainListView.state == 'show')
            mainListView.state = 'selection';
        else
            mainListView.state = 'show';
    }

    function enableSelection() {
        mainListView.state = 'selection';
    }

    function disableSelection() {
        mainListView.state = 'show';
    }

}

