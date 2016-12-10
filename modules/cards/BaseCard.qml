import QtQuick 2.5

Item {
    property int requiredHeight
    signal selectedPage(string page, var parameters, string title)

    function updateContents() {
        console.log('Update contents base classe');
    }
}
