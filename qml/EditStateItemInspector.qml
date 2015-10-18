import QtQuick 2.3
import QtQuick.Controls 1.2
import 'qrc:///common' as Common

CollectionInspectorItem {
    id: editState

    Common.UseUnits { id: units }

    clip: true

    visorComponent: Text {
        id: textVisor
        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
        property string shownContent

        text: {
            switch(textVisor.shownContent) {
            case '-1':
                return qsTr('Finalitzat');
            case '1':
                return qsTr('10%');
            case '2':
                return qsTr('20%');
            case '3':
                return qsTr('30%');
            case '4':
                return qsTr('40%');
            case '5':
                return qsTr('50%');
            case '6':
                return qsTr('60%');
            case '7':
                return qsTr('70%');
            case '8':
                return qsTr('80%');
            case '9':
                return qsTr('90%');
            case '10':
                return qsTr('100%');
            default:
                return qsTr('Actiu');
            }
        }

        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    editorComponent: Item {
        id: eventDoneList
        property int requiredHeight: units.fingerUnit * 2
        property string editedContent

        Row {
            anchors.fill: parent

            Repeater {
                model: 12
                Common.BoxedText {
                    id: boxedText

                    states: [
                        State {
                            name: 'completed'
                            PropertyChanges {
                                target: boxedText
                                text: qsTr('Finalitzat')
                            }
                        },
                        State {
                            name: 'active'
                            PropertyChanges {
                                target: boxedText
                                text: qsTr('Actiu')
                            }
                        },
                        State {
                            name: 'percentage'
                            PropertyChanges {
                                target: boxedText
                                text: ((model.index - 1) * 10) + "%"
                            }
                        }
                    ]
                    state: {
                        switch(model.index-1) {
                        case -1:
                            return 'completed';
                        case 0:
                            return 'active';
                        default:
                            return 'percentage';
                        }
                    }

                    property string content

                    width: eventDoneList.width / 12
                    height: eventDoneList.height
                    color: (editedContent == model.index-1)?'yellow':'transparent'

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            eventDoneList.editedContent = model.index-1;
                            editState.setChanges(true);
                        }
                    }
                }
            }
        }
    }

}

