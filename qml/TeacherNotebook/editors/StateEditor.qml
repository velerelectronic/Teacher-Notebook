import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import '../common' as Common

Common.AbstractEditor {
    id: editor
    property string content: ''

    Common.UseUnits { id: units }

    height: units.fingerUnit + units.nailUnit * 2

    CheckBox {
        id: eventDoneButton
        anchors.fill: parent
        anchors.margins: units.nailUnit
        checked: editor.content == 'done'
        text: qsTr('Finalitzat')
        onClicked: {
            editor.content = (checked)?'done':'';
            editor.setChanges(true);
        }
    }
}
