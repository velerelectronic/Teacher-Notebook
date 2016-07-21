import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import 'qrc:///common' as Common

Item {
    Common.UseUnits {
        id: units
    }

    default property alias sections: sectionsModel.children

    property bool moveForwardEnabled: true
    property bool moveBackwardsEnabled: true

    property string title

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Text {
            Layout.preferredHeight: contentHeight
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: units.readUnit
            font.bold: true
            text: title
        }

        ListView {
            id: sectionsList
            Layout.fillHeight: true
            Layout.fillWidth: true
            orientation: ListView.Horizontal
            interactive: false
            keyNavigationWraps: false
            clip: true
            spacing: units.nailUnit
            highlightMoveDuration: 250

            onWidthChanged: recalculateSectionDimensions()
            onHeaderChanged: recalculateSectionDimensions()

            model: ObjectModel {
                id: sectionsModel
            }
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

                    enabled: moveBackwardsEnabled
                    visible: moveBackwardsEnabled
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

                    enabled: moveForwardEnabled
                    visible: moveForwardEnabled
                    image: 'arrow-145766'

                    onClicked: moveForward()
                }
            }
        }
    }

    function moveForward() {
        if (moveForwardEnabled)
            sectionsList.incrementCurrentIndex();
    }

    function moveBackwards() {
        if (moveBackwardsEnabled)
            sectionsList.decrementCurrentIndex();
    }

    function recalculateSectionDimensions() {
        console.log('children count', sections.length);
        for (var i=0; i<sections.length; i++) {
            console.log('WxH', sectionsList.width, sectionsList.height);
            sections[i].width = Qt.binding(function() { return sectionsList.width; });
            sections[i].height = Qt.binding(function() { return sectionsList.height; });
        }
//        sectionsList.currentIndex = 0;
    }
}
