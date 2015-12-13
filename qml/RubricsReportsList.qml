import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
//import QtWebKit 3.0
import QtQml.Models 2.2
import PersonalTypes 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates

BasicPage {
    id: rubricsListBasicPage
    width: 100
    height: 62

    pageTitle: qsTr("Rúbriques");

    Common.UseUnits { id: units }

    mainPage: Item {
        id: historyItem

        ListView {
            id: reportItemsList
            anchors.fill: parent
            model: reportItems
            spacing: units.nailUnit
        }

        ObjectModel {
            id: reportItems

            Common.BoxedText {
                width: reportItemsList.width
                height: units.fingerUnit
                text: qsTr('Llistes')
            }
            Common.BoxedText {
                width: reportItemsList.width
                height: units.fingerUnit
                text: qsTr('Rúbrica:')
            }
            ListView {
                id: rubricsList

                width: reportItemsList.width
                height: units.fingerUnit * 2
                model: rubricsModel

                orientation: ListView.Horizontal

                delegate: Common.BoxedText {
                    height: rubricsList.height
                    width: units.fingerUnit * 4

                    property int rubric: model.id
                    property string rubricTitle: model.title

                    color: 'transparent'
                    border.color: 'black'
                    margins: units.nailUnit

                    text: model.title

                    MouseArea {
                        anchors.fill: parent
                        onClicked: rubricsList.currentIndex = model.index;
                    }

                }
                highlight: Rectangle {
                    height: units.fingerUnit * 4
                    width: units.fingerUnit * 4
                    color: 'yellow'
                }
            }
            Common.BoxedText {
                width: reportItemsList.width
                height: units.fingerUnit
                text: qsTr('Criteris:')
            }
            GridView {
                id: criteriaList

                width: reportItemsList.width
                height: Math.max(units.fingerUnit * 2, contentItem.height)

                model: criteriaModel

                cellHeight: units.fingerUnit * 2
                cellWidth: units.fingerUnit * 4

                interactive: false

                delegate: Common.BoxedText {
                    id: singleCriterium

                    height: criteriaList.cellHeight
                    width: criteriaList.cellWidth

                    property int criterium: model.id
                    property string criteriumTitle: model.title

                    states: [
                        State {
                            name: 'selected'
                            PropertyChanges {
                                target: singleCriterium
                                color: 'yellow'
                            }
                        },
                        State {
                            name: 'unselected'
                            PropertyChanges {
                                target: singleCriterium
                                color: 'transparent'
                            }
                        }
                    ]

                    state: 'unselected'

                    color: 'transparent'
                    border.color: 'black'
                    margins: units.nailUnit

                    text: model.title

                    MouseArea {
                        anchors.fill: parent
                        onClicked: singleCriterium.state = (singleCriterium.state == 'unselected')?'selected':'unselected'
                    }

                }
            }
            Common.BoxedText {
                width: reportItemsList.width
                height: units.fingerUnit
                text: qsTr('Grups:')
            }
            GridView {
                id: groupsList

                width: reportItemsList.width
                height: Math.max(units.fingerUnit * 2, contentItem.height)

                model: groupsModel

                cellHeight: units.fingerUnit * 2
                cellWidth: units.fingerUnit * 4

                interactive: false

                delegate: Common.BoxedText {
                    id: singleGroup

                    height: groupsList.cellHeight
                    width: groupsList.cellWidth

                    property string group: model.group

                    states: [
                        State {
                            name: 'selected'
                            PropertyChanges {
                                target: singleGroup
                                color: 'yellow'
                            }
                        },
                        State {
                            name: 'unselected'
                            PropertyChanges {
                                target: singleGroup
                                color: 'transparent'
                            }
                        }
                    ]

                    state: 'unselected'

                    border.color: 'black'
                    margins: units.nailUnit

                    text: model.group

                    MouseArea {
                        anchors.fill: parent
                        onClicked: singleGroup.state = (singleGroup.state == 'unselected')?'selected':'unselected';
                    }

                }
                Component.onCompleted: {
                    groupsModel.selectUnique('group');
                }
            }
            Item {
                width: reportItemsList.width
                height: units.fingerUnit * 10
                RowLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit

                    Calendar {
                        id: historyStartDate

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Calendar {
                        id: historyEndDate

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
            Common.BoxedText {
                width: reportItemsList.width
                height: units.fingerUnit
                text: qsTr('Mitjanes:')
            }
            CheckBox {
                id: criteriaMeansInclude
                width: reportItemsList.width
                height: units.fingerUnit * 2
                text: qsTr('Incloure les mitjanes de cada criteri')
            }
            Button {
                width: reportItemsList.width
                height: units.fingerUnit * 2
                text: qsTr('Genera llista')
                onClicked: historyItem.generateList()
            }
        }

        Models.RubricsCriteriaModel {
            id: criteriaModel

            filters: ['rubric=?']
            bindValues: [(rubricsList.currentIndex>=0)?rubricsList.currentItem.rubric:-1]

        }

        Models.IndividualsModel {
            id: individualsModel
        }

        Models.RubricsLastScoresModel {
            id: traverseRubricsLastScoresModel
            filters: [
                'INSTR(annotationStart,?)',
                'criterium=?',
                '\"group\"=?',
                'individual=?',
                'rubric=?'
            ]
        }

        Connections {
            target: rubricsList
            onCurrentIndexChanged: criteriaModel.select()
        }

        function filterInt(value) {
            if(/^(\-|\+)?([0-9]+|Infinity)$/.test(value))
              return Number(value);
            return NaN;
        }

        function generateList() {
            historyListLayout.visible = true;
            var text = "<html>";
            text += "<head>";
            text += "<style text=\"text/css\">";
            text += "h1 { text-decoration: underline }";
            text += "</style>";
            text += "</head>";
            text += "<body>";
            text += "<h1>Llista</h1>"

            var rubricTitle = rubricsList.currentItem.rubricTitle;
            text += "<p>Rúbrica: " + rubricTitle + "</p>";

            for (var i=0; i < criteriaList.contentItem.children.length; i++) {
                var criteriumObj = criteriaList.contentItem.children[i];
                if (criteriumObj.state == 'selected') {
                    text += "<h2>Criteri: " + criteriumObj.criteriumTitle + "</h2>";

                    for (var j=0; j < groupsList.contentItem.children.length; j++) {
                        var groupObj = groupsList.contentItem.children[j];
                        if (groupObj.state == 'selected') {
                            text += "<h3>Grup: " + groupObj.group + "</h3>";

                            var valuesForCriteriaArray = [];

                            individualsModel.filters = ["\"group\"=?"];
                            individualsModel.bindValues = [groupObj.group];
                            individualsModel.select();

                            text += "<table style=\"border: solid 1pt black; border-collapse: collapse\">";
                            text += "<tr>";
                            text += "<th>Data</th>";
                            console.log('individuals count', individualsModel.count);
                            for (var indiv = 0; indiv < individualsModel.count; indiv++) {
                                var indivObj = individualsModel.getObjectInRow(indiv);
                                text += "<th style=\"border: solid 1pt black; padding: 1ex\">" + indivObj.surname + ", " + indivObj.name + ":" + indivObj.group + "." + "</th>";
                                valuesForCriteriaArray.push({sum: 0, count: 0});
                            }
                            text += "</tr>";

                            var day = historyStartDate.selectedDate;

                            while (day <= historyEndDate.selectedDate) {
                                text += "<tr>";
                                text += "<td>" + day.toLongDate() + "</td>";

                                for (var indiv = 0; indiv < individualsModel.count; indiv++) {
                                    var indivObj = individualsModel.getObjectInRow(indiv);
                                    traverseRubricsLastScoresModel.bindValues = [
                                                day.toYYYYMMDDFormat(),
                                                criteriumObj.criterium,
                                                groupObj.group,
                                                indivObj.id,
                                                rubricsList.currentItem.rubric
                                            ];
                                    traverseRubricsLastScoresModel.select();

                                    var c = "";
                                    for (var valuesRow = 0; valuesRow < traverseRubricsLastScoresModel.count; valuesRow++) {
                                        c = "<p>";
                                        var rowObj = traverseRubricsLastScoresModel.getObjectInRow(valuesRow);
                                        c += rowObj['score'] + " " + rowObj['definition'];
                                        c += "</p>";
                                        var score = filterInt(rowObj['score']);
                                        if (score == score) {
                                            valuesForCriteriaArray[indiv].sum += score;
                                            valuesForCriteriaArray[indiv].count += 1;
                                        }
                                    }

                                    text += "<td style=\"border: solid 1pt black; padding: 1ex\">" + c +  "</td>";
                                }

                                text += "</tr>";
                                day.setDate(day.getDate() + 1);
                            }

                            if (criteriaMeansInclude.checked) {
                                text += "<tr>";
                                text += "<td>Suma</td>";
                                for (var indiv = 0; indiv < individualsModel.count; indiv++) {
                                    text += "<td>";
                                    text += valuesForCriteriaArray[indiv].sum;
                                    text += "</td>";
                                }
                                text += "</tr>"
                                text += "<tr>";
                                text += "<td>Recompte</td>";
                                for (var indiv = 0; indiv < individualsModel.count; indiv++) {
                                    text += "<td>";
                                    text += valuesForCriteriaArray[indiv].count;
                                    text += "</td>";
                                }
                                text += "</tr>"
                                text += "<tr>";
                                text += "<td>Mitjana</td>";
                                for (var indiv = 0; indiv < individualsModel.count; indiv++) {
                                    text += "<td>";
                                    text += Math.round(1000 * valuesForCriteriaArray[indiv].sum / valuesForCriteriaArray[indiv].count)/1000;
                                    text += "</td>";
                                }
                                text += "</tr>"
                            }
                            text += "</table>";
                        }

                    }
                }
            }

            text += "</html>";
            htmlList.htmlSource = text;
        }

        QClipboard {
            id: clipboard
        }

        Rectangle {
            id: historyListLayout

            anchors.fill: parent
            visible: false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        id: htmlList
                        property string htmlSource: ''
                        onHtmlSourceChanged: text = htmlSource
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    text: qsTr('Copia')
                    onClicked: {
                        clipboard.copia(htmlList.htmlSource)
                    }
                }
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    text: qsTr('Tanca')
                    onClicked: historyListLayout.visible = false;
                }
            }
        }

        Models.IndividualsModel {
            id: groupsModel

            fieldNames: ['group']

            sort: 'id DESC'
        }

        Models.RubricsModel {
            id: rubricsModel
            Component.onCompleted: select()
        }

        Component.onCompleted: {
            rubricsModel.select();
        }

    }

}

