import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import RubricXml 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import "qrc:///javascript/Storage.js" as Storage

Rectangle {
    id: rubricAssessmentFixedCriterium

    Common.UseUnits {
        id: units
    }

    property string criterium
    property RubricDescriptorsModel descriptorsModel
    property RubricXml rubricModel

    color: 'gray'

    property bool showDetailedDescriptors: false

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
                        descriptorsModel = model.descriptors;
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

            delegate: Rectangle {
                id: singleIndividualItem

                states: [
                    State {
                        name: 'condensed'
                        PropertyChanges {
                            target: singleIndividualItem
                            height: units.fingerUnit * 2
                        }
                        PropertyChanges {
                            target: descriptorsList
                            descriptorWidth: descriptorsList.width / Math.max(descriptorsModel.count,1)
                            interactive: false
                        }
                    },
                    State {
                        name: 'detailed'
                        PropertyChanges {
                            target: singleIndividualItem
                            height: units.fingerUnit * 2 + descriptorsList.maxRequiredHeight
                        }
                        PropertyChanges {
                            target: descriptorsList
                            descriptorWidth: descriptorsList.width
                            interactive: true
                        }
                    }
                ]
                state: (ListView.isCurrentItem)?'detailed':'condensed'
                width: populationList.width

                property bool isCurrentItem: ListView.isCurrentItem
                border.color: (ListView.isCurrentItem)?'green':'white'
                color: 'transparent'
                border.width: units.nailUnit / 2

                property string individual: model.identifier
                property string selectedDescriptorIdentifier: ''

                z: 1

                MouseArea {
                    anchors.fill: superiorLayout
                    onClicked: {
                        populationList.currentIndex = model.index;
                    }

                    onPressAndHold: {
                        rubricAssessmentFixedCriterium.showDetailedDescriptors = !rubricAssessmentFixedCriterium.showDetailedDescriptors;
                    }
                }

                RowLayout {
                    id: superiorLayout
                    anchors.fill: parent
                    anchors.margins: parent.border.width

                    spacing: units.nailUnit

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 5
                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            text: (model.index+1).toString() + ". " + model.name + " " + model.surname
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        ListView {
                            id: descriptorsList
                            anchors.fill: parent
                            orientation: ListView.Horizontal
                            model: descriptorsModel
                            property int descriptorWidth
                            clip: true
                            snapMode: ListView.SnapOneItem

                            property int maxRequiredHeight: 0

                            delegate: Rectangle {
                                width: descriptorsList.descriptorWidth
                                height: descriptorsList.height

                                color: (singleIndividualItem.selectedDescriptorIdentifier == model.identifier)?'yellow':'white'

                                Text {
                                    id: descriptorBasics
                                    anchors.fill: parent
                                    anchors.margins: units.nailUnit

                                    visible: singleIndividualItem.state == 'condensed'
                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    elide: Text.ElideRight
                                    text: model.identifier
                                    clip: true
                                }
                                ColumnLayout {
                                    id: descriptorDetails

                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                    }

                                    anchors.margins: units.nailUnit
                                    visible: singleIndividualItem.state == 'detailed'
                                    spacing: units.nailUnit

                                    property int requiredHeight: childrenRect.height

                                    Text {
                                        id: descriptorIdentifierText
                                        Layout.fillWidth: true
                                        height: contentHeight
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.identifier
                                    }
                                    Text {
                                        id: descriptorLevelText
                                        Layout.fillWidth: true
                                        height: contentHeight
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.level
                                    }
                                    Text {
                                        id: descriptorTitleText
                                        Layout.fillWidth: true
                                        height: contentHeight
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: '<b>' + model.title + '</b><br/>' + model.description
                                    }
                                    Text {
                                        id: descriptorScoreText
                                        Layout.fillWidth: true
                                        height: contentHeight
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.score
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: singleIndividualItem.isCurrentItem
                                    onClicked: {
                                        var obj = {
                                            individual: singleIndividualItem.individual,
                                            criterium: rubricAssessmentFixedCriterium.criterium,
                                            descriptor: model.identifier,
                                            comment: commentsText.text,
                                            moment: Storage.currentTime()
                                        };
                                        rubricModel.assessment.append(obj);
                                        singleIndividualItem.getEvaluationData();
                                    }
                                }

                                Component.onCompleted: {
                                    if (descriptorDetails.requiredHeight > descriptorsList.maxRequiredHeight)
                                        descriptorsList.maxRequiredHeight = descriptorDetails.requiredHeight;
                                }
                            }
                        }

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
                        Layout.preferredWidth: parent.width / 5
                        Text {
                            id: commentsText
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
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
                            singleIndividualItem.selectedDescriptorIdentifier = data.descriptor;
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
