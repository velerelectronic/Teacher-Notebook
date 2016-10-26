import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

ListView {
    id: parametersList

    property int sectionId

    signal close()
    signal parametersSaved()

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
        parametersSaved();
    }

    function getParametersList(page) {
        switch(page) {
        case 'annotations2/AnnotationsList':
            return [];

        case 'calendar/WeeksAnnotationsView':
            return ['initialDate'];

        case 'calendar/YearView':
            return ['fullyear'];

        case 'checklists/AssessmentSystem':
            return ['selectedGroup'];

        case 'documents/ShowDocument':
            return ['document'];

        case 'files/Gallery':
            return ['folder', 'numberOfColumns'];

        case 'whiteboard/WhiteBoard':
            return ['baseDirectory'];

        case 'documents/DocumentsMosaic':
            return ['columnsNumber','rowsNumber','documentsList'];

        case 'documents/DocumentsList':
            return [];

        case 'pagesfolder/SuperposedPapers':
            return [];

        default:
            return [];
        }
    }

    Component.onCompleted: {
        // Get page name and parameters names and values
        var object = sectionsModel.getObject(sectionId);
        var page = object['page'];

        // Extract parameters list
        var parametersList = getParametersList(page);

        // Extract parameters values
        var parametersValues = {};
        try {
            parametersValues = JSON.parse(object['parameters']);
        }catch(e) {}

        // Build new model with parameters names and values
        for (var i=0; i<parametersList.length; i++) {
            var name = parametersList[i]
            parametersModel.append({parameter: name, value: parametersValues[name]});
        }
    }
}
