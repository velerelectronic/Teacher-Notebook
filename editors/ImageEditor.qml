import QtQuick 2.2
import QtMultimedia 5.0
import 'qrc:///common' as Common

Item {
    id: imageItem
    height: units.fingerUnit * 3

    Common.UseUnits { id: units }

    Camera {
        id: camera
        captureMode: Camera.CaptureStillImage
        imageCapture {
            onImageCaptured: imageFromCamera.source = preview
        }
    }

    VideoOutput {
        anchors.fill: parent
        source: camera
        focus: visible

        MouseArea {
            anchors.fill: parent
            onClicked: camera.imageCapture.capture()
        }
    }

    Image {
        id: imageFromCamera
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }

}

