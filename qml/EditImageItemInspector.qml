import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

CollectionInspectorItem {
    id: imageEditor

    Common.UseUnits { id: units }

    signal openCamera(var receiver)

    function receiveCameraData(data) {
        cameraData = data;
    }

    property string cameraData: ''

    visorComponent: Image {
        property int requiredHeight: Math.max(scaledHeight,units.fingerUnit)
        property string shownContent
        property int scaledHeight: sourceSize.height * (width / sourceSize.width)

        fillMode: Image.PreserveAspectFit
        source: shownContent
    }

    editorComponent: Item {
        property int requiredHeight: Math.max(photoPreview.scaledHeight,takeButton.height,units.fingerUnit)
        property string editedContent: cameraData

        Connections {
            target: imageEditor
            onCameraDataChanged: editedContent = cameraData
        }

        RowLayout {
            anchors.fill: parent

            Image {
                id: photoPreview
                Layout.fillWidth: true
                Layout.preferredHeight: scaledHeight
                property int scaledHeight: sourceSize.height * (width / sourceSize.width)
                source: editedContent

                fillMode: Image.PreserveAspectFit
            }
            Common.Button {
                id: takeButton
                Layout.preferredHeight: units.fingerUnit * 2
                color: '#F3F781'
                text: qsTr('Càmera')
                onClicked: imageEditor.openCamera(imageEditor)
            }
        }

    }
}
