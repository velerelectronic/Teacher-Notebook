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

    signal showExtendedAnnotation(var parameters)

    Common.UseUnits {
        id: units
    }

    Models.IndividualsModel {
        id: individualsModel
        filters: ["\"group\"='" + group + "'"]
        Component.onCompleted: select()
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

        delegate: Rectangle {
            id: individualRow

            property int individual: model.id

            color: '#AAFFAA'
            width: individualsList.width
            height: individualsBox.height + rubricsListItem.height + units.nailUnit

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

                                    property int requiredHeight: (sourceComponent == undefined)?(units.fingerUnit * 2):item.contentItem.height
                                    sourceComponent: undefined
                                }

                                Component {
                                    id: criteriaListComponent

                                    ListView {
                                        id: criteriaList

                                        anchors.fill: parent
                                        anchors.margins: units.nailUnit
                                        spacing: units.nailUnit

                                        interactive: false

                                        model: SqlTableModel {
                                            tableName: 'rubrics_criteria'
                                            fieldNames: ['id', 'title', 'desc', 'rubric', 'ord', 'weight']
                                            filters: ["rubric='" + rubricRow.rubric + "'"]
                                            primaryKey: 'id'

                                            sort: 'weight ASC'
                                            Component.onCompleted: select()
                                        }

                                        delegate: Rectangle {
                                            id: criteriumRow
                                            width: criteriaList.width
                                            height: units.fingerUnit * (rubricRow.maxValue - rubricRow.minValue + 10)

                                            property int criterium: model.id

                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 0

                                                Common.BoxedText {
                                                    Layout.fillHeight: true
                                                    Layout.preferredWidth: units.fingerUnit * 3
                                                    margins: units.nailUnit
                                                    fontSize: units.readUnit
                                                    text: model.title
                                                }

                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    border.color: 'black'

                                                    ListView {
                                                        id: scoresList
                                                        anchors.fill: parent
                                                        orientation: ListView.Horizontal
                                                        layoutDirection: ListView.RightToLeft
                                                        clip: true

                                                        model: Models.RubricsLastScoresModel {
                                                            id: scoresModel
                                                            filters: [
                                                                "individual='" + individualRow.individual + "'",
                                                                "rubric='" + rubricRow.rubric + "'",
                                                                "criterium='" + criteriumRow.criterium + "'"
                                                            ]
                                                            Component.onCompleted: {
                                                                setSort(21, Qt.DescendingOrder);
                                                                select();
                                                            }
                                                        }

                                                        delegate: Rectangle {
                                                            border.color: 'grey'
                                                            color: '#DDDDDD'
                                                            border.width: 1
                                                            width: units.fingerUnit
                                                            height: scoresList.height

                                                            property string start: model.annotationStart

                                                            onStartChanged: console.log('Annotation start ' + start)

                                                            Component.onCompleted: {
                                                                console.log('SCORE: ' + model.score);
                                                                /*
                                                                for (var prop in model) {
                                                                    console.log(prop + ">>>" + model[prop]);
                                                                }
                                                                */
                                                            }

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
                                                                    ColumnLayout {
                                                                        anchors.fill: parent
                                                                        spacing: 0
                                                                        Repeater {
                                                                            model: rubricRow.maxValue - rubricRow.minValue + 1
                                                                            Rectangle {
                                                                                Layout.fillWidth: true
                                                                                Layout.fillHeight: true

                                                                                border.color: 'gray'
                                                                            }
                                                                        }
                                                                    }
                                                                    Common.VerticalBoxDiagram {
                                                                        anchors.fill: parent
                                                                        minimum: rubricRow.minValue
                                                                        maximum: rubricRow.maxValue
                                                                        clip: true
                                                                        value: (model.score==='')?-1:parseInt(model.score)
                                                                        onValueChanged: {
                                                                            console.log("-->" + minimum + "--" + value + "--" + maximum);
                                                                        }
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
                                                                        text: model.comment
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
                }

            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

            }

        }
    }
}

