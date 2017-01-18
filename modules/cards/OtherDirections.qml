import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import 'qrc:///common' as Common

Item {
    id: otherDirectionsPage

    signal mainPageSelected()
    signal selectedPage(string page, var parameters, string title)

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        RecentPagesCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            onSelectedPage: otherDirectionsPage.selectedPage(page, parameters, title)
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            text: qsTr('Principal')

            onClicked: mainPageSelected()
        }
    }

}
