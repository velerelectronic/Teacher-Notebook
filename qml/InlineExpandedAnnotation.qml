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
    property string descText: ''

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
        contentHeight: groupAnnotationItem.height
        contentWidth: groupAnnotationItem.width
        clip: true

        Item {
            id: groupAnnotationItem

            property int interspacing: units.nailUnit
            width: flickableText.width
            height: Math.max(gotoPreviousText.height + headerData.height + titleRect.height + contentText.requiredHeight + gotoNextText.height + 4 * groupAnnotationItem.interspacing, flickableText.height)

            ColumnLayout {
                anchors.fill: parent
                spacing: groupAnnotationItem.interspacing

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

                Item {
                    id: titleRect

                    Layout.preferredHeight: titleText.height + 2
                    Layout.fillWidth: true

                    Text {
                        id: titleText
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }

                        height: Math.max(contentHeight, units.fingerUnit)
                        font.pixelSize: units.glanceUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                    Rectangle {
                        anchors {
                            top: titleText.bottom
                            left: parent.left
                            right: parent.right
                        }
                        height: 2
                        color: 'black'
                    }

                }

                Text {
                    id: contentText
                    property int requiredHeight: Math.max(contentHeight, units.fingerUnit)

                    Layout.fillHeight: true
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

    function getText(newTitle,newDesc,start,end, labels) {
        identifier = newTitle;
        flickableText.contentY = gotoPreviousText.height;
        startText.text = qsTr('Inici: ') + start;
        endText.text = qsTr('Final: ') + end;
        labelsText.text = '# ' + labels;
        titleText.text = newTitle;
        descText = newDesc;
        contentText.text = parser.toHtml(newDesc);
    }

    MarkDownParser {
        id: parser
    }
}

