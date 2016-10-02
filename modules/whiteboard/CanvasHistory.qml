import QtQuick 2.7

Item {
    property var canvasArray: []
    property int canvasArrayIndex: -1
    property int canvasArrayLength: canvasArray.length

    property bool canUndo: canvasArrayLength > 1
    property bool canRedo: canvasArrayIndex < canvasArrayLength

    property bool blocked: false

    // Conditions
    // * canvasArray must have one item, always
    // * canvasArrayLength must be at least 1
    // * canvasArrayIndex goes from 0 to canvasArrayLength-1

    function addCanvas(canvas) {
        while (canvasArrayIndex < canvasArray.length-1) {
            canvasArray.pop();
        }

        canvasArray.push(canvas.toDataURL());
        var newLength = canvasArray.length;
        canvasArrayLength = newLength;
        canvasArrayIndex = newLength-1;
        console.log('new length', canvasArrayLength);
    }

    function setPreviousCanvas(canvas1, canvas2) {
        if (!blocked) {
            blocked = true;

            if (canvasArrayIndex>0) {
                var newIndex = canvasArrayIndex - 1;
                canvasArrayIndex = newIndex;
                var data = canvasArray[canvasArrayIndex];

                var ctx = canvas1.getContext("2d");
    //            ctx.clearRect(0,0, data.width, data.height);
                ctx.drawImage(data, 0, 0);
                canvas1.markDirty(Qt.rect(0,0,data.width,data.height));
                ctx.drawImage(data, 0, 0);
                canvas1.markDirty(Qt.rect(0,0,data.width,data.height));
                canvas2.source = data;
                console.log('index', canvasArrayIndex, 'length', canvasArrayLength);
            }

            blocked = false;
        }

    }

    function setNextCanvas(canvas1, canvas2) {
        if (!blocked) {
            blocked = true;
            if (canvasArrayIndex < canvasArrayLength-1) {
                canvasArrayIndex = canvasArrayIndex + 1;
                var data = canvasArray[canvasArrayIndex];
                var ctx = canvas1.getContext("2d");
                ctx.drawImage(data, 0, 0);
                canvas1.markDirty(Qt.rect(0,0,data.width,data.height));
                ctx.drawImage(data, 0, 0);
                canvas1.markDirty(Qt.rect(0,0,data.width,data.height));
                canvas2.source = data;
                console.log('index', canvasArrayIndex, 'length', canvasArrayLength);
            }
            blocked = false;
        }

    }


}
