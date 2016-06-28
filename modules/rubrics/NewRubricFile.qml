import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Item {
    id: newRubricFileItem

    property string sourceFolder: ''

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit
        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: sourceFolder
        }
    }
}
