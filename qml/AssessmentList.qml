import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

Rectangle {
    width: 100
//    height: 62

    property string pageTitle: qsTr("Llista d'avaluació");
    property string groupName: ''

    signal showEvent(var parameters)

    Common.UseUnits { id: units }

    SqlTableModel {
        id: gridModel
        tableName: 'assessmentGrid'
        fieldNames: ['id','created','moment','group','individual','variable','value','comment']
        limit: 200
        filters: []
    }

    SqlTableModel {
        id: individualsModel
        tableName: 'assessmentGrid'
        fieldNames: gridModel.fieldNames
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: individualsList
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: units.nailUnit
            clip: true

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
                            valuesModel.filters = ['\"group\"=\'' + groupName + '\'','individual=\''+ individual + '\''];
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

            function fillIndividuals() {
                var individuals = individualsModel.selectDistinct('individual', 'id', '\"group\"=\"' + groupName + '\"', false);
                individualsList.model = individuals;
            }
        }
    }

    onGroupNameChanged: {
        individualsList.fillIndividuals();
    }
}
