import QtQuick 2.7
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    id: individualValuesItem

    property string group: ''
    property string individual: ''

    signal updated()

    Common.UseUnits { id: units }

    Models.AssessmentGridModel {
        id: gridModel

        sort: 'id DESC'
        filters: ["\"group\"=?", "individual=?"]

        function getIndividualValues() {
            bindValues = [group, individual];
            select();
        }

        function removeValue(identifier) {
            removeObject(identifier);
            getIndividualValues();
            console.log('removed and updating')
            individualValuesItem.updated();
        }

        Component.onCompleted: getIndividualValues();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.fingerUnit

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            RowLayout {
                anchors.fill: parent
                Text {
                    Layout.preferredWidth: contentWidth
                    font.pixelSize: units.readUnit
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: individual + " ( " + group + ")"
                }
                Text {
                    id: valuesNumber
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: units.readUnit

                    text: gridModel.count + " " + qsTr('valoracions')
                }
            }
        }

        ListView {
            id: valuesList
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            section.delegate: Text {
                height: contentHeight
                width: valuesList.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: units.smallReadUnit
                color: 'gray'
                text: section
            }

            model: gridModel

            section.property: 'momentCategory'
            section.labelPositioning: ViewSection.InlineLabels

            delegate: Rectangle {
                border.color: 'green'
                height: Math.max(units.fingerUnit,totalHeight)
                width: valuesList.width
                property int totalHeight: Math.max(momentText.contentHeight, momentCategoryText.contentHeight, variableText.contentHeight,valueText.contentHeight,commentText.contentHeight) + units.nailUnit * 2
                property string valueDate: model.moment.substring(0,model.moment.indexOf(' '))
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Text {
                        id: momentText
                        Layout.preferredWidth: (parent.width - 2 * units.nailUnit) / 5
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.moment
                    }
                    Text {
                        id: momentCategoryText
                        Layout.preferredWidth: (parent.width - 2 * units.nailUnit) / 5
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.momentCategory
                    }

                    Text {
                        id: variableText
                        Layout.preferredWidth: (parent.width - 2 * units.nailUnit) / 5
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.variable
                    }
                    Text {
                        id: valueText
                        Layout.preferredWidth: (parent.width - 2 * units.nailUnit) / 5
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.value
                    }
                    Text {
                        id: commentText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.comment
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressAndHold: gridModel.removeValue(model.id)
                }
            }
        }
    }

    onGroupChanged: {
        gridModel.getIndividualValues();
    }
}
