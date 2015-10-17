import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
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
    property string annotation: ''

    property int sectionsHeight: units.fingerUnit * 2
    property int sectionsWidth: units.fingerUnit * 3
    property int contentsHeight: units.fingerUnit * 2
    property int contentsWidth: units.fingerUnit * 2

    signal editRubricDetails(int idRubric, string title, string desc, var model)
    signal editRubricAssessmentDescriptor(
        int idAssessment,
        int criterium,
        int individual,
        int lastScoreId
        )

    signal editRubricAssessmentByCriterium(int assessment, int criterium)
    signal editRubricAssessmentByIndividual(int assessment, int individual)
    signal showExtendedAnnotation(var parameters)

    Common.UseUnits { id: units }

    color: 'gray'

    ListModel {
        id: buttonsModel
    }

    ColumnLayout {
        anchors.fill: parent

        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            columns: 2

            Text {
                Layout.preferredHeight: units.fingerUnit
                Layout.preferredWidth: sectionsWidth
                text: qsTr('Anotació')
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

                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    elide: Text.ElideRight

                    text: rubricRectangle.annotation
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: rubricRectangle.showExtendedAnnotation({title: rubricRectangle.annotation})
                }
            }


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
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    elide: Text.ElideRight
                    text: rubricRectangle.group
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: 2
            rows: 3

            columnSpacing: units.nailUnit
            rowSpacing: units.nailUnit

            Rectangle {
                id: title
                width: sectionsWidth
                height: sectionsHeight

                border.color: 'black'
                color: 'pink'
                clip: true

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

            ListView {
                id: horizontalHeading
                Layout.fillWidth: true
                Layout.preferredHeight: sectionsHeight

                interactive: false
                orientation: ListView.Horizontal

                delegate: Rectangle {
                    id: horizontalHeadingCell

                    property bool selectedCell: false

                    height: sectionsHeight
                    width: horizontalHeading.width / individualsModel.count
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
                        onClicked: {
                            horizontalHeading.currentIndex = model.index;
                            editRubricAssessmentByIndividual(idAssessment,model.id);
                        }
                    }
                }

                model: individualsModel

                highlight: Rectangle {
                    color: 'yellow'
                }
                highlightFollowsCurrentItem: true
            }

            ListView {
                id: verticalHeading

                Layout.fillHeight: true
                Layout.preferredWidth: sectionsWidth

                interactive: false
                orientation: ListView.Vertical

                model: rubricsCriteria

                delegate: Rectangle {
                    id: verticalHeadingCriterium

                    height: verticalHeading.height / rubricsCriteria.count
                    width: verticalHeading.width
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
                        onClicked: {
                            verticalHeading.currentIndex = model.index;
                            editRubricAssessmentByCriterium(idAssessment,model.id);
                        }
                    }
                }

                highlight: Rectangle {
                    color: 'yellow'
                }
                highlightFollowsCurrentItem: true
            }

            Rectangle {
                id: criteriaList

                Layout.fillHeight: true
                Layout.fillWidth: true

                Column {
                    Repeater {
                        model: rubricsCriteria

                        Rectangle {
                            id: wholeCriteria
                            height: criteriaList.height / rubricsCriteria.count
                            width: criteriaList.width

                            property bool selectedCellVertically: false

                            border.color: 'black'
                            color: (selectedCellVertically)?'yellow':'transparent'

                            property string title: model.title
                            property int verticalIndex: model.index
                            property int criterium: model.id
                            property int criteriumIndex: model.index
                            property bool isCurrentItem: ListView.isCurrentItem

                            Row {
                                id: individualsList
                                property bool enableValues: false

                                Repeater {
                                    model: Models.RubricsLastScoresModel {
                                        id: rubricIndividualLastScoresModel
                                        filters: [
                                            "\"group\"='" + rubricRectangle.group + "'",
                                            "criterium='" +  wholeCriteria.criterium + "'",
                                            "assessment='" + idAssessment + "'",
                                        ]
                                        Component.onCompleted: {
                                            select();
                                        }
                                    }
/*
                                    SqlTableModel {
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
*/
                                    Rectangle {
                                        id: valuesForIndividual
                                        // The scores for a single individual

                                        height: wholeCriteria.height
                                        width: wholeCriteria.width / individualsModel.count
                                        border.color: 'black'
                                        color: 'transparent'
                                            // ((valuesForIndividual.isCurrentItem) && (wholeCriteria.isCurrentItem))?'#BEF781':'transparent'

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
                                            text: (model.lastScoreId == '')?'':(model.score + ((model.comment !== '')?'*':''))
                                            clip: true
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            preventStealing: false
                                            propagateComposedEvents: true

                                            onClicked: {
                                                editRubricAssessmentDescriptor(
                                                            idAssessment,
                                                            wholeCriteria.criterium,
                                                            model.individual,
                                                            model.lastScoreId
                                                        );
                                            }
                                        }
                                    }
                                }
                                Component.onCompleted: {
                                    enableValues = true;
                                }
                            }
                        }

                    }
                }

            }

            Rectangle {
                Layout.preferredWidth: sectionsWidth
                Layout.preferredHeight: sectionsHeight
                border.color: 'black'
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

            Rectangle {
                id: footerTotalRow

                Layout.fillWidth: true
                Layout.preferredHeight: sectionsHeight
                color: 'pink'

                Row {
                    Repeater {
                        model: totalPointsModel

                        Rectangle {
                            height: footerTotalRow.height
                            width: footerTotalRow.width / individualsModel.count
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
                        primaryKey: 'id'
                        sort: 'individual ASC'
                        Component.onCompleted: {
                            select();
                            console.log('TOTAL' + count);
                            Debug.printSqlModel(totalPointsModel);
                        }
                    }
                }
            }
        }
    }

    SqlTableModel {
        id: rubricsCriteria
        tableName: 'rubrics_criteria'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'ord', 'weight']
        primaryKey: 'id'
        sort: 'ord ASC'
    }

    Models.IndividualsModel {
        id: individualsModel
        filters: ['"group"=\'' + rubricRectangle.group + '\'']
        sort: 'id ASC'
    }

    onGroupChanged: {
        individualsModel.select();
    }

    Component.onCompleted: {
        var filter = ["rubric=\'" + rubricRectangle.rubric + "\'"];
        rubricsCriteria.filters = filter;
        rubricsCriteria.select();

        rubricsModel.select();

        var obj = rubricsModel.getObject(rubricRectangle.rubric);
        if ('title' in obj)
            rubricTitle = obj['title'];
        if ('desc' in obj)
            rubricDesc = obj['desc'];

        var objAssessment = rubricsAssessmentModel.getObject(rubricRectangle.idAssessment);
        if ('group' in objAssessment) {
            group = objAssessment['group'];
            annotation = objAssessment['annotation'];
        }

    }
}

