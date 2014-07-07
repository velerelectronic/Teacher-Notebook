import QtQuick 2.2
import QtQuick.Layouts 1.1

Rectangle {
    id: editor
    property alias dataModel: firstList.model

    height: childrenRect.height
    width: parent.width

    color: 'transparent'

    Flickable {
        id: flickableContents
        anchors.fill: parent
        contentWidth: width
        contentHeight: listContents.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Item {
            id: listContents
            width: flickableContents.width
            height: childrenRect.height

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: childrenRect.height

                Repeater {
                    id: firstList
                    model: editor.dataModel
                    delegate: Rectangle {
//                        radius: units.nailUnit * 2
//                        border.color: 'green'
                        color: 'white'
                        width: parent.width
                        height: childrenRect.height  + 2 * units.nailUnit

                        Text {
                            id: textRepeater
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: units.nailUnit
                            height: contentHeight
                            font.pixelSize: units.readUnit
                            color: 'green'
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: title
                        }
                        Column {
                            anchors.left: parent.left
                            anchors.top: textRepeater.bottom
                            anchors.right: parent.right
                            height: childrenRect.height
                            anchors.margins: units.nailUnit
                            Repeater {
                                model: dades
                                height: childrenRect.height
                                XmlListTextEditor {
                                    width: parent.width
                                    title: model.text
                                }
                            }
                        }

                    }
                }

            }
        }

    }



    Component.onCompleted: console.log('XmlMultiple Editor')
}
