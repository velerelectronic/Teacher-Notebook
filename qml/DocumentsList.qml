/*
  Llicències CC0
  - Amunt: http://pixabay.com/es/equipo-icono-azul-s%C3%ADmbolo-flecha-31223/
  - Documents: http://pixabay.com/es/plana-icono-documento-tema-28213/
  - Carpeta: http://pixabay.com/es/documento-abierta-carpeta-97576/
  */


import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import Qt.labs.folderlistmodel 2.1

Rectangle {
    width: 300
    height: 200
    property string pageTitle: 'Documents'

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                Image {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.height
                    fillMode: Image.PreserveAspectFit
                    source: 'qrc:///icons/computer-31223.svg'
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (folderList.parentFolder != '') folderList.folder = folderList.parentFolder;
                    }
                }

                Text {
                    text: folderList.folder
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
                Button {
                    id: opcioDetalls
                    text: qsTr('Detalls')
                    checkable: true
                    checked: false
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: folderList
            clip: true

            delegate: Rectangle {
                border.color: 'black'
                width: parent.width
                height: units.fingerUnit

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Image {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.height
                        fillMode: Image.PreserveAspectFit
                        source: 'qrc:///icons/' + (model.fileIsDir?'document-97576':'flat-28213') + '.svg'
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        text: fileName
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: (opcioDetalls.checked)?contentWidth:0
                        verticalAlignment: Text.AlignVCenter
                        text: fileSize.toString() + " bytes"
                        clip: true
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: (opcioDetalls.checked)?contentWidth:0
                        verticalAlignment: Text.AlignVCenter
                        text: fileModified
                        clip: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: folderList.folder = model.fileURL
                }
            }
        }
    }

    FolderListModel {
        id: folderList
        folder: ''
        showDirs: true
        showFiles: true
        showDirsFirst: true
    }
}
