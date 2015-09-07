import QtQuick 2.5

Item {
    id: customDialog

    property int horizontalMargins: width / 8
    property int verticalMargins: height / 8
    property Component customItem: null

    property var content

    signal acceptingDialog(var content)

    function showDialog(content) {
        visible = true;
        enabled = true;

        dialogLoader.sourceComponent = customItem;
        setContent(content);
    }

    function closeDialog(content) {
        if (typeof content !== 'undefined') {
            customDialog.acceptingDialog(content);
        }

        dialogLoader.sourceComponent = undefined;
        enabled = false;
        visible = false;
    }

    visible: false
    enabled: false

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log('Closing')
            customDialog.closeDialog();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: 0.5
    }

    MouseArea {
        anchors.fill: dialogLoader
        propagateComposedEvents: false
    }
    Loader {
        id: dialogLoader
        anchors {
            fill: parent
            leftMargin: parent.horizontalMargins
            rightMargin: parent.horizontalMargins
            topMargin: parent.verticalMargins
            bottomMargin: parent.verticalMargins
        }
        sourceComponent: customItem
    }

    function setContent(content) {
        dialogLoader.item.content = content;
    }

    function getContent() {
        return dialogLoader.item.content;
    }
}
