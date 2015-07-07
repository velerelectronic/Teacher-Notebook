import QtQuick 2.3
import QtQuick.Controls 1.2
import 'qrc:///common' as Common

CollectionInspectorItem {
    id: editState

    Common.UseUnits { id: units }

    clip: true

    visorComponent: Text {
        id: textVisor
        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
        property string shownContent

        text: (textVisor.shownContent === 'done')?qsTr('Fet'):qsTr('Obert')
        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    editorComponent: CheckBox {
        id: eventDoneButton
        property int requiredHeight: units.fingerUnit * 2
        property string editedContent

        checked: editedContent === 'done'
        text: qsTr('Finalitzat')
        onClicked: {
            editedContent = (checked)?'done':'';
            editState.setChanges(true);
        }
    }

}

