import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import 'common' as Common

Common.BaseWidget {
    id: whiteboard
    title: qsTr('Pissarra')
    // Possible drawing actions ['Clear', 'Path']
    property string drawingAction: 'Clear'

    ColumnLayout {
        anchors.fill:parent
        Rectangle {
            Layout.fillWidth: true;
            height: 50
            RowLayout {
                anchors.fill: parent
                Button {
                    Layout.fillHeight: true
                    text: qsTr('Guix')
                    menu: Menu {
                        title: 'Color del guix'
                        MenuItem {
                            text: qsTr('Blanc')
                            onTriggered: whiteArea.foreground = 'white'
                        }
                        MenuItem {
                            text: qsTr('Verd')
                            onTriggered: whiteArea.foreground = '#00ff00'
                        }
                        MenuItem {
                            text: qsTr('Negre')
                            onTriggered: whiteArea.foreground = 'black'
                        }
                    }
                }

                Button {
                    Layout.fillHeight: true
                    text: 'Fons'
                    menu: Menu {
                        title: qsTr('Color del fons')
                        MenuItem {
                            text: qsTr('Fosc')
                            onTriggered: whiteArea.background = '#585858'
                        }
                        MenuItem {
                            text: qsTr('Verd')
                            onTriggered: whiteArea.background = '#007700'
                        }
                        MenuItem {
                            text: qsTr('Clar')
                            onTriggered: whiteArea.background = '#F5F6CE'
                        }
                    }
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Neteja')
                    onClicked: {
                        whiteboard.drawingAction = 'Clear'
                        whiteArea.requestPaint();
                    }
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Desa')
                    height: 50
                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }

        Canvas {
            id: whiteArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            renderStrategy: Canvas.Cooperative
            renderTarget: Canvas.FramebufferObject

            property var points: []
            property string background: '#007700'
            property string foreground: 'white'

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                property int px;
                property int py;

                onPressed: {
                    whiteboard.drawingAction = 'Path'
                    whiteArea.points = [];
                    whiteArea.points.push({x: Math.round(mouseArea.mouseX), y: Math.round(mouseArea.mouseY)});
                }
                onPositionChanged: {
                    whiteboard.drawingAction = 'Path'
                    whiteArea.points.push({x: Math.round(mouseArea.mouseX), y: Math.round(mouseArea.mouseY)});
                    whiteArea.requestPaint();
                }
                onReleased: {
                    whiteboard.drawingAction = 'Path'
                    whiteArea.requestPaint();
                }
            }

            onPaint: {
                switch(whiteboard.drawingAction) {
                case 'Clear':
                    clearArea(whiteArea.background);
                    break;
                case 'Path':
                    var l = whiteArea.points.length;
                    switch (l) {
                    case 0:
                        break;
                    case 1:
                        drawPoint(whiteArea.points[0].x,whiteArea.points[0].y);
                        break;
                    default:
                        for (var i=1; i<l; i++) {
                            var p = whiteArea.points[i-1];
                            var q = whiteArea.points[i];
                            drawLineSegment(p.x,p.y,q.x,q.y);
                        }
                        break;
                    }
                default:
                    break;
                }
            }

            function clearArea(color) {
                var ctx = whiteArea.getContext("2d")
                ctx.save();
                ctx.fillStyle = color;
                ctx.fillRect(0,0,whiteArea.width,whiteArea.height);
                ctx.restore();
            }

            function drawLineSegment(px,py,qx,qy) {
                var ctx = whiteArea.getContext("2d")
                ctx.save();
                ctx.beginPath();
                ctx.strokeStyle = whiteArea.foreground;
                ctx.lineWidth = 3
                ctx.moveTo(px, py);
                ctx.lineTo(qx, qy);
                ctx.stroke();
                ctx.closePath();
                ctx.restore();
            }

            function drawPoint(px,py) {
                var ctx = whiteArea.getContext("2d")
                ctx.save();
                ctx.lineWidth = 3
                ctx.fillStyle = whiteArea.foreground;

                ctx.fillRect(px-5, py+5, 10, 10);
                ctx.restore();
            }
        }
    }
    Component.onCompleted: {
        whiteboard.drawingAction = 'Clear'
        whiteArea.requestPaint();
    }
}

