import QtQuick 2.0
import '../common' as Common

Common.AbstractEditor {
    id: editor
    property alias content: textline.text

    Common.UseUnits { id: units }

    height: units.fingerUnit + units.nailUnit * 2

    TextInput {
        id: textline
        anchors.fill: parent
        anchors.margins: units.nailUnit
        clip: true
        font.pixelSize: units.nailUnit * 2
        wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
//        inputMethodHints: Qt.ImhNoPredictiveText
        onTextChanged: editor.setChanges(true)
        onVisibleChanged: {
            if (visible) {
                forceActiveFocus();
            }
        }
    }
}
