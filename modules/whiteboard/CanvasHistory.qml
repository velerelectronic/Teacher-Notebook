import QtQuick 2.7

Item {
    property var canvasArray: []
    property int canvasArrayIndex: 0
    property int canvasArrayLength: canvasArray.length

    property bool canUndo: canvasArrayLength > 1
    property bool canRedo: canvasArrayIndex < canvasArrayLength

    property bool blocked: false

    visible: false

    // Conditions
    // * canvasArrayLength must be at least 1 - the first element is not removable.
    // * canvasArrayIndex goes from 0 to canvasArrayLength-1.
    // * canvasArrayIndex with 0 means the first image.

    function addCanvas(imageData) {
        while (canvasArrayIndex < canvasArray.length-1) {
            canvasArray.pop();
        }

        canvasArray.push(imageData);
        var newLength = canvasArray.length;
        canvasArrayLength = newLength;
        canvasArrayIndex = newLength-1;
        console.log('new length after adding', canvasArrayLength);
    }

    function setPreviousCanvas() {
        var data;

        if (canvasArrayIndex>0) {
            var newIndex = canvasArrayIndex - 1;
            canvasArrayIndex = newIndex;
            data = canvasArray[canvasArrayIndex];
        } else {
            data = canvasArray[0];
        }

        return data;
    }

    function setNextCanvas() {
        if (canvasArrayIndex < canvasArrayLength-1) {
            canvasArrayIndex = canvasArrayIndex + 1;
            var data = canvasArray[canvasArrayIndex];
            return data;
        } else {
            return canvasArray[canvasArrayLength-1];
        }
    }


    function initHistory(imageData) {
        canvasArray = [];
        addCanvas(imageData);
    }
}
