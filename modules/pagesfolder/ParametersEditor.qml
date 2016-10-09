import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

ListView {
    id: parametersList

    property int sectionId
    signal close()

    clip: true

    model: parametersModel

    spacing: units.nailUnit
    header: Common.BoxedText {
        width: parametersList.width
        height: units.fingerUnit
        text: qsTr('Paràmetres')
    }

    delegate: Rectangle {
        id: singleParamterItem

        width: parametersList.width
        height: units.fingerUnit * 5
        RowLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            spacing: units.nailUnit

            Text {
                Layout.fillHeight: true
                Layout.preferredWidth: singleParamterItem.width / 2
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: model.parameter
            }
            Editors.TextAreaEditor3 {
                id: parameterValueEditor

                Layout.fillHeight: true
                Layout.fillWidth: true

                objectName: 'parameterValue_' + model.parameter

                content: model.value

                onContentChanged: parametersModel.setProperty(model.index, 'value', content)
            }
        }
    }

    footer: Common.TextButton {
        text: qsTr('Desa')
        onClicked: saveParameters()
    }

    Models.PagesFolderSectionsModel {
        id: sectionsModel
    }

    ListModel {
        id: parametersModel
    }

    function saveParameters() {
        var parametersArray = {};

        for (var i=0; i<parametersModel.count; i++) {
            var object = parametersModel.get(i);
            parametersArray[object['parameter']] = object['value'];
        }

        sectionsModel.updateObject(sectionId, {parameters: JSON.stringify(parametersArray)});

        close()
    }

    Component.onCompleted: {
        var object = sectionsModel.getObject(sectionId);
        var parameters = JSON.parse(object['parameters']);
        for (var prop in parameters) {
            parametersModel.append({parameter: prop, value: parameters[prop]});
        }
    }
}
