import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: annotationItem
    state: 'basic'
    states: [
        State {
            name: 'basic'
            PropertyChanges {
                target: annotationItem
                color: 'white'
                height: contents.height
            }
        },
        State {
            name: 'selected'
            PropertyChanges {
                target: annotationItem
                color: 'grey'
                height: units.fingerUnit * 2
            }
        },
        State {
            name: 'expanded'
            PropertyChanges {
                target: annotationItem
                color: 'white'
                height: contents.height + units.nailUnit * 2
            }
        }

    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: 'color'
                easing.type: Easing.Linear
            }
        }
    ]

    property int idAnnotation: -1
    property alias title: titleLabel.text
    property string desc: ''
    property alias image: imageLabel.source
    property string labels: ''

    property bool isSelected: false

    signal annotationSelected (string title,string desc)
    signal annotationLongSelected(string title,string desc)
    signal openingDocumentExternally(string document)
    signal showEvent(var parameters)

    border.color: "black";

    Common.UseUnits { id: units }

    clip: true

    Behavior on height {
        PropertyAnimation {
            duration: 100
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (descLoader.sourceComponent == null) {
                descLoader.sourceComponent = descComponent;
                descLoader.item.desc = annotationItem.desc;
            } else {
                descLoader.sourceComponent = null;
            }
        }

        onPressAndHold: annotationItem.annotationLongSelected(annotationItem.title, annotationItem.desc)
    }

    ColumnLayout {
        id: contents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: units.nailUnit

        spacing: units.nailUnit

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(titleLabel.height,eventsLabel.height,labelsLabel.height)

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                spacing: 0

                Text {
                    id: titleLabel
        //            anchors { left: parent.left; right: parent.right; margins: units.nailUnit }
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    text: title + " ( " + projectName + ")"
                    font.bold: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    clip: true
                }

                Text {
                    id: labelsLabel
                    Layout.preferredWidth: contents.width / 4
                    Layout.fillHeight: true
                    clip: true
                    text: labels
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'green'
                    font.pixelSize: units.readUnit
                }

                Common.BoxedText {
                    id: eventsLabel
                    Layout.preferredWidth: (model.eventsCount>0)?units.fingerUnit * 2:0
                    Layout.preferredHeight: units.fingerUnit * 2 - units.nailUnit * 2
                    clip: true
                    margins: units.nailUnit
                    textColor: 'red'
                    fontSize: units.readUnit
                    text: (model.eventsCount>0)?model.eventsCount+qsTr(" esdeveniments"):''
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (eventsLoader.sourceComponent == null) {
                                eventsLoader.sourceComponent = eventsListComponent;
                                eventsLoader.item.idAnnotation = annotationItem.idAnnotation;
                            } else {
                                eventsLoader.sourceComponent = null;
                            }
                        }
                    }
                }

                Common.BoxedText {
                    id: resourcesLabel
                    Layout.preferredWidth: (model.resourcesCount>0)?units.fingerUnit * 2: 0
                    Layout.preferredHeight: units.fingerUnit * 2 - units.nailUnit * 2
                    clip: true
                    margins: units.nailUnit
                    textColor: 'blue'
                    fontSize: units.readUnit
                    text: (model.resourcesCount>0)?model.resourcesCount+qsTr(" recursos"):''

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (resourcesLoader.sourceComponent == null) {
                                resourcesLoader.sourceComponent = resourcesListComponent;
                                resourcesLoader.item.idAnnotation = annotationItem.idAnnotation;
                            } else {
                                resourcesLoader.sourceComponent = null;
                            }
                        }
                    }
                }
            }
        }

        Loader {
            id: descLoader
            Layout.fillWidth: true
            Layout.preferredHeight: (item == null)?0:item.requiredHeight
        }

        Image {
            id: imageLabel
            Layout.fillWidth: true
            Layout.preferredHeight: (image!== '')?(sourceSize.height * (width / sourceSize.width)):0
            source: image
            fillMode: Image.PreserveAspectFit
        }

        Loader {
            id: eventsLoader
            Layout.fillWidth: true
            Layout.preferredHeight: height
            height: (item == null)?0:item.requiredHeight
            onHeightChanged: console.log('New height ' + height)
        }

        Loader {
            id: resourcesLoader
            Layout.fillWidth: true
            Layout.preferredHeight: height
            height: (item == null)?0:item.requiredHeight
        }
    }

    /*
    MouseArea {
        anchors.fill: parent
        onClicked: annotationItem.annotationSelected(annotationItem.title, annotationItem.desc)
    }
    */

    Component {
        id: descComponent

        Text {
            id: descLabel
//            anchors { left: parent.left; right: parent.right; margins: units.nailUnit }
            property int requiredHeight: contentHeight
            property string desc

            text: descLabel.desc
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    Component {
        id: resourcesListComponent

        ListView {
            id: resourcesList

            property int requiredHeight: contentItem.height
            property int idAnnotation: -1

            interactive: false

            model: Models.DetailedResourcesModel {
                id: resourcesModel
                filters: ["annotationId='" + resourcesList.idAnnotation + "'"]
                onFiltersChanged: select()

                Component.onCompleted: select()
            }

            Connections {
                target: globalResourcesModel
                onUpdated: resourcesModel.select()
            }
            Connections {
                target: globalResourcesAnnotationsModel
                onUpdated: resourcesModel.select()
            }

            delegate: Rectangle {
                border.color: 'black'
                width: resourcesList.width
                height: units.fingerUnit * 2
                RowLayout {
                    id: resourcesLayout
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: '<b>' + model.resourceTitle + '</b>\n' + model.resourceDesc
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: resourcesLayout.width / 4
                        text: model.resourceType
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        openingDocumentExternally(model.resourceSource);
                        Qt.openUrlExternally(model.resourceSource);
                    }
                    onPressAndHold: annotationEditor.newResourceAttachment({attachmentId: model.id})
                }
            }
        }
    }

    Component {
        id: eventsListComponent

        /*
        Rectangle {
            color: 'pink'
            border.color: 'red'
            property int requiredHeight: units.fingerUnit * 3
            height: units.fingerUnit
            width: units.fingerUnit
        }
        */

        Schedule {
            property int idAnnotation: -1
            // requiredHeight is defined inside Schedule
            interactive: false

            scheduleModel: eventsModel

            onShowEvent: annotationItem.showEvent(parameters)

            Models.ScheduleModel {
                id: eventsModel
                filters: ["ref='" + idAnnotation + "'"]
                onFiltersChanged: {
                    setSort(5,Qt.AscendingOrder);
                    select();
                }
            }

        }
    }

    /*
    Common.ExtraInfo {
        minHeight: units.fingerUnit * 2
        contentHeight: contents.height + units.nailUnit * 2
        available: annotationItem.state == 'basic'
    }
    */
}
