import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Common.ThreePanesNavigator {
    id: gridsListBaseItem

    Common.UseUnits {
        id: units
    }

    signal multigridSelected(int multigrid)


    MultigridsModel {
        id: gridsModel

        function newGrid(title, desc) {
            insertObject({title: title, desc: desc, config: ''});
            select();
        }

        Component.onCompleted: select()
    }

    firstPane: Common.NavigationPane {
        onClosePane: openPane('first')

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
                height: units.fingerUnit * 2

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

                        text: model.title
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
                        openPane('second');
                        multigridSelected(model.id);
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

        property int selectedMultigrid: -1

        color: Qt.lighter('green')

        Connections {
            target: gridsListBaseItem
            onMultigridSelected: {
                oneGridView.selectedMultigrid = multigrid;
                mgVariablesModel.update();
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: units.nailUnit

            ListView {
                id: variablesList

                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 2

                model: mgVariablesModel

                orientation: ListView.Horizontal

                delegate: Rectangle {
                    width: units.fingerUnit * 4
                    height: variablesList.height

                    border.color: 'white'

                    Text {
                        anchors.fill: parent
                        padding: units.nailUnit

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: '<b>' + model.title + '</b>' + model.desc
                    }
                }

                MultigridVariablesModel {
                    id: mgVariablesModel

                    function update() {
                        filters = ['multigrid=?']
                        bindValues = [oneGridView.selectedMultigrid];
                        select();
                    }

                    function addVariable() {
                        var date = new Date();
                        insertObject({multigrid: oneGridView.selectedMultigrid, title: qsTr('Var') + date.toDateString(), desc: ''});
                        update();
                    }
                }

                Common.SuperposedButton {
                    anchors {
                        right: parent.right
                    }

                    size: units.fingerUnit

                    imageSource: 'plus-24844'

                    onClicked: mgVariablesModel.addVariable()
                }
            }

            GenericGrid {
                Layout.fillHeight: true
                Layout.fillWidth: true

                columnSpacing: 0
                rowSpacing: 0

                onCellSelected: console.log('cell', column, row)
                onHorizontalHeadingCellSelected: console.log('hheading', column)
                onVerticalHeadingCellSelected: console.log('vheading', row)
            }
        }

    }
}

