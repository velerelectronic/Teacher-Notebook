import QtQuick 2.2

Item {
    id: canvasElement
    width: 10
    height: 10
    // Types of figures
    property int typePolygon: 1
    property int typeLine: 2
    property int typeRect: 3
    property int typeImage: 4
    property int typeText: 5
    property int typeCircle: 6
    property int typeEllipse: 7

    property int itemType: 0
    property var points: []
    property var image: []
    property int rotation: 0
    property real scale: 1
    property string color: ''
    property string content: ''

    signal selected

    MouseArea {
        anchors.fill: parent
        onClicked: canvasElement.selected()
        propagateComposedEvents: true
    }

    function drawLineSegment(ctx,px,py,qx,qy) {
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = 3
        ctx.moveTo(px, py);
        ctx.lineTo(qx, qy);
        ctx.stroke();
        ctx.closePath();
    }

    function drawRect(ctx,px,py,qx,qy) {
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = 3;
        ctx.moveTo(px,py);
        ctx.lineTo(px,qy);
        ctx.lineTo(qx,qy);
        ctx.lineTo(qx,py);
        ctx.lineTo(px,py);
        ctx.stroke();
        ctx.closePath();
    }

    function drawCircle(ctx,px,py,qx,qy) {
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = 3;
        ctx.arc(px,py,Math.sqrt(Math.pow(px-qx,2)+Math.pow(py-qy,2)),0,Math.PI*2, true);
        ctx.stroke();
        ctx.closePath();
    }

    function drawAnEllipse(ctx,px,py,qx,qy) {
        console.log('Draw ellipse');
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = 3;
        ctx.ellipse(px,py,qx-px,qy-py);
        ctx.stroke();
        ctx.closePath();
    }

    function paint(ctx) {
        ctx.save();
        switch(itemType) {
        case typeLine:
        case typePolygon:
            var l = points.length;
            for (var i=1; i<l; i++) {
                var p = points[i-1];
                var q = points[i];
                drawLineSegment(ctx,p.x,p.y,q.x,q.y);
            }
            break;
        case typeRect:
            if (points.length==2) {
                var p = points[0];
                var q = points[1];
                drawRect(ctx,p.x,p.y,q.x,q.y);
            }
            break;

        case typeCircle:
            if (points.length==2) {
                var p = points[0];
                var q = points[1];
                drawCircle(ctx,p.x,p.y,q.x,q.y);
            }
            break;

        case typeEllipse:
            if (points.length==2) {
                var p = points[0];
                var q = points[1];
                drawAnEllipse(ctx,p.x,p.y,q.x,q.y);
            }
            break;
        default:
            break;
        }
        ctx.restore();
    }

    function addPoint(newpoint) {
        switch(itemType) {
        case typeLine:
        case typeRect:
        case typeCircle:
        case typeEllipse:
            if (points.length>1)
                points.pop();
            points.push(newpoint);
            break;
        default:
            points.push(newpoint);
            break;
        }
    }

    function writeText(ctx) {

    }
}
