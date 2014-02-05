import QtQuick 2.0

Rectangle {
    id: annotationItem

    property alias title: titleLabel.text
    property alias desc: descLabel.text
    signal annotationSelected (string title,string desc)

    height: childrenRect.height
    border.color: "black";

    Text {
        id: titleLabel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        text: title
        font.bold: true
        font.pointSize: 16
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }
    Text {
        id: descLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleLabel.bottom
        anchors.margins: 10
        text: desc
        font.pointSize: 12
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    MouseArea {
        anchors.fill: parent
        onClicked: annotationItem.annotationSelected(annotationItem.title, annotationItem.desc)
    }
}
