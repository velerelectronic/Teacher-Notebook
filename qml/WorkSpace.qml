import QtQuick 2.3
import 'qrc:///common' as Common

Common.MultiWidgetsArea {
    property string pageTitle: qsTr('Espai de treball')
    signal openPageArgs(string page, var args)

    Component.onCompleted: {
        addWidget('TasksSystem',{});
        addWidget('AssessmentSystem',{});
        addWidget('MarkDownViewer',{document: 'file:///sdcard/Esquirol/Curs-14-15/mapa curs.md'});
    }

    onEmitSignal: {
        switch(name) {
        case 'openTabularEditor':
            openPageArgs('AssessmentGeneralEditor', param);
            console.log('Parametres' + param);
            for (var prop in param) {
                console.log(prop + '->' + param[prop]);
            }
            console.log(param['group']);
            break;
        case 'categorizedAssessment':
            openPageArgs('AssessmentByCategories', param);
            break;
        case 'openMarkDown':
            openPageArgs('MarkDownViewer', param);
            break;
        case 'processDocument':
            openPageArgs('Planning2', param);
            break;
        default:
            openPageArgs(name,param);
            break;
        }
    }
}
