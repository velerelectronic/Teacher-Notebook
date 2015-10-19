import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common

Item {
    id: basicPageItem

    property string pageTitle: basicPageItem.pageTitle
    property Component mainPage

    property int padding: 0

    signal closePage()
    signal openMenu(int initialHeight, var menu)

    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: 0.5
    }

    Loader {
        id: basicPageLoader

        anchors.fill: parent
        anchors.margins: basicPageItem.padding

        property string pageTitle: ((item) && (item.pageTitle))?item.pageTitle:''

        sourceComponent: basicPageItem.mainPage

        onLoaded: {
            buttons.model = getButtonsList();
        }

    }

    MouseArea {
        id: subPageArea

        anchors.fill: parent
        onPressed: mouse.accepted = true
        onPositionChanged: mouse.accepted = true
        propagateComposedEvents: false
        visible: false
        enabled: false

        Rectangle {
            anchors.fill: parent
            color: 'black'
            opacity: 0.5
        }

        Rectangle {
            id: subPageRect
            anchors.fill: parent
            anchors.margins: basicPageItem.padding
            border.color: 'black'
            border.width: units.nailUnit

            Rectangle {
                id: subBar
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: parent.border.width
                    leftMargin: anchors.topMargin
                    rightMargin: anchors.topMargin
                }
                height: units.fingerUnit * 1.5
                color: 'green'
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: ((subPageloader.item) && (subPageloader.item.pageTitle))?subPageloader.item.pageTitle:''
                        color: 'white'
                    }
                    Common.ImageButton {
                        Layout.fillHeight: true
                        size: units.fingerUnit
                        image: 'road-sign-147409'
                        onClicked: requestClosePage()
                    }
                }
            }

            Loader {
                id: subPageloader
                anchors {
                    top: subBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: parent.border.width
                    leftMargin: anchors.bottomMargin
                    rightMargin: anchors.bottomMargin
                }
            }

        }
    }

    Connections {
        target: basicPageLoader.item
        ignoreUnknownSignals: true

        // Slide menu

        onOpenMenu: {
            openMenu(initialHeight, menu);
        }

        // Page handling
        onOpenPage: {
            console.log('Opening page ' + page);
            openNewPage(page,{});
        }
        onClosePage: {
            closeCurrentPage();
            if (message != '')
                messageBox.publishMessage(message);
        }
    }

    MessageDialog {
        id: closeWorkingPageDialog

        title: qsTr("Tancar aquest espai")
        text: qsTr("Vols tancar aquest espai?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: closeWorkingSpace()
    }

    function openSubPage(page, param, padding) {
        subPageArea.visible = true;
        subPageArea.enabled = true;
        subPageRect.anchors.margins = padding;
        subPageloader.setSource(Qt.resolvedUrl(page + '.qml'), param);
    }

    function getButtonsList() {
        var pageObj = pagesStack.currentItem;
        if ((pageObj) && (typeof(pageObj.buttons) !== 'undefined')) {
            return pageObj.buttons;
        } else {
            return undefined;
        }
    }

    function requestClosePage() {
        subPageloader.sourceComponent = null;
        subPageArea.visible = false;
        subPageArea.enabled = false;
    }

    function closeSubPage() {
        subPageloader.source = undefined;
    }
}

