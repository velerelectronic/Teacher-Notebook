import QtQuick 2.6
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Item {
    id: oneGridView

    property int columnWidth: units.fingerUnit * 4
    property int columnSpacing: units.nailUnit
    property int rowHeight: units.fingerUnit * 4
    property int rowSpacing: units.nailUnit
    property int numberOfColumns: 3
    property int numberOfRows: 3

    property ListModel horizontalHeadingModel: ListModel {
        ListElement { text: 'h1' }
        ListElement { text: 'h2' }
        ListElement { text: 'h3' }
    }
    property ListModel verticalHeadingModel: ListModel {
        ListElement { text: 'v1' }
        ListElement { text: 'v2' }
        ListElement { text: 'v3' }
    }

    property var cellsModel: [[1, 2, 3], ['a', 'b', 'c'], ['yes', 'no', 'maybe']]

    signal cellSelected(int column, int row)
    signal horizontalHeadingCellSelected(int column)
    signal verticalHeadingCellSelected(int row)

    property string selectedColumnColor: 'orange'
    property string selectedRowColor: Qt.lighter('orange')
    property string selectedCellColor: 'yellow'

    property string verticalHeadingBackgroundColor: Qt.lighter('grey')
    property string horizontalHeadingBackgroundColor: Qt.lighter('grey')
    property string cellBackgroundColor: 'white'

    property int selectedRow: -1
    property int selectedColumn: -1

    GridLayout {
        anchors.fill: parent

        rows: 2
        columns: 2

        clip: true

        Rectangle {
            Layout.preferredHeight: oneGridView.rowHeight
            Layout.preferredWidth: oneGridView.columnWidth

            z: 2
            border.color: 'black'

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    selectedColumn = -1;
                    selectedRow = -1;
                }
            }
        }

        Flickable {
            id: horizontalHeadingFlickArea

            Layout.preferredHeight: oneGridView.rowHeight
            Layout.fillWidth: true

            z: 1

            contentWidth: horizontalHeadingItem.width
            contentHeight: horizontalHeadingItem.height

            onContentXChanged: {
                if (movingHorizontally)
                    gridFlickArea.contentX = contentX;
            }

            Item {
                id: horizontalHeadingItem

                width: numberOfColumns * (columnWidth + columnSpacing) - columnSpacing
                height: oneGridView.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: oneGridView.columnSpacing

                    Repeater {
                        model: oneGridView.numberOfColumns

                        Rectangle {
                            height: parent.height
                            width: oneGridView.columnWidth

                            border.color: 'black'
                            color: (selectedColumn == model.index)?selectedColumnColor:horizontalHeadingBackgroundColor

                            Text {
                                anchors.fill: parent
                                font.pixelSize: units.readUnit
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight

                                text: horizontalHeadingModel.get(model.index)['text']
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    selectedColumn = model.index;
                                    horizontalHeadingCellSelected(model.index);
                                }
                            }
                        }
                    }
                }
            }
        }

        Flickable {
            id: verticalHeadingFlickArea

            Layout.fillHeight: true
            Layout.preferredWidth: oneGridView.columnWidth

            z: 1
            contentHeight: verticalHeadingItem.height
            contentWidth: verticalHeadingItem.width

            onContentYChanged: {
                if (movingVertically)
                    gridFlickArea.contentY = contentY;
            }

            Item {
                id: verticalHeadingItem

                width: columnWidth
                height: numberOfRows * (rowHeight + rowSpacing) - rowSpacing

                Column {
                    anchors.fill: parent
                    spacing: oneGridView.rowSpacing

                    Repeater {
                        model: oneGridView.numberOfRows

                        Rectangle {
                            height: oneGridView.rowHeight
                            width: parent.width

                            border.color: 'black'
                            color: (selectedRow == model.index)?selectedRowColor:verticalHeadingBackgroundColor

                            Text {
                                anchors.fill: parent
                                font.pixelSize: units.readUnit
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight

                                text: verticalHeadingModel.get(model.index)['text']
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    selectedRow = model.index;
                                    verticalHeadingCellSelected(model.index);
                                }
                            }
                        }
                    }
                }
            }
        }


        Flickable {
            id: gridFlickArea

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true

            contentHeight: mainGridItem.height
            contentWidth: mainGridItem.width

            onContentXChanged: {
                if (movingHorizontally)
                    horizontalHeadingFlickArea.contentX = contentX;
            }

            onContentYChanged: {
                if (movingVertically)
                    verticalHeadingFlickArea.contentY = contentY;
            }

            Item {
                id: mainGridItem

                width: oneGridView.numberOfColumns * (oneGridView.columnWidth + oneGridView.columnSpacing) - oneGridView.columnSpacing
                height: oneGridView.numberOfRows * (oneGridView.rowHeight + oneGridView.rowSpacing) - oneGridView.rowSpacing

                Row {
                    anchors.fill: parent
                    spacing: oneGridView.columnSpacing

                    Repeater {
                        model: oneGridView.numberOfColumns + 1

                        Item {
                            id: oneGridColumn

                            property int columnIndex: model.index

                            width: oneGridView.columnWidth
                            height: mainGridItem.height

                            Column {
                                anchors.fill: parent
                                spacing: oneGridView.rowSpacing

                                Repeater {
                                    model: oneGridView.numberOfRows + 1

                                    Rectangle {
                                        id: oneGridCell

                                        property int rowIndex: model.index
                                        property bool isMarginal: (oneGridColumn.columnIndex == oneGridView.numberOfColumns) || (oneGridCell.rowIndex == oneGridView.numberOfRows)

                                        width: oneGridView.columnWidth
                                        height: oneGridView.rowHeight

                                        border.color: 'gray'

                                        color: {
                                            if ((selectedRow == oneGridCell.rowIndex) && (selectedColumn == oneGridColumn.columnIndex)) {
                                                return selectedCellColor;
                                            } else {
                                                if (selectedRow == oneGridCell.rowIndex)
                                                    return selectedRowColor;
                                                else {
                                                    if (selectedColumn == oneGridColumn.columnIndex)
                                                        return selectedColumnColor;
                                                    else
                                                        return cellBackgroundColor;
                                                }
                                            }
                                        }
                                        Text {
                                            anchors.fill: parent
                                            padding: units.nailUnit
                                            font.pixelSize: units.readUnit
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            elide: Text.ElideRight

                                            text: (oneGridCell.isMarginal)?'':cellsModel[oneGridColumn.columnIndex][oneGridCell.rowIndex]
                                        }

                                        MouseArea {
                                            anchors.fill: parent

                                            enabled: !oneGridCell.isMarginal

                                            onClicked: {
                                                selectedColumn = oneGridColumn.columnIndex;
                                                selectedRow = oneGridCell.rowIndex;
                                                oneGridView.cellSelected(oneGridColumn.columnIndex, oneGridCell.rowIndex);
                                            }
                                        }

                                        Common.SuperposedButton {
                                            anchors.fill: parent
                                            imageSource: 'plus-24844'

                                            enabled: oneGridCell.isMarginal
                                            visible: oneGridCell.isMarginal
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
    }

}

