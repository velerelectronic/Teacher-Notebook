import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Item {
    property int section
    property string title

    signal close()
    signal sectionTitleChanged()

    property SqlTableModel sectionsModel

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.fingerUnit

        Common.BoxedText {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            text: qsTr('Títol')
        }

        Editors.TextAreaEditor3 {
            Layout.fillHeight: true
            Layout.fillWidth: true
            content: title

            onContentChanged: title = content
        }

        Common.TextButton {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            text: qsTr('Canvia el títol')
            onClicked: {
                sectionsModel.updateObject(section, {title: title});
                sectionTitleChanged();
            }
        }
    }
}
