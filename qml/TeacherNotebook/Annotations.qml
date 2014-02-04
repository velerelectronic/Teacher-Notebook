import QtQuick 2.0
import QtQuick.Controls 1.0
import "Storage.js" as Storage

Rectangle {
    width: 300
    height: 200

    TableView {
        id: annotationsList
        anchors.fill: parent
        rowDelegate: Rectangle {
            anchors.fill: parent
            border.color: black;
        }
    }
    Component.onCompleted: {
        Storage.newDimensionalTable('annotations',['title','desc'],['Títol','Descripció']);
        Storage.listTableRecords('FieldNames',0,[],annotationsList.model);
    }
}
