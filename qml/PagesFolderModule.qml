import QtQuick 2.5
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/pagesfolder' as PagesFolder

Basic.BasicPage {
    pageTitle: qsTr('Carpeta')

    Common.UseUnits {
        id: units
    }

    headingCollapse: true
    sourceComponent: PagesFolder.PagesFolder {
    }
}
