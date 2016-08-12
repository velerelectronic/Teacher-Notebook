import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/files' as Files
import 'qrc:///modules/documents' as Documents
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///modules/files/mediaTypes.js" as MediaTypes

Rectangle {
    id: docAnnotationsRect

    Common.UseUnits {
        id: units
    }

    property string document: ''
    property alias count: docAnnotationsModel.count
    signal annotationSelected(int annotation)

    property int requiredHeight: docAnnotationsList.contentItem.height + docAnnotationsList.anchors.margins * 2 + docAnnotationsList.bottomMargin
    color: 'gray'

    property Item frameItem

    ListView {
        id: docAnnotationsList

        anchors.fill: parent
        anchors.margins: units.nailUnit

        bottomMargin: addAnnotationButton.size

        model: Models.DocumentAnnotations {
            id: docAnnotationsModel

            function update() {
                if (document !== '') {
                    docAnnotationsModel.filters = ['document=?'];
                    docAnnotationsModel.bindValues = [document];
                } else {
                    docAnnotationsModel.filters = [];
                }
                docAnnotationsModel.select();
                console.log('compte', docAnnotationsModel.count);
            }
        }

        interactive: false
        spacing: units.nailUnit

        header: Rectangle {
            id: docAnnotationsHeader
            color: '#C4FFA9'
            width: docAnnotationsList.width
            height: units.fingerUnit * 2
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Títol i descripció')
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: docAnnotationsHeader.width / 6
                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr('Etiquetes')
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: docAnnotationsHeader.width / 3 - stateHeading.width
                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr('Termini')
                }
                Text {
                    id: stateHeading
                    Layout.fillHeight: true
                    Layout.preferredWidth: Math.max(units.fingerUnit, stateHeading.contentWidth)

                    font.pixelSize: units.readUnit
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Estat')
                }
            }
        }

        delegate: Rectangle {
            width: docAnnotationsList.width
            height: units.fingerUnit * 2

            RowLayout {
                id: singleAnnotationLayout
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    text: '<b>' + model.title + '</b>&nbsp;' + model.desc + ''
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: singleAnnotationLayout.width / 6
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    color: 'green'
                    text: model.labels
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: singleAnnotationLayout.width / 6
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'green'
                    text: (model.start == '')?'---':model.start
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: singleAnnotationLayout.width / 6
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'red'
                    text: (model.end == '')?'---':model.end
                }
                StateDisplay {
                    Layout.fillHeight: true
                    Layout.preferredWidth: units.fingerUnit

                    stateValue: model.state
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: annotationSelected(model.id)
            }
        }

        Common.SuperposedButton {
            id: addAnnotationButton
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            size: units.fingerUnit * 2
            imageSource: 'plus-24844'
            onClicked: {
                newAnnotationDialog.load(qsTr('Nova anotació'), 'annotations2/NewAnnotation', {document: document, annotationsModel: docAnnotationsModel});
            }
        }

    }

    Common.SuperposedWidget {
        id: newAnnotationDialog

        parentWidth: frameItem.width
        parentHeight: frameItem.height
    }

    Component.onCompleted: docAnnotationsModel.update()
}

