import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Item {
    id: inlineExpandedAnnotation

    signal gotoPreviousAnnotation()
    signal gotoNextAnnotation()
    signal openExternalViewer(string identifier)
    signal closeView()

    signal closeEditor()
    signal openTitleEditor()
    signal openDescriptionEditor()
    signal openPeriodEditor()
    signal openLabelsEditor()

    signal requestSaveDescription(string content)

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

        visible: flickableText.enabled
        enabled: !editorLoader.enabled

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
                    Common.ImageButton {
                        anchors {
                            top: parent.top
                            right: parent.right
                        }

                        size: units.fingerUnit
                        image: 'edit-153612'
                        onClicked: editorLoader.changeEditor('descEditor', inlineExpandedAnnotation.descText)
                    }
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

    Loader {
        id: editorLoader

        anchors.fill: flickableText

        property string newContent: ''
        visible: editorLoader.enabled

        states: [
            State {
                name: 'viewer'
                PropertyChanges {
                    target: editorLoader
                    enabled: false
                }
            },
            State {
                name: 'titleEditor'
            },
            State {
                name: 'descEditor'
                PropertyChanges {
                    target: editorLoader
                    sourceComponent: descEditorComponent
                }
            },
            State {
                name: 'periodEditor'
            },
            State {
                name: 'labelsEditor'
            }
        ]
        state: 'viewer'

        transitions: [
            Transition {
                to: "descEditor"
                ScriptAction {
                    script: inlineExpandedAnnotation.openDescriptionEditor()
                }
            }
        ]

        onLoaded: {
            item.content = editorLoader.newContent;
        }

        function changeEditor(newEditor, newContent) {
            if (editorLoader.state == 'viewer') {
                editorLoader.newContent = newContent;
                editorLoader.state = newEditor;
                editorLoader.enabled = true;
            }
        }

        function getEditedContent() {
            return item.content;
        }
    }

    Component {
        id: descEditorComponent

        Editors.TextAreaEditor3 {

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

    function saveDescriptionContent() {
        saveEditorContents();
    }

    function saveEditorContents() {
        switch(editorLoader.state) {
        case 'descEditor':
            inlineExpandedAnnotation.requestSaveDescription(editorLoader.getEditedContent());
            break;
        }

        inlineExpandedAnnotation.closeEditor();
    }

    MarkDownParser {
        id: parser
    }
}

