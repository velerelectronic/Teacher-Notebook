import QtQuick 2.2

Rectangle {
    id: pageCollection

    color: 'yellow'

    // property list pages: []
    property int count: children.length
    property int currentPage: -1

    signal pageDestroyed(int index)

    onCurrentPageChanged: showCurrentPage()

    function test() {
        for (var i=0; i<pageCollection.children.length; i++) {
            console.log(pageCollection.children[i]);
        }
    }

    function addPage(page,params) {
        var newPageComponent = Qt.createComponent('qrc:///qml/' + page + '.qml');

        if (newPageComponent.status == Component.Ready) {
            var args = {width: Qt.binding(function() { return pageCollection.width; }), height: Qt.binding(function() { return pageCollection.height; })};

            for (var prop in params) {
                args[prop] = params[prop];
            }

            var pageObj = newPageComponent.createObject(pageCollection,args);

            return pageObj;
        } else {
            if (newPageComponent.status == Component.Error) {
                console.log('Error in page ' + page + ' ' + newPageComponent.errorString());
                return null;
            }
        }
    }

    function showCurrentPage() {
        // Hide everything

        for (var i=0; i<count; i++) {
            pageCollection.children[i].enabled = false;
            pageCollection.children[i].visible = false;
        }

        if ((currentPage>=0) && (currentPage<count)) {
            var pageObj = pageCollection.children[currentPage];
            pageObj.enabled = true;
            pageObj.visible = true;
        }
    }

    function getPage(index) {
        return pageCollection.children[index];
    }

    function getCurrentPage() {
        return getPage(currentPage);
    }

    function removePage(index) {
        console.log('Remove page ' + index + ' out of ' + count);
        if (index>=count)
            return;
        else {
            console.log('inside page collection: remove ' + pageCollection.children[index].pageTitle);
            pageCollection.children[index].destroy();
            delete pageCollection.children[index];
            pageDestroyed(index);
        }
    }
}
