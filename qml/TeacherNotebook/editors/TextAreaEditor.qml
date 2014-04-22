import QtQuick 2.0
import '../common' as Common

Common.AbstractEditor {
    id: editor
    property alias content: textarea.text

    Common.UseUnits { id: units }

    height: units.fingerUnit * 5 + units.nailUnit * 2

    Common.TextAreaEditor {
        id: textarea
        anchors.fill: parent
        anchors.margins: units.nailUnit

        border.color: 'black'
        fontPixelSize: units.nailUnit
        toolHeight: units.fingerUnit
        buttonMargins: units.nailUnit / 2
        wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
        onTextChanged: editor.setChanges(true)
    }
}
