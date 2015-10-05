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
        property int requiredHeight: Math.max(textVisor.contentHeight, units.fingerUnit) + units.fingerUnit
        property string shownContent: ''

        onShownContentChanged: textVisor.getReadableText()

        RowLayout {
            id: buttonsLayout
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: units.fingerUnit

            Button {
                id: copyButton

                Layout.fillHeight: true
                text: qsTr('Copia')
                onClicked: clipboard.copia(textVisor.text)
            }

            Button {
                id: sendButton

                Layout.fillHeight: true
                text: qsTr('Envia')
                onClicked: Qt.openUrlExternally("mailto:?subject=Anotació&body=" + encodeURIComponent(itemVisor.shownContent))
            }

            Button {
                id: markdownButton

                Layout.fillHeight: true
                text: qsTr('MarkDown')
                checkable: true
                checked: true
                onClicked: textVisor.getReadableText()
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
    }


    editorComponent: Editors.TextAreaEditor2 {
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

