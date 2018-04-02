import QtQuick 2.7
import 'qrc:///common' as Common

ListView {
    id: mainPagesList

    signal openPage(string caption, string qmlPage, var properties)

    Common.UseUnits {
        id: units
    }

    model: ListModel {
        id: mainPagesModel
        dynamicRoles: true
    }

    spacing: units.nailUnit

    delegate: Rectangle {
        width: mainPagesList.width
        height: units.fingerUnit * 2

        Text {
            anchors.fill: parent
            padding: units.nailUnit
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: units.readUnit

            text: model.caption
        }

        MouseArea {
            anchors.fill: parent
            onClicked: openPage(model.caption, model.qmlPage, model.properties)
        }
    }

    function addPage(caption, qmlPage, properties) {
        mainPagesModel.append({caption: caption, qmlPage: qmlPage, properties: properties});
    }

    Component.onCompleted: {
        addPage(qsTr('Anotacions'), 'simpleannotations/SimpleAnnotationsList', {});
        addPage(qsTr("Calendari d'anotacions"), 'simpleannotations/AnnotationsCalendar', {});
        addPage(qsTr('Sistema de fitxers'), 'files/FilesystemBrowser', {});
        addPage(qsTr("Targetes"), 'cards/CardsList', {});
    }
}
