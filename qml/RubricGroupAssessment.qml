import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    id: rubricRectangle

    property string pageTitle: qsTr("Avaluació de rúbrica per grups");
    property var buttons: buttonsModel

    property SqlTableModel rubricsModel
    property SqlTableModel rubricsAssessmentModel

    property int rubric: -1
    property int idAssessment: -1
    property string rubricTitle
    property string rubricDesc
    property string group

    property int sectionsHeight: units.fingerUnit * 4
    property int sectionsWidth: units.fingerUnit * 5
    property int contentsHeight: units.fingerUnit * 3
    property int contentsWidth: units.fingerUnit * 7

    signal editRubricDetails(int idRubric, string title, string desc, var model)
    signal editRubricAssessmentScore(int assessment, int criterium, string individual, var scoresModel)

    Common.UseUnits { id: units }

    color: 'gray'

    ListModel {
        id: buttonsModel

        ListElement {
            method: 'newCriterium'
            image: 'plus-24844'
        }
        ListElement {
            method: 'newLevel'
            image: 'plus-24844'
        }
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            Text {
                Layout.preferredHeight: units.fingerUnit
                Layout.preferredWidth: sectionsWidth
                text: qsTr('Grups')
            }

            Rectangle {
                Layout.preferredHeight: units.fingerUnit
                Layout.fillWidth: true
                color: 'white'
                Text {
                    anchors {
                        fill: parent
                        margins: units.nailUnit
                    }
                    font.pixelSize: units.readUnit
                    text: rubricRectangle.group
                }
            }
        }

        Common.FixedHeadingsTableView {
            id: fixedHeadingsTable
            Layout.fillHeight: true
            Layout.fillWidth: true

            headingsSpacing: units.nailUnit
            verticalHeadingWidth: sectionsWidth
            horizontalHeadingHeight: sectionsHeight
            crossHeadingItem: Rectangle {
                id: title
                anchors.fill: parent

                border.color: 'black'
                color: 'pink'

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Text {
                        Layout.preferredHeight: parent.height / 2
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: rubricTitle
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: rubricDesc
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: editRubricDetails(rubric,rubricTitle,rubricDesc,rubricsModel)
                }
            }

            horizontalHeadingModel: individualsModel
            horizontalHeadingDelegate: Rectangle {
                height: sectionsHeight
                width: contentsWidth
                border.color: 'black'
                color: 'transparent'
                Text {
                    anchors {
                        fill: parent
                        margins: units.nailUnit
                    }

                    clip: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: model.individual
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fixedHeadingsTable.changeCurrentHorizontalIndex(model.index)
                }
            }
            horizontalHeadingHighlight: Rectangle {
                height: sectionsHeight
                width: contentsWidth
                color: 'yellow'
            }

            verticalHeadingModel: rubricsCriteria
            verticalHeadingDelegate: Rectangle {
                height: contentsHeight
                width: sectionsWidth
                border.color: 'black'
                color: 'transparent'
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: '<b>' + model.title + '</b>&nbsp;' + model.desc
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: contentWidth
                        text: model.weight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fixedHeadingsTable.changeCurrentVerticalIndex(model.index)
                }
            }
            verticalHeadingHighlight: Rectangle {
                height: sectionsHeight
                width: contentsWidth
                color: 'yellow'
            }

            mainTabularItem: ListView {
                id: descriptorsList
                anchors.fill: parent
                orientation: ListView.Vertical
                interactive: false

                model: rubricsCriteria

                highlight: Rectangle {
                    height: contentsHeight
                    width: descriptorsList.width
                    color: 'pink'
                }
                onCurrentIndexChanged: { console.log('New current index ' + currentIndex)}

                delegate: Rectangle {
                    id: wholeCriteria
                    height: contentsHeight
                    width: descriptorsList.width

                    border.color: 'black'
                    color: 'transparent'

                    property int levelId: model.id
                    property string title: model.title
                    property int verticalIndex: model.index
                    property int criterium: model.id

                    ListView {
                        id: rubricsList
                        anchors.fill: parent

                        model: individualsModel // rubricsCriteria
                        orientation: ListView.Horizontal
                        interactive: false
                        highlight: Rectangle {
                            height: contentsHeight
                            width: contentsWidth
                            color: 'green'
                        }

                        delegate: Rectangle {
                            height: contentsHeight
                            width: contentsWidth
                            border.color: 'black'
                            color: 'transparent'
                            //color: (model.index === fixedHeadingsTable.currentHorizontalIndex)?((wholeCriteria.verticalIndex === fixedHeadingsTable.currentVerticalIndex)?'#ffffaa':'yellow'):'transparent'
                            clip: true

                            property int criteriumId: model.id
                            property string title: model.title
                            property int descriptorId: -1
                            property string definition: ''

                            SqlTableModel {
                                id: rubricIndividualScoresModel
                                tableName: 'rubrics_scores'
                                fieldNames: ['id', 'assessment', 'criterium', 'level', 'moment', 'individual', 'comment']
                                filters: [
                                    'criterium=\"' +  wholeCriteria.criterium + '\"',
                                    'assessment=\"' + idAssessment + '\"',
                                    'individual=\"' + model.individual + '\"'
                                ]
                                onCountChanged: console.log('scores count ' + count)
                                Component.onCompleted: select()
                            }

                            ListView {
                                id: valuesList
                                anchors.fill: parent
                                model: rubricIndividualScoresModel
                                delegate: Text {
                                    id: cellText
                                    width: valuesList.width
                                    height: valuesList.height
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    font.pixelSize: units.readUnit
                                    text: model.level + ' ' + model.comment
                                }
                            }
                            Text {
                                visible: rubricIndividualScoresModel.count === 0
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                text: qsTr('No definit')
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    editRubricAssessmentScore(idAssessment,wholeCriteria.criterium,model.individual,rubricIndividualScoresModel);
                                }
                            }
                        }
                        highlightMoveDuration: 500
                        Component.onCompleted: currentIndex = -1
                    }
                }
            }

        }

    }

/*
    SqlTableModel {
        id: rubricsModel
        tableName: 'rubrics'
        fieldNames: ['id', 'title', 'desc']
    }
*/

    SqlTableModel {
        id: rubricsCriteria
        tableName: 'rubrics_criteria'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'ord', 'weight']
    }

    SqlTableModel {
        id: rubricsLevels
        tableName: 'rubrics_levels'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'score']
    }

    SqlTableModel {
        id: allRubricsDescriptors
        tableName: 'rubrics_descriptors'
        fieldNames: []
    }

    SqlTableModel {
        id: individualsModel
        tableName: 'assessmentGrid'
        fieldNames: ['id', 'created', 'moment', "group", 'individual', 'variable', 'value', 'comment']
        filters: ['\"group\"=\'' + rubricRectangle.group + '\'']
    }

    onGroupChanged: individualsModel.select()

    Component {
        id: addNewElement
        Rectangle {
            border.color: 'black'
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: units.readUnit
                text: '+'
            }
        }
    }

    function newCriterium() {
        rubricsCriteria.insertObject({title: qsTr('Nou criteri'), desc: '', rubric: rubricRectangle.rubric, weight: 1});
    }

    function newLevel() {
        rubricsLevels.insertObject({title: qsTr('Nou nivell'), desc: '', rubric: rubricRectangle.rubric});
    }

    function deleteLevelRequest(idLevel,title,desc) {
        deleteLevelsDialog.levelId = idLevel;
        deleteLevelsDialog.levelTitle = title;
        deleteLevelsDialog.levelDesc = desc;

        allRubricsDescriptors.filters = ['level=\"' + idLevel + '\"'];
        allRubricsDescriptors.select();

        deleteLevelsDialog.open();
    }

    function deleteCriteriaRequest(idCriterium,title,desc) {
        deleteCriteriaDialog.criteriumId = idCriterium;
        deleteCriteriaDialog.criteriumTitle = title;
        deleteCriteriaDialog.criteriumDesc = desc;

        allRubricsDescriptors.filters = ['criterium=\"' +  idCriterium + '\"'];
        allRubricsDescriptors.select();

        deleteCriteriaDialog.open();
    }

    MessageDialog {
        id: deleteLevelsDialog
        property string levelTitle: ''
        property string levelDesc: ''
        property int rubricId: -1
        property int levelId: -1

        title: qsTr('Elimina nivell')
        text: qsTr("S'esborrarà el nivell «") + levelTitle + qsTr('» i els ') + allRubricsDescriptors.count + qsTr(' descriptors que du associats. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: {
            for (var i=0; i<allRubricsDescriptors.count; i++) {
                allRubricsDescriptors.removeObjectInRow(i);
            }

            rubricsLevels.removeObjectWithKeyValue(levelId);
            rubricsLevels.select();
        }
    }

    MessageDialog {
        id: deleteCriteriaDialog
        property string criteriumTitle: ''
        property string criteriumDesc: ''
        property int rubricId: -1
        property int criteriumId: -1

        title: qsTr('Elimina criteri')
        text: qsTr("S'esborrarà el criteri «") + criteriumTitle + qsTr('» i els ') + allRubricsDescriptors.count + qsTr(' descriptors que du associats. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: {
            for (var i=0; i<allRubricsDescriptors.count; i++) {
                allRubricsDescriptors.removeObjectInRow(i);
            }

            rubricsCriteria.removeObjectWithKeyValue(criteriumId);
            rubricsCriteria.select();
        }

    }

    Component.onCompleted: {
        var filter = ["rubric=\'" + rubricRectangle.rubric + "\'"];
        rubricsCriteria.filters = filter;
        rubricsCriteria.setSort(4, Qt.AscendingOrder);
        rubricsCriteria.select();

        rubricsLevels.filters = filter;
        rubricsLevels.setSort(4, Qt.AscendingOrder);
        rubricsLevels.select();
        rubricsModel.select();

        var obj = rubricsModel.getObject(rubricRectangle.rubric);
        if ('title' in obj)
            rubricTitle = obj['title'];
        if ('desc' in obj)
            rubricDesc = obj['desc'];

        var objAssessment = rubricsAssessmentModel.getObject(rubricRectangle.idAssessment);
        if ('group' in objAssessment)
            group = objAssessment['group']
        for (var prop in objAssessment) {
            console.log('prop ' + prop + '-' + objAssessment[prop]);
        }

    }
}

