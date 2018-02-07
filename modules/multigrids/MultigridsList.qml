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

    onMultigridSelected: {
        variablesModel.selectedMultigrid = multigrid;
        variablesModel.update();
    }

    MultigridsModel {
        id: gridsModel

        function newGrid(title, desc) {
            insertObject({title: title, desc: desc, config: ''});
            select();
        }

        Component.onCompleted: select()
    }

    MultigridVariablesModel {
        id: variablesModel

        property int selectedMultigrid: -1
        signal updated()

        function update() {
            if (selectedMultigrid > -1) {
                filters = ['multigrid=?']
                bindValues = [variablesModel.selectedMultigrid];
                select();
                updated();
            }
        }

        function addVariable() {
            var date = new Date();
            insertObject({multigrid: variablesModel.selectedMultigrid, title: qsTr('Var') + date.toDateString(), desc: ''});
            update();

        }

        onSelectedMultigridChanged: fixedValuesModel.update();
    }

    MultigridFixedValuesModel {
        id: fixedValuesModel

        property int selectedVariable: -1
        signal updated()

        function update() {
            if (selectedVariable > -1) {
                filters = ["variable=?"]
                bindValues = [fixedValuesModel.selectedVariable];
                select();
                updated();
            }
        }
    }

    MultigridMainVariablesModel {
        id: mainVariableCandidatesModel
    }

    MultigridDataModel {
        id: dataModel
    }

    firstPane: Common.NavigationPane {
        onClosePane: openPane('first')

        Common.GeneralListView {
            id: gridsList

            anchors.fill: parent

            property int lastSelectedMultigrid: -1

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
                height: units.fingerUnit * 2

                color: (model.id == gridsList.lastSelectedMultigrid)?'yellow':'white'

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

                        text: model.title + "-" + model.id
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: model.desc
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        gridsList.lastSelectedMultigrid = model.id;
                        multigridSelected(model.id);
                        openPane('second');
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

        property int selectedMultigrid: variablesModel.selectedMultigrid

        color: Qt.lighter('green')

        Item {
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                ListView {
                    id: variablesList

                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2

                    model: variablesModel

                    orientation: ListView.Horizontal

                    delegate: Rectangle {
                        width: units.fingerUnit * 4
                        height: variablesList.height

                        border.color: 'black'

                        Text {
                            anchors.fill: parent
                            padding: units.nailUnit

                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            text: '<b>' + model.title + '</b>' + model.desc
                        }
                    }

                    Common.SuperposedButton {
                        anchors {
                            right: parent.right
                        }

                        size: units.fingerUnit

                        imageSource: 'plus-24844'

                        onClicked: variablesModel.addVariable()
                    }
                }

                GenericGrid {
                    id: genericGrid

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    columnSpacing: 0
                    rowSpacing: 0

                    function getHeadingsFromMainValues() {
                        verticalHeadingModel.clear();
                        for (var i=0; i<fixedValuesModel.count; i++) {
                            var valueObj = fixedValuesModel.getObjectInRow(i);
                            verticalHeadingModel.append({text: valueObj['title']});
                        }
                    }

                    function getHeadingsFromVariables() {
                        horizontalHeadingModel.clear();
                        for (var i=0; i<variablesModel.count; i++) {
                            var varObj = variablesModel.getObjectInRow(i);
                            horizontalHeadingModel.append({text: varObj['title']});
                        }
                    }

                    Connections {
                        target: variablesModel

                        onUpdated: {
                            console.log('vars updated;');
                            genericGrid.getHeadingsFromVariables();
                        }
                    }

                    Connections {
                        target: fixedValuesModel

                        onUpdated: {
                            genericGrid.getHeadingsFromMainValues()
                        }
                    }

                    onCellSelected: console.log('cell', column, row)
                    onHorizontalHeadingCellSelected: console.log('hheading', column)
                    onVerticalHeadingCellSelected: console.log('vheading', row)

                    onAddColumn: createNewVariable(variablesModel.selectedMultigrid)

                    onAddRow: {
                        // Add a new value for the main variable
                    }

                    onEditColumn: editVariable(index)
                }
            }
        }
    }

    thirdPane: Common.NavigationPane {
        id: editorsPane

        Loader {
            id: editorLoader

            anchors.fill: parent

            Connections {
                target: gridsListBaseItem

                onCreateNewVariable: {
                    editorLoader.setSource('qrc:///modules/multigrids/MultigridVariableEditor.qml', {multigrid: multigrid});
                    openPane('third');
                }
            }

            Connections {
                target: editorLoader.item
                ignoreUnknownSignals: true

                onClose: openPane('second')

                onVariableCreated: {
                    variablesModel.insertObject({multigrid: editorLoader.item.multigrid, title: title, desc: desc});
                    variablesModel.update();
                    openPane('second');
                }

                onTitleChanged: {
                    variablesModel.updateObject(variable, {title: title});
                    variablesModel.update();
                    openPane('second');
                }

                onDescChanged: {
                    variablesModel.updateObject(variable, {desc: desc});
                    variablesModel.update();
                    openPane('second');
                }
            }
        }

    }
}

