import QtQuick 2.3
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

CollectionInspectorItem {
    id: editText

    Common.UseUnits { id: units }

    clip: true

    visorComponent: Text {
        id: textVisor
        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
        property string shownContent: ''

        text: textVisor.shownContent
        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        Button {
            id: markdownButton

            anchors {
                top: parent.top
                right: parent.right
            }
            height: units.fingerUnit
            text: qsTr('MarkDown')
            checkable: true
            checked: true
            onClicked: textVisor.getReadableText()
        }

        onShownContentChanged: textVisor.getReadableText()

        function getReadableText() {
            textVisor.text = (markdownButton.checked)?parser.toHtml(textVisor.shownContent):textVisor.shownContent;
        }

        MarkDownParser {
            id: parser
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

