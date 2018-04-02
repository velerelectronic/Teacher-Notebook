import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import 'qrc:///common' as Common

Rectangle {
    id: spacesItem

    property string caption: ''
    property string qmlPage: ''
    property var pageProperties: null

    signal selectedSpace(int index)

    // z will contain the space index in the whole list

    border.color: 'black'

    Common.UseUnits {
        id: units
    }

    RectangularGlow {
        anchors.fill: parent
        color: 'black'
        glowRadius: units.nailUnit
        spread: 0.2
    }

    Rectangle {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            // Upper bar
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            RowLayout {
                anchors.fill: parent

                Common.ImageButton {
                    size: units.fingerUnit

                    image: 'outline-27146'
                }

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    padding: units.nailUnit

                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    text: caption
                }
            }

            MouseArea {
                anchors.fill: parent

                drag.target: spacesItem

                drag.axis: Drag.XandYAxis
                drag.minimumX: 0
                drag.minimumY: 0

                onPressed: {
                    selectedSpace(spacesItem.z);
                }
            }
        }
        Loader {
            id: pageLoader

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true

            function loadPage() {
                console.log('SETTINGG', 'qrc:///modules/' + qmlPage + ".qml", pageProperties);
                if ((qmlPage !== "") && (pageProperties !== null))
                    pageLoader.setSource('qrc:///modules/' + qmlPage + ".qml", pageProperties);
            }

            Connections {
                target: spacesItem
                onQmlPageChanged: pageLoader.loadPage()
                onPagePropertiesChanged: pageLoader.loadPage()
            }
        }
    }

    Component.onCompleted: {
        pageLoader.loadPage();
    }
}
