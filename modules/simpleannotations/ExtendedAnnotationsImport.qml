import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Rectangle {
    id: extendedImporter

    signal extendedAnnotationSelected(string title, string desc)

    property string selectedAnnotationId: ""

    color: 'green'

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        Common.SearchBox {
            id: searchFilter

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            onTextChanged: extendedModel.update()
        }

        ListView {
            id: annotationsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true
            spacing: units.nailUnit

            model: ExtendedAnnotationsModel {
                id: extendedModel

                function update() {
                    if (searchFilter.text == '') {
                        searchFields = [];
                    } else {
                        searchFields = fieldNames;
                    }
                    searchString = searchFilter.text
                    select();
                }

                Component.onCompleted: update()
            }

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                z: 2
                width: annotationsList.width
                height: units.fingerUnit * 2

                color: '#AAAAAA'

                RowLayout {
                    anchors.fill: parent
                    Text {
                        Layout.preferredWidth: parent.width / 5
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        text: qsTr('Títol')
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        text: qsTr('Descripció')
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 5
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        text: qsTr('Projecte i etiquetes')
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 5
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        text: qsTr('Principi i final')
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 5
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: qsTr('Estat i creació')
                    }
                }

            }

            delegate: Rectangle {
                z: 1
                width: annotationsList.width
                height: units.fingerUnit * 2

                clip: true

                color: (ListView.isCurrentItem)?'yellow':'white'
                property string title: model.title
                property string desc: model.desc
                property string project: model.project
                property string labels: model.labels
                property string start: model.start
                property string end: model.end
                property string state: model.state
                property string created: model.created

                RowLayout {
                    anchors.fill: parent
                    Text {
                        Layout.preferredWidth: parent.width / 5
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.title
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.desc
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 5
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.project + "\n" + model.labels
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 5
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.start + " -> " + model.end
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 5
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.state + "\n" + model.created
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedAnnotationId = model[extendedModel.primaryKey];
                        annotationsList.currentIndex = model.index;
                    }
                }
            }
        }

        Common.TextButton {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            text: qsTr('Trasllada')

            onClicked: {
                var sItem = annotationsList.currentItem;
                var project = (sItem.project != '')?("[" + sItem.project + "]"):''
                var labels = (sItem.labels != '')?(qsTr('Etiquetes: ') + sItem.labels + "\n"):''
                var created = (sItem.created != '')?(qsTr('Creada: ') + sItem.created + "\n"):''
                var start = (sItem.start != '')?(qsTr('Inici: ') + sItem.start + "\n"):''
                var end = (sItem.end != '')?(qsTr('Final: ') + sItem.end + "\n"):''
                var state = qsTr('Estat: ') + sItem.state
                extendedAnnotationSelected(sItem.title + project, created + labels + start + end + state + sItem.desc)
            }
        }
    }

    function removeSelectedAnnotation() {
        if (selectedAnnotationId != '') {
            extendedModel.removeObject(selectedAnnotationId);
            extendedModel.update();
            annotationsList.currentIndex = -1;
            selectedAnnotationId = "";
        }
    }
}
