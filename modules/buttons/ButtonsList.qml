import QtQuick 2.5
import QtQml.Models 2.2
import 'qrc:///common' as Common

ListView {
    id: buttonsList

    property ObjectModel buttons: ObjectModel {}
    property int buttonsCount: buttons.children.length;
    property int requiredWidth: contentItem.width

    Common.UseUnits {
        id: units
    }

    onButtonsCountChanged: {
        console.log('CHanged now');
        recalculateDimensions();
    }

    spacing: units.fingerUnit
    interactive: false
    orientation: ListView.Horizontal

    model: buttons

    function recalculateDimensions() {
        for (var i=0; i<buttons.children.length; i++) {
            console.log('button object', i);
            if (buttons.children[i].objectName == 'MainButton') {
                buttons.children[i].height = Qt.binding(function() { return buttonsList.height; });
    //            buttons.children[i].height = Qt.binding(function() {return buttonsList.height; });
            }
        }
    }

    Component.onCompleted: {
//        recalculateDimensions();
    }
}
