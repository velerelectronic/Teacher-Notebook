import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

Rectangle {
    width: 100
//    height: 62

    property string pageTitle: qsTr("Llista d'avaluació");
    property var buttons: buttonsModel
    signal exportedContents()
    signal emitSignal(string name, var param)

    property string selectedGroup: ''

    Common.UseUnits { id: units }

    ListModel {
        id: buttonsModel
        ListElement {
            method: 'newAssessmentEditor'
            image: 'plus-24844'
        }
        ListElement {
            method: 'exportList'
            image: 'box-24557'
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

    SqlTableModel {
        id: individualsModel
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
                                individualsList.fillIndividuals(model.modelData);
                                selectedGroup = model.modelData;
                            }
                        }
                    }
                    highlight: Rectangle {
                        color: 'green'
                    }
                }
            }
        }

        ListView {
            id: individualsList
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: units.nailUnit
            clip: true
            property string groupName: ''

            delegate: Rectangle {
                border.color: 'black'
                radius: units.fingerUnit / 2
                height: childrenRect.height + radius * 2
                width: individualsList.width
                ColumnLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: parent.radius
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        Text {
                            Layout.preferredWidth: contentWidth
                            font.pixelSize: units.readUnit
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.modelData
                        }
                        Text {
                            id: valuesNumber
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: units.readUnit
                        }
                    }
                    ListView {
                        id: valuesList
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentItem.height
                        interactive: false
                        section.delegate: Text {
                            height: contentHeight
                            width: valuesList.width
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.smallReadUnit
                            color: 'gray'
                            text: {
                                var thisSection = onlyDate(section);
                                var prevSection = onlyDate(previousSection);
                                return (thisSection == prevSection)?'':thisSection;
                            }

                            function onlyDate(cad) {
                                return cad.substring(0,cad.indexOf(' '));
                            }
                        }
                        section.property: 'moment'
                        section.labelPositioning: ViewSection.InlineLabels

                        delegate: Rectangle {
                            border.color: 'green'
                            height: Math.max(units.fingerUnit,totalHeight)
                            width: valuesList.width
                            property int totalHeight: Math.max(momentText.contentHeight,variableText.contentHeight,valueText.contentHeight,commentText.contentHeight) + units.nailUnit * 2
                            property string valueDate: model.moment.substring(0,model.moment.indexOf(' '))
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                spacing: units.nailUnit
                                Text {
                                    id: momentText
                                    Layout.preferredWidth: (parent.width - 2 * units.nailUnit) / 4
                                    Layout.fillHeight: true
                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    text: model.moment
                                }
                                Text {
                                    id: variableText
                                    Layout.preferredWidth: (parent.width - 2 * units.nailUnit) / 4
                                    Layout.fillHeight: true
                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    text: model.variable
                                }
                                Text {
                                    id: valueText
                                    Layout.preferredWidth: (parent.width - 2 * units.nailUnit) / 4
                                    Layout.fillHeight: true
                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    text: model.value
                                }
                                Text {
                                    id: commentText
                                    Layout.preferredWidth: (parent.width - 2 * units.nailUnit) / 4
                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    text: model.comment
                                }
                            }
                        }

                        model: valuesModel

                        SqlTableModel {
                            id: valuesModel
                            tableName: 'assessmentGrid'
                            fieldNames: gridModel.fieldNames
                        }

                        function fillValues(individual) {
                            valuesModel.filters = ['\"group\"=\'' + individualsList.groupName + '\'','individual=\''+ individual + '\''];
                            console.log('----');
                            console.log(individual);
                            console.log(valuesModel.filters);
                            valuesModel.setSort(2,Qt.DescendingOrder);
                            valuesModel.select();
                        }

                        onCountChanged: valuesNumber.text = count + ' valoracions'

                    }
                    Component.onCompleted: valuesList.fillValues(model.modelData)
                }
            }

            function fillIndividuals(group) {
                groupName = group;
                var individuals = individualsModel.selectDistinct('individual', 'id', '\"group\"=\"' + group + '\"', false);
                individualsList.model = individuals;
            }
        }
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

    function newAssessmentEditor() {
        emitSignal('openTabularEditor',{group: selectedGroup});
    }

    TextEdit {
        id: clipboard
        width: 0
        height: 0
        visible: false
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
