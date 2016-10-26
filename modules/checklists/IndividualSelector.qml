import QtQuick 2.7
import QtQuick.Layouts 1.1

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Item {
    property int requiredHeight: childrenRect.height + units.nailUnit
    property string selectedGroup
    property alias selectedIndividual: individualTextEditor.content

    Common.UseUnits {
        id: units
    }

    Models.AssessmentGridModel {
        id: individualsModel

        sort: 'individual ASC, id ASC'

        function selectIndividuals() {
            filters = ["\"group\"=?"];
            bindValues = [selectedGroup];
            select();
            var result = [];
            for (var i=0; i<count; i++) {
                var newIndividual = getObjectInRow(i)['individual'];
                if (result.indexOf(newIndividual)<0)
                    result.push(newIndividual);
            }
            console.log('there are', result.length, 'individuals of', count);
            return result;
        }
    }

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        spacing: units.nailUnit

        Editors.TextLineEditor {
            id: individualTextEditor

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5
        }

        Flow {
            id: individualsList

            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            spacing: units.nailUnit

            Repeater {
                id: individualsRepeater

                Rectangle {
                    radius: height / 2
                    border.color: 'green'
                    height: units.fingerUnit
                    width: Math.max(individualText.width + radius * 2, units.fingerUnit * 2)
                    color: 'yellow'
                    Text {
                        id: individualText
                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom: parent.bottom
                            margins: units.nailUnit
                            leftMargin: parent.radius
                        }
                        width: contentWidth
                        text: modelData
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedIndividual = modelData
                    }
                }
            }
            Component.onCompleted: individualsRepeater.model = individualsModel.selectIndividuals()
        }
    }

    onSelectedGroupChanged: {
        console.log('updating individuals');
        individualsRepeater.model = individualsModel.selectIndividuals();
    }

    onSelectedIndividualChanged: {
        individualTextEditor.content = selectedIndividual;
    }
}
