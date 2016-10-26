import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    id: assessmentByCategories

    property string groupName: ''
    property var categoryMomentsArray: []
    property var individualsModel: []
    property var variablesModel: []
    property string momentCategory: ''

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
        filters: ["\"group\"=?"]
        //limit: 1

        function getGroupLastValue() {
            bindValues = [groupName];
            select();
            if (count<1) {
                groupLastValueId = -1;
            } else {
                groupLastValueId = lastValueModel.getObjectInRow(0)['id'];
            }
        }

        Component.onCompleted: {
            getGroupLastValue();
            console.log('groupLastValueId', groupLastValueId);
        }
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

    Models.AssessmentGridModel {
        id: momentCategoriesModel

        filters: ["\"group\"=?"]
        sort: 'id DESC'

        function selectMomentCategories() {
            bindValues = [groupName];
            select();
            var result = [];
            momentsCategoriesList.model = [];

            for (var i=0; i<count; i++) {
                var newCategory = getObjectInRow(i)['momentCategory'];
                if (result.indexOf(newCategory)<0) {
                    result.push(newCategory);
                }
            }

            momentsCategoriesList.model = result;
            categoryMomentsArray = result;
        }

        Component.onCompleted: selectMomentCategories()
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: momentsCategoriesList

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 3

            orientation: ListView.Horizontal

            spacing: units.nailUnit

            header: Rectangle {
                width: height
                height: momentsCategoriesList.height

                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: qsTr('Sense categoria')
                }
            }
            delegate: Rectangle {
                width: height
                height: momentsCategoriesList.height

                color: (ListView.isCurrentItem)?'yellow':'white'
                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: modelData
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        momentsCategoriesList.currentIndex = model.index;
                        momentCategory = modelData;
                    }
                }
            }
            footer: Text {
                width: (momentCategoriesModel.count>0)?contentWidth:0
                height: momentsCategoriesList.height
                text: qsTr('No hi ha categories')
            }
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
                    width: categoryMomentsArray.length * (assessmentByCategories.momentCategoryInfoWidth + infoAreaColumn.spacing) - infoAreaColumn.spacing
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
                                    id: variablesList
                                    anchors.fill: parent
                                    spacing: units.nailUnit
                                    visible: false

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
                                                                addValue(groupName, momentCategory, individualInfo.individualName,singleVariable.variable);
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

                                Row {
                                    id: categoryMomentsList
                                    anchors.fill: parent
                                    spacing: units.nailUnit

                                    Repeater {
                                        model: categoryMomentsArray

                                        delegate: Rectangle {
                                            id: singleCategoryMomentItem

                                            width: momentCategoryInfoWidth
                                            height: categoryMomentsList.height

                                            property string momentCategory: modelData
                                            property int calculatedHeight: units.fingerUnit + variablesSubList.contentItem.height
                                            onCalculatedHeightChanged: individualInfo.recalculateMaxHeight();

                                            ColumnLayout {
                                                anchors.fill: parent
                                                Common.BoxedText {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: units.fingerUnit
                                                    text: singleCategoryMomentItem.momentCategory
                                                    color: '#AAFFAA'
                                                    margins: units.nailUnit
                                                    border.width: 0
                                                }
                                                ListView {
                                                    id: variablesSubList

                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    interactive: false

                                                    model: variablesModel

                                                    delegate: Rectangle {
                                                        id: singleVariableItem

                                                        width: variablesSubList.width
                                                        height: units.fingerUnit + 2 * units.nailUnit

                                                        property string variableName: modelData
                                                        property string lastValueText: ''
                                                        property int lastValueId: -1

                                                        color: ((groupLastValueId > -1) && (lastValueId > -1) && (lastValueId == groupLastValueId))?'yellow':'white'

                                                        Models.AssessmentGridModel {
                                                            id: singleVariableValueModel

                                                            sort: 'id DESC'
                                                            filters: ['momentCategory=?', '\"group\"=?', "variable=?", "individual=?"]

                                                            function getLastValue() {
                                                                bindValues = [singleCategoryMomentItem.momentCategory, groupName, singleVariableItem.variableName, individualInfo.individualName];
                                                                select();
                                                                var text = "";
                                                                if (count>0) {
                                                                    var obj = getObjectInRow(0);
                                                                    singleVariableItem.lastValueId = obj['id'];
                                                                    text = obj['value'];
                                                                    if (obj['comment'] !== '') {
                                                                        text += " (*)";
                                                                    }
                                                                }

                                                                singleVariableItem.lastValueText = text;
                                                            }

                                                            Component.onCompleted: getLastValue()
                                                        }

                                                        RowLayout {
                                                            anchors.fill: parent
                                                            anchors.margins: units.nailUnit

                                                            Text {
                                                                id: singleVariableNameText
                                                                Layout.fillHeight: true
                                                                Layout.fillWidth: true
                                                                verticalAlignment: Text.AlignVCenter
                                                                text: singleVariableItem.variableName
                                                            }
                                                            Text {
                                                                id: singleVariableValueText

                                                                Layout.preferredWidth: parent.width / 3
                                                                Layout.fillHeight: true

                                                                font.pixelSize: units.readUnit

                                                                verticalAlignment: Text.AlignVCenter
                                                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                                                text: singleVariableItem.lastValueText
                                                            }

                                                            Common.ImageButton {
                                                                Layout.fillHeight: true
                                                                Layout.preferredWidth: units.fingerUnit
                                                                size: units.fingerUnit
                                                                image: 'plus-24844'
                                                                onClicked: {
                                                                    addValue(groupName, singleCategoryMomentItem.momentCategory, individualInfo.individualName,singleVariableItem.variableName);
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
        lastValueModel.getGroupLastValue();
        momentCategoriesModel.selectMomentCategories();
        variablesSqlModel.getVariableNames();
        individualsSqlModel.selectIndividuals();
    }

    onGroupNameChanged: updateContents()

    Component.onCompleted: updateContents()
}

