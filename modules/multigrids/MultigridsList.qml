import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Common.ThreePanesNavigator {
    id: gridsListBaseItem

    Common.UseUnits {
        id: units
    }

    signal multigridSelected(int multigrid)
    signal createNewVariable(int multigrid)
    signal editVariable(int multigrid, int variable)
    signal editVariableValue(int variable, int value)

    property int selectedMultigrid: -1

    onMultigridSelected: {
        selectedMultigrid = multigrid;
        variablesModel.update();
    }

    MultigridsModel {
        id: gridsModel

        function newGrid(title, desc) {
            insertObject({title: title, desc: desc, config: ''});
            select();
        }

        function updateGrid(id, obj) {
            updateObject(id, obj);
            update();
        }

        function lookForGrid(multigrid) {
            for (var i=0; i<count; i++) {
                var obj = getObjectInRow(i);
                if (obj['id'] == multigrid)
                    return obj;
            }
            return null;
        }

        Component.onCompleted: select()
    }

    MultigridVariablesModel {
        id: variablesModel

        property int keyVariable: -1
        property string keyVariableTitle: ""
        property string keyVariableDesc: ""

        signal updated()

        function update() {
            var keyVariableObj = selectKeyVariable(selectedMultigrid);
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
            bindValues = [selectedMultigrid];
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

    firstPane: Common.NavigationPane {
        headingText: qsTr('Llista de graelles')
        color: '#86B404'

        Common.GeneralListView {
            id: gridsList

            anchors.fill: parent

            model: gridsModel

            headingBar: Rectangle {
                color: 'red'

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3

                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: qsTr('Títol')
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: qsTr('Descripció')
                    }
                }
            }

            delegate: Rectangle {
                width: gridsList.width
                height: Math.max(titleEditor.requiredHeight, descEditor.requiredHeight)

                color: (model.id == selectedMultigrid)?'yellow':((selectGridMouseArea.enabled)?'white':'gray')

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Common.EditableText {
                        id: titleEditor

                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3

                        text: model.title

                        onTextChangeAccepted: {
                            gridsModel.updateGrid(selectedMultigrid, {title: text});
                        }

                        onEditorClosed: selectGridMouseArea.enabled = true;
                    }

                    Common.EditableText {
                        id: descEditor

                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        text: model.desc

                        onTextChangeAccepted: {
                            gridsModel.updateGrid(selectedMultigrid, {desc: text});
                        }

                        onEditorClosed: selectGridMouseArea.enabled = true;
                    }
                }
                MouseArea {
                    id: selectGridMouseArea

                    anchors.fill: parent
                    onClicked: {
                        selectedMultigrid = model.id;
                        multigridSelected(model.id);
                        openPane('second');
                    }
                    onPressAndHold: {
                        enabled = false;
                    }
                }
            }

            Common.SuperposedButton {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }

                size: units.fingerUnit * 1.5
                imageSource: 'plus-24844'

                onClicked: {
                    var date = new Date();
                    gridsModel.newGrid(qsTr('Graella') + date.toLocaleDateString(), 'Nova graella');
                }
            }
        }

    }

    secondPane: Common.NavigationPane {
        id: oneGridView

        headingText: qsTr('Graella: ') + "<b>" + multigridTitle + "</b>" + multigridDesc
        color: Qt.lighter('green')

        property string multigridTitle
        property string multigridDesc

        GenericGrid {
            id: genericGrid

            // Columns: variables (not keys)
            // Rows: the key variable with its values

            Connections {
                target: gridsListBaseItem

                onMultigridSelected: {
                    var mg = gridsModel.lookForGrid(multigrid);
                    if (mg != null) {
                        oneGridView.multigridTitle = mg['title'];
                        oneGridView.multigridDesc = mg['desc'];
                    }
                }
            }

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

                        var obj = dataModel.getAllDataInfo(variablesModel.keyVariable, keyValueId, varId);
                        // var obj = dataModel.lookFor(variablesModel.keyVariable, keyValueId, varId);
                        if (obj !== null) {
                            console.log('data', keyValueId, obj['id'], obj['secondValue']);
                            columnValues.push({key: keyValueId, value: obj['secondValue'], text: "<p>" + obj['secondValueTitle'] + "</p><p>" + obj['secondValueDesc'] + "</p>"});
                        } else {
                            console.log('data', keyValueId, -1, "buit");
                            columnValues.push({key: keyValueId, value: -1, text: ''});
                        }
                    }
                    cellsModel.append({key: varId, columns: columnValues});
                }
            }

            Connections {
                target: variablesModel

                onUpdated: {
                    genericGrid.getHeadingsFromVariables();
                }
            }

            Connections {
                target: keyValuesModel

                onUpdated: {
                    genericGrid.getHeadingsFromKeyValues();
                    genericGrid.getDataValues();
                }
            }

            onAddColumn: createNewVariable(selectedMultigrid)
            onAddRow: editVariableValue(variablesModel.keyVariable, -1)

            onEditColumn: {
                editVariable(selectedMultigrid, key);
            }
            onEditRow: {
                console.log('key var', variablesModel.keyVariable);
                editVariableValue(variablesModel.keyVariable, key);
            }

            onCellReselected: {
                console.log("C x R", colKey, rowKey)
                setThirdPaneSource('multigrids/MultigridDataEditor', {keyVariable: variablesModel.keyVariable, keyValue: rowKey, secondVariable: colKey, secondValue: value}, {headingText: qsTr("Edita valors")});
                //dataEditorConnections.target = thirdPaneItem;
                openPane('third');
            }
            onCellSelected: console.log('cell', colKey, rowKey)

            onHorizontalHeadingCellSelected: console.log('hheading', column)
            onVerticalHeadingCellSelected: console.log('vheading', row)

            Connections {
                id: dataEditorConnections

                target: thirdPaneItem.innerItem
                ignoreUnknownSignals: true

                onValueChanged: {
                    variablesModel.update();
                    openPane('second');
                }
            }
        }

    }

    thirdPane: Common.NavigationPane {
        id: editorsPane

        headingText: ''
        headingColor: 'black'
    }

    Connections {
        target: thirdPaneItem.innerItem
        ignoreUnknownSignals: true

        onVariableCreated: {
            variablesModel.update();
            openPane('second');
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
            openPane('second');
        }
    }

    Connections {
        target: gridsListBaseItem

        onCreateNewVariable: {
            setThirdPaneSource('multigrids/MultigridVariableEditor', {multigrid: multigrid}, {headingText: qsTr("Crear una nova variable")});
            openPane('third');
        }

        onEditVariable: {
            console.log('key----', variable);
            setThirdPaneSource('multigrids/MultigridVariableEditor', {multigrid: multigrid, variable: variable}, {headingText: qsTr('Editor de variable')});
            openPane('third');
        }

        onEditVariableValue: {
            setThirdPaneSource('multigrids/MultigridVariableEditor', {multigrid: selectedMultigrid, variable: variable}, {headingText: qsTr('Editor de variable')});
            openPane('third');
        }

    }
}
