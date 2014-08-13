import QtQuick 2.2

Rectangle {
    id: pageStack

    color: 'yellow'

    property var pages: []
    property alias count: pages.length
    property int currentPage: -1

    function addPage(page,params) {
        var newPageComponent = Qt.createComponent(page)
        if (newPageComponent.status == Component.Ready) {
            var pageObj = newPageComponent.createObject(pageStack,params);
            pages.push(pageObj);
        }
    }

    function showPage(index) {
        pages[index].enabled = true;
    }
}
