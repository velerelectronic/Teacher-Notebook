import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import 'qrc:///common' as Common

Common.AbstractEditor {
    id: editor
    property alias content: textarea.text

    signal changesAccepted
    signal changesCanceled

    Common.UseUnits { id: units }

    height: units.fingerUnit * 5 + units.nailUnit * 2

    Common.TextAreaEditor {
        id: textarea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: buttons.top
        anchors.margins: units.nailUnit

//        border.color: 'black'
        fontPixelSize: units.readUnit
        toolHeight: units.fingerUnit
        buttonMargins: units.nailUnit
        wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
        onTextChanged: editor.setChanges(true)
    }

    RowLayout {
        id: buttons
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: units.fingerUnit
        Button {
            text: qsTr('Accepta')
            onClicked: changesAccepted()
        }
        Button {
            text: qsTr('Cancela')
            onClicked: changesCanceled()
        }
        Item {
            Layout.fillWidth: true
        }
    }
}
