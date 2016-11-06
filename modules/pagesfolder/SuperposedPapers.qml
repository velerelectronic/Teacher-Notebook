import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    color: 'gray'

    Common.UseUnits {
        id: units
    }

    property alias model: mainList.model
    property Component expandedPage: expandedPageComponent
    property int availableHeight: height - (units.fingerUnit * model.count) - (mainList.spacing * (model.count-1))
    property string captionString: ''
    property string identifierString: captionString

    signal paperSelected(string title, string identifier)
    signal setupSelected()

    ListView {
        id: mainList

        anchors.fill: parent
        anchors.margins: units.nailUnit
        interactive: false

        model: ListModel {
            ListElement {
                title: 'hola'
            }
            ListElement {
                title: 'que'
            }
            ListElement {
                title: 'tal'
            }
            ListElement {
                title: 'mes'
            }
            ListElement {
                title: 'dos'
            }
            ListElement {
                title: 'tres'
            }
        }
        spacing: units.nailUnit

        delegate: Loader {
            asynchronous: true
            sourceComponent: (ListView.isCurrentItem)?expandedPage:simpleHeading

            onLoaded: {
                item.index = model.index;
                item.title = model[captionString];
                item.identifier = model[identifierString];
            }
        }
    }

    Common.ImageButton {
        anchors {
            top: parent.top
            right: parent.right
        }
        size: units.fingerUnit
        image: 'cog-147414'
        onClicked: setupSelected()
    }

    Component {
        id: simpleHeading

        Rectangle {
            id: simpleHeadingItem

            width: mainList.width
            height: units.fingerUnit

            property string title
            property string identifier
            property int index

            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                text: simpleHeadingItem.title
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mainList.currentIndex = simpleHeadingItem.index;
                    paperSelected(simpleHeadingItem.title, simpleHeadingItem.identifier);
                }
            }
        }
    }

    Component {
        id: expandedPageComponent

        Rectangle {
            property string title: ''
            property string identifier: ''
            property int index

            width: mainList.width
            height: mainList.height - (mainList.model.count-1) * (units.fingerUnit + units.nailUnit)
            color: 'yellow'
        }
    }
}
