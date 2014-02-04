import QtQuick 2.0
import QtQuick.Controls 1.1
import "Storage.js" as Storage

Rectangle {
    id: mainApp
    width: 768
    height: 1014

    signal openAnnotations

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: title.height + 50
        color: "#009900"
        visible: true
        clip: false
        z: 1

        Text {
            id: title
            anchors.verticalCenter: parent.verticalCenter
            height: 25
            color: "#ffffff"
            text: "Teacher Notebook"
            anchors.left: parent.left
            anchors.leftMargin: 10
            font.italic: false
            font.bold: true
            font.pointSize: 32
            verticalAlignment: Text.AlignVCenter
            font.family: "Tahoma"

        }
        Button {
            id: exit
            width: 50
            height: 50
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "Surt"
            anchors.rightMargin: 10
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            onClicked: {
                Qt.quit();
            }
        }
    }
    Loader {
        id: pageLoader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: statusBar.top

        Connections {
            target: pageLoader.item
            ignoreUnknownSignals: true
            onOpenAnnotations: pageLoader.setSource('Annotations.qml')
            onOpenDocumentsList: pageLoader.setSource('DocumentsList.qml')
            /*
            onNewReceipt: pageLoader.setSource('NewReceipt.qml', {receiptName: name})
            onNoNewReceipt: openMainPage()
            onSavedReceipt: pageLoader.setSource('ShowReceipt.qml', {receiptId: receiptId})
            onShowReceipt: pageLoader.setSource('ShowReceipt.qml', {receiptId: id})
            onCloseReceipt: openMainPage()
            onBackup: pageLoader.setSource('Backup.qml')
            onCloseBackup: openMainPage()
            */
        }
    }

    Menu {
        id: mainMenu
        title: 'Menú Teacher Notebook'

        MenuItem {
            text: qsTr("Inicial")
//            onTriggered:
        }

        MenuItem {
            text: qsTr("Anotacions")
        }
        MenuItem {
            text: qsTr("Valoracions")
        }
        MenuItem {
            text: qsTr("Documents")
        }
        MenuItem {
            text: qsTr("Rellotge")
        }
        enabled: true
    }

    StatusBar {
        id: statusBar
        height: 50
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    /*
    ArisenWidget {
        anchors.centerIn: parent

        Rectangle {
            width: 50
            height: 50
            anchors.centerIn: parent
            color: "yellow"
        }
    }
    */
    Component.onCompleted: {
        Storage.initDatabase();
        mainApp.openAnnotations();
        pageLoader.setSource('Annotations.qml')
    }
}
