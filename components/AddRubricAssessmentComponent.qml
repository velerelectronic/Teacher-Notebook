import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: addRubricMenuRect

//    property int requiredHeight: possibleList.requiredHeight + possibleList.anchors.margins * 2

    signal closeNewRubricAssessment()

    property string annotation

    property string chosenGroup: ''
    property int chosenRubricId: -1
    property string chosenRubricTitle: ''
    property string chosenRubricDesc: ''

    Common.UseUnits {
        id: units
    }

    Models.IndividualsModel {
        id: groupsModel

        fieldNames: ['group']

        sort: 'id DESC'
    }

    Models.RubricsModel {
        id: rubricsModel

        Component.onCompleted: select();
    }

    Models.RubricsAssessmentModel {
        id: rubricsAssessmentModel
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.fingerUnit

        spacing: units.nailUnit

        ListView {
            id: groupsList
            Layout.fillHeight: true
            Layout.fillWidth: true

            model: groupsModel

            spacing: units.nailUnit
            delegate: Common.BoxedText {
                width: groupsList.width
                height: units.fingerUnit * 2

                color: 'transparent'
                text: qsTr('Grup') + " " + model.group
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        groupsList.currentIndex = model.index;
                        chosenGroup = model.group;
                    }
                }
            }

            highlight: Rectangle {
                width: groupsList.width
                height: units.fingerUnit * 2
                color: 'yellow'
            }
        }

        ListView {
            id: rubricsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: rubricsModel

            spacing: units.nailUnit
            delegate: Common.BoxedText {
                width: rubricsList.width
                height: units.fingerUnit * 2
                margins: units.nailUnit
                color: 'transparent'
                text: model.title
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        rubricsList.currentIndex = model.index;
                        chosenRubricId = model.id;
                        chosenRubricTitle = model.title;
                        chosenRubricDesc = model.desc;
                    }
                }
            }
            highlight: Rectangle {
                width: rubricsList.width
                height: units.fingerUnit * 2
                color: 'yellow'
            }
        }
        Common.Button {
            Layout.preferredWidth: units.fingerUnit * 3
            Layout.fillHeight: true

            enabled: (groupsList.currentIndex > -1) && (rubricsList.currentIndex > -1)
            text: qsTr('Crea rúbrica')
            onClicked: {
                addRubricMenuRect.createNewRubricAssessment(chosenRubricTitle, chosenRubricDesc, chosenRubricId, chosenGroup);
                closeNewRubricAssessment();
            }
        }

    }


    function createNewRubricAssessment(title, desc, rubric, group) {
        var obj = {};
        obj = {
            title: title,
            desc: desc,
            rubric: rubric,
            group: group,
            annotation: addRubricMenuRect.annotation
        };

        rubricsAssessmentModel.insertObject(obj);
        rubricsAssessmentModel.select();
    }

    Component.onCompleted: {
        groupsModel.selectUnique('group');
        console.log('COUNT', groupsModel.count)
    }
}
