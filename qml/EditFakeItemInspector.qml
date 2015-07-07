import QtQuick 2.3
import QtQuick.Controls 1.2
import 'qrc:///common' as Common

CollectionInspectorItem {
    id: fakeEditItem

    Common.UseUnits { id: units }

    visorComponent: Text {
        id: textVisor
        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
        property alias shownContent: textVisor.text

        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    // No editor component
    editorComponent: null
}
