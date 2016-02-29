import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

BasicPage {
    id: rubricRectangleBasicPage

    pageTitle: qsTr("Rúbrica");

    property SqlTableModel rubricsModel

    property int rubric: -1

    function editCriterium(idCriterium) {
        openPageArgs('RubricCriteriumEditor',{idCriterium: idCriterium, rubric: rubric, criteriaModel: rubricsCriteria}, units.fingerUnit);
    }

    function editDescriptor(idDescriptor, criterium, level, descriptorsModel) {
        openPageArgs('RubricDescriptorEditor',{idDescriptor: idDescriptor, criterium: criterium, level: level, descriptorsModel: descriptorsModel}, units.fingerUnit)
    }

    function editLevel(idLevel) {
        openPageArgs('RubricLevelEditor',{idLevel: idLevel, rubric: rubric, levelsModel: rubricsLevels}, units.fingerUnit)
    }

    function editRubricDetails(idRubric) {
        openPageArgs('RubricDetailsEditor',{idRubric: rubric, rubricsModel: rubricsModel}, units.fingerUnit)
    }

    mainPage: Rectangle {
        id: rubricRectangle

        property string rubricTitle
        property string rubricDesc

        property int sectionsHeight: units.fingerUnit * 4
        property int sectionsWidth: units.fingerUnit * 5
        property int contentsHeight: units.fingerUnit * 3
        property int contentsWidth: units.fingerUnit * 7

        Common.UseUnits { id: units }

        color: 'white'

        Common.FixedHeadingsTableView {
            anchors.fill: parent
            headingsSpacing: units.nailUnit
            horizontalHeadingHeight: sectionsHeight
            verticalHeadingWidth: sectionsWidth
            extraHorizontalSpace: units.fingerUnit * 2
            extraVerticalSpace: units.fingerUnit * 2

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
                    onClicked: editRubricDetails(rubric)
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
                    onClicked: rubricRectangleBasicPage.editLevel(model.id)
                    onPressAndHold: rubricRectangle.deleteLevelRequest(model.id,model.title,model.desc)
                }
            }
            horizontalHeadingOptions: Item {
                z: 2
                width: units.fingerUnit * 2
                height: rubricRectangle.sectionsHeight

                Common.SuperposedButton {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    imageSource: 'plus-24844'
                    margins: units.nailUnit
                    size: units.fingerUnit * 1.5
                    onClicked: rubricRectangle.newLevel()
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
                    onClicked: rubricRectangleBasicPage.editCriterium(model.id)
                    onPressAndHold: rubricRectangle.deleteCriteriaRequest(model.id,model.title,model.desc)
                }
            }
            verticalHeadingOptions: Item {
                z: 2
                width: rubricRectangle.sectionsWidth
                height: units.fingerUnit * 2

                Common.SuperposedButton {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    imageSource: 'plus-24844'
                    margins: units.nailUnit
                    size: units.fingerUnit * 1.5
                    onClicked: rubricRectangle.newCriterium()
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
                                fieldNames: ['id', 'criterium', 'level', 'definition']
                                primaryKey: 'id'
                                filters: ['criterium=?','level=?']
                                bindValues: [wholeCriteria.criterium, criteriumAndLevelCell.level]

                                Component.onCompleted: {
                                    rubricsDescriptors.updated();
                                }

                                onUpdated: {
                                    select();
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
                                    rubricRectangleBasicPage.editDescriptor(criteriumAndLevelCell.descriptor,wholeCriteria.criterium,criteriumAndLevelCell.level,rubricsDescriptors);
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
            id: allRubricsDescriptors
            tableName: 'rubrics_descriptors'
            fieldNames: ['id', 'criterium', 'level', 'definition']
            primaryKey: 'id'
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
            rubricsCriteria.insertObject({title: qsTr('Nou criteri'), desc: '', rubric: rubric, weight: 1});
            rubricsCriteria.select();
        }

        function newLevel() {
            rubricsLevels.insertObject({title: qsTr('Nou nivell'), desc: '', rubric: rubric});
            rubricsLevels.select();
        }

        function deleteLevelRequest(idLevel,title,desc) {
            deleteLevelsDialog.levelId = idLevel;
            deleteLevelsDialog.levelTitle = title;
            deleteLevelsDialog.levelDesc = desc;

            allRubricsDescriptors.filters = ['level=?'];
            allRubricsDescriptors.bindValues = [idLevel];
            allRubricsDescriptors.select();

            deleteLevelsDialog.open();
        }

        function deleteCriteriaRequest(idCriterium,title,desc) {
            deleteCriteriaDialog.criteriumId = idCriterium;
            deleteCriteriaDialog.criteriumTitle = title;
            deleteCriteriaDialog.criteriumDesc = desc;

            allRubricsDescriptors.filters = ['criterium=?'];
            allRubricsDescriptors.bindValues = [idCriterium];
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
                    allRubricsDescriptors.removeObject(allRubricsDescriptors.getObject(i)['id']);
                }

                rubricsLevels.removeObject(levelId)
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
                    allRubricsDescriptors.removeObject(allRubricsDescriptors.getObject(i)['id']);
                }

                rubricsCriteria.removeObject(criteriumId);
                rubricsCriteria.select();
            }

        }

        Component.onCompleted: {
            var obj = rubricsModel.getObject(rubric);
            if (obj) {
                rubricTitle = obj['title'];
                rubricDesc = obj['desc'];
            }

            rubricsCriteria.select();
            rubricsLevels.select();
        }
    }

    SqlTableModel {
        id: rubricsLevels
        tableName: 'rubrics_levels'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'score']
        filters: ['rubric=?']
        bindValues: [rubric]
        primaryKey: 'id'
        sort: 'score ASC'
    }

    SqlTableModel {
        id: rubricsCriteria
        tableName: 'rubrics_criteria'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'ord', 'weight']
        primaryKey: 'id'
        filters: ['rubric=?']
        bindValues: [rubric]
        sort: 'ord ASC'
    }

}

