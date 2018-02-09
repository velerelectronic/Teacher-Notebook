import QtQuick 2.6
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Item {
    id: oneGridView

    property int columnWidth: units.fingerUnit * 4
    property int columnSpacing: units.nailUnit
    property int rowHeight: units.fingerUnit * 4
    property int rowSpacing: units.nailUnit
    property int numberOfColumns: horizontalHeadingModel.count
    property int numberOfRows: verticalHeadingModel.count
    property string crossHeadingText: ''
    property int crossHeadingKey: -1

    property ListModel horizontalHeadingModel: ListModel {
        ListElement { text: 'h1'; key: 1 }
        ListElement { text: 'h2'; key: 2 }
        ListElement { text: 'h3'; key: 3 }
    }
    property ListModel verticalHeadingModel: ListModel {
        ListElement { text: 'v1'; key: 4 }
        ListElement { text: 'v2'; key: 5 }
        ListElement { text: 'v3'; key: 6 }
    }

    property var cellsModel: [[1, 2, 3], ['a', 'b', 'c'], ['yes', 'no', 'maybe']]

    signal addColumn()
    signal addRow()

    signal editColumn(int key)
    signal editRow(int key)

    signal cellSelected(int column, int row)
    signal horizontalHeadingCellSelected(int column)
    signal verticalHeadingCellSelected(int row)

    property string selectedColumnColor: 'orange'
    property string selectedRowColor: Qt.lighter('orange')
    property string selectedCellColor: 'yellow'

    property string verticalHeadingBackgroundColor: Qt.lighter('grey', 1.33)
    property string horizontalHeadingBackgroundColor: Qt.lighter('grey', 1.66)
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

            Text {
                anchors.fill: parent
                font.pixelSize: units.readUnit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight

                text: crossHeadingText
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    selectedColumn = -1;
                    selectedRow = -1;
                }
                onPressAndHold: {
                    editColumn(crossHeadingKey);
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

                width: (numberOfColumns+1) * (columnWidth + columnSpacing) - columnSpacing
                height: oneGridView.rowHeight

                Row {
                    anchors.fill: parent
                    spacing: oneGridView.columnSpacing

                    Repeater {
                        model: horizontalHeadingModel

                        Rectangle {
                            id: horizontalHeadingCell

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

                                text: model.text
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    selectedColumn = model.index;
                                    horizontalHeadingCellSelected(model.index);
                                }
                                onPressAndHold: editColumn(model.key);
                            }
                        }
                    }

                    Common.SuperposedButton {
                        height: parent.height
                        width: oneGridView.columnWidth

                        imageSource: 'plus-24844'

                        onClicked: addColumn()
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
                height: (numberOfRows+1) * (rowHeight + rowSpacing) - rowSpacing

                Column {
                    anchors.fill: parent
                    spacing: oneGridView.rowSpacing

                    Repeater {
                        model: verticalHeadingModel

                        Rectangle {
                            id: verticalHeadingCell

                            height: oneGridView.rowHeight
                            width: parent.width

                            border.color: 'black'
                            color: (selectedRow == model.index)?selectedRowColor:verticalHeadingBackgroundColor

                            property int key: model.key

                            Text {
                                anchors.fill: parent
                                font.pixelSize: units.readUnit
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight

                                text: model.text
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    selectedRow = model.index;
                                    verticalHeadingCellSelected(model.index);
                                }
                                onPressAndHold: editRow(verticalHeadingCell.key);
                            }
                        }
                    }

                    Common.SuperposedButton {
                        height: oneGridView.rowHeight
                        width: parent.width

                        imageSource: 'plus-24844'
                        onClicked: addRow()
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

                width: (oneGridView.numberOfColumns+1) * (oneGridView.columnWidth + oneGridView.columnSpacing) - oneGridView.columnSpacing
                height: (oneGridView.numberOfRows+1) * (oneGridView.rowHeight + oneGridView.rowSpacing) - oneGridView.rowSpacing

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

