import QtQuick 2.2

Item {
    id: imageButton
    property string image
    property string selectedImage: ''
    property int size: units.fingerUnit
    property bool available: true
    signal clicked

    clip: true

    width: (available)?size:0
    height: (available)?size:0
    visible: available

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: (image)?('qrc:///icons/' + image + '.svg'):''
    }

    Image {
        id: superposedImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false
        source: (selectedImage !== '')?'qrc:///icons/' + selectedImage + '.svg':''
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (selectedImage !== '') {
                superposedImage.visible = !superposedImage.visible;
            }

            imageButton.clicked();
        }
    }
}

