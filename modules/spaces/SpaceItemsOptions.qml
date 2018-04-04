import QtQuick 2.7
import QtQml.Models 2.3
import 'qrc:///common' as Common

ListView {
    id: optionsList

    signal minimumSize()
    signal mediumSize()
    signal columnSize()
    signal rowSize()
    signal screenSize()
    signal closeSpace()

    Common.UseUnits {
        id: units
    }

    model: ObjectModel {
        Common.SuperposedMenuEntry {
            width: optionsList.width
            height: units.fingerUnit * 2
            text: qsTr('Mida: mínim')
            onClicked: minimumSize()
        }

        Common.SuperposedMenuEntry {
            width: optionsList.width
            height: units.fingerUnit * 2
            text: qsTr('Mida: fins a la meitat')
            onClicked: mediumSize()
        }
        Common.SuperposedMenuEntry {
            width: optionsList.width
            height: units.fingerUnit * 2
            text: qsTr('Mida: columna')
            onClicked: columnSize()
        }
        Common.SuperposedMenuEntry {
            width: optionsList.width
            height: units.fingerUnit * 2
            text: qsTr('Mida: fila')
            onClicked: rowSize()
        }
        Common.SuperposedMenuEntry {
            width: optionsList.width
            height: units.fingerUnit * 2
            text: qsTr('Mida: màxima')
            onClicked: screenSize()
        }
        Common.SuperposedMenuEntry {
            color: '#FFAAAA'

            width: optionsList.width
            height: units.fingerUnit * 2
            text: qsTr('Tanca')
            onClicked: closeSpace()
        }
    }
}
