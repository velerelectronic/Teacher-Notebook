import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

CollectionInspectorItem {
    id: editText

    Common.UseUnits { id: units }

    QClipboard {
        id: clipboard
    }

    clip: true

    visorComponent: Item {
        id: itemVisor
        property int requiredHeight: Math.max(textVisor.height, units.fingerUnit) // + units.fingerUnit
        property string shownContent: ''

        onRequiredHeightChanged: console.log('new required height2', itemVisor.requiredHeight)
        onShownContentChanged: {
            textVisor.getReadableText();
        }

        RowLayout {
            id: buttonsLayout
            anchors {
                top: parent.top
                right: parent.right
            }
            height: units.fingerUnit

            Button {
                id: markdownButton

                Layout.fillHeight: true
                text: qsTr('MarkDown')
                checkable: true
                checked: true
                onClicked: textVisor.getReadableText()
            }
            Button {
                Layout.fillHeight: true
                height: units.fingerUnit
                text: qsTr('Més...')
                onClicked: {
                    editText.openMenu(units.fingerUnit * 2,menuComponent);
                }
            }
        }
        Text {
            id: textVisor

            anchors {
                top: buttonsLayout.bottom
                left: parent.left
                right: parent.right
            }
            height: contentHeight

            text: textVisor.shownContent

            font.pixelSize: units.readUnit
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere


            function getReadableText() {
                textVisor.text = (markdownButton.checked)?parser.toHtml(itemVisor.shownContent):itemVisor.shownContent;
            }

            MarkDownParser {
                id: parser
            }
        }

        Component {
            id: menuComponent
            Rectangle {
                id: menuRect

                property int requiredHeight: childrenRect.height + units.fingerUnit * 2

                signal closeMenu()

                color: 'white'
                ColumnLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    anchors.margins: units.fingerUnit

                    spacing: units.fingerUnit
                    Common.TextButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        fontSize: units.readUnit
                        text: qsTr('Copia')
                        onClicked: {
                            menuRect.closeMenu();
                            clipboard.copia(textVisor.text);
                        }
                    }
                    Common.TextButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        fontSize: units.readUnit
                        text: qsTr('Envia')
                        onClicked: {
                            menuRect.closeMenu();
                            Qt.openUrlExternally("mailto:?subject=Anotació&body=" + encodeURIComponent(itemVisor.shownContent));
                        }
                    }
                }
            }
        }
    }


    editorComponent: Editors.TextAreaEditor3 {
        id: textEditor
        property int requiredHeight: units.fingerUnit * 5
        property alias editedContent: textEditor.text

        clip: true

        wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
//        inputMethodHints: Qt.ImhNoPredictiveText

        onTextChanged: editText.setChanges(true)
        onVisibleChanged: {
            if (visible) {
                forceActiveFocus();
            }
        }
    }
}

