import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    id: descriptionEditorComponent

    property string content: ''

    signal saveAnnotationDescriptionRequest(string content)

    Common.UseUnits {
        id: units
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit

        Editors.TextAreaEditor3 {
            id: descEditor
            Layout.fillHeight: true
            Layout.fillWidth: true

            content: descriptionEditorComponent.content
        }

        Common.ImageButton {
            image: 'floppy-35952'
            size: units.fingerUnit
            onClicked: saveAnnotationDescriptionRequest(descEditor.content)
        }
    }
}

