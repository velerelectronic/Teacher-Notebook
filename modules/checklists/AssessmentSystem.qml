import QtQuick 2.7
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic

Item {
    signal exportedContents()
    signal emitSignal(string name, var param)

    property string selectedGroup: ''

    property var groupsArray: []

    Common.UseUnits { id: units }

    Models.AssessmentGridModel {
        id: gridModel
    }

    Models.AssessmentGridModel {
        id: groupsModel

        function selectGroups() {
            groupsArray = gridModel.selectDistinct('\"group\"', 'id', '', false);
        }

        Component.onCompleted: groupsModel.selectGroups()
    }

    ColumnLayout {
        anchors.fill: parent

        Basic.ButtonsRow {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + 2 * units.nailUnit

            Common.ImageButton {
                image: 'plus-24844'
                onClicked: newAssessmentEditor()
            }

            Common.ImageButton {
                image: 'calendar-23684'
                onClicked: fixedColumnsAssessment()
            }

            Common.ImageButton {
                image: 'calendar-23684'
                onClicked: timeAssessment()
            }

            Common.ImageButton {
                image: 'list-153185'
                onClicked: listAssessment()
            }

            Common.ImageButton {
                image: 'hierarchy-35795'
                onClicked: categorizedAssessment()
            }

            Common.ImageButton {
                image: 'calendar-23684'
                onClicked: historyAssessment()
            }

            Common.ImageButton {
                image: 'box-24557'
                onClicked: exportList()
            }
        }

        Item {
            id: groupSelectorItem

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            RowLayout {
                anchors.fill: parent
                Text {
                    text: qsTr('Selecciona grup: ')
                    font.pixelSize: units.readUnit
                }
                ListView {
                    id: groupList
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    orientation: ListView.Horizontal
                    clip: true

                    spacing: units.nailUnit

                    model: groupsArray

                    delegate: Rectangle {
                        radius: units.fingerUnit / 2
                        height: units.fingerUnit
                        width: groupName.contentWidth + radius * 2
                        color: 'yellow'
                        Text {
                            id: groupName
                            anchors.fill: parent
                            anchors.margins: parent.radius
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            width: contentWidth
                            text: model.modelData
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: groupSelectorItem.selectGroup(model.index)
                        }
                    }
                    highlight: Rectangle {
                        color: 'green'
                    }

                    onModelChanged: groupSelectorItem.selectFromSelectedGroup()
                }
            }

            function selectGroup(index) {
                groupList.currentIndex = index;
                selectedGroup = groupList.model[index];
                assessmentLoader.sendSelectedGroup();
            }

            function selectFromSelectedGroup() {
                var idx = groupList.model.indexOf(selectedGroup);
                if (idx>-1) {
                    selectGroup(idx);
                }
            }
        }
        Loader {
            id: assessmentLoader
            Layout.fillHeight: true
            Layout.fillWidth: true

            Connections {
                target: assessmentLoader.item
                ignoreUnknownSignals: true
                onAddValue: {
                    assessmentGeneralEditor.openGeneralEditor(selectedGroup, momentCategory, individual, variable);
                }
                onIndividualSelected: {
                    assessmentGeneralEditor.openIndividualValues(selectedGroup, individual);
                }

                onGroupNameChanged: {
                    selectedGroup = assessmentLoader.item.groupName;
                }
            }

            Component.onCompleted: timeAssessment()

            function sendSelectedGroup() {
                if (item) {
                    item.groupName = selectedGroup;
                }
            }

            function updateContents() {
                if (item) {
                    item.updateContents();
                }
            }
        }
    }

    function newAssessmentEditor() {
        assessmentGeneralEditor.openGeneralEditor({group: selectedGroup});
    }

    function fixedColumnsAssessment() {
        assessmentLoader.setSource(Qt.resolvedUrl('AssessmentFixedColumns.qml'), {groupName: selectedGroup});
    }

    function timeAssessment() {
        assessmentLoader.setSource(Qt.resolvedUrl('AssessmentByMomentCategory.qml'), {groupName: selectedGroup});
    }

    function listAssessment() {
        assessmentLoader.setSource(Qt.resolvedUrl('AssessmentList.qml'),{groupName: selectedGroup});
    }

    function categorizedAssessment() {
        assessmentLoader.setSource(Qt.resolvedUrl('AssessmentByCategories.qml'),{groupName: selectedGroup});
    }

    function historyAssessment() {
        assessmentLoader.setSource(Qt.resolvedUrl('AssessmentHistory.qml'));
    }

    function exportList() {
        var html = "<html>\n";
        html += "<head><meta charset=\"UTF-8\"></head>\n";
        html += "<body>";

        html += "<h1>Llista d'avaluacio</h1>";
        html += "<p>Data: " + (new Date()).toISOString() + "</p>";
        for (var i=0; i<groupList.model.length; i++) {
            html += "<h2>Grup: ";
            var group = groupList.model[i];
            html += group;
            html += "</h2>\n";
            var individuals = individualsModel.selectDistinct('individual', 'id', '\"group\"=\"' + group + '\"', false);
            for (var j=0; j<individuals.length; j++) {
                var individual = individuals[j];
                html += "<h3>Alumne: " + individual + "</h3>\n";
                html += "<table style=\"border: solid 1pt black\"><tr><th>#</th><th>Id</th><th>Moment</th><th>Variable</th><th>Valor</th><th>Comentari</th></tr>\n";

                // Get values from each individual
                exportValuesModel.filters = ['\"group\"=\'' + group + '\'','individual=\''+ individual + '\''];
                exportValuesModel.setSort(2,Qt.DescendingOrder);
                exportValuesModel.select();
                for (var k=0; k<exportValuesModel.count; k++) {
                    html += "<tr>";
                    html += "<td>" + (k+1) + "</td>";
                    var obj = exportValuesModel.getObjectInRow(k);
                    html += "<td>" + obj['id'] + "</td>";
                    html += "<td>" + obj['moment'] + "</td>";
                    html += "<td>" + obj['variable'] + "</td>";
                    html += "<td>" + obj['value'] + "</td>";
                    html += "<td>" + obj['comment'] + "</td>";
                    html += "</tr>\n";
                }

                html += "</table>\n";

            }
        }

        html += "</body></html>";
        console.log(html);
        clipboard.text = html;
        clipboard.selectAll();
        clipboard.copy();
        exportedContents();

        Qt.openUrlExternally("mailto:?subject=" + encodeURIComponent("[TeacherNotebook] Avaluacio") + "&body=" + encodeURIComponent(html));
    }

    TextEdit {
        id: clipboard
        width: 0
        height: 0
        visible: false
    }

    SqlTableModel {
        id: individualsModel
        tableName: 'assessmentGrid'
        fieldNames: gridModel.fieldNames
    }

    SqlTableModel {
        id: exportValuesModel
        tableName: 'assessmentGrid'
        fieldNames: gridModel.fieldNames
    }

    Common.SuperposedWidget {
        id: assessmentGeneralEditor

        title: qsTr("Quadre")

        function openGeneralEditor(group, momentCategory, individual, variable) {
            load(qsTr("Editor general d'avaluacions"), 'checklists/AssessmentGeneralEditor', {group: group, momentCategory: momentCategory, individual: individual, variable: variable});
            dialogConnections.target = assessmentGeneralEditor.mainItem;
        }

        function openIndividualValues(group, individual) {
            load(qsTr("Informació d'individu"), 'checklists/IndividualValues', {group: group, individual: individual});
            dialogConnections.target = assessmentGeneralEditor.mainItem;
        }

        Connections {
            id: dialogConnections
            ignoreUnknownSignals: true

            onClose: assessmentGeneralEditor.close()
            onUpdated: {
                console.log('updated detected');
                assessmentLoader.updateContents();
            }
        }
    }

    onSelectedGroupChanged: assessmentLoader.sendSelectedGroup()
}

