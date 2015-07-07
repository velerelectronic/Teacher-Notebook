import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///javascript/Debug.js' as Debug
import "qrc:///javascript/Storage.js" as Storage

Rectangle {
    id: rubricRectangle

    property string pageTitle: qsTr("Avaluació de rúbrica per grups");
    property var buttons: buttonsModel

    property SqlTableModel rubricsModel
    property SqlTableModel rubricsAssessmentModel

    property int rubric: -1
    property int idAssessment: -1
    property string rubricTitle
    property string rubricDesc
    property string group

    property int sectionsHeight: units.fingerUnit * 4
    property int sectionsWidth: units.fingerUnit * 5
    property int contentsHeight: units.fingerUnit * 3
    property int contentsWidth: units.fingerUnit * 7

    signal editRubricDetails(int idRubric, string title, string desc, var model)
    signal editRubricAssessmentDescriptor(
        int idAssessment,
        int criterium,
        int individual,
        int lastScoreId,
        var rubricIndividualScoresSaveModel,
        var rubricIndividualScoresModel,
        var levelDescriptorsModel,
        var individualsModel,
        var lastScoresModel)

    Common.UseUnits { id: units }

    color: 'gray'

    ListModel {
        id: buttonsModel
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            Text {
                Layout.preferredHeight: units.fingerUnit
                Layout.preferredWidth: sectionsWidth
                text: qsTr('Grups')
            }

            Rectangle {
                Layout.preferredHeight: units.fingerUnit
                Layout.fillWidth: true
                color: 'white'
                Text {
                    anchors {
                        fill: parent
                        margins: units.nailUnit
                    }
                    font.pixelSize: units.readUnit
                    text: rubricRectangle.group
                }
            }
        }

        Common.FixedHeadingsTableView {
            id: fixedHeadingsTable
            Layout.fillHeight: true
            Layout.fillWidth: true

            headingsSpacing: units.nailUnit
            verticalHeadingWidth: sectionsWidth
            horizontalHeadingHeight: sectionsHeight

            crossHeadingItem: Rectangle {
                id: title
                anchors.fill: parent

                border.color: 'black'
                color: 'pink'

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

            horizontalHeadingModel: individualsModel
            horizontalHeadingDelegate: Rectangle {
                height: sectionsHeight
                width: contentsWidth
                border.color: 'black'
                color: 'transparent'
                Text {
                    anchors {
                        fill: parent
                        margins: units.nailUnit
                    }

                    clip: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: model.name + " " + model.surname
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fixedHeadingsTable.changeCurrentHorizontalIndex(model.index)
                }
            }
            horizontalHeadingHighlight: Rectangle {
                height: sectionsHeight
                width: contentsWidth
                color: 'yellow'
            }

            verticalHeadingModel: rubricsCriteria
            verticalHeadingDelegate: Rectangle {
                height: contentsHeight
                width: sectionsWidth
                border.color: 'black'
                color: 'transparent'
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
                    onClicked: fixedHeadingsTable.changeCurrentVerticalIndex(model.index)
                }
            }
            verticalHeadingHighlight: Rectangle {
                height: sectionsHeight
                width: contentsWidth
                color: 'yellow'
            }

            mainTabularItem: ListView {
                id: criteriaList
                anchors.fill: parent
                orientation: ListView.Vertical
                interactive: false

                model: rubricsCriteria

                highlight: Rectangle {
                    height: contentsHeight
                    width: criteriaList.width
                    color: '#E3F6CE'
                }

                delegate: Rectangle {
                    id: wholeCriteria
                    height: contentsHeight
                    width: criteriaList.width

                    border.color: 'black'
                    color: 'transparent'

                    property string title: model.title
                    property int verticalIndex: model.index
                    property int criterium: model.id
                    property int criteriumIndex: model.index
                    property bool isCurrentItem: ListView.isCurrentItem

                    SqlTableModel {
                        id: levelDescriptorsModel
                        tableName: 'rubrics_levels_descriptors'
                        fieldNames: ['id', 'criterium', 'criteriumTitle', 'criteriumDesc', 'level', 'definition', 'title', 'desc', 'score']
                        filters: ["criterium='" + wholeCriteria.criterium + "'"]
                        Component.onCompleted: {
                            setSort(8, Qt.DescendingOrder);
                            select();
                        }
                    }

                    ListView {
                        id: individualsList
                        anchors.fill: parent

                        property bool enableValues: false
                        //clip: true

                        model: SqlTableModel {
                            id: rubricIndividualLastScoresModel
                            tableName: 'rubrics_last_scores' // 'rubrics_descriptors_scores'
                            fieldNames: ['assessment', 'individual', 'descriptor', 'moment', 'comment', 'criterium', 'criteriumTitle', 'criteriumDesc', 'weight', 'lastScoreId', 'score', 'level', 'definition']
                            filters: [
                                "\"group\"='" + rubricRectangle.group + "'",
                                "criterium='" +  wholeCriteria.criterium + "'",
                                "assessment='" + idAssessment + "'",
                            ]
                            Component.onCompleted: {
                                select();
                            }
                        }

                        orientation: ListView.Horizontal
                        interactive: false
                        highlight: Rectangle {
                            height: contentsHeight
                            width: contentsWidth
                            color: '#E3F6CE'
                        }

                        SqlTableModel {
                            id: rubricIndividualScoresSaveModel
                            tableName: 'rubrics_scores'
                            fieldNames: ['id', 'assessment', 'descriptor', 'moment', 'individual', 'comment']
                        }


                        delegate: Rectangle {
                            id: valuesForIndividual
                            // The scores for a single individual

                            height: contentsHeight
                            width: contentsWidth
                            border.color: 'black'
                            color: ((valuesForIndividual.isCurrentItem) && (wholeCriteria.isCurrentItem))?'#BEF781':'transparent'

                            property bool isCurrentItem: ListView.isCurrentItem

                            //color: (model.index === fixedHeadingsTable.currentHorizontalIndex)?((wholeCriteria.verticalIndex === fixedHeadingsTable.currentVerticalIndex)?'#ffffaa':'yellow'):'transparent'

                            // property int criteriumId: model.id
                            // property int descriptorId: -1
                            // property string definition: ''

                            Text {
                                id: valuesText
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: (model.lastScoreId == '')?'Cap registre':model.level + " " + model.definition + "\n" + model.score + "\n" + model.comment
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight
                            }

                            SqlTableModel {
                                id: rubricIndividualScoresModel
                                tableName: 'rubrics_descriptors_scores'
                                fieldNames: [
                                    'assessment',
                                    'rubric',
                                    'individual',
                                    'name',
                                    'surname',
                                    '\"group\"',

                                    'criterium',
                                    'criteriumTitle',
                                    'criteriumDesc',
                                    'weight',

                                    'descriptor',
                                    'moment',
                                    'comment',

                                    'level',
                                    'definition',
                                    'score'
                                ]
                                filters: [
                                    "\"group\"='" + rubricRectangle.group + "'",
                                    "criterium='" +  wholeCriteria.criterium + "'",
                                    "assessment='" + idAssessment + "'",
                                    "individual='" + model.individual + "'"
                                ]
                            }


                            MouseArea {
                                property bool selectedCell: (model.index === fixedHeadingsTable.currentHorizontalIndex) || (wholeCriteria.criteriumIndex == fixedHeadingsTable.currentVerticalIndex)
                                anchors.fill: parent
                                preventStealing: false
                                propagateComposedEvents: true

                                onClicked: {
                                    if (selectedCell) {
                                        var levels = [];
                                        for (var i=0; i<levelDescriptorsModel.count; i++) {
                                            levels.push(levelDescriptorsModel.getObjectInRow(i)['id']);
                                        }

                                        var newObj = {
                                            assessment: idAssessment,
                                            individual: model.id,
                                            moment: Storage.currentTime()
                                        }
                                        var newDescriptor;

                                        if (rubricIndividualLastScoresModel.count>0) {
                                            var obj = rubricIndividualLastScoresModel.getObjectInRow(0);
                                            newObj['comment'] = obj['comment'] + '*';
                                            var descriptorIndex = levels.indexOf(obj['descriptor']);
                                            newDescriptor = levels[(descriptorIndex + 1) % levels.length];

                                        } else {
                                            newDescriptor = levels[0];
                                        }
                                        newObj['descriptor'] = newDescriptor;
                                        rubricIndividualScoresSaveModel.insertObject(newObj);
                                        rubricIndividualLastScoresModel.select();
                                    } else {
                                        rubricIndividualScoresModel.setSort(11, Qt.DescendingOrder);
                                        rubricIndividualScoresModel.select();
                                        editRubricAssessmentDescriptor(
                                                    idAssessment,
                                                    wholeCriteria.criterium,
                                                    model.individual,
                                                    model.lastScoreId,
                                                    rubricIndividualScoresSaveModel,
                                                    rubricIndividualScoresModel,
                                                    levelDescriptorsModel,
                                                    individualsModel,
                                                    rubricIndividualLastScoresModel
                                                    );
                                    }
                                }
                                onPressAndHold: {
                                    if (selectedCell) {
                                        rubricIndividualScoresModel.setSort(11, Qt.DescendingOrder);
                                        rubricIndividualScoresModel.select();
                                        editRubricAssessmentDescriptor(
                                                    idAssessment,
                                                    wholeCriteria.criterium,
                                                    model.individual,
                                                    model.lastScoreId,
                                                    rubricIndividualScoresSaveModel,
                                                    rubricIndividualScoresModel,
                                                    levelDescriptorsModel,
                                                    individualsModel,
                                                    rubricIndividualLastScoresModel
                                                    );
                                    }
                                }
                            }
                        }
                        highlightMoveDuration: 200
                        Component.onCompleted: {
                            enableValues = true;
                        }
                    }
                    Connections {
                        target: fixedHeadingsTable
                        onCurrentHorizontalIndexChanged: { individualsList.currentIndex = fixedHeadingsTable.currentHorizontalIndex }
                    }
                }

                Connections {
                    target: fixedHeadingsTable
                    onCurrentVerticalIndexChanged: { criteriaList.currentIndex = fixedHeadingsTable.currentVerticalIndex }
                }
                highlightMoveDuration: 250

                footer: Rectangle {
                    width: criteriaList.width
                    height: sectionsHeight
                    color: 'pink'

                    Row {
                        id: footerRow
                        anchors.fill: parent

                        Repeater {
                            model: totalPointsModel

                            Rectangle {
                                height: footerRow.height
                                width: contentsWidth
                                border.color: 'black'
                                color: '#F5DA81'
                                Text {
                                    anchors.fill: parent
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: units.readUnit
                                    text: model.name + " " + model.surname + ": " + model.points
                                }
                            }
                        }
                        SqlTableModel {
                            id: totalPointsModel
                            tableName: 'rubrics_total_scores'
                            //fieldNames: ['assessment', 'individual', 'total']
                            fieldNames: ['assessment', 'individual', 'weight', 'score', 'points']
                            filters: ["assessment='" + idAssessment + "'"]
                            Component.onCompleted: {
                                setSort(1,Qt.AscendingOrder);
                                select();
                                console.log('TOTAL' + count);
                                Debug.printSqlModel(totalPointsModel);
                            }
                        }
                    }

                }
            }

            verticalHeadingFooter: Rectangle {
                width: sectionsWidth
                height: sectionsHeight
                color: 'yellow'
                Text {
                    anchors {
                        fill: parent
                        margins: units.nailUnit
                    }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: units.readUnit
                    text: qsTr('Total punts')
                }
            }
        }
    }

    SqlTableModel {
        id: rubricsCriteria
        tableName: 'rubrics_criteria'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'ord', 'weight']
    }

    SqlTableModel {
        id: individualsModel
        tableName: 'individuals_list'
        fieldNames: ['id', 'group', 'name', 'surname']
        filters: ['\"group\"=\'' + rubricRectangle.group + '\'']
    }

    onGroupChanged: {
        individualsModel.setSort(0, Qt.AscendingOrder);
        individualsModel.select();
    }

    Component.onCompleted: {
        var filter = ["rubric=\'" + rubricRectangle.rubric + "\'"];
        rubricsCriteria.filters = filter;
        rubricsCriteria.setSort(4, Qt.AscendingOrder);
        rubricsCriteria.select();

        rubricsModel.select();

        var obj = rubricsModel.getObject(rubricRectangle.rubric);
        if ('title' in obj)
            rubricTitle = obj['title'];
        if ('desc' in obj)
            rubricDesc = obj['desc'];

        var objAssessment = rubricsAssessmentModel.getObject(rubricRectangle.idAssessment);
        if ('group' in objAssessment)
            group = objAssessment['group'];

    }
}

