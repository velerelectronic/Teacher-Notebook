import QtQuick 2.2
import QtMultimedia 5.2
import PersonalTypes 1.0
import 'qrc:///common' as Common

Common.AbstractEditor {
    id: imageEditor
    property string content: ''

    height: units.fingerUnit * 10

    Common.UseUnits { id: units }

    Camera {
        id: camera
        captureMode: Camera.CaptureStillImage
        imageCapture {
            onImageSaved: {
                console.log(path);
                imageData.source = path;
            }
        }
    }

    VideoOutput {
        anchors.fill: parent
        source: camera
        focus: visible
        autoOrientation: true

        MouseArea {
            anchors.fill: parent
            onClicked: camera.imageCapture.capture()
        }
    }

    ImageData {
        id: imageData
        onSourceChanged: {
            imageEditor.content = "data:image/png;base64," + dataURL;
            imageEditor.setChanges(true);
        }
    }

    Image {
        id: imageFromCamera
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }

}

