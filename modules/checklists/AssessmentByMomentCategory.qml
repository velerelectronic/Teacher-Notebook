import QtQuick 2.7
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Item {
    id: assessmentByCategories

    property string groupName: ''
    property var individualsModel: []
    property var variablesModel: []
    property string momentCategory: momentsCategoriesList.momentCategory

    property var momentCategoriesArray: momentsCategoriesList.momentCategoriesArray

    property int variableInfoWidth: units.fingerUnit * 10
    property int momentCategoryInfoWidth: units.fingerUnit * 10

    property int groupLastValueId: -1

    signal addValue(string group, string momentCategory, string individual, string variable)
    signal individualSelected(string individual)

    Common.UseUnits { id: units }

    Models.AssessmentGridModel {
        id: gridModel
    }

    Models.AssessmentGridModel {
        id: lastValueModel

        sort: 'id DESC'
        filters: ["\"group\"=?", "momentCategory=?"]
        //limit: 1

        function getGroupLastValue() {
            bindValues = [groupName, momentCategory];
            select();
            if (count<1) {
                groupLastValueId = -1;
            } else {
                groupLastValueId = lastValueModel.getObjectInRow(0)['id'];
            }
            console.log('group last value id', groupLastValueId);
        }

        Component.onCompleted: {
            getGroupLastValue();
            console.log('groupLastValueId', groupLastValueId);
        }

    }

    Connections {
        target: assessmentByCategories
        onMomentCategoryChanged: lastValueModel.getGroupLastValue()
    }

    Models.AssessmentGridModel {
        id: individualsSqlModel

        filters: ["\"group\"=?"]
        sort: 'individual ASC'

        function selectIndividuals() {
            individualsModel = [];
            bindValues = [groupName];
            select();
            var result = [];
            for (var i=0; i<count; i++) {
                var indivObj = getObjectInRow(i);
                if (result.indexOf(indivObj['individual'])<0)
                    result.push(indivObj['individual']);
            }
            individualsModel = result;
        }
    }

    Models.AssessmentGridModel {
        id: variablesSqlModel

        sort: 'variable ASC'
        filters: ["\"group\"=?"]

        function getVariableNames() {
            assessmentByCategories.variablesModel = [];
            bindValues = [groupName];
            select();
            var result = [];
            for (var i=0; i<count; i++) {
                var variableObj = getObjectInRow(i);
                if (result.indexOf(variableObj['variable'])<0) {
                    console.log(variableObj['variable']);
                    result.push(variableObj['variable']);
                }
            }

            console.log('variables found', result.length);
            assessmentByCategories.variablesModel = result;
        }

        Component.onCompleted: getVariableNames()
    }


    ColumnLayout {
        anchors.fill: parent

        MomentCategoriesList {
            id: momentsCategoriesList

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            groupName: assessmentByCategories.groupName
            autoSelectAfterUpdate: true

            onMomentCategorySelected: updateContents()
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: mainAssessmentList
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    margins: units.nailUnit
                }
                width: variableInfoWidth /3

                model: individualsModel
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
                    MouseArea {
                        anchors.fill: parent
                        onClicked: individualSelected(singleIndividual.individualName)
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
                    width: variablesModel.length * (assessmentByCategories.variableInfoWidth + infoAreaColumn.spacing) - infoAreaColumn.spacing
                    height: infoAreaColumn.childrenRect.height

                    Column {
                        id: infoAreaColumn
                        //height: childrenRect.height
                        spacing: units.nailUnit

                        Repeater {
                            id: individualsList

                            model: individualsModel
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
                                    for (var i=0; i<categoryMomentsList.children.length; i++) {
                                        var newHeight = categoryMomentsList.children[i].calculatedHeight;
                                        if (newHeight > mh)
                                            mh = newHeight;
                                    }
                                    maxHeight = mh;
                                }

                                Row {
                                    id: categoryMomentsList
                                    anchors.fill: parent
                                    spacing: units.nailUnit

                                    Repeater {
                                        model: variablesModel

                                        delegate: Rectangle {
                                            id: singleVariableItem

                                            width: variableInfoWidth
                                            height: categoryMomentsList.height

                                            property string variableName: modelData
                                            property int calculatedHeight: childrenRect.height
                                            onCalculatedHeightChanged: individualInfo.recalculateMaxHeight();

                                            ColumnLayout {
                                                anchors {
                                                    top: parent.top
                                                    left: parent.left
                                                    right: parent.right
                                                }

                                                Common.BoxedText {
                                                    id: variableCaption
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: units.fingerUnit
                                                    text: singleVariableItem.variableName
                                                    color: '#AAFFAA'
                                                    margins: units.nailUnit
                                                    border.width: 0
                                                }
                                                Column {
                                                    id: variableValues
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: childrenRect.height

                                                    Repeater {
                                                        model: singleVariableValueModel

                                                        delegate: Rectangle {
                                                            width: variableValues.width
                                                            height: units.fingerUnit
                                                            border.color: 'black'

                                                            color: ((groupLastValueId > -1) && (model.id == groupLastValueId))?'yellow':'white'

                                                            Text {
                                                                anchors.fill: parent
                                                                anchors.margins: units.nailUnit
                                                                font.pixelSize: units.readUnit
                                                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                                verticalAlignment: Text.AlignVCenter
                                                                horizontalAlignment: Text.AlignHCenter
                                                                text: model.value + ((model.comment !== '')?' (*)':'')
                                                            }
                                                        }
                                                    }

                                                    Models.AssessmentGridModel {
                                                        id: singleVariableValueModel

                                                        sort: 'id DESC'
                                                        filters: ['momentCategory=?', '\"group\"=?', "variable=?", "individual=?"]

                                                        function getValues() {
                                                            console.log('moment category',momentCategory);
                                                            bindValues = [momentCategory, groupName, singleVariableItem.variableName, individualInfo.individualName];
                                                            select();
                                                        }

                                                        Component.onCompleted: getValues()
                                                    }

                                                    Connections {
                                                        target: assessmentByCategories

                                                        onMomentCategoryChanged: singleVariableValueModel.getValues()
                                                    }

                                                }

                                                Common.ImageButton {
                                                    Layout.fillHeight: true
                                                    Layout.preferredWidth: units.fingerUnit
                                                    size: units.fingerUnit
                                                    image: 'plus-24844'
                                                    onClicked: {
                                                        addValue(groupName, momentCategory, individualInfo.individualName,singleVariableItem.variableName);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                onContentYChanged: {
                    if (movingVertically) {
                        mainAssessmentList.contentY = contentY;
                    }
                }

            }

        }
    }


    function updateContents() {
        console.log('updating contents');
        variablesSqlModel.getVariableNames();
        individualsSqlModel.selectIndividuals();
        lastValueModel.getGroupLastValue();
    }

    onGroupNameChanged: {
        momentsCategoriesList.updateCategories();
    }

    Component.onCompleted: {
        momentsCategoriesList.updateCategories();
    }
}

