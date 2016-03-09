import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

Item {
    id: inlineExpandedAnnotation

    signal gotoPreviousAnnotation()
    signal gotoNextAnnotation()
    signal openExternalViewer(string identifier)
    signal closeView()

    property string identifier: ''

//    color: 'yellow'

    Flickable {
        id: flickableText
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            margins: units.nailUnit
        }
        width: parent.width - 2 * anchors.margins
        contentHeight: groupAnnotationItem.height + units.nailUnit * 2
        contentWidth: groupAnnotationItem.width
        clip: true

        Item {
            id: groupAnnotationItem

            width: flickableText.width
            height: gotoPreviousText.height + headerData.height + contentText.height + gotoNextText.height

            ColumnLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                spacing: units.nailUnit

                Text {
                    id: gotoPreviousText

                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: 'gray'
                    font.pixelSize: units.glanceUnit
                    text: qsTr('Anterior')
                    MouseArea {
                        anchors.fill: parent
                        onClicked: gotoPreviousAnnotation()
                    }
                }

                Rectangle {
                    id: headerData
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    border.color: 'black'

                    RowLayout {
                        anchors.fill: parent
                        spacing: units.nailUnit
                        Text {
                            id: startText
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                        }
                        Text {
                            id: endText
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                        }
                        Text {
                            id: labelsText
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: 'green'
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: inlineExpandedAnnotation.openExternalViewer(identifier)
                    }
                }

                Text {
                    id: contentText
                    Layout.preferredHeight: Math.max(contentHeight, flickableText.height)
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    onLinkActivated: openExternalViewer(link)
                }

                Text {
                    id: gotoNextText
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: 'gray'
                    font.pixelSize: units.glanceUnit
                    text: qsTr('Posterior')
                    MouseArea {
                        anchors.fill: parent
                        onClicked: gotoNextAnnotation()
                    }
                }
            }
        }

    }

    Common.ImageButton {
        anchors {
            top: parent.top
            right: parent.right
        }

        size: units.fingerUnit
        image: 'road-sign-147409'
        onClicked: inlineExpandedAnnotation.closeView()
    }

    function getText(newTitle,newDesc,start,end, labels) {
        identifier = newTitle;
        flickableText.contentY = gotoPreviousText.height;
        startText.text = qsTr('Inici: ') + start;
        endText.text = qsTr('Final: ') + end;
        labelsText.text = '# ' + labels;
        contentText.text = "<h1>" + newTitle + "</h1>" + parser.toHtml(newDesc);
    }

    MarkDownParser {
        id: parser
    }
}

