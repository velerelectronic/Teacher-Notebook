import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Item {
    Common.UseUnits {
        id: units
    }

    property alias sections: sectionsList.model

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        ListView {
            id: sectionsList
            Layout.fillHeight: true
            Layout.fillWidth: true
            orientation: ListView.Horizontal
            interactive: false
            keyNavigationWraps: false
            clip: true
            spacing: units.nailUnit

            onWidthChanged: recalculateSectionDimensions()
            onHeaderChanged: recalculateSectionDimensions()
        }

        Item {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height

                    image: 'arrow-145769'

                    onClicked: moveBackwards()
                }

                ListView {
                    id: sectionsNumberList

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    orientation: ListView.Horizontal
                    interactive: false

                    model: sectionsList.model.count
                    spacing: units.fingerUnit

                    currentIndex: sectionsList.currentIndex

                    delegate: Rectangle {
                        width: units.fingerUnit
                        height: width
                        radius: units.fingerUnit / 2
                        border.color: 'black'
                        color: (ListView.isCurrentItem)?'white':'green'
                    }
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height

                    image: 'arrow-145766'

                    onClicked: moveForward()
                }
            }
        }
    }

    function moveForward() {
        sectionsList.incrementCurrentIndex();
    }

    function moveBackwards() {
        sectionsList.decrementCurrentIndex();
    }

    function recalculateSectionDimensions() {
        console.log('children count', sections.children.length);
        for (var i=0; i<sections.children.length; i++) {
            console.log('WxH', sectionsList.width, sectionsList.height);
            sections.children[i].width = Qt.binding(function() { return sectionsList.width; });
            sections.children[i].height = Qt.binding(function() { return sectionsList.height; });
        }
//        sectionsList.currentIndex = 0;
    }
}
