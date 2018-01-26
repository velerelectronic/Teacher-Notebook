import QtQuick 2.5
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

import 'qrc:///common' as Common

Dialog {
    id: superposedWidget

    Common.UseUnits {
        id: units
    }

    property int parentWidth: Screen.width
    property int parentHeight: Screen.height

    property bool autoDestroy: true
    property Item mainItem: subPanelLoader.item

    standardButtons: StandardButton.Close

    onVisibilityChanged: {
        if ((!visible) && (autoDestroy)) {
            subPanelLoader.sourceComponent = undefined;
        }
    }

    function load(title, page, args) {
        superposedWidget.title = title;
        subPanelLoader.sourceComponent = undefined;
        console.log('----------')
        console.log("qrc:///modules/" + page + ".qml", args)
        subPanelLoader.setSource("qrc:///modules/" + page + ".qml", args);
        superposedWidget.open();
    }

    contentItem: Rectangle {
        implicitHeight: parentHeight * 0.8
        implicitWidth: parentWidth * 0.8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            spacing: units.nailUnit

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 2
                RowLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: superposedWidget.title
                    }
                    Common.ImageButton {
                        Layout.fillHeight: true
                        image: 'road-sign-147409'
                        onClicked: superposedWidget.close()
                    }
                }
            }

            Loader {
                id: subPanelLoader
                Layout.fillHeight: true
                Layout.fillWidth: true

                clip: true

                Connections {
                    target: subPanelLoader.item
                    ignoreUnknownSignals: true

                    onClose: {
                        subPanelLoader.sourceComponent = undefined;
                        superposedWidget.close();
                    }
                    onDiscarded: {
                        subPanelLoader.sourceComponent = undefined;
                        superposedWidget.close();
                    }
                }
            }
        }

    }

}

