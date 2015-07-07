import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

Rectangle {
    width: 100
    height: 62

    property string pageTitle: qsTr("Avaluació");
    property var buttons: buttonsModel
    signal exportedContents()
    signal emitSignal(string name, var param)

    property string selectedGroup: ''

    Common.UseUnits { id: units }

    ListModel {
        id: buttonsModel

        Component.onCompleted: {
            append({method: 'newAssessmentEditor', image: 'plus-24844', title: qsTr('Afegeix avaluació')});
            append({method: 'listAssessment', image: 'list-153185', title: qsTr('Mode llista')});
            append({method: 'categorizedAssessment', image: 'hierarchy-35795', title: qsTr('Mode categories')});
            append({method: 'exportList', image: 'box-24557', title: qsTr('Exporta la llista com a HTML')});
        }
    }

    SqlTableModel {
        id: gridModel
        tableName: 'assessmentGrid'
        fieldNames: ['id','created','moment','group','individual','variable','value','comment']
        limit: 200
        filters: []
    }

    SqlTableModel {
        id: groupsModel
        tableName: 'assessmentGrid'
        fieldNames: gridModel.fieldNames
    }

    ColumnLayout {
        anchors.fill: parent
        Item {
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
                            onClicked: {
                                groupList.currentIndex = model.index;
                                selectedGroup = model.modelData;
                                assessmentLoader.item.groupName = selectedGroup;
                            }
                        }
                    }
                    highlight: Rectangle {
                        color: 'green'
                    }
                }
            }
        }
        Loader {
            id: assessmentLoader
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: Qt.resolvedUrl('AssessmentByCategories.qml')

            Connections {
                target: assessmentLoader.item
                ignoreUnknownSignals: true
                onAddValue: emitSignal('openTabularEditor',{group: group, individual: individual, variable: variable})
            }
        }
    }

    function newAssessmentEditor() {
        emitSignal('openTabularEditor',{group: selectedGroup});
    }

    function listAssessment() {
        assessmentLoader.setSource(Qt.resolvedUrl('AssessmentList.qml'),{groupName: selectedGroup});
    }

    function categorizedAssessment() {
        assessmentLoader.setSource(Qt.resolvedUrl('AssessmentByCategories.qml'),{groupName: selectedGroup});
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

    Component.onCompleted: {
        var groups = gridModel.selectDistinct('\"group\"', 'id', '', false);
        groupList.model = groups;
    }
}

