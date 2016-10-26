import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    id: assessmentByCategories

    property string groupName: ''
    property var variablesModel: []

    property int variableInfoWidth: units.fingerUnit * 10

    signal addValue(string group, string individual, string variable)

    Common.UseUnits { id: units }

    Models.AssessmentGridModel {
        id: gridModel
    }

    Models.AssessmentGridModel {
        id: individualsModel
    }

    Models.AssessmentGridModel {
        id: variablesSqlModel
    }

    ListView {
        id: mainAssessmentList
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: units.nailUnit
        }
        width: variableInfoWidth /3

        clip: true
        spacing: units.nailUnit
        delegate: Rectangle {
            id: singleIndividual

            width: mainAssessmentList.width
            height: Math.max(infoAreaColumn.children[model.index].maxHeight)
/*
            Behavior on height {
                NumberAnimation { duration: 250 }
            }
*/
            property string individualName: model.modelData
            property int individualIndex: model.index

            color: 'white'
            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit

                text: singleIndividual.individualName
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }

        onContentYChanged: {
            if (movingVertically) {
                individualsInfo.contentY = contentY;
            }
        }
    }

    Flickable {
        id: individualsInfo
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: mainAssessmentList.right
            right: parent.right
            margins: units.nailUnit
        }

        contentHeight: infoArea.height
        contentWidth: infoArea.width
        clip: true

        Item {
            id: infoArea
            width: variablesModel.length * assessmentByCategories.variableInfoWidth
            height: infoAreaColumn.childrenRect.height

            Column {
                id: infoAreaColumn
                //height: childrenRect.height
                spacing: units.nailUnit

                Repeater {
                    id: individualsList
                    delegate: Item {
                        id: individualInfo
                        width: infoArea.width
                        height: maxHeight
                        clip: true

                        /*
                        Behavior on height {
                            PropertyAnimation { duration: 250 }
                        }
                        */

                        property string individualName: model.modelData
                        property int maxHeight: 0

                        function recalculateMaxHeight() {
                            var mh = 0;
        /*
                            for (var i=0; i<variablesList.contentItem.children.length; i++) {
                                var newHeight = variablesList.contentItem.children[i].calculatedHeight;
                                if (newHeight > mh)
                                    mh = newHeight;
                            }
                            */
                            for (var i=0; i<variablesList.children.length; i++) {
                                var newHeight = variablesList.children[i].calculatedHeight;
                                if (newHeight > mh)
                                    mh = newHeight;
                            }
                            maxHeight = mh;
                        }

                        Row {
                            id: variablesList
                            anchors.fill: parent
                            spacing: units.nailUnit

                            Repeater {
                                delegate: Rectangle {
                                    id: singleVariable

                                    property int calculatedHeight: variableTitle.height + valuesGrid.contentHeight
                                    onCalculatedHeightChanged: individualInfo.recalculateMaxHeight();

                                    Layout.alignment: Layout.Top
                                    height: variablesList.height
                                    width: assessmentByCategories.variableInfoWidth
                                    property string variable: model.modelData

                                    ColumnLayout {
                                        id: column
                                        anchors.fill: parent
                                        spacing: 0

                                        Rectangle {
                                            id: variableTitle
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: units.fingerUnit
                                            color: '#AAFFAA'
                                            Text {
                                                anchors.fill: parent
                                                anchors.margins: units.nailUnit
                                                height: contentHeight
                                                font.pixelSize: units.readUnit
                                                font.bold: true
                                                verticalAlignment: Text.AlignVCenter
                                                text: singleVariable.variable
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (valuesGrid.state != 'showOnlyValues') {
                                                        valuesGrid.state = 'showOnlyValues';
                                                    } else {
                                                        valuesGrid.state = 'showValuesAndComments';
                                                    }
                                                }
                                            }
                                        }

                                        GridView {
                                            id: valuesGrid
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
            //                                contentHeight: contentItem.height

                                            cellWidth: parent.width / 5
                                            cellHeight: units.fingerUnit
                                            interactive: false
                                            states: [
                                                State {
                                                    name: 'showOnlyValues'
                                                    PropertyChanges {
                                                        target: valuesGrid
                                                        cellWidth: valuesGrid.width / 5
                                                    }
                                                },
                                                State {
                                                    name: 'showValuesAndComments'
                                                    PropertyChanges {
                                                        target: valuesGrid
                                                        cellWidth: valuesGrid.width
                                                    }
                                                }
                                            ]
                                            state: 'showOnlyValues'

                                            delegate: Rectangle {
                                                border.color: 'black'
                                                width: valuesGrid.cellWidth
                                                height: valuesGrid.cellHeight
                                                Text {
                                                    id: valueText
                                                    anchors {
                                                        top: parent.top
                                                        left: parent.left
                                                        bottom: parent.bottom
                                                    }
                                                    width: valuesGrid.width / 5
                                                    fontSizeMode: Text.Fit
                                                    font.pixelSize: units.readUnit
                                                    verticalAlignment: Text.AlignVCenter
                                                    horizontalAlignment: Text.AlignHCenter
                                                    text: model.value + ((model.comment!=='')?'(*)':'')
                                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                }
                                                Rectangle {
                                                    id: momentRect
                                                    anchors {
                                                        top: parent.top
                                                        left: valueText.right
                                                        bottom: parent.bottom
                                                    }
                                                    width: (valuesGrid.state == 'showValuesAndComments')?(units.fingerUnit*3):0
                                                    clip: true
                                                    color: '#DDDDDD'
                                                    border.color: 'black'
                                                    Text {
                                                        anchors.fill: parent
                                                        font.pixelSize: units.readUnit
                                                        fontSizeMode: Text.Fit
                                                        text: model.moment
                                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                    }
                                                }

                                                Rectangle {
                                                    id: commentRect
                                                    anchors {
                                                        top: parent.top
                                                        left: momentRect.right
                                                        right: parent.right
                                                        bottom: parent.bottom
                                                    }
                                                    clip: true
                                                    color: '#BBBBBB'
                                                    border.color: 'black'
                                                    Text {
                                                        anchors.fill: parent
                                                        font.pixelSize: units.readUnit
                                                        fontSizeMode: Text.Fit
                                                        text: model.comment
                                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                    }

                                                }

                                            }
                                            footer: Item {
                    //                                    border.color: 'black'
                                                width: valuesGrid.width
                                                height: valuesGrid.cellHeight
                                                Text {
                                                    anchors.fill: parent
                                                    font.pixelSize: units.readUnit
                                                    fontSizeMode: Text.Fit
                                                    verticalAlignment: Text.AlignVCenter
                                                    horizontalAlignment: Text.AlignHCenter
                                                    text: qsTr('Afegeix')
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        addValue(groupName,individualInfo.individualName,singleVariable.variable);
                                                    }
                                                }
                                            }

                                            model: valuesModel

                                            SqlTableModel {
                                                id: valuesModel
                                                tableName: gridModel.tableName
                                                fieldNames: gridModel.fieldNames
                                                filters: ['\"group\"=\"' + assessmentByCategories.groupName + '\"', 'individual=\"' + individualInfo.individualName +'\"', 'variable=\"' + singleVariable.variable + '\"']
                                                Component.onCompleted: {
                                                    setSort(2, Qt.AscendingOrder);
                                                    select();
                                                }
                                            }
                                        }
                                    }
                                    Component.onCompleted: individualInfo.recalculateMaxHeight()
                                }
                                model: assessmentByCategories.variablesModel
                            }
                        }
                    }
                }
            }
        }

        ListView {
        }
        onContentYChanged: {
            if (movingVertically) {
                mainAssessmentList.contentY = contentY;
            }
        }

    }

    function fillIndividuals() {
        // assessmentByCategories.groupName = group;
        var individuals = individualsModel.selectDistinct('individual', 'id', '\"group\"=\"' + groupName + '\"', false);
        mainAssessmentList.model = individuals;
        individualsList.model = individuals;
        assessmentByCategories.variablesModel = variablesSqlModel.selectDistinct('variable','id','\"group\"=\"' + groupName + '\"', false);

    }

    onGroupNameChanged: fillIndividuals()

    Component.onCompleted: fillIndividuals()
}

