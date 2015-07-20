import QtQuick 2.5
import QtMultimedia 5.2
import QtQuick.Layouts 1.1
import PersonalTypes 1.0

Rectangle {
    id: cameraShoot

    signal takenData(string data)
    signal closeCamera

    property var receiver

    states: [
        State {
            name: 'preparePhoto'
            PropertyChanges {
                target: photoPreview
                visible: false
            }
        },
        State {
            name: 'previewPhoto'
            PropertyChanges {
                target: photoPreview
                visible: true
            }
        }
    ]
    state: 'preparePhoto'

    Camera {
        id: camera
        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceAuto
        captureMode: Camera.CaptureStillImage

        imageCapture {
            onImageCaptured: {
                photoPreview.source = preview;
            }
            onImageSaved: {
                photoData.source = path;
            }
        }
    }

    VideoOutput {
        anchors.fill: parent
        source: camera
        focus: visible

        RowLayout {
            id: takePhotoOptions
            visible: true

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: units.nailUnit
            }
            Button {
                text: qsTr('Fes foto')
                onClicked: {
                    camera.imageCapture.capture();
                    cameraShoot.state = 'previewPhoto';
                }
            }
        }
    }

    ImageData {
        id: photoData
    }

    Image {
        id: photoPreview
        anchors.fill: parent

        fillMode: Image.PreserveAspectFit

        RowLayout {
            id: decidePhotoOptions

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: units.nailUnit
            }
            spacing: units.nailUnit

            Button {
                text: qsTr('Accepta')
                onClicked: {
                    receiver.receiveCameraData(photoData.dataURL);
                    closeCamera();
                }
            }
            Button {
                text: qsTr('Rebutja')
                onClicked: {
                    cameraShoot.closeCamera();
                }
            }
            Button {
                text: qsTr('Repeteix')
                onClicked: cameraShoot.state = 'preparePhoto'
            }
        }
    }
}

