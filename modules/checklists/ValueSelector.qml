import QtQuick 2.7
import QtQuick.Layouts 1.1

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Item {
    property int requiredHeight: childrenRect.height + units.nailUnit
    property string selectedVariable
    property alias selectedValue: valueTextEditor.content

    Common.UseUnits {
        id: units
    }

    Models.AssessmentGridModel {
        id: valuesModel

        sort: 'value ASC, id ASC'

        function selectValues() {
            filters = ["variable=?"];
            bindValues = [selectedVariable];
            select();
            var result = [];
            for (var i=0; i<count; i++) {
                var newValue = getObjectInRow(i)['value'];
                if (result.indexOf(newValue)<0)
                    result.push(newValue);
            }
            return result;
        }
    }

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        spacing: units.nailUnit

        Editors.TextLineEditor {
            id: valueTextEditor

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5
        }

        Flow {
            id: valuesList

            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            spacing: units.nailUnit

            Repeater {
                id: valuesRepeater

                Rectangle {
                    radius: height / 2
                    border.color: 'green'
                    height: units.fingerUnit
                    width: Math.max(valueText.width + radius * 2, units.fingerUnit * 2)
                    color: 'yellow'
                    Text {
                        id: valueText
                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom: parent.bottom
                            margins: units.nailUnit
                            leftMargin: parent.radius
                        }
                        width: contentWidth
                        text: modelData
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedValue = modelData
                    }
                }
            }
            Component.onCompleted: valuesRepeater.model = valuesModel.selectValues()
        }
    }

    onSelectedVariableChanged: {
        console.log('variable changed');
        valuesRepeater.model = valuesModel.selectValues();
    }

    onSelectedValueChanged: {
        valueTextEditor.content = selectedValue;
    }
}
