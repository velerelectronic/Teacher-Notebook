import QtQuick 2.7

WeeksView {
    onSelectedDate: console.log(day, month, year)

    subWidget: Item {
        id: subWidgetItem

        property int day
        property int month
        property int year

        Text {
            id: annotationsDataText

            anchors.fill: parent
            anchors.topMargin: units.fingerUnit

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: units.readUnit
        }

        function init() {
            annotationsModel.filters = ['INSTR(start,?) OR INSTR(end,?)'];
            var date = new Date();
            date.setDate(day);
            date.setMonth(month);
            date.setFullYear(year);

            var dateString = date.toYYYYMMDDFormat();
            annotationsModel.bindValues = [dateString, dateString];
            annotationsModel.select();

            if (annotationsModel.count>0)
                annotationsDataText.text = annotationsModel.count + qsTr(' anotacions');
        }
    }

}
