import QtQuick 2.6
import QtGraphicalEffects 1.0
import 'qrc:///common' as Common

Rectangle {
    id: spacesView

    color: 'gray'

    property int otherSpacesSize: units.fingerUnit * 2

    Item {
        id: spacesZone

        anchors.fill: parent
    }

    Component {
        id: spaceItemComponent

        SpaceItem {
            onSelectedSpace: spacesView.moveUp(index)
        }
    }

    function addSpace(caption, qmlPage, properties) {
        var index = spacesZone.children.length;
        var spaceProperties = {
            x: index * units.fingerUnit,
            y: index * units.fingerUnit,
            z: index,
            width: parent.width / 3,
            height: parent.height / 3,
            caption: caption,
            qmlPage: qmlPage,
            pageProperties: properties
        }

        console.log('addingg', JSON.stringify(spaceProperties));
        spaceItemComponent.createObject(spacesZone, spaceProperties);
    }

    function moveUp(index) {
        var spacesObjList = spacesZone.children;
        for (var i=0; i<spacesObjList.length; i++) {
            if (spacesObjList[i].z > index) {
                spacesObjList[i].z = spacesObjList[i].z - 1;
            } else {
                if (spacesObjList[i].z == index) {
                    spacesObjList[i].z = spacesObjList.length;
                }
            }
        }
    }
}

