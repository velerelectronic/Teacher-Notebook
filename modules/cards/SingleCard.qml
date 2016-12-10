import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    property string title
    property string backgroundColor: 'blue'

    property string cardItem: ''
    property alias subCardTarget: cardSubLoader.item

    property int requiredHeight

    signal selectedPage(string page, var parameters, string title)
    signal updateSelected()

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Common.BoxedText {
            id: titleBox

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            margins: units.nailUnit
            color: backgroundColor
            boldFont: true
            textColor: 'white'
            text: title

            Common.ImageButton {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: units.nailUnit
                }
                size: units.fingerUnit

                image: 'input-25064'

                onClicked: {
                    cardSubLoader.item.updateContents();
                    updateSelected();
                }
            }
        }
        Loader {
            id: cardSubLoader

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: units.nailUnit

            source: 'qrc:///modules/cards/' + cardItem + 'Card.qml'

            onLoaded: {
                requiredHeight = Qt.binding(function() { return titleBox.height + cardSubLoader.item.requiredHeight + 2 * units.nailUnit; });
            }

            Connections {
                target: cardSubLoader.item
                ignoreUnknownSignals: true

                onSelectedPage: selectedPage(page, parameters, title)
            }
        }
    }
}
