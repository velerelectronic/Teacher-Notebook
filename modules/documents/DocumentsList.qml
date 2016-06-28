import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///modules/files/mediaTypes.js" as MediaTypes

Item {
    id: documentsListItem

    Common.UseUnits { id: units }

    signal newDocumentSelected()
    signal documentSelected(string document)
    signal documentSourceSelected(string source)

    property int requiredHeight: documentsListView.contentItem.height

    property string selectedIdentifier

    Models.DocumentsModel {
        id: documentsModel

        searchFields: ['title','desc','type','source','hash']

        limit: 30

        sort: 'created DESC'

        Component.onCompleted: {
            select();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        ListView {
            id: documentsListView
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: documentsModel
            spacing: units.nailUnit

            bottomMargin: addDocumentButton.size + addDocumentButton.margins * 2

            header: Rectangle {
                id: documentsHeader

                width: documentsListView.width
                height: units.fingerUnit * 2 + units.nailUnit
                z: 2

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    columnSpacing: units.nailUnit
                    rowSpacing: columnSpacing

                    rows: 2
                    columns: 4

                    Common.SearchBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        Layout.columnSpan: parent.columns

                        onPerformSearch: {
                            documentsModel.searchString = text;
                            documentsModel.select();
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit * 4
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: documentsHeader.width / 4
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Títol i descripció')
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Origen')
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: documentsHeader.width / 4
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Tipus')
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                    }
                }
            }

            headerPositioning: ListView.OverlayHeader

            delegate: Rectangle {
                id: documentItem
                width: documentsListView.width
                height: units.fingerUnit * 4
                z: 1

                Behavior on x {
                    NumberAnimation {
                        duration: 200
                    }
                }

//                border.color: 'grey'

                color: ((model.title == selectedIdentifier) && (selectedIdentifier !== ''))?'yellow':'white'

                MouseArea {
                    anchors.fill: parent
                    drag.target: documentItem
                    drag.axis: Drag.XAxis
                    drag.minimumX: -documentItem.width
                    drag.maximumX: 0

                    property bool dragActive: drag.active

                    onClicked: {
                        selectedIdentifier = model.title;
                        documentsListItem.documentSelected(model.title);
                    }

                    onDragActiveChanged: {
                        if (dragActive) {

                        } else {
                            if (documentItem.x < -documentItem.height * 2) {
                                documentItem.x = -documentItem.width
                            } else {
                                documentItem.x = 0;
                            }
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Item {
                        id: thumbnailItem
                        Layout.fillHeight: true
                        Layout.preferredWidth: height

                        Component {
                            id: thumbnailComponent

                            Image {
                                anchors.fill: thumbnailItem
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Component.onCompleted: {
                            var incubator = thumbnailComponent.incubateObject(thumbnailItem, {source: MediaTypes.imageForMediaType(model.source, model.type)});
                            if (incubator.status != Component.Ready) {
                                incubator.onStatusChanged = function(status) {
                                    if (status == Component.Ready) {
                                        console.log('Incubator after');
                                    }
                                }
                            } else {
                                console.log('Incubator now');
                            }
                        }
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: documentItem.width / 4
                        font.pixelSize: units.readUnit
                        text: "<b>" + model.title + "</b><br>" + model.desc
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.source + "\n" + model.hash
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                selectedIdentifier = model.title;
                                console.log('new identifier', selectedIdentifier);
                                documentSourceSelected(model.source);
                            }
                        }
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: documentItem.width / 4
                        font.pixelSize: units.readUnit
                        text: model.type
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                    }
                }
            }
            Common.SuperposedButton {
                id: addDocumentButton
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                size: units.fingerUnit * 2
                imageSource: 'plus-24844'
                onClicked: {
                    superposedAddMenu.toggleWidget();
                }
            }
            Common.SuperposedWidget {
                id: superposedAddMenu

                anchors.fill: parent
                anchoringItem: addDocumentButton

                minimumHeight: units.fingerUnit * 4
                minimumWidth: units.fingerUnit * 6

                glowColor: 'black'

                ListView {
                    id: menuList
                    anchors.fill: parent

                    headerPositioning: ListView.OverlayHeader

                    header: Common.BoxedText {
                        width: menuList.width
                        height: units.fingerUnit
                        boldFont: true
                        fontSize: units.readUnit
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr('Nou document...')
                    }

                    model: ObjectModel {
                        Common.BoxedText {
                            width: menuList.width
                            height: units.fingerUnit * 1.5
                            margins: units.nailUnit
                            text: qsTr('Fitxer')
                            MouseArea {
                                anchors.fill: parent
                                onClicked: documentsListItem.newDocumentSelected();
                            }
                        }
                        Common.BoxedText {
                            width: menuList.width
                            height: units.fingerUnit * 1.5
                            margins: units.nailUnit
                            text: qsTr('Adreça web')
                            MouseArea {
                                anchors.fill: parent
                                onClicked: superposedAddMenu.hideWidget()
                                // Not available yet
                            }
                        }
                    }
                }
            }
        }
    }

}

