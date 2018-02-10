import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common


Rectangle {
    id: navigationPaneBase

    signal headingSelected()

    default property Component innerComponent

    property alias innerItem: innerItemLocation.item

    property int lateralMargins: units.fingerUnit
    property int headingHeight: units.fingerUnit * 2
    property string headingText: 'Navigation Pane'
    property string headingColor: 'white'

    function setSource(page, properties) {
        innerItemLocation.setSource(page, properties);
    }

    onInnerComponentChanged: innerItemLocation.sourceComponent = innerComponent;

    Common.UseUnits {
        id: units
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0

        spacing: 0

        Item {
            Layout.preferredWidth: lateralMargins
            Layout.fillHeight: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                id: headingTextItem

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: navigationPaneBase.headingHeight

                padding: units.nailUnit
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                font.pixelSize: units.readUnit
                font.bold: true

                color: headingColor

                text: headingText

                MouseArea {
                    anchors.fill: parent

                    onClicked: headingSelected()
                }
            }

            Loader {
                id: innerItemLocation

                anchors {
                    top: headingTextItem.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                sourceComponent: innerComponent
            }
        }

        Item {
            Layout.preferredWidth: lateralMargins
            Layout.fillHeight: true
        }
    }
}
