import QtQuick 2.7

Rectangle {
    id: imageButton
    property string image
    property string selectedImage: ''
    property int size: units.fingerUnit
    property bool available: true
    property int padding: 0
    signal clicked
    color: 'transparent'

//    clip: true

    width: (available)?(size + padding * 2):0
    height: (available)?(size + padding * 2):0
    visible: available

    Image {
        anchors.fill: parent
        anchors.margins: imageButton.padding

        fillMode: Image.PreserveAspectFit
        smooth: true
        source: (image)?('qrc:///icons/' + image + '.svg'):''
    }

    Image {
        id: superposedImage
        anchors.fill: parent
        anchors.margins: imageButton.padding

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

