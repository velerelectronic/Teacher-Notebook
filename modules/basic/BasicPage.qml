import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///modules/buttons' as Buttons

Item {
    id: basicPageItem

    objectName: 'basicPage'

    property string pageTitle: ''

    property Component mainPage
    property alias mainItem: basicPageLocation.item

    property bool headingCollapse: false
    property int padding: 0
    property alias sourceComponent: basicPageLocation.sourceComponent

    signal closePage()
    signal openMainPage()
    signal openPageArgs(string page, var args)
    signal showMessage(string message)

    property alias buttonsModel: buttonsList.buttons


    property bool pageClosable: true

    function setSource(source, parameters) {
        basicPageLocation.setSource(source, parameters);
    }


    Item {
        id: heading

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: units.fingerUnit * 1.5

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
                visible: !headingCollapse
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

        anchors {
            top: (headingCollapse)?parent.top:heading.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        sourceComponent: mainPage
        clip: true

        onLoaded: {
            if (typeof basicPageLocation.item !== 'undefined') {
                basicPageLocation.item.width = basicPageLocation.width;
                basicPageLocation.item.height = basicPageLocation.height;
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

    function closeThisPage() {
        closePage();
    }
}
