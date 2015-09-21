import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common

Rectangle {
    Common.UseUnits { id: units }
    property string pageTitle: qsTr("Avaluació de rúbrica per individus")

    property int assessment: -1
    property int individual: -1

}

