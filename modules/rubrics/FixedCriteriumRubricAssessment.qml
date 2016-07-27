import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import RubricXml 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    id: rubricAssessmentFixedCriterium

    Common.UseUnits {
        id: units
    }

    property string criterium
    property RubricXml rubricModel

    color: 'gray'

    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: criteriaList

            Layout.preferredHeight: units.fingerUnit * 3
            Layout.fillWidth: true

            orientation: ListView.Horizontal
            model: rubricModel.criteria

            spacing: units.nailUnit

            delegate: Rectangle {
                id: criteriaDelegate
                width: units.fingerUnit * 4
                height: parent.height
                color: (ListView.isCurrentItem)?'yellow':'white'

                Text {
                    anchors.fill: parent
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: model.identifier
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        criteriaList.currentIndex = model.index;
                        criterium = model.identifier;
                    }
                }
            }
        }

        ListView {
            id: populationList

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true
            model: rubricModel.population

            spacing: units.nailUnit

            headerPositioning: ListView.OverlayHeader

            header: Item {
                width: populationList.width
                height: units.fingerUnit * 2

                z: 2

                RowLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr('Població')
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr('Descriptors')
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr('Comentaris')
                    }
                }
            }

            delegate: Item {
                id: singleIndividualItem

                width: populationList.width
                height: units.fingerUnit * 2

                property string individual: model.identifier

                z: 1

                RowLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        Text {
                            anchors.fill: parent
                            font.pixelSize: units.readUnit
                            text: (model.index+1).toString() + ". " + model.name + " " + model.surname
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Text {
                            id: descriptorsText
                            anchors.fill: parent
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        Text {
                            id: commentsText
                            anchors.fill: parent
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                        }
                    }
                }
                Component {
                    id: assessmentDataComponent
                    Item {
                    }
                }

                Component.onCompleted: {
                    var incubator = assessmentDataComponent.incubateObject(parent);

                    if (incubator.status != Component.Ready) {
                        incubator.onStatusChanged = function(status) {
                            if (status == Component.Ready) {
                                singleIndividualItem.getEvaluationData();
                            }
                        }
                    } else {
                        singleIndividualItem.getEvaluationData();
                    }
                }

                function getEvaluationData() {
                    descriptorsText.text = '';
                    commentsText.text = '';
                    for (var i=0; i<rubricModel.assessment.count; i++) {
                        var data = rubricModel.assessment.get(i);
                        if ((data.criterium == criterium) && (data.individual == singleIndividualItem.individual)) {
                            descriptorsText.text = data.descriptor;
                            commentsText.text = data.comment;
                        }
                    }
                }

                Connections {
                    target: rubricAssessmentFixedCriterium
                    onCriteriumChanged: {
                        console.log('new criterium');
                        singleIndividualItem.getEvaluationData();
                    }
                }
            }
        }
    }

}
