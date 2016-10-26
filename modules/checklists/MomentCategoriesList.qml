import QtQuick 2.7
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

ListView {
    id: momentsCategoriesList

    property string groupName: ''
    property string momentCategory: ''
    property var momentCategoriesArray: []

    signal momentCategorySelected(string momentCategory)

    Common.UseUnits {
        id: units
    }

    Models.AssessmentGridModel {
        id: momentCategoriesModel

        filters: ["\"group\"=?"]
        sort: 'id DESC'

        function selectMomentCategories() {
            console.log('selecting', groupName);
            bindValues = [groupName];
            select();
            var result = [];
            //momentCategoriesArray = [];

            for (var i=0; i<count; i++) {
                var newCategory = getObjectInRow(i)['momentCategory'];
                if (result.indexOf(newCategory)<0) {
                    result.push(newCategory);
                }
            }

            momentCategoriesArray = result;
            console.log('nine categories array', result, result.length)
        }
    }

    orientation: ListView.Horizontal

    spacing: units.nailUnit

    model: momentCategoriesArray

    header: Common.ImageButton {
        height: momentsCategoriesList.height
        width: size + 2 * units.nailUnit
        size: units.fingerUnit
        image: 'plus-24844'

        onClicked: {
            newMomentCategoryDialog.open();
        }
    }

    delegate: Rectangle {
        id: singleCategoryRect

        width: height * 3
        height: momentsCategoriesList.height

        color: (ListView.isCurrentItem)?'yellow':'white'

        property string category: modelData

        Text {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: modelData
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log(singleCategoryRect.category);
                momentsCategoriesList.selectMomentCategory(singleCategoryRect.category)
            }
        }
    }

    Common.SuperposedMenu {
        id: newMomentCategoryDialog

        title: qsTr('Nova categoria')

        parentWidth: momentsCategoriesList.parent.width
        parentHeight: units.fingerUnit * 10

        Editors.TextAreaEditor3 {
            id: newCategoryEditor

            width: newMomentCategoryDialog.parentWidth
            height: units.fingerUnit * 5
        }

        Common.TextButton {
            width: newMomentCategoryDialog.parentWidth
            height: units.fingerUnit
            text: qsTr('Defineix categoria')

            onClicked: {
                var newCat = newCategoryEditor.content.trim();
                console.log(newCat);
                if (newCat !== '') {
                    var newList = momentCategoriesArray;
                    newList.unshift(newCat);
                    momentCategoriesArray = newList;
                    newMomentCategoryDialog.close();
                    selectMomentCategory(newCat);
                }
            }
        }
    }

    // onMomentCategoriesArrayChanged: selectFirst()

    function selectFirst() {
        if (momentCategoriesArray.length>0) {
            currentIndex = 0;
            momentCategory = momentCategoriesArray[0];
        } else {
            currentIndex = -1;
            momentCategory = '';
        }
    }

    function selectMomentCategory(category) {
        var idx = momentCategoriesArray.indexOf(category);
        console.log('index', idx);
        if (idx >= 0) {
            momentsCategoriesList.currentIndex = idx;
            momentCategory = category;
            momentCategorySelected(category);
        } else {
            momentsCategoriesList.currentIndex = -1;
            momentCategory = '';
        }
    }

    function updateCategories() {
        momentCategoriesModel.selectMomentCategories();
    }

    onGroupNameChanged: updateCategories()

//    onMomentCategoryChanged: updateCategories()

    Component.onCompleted: updateCategories()
}
