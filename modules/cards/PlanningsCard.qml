import QtQuick 2.6
import QtQuick.Layouts 1.1
import 'qrc:///models' as Models
import 'qrc:///common' as Common
import 'qrc:///modules/plannings' as Plannings
import "qrc:///common/FormatDates.js" as FormatDates

BaseCard {
    requiredHeight: planningsList.contentItem.height

    signal planningSelected(string title)

    Models.PlanningsModel {
        id: planningsModel

        sort: 'category ASC, title ASC'

        searchFields: ['title', 'desc', 'category', 'fields']
    }

    ListView {
        id: planningsList

        anchors.fill: parent

        model: planningsModel
        interactive: false

        spacing: units.nailUnit

        section.property: 'category'
        section.delegate: Rectangle {
            width: planningsList.width
            height: units.fingerUnit

            color: 'gray'

            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                verticalAlignment: Text.AlignBottom
                font.pixelSize: units.readUnit
                font.bold: true
                elide: Text.ElideRight
                color: 'white'
                text: section
            }
        }

        delegate: Rectangle {
            id: singlePlanningRect

            width: planningsList.width
            height: units.fingerUnit

            clip: true

            property string planning: model.title

            MouseArea {
                anchors.fill: parent
                onClicked: planningSelected(model.title)
            }

            Text {
                anchors.fill: parent
                padding: units.nailUnit
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                text: model.title
            }
        }
    }

    function updateContents() {
        planningsModel.select();
    }

    Component.onCompleted: updateContents()
}
