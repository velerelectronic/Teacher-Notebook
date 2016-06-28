import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage

Item {
    id: descriptorEditor

    property int assessment
    property int criterium
    property int individual

    property int descriptorId
    property int newDescriptorId: descriptorId
    property string comment

    signal contentsSaved()

    Common.UseUnits {
        id: units
    }

    Models.RubricsLevelsDescriptorsModel {
        id: descriptorsModel

        filters: ['criterium=?']
        sort: 'score ASC, desc ASC'

        Component.onCompleted: refreshModels()
    }

    Models.RubricsLastScoresModel {
        id: lastScoresModel

        filters: ['assessment=?','criterium=?','individual=?']

        Component.onCompleted: refreshModels()
    }

    Models.RubricsDetailedScoresModel {
        id: detailedScoresModel

        filters: ['assessment=?','criterium=?','individual=?']
        sort: 'moment DESC'

        Component.onCompleted: refreshModels()
    }

    Models.RubricsScoresModel {
        id: rubricsScoresModel
    }

    function refreshModels() {
        if ((assessment>-1) && (criterium>-1) && (individual>-1)) {
            descriptorsModel.bindValues = [criterium];
            descriptorsModel.select();
            detailedScoresModel.bindValues = [assessment, criterium, individual];
            detailedScoresModel.select();
            lastScoresModel.bindValues = [assessment, criterium, individual];
            lastScoresModel.select();
            console.log('count', lastScoresModel.count);
            if (lastScoresModel.count>0) {
                var obj = lastScoresModel.getObjectInRow(0);
                descriptorId = obj['descriptor'];
                comment = obj['comment'];
            }
            console.log('assessment', assessment, 'criterium', criterium, 'individual', individual, 'descriptor', descriptorId);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            GridLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                columns: 2
                rows: 3
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: qsTr('Rúbrica avaluada')
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: assessment
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: qsTr('Criteri')
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: criterium
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: qsTr('Individu')
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: individual
                }
            }
        }
        ListView {
            id: completeList
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            spacing: units.nailUnit

            model: ObjectModel {
                Text {
                    width: completeList.width
                    height: contentHeight
                    font.bold: true
                    font.pixelSize: units.readUnit
                    text: qsTr('Descriptors')
                }

                Rectangle {
                    width: completeList.width
                    height: descriptorsList.contentItem.height
                    border.color: 'black'
                    color: 'white'
                    ListView {
                        id: descriptorsList
                        anchors.fill: parent

                        interactive: false

                        model: descriptorsModel

                        highlight: Rectangle {
                            width: descriptorsList.width
                            height: units.fingerUnit * 2
                            color: 'yellow'
                        }

                        delegate: Rectangle {
                            id: descriptorRect
                            width: descriptorsList.width
                            height: units.fingerUnit * 2

                            border.color: 'black'
                            color: 'transparent'

                            RowLayout {
                                anchors.fill: parent
                                spacing: units.nailUnit
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: units.fingerUnit
                                    border.color: 'transparent'
                                    border.width: descriptorRect.border.width

                                    color: (model.descriptor == descriptorId)?'orange':'transparent'
                                }

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width / 4
                                    verticalAlignment: Text.AlignVCenter
                                    text: model.title
                                }
                                Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    verticalAlignment: Text.AlignVCenter
                                    text: model.definition
                                }
                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width / 4
                                    verticalAlignment: Text.AlignVCenter
                                    text: model.score
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    descriptorsList.currentIndex = model.index;
                                    newDescriptorId = model.descriptor;
                                }
                            }
                            Connections {
                                target: descriptorEditor
                                onDescriptorIdChanged: {
                                    if (model.descriptor == descriptorId) {
                                        descriptorsList.currentIndex = model.index;
                                    }
                                }
                            }

                        }
                    }
                }

                Text {
                    width: completeList.width
                    height: contentHeight
                    font.bold: true
                    text: qsTr('Comentaris')
                }
                Common.TextAreaEditor {
                    id: commentArea
                    width: completeList.width
                    height: units.fingerUnit * 8
                    text: comment
                }
                Text {
                    width: completeList.width
                    height: contentHeight
                    font.bold: true
                    text: qsTr('Historial')
                }
                ListView {
                    id: historyValues
                    width: completeList.width
                    height: contentItem.height

                    model: detailedScoresModel

                    header: Rectangle {
                        width: historyValues.width
                        height: (detailedScoresModel.count==0)?units.fingerUnit:0
                        Text {
                            anchors.fill: parent
                            clip: true
                            text: qsTr('No hi ha valors enregistrats.')
                        }
                    }
                    delegate: Item {
                        width: historyValues.width
                        height: units.fingerUnit * 2
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit
                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.levelTitle + " - " + model.definition + " (" + model.score + ")"
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: historyValues.width / 3
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.comment
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: historyValues.width / 3
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.moment
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {

                            }
                        }
                    }
                }
            }
        }
    }

    function saveModifiedContents() {
        console.log('saving');
        var obj = {
            assessment: assessment,
            descriptor: newDescriptorId,
            moment: Storage.currentTime(),
            individual: individual,
            comment: commentArea.text
        }

        rubricsScoresModel.insertObject(obj);
        contentsSaved();
    }
}
