import QtQuick 2.6
import QtQuick.Layouts 1.1
import 'qrc:///models' as Models
import 'qrc:///common' as Common
import 'qrc:///modules/plannings' as Plannings
import "qrc:///common/FormatDates.js" as FormatDates

BaseCard {
    Common.UseUnits {
        id: units
    }

    requiredHeight: gridList.contentItem.height
    signal checklistsSelected()

    Models.AssessmentGridModel {
        id: assessmentModel

        sort: 'moment DESC, id DESC'
        limit: 10
    }

    ListView {
        id: gridList

        anchors.fill: parent

        model: assessmentModel
        interactive: false

        delegate: Item {
            width: gridList.width
            height: units.fingerUnit * 2
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 3

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    text: model.group
                }

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 3

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    text: model.momentCategory
                }

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    text: model.variable
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: checklistsSelected()
    }

    function updateContents() {
        assessmentModel.select();
    }

    Component.onCompleted: updateContents()
}
