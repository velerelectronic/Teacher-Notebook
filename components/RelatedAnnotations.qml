import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    id: relatedAnnotations

    property int requiredHeight
    property string labelBase: ''
    property string labels

    property string mainIdentifier: ''
    property string initialState: ''

    signal selectAnnotation(string identifier)

    Common.TabbedView {
        id: annotationsTabbedView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: tabsHeight

        Component.onCompleted: {
            annotationsTabbedView.widgets.append({title: qsTr("Alfabètic")});
            annotationsTabbedView.widgets.append({title: qsTr("Etiquetes")});
            annotationsTabbedView.widgets.append({title: qsTr("Pendents")});

            switch(initialState) {
            case 'alpha':
                annotationsTabbedView.selectedIndex = 0;
                break;
            case 'labels':
                annotationsTabbedView.selectedIndex = 1;
                break;
            case 'pending':
                annotationsTabbedView.selectedIndex = 2;
                break;
            default:
                annotationsTabbedView.selectedIndex = 2;
                break;
            }
        }

        onSelectedIndexChanged: {
            switch(selectedIndex) {
            case 0:
                relatedAnnotationsModel.sort = 'title ASC, start ASC, end ASC';
                relatedAnnotationsModel.filters = ["title != ''"];
                relatedAnnotationsModel.bindValues = [];
                relatedAnnotationsModel.select();
                break;
            case 1:
                var labelsArray = relatedAnnotations.labels.trim().split(' ');
                var filters = [];
                for (var i=0; i<labelsArray.length; i++) {
                    filters.push("(INSTR(' '||labels||' ',?))");
                }
                relatedAnnotationsModel.sort = 'start ASC, end ASC, title ASC';
                relatedAnnotationsModel.filters = ["" + filters.join(' OR ')];
                relatedAnnotationsModel.bindValues = labelsArray;
                relatedAnnotationsModel.select();
                break;
            case 2:
                relatedAnnotationsModel.sort = 'start ASC, end ASC, title ASC';
                relatedAnnotationsModel.filters = ["title != ''", "state != '-1'"];
                relatedAnnotationsModel.bindValues = [];
                relatedAnnotationsModel.select();
                break;
            default:
                break;
            }
            getMainIndex();
        }
    }

    Rectangle {
        anchors {
            top: annotationsTabbedView.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        color: 'gray'

        ListView {
            id: relatedAnnotationsView

            anchors.fill: parent
            clip: true

            property int listIndex

            model: Models.ExtendedAnnotations {
                id: relatedAnnotationsModel
            }

            spacing: units.nailUnit

            header: Text {
                width: relatedAnnotationsView.width
                height: units.fingerUnit
                font.pixelSize: units.readUnit
                text: qsTr("Anotacions amb etiqueta #") + relatedAnnotations.labelBase
            }

            delegate: Rectangle {
                width: relatedAnnotationsView.width
                height: units.fingerUnit * 2
                color: (model.title == mainIdentifier)?'yellow':'white'
                RowLayout {
                    anchors.fill: parent
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                        font.pixelSize: units.readUnit
                        color: 'green'
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: (model.labels)?model.labels:''
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 5
                        font.pixelSize: units.readUnit
                        color: 'red'
                        text: model.start + "\n" + model.end
                    }

                    StateComponent {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit * 3

                        stateValue: model.state
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectAnnotation(model.title);
                    }
                }
            }

            onListIndexChanged: {
                if (relatedAnnotationsView.listIndex > -1)
                    relatedAnnotationsView.positionViewAtIndex(listIndex,ListView.Center);
            }
        }
    }

    function getMainIndex() {
        for (var i=0; i<relatedAnnotationsModel.count; i++) {
            var obj = relatedAnnotationsModel.getObjectInRow(i);
            if (obj['title'] == mainIdentifier) {
                relatedAnnotationsView.listIndex = i;
                break;
            }
        }
        console.log('main index', relatedAnnotationsView.listIndex);
    }
}
