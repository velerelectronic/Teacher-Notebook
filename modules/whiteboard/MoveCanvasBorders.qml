import QtQuick 2.5
import QtQuick.Layouts 1.1

Item {
    id: moveCanvasBordersItem

    property int maximumBorder
    property string color

    signal topLeftBorderClicked()
    signal topBorderClicked()
    signal topRightBorderClicked()
    signal leftBorderClicked()
    signal rightBorderClicked()
    signal bottomLeftBorderClicked()
    signal bottomBorderClicked()
    signal bottomRightBorderClicked()

    property bool leftBorderEnabled: true
    property bool topBorderEnabled: true
    property bool rightBorderEnabled: true
    property bool bottomBorderEnabled: true

    GridLayout {
        anchors.fill: parent
        rowSpacing: 0
        columnSpacing: 0
        columns: 3
        rows: 3

        MoveCanvasArea {
            id: topLeftArea

            Layout.preferredHeight: maximumBorder
            Layout.preferredWidth: maximumBorder

            enabled: leftBorderEnabled || topBorderEnabled
            color: moveCanvasBordersItem.color
            onClicked: leftTopBorderClicked()
        }
        MoveCanvasArea {
            id: topArea

            Layout.preferredHeight: maximumBorder
            Layout.fillWidth: true

            enabled: topBorderEnabled
            color: moveCanvasBordersItem.color
            onClicked: topBorderClicked()
        }
        MoveCanvasArea {
            id: topRightArea

            Layout.preferredHeight: maximumBorder
            Layout.preferredWidth: maximumBorder

            enabled: rightBorderEnabled || topBorderEnabled
            color: moveCanvasBordersItem.color
            onClicked: topRightBorderClicked()
        }

        MoveCanvasArea {
            id: leftArea

            Layout.fillHeight: true
            Layout.preferredWidth: maximumBorder

            enabled: leftBorderEnabled
            color: moveCanvasBordersItem.color
            onClicked: leftBorderClicked()
        }
        Item {
            id: centerArea

            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        MoveCanvasArea {
            id: rightArea

            Layout.fillHeight: true
            Layout.preferredWidth: maximumBorder

            enabled: rightBorderEnabled
            color: moveCanvasBordersItem.color
            onClicked: rightBorderClicked()
        }

        MoveCanvasArea {
            id: bottomLeftArea

            Layout.preferredHeight: maximumBorder
            Layout.preferredWidth: maximumBorder

            enabled: leftBorderEnabled || bottomBorderEnabled
            color: moveCanvasBordersItem.color
            onClicked: bottomLeftBorderClicked()
        }
        MoveCanvasArea {
            id: bottomArea

            Layout.preferredHeight: maximumBorder
            Layout.fillWidth: true

            enabled: bottomBorderEnabled
            color: moveCanvasBordersItem.color
            onClicked: bottomBorderClicked()
        }

        MoveCanvasArea {
            id: bottomRightArea

            Layout.preferredHeight: maximumBorder
            Layout.preferredWidth: maximumBorder

            enabled: rightBorderEnabled || bottomBorderEnabled
            color: moveCanvasBordersItem.color
            onClicked: bottomRightBorderClicked()
        }
    }
}
