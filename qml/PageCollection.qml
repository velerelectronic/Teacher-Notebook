import QtQuick 2.2

Rectangle {
    id: pageCollection

    color: 'yellow'

    // property list pages: []
    property int count: pageCollection.children.length
    property int currentPage: -1

    function addPage(page,params) {
        var newPageComponent = Qt.createComponent('qrc:///qml/' + page + '.qml');
        console.log('Add page');
        console.log('Ready');
        var args = {width: Qt.binding(function() { return pageCollection.width; }), height: Qt.binding(function() { return pageCollection.height; })};
        for (var prop in params) {
            args[prop] = params[prop];
        }

        var pageObj = newPageComponent.createObject(pageCollection,args);
        return pageObj;
    }

    function showPage(index) {
        for (var i=0; i<count; i++) {
            pageCollection.children[i].enabled = false;
            pageCollection.children[i].visible = false;
        }

        var pageObj = pageCollection.children[index];
        pageObj.enabled = true;
        pageObj.visible = true;
        currentPage = index;
        return pageObj;
    }

    function removePage(index) {
        pageCollection.children[i].destroy();
        if (currentPage>=count)
            currentPage = count-1;
    }
}
