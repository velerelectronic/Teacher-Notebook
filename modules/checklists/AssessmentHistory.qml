import QtQuick 2.7
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Item {
    id: assessmentHistoryItem

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: gridValuesList

            Layout.fillWidth: true
            Layout.fillHeight: true

            property string selectedSectioningField: ''

            clip: true
            model: gridModel

            Models.AssessmentGridModel {
                id: gridModel

                sort: 'id DESC'
            }

            spacing: units.nailUnit

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                id: listHeaderRect

                z: 2
                width: gridValuesList.width
                height: Math.max(units.fingerUnit, createdHeader.requiredHeight, momentHeader.requiredHeight, groupHeader.requiredHeight, individualHeader.requiredHeight, variableHeader.requiredHeight, valueHeader.requiredHeight, commentHeader.requiredHeight, momentCategoryHeader.requiredHeight, variableCategoryHeader.requiredHeight)

                RowLayout {
                    anchors.fill: parent

                    GridAssessmentListHeader {
                        id: createdHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'created'
                        caption: qsTr('Creat')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                    GridAssessmentListHeader {
                        id: momentHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'moment'
                        caption: qsTr('Moment')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                    GridAssessmentListHeader {
                        id: groupHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'group'
                        caption: qsTr('Grup')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                    GridAssessmentListHeader {
                        id: individualHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'individual'
                        caption: qsTr('Individu')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                    GridAssessmentListHeader {
                        id: variableHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'variable'
                        caption: qsTr('Variable')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                    GridAssessmentListHeader {
                        id: valueHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'value'
                        caption: qsTr('Valor')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                    GridAssessmentListHeader {
                        id: commentHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'comment'
                        caption: qsTr('Comentari')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                    GridAssessmentListHeader {
                        id: momentCategoryHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'momentCategory'
                        caption: qsTr('Categoria de moments')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                    GridAssessmentListHeader {
                        id: variableCategoryHeader

                        Layout.preferredWidth: parent.width / 9
                        Layout.preferredHeight: listHeaderRect.height

                        color: (field == gridValuesList.selectedSectioningField)?'yellow':'white'
                        field: 'variableCategory'
                        caption: qsTr('Categoria de variables')

                        onSectioningSelected: gridValuesList.selectedSectioningField = field
                    }
                }
            }

            section.property: gridValuesList.selectedSectioningField
            section.delegate: Text {
                z: 1
                width: gridValuesList.width
                height: units.fingerUnit
                horizontalAlignment: Text.AlignBottom
                font.pixelSize: units.readUnit
                text: section
            }

            delegate: Rectangle {
                z: 1
                width: assessmentHistoryItem.width
                height: units.fingerUnit * 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.preferredWidth: parent.width / 9
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.created
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 9
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.moment
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 9
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.group
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 9
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.individual
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 9
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.variable
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 9
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.value
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.comment
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 9
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.momentCategory
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 9
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.variableCategory
                    }
                }
            }
        }
    }

    Component.onCompleted: gridModel.select()
}

