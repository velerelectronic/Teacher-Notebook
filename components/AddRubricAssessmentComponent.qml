import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: addRubricMenuRect

//    property int requiredHeight: possibleList.requiredHeight + possibleList.anchors.margins * 2

    signal closeNewRubricAssessment()

    property string annotation

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

    ListView {
        id: possibleList
        anchors.fill: parent
        anchors.margins: units.fingerUnit

        clip: true
        spacing: units.nailUnit

        model: groupsModel

        delegate: Item {
            id: singleRubricXGroup

            width: possibleList.width
            height: groupText.height + rubricsGrid.height + units.nailUnit

            property string thisGroup: model.group

            ColumnLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                spacing: units.nailUnit

                Text {
                    id: groupText
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    font.bold: true
                    font.pixelSize: units.readUnit
                    elide: Text.ElideRight
                    text: qsTr('Grup') + " " + singleRubricXGroup.thisGroup
                }
                GridView {
                    id: rubricsGrid
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentItem.height

                    model: rubricsModel
                    interactive: false

                    cellWidth: units.fingerUnit * 4
                    cellHeight: cellWidth

                    delegate: Common.BoxedText {
                        width: units.fingerUnit * 3
                        height: width
                        margins: units.nailUnit
                        text: model.title
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                addRubricMenuRect.createNewRubricAssessment(model.title, model.desc, model.id, singleRubricXGroup.thisGroup);
                                closeNewRubricAssessment();
                            }
                        }
                    }
                }
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
