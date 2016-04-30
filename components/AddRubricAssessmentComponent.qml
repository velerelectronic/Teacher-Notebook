import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models

Rectangle {
    id: addRubricMenuRect

    property int requiredHeight: childrenRect.height

    signal closeNewRubricAssessment()

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
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: units.fingerUnit
        }
        height: contentItem.height

        clip: true

        model: groupsModel

        delegate: Item {
            id: singleRubricXGroup

            width: possibleList.width
            height: childrenRect.height

            property string group: model.group

            ColumnLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
//                            height: childrenRect.height

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    font.bold: true
                    font.pixelSize: units.readUnit
                    elide: Text.ElideRight
                    text: qsTr('Grup') + " " + model.group
                }
                GridView {
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
                                newRubricAssessment(model.title, model.desc, model.id, singleRubricXGroup.group);
                                closeNewRubricAssessment();
                            }
                        }
                    }
                }
            }
        }
    }

    function newRubricAssessment(title, desc, rubric, group) {
        var obj = {};
        obj = {
            title: title,
            desc: desc,
            rubric: rubric,
            group: group,
            annotation: annotationView.identifier
        };

        rubricsAssessmentModel.insertObject(obj);
        rubricsAssessmentModel.select();
    }

    Component.onCompleted: {
        groupsModel.selectUnique('group');
        console.log('COUNT', groupsModel.count)
    }

}
