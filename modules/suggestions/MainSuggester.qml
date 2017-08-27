import QtQuick 2.6
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    signal selectedPage(string page, var parameters)

    property bool suggestionsEnabled: true

    Common.UseUnits {
        id: units
    }

    ListView {
        id: suggestionsList

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: parent.height

        spacing: units.fingerUnit
        interactive: false
        bottomMargin: spacing

        orientation: ListView.Vertical
        verticalLayoutDirection: ListView.BottomToTop

        model: ListModel {
            id: suggestionsModel
        }

        delegate: Rectangle {
            id: suggestionRect

            radius: units.fingerUnit / 2
            width: suggestionsList.width * 0.6
            height: units.fingerUnit * 2
            property real startingXpos: (suggestionsList.width - suggestionRect.width) / 2
            property real middlePoint: x + width / 2

            x: startingXpos

            opacity: (1-Math.abs(x - startingXpos)/width)

            states: [
                State {
                    name: 'active'
                    PropertyChanges {
                        target: suggestionRect
                        x: startingXpos
                    }
                },
                State {
                    name: 'removing'
                    PropertyChanges {
                        target: suggestionRect
                    }
                }
            ]
            state: 'active'
            color: '#2E9AFE'

            Behavior on x {
                NumberAnimation {
                    duration: 500
                }
            }

            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                verticalAlignment: Text.AlignVCenter

                padding: units.nailUnit
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                color: 'white'

                text: model.caption
            }

            MouseArea {
                anchors.fill: parent

                drag.target: suggestionRect
                drag.axis: Drag.XAxis
                drag.minimumX: -suggestionRect.width
                drag.maximumX: suggestionRect.width

                property bool active: drag.active

                onActiveChanged: {
                    if (!active) {
                        if ((suggestionRect.x<0) || (suggestionRect.x+suggestionRect.width>suggestionsList.width)) {
                            suggestionsModel.remove(model.index);
                        } else {
                            suggestionRect.state = 'active';
                        }
                    } else {
                        suggestionRect.state = 'removing';
                    }
                }

                onClicked: {
                    console.log("---", model.caption, model.action, JSON.stringify(model.parameters));
                    selectedPage(model.action, model.parameters, model.caption);
                    suggestionsModel.remove(model.index);
                }
            }

            ListView.onRemove: SequentialAnimation {
                PropertyAction {
                    target: suggestionRect
                    property: "ListView.delayRemove"
                    value: true
                }
                NumberAnimation {
                    target: suggestionRect
                    properties: 'opacity'
                    to: 0
                    duration: 500
                }
                PropertyAction {
                    target: suggestionRect
                    property: "ListView.delayRemove"
                    value: false
                }
            }

        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
            NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 400 }
        }

        /*
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
        }
        */

    }

    Timer {
        interval: 2000
        running: (suggestionsEnabled) && (suggestionsModel.count < 5)
        triggeredOnStart: false
        repeat: true

        onTriggered: newSuggestion()
    }

    function newSuggestion() {
        annotationsModel.filters = ['state=? OR state IS NULL']
        annotationsModel.bindValues = ['0']
        annotationsModel.select();
        if (annotationsModel.count > 0) {
            var s = Math.floor(Math.random() * annotationsModel.count)
            var obj = annotationsModel.getObjectInRow(s);

            suggestionsModel.append({caption: qsTr("Anotació «") + obj['title'] + "»" + qsTr(" dins Inbox"), action: 'annotations2/ShowAnnotation', parameters: ({identifier: obj['id']}) });
        }
    }

    Models.DocumentAnnotations {
        id: annotationsModel
    }

    Component.onCompleted: {
        suggestionsModel.append({caption: 'Motor de suggerències en marxa...', action: '', parameters: {}});
    }
}

