import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    id: rubricRectangle

    property string pageTitle: qsTr("Rúbrica");
    property var buttons: buttonsModel

    property SqlTableModel rubricsModel

    property int rubric: -1
    property string rubricTitle
    property string rubricDesc

    property int sectionsHeight: units.fingerUnit * 4
    property int sectionsWidth: units.fingerUnit * 5
    property int contentsHeight: units.fingerUnit * 3
    property int contentsWidth: units.fingerUnit * 7

    signal editRubricDetails(int idRubric, string title, string desc, var model)
    signal editCriterium(int idCriterium, int rubric, string title, string desc, int ord, int weight, var model)
    signal editLevel(int idLevel, int rubric, string title, string desc, int score, var model)
    signal editDescriptor(int idDescriptor, int criterium, int level, string definition, var model)

    Common.UseUnits { id: units }

    color: 'gray'

    ListModel {
        id: buttonsModel

        Component.onCompleted: {
            append({method: 'newCriterium', image: 'plus-24844', title: qsTr('Afegeix un criteri a la rúbrica')});
            append({method: 'newLevel', image: 'plus-24844', title: qsTr('Afegeix un nivell als criteris')});
        }
    }

    Common.FixedHeadingsTableView {
        anchors.fill: parent
        headingsSpacing: units.nailUnit
        horizontalHeadingHeight: sectionsHeight
        verticalHeadingWidth: sectionsWidth

        crossHeadingItem: Rectangle {
            anchors.fill: parent
            border.color: 'black'
            color: '#C893B1'

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

        horizontalHeadingModel: rubricsLevels
        horizontalHeadingDelegate: Rectangle {
            // Levels
            height: sectionsHeight
            width: contentsWidth
            border.color: 'black'
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: model.title
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.glanceUnit
                    text: model.score
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.readUnit
                    text: model.desc
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: rubricRectangle.editLevel(model.id,model.rubric,model.title,model.desc,model.score,rubricsLevels)
                onPressAndHold: rubricRectangle.deleteLevelRequest(model.id,model.title,model.desc)
            }
        }

        verticalHeadingModel: rubricsCriteria
        verticalHeadingDelegate: Rectangle {
            height: contentsHeight
            width: sectionsWidth
            border.color: 'black'
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
                onClicked: rubricRectangle.editCriterium(model.id,model.rubric,model.title,model.desc,model.ord,model.weight,rubricsCriteria)
                onPressAndHold: rubricRectangle.deleteCriteriaRequest(model.id,model.title,model.desc)
            }
        }

        mainTabularItem: ListView {
            id: descriptorsList
            width: contentsWidth * rubricsLevels.count
            height: contentsHeight * rubricsCriteria.count
            clip: true
            orientation: ListView.Vertical // ListView.Horizontal
            interactive: false

            model: rubricsCriteria // rubricsLevels

            delegate: Rectangle {
                id: wholeCriteria
                height: contentsHeight
                width: descriptorsList.width

                border.color: 'black'
                color: 'white'

                property int criterium: model.id

                ListView {
                    id: rubricsList
                    anchors.fill: parent

                    model: rubricsLevels
                    orientation: ListView.Horizontal
                    interactive: false
                    delegate: Rectangle {
                        id: criteriumAndLevelCell
                        height: contentsHeight
                        width: contentsWidth
                        border.color: 'black'
                        color: 'transparent'
                        clip: true

                        property int level: model.id
                        property string definition: ''
                        property int descriptor: -1

                        SqlTableModel {
                            id: rubricsDescriptors
                            tableName: 'rubrics_descriptors'
                            filters: ['criterium=\"' + wholeCriteria.criterium + '\"','level=\"' + criteriumAndLevelCell.level + '\"']

                            Component.onCompleted: {
                                rubricsDescriptors.select();
                                console.log("Cell desciptors count " + rubricsDescriptors.count);
                                if (rubricsDescriptors.count > 0) {
                                    var result = rubricsDescriptors.getObjectInRow(0);
                                    console.log(result['id']);
                                    criteriumAndLevelCell.descriptor = ('id' in result)?parseInt(result['id']):-1;
                                    criteriumAndLevelCell.definition = result['definition'];
                                }
                            }
                        }

                        Text {
                            id: cellText
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                            text: criteriumAndLevelCell.definition
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                rubricRectangle.editDescriptor(criteriumAndLevelCell.descriptor,wholeCriteria.criterium,criteriumAndLevelCell.level,criteriumAndLevelCell.definition,rubricsDescriptors);
                            }
                        }

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
        var filter = ['rubric=\"' + rubricRectangle.rubric + '\"'];
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
    }
}

