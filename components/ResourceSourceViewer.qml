import QtQuick 2.5
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    id: resourceSourceDisplayItem

    property int resource: -1

    Models.ResourcesModel {
        id: resourcesModel
    }

    Image {
        id: mainImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Rotate fill mode
            var fillModes = [Image.Stretch, Image.PreserveAspectFit, Image.PreserveAspectCrop, Image.Pad];
            var index = fillModes.indexOf(mainImage.fillMode);
            mainImage.fillMode = fillModes[(index + 1) % fillModes.length];
        }
    }

    Component.onCompleted: {
        resourcesModel.select();
        var obj = resourcesModel.getObject(resource);
        if (obj['source'] != '')
            mainImage.source = obj['source'];
    }
}
