import QtQuick 2.0
import '../common' as Common

// Show a single line of the first 5 elements

Rectangle {
    id: previewBox
    width: 100
    height: list.height
    anchors.margins: units.nailUnit
    clip: true

    property int maxItems: 5
    property alias delegate: list.delegate
    property int totalCount: 0
    property string caption: 'Heading'
    property string prefixTotal: 'There are'
    property string suffixTotal: 'items'
    property string captionBackgroundColor: '#CEF6CE'
    property string totalBackgroundColor: ''
    property alias model: list.model

    signal totalCountClicked()
    signal plusClicked()
    signal captionClicked()

    Common.UseUnits { id: units }

    border.color: 'black'

    ListView {
        id: list
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: contentItem.height

        interactive: false

        header: Rectangle {
            id: listHeader
            width: list.width
            border.width: 0
            height: Math.max(textHeader.contentHeight, units.fingerUnit) + units.nailUnit * 2
            color: previewBox.captionBackgroundColor

            Text {
                id: textHeader
                anchors.left: parent.left
                anchors.right: plusIcon.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: units.nailUnit
                font.bold: true
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: previewBox.caption
                verticalAlignment: Text.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: previewBox.captionClicked()
                }
            }
            Image {
                id: plusIcon
                source: 'qrc:///icons/plus-24844.svg'
                anchors.margins: units.nailUnit
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                height: units.fingerUnit
                width: units.fingerUnit
                MouseArea {
                    anchors.fill: parent
                    onClicked: plusClicked()
                }
            }
        }

        footer: (totalCount>-1)?previewFooter:emptyComponent

        Component {
            id: emptyComponent
            Item {
                width: 0
                height: 0
            }
        }

        Component {
            id: previewFooter
            Rectangle {
                width: list.width
                height: textFooter.height + units.nailUnit * 2
                border.width: 0
                color: previewBox.totalBackgroundColor

                Text {
                    id: textFooter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: units.nailUnit
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: (totalCount>-1)?(previewBox.prefixTotal + ' ' + totalCount + ' ' + previewBox.suffixTotal):previewBox.prefixTotal
                    MouseArea {
                        anchors.fill: parent
                        onClicked: previewBox.totalCountClicked()
                    }
                }
            }
        }
    }
}
