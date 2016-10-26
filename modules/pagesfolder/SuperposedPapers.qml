import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    color: 'gray'

    Common.UseUnits {
        id: units
    }

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
                item.title = model.title;
                item.index = model.index;
            }
        }
    }

    Component {
        id: simpleHeading

        Rectangle {
            width: mainList.width
            height: units.fingerUnit

            property string title
            property int index

            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                text: model.title
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log('asdjfh');
                    mainList.currentIndex = index;
                }
            }
        }
    }

    Component {
        id: expandedPage

        Rectangle {
            property string title
            property int index

            width: mainList.width
            height: mainList.height - (mainList.model.count-1) * (units.fingerUnit + units.nailUnit)
            color: 'yellow'
        }
    }
}
