import QtQuick 2.7
import QtQuick.Window 2.1
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

GridView {
    id: momentsCategoriesItem

    property int cellSize
    property int cellPadding

    property int requiredHeight: contentItem.height

    property string selectedMomentCategory: ''

    interactive: false
    cellWidth: momentsCategoriesItem.cellSize
    cellHeight: momentsCategoriesItem.cellSize

    onModelChanged: {
        highlightSelectedMomentCategory();
        console.log("model", model);
    }

    highlight: Rectangle {
        width: cellWidth
        height: cellHeight
        color: 'yellow'
    }

    delegate: Item {
        id: momentItem

        property string momentCategory: modelData
        property int index: model.index

        width: cellWidth
        height: cellHeight

        Rectangle {
            border.color: 'black'
            radius: cellPadding
            anchors.fill: parent
            anchors.margins: cellPadding

            Loader {
                anchors.fill: parent
                anchors.margins: cellPadding

                sourceComponent: (modelData == '')?addComponent:textComponent
            }

            Component {
                id: textComponent

                Text {
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    text: modelData
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            momentsCategoriesItem.currentIndex = momentItem.index;
                            selectedMomentCategory = momentItem.momentCategory;
                        }
                    }
                }
            }

            Component {
                id: addComponent

                Common.ImageButton {
                    image: 'plus-24844'
                    onClicked: addMomentDialog.open()
                }
            }
        }
    }

    Common.SuperposedMenu {
        id: addMomentDialog

        title: qsTr('Nova categoria de moments')

        parentWidth: momentsCategoriesItem.width * 0.8
        parentHeight: Screen.height * 0.8

        Editors.TextAreaEditor3 {
            id: newMomentEditor

            width: addMomentDialog.parentWidth
            height: units.fingerUnit * 4
        }

        Common.Button {
            width: addMomentDialog.parentWidth
            height: units.fingerUnit * 2
            text: qsTr('Desa')
            onClicked: {
                addMomentDialog.close();
                var array = momentsCategoriesItem.model;
                var idx = array.indexOf('');
                if (idx>-1) {
                    array[idx] = newMomentEditor.content;
                    momentsCategoriesItem.model = array;
                    currentIndex = idx;
                    selectedMomentCategory = newMomentEditor.content;
                }
            }
        }
    }

    function highlightSelectedMomentCategory() {
        console.log('moment-category', selectedMomentCategory);
        for (var i=0; i<model.length; i++) {
            if (model[i] == selectedMomentCategory) {
                currentIndex = i;
            }
        }
    }

    Component.onCompleted: highlightSelectedMomentCategory()
}
