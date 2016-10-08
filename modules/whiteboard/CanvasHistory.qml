import QtQuick 2.7

Item {
    property var canvasArray: []
    property int canvasArrayIndex: -1
    property int canvasArrayLength: canvasArray.length

    property bool canUndo: canvasArrayLength > 1
    property bool canRedo: canvasArrayIndex < canvasArrayLength

    property bool blocked: false

    visible: false

    // Conditions
    // * canvasArray must have one item, always
    // * canvasArrayLength must be at least 1
    // * canvasArrayIndex goes from 0 to canvasArrayLength-1

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

            //var ctx = canvas1.getContext("2d");
            //ctx.clearRect(0,0, data.width, data.height);
            //ctx.drawImage(data, 0, 0);
            //canvas1.markDirty(Qt.rect(0,0,data.width,data.height));
            //canvas2.source = data;
            console.log('index', canvasArrayIndex, 'length', canvasArrayLength);
        } else {
            data = canvasArray[0];
        }

        return data;
    }

    function setNextCanvas() {
        if (!blocked) {
            blocked = true;
            if (canvasArrayIndex < canvasArrayLength-1) {
                canvasArrayIndex = canvasArrayIndex + 1;
                var data = canvasArray[canvasArrayIndex];
                //canvas2.source = data;
                console.log('index', canvasArrayIndex, 'length', canvasArrayLength);
            }
            blocked = false;
            return data;
        }

    }


}
