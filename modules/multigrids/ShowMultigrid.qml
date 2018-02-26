import QtQuick 2.7
import 'qrc:///common' as Common

GenericGrid {
    id: genericGrid

    Common.UseUnits {
        id: units
    }

    // Columns: variables (not keys)
    // Rows: the key variable with its values

    property int multigrid
    property string multigridTitle
    property string multigridDesc

    signal newHeading(string text)
    signal openCard(string page, var pageProperties, var cardProperties)
    signal connectToNextCard(var connections)

    cellPadding: units.nailUnit

    MultigridsModel {
        id: gridsModel

        function lookForGrid() {
            filters = ['id=?'];
            bindValues = [multigrid];
            select();
            if (count>0) {
                var obj = getObjectInRow(0);
                multigridTitle = obj['title'];
                multigridDesc = obj['desc'];
                console.log('invoking new heading');
                newHeading(qsTr('Graella ') + multigridTitle + " " + multigridDesc);
            }
        }
    }

    MultigridVariablesModel {
        id: variablesModel

        property int keyVariable: -1
        property string keyVariableTitle: ""
        property string keyVariableDesc: ""

        signal updated()

        function update() {
            var keyVariableObj = selectKeyVariable(multigrid);
            if (keyVariableObj != null) {
                keyVariable = keyVariableObj['id'];
                keyVariableTitle = keyVariableObj['title'];
                keyVariableDesc = keyVariableObj['desc'];
            } else {
                keyVariable = -1;
                keyVariableTitle = "";
                keyVariableDesc = "";
            }

            filters = ['multigrid=?', 'isKey=0'];
            bindValues = [multigrid];
            select();
            updated();
            keyValuesModel.update();
        }

        function addVariable() {
            var date = new Date();
            insertObject({multigrid: selectedMultigrid, title: qsTr('Var') + date.toDateString(), desc: ''});
            update();
        }
    }

    MultigridFixedValuesModel {
        id: keyValuesModel

        property int keyVariable: variablesModel.keyVariable
        signal updated()

        function update() {
            filters = ["variable=?"]
            console.log('hey2', keyVariable);
            bindValues = [keyVariable];
            select();
            updated();
        }
    }

    MultigridDataModel {
        id: dataModel
    }

    onMultigridChanged: initData()

    columnSpacing: 0
    rowSpacing: 0

    crossHeadingText: variablesModel.keyVariableTitle
    crossHeadingKey: variablesModel.keyVariable

    function getHeadingsFromKeyValues() {
        verticalHeadingModel.clear();
        for (var i=0; i<keyValuesModel.count; i++) {
            var valueObj = keyValuesModel.getObjectInRow(i);
            verticalHeadingModel.append({text: valueObj['title'], key: valueObj['id']});
        }
    }

    function getHeadingsFromVariables() {
        horizontalHeadingModel.clear();
        for (var i=0; i<variablesModel.count; i++) {
            var varObj = variablesModel.getObjectInRow(i);
            horizontalHeadingModel.append({text: varObj['title'], key: varObj['id']});
        }
    }

    function getDataValues() {
        // Traverse non-key variables and for each of them, traverse key values
        // In the crossing, look for associated pairs key-value with non-key-values

        cellsModel.clear();
        console.log("ALL DATA", variablesModel.count, keyValuesModel.count);
        for (var i=0; i<variablesModel.count; i++) {
            var varId = variablesModel.getObjectInRow(i)['id'];

            var columnValues = [];
            for (var j=0; j<keyValuesModel.count; j++) {
                var keyValueId = keyValuesModel.getObjectInRow(j)['id'];

                dataModel.getAllDataInfo(variablesModel.keyVariable, keyValueId, varId);
                var newContents = [];

                for (var k=0; k<dataModel.count; k++) {
                    var singleObj = dataModel.getObjectInRow(k);
                    newContents.push({key: singleObj['id'], value: singleObj['secondValue'], text: "<p>" + singleObj['secondValueTitle'] + "</p><p>" + singleObj['secondValueDesc'] + "</p>"});
                }
                var newObj = {key: keyValueId, value: -1, contents: newContents};
                columnValues.push(newObj);
            }
            cellsModel.append({key: varId, columns: columnValues});
        }
    }

    Connections {
        target: variablesModel

        onUpdated: {
            getHeadingsFromVariables();
        }
    }

    Connections {
        target: keyValuesModel

        onUpdated: {
            getHeadingsFromKeyValues();
            getDataValues();
        }
    }

    onAddColumn: {
        openCard('multigrids/MultigridVariableEditor', {multigrid: genericGrid.multigrid}, {headingText: qsTr("Crear una nova variable")});
        connectToNextCard(variableEditorConnections);
    }
    onAddRow: {
        //editVariableValue(variablesModel.keyVariable, -1)
        openCard('multigrids/MultigridVariableEditor', {multigrid: multigrid, variable: variablesModel.keyVariable}, {headingText: qsTr('Editor de variable')});
        connectToNextCard(variableEditorConnections);
    }

    onEditColumn: {
        openCard('multigrids/MultigridVariableEditor', {multigrid: multigrid, variable: key}, {headingText: qsTr('Editor de variable')});
        connectToNextCard(variableEditorConnections);
    }
    onEditRow: {
        openCard('multigrids/MultigridVariableEditor', {multigrid: multigrid, variable: variablesModel.keyVariable}, {headingText: qsTr('Editor de variable')});
        connectToNextCard(variableEditorConnections);
    }

    onCellReselected: {
        openCard('multigrids/MultigridDataEditor', {keyVariable: variablesModel.keyVariable, keyValue: rowKey, secondVariable: colKey, secondValue: value}, {headingText: qsTr("Edita valors")});
        connectToNextCard(dataEditorConnections);
    }

    Connections {
        id: variableEditorConnections

        ignoreUnknownSignals: true

        onVariableCreated: {
            variablesModel.update();
        }

        onTitleChanged: {
            variablesModel.update();
        }

        onDescChanged: {
            variablesModel.update();
        }

        onIsKeyChanged: {
            variablesModel.update();
        }

        onVariableValueAdded: keyValuesModel.update()

        onVariableValuesChanged: keyValuesModel.update()

        onVariableRemoved: {
            variablesModel.update();
        }
    }

    Connections {
        id: dataEditorConnections

        ignoreUnknownSignals: true

        onValueChanged: {
            variablesModel.update();
        }
    }

    function initData() {
        gridsModel.lookForGrid();
        variablesModel.update();
    }

    Component.onCompleted: initData()
}
