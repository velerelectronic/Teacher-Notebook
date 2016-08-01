import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///modules/buttons' as Buttons

Item {
    id: basicPageItem

    property string pageTitle: ''

    property Component mainPage
    property alias mainItem: basicPageLocation.item

    property bool isSubPage: false

    property alias subItem: superposedWidgetLoader.item
    property int padding: 0

    signal openMainPage()
    signal closePage()
    signal openMenu(int initialHeight, var menu, var options)
    signal openPageArgs(string page, var args)
    signal showMessage(string message)

    property alias buttonsModel: buttonsList.buttons


    property bool pageClosable: true

    function setSource(source, parameters) {
        basicPageLocation.setSource(source, parameters);
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            RowLayout {
                anchors.fill: parent
                Common.ImageButton {
                    Layout.preferredWidth: units.fingerUnit
                    Layout.preferredHeight: units.fingerUnit

                    size: units.fingerUnit

                    image: (basicPageItem.isSubPage)?'arrow-145769':'small-41255'
                    onClicked: {
                        if (basicPageItem.isSubPage)
                            closePage();
                        else
                            basicPageItem.openMainPage();
                    }
                }

                Text {
                    id: title
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    font.bold: true
                    font.pixelSize: units.glanceUnit
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Tahoma"
                    text: basicPageItem.pageTitle
                }

                Buttons.ButtonsList {
                    id: buttonsList
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width
                }
            }
        }
        Loader {
            id: basicPageLocation

            Layout.fillHeight: true
            Layout.fillWidth: true
            sourceComponent: mainPage
            clip: true

            onLoaded: {
                if (typeof basicPageLocation.item !== 'undefined') {
                    basicPageLocation.item.width = basicPageLocation.width;
                    basicPageLocation.item.height = basicPageLocation.height;
                }
            }            
        }
    }


    Common.SuperposedWidget {
        id: superposedWidget

        Loader {
            id: superposedWidgetLoader

            anchors.fill: parent
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

    function requestClosePage() {
        subPageloader.sourceComponent = null;
        subPageArea.visible = false;
        subPageArea.enabled = false;
    }

    function closeSubPage() {
        subPageloader.source = undefined;
    }

    function closeThisPage() {
        closePage();
    }

    function lookFor() {
        basicPageItem.openPageArgs('OmniboxSearch',{});
    }

    function openSuperposedMenu(widget, minWidth, minHeight, page, params) {
        superposedWidget.anchoringItem = widget;
        superposedWidget.minimumWidth = minWidth - superposedWidget.margins * 2;
        superposedWidget.minimumHeight = minHeight - superposedWidget.margins * 2;
        superposedWidget.showWidget();
        superposedWidgetLoader.setSource(page, params);
    }

    function closeSuperposedMenu() {
        superposedWidget.hideWidget();
        superposedWidgetLoader.sourceComponent = undefined;
    }

    Component.onCompleted: {

    }
}

