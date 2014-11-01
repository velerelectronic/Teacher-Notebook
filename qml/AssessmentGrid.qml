/* Licenses:

  CC0:
  * Table edit: http://pixabay.com/es/ventana-tabla-cuadrados-inform%C3%A1tica-27140/

  */


import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    id: assessmentGrid
    width: 100
    height: 62
    property string pageTitle: qsTr("Graella d'avaluació");
    property var buttons: buttonsModel

    property string groupFilter: ''
    property string individualFilter: ''
    property string variableFilter: ''
    property string valueFilter: ''
    property string commentFilter: ''

    signal openTabularEditor()

    Common.UseUnits { id: units }

    DatabaseBackup {
        id: dataBck

        Component.onCompleted: {
//            dataBck.dropTable('assessmentGrid');
            dataBck.createTable('assessmentGrid','id INTEGER PRIMARY KEY, created TEXT, moment TEXT, "group" TEXT, individual TEXT, variable TEXT, value TEXT, comment TEXT');
            console.log('Taula creada');
        }
    }

    SqlTableModel {
        id: gridModel
        tableName: 'assessmentGrid'
        fieldNames: ['id','created','moment','group','individual','variable','value','comment']
        limit: 200
        filters: []

        function setAllFilters() {
            var newFilters = [];
            if (groupFilter != '')
                newFilters.push('\"group\"=' + "'" + groupFilter + "'");
            if (individualFilter != '')
                newFilters.push('individual=' + "'" + individualFilter + "'");
            if (variableFilter != '')
                newFilters.push('variable=' + "'" + variableFilter + "'");
            if (valueFilter != '')
                newFilters.push('value=' + "'" + valueFilter + "'");
            if (commentFilter != '')
                newFilters.push('comment=' + "'" + commentFilter + "'");
            filters = newFilters;
        }
        function eraseFilters() {
            groupFilter = '';
            individualFilter = '';
            variableFilter = '';
            valueFilter = '';
            commentFilter = '';
            setAllFilters();
        }
    }

    SqlTableModel {
        id: groupModel
        tableName: gridModel.tableName
        fieldNames: gridModel.fieldNames
    }
    SqlTableModel {
        id: individualModel
        tableName: gridModel.tableName
        fieldNames: gridModel.fieldNames
    }
    SqlTableModel {
        id: variableModel
        tableName: gridModel.tableName
        fieldNames: gridModel.fieldNames
    }
    SqlTableModel {
        id: valueModel
        tableName: gridModel.tableName
        fieldNames: gridModel.fieldNames
    }

    Menu {
        id: momentFilterMenu
        title: qsTr('Filtra moment')
    }
    Menu {
        id: groupFilterMenu
        title: qsTr('Filtra grup')
    }
    Menu {
        id: individualFilterMenu
        title: qsTr('Filtra individu')
    }
    Menu {
        id: variableFilterMenu
        title: qsTr('Filtra variable')
    }
    Menu {
        id: valueFilterMenu
        title: qsTr('Filtra valor')
    }
    Menu {
        id: commentFilterMenu
        title: qsTr('Filtra comentari')
    }

    Rectangle {
        id: assessmentHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: units.fingerUnit
        border.color: 'black'

        property real commonWidth: (width - 5 * units.nailUnit) / 6

        RowLayout {
            anchors.fill: parent
            spacing: units.nailUnit

            Text {
                Layout.preferredWidth: assessmentHeader.commonWidth
                Layout.fillHeight: true
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Moment')
                MouseArea {
                    anchors.fill: parent
                    onClicked: momentFilterMenu.popup()
                }
            }
            Text {
                Layout.preferredWidth: assessmentHeader.commonWidth
                Layout.fillHeight: true
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Grup') + ((groupFilter != '')?": " + groupFilter:"")
                MouseArea {
                    anchors.fill: parent
                    onClicked: groupFilterMenu.popup()
                }
            }
            Text {
                Layout.preferredWidth: assessmentHeader.commonWidth
                Layout.fillHeight: true
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Individu') + ((individualFilter != '')?": " + individualFilter:"")
                MouseArea {
                    anchors.fill: parent
                    onClicked: individualFilterMenu.popup()
                }
            }
            Text {
                Layout.preferredWidth: assessmentHeader.commonWidth
                Layout.fillHeight: true
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Variable') + ((variableFilter != '')?": " + variableFilter:"")
                MouseArea {
                    anchors.fill: parent
                    onClicked: variableFilterMenu.popup()
                }
            }
            Text {
                Layout.preferredWidth: assessmentHeader.commonWidth
                Layout.fillHeight: true
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Valor') + ((valueFilter != '')?": " + valueFilter:"")
                MouseArea {
                    anchors.fill: parent
                    onClicked: valueFilterMenu.popup()
                }
            }
            Text {
                Layout.preferredWidth: assessmentHeader.commonWidth
                Layout.fillHeight: true
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Comentari')  + ((commentFilter != '')?": " + commentFilter:"")
                MouseArea {
                    anchors.fill: parent
                    onClicked: commentFilterMenu.popup()
                }
            }
        }
    }

    ListView {
        id: assessmentList

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: assessmentHeader.bottom
        anchors.bottom: parent.bottom

        clip: true

        model: gridModel
        delegate: Rectangle {
            width: assessmentList.width
            height: units.fingerUnit * 2
            border.color: 'black'
            Row {
                id: assessmentRow
                anchors.fill: parent

                property real commonWidth: width / 6
                Editors.TableCell {
                    width: assessmentRow.commonWidth
                    height: parent.height
                    text: model.id + '-' + model.moment
                }

                Editors.TableCell {
                    width: assessmentRow.commonWidth
                    height: parent.height
                    text: model.group
                }
                Editors.TableCell {
                    width: assessmentRow.commonWidth
                    height: parent.height
                    text: model.individual
                }
                Editors.TableCell {
                    width: assessmentRow.commonWidth
                    height: parent.height
                    text: model.variable
                }
                Editors.TableCell {
                    width: assessmentRow.commonWidth
                    height: parent.height
                    text: model.value
                }
                Editors.TableCell {
                    width: assessmentRow.commonWidth
                    height: parent.height
                    text: model.comment
                }
            }
            MouseArea {
                anchors.fill: parent
                onPressAndHold: deleteDialog.confirmDeletion(model.id, model.moment)
            }
        }
    }

    ListModel {
        id: buttonsModel
        ListElement {
            method: 'newAssessmentEditor'
            image: 'plus-24844'
        }
    }

    Action {
        id: groupCommonAction
        onTriggered: {
            groupFilter = source.text;
            gridModel.setAllFilters();
        }
    }
    Action {
        id: individualCommonAction
        onTriggered: {
            individualFilter = source.text;
            gridModel.setAllFilters();
        }
    }
    Action {
        id: variableCommonAction
        onTriggered: {
            variableFilter = source.text;
            gridModel.setAllFilters();
        }
    }
    Action {
        id: valueCommonAction
        onTriggered: {
            valueFilter = source.text;
            gridModel.setAllFilters();
        }
    }
    Action {
        id: commentCommonAction
        onTriggered: {
            commentFilter = source.text;
            gridModel.setAllFilters();
        }
    }

    Action {
        id: deleteFilter
        onTriggered: {
            gridModel.eraseFilters();
        }
    }

    MessageDialog {
        id: deleteDialog
        title: qsTr('Esborrar item')
        standardButtons: StandardButton.Ok | StandardButton.Cancel

        property string itemId: ''

        function confirmDeletion(item, moment) {
            deleteDialog.itemId = item
            deleteDialog.text = "L'element " + item + " del moment " + moment + " s'esborrara. Vols continuar?";
            deleteDialog.open();
        }

        onAccepted: {
            if (gridModel.removeObjectWithKeyValue(itemId))
                gridModel.select();
        }
    }

    Component.onCompleted: {
        updateGrid();
        prepareFilter('\"group\"', groupFilterMenu, groupCommonAction);
        prepareFilter('individual', individualFilterMenu, individualCommonAction);
        prepareFilter('variable', variableFilterMenu, variableCommonAction);
        prepareFilter('value', valueFilterMenu, valueCommonAction);
        prepareFilter('comment', commentFilterMenu, commentCommonAction);
        gridModel.limit = undefined;
    }

    function prepareFilter(field,menu,action) {
        menu.addItem('- Esborra -').action = deleteFilter;
        var values = gridModel.selectDistinct(field,'id','',false);
        for (var i=0; i<values.length; i++) {
            menu.addItem(values[i]).action = action;
        }
    }

    function newAssessmentEditor() {
        openTabularEditor();
    }

    function updateGrid() {
        gridModel.select();
    }
}
