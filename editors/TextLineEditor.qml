import QtQuick 2.5
import QtQuick.Controls 1.1
import 'qrc:///common' as Common

Common.AbstractEditor {
    id: editor
    property alias content: textline.text
    signal accepted()

    Common.UseUnits { id: units }

    height: units.fingerUnit + units.nailUnit * 2

    TextField {
        id: textline
        anchors.fill: parent
        anchors.margins: units.nailUnit
        clip: true
        font.pixelSize: units.readUnit
        // wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
//        inputMethodHints: Qt.ImhNoPredictiveText
        onTextChanged: editor.setChanges(true)
        onVisibleChanged: {
            if (visible) {
                forceActiveFocus();
            }
        }
        onAccepted: {
            console.log('ACCEPTED1');
            editor.accepted();
        }
    }
}
