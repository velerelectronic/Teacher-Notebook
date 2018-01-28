import QtQuick 2.5
import QtQuick.Layouts 1.1

Item {
    id: mainListView

    UseUnits {
        id: units
    }

    property Component toolBar: Rectangle {
        color: 'green'
    }

    property int toolBarHeight: units.fingerUnit * 4 + units.nailUnit

    property Component headingBar: null
    property Component listDelegate: null
    property Component selectionBox: null

    property Component sectionDelegate: null
    property string sectionProperty: ''
    property int sectionCriteria
    property alias delegate: innerListView.delegate
    property alias model: innerListView.model

    property Component footerBar: null

    property int requiredHeight: toolBarLoader.height + innerListView.contentItem.height

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
        spacing: 0

        Loader {
            id: toolBarLoader

            Layout.preferredHeight: toolBarHeight
            Layout.fillWidth: true

            sourceComponent: toolBar
        }

        ListView {
            id: innerListView

            Layout.fillHeight: true
            Layout.fillWidth: true

            spacing: units.nailUnit

            snapMode: ListView.SnapToItem
            headerPositioning: ListView.OverlayHeader
            header: Loader {
                id: headerLoader

                z: 2
                width: mainListView.width
                height: units.fingerUnit * 2

                sourceComponent: headingBar

                onLoaded: {
                    if (typeof headerLoader.item.requiredHeight !== 'undefined')
                        headerLoader.height = Qt.binding(function() { return headerLoader.item.requiredHeight; });
                }
            }

            clip: true

            delegate: Loader {
                id: delegateLoader

                z: 1
                width: mainListView.width
                height: units.fingerUnit * 2

                sourceComponent: listDelegate

                onLoaded: {
                    //if (typeof delegateLoader.item.requiredHeight !== 'undefined')
                    //    delegateLoader.height = 100; // Qt.binding(function() { return delegateLoader.item.requiredHeight; });
                }
            }

            section.delegate: sectionDelegate
            section.property: sectionProperty
            section.criteria: sectionCriteria

            footer: Loader {
                id: footerLoader

                width: mainListView.width
                height: units.fingerUnit * 2

                sourceComponent: footerBar

                onLoaded: {
                    if (typeof footerLoader.item.requiredHeight !== 'undefined')
                        footerLoader.height = Qt.binding(function() { return footerLoader.item.requiredHeight; });
                }
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

                onLoaded: {
                    if (typeof selectionBoxLoader.item.requiredHeight !== 'undefined')
                        selectionBoxLoader.height = Qt.binding(function() { return selectionBoxLoader.item.requiredHeight; });
                }
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

