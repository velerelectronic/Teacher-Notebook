import QtQuick 2.3
import 'qrc:///common' as Common

Common.MultiWidgetsArea {
    property string pageTitle: qsTr('Espai de treball')
    signal openPageArgs(string page, var args)

    Component.onCompleted: {
        addWidget('Calendar',{});
        addWidget('MarkDownViewer',{document: 'file:///sdcard/Esquirol/Curs-14-15/mapa curs.md'});
        addWidget('AssessmentList',{});
    }

    onEmitSignal: {
        switch(name) {
        case 'createEvent':
            openPageArgs('ShowEvent', param);
            break;
        case 'editEvent':
            openPageArgs('ShowEvent', param);
            break;
        case 'openTabularEditor':
            openPageArgs('AssessmentGeneralEditor', param);
            console.log('PArametres' + param);
            for (var prop in param) {
                console.log(prop + '->' + param[prop]);
            }
            console.log(param['group']);
            break;
        case 'openMarkDown':
            openPageArgs('MarkDownViewer', param);
            break;
        default:
            break;
        }
    }
}
