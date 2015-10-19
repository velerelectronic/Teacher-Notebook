import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage

BasicPage {
    id: criteriumAssessmentEditorBasicPage

    Common.UseUnits { id: units }

    property string pageTitle: qsTr("Avaluació de rúbrica per criteris")

    property int assessment: -1
    property int group: -1
    property int criterium: -1

    property SqlTableModel lastScoresModel

    signal editRubricAssessmentDescriptor(int individual, int lastScoreId)

    onEditRubricAssessmentDescriptor: {
        openSubPage('RubricAssessmentDescriptor', {assessment: assessment, criterium: criterium, individual: individual, lastScoreId: lastScoreId, lastScoresModel: lastScoresModel}, units.fingerUnit);
    }

    mainPage: Rectangle {
        id: criteriumAssessmentEditor

        SqlTableModel {
            id: rubricsScoresModel
            tableName: 'rubrics_scores'
            fieldNames: [
                'id', 'assessment', 'descriptor', 'moment', 'individual', 'comment'
            ]

            onUpdated: lastScoresModel.select()

            Component.onCompleted: select()
        }

        Models.RubricsLevelsDescriptorsModel {
            id: levelsDescriptorsModel
            filters: [
                "criterium='" + criterium + "'"
            ]
            Component.onCompleted: {
                setSort(9,Qt.AscendingOrder);
                select();
            }
        }

        ListView {
            id: criteriaList

            anchors.fill: parent
            anchors.margins: units.nailUnit
            clip: true

            model: lastScoresModel

            headerPositioning: ListView.OverlayHeader

            property int descriptorsCriteriumHeight: 0

            header: Rectangle {
                width: criteriaList.width
                height: headerLayout.height // criteriumTitle.contentHeight + criteriumDesc.contentHeight + descriptorsHeadingList.height + 2 * units.nailUnit
                z: 2
                RowLayout {
                    id: headerRow
                    anchors.fill: parent
                    spacing: 0
                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit * 3
                        fontSize: units.readUnit
                        text: qsTr('Individu')
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        border.color: 'black'
                        color: 'white'

                        ColumnLayout {
                            id: headerLayout
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
                            height: childrenRect.height

                            spacing: units.nailUnit
                            Text {
                                id: criteriumTitle
                                Layout.fillWidth: true
                                height: criteriumTitle.contentHeight
                                anchors.margins: units.nailUnit
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }

                            Text {
                                id: criteriumDesc
                                Layout.fillWidth: true
                                height: contentHeight
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }

                            ListView {
                                id: descriptorsHeadingList
                                Layout.fillWidth: true
                                Layout.preferredHeight: criteriaList.descriptorsCriteriumHeight
    //                            onHeightChanged: criteriaList.descriptorsCriteriumHeight = height
                                orientation: ListView.Horizontal
                                interactive: false

                                model: levelsDescriptorsModel

                                delegate: Common.BoxedText {
                                    margins: units.nailUnit
                                    height: criteriaList.descriptorsCriteriumHeight
                                    onContentHeightChanged: {
                                        console.log('height ' + contentHeight);
                                        if (contentHeight > criteriaList.descriptorsCriteriumHeight)
                                            criteriaList.descriptorsCriteriumHeight = contentHeight;
                                    }

                                    width: (levelsDescriptorsModel.count>0)?descriptorsHeadingList.width / levelsDescriptorsModel.count:0
                                    text: model.score + " " + model.definition
                                    elide: Text.ElideNone
                                }
                            }
                        }

                        Connections {
                            target: levelsDescriptorsModel
                            onCountChanged: {
                                if (levelsDescriptorsModel.count>0) {
                                    var obj = levelsDescriptorsModel.getObjectInRow(0);
                                    criteriumTitle.text = qsTr('Criteri:') + " " + obj['criteriumTitle'];
                                    criteriumDesc.text = obj['criteriumDesc'];
                                }
                            }
                        }
                    }
                    Common.BoxedText {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit * 3
                        fontSize: units.readUnit
                        text: qsTr('Comentaris')
                    }
                }
            }

            delegate: Rectangle {
                id: individualRow

                z: 1
                width: criteriaList.width
                height: Math.max(units.fingerUnit, assessmentIndividual.contentHeight, assessmentComment.contentHeight) + 2 * units.nailUnit
                border.color: 'black'

                property int selectedLevel: model.level
                property string selectedComment: model.comment

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit * 3
                        border.color: 'black'
                        Text {
                            id: assessmentIndividual

                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                            text: model.name + " " + model.surname
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        border.color: 'black'
                        color: 'pink'
                        ListView {
                            id: descriptorsList
                            anchors.fill: parent
                            orientation: ListView.Horizontal
                            interactive: false

                            model: levelsDescriptorsModel

                            delegate: Common.BoxedText {
                                width: descriptorsList.width / levelsDescriptorsModel.count
                                height: descriptorsList.height
                                text: model.score

                                color: (individualRow.selectedLevel !== model.level)?'transparent':'yellow'
                                margins: units.nailUnit

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        var obj = {
                                            assessment: assessment,
                                            descriptor: model.descriptor,
                                            moment: Storage.currentTime(),
                                            individual: individual,
                                            comment: individualRow.selectedComment
                                        }
                                        console.log(obj);

                                        if (rubricsScoresModel.insertObject(obj)) {
                                            //descriptorsList.currentIndex = model.index;
                                        }
                                    }
                                }

                                Component.onCompleted: {
                                    if (individualRow.selectedLevel === model.level) {
                                        descriptorsList.currentIndex = model.index;
                                    }
                                }
                            }
                            /*
                            highlight: Rectangle {
                                width: descriptorsList.width / levelsDescriptorsModel.count
                                height: descriptorsList.height
                                color: 'yellow'
                            }
                            highlightFollowsCurrentItem: true
                            */
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit * 3
                        border.color: 'black'
                        Text {
                            id: assessmentComment

                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                            text: model.comment
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log('SINGLE', model.individual, model.lastScoreId);
                                editRubricAssessmentDescriptor(model.individual, model.lastScoreId);
                            }
                        }
                    }
                }
            }
        }
    }
}


