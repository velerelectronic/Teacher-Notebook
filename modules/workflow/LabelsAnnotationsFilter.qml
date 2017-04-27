import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

import ClipboardAdapter 1.0
import PersonalTypes 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/calendar' as Calendar
import 'qrc:///modules/files' as Files

Flow {
    id: labelsList

    Common.UseUnits {
        id: units
    }

    property int labelHeight: 0
    property string workFlow: ''

    Models.WorkFlowGeneralLabels {
        id: generalLabelsModel

        filters: ['workFlow=?']

        function getLabels() {
            console.log('WFF', workFlow);
            bindValues = [workFlow];
            select();
        }
    }

    property int requiredHeight: childrenRect.height

    spacing: units.nailUnit

    Repeater {
        model: generalLabelsModel

        delegate: Rectangle {
            width: Math.max(childrenRect.width, units.fingerUnit) + 2 * units.nailUnit
            height: labelHeight

            radius: height / 4

            color: model.color

            Text {
                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }
                width: contentWidth

                padding: units.nailUnit

                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.readUnit
                text: model.title

                style: Text.Outline
                styleColor: 'white'
                color: 'black'
            }
        }

    }

    Component.onCompleted: generalLabelsModel.getLabels()
}
