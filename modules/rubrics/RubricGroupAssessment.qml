import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import PersonalTypes 1.0
import 'qrc:///javascript/Debug.js' as Debug


Item {
    id: rubricRectangle

    property int assessment

    onAssessmentChanged: console.log('2assessment', assessment)

    property int rubric: -1
    property string title
    property string desc
    property string rubricTitle
    property string rubricDesc
    property string group: ''

    property string annotation: ''

    // color: 'gray'

    property int sectionsHeight: units.fingerUnit * 2
    property int sectionsWidth: units.fingerUnit * 3
    property int contentsHeight: units.fingerUnit * 2
    property int contentsWidth: units.fingerUnit * 2

    signal annotationSelected(string annotation)
    signal rubricAssessmentRubricEdit()
    signal rubricAssessmentDetailsEdit()
    signal rubricAssessmentAnnotationEdit()
    signal rubricAssessmentGroupEdit()
    signal rubricAssessmentCriteriumSelected(int criterium)

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            GridLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                columns: 3
                rows: 3
                columnSpacing: units.nailUnit
                rowSpacing: columnSpacing

                Text {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: sectionsWidth
                    text: qsTr('Avaluació')
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
                        text: '<b>' + rubricRectangle.title + '</b> ' + rubricRectangle.desc
                    }
                }

                Common.ImageButton {
                    image: 'edit-153612'
                    size: units.fingerUnit
                    onClicked: rubricAssessmentDetailsEdit()
                }

                Text {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: sectionsWidth
                    text: qsTr('Rúbrica')
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
                        text: rubricRectangle.rubricTitle + rubricRectangle.rubricDesc
                    }
                }
                Common.ImageButton {
                    image: 'edit-153612'
                    size: units.fingerUnit
                    onClicked: rubricAssessmentRubricEdit()
                }

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
                        onClicked: rubricRectangle.annotationSelected(annotation)
                    }
                }
                Common.ImageButton {
                    image: 'edit-153612'
                    size: units.fingerUnit
                    onClicked: rubricAssessmentAnnotationEdit()
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
                Common.ImageButton {
                    image: 'edit-153612'
                    size: units.fingerUnit
                    onClicked: rubricAssessmentGroupEdit()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridLayout {
                anchors.fill: parent

                columns: 2
                rows: 3

                columnSpacing: units.nailUnit
                rowSpacing: units.nailUnit

                Rectangle {
                    id: title
                    Layout.preferredWidth: sectionsWidth
                    Layout.preferredHeight: sectionsHeight

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
                        onClicked: rubricDetailsEdit(rubric,rubricTitle,rubricDesc,rubricsModel)
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
                                editRubricAssessmentByIndividual(assessment,model.id);
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
                                rubricAssessmentCriteriumSelected(model.id);
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
                        id: criteriaListColumn

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
                                property alias lastScoresModel: rubricIndividualLastScoresModel


                                ListView {
                                    id: individualsList

                                    anchors.fill: parent

                                    property bool enableValues: false
                                    property string group: rubricRectangle.group

                                    onGroupChanged: console.log('individual group changed',rubricRectangle.group)

                                    orientation: ListView.Horizontal
                                    interactive: false

                                    model: Models.RubricsLastScoresModel {
                                        id: rubricIndividualLastScoresModel

                                        filters: [
//                                            "group=?",
                                            "criterium=?",
                                            "assessment=?"
                                        ]
                                        bindValues: [
//                                            rubricRectangle.group,
                                            wholeCriteria.criterium,
                                            assessment
                                        ]

                                        onCountChanged: console.log('COUNT',count)
                                        onBindValuesChanged: {
                                            console.log('BIND VALUES-->', bindValues);
                                            select();
                                        }
                                        Component.onCompleted: select()
                                    }

                                    delegate: Rectangle {
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
                                                rubricAssessmentCriteriumSelected(
                                                            assessment,
                                                            wholeCriteria.criterium,
                                                            model.individual,
                                                            model.lastScoreId
                                                        );
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
                            filters: ["assessment='" + assessment + "'"]
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
    }

    Models.RubricsModel {
        id: rubricsModel
    }

    Models.RubricsAssessmentModel {
        id: rubricsAssessmentModel
    }

    SqlTableModel {
        id: rubricsCriteria
        tableName: 'rubrics_criteria'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'ord', 'weight']
        primaryKey: 'id'
        sort: 'ord ASC'
        filters: ["rubric=?"]
        bindValues: [rubricRectangle.rubric]
    }

    Models.IndividualsModel {
        id: individualsModel
        filters: ['"group"=\'' + rubricRectangle.group + "'"]
        sort: 'id ASC'
    }

    Component.onCompleted: {
        // Get assessment details

        rubricsAssessmentModel.select();
        var objAssessment = rubricsAssessmentModel.getObject(rubricRectangle.assessment);
        if ('group' in objAssessment) {
            rubricRectangle.group = objAssessment['group'];
            rubricRectangle.annotation = objAssessment['annotation'];
            rubricRectangle.rubric = objAssessment['rubric'];
            rubricRectangle.title = objAssessment['title'];
            rubricRectangle.desc = objAssessment['desc'];
        }

        // Get rubrics details

        rubricsModel.select();

        var obj = rubricsModel.getObject(rubricRectangle.rubric);
        if ('title' in obj)
            rubricTitle = obj['title'];
        if ('desc' in obj)
            rubricDesc = obj['desc'];


        // Get criteria and individuals

        rubricsCriteria.select();
        individualsModel.select();
    }

}
