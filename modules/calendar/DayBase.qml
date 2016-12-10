import QtQuick 2.5

Rectangle {
    property int day
    property int month
    property int year

    function dateUpdated() {
        console.log('Date updated in DayBase class');
    }
}
