import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtQml.Models 2.2

Item {
    property int minimumHeight: 0
    property int minimumWidth: 0
    property Item anchoringItem: null
    property string glowColor: 'black'
    property int margins: 0

    default property alias subwidget: superposedWidget.children
    visible: false

    signal shown()
    signal hidden()

    signal interiorClicked()

    MouseArea {
        anchors.fill: parent
        onPressed: mouse.accepted = true
    }

    Item {
        id: superposedWidget

        // Parent is the enclosing Item
        // MaximumHeight is parent's total height
        // MaximumWidth is parent's total width

        property int maximumHeight: parent.height
        property int maximumWidth: parent.width

        width: minimumWidth
        height: minimumHeight

        /*
        anchors {
            top: (anchoringItem.y + anchoringItem.height + height < enclosingItem.height)?anchoringItem.bottom:undefined
            left: (anchoringItem.x + anchoringItem.width + width < enclosingItem.width)?anchoringItem.right:undefined
            bottom: (anchoringItem.y + anchoringItem.height + height >= enclosingItem.height)?anchoringItem.top:undefined
            right: (anchoringItem.x + anchoringItem.width + width >= enclosingItem.width)?anchoringItem.left:undefined
        }
        */

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log('INT');
                interiorClicked();
            }
        }

        RectangularGlow {
            anchors.fill: parent
            glowRadius: units.nailUnit
            spread: 0.2
            color: glowColor
        }

        function setPosition() {
            var obj = parent.mapFromItem(anchoringItem, anchoringItem.width / 2, anchoringItem.height / 2);

            // Calculate proper position for the widget in order to show it completely
            var posX = obj.x - superposedWidget.width;
            if (posX < margins)
                posX = margins;
            superposedWidget.x = posX;

            var posY = obj.y - superposedWidget.height;
            if (posY < margins)
                posY = margins;
            superposedWidget.y = posY;
        }
    }

    function hideWidget() {
        visible = false;
        hidden();
    }

    function showWidget() {
        visible = true;
        superposedWidget.setPosition();
        shown();
    }

    function toggleWidget() {
        if (visible)
            hideWidget();
        else
            showWidget();
    }
}

