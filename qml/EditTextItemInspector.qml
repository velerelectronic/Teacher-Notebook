import QtQuick 2.3
import QtQuick.Controls 1.2
import 'qrc:///common' as Common

CollectionInspectorItem {
    id: editText

    Common.UseUnits { id: units }

    clip: true

    visorComponent: Text {
        id: textVisor
        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
        property alias shownContent: textVisor.text

        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    editorComponent: TextField {
        id: textEditor
        property int requiredHeight: units.fingerUnit * 2
        property alias editedContent: textEditor.text

        clip: true
        font.pixelSize: units.readUnit

        // wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
//        inputMethodHints: Qt.ImhNoPredictiveText

        onTextChanged: editText.setChanges(true)
        onVisibleChanged: {
            if (visible) {
                forceActiveFocus();
            }
        }
    }
}

