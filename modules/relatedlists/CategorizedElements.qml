import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    id: categorizedElementsMainItem

    Models.CategorizedElementsModel {
        id: categorizedModel

        function filterByCategories(categoriesArray) {
            if (categoriesArray.length > 0) {
                var newFilter = [];
                var newBindValues = [];
                while (categoriesArray.length > 0) {
                    var newCategory = categoriesArray.pop();
                    newFilter.push('category=?');
                    newBindValues.push(newCategory);
                }
                filters = ['(' + newFilter.join(' OR ') + ')'];
                bindValues = newBindValues;
            } else {
                filters = [];
                bindValues = [];
            }
            select();
        }

        function removeElement(identifier) {
            removeObject(identifier);
            select();
        }
    }

    Models.RelatedListsModel {
        id: relatedListsModel

        function filterByMainItem(mainCategory, mainElement) {
            filters = ['mainCategory=?', 'mainElement=?'];
            bindValues = [mainCategory, mainElement];
            select();
        }

        Component.onCompleted: {
            select();
            console.log('related lists count', relatedListsModel.count);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Item {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                Button {
                    Layout.fillHeight: true
                    text: qsTr('Filtra')
                    onClicked: filterDialog.openFilters()
                }
            }
        }

        ListView {
            id: categorizedElementsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            Common.UseUnits {
                id: units
            }

            model: categorizedModel
            spacing: units.nailUnit
            clip: true

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                id: listHeader
                height: units.fingerUnit * 2
                width: categorizedElementsList.width
                z: 2

                RowLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit
                    Text {
                        Layout.preferredWidth: listHeader.width / 6
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: qsTr('Id')
                    }
                    Text {
                        Layout.preferredWidth: listHeader.width / 4
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: qsTr('Categoria')
                    }
                    Text {
                        Layout.preferredWidth: listHeader.width / 4
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: qsTr('Element')
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: qsTr('Descripció')
                    }
                }
            }
            delegate: Rectangle {
                id: singleListElement
                height: Math.max(units.fingerUnit * 2, identifierText.contentHeight, categoryText.contentHeight, elementText.contentHeight, descriptionText.contentHeight) + 2 * units.nailUnit
                width: categorizedElementsList.width
                z: 1

                color: (ListView.isCurrentItem)?'yellow':'white'

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Text {
                        id: identifierText
                        Layout.preferredWidth: singleListElement.width / 6
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.id
                    }
                    Text {
                        id: categoryText
                        Layout.preferredWidth: singleListElement.width / 4
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.category
                    }
                    Text {
                        id: elementText
                        Layout.preferredWidth: singleListElement.width / 4
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.element
                    }
                    Text {
                        id: descriptionText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.description
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (categorizedElementsList.currentIndex == model.index) {
                            categorizedElementsList.currentIndex = -1;
                        } else {
                            categorizedElementsList.currentIndex = model.index;
                            relatedListsModel.filterByMainItem(model.category, model.element);
                        }
                    }

                    onPressAndHold: categorizedModel.removeElement(model.id)
                }
            }

            footerPositioning: ListView.OverlayFooter
            footer: Rectangle {
                z: 2

                width: categorizedElementsList.width
                height: units.fingerUnit

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.readUnit
                    text: qsTr('Hi ha ') + categorizedModel.count + qsTr(' elements.')
                }
            }

            bottomMargin: addElementButton.size + addElementButton.margins

            Common.SuperposedButton {
                id: addElementButton

                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }

                imageSource: 'plus-24844'
                size: units.fingerUnit * 2
                margins: units.nailUnit

                onClicked: importElementsDialog.openImportDialog()
            }

            Component.onCompleted: categorizedModel.select()
        }

        ListView {
            id: relatedElementsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            model: relatedListsModel
            clip: true
            spacing: units.nailUnit

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                z: 2

                width: relatedElementsList.width
                height: units.fingerUnit * 2
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: relatedElementsList.width / 4

                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr('Categoria i element principals')
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: relatedElementsList.width / 4

                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr('Categoria i element relacionats')
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr('Relació')
                    }
                }
            }
            delegate: Rectangle {
                z: 1

                width: relatedElementsList.width
                height: units.fingerUnit * 2
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: relatedElementsList.width / 4

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: '<p><b>' + model.mainCategory + '</b></p><p>' + model.mainElement + '</p>'
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: relatedElementsList.width / 4

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: '<p><b>' + model.relatedCategory + '</b></p><p>' + model.relatedElement + '</p>'
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.relationship
                    }
                }
            }

            footerPositioning: ListView.OverlayFooter
            footer: Rectangle {
                z: 2

                width: relatedElementsList.width
                height: units.fingerUnit

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.readUnit
                    text: qsTr('Hi ha ') + relatedListsModel.count + qsTr(' relacions.')
                }
            }

            Common.SuperposedButton {
                id: addRelationshipButton

                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }

                imageSource: 'plus-24844'
                size: units.fingerUnit * 2
                margins: units.nailUnit

                onClicked: importRelatedListsDialog.openImportDialog()
            }
        }
    }

    Models.CategorizedElementsModel {
        id: categoriesOnlyModel

        function getCategoriesList() {
            categoriesOnlyModel.select();
            var categoriesArray = [];

            console.log('count', categoriesOnlyModel.count);

            for (var i=0; i<categoriesOnlyModel.count; i++) {
                var obj = categoriesOnlyModel.getObjectInRow(i);
                var category = obj['category'];
                if (categoriesArray.indexOf(category) < 0) {
                    categoriesArray.push(category);
                }
            }
            console.log('new count', categoriesArray.length);
            return categoriesArray;
        }
    }

    Common.SuperposedMenu {
        id: filterDialog

        title: qsTr('Filtra per categories')

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        function openFilters() {
            categoriesList.model = categoriesOnlyModel.getCategoriesList();
            filterDialog.open();
        }

        ListView {
            id: categoriesList

            width: parent.width
            height: contentItem.height

            delegate: Rectangle {
                id: categoryRectangle

                width: categoriesList.width
                height: units.fingerUnit * 2

                objectName: 'categoryRectangle'

                property bool selected: false
                property string categoryName: modelData

                color: (selected)?'yellow':'white'

                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: categoryRectangle.categoryName
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: categoryRectangle.selected = !categoryRectangle.selected
                }
            }
        }

        onAccepted: {
            var categoriesArray = [];
            for (var i=0; i<categoriesList.contentItem.children.length; i++) {
                var oneCategory = categoriesList.contentItem.children[i];
                if ((oneCategory.objectName == 'categoryRectangle') && (oneCategory.selected)) {
                    categoriesArray.push(oneCategory.categoryName);
                }
            }
            categorizedModel.filterByCategories(categoriesArray);
        }
    }

    Common.SuperposedWidget {
        id: importElementsDialog

        title: qsTr('Importa elements')

        function openImportDialog() {
            load(qsTr('Importa elements'), 'relatedlists/ImportElements', {categorizedModel: categorizedModel});
            open();
        }
    }

    Common.SuperposedWidget {
        id: importRelatedListsDialog

        title: qsTr('Importa llistes de relacions')

        function openImportDialog() {
            load(qsTr('Importa relactions'), 'relatedlists/ImportRelatedLists', {relatedListsModel: relatedListsModel});
            open();
        }
    }
}

