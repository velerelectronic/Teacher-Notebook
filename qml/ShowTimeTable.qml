import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates
import PersonalTypes 1.0

Common.AbstractEditor {
    id: annotationEditor
    property string pageTitle: qsTr("Horari")

    signal closePage(string message)

    property string identifier

    Common.UseUnits { id: units }

    color: 'gray'

    ColumnLayout {
        id: daysLayout

        anchors.fill: parent
        spacing: units.nailUnit

        Repeater {
            model: 7
            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: daysLayout.width / 7

                ListView {
                    id: singleDayList
                    anchors.fill: parent
                    model: 10
                    spacing: units.nailUnit
                    delegate: Rectangle {
                        color: 'white'
                        width: singleDayList.width
                        height: singleDayList.height / singleDayList.count
                    }
                }
            }
        }
    }
}
