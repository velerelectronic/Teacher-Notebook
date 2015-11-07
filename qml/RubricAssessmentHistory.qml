import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: rubricAssessmentHistory

    property string pageTitle: qsTr("Historial d'avaluació de rúbrica")

    property int rubric: -1
    property string group: ''

    property var rubricsIdList: []

    signal editRubricAssessmentDescriptor(
        int idAssessment,
        int criterium,
        int individual,
        int lastScoreId
        )

    signal openRubricGroupAssessment(int assessment)
    signal showExtendedAnnotation(var parameters)

    Common.UseUnits {
        id: units
    }

    Models.IndividualsModel {
        id: individualsModel
        filters: ["\"group\"=?"]
        bindValues: [rubricAssessmentHistory.group]
        Component.onCompleted: {
            select();
            console.log('Individuals',individualsModel.count);
        }
    }

    Models.RubricsModel {
        id: rubricsModel
    }

    Models.RubricsAssessmentModel {
        id: rubricsAssessmentModel
        Component.onCompleted: select()
        onCountChanged: {
            console.log('Count ' + count)
            rubricsModel.select();
            rubricsIdList = selectDistinct('rubric', 'id', "\"group\"='" + group + "'", true);
        }
    }

    ListView {
        id: individualsList
        anchors.fill: parent
        anchors.margins: units.nailUnit
        model: individualsModel
        spacing: units.nailUnit
        clip: true

        headerPositioning: ListView.OverlayHeader

        header: Common.BoxedText {
            width: individualsList.width
            height: units.fingerUnit
            margins: units.nailUnit
            text: "<b>Grup:</b> " + rubricAssessmentHistory.group
            z: 2
        }

        delegate: Rectangle {
            id: individualRow

            property int individual: model.id

            color: '#AAFFAA'
            width: individualsList.width
            height: individualsBox.height + rubricsListItem.height + units.nailUnit
            z: 1

            Common.BoxedText {
                id: individualsBox
                border.color: 'transparent'
                color: 'transparent'
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: units.fingerUnit

                margins: units.nailUnit
                fontSize: units.readUnit
                text: model.name + " " + model.surname
            }

            Item {
                id: rubricsListItem
                anchors {
                    top: individualsBox.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: units.nailUnit
                    leftMargin: units.fingerUnit
                }
                height: rubricsList.contentItem.height + 2 * rubricsList.anchors.margins

                ListView {
                    id: rubricsList

                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    interactive: false

                    model: rubricsIdList
                    delegate: Rectangle {
                        id: rubricRow

                        property int rubric: modelData
                        property int minValue: 0
                        property int maxValue: 0

                        color: '#F3F781'
                        width: parent.width
                        height: criteriaListArea.height

                        SqlTableModel {
                            id: levelsModel

                            tableName: 'rubrics_levels'
                            fieldNames: ['id', 'title', 'desc', 'rubric', 'score']
                            filters: ["rubric='" + rubricRow.rubric + "'"]
                            primaryKey: 'id'
                            sort: 'score ASC'

                            Component.onCompleted: select()

                            onCountChanged: {
                                rubricRow.minValue = parseInt(getObjectInRow(0)['score']);
                                rubricRow.maxValue = parseInt(getObjectInRow(count-1)['score']);
                                console.log('MAX set to ' + rubricRow.maxValue + "-- MIN set to " + rubricRow.minValue);

                                for (var i=0; i<levelsModel.count; i++) {
                                    var obj = levelsModel.getObjectInRow(i);
                                    console.log("->" + obj.id + "---" + obj.title + "---" + obj.rubric + "---" + obj.score);
                                }
                                console.log("====");
                            }
                        }

                        RowLayout {
                            anchors.fill: parent

                            Common.BoxedText {
                                Layout.fillHeight: true
                                Layout.preferredWidth: units.fingerUnit * 3

                                color: 'transparent'
                                border.color: 'transparent'
                                margins: units.nailUnit
                                fontSize: units.readUnit
                                text: modelData // model.title
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (criteriaListLoader.sourceComponent == null)
                                            criteriaListLoader.sourceComponent = criteriaListComponent
                                        else
                                            criteriaListLoader.sourceComponent = undefined;
                                    }
                                }
                                Component.onCompleted: {
                                    text = rubricsModel.getObject('id',modelData)['title'];
                                }
                            }

                            Item {
                                id: criteriaListArea
                                Layout.preferredHeight: criteriaListLoader.requiredHeight + 2 * units.nailUnit
                                Layout.fillWidth: true

                                Loader {
                                    id: criteriaListLoader
                                    anchors.fill: parent

                                    property int requiredHeight: (sourceComponent == undefined)?(units.fingerUnit * 2):item.requiredHeight
                                    sourceComponent: undefined
                                }

                                Component {
                                    id: criteriaListComponent

                                    Item {
                                        id: criteriaList

                                        property int requiredHeight: units.fingerUnit * (rubricRow.maxValue - rubricRow.minValue + 10)

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: units.nailUnit
                                            spacing: units.nailUnit

                                            ListView {
                                                id: criteriaTitlesList

                                                Layout.fillHeight: true
                                                Layout.preferredWidth: units.fingerUnit * 3

                                                interactive: false
                                                model: rubricsCriteriaModel
                                                delegate: Rectangle {
                                                    id: criteriaTitlesItem
                                                    width: criteriaTitlesList.width
                                                    border.color: 'black'
                                                    height: criteriaTitlesList.height / rubricsCriteriaModel.count

                                                    states: [
                                                        State {
                                                            name: 'selected'
                                                            PropertyChanges {
                                                                target: criteriaTitlesItem
                                                                color: 'yellow'
                                                            }
                                                        },
                                                        State {
                                                            name: 'unselected'
                                                            PropertyChanges {
                                                                target: criteriaTitlesItem
                                                                color: 'white'
                                                            }
                                                        }
                                                    ]
                                                    state: 'selected'
                                                    Text {
                                                        anchors.fill: parent
                                                        anchors.margins: units.nailUnit
                                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                        text: model.title
                                                        elide: Text.ElideRight
                                                    }
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        onClicked: {
                                                            criteriaTitlesItem.state = (criteriaTitlesItem.state == 'selected')?'unselected':'selected';
                                                        }
                                                        onPressAndHold: {
                                                            for (var i=0; i<criteriaTitlesList.contentItem.children.length; i++) {
                                                                criteriaTitlesList.contentItem.children[i].state = 'unselected';
                                                            }
                                                            criteriaTitlesItem.state = 'selected';
                                                        }
                                                    }
                                                }
                                                SqlTableModel {
                                                    id: rubricsCriteriaModel
                                                    tableName: 'rubrics_criteria'
                                                    fieldNames: ['id', 'title', 'desc', 'rubric', 'ord', 'weight']
                                                    filters: ["rubric='" + rubricRow.rubric + "'"]
                                                    primaryKey: 'id'

                                                    sort: 'ord ASC'
                                                    Component.onCompleted: select()
                                                }
                                            }

                                            ListView {
                                                id: scoresList

                                                Layout.fillHeight: true
                                                Layout.fillWidth: true

                                                orientation: ListView.Horizontal
                                                layoutDirection: ListView.RightToLeft
                                                clip: true

                                                model: Models.RubricsLastScoresModel {
                                                    id: scoresModel
                                                    filters: [
                                                        "individual='" + individualRow.individual + "'",
                                                        "rubric='" + rubricRow.rubric + "'"
                                                    ]
                                                    groupBy: 'annotationTitle'
                                                    sort: 'annotationStart DESC'
                                                    Component.onCompleted: select()
                                                }

                                                delegate: Rectangle {
                                                    id: scoresOfASingleRubric

                                                    border.color: 'grey'
                                                    color: '#DDDDDD'
                                                    border.width: 1
                                                    width: units.fingerUnit
                                                    height: scoresList.height

                                                    property string title: model.annotationTitle
                                                    property string start: model.annotationStart
                                                    property int commentsNumber: 0

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        onClicked: {
                                                            rubricAssessmentHistory.editRubricAssessmentDescriptor(model.assessment, model.criterium, model.individual, model.lastScoreId)
                                                        }
                                                    }

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        spacing: 0

                                                        Item {
                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: units.fingerUnit * 4

                                                            clip: parent
                                                            Text {
                                                                anchors.centerIn: parent
                                                                width: parent.height
                                                                height: parent.width
                                                                font.pixelSize: units.readUnit
                                                                fontSizeMode: Text.Fit
                                                                text: model.annotationStart + " " + model.annotationTitle
                                                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                                verticalAlignment: Text.AlignVCenter
                                                                horizontalAlignment: Text.AlignHCenter
                                                                transformOrigin: Item.Center
                                                                rotation: 270
                                                            }
                                                            MouseArea {
                                                                anchors.fill: parent
                                                                onClicked: rubricAssessmentHistory.showExtendedAnnotation({title: model.annotationTitle})
                                                            }
                                                        }

                                                        Rectangle {
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: true

                                                            border.color: 'gray'
                                                            color: 'transparent'

                                                            Models.RubricsLastScoresModel {
                                                                id: rubricsScoresByDay
                                                                filters: [
                                                                    "individual='" + individualRow.individual + "'",
                                                                    "rubric='" + rubricRow.rubric + "'",
                                                                    "annotationTitle='" + scoresOfASingleRubric.title + "'"
                                                                ]
                                                                sort: 'criteriumOrder ASC'
                                                                Component.onCompleted: {
                                                                    select();
                                                                    scoresOfASingleRubric.commentsNumber = 0;
                                                                    for (var i=0; i<rubricsScoresByDay.count; i++) {
                                                                        if (rubricsScoresByDay.getObjectInRow(i)['comment'] !== '')
                                                                            scoresOfASingleRubric.commentsNumber = scoresOfASingleRubric.commentsNumber + 1;
                                                                    }
                                                                }
                                                            }

                                                            ColumnLayout {
                                                                // Backgorund grid for the score of a single day in a single rubric

                                                                anchors.fill: parent
                                                                spacing: 0
                                                                Repeater {
                                                                    model: rubricRow.maxValue - rubricRow.minValue + 1
                                                                    Rectangle {
                                                                        Layout.fillWidth: true
                                                                        Layout.fillHeight: true

                                                                        border.color: 'gray'
                                                                        color: 'white'
                                                                    }
                                                                }
                                                            }

                                                            Repeater {
                                                                model: rubricsScoresByDay
                                                                delegate: Item {
                                                                    id: criteriumRow

                                                                    anchors.fill: parent

                                                                    Common.VerticalBoxDiagram {
                                                                        anchors.fill: parent
                                                                        visible: criteriaTitlesList.contentItem.children[model.index].state == 'selected'
                                                                        minimum: rubricRow.minValue
                                                                        maximum: rubricRow.maxValue
                                                                        clip: true
                                                                        value: (model.score==='')?-1:parseInt(model.score)
                                                                        legend: Text {
                                                                            verticalAlignment: Text.AlignVCenter
                                                                            horizontalAlignment: Text.AlignHCenter
                                                                            font.pixelSize: units.readUnit
                                                                            fontSizeMode: Text.Fit
                                                                            color: 'white'
                                                                            text: model.score
                                                                        }
                                                                    }
                                                                }
                                                            }

                                                            MouseArea {
                                                                anchors.fill: parent
                                                                onClicked: rubricAssessmentHistory.openRubricGroupAssessment(model.assessment)
                                                            }

                                                        }

                                                        Item {
                                                            clip: true
                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: units.fingerUnit * 4
                                                            Text {
                                                                anchors.centerIn: parent
                                                                width: parent.height
                                                                height: parent.width
                                                                font.pixelSize: units.readUnit
                                                                fontSizeMode: Text.Fit
                                                                text: (scoresOfASingleRubric.commentsNumber>0)?(scoresOfASingleRubric.commentsNumber + qsTr(" comentaris")):""
                                                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                                verticalAlignment: Text.AlignVCenter
                                                                horizontalAlignment: Text.AlignHCenter
                                                                transformOrigin: Item.Center
                                                                rotation: 270
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

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

            }

        }
    }
}

