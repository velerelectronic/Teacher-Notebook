/*
  Llicències CC0
  - Enrere: http://pixabay.com/es/men%C3%BA-rojo-brillante-ventana-145776/
  - Actualitza: http://pixabay.com/es/equipo-verde-icono-s%C3%ADmbolo-flecha-31177/
  - Llista: http://pixabay.com/es/plana-icono-propagaci%C3%B3n-frontera-27140/
  - Botó anterior: http://pixabay.com/es/flecha-verde-brillante-izquierda-145769/
  - Botó següent: http://pixabay.com/es/flecha-verde-brillante-derecho-145766/
  - Obre extern: http://pixabay.com/es/nuevo-internet-abierta-web-38743/
  - Menú extra: http://pixabay.com/es/icono-tema-acci%C3%B3n-barras-fila-27951/
  */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.XmlListModel 2.0
import PersonalTypes 1.0
import 'qrc:///qml' as Qml
import 'qrc:///common' as Common


Rectangle {
    id: feedView

    Common.UseUnits { id: units }

    property string titol
    property var model
    property Component feedDelegate
    property bool oneViewVisible: false
    property string loadingBoxState: ''

//    property alias currentIndex: feedList.currentIndex
    property int statusCache
    property bool formatSectionDate: false
    property bool showReloadButton: !oneViewVisible
    property bool showListButton: oneViewVisible
    property bool showPreviousButton: oneViewVisible
    property bool showNextButton: oneViewVisible

    signal goBack()
    signal reload()

    onStatusCacheChanged: feedView.tradueixEstat(statusCache)

    Item {
        id: mainPanel
        Component.onCompleted: console.log('Creat ara ' + (new Date()).toISOString());

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit

//            property alias model: feedList.model
//            property alias feedDelegate: feedList.delegate

            LoadingBox {
                id: loadingBox
                Layout.fillWidth: true
                Layout.preferredHeight: height
                state: loadingBoxState
                actualitzat: (typeof (model.lastUpdate) != 'undefined')?model.lastUpdate:''
            }

            ListView {
                id: feedList
                property bool mustUpdate: false
                property bool initialValue: true

                Layout.fillHeight: true
                Layout.fillWidth: true

                z: 1
                clip: true
                model: feedView.model
                delegate: feedView.feedDelegate

                section.property: 'grup'
                section.criteria: ViewSection.FullString
                section.delegate: Item {
                    width: childrenRect.width
                    height: childrenRect.height + units.readUnit
                    Rectangle {
                        color: mainBar.color // Same color as the main bar
                        radius: units.nailUnit / 2
                        anchors.left: parent.left
                        width: childrenRect.width + units.nailUnit
                        anchors.top: parent.top
                        anchors.topMargin: units.readUnit
                        height: childrenRect.height + units.nailUnit
                        Text {
                            anchors.margins: units.nailUnit / 2
                            anchors.left: parent.left
                            width: paintedWidth
                            anchors.top: parent.top
                            height: paintedHeight
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            text: (formatSectionDate)?((new Date(section)).escriuDiaMes()):section
                        }
                    }
                }

                Component.onCompleted: {
                    currentIndex = -1;
                    initialValue = false;
                }

                onCurrentIndexChanged: {
                    if (!initialValue) {
                        if (currentIndex>-1) {
                            oneViewVisible = true;
                        }
                    }
                }

                onContentYChanged: {
                    switch(loadingBoxState) {
                    case '':
                    case 'perfect':
                    case 'error':
                        // The view has not been dragged downwards yet
                        if ((contentY<0) && (draggingVertically)) {
                            loadingBoxState = 'updateable';
                        }
                        break;

                    case 'updateable':
                        // The view has previously been dragged downwards
                        if ((movingVertically) && (!draggingVertically)) {
                            console.log('do loading');
                            loadingBoxState = 'loading';
                            feedView.reload();
                        } else {
                            if (contentY>=0)
                                loadingBoxState = 'perfect';
                        }
                        break;

                    case 'loading':
                        // The view has been activated to load new contents
                        break;
                    }
                }

                Rectangle {
                    id: oneView
                    anchors.fill: feedList
                    visible: oneViewVisible
                    z: 3

                    MouseArea {
                        anchors.fill: parent
                        preventStealing: true
                        onPressed: mouse.accepted = true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            id: extraMenu
                            states: [
                                State {
                                    name: 'hidden'
                                    PropertyChanges {
                                        target: extraMenu
                                        height: 0
                                    }
                                },
                                State {
                                    name: 'show'
                                    PropertyChanges {
                                        target: extraMenu
                                        height: Math.round(units.fingerUnit * 1.5)
                                    }
                                }
                            ]

                            state: 'hidden'
                            radius: units.nailUnit
                            color: '#60ff60'
                            Layout.fillWidth: true
                            Layout.preferredHeight: height
                            clip: true

                        }

                    }
                }

            }
        }
        function goToPreviousItem() {
            feedList.decrementCurrentIndex();
            singleItem.situaAlPrincipi();
        }

        function goToNextItem() {
            feedList.incrementCurrentIndex();
            singleItem.situaAlPrincipi();
        }

        function openExternally() {
            Qt.openUrlExternally(singleItem.enllac);
        }
    }

    MessageDialog {
        id: infoMessage
        visible: false
        standardButtons: StandardButton.Ok
        onAccepted: visible = false

        function mostraInfo(text) {
            informativeText = text;
            visible = true;
        }
    }
}

