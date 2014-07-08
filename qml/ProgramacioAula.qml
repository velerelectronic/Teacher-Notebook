import QtQuick 2.2
import QtWebKit 3.0
import FileIO 1.0
import PersonalTypes 1.0

Rectangle {
    id: xmlViewer
    property string pageTitle: qsTr('Programació d\'aula');
    width: parent.width
    height: parent.height

    /*
    XmlReader {
        id: xmlReader
        source: '/Users/jmpayeras/Desenvolupament/prova.xml'

        onObjectivesChanged: {
            console.log('Changed objectives ');
            for (var prop in objectives) {
                console.log('-> ' + prop + ' -- ' + JSON.stringify(objectives[prop]));
            }
        }
    }*/

    ProgramacioAulaModel {
        id: xmlReader
        source: '/Users/jmpayeras/Desenvolupament/prova.xml'
    }

    Rectangle {
        color: 'yellow'
        anchors.fill: parent
        Text {
            anchors.fill: parent
            text: '' // JSON.stringify(pa.objectives.list)
        }
    }


    XmlModel {
        //source: '/Users/jmpayeras/Desenvolupament/prova.xml'
        source: '<objectives>
<objective>hello</objective>
<objective>hola</objective></objectives>'
        tagName: 'objective'
        onListChanged: console.log('Llista ' + list);
    }


    ListView {
        id: sectionsList
        anchors.fill: parent
        anchors.margins: units.nailUnit
        model: ListModel {
            id: sectionsModel
            dynamicRoles: true
        }
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapToItem

        delegate: Rectangle {
            width: sectionsList.width
            height: sectionsList.height
            color: 'white'
            Rectangle {
                id: titleText
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: childrenRect.height + 2 * units.nailUnit
                color: 'green'

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: contentHeight
                    anchors.margins: units.nailUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: title
                    color: 'white'
                    font.pixelSize: units.readUnit
                }
            }

            Loader {
                id: mainSectionLoader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: titleText.bottom
                anchors.bottom: parent.bottom
            }
            Component.onCompleted: {
                mainSectionLoader.setSource('qrc:///editors/' + editor + '.qml',{dataModel: model});
            }
        }
    }

    function reload() {
        sectionsModel.clear();
        sectionsModel.append({title: qsTr('Introducció'), editor: 'XmlTextEditor', model: xmlReader.introduction});
        sectionsModel.append({title: qsTr('Dades generals'), editor: 'XmlListEditor', model: xmlReader.basicData});
        sectionsModel.append({title: qsTr('Objectius'), editor: 'XmlListEditor', model: xmlReader.objectives});
        sectionsModel.append({title: qsTr('Competències bàsiques'), editor: 'XmlMultipleListEditor', model: [
                                     {title: qsTr('Comunicació lingüística i audiovisual'), dades: xmlReader.competenceLing},
                                     {title: qsTr('Matemàtica'), editor: 'XmlTextEditor', dades: xmlReader.competenceMat},
                                     {title: qsTr('Tractament de la informació i competència digital'), editor: 'XmlTextEditor', dades: xmlReader.competenceTic},
                                     {title: qsTr('Social i ciutadana'), editor: 'XmlTextEditor', dades: xmlReader.competenceSoc},
                                     {title: qsTr('Cultural i artística'), editor: 'XmlTextEditor', dades: xmlReader.competenceCult},
                                     {title: qsTr('Aprendre a aprendre'), editor: 'XmlTextEditor', dades: xmlReader.competenceLearn},
                                     {title: qsTr('Autonomia i iniciativa personal'), editor: 'XmlTextEditor', dades: xmlReader.competenceAuto}
                                 ]});
        sectionsModel.append({title: qsTr('Avaluació'), editor: 'XmlMultipleListEditor', model: [
                                     {title: qsTr('Tasques'), dades: xmlReader.assessmentTasks},
                                     {title: qsTr('Criteris'), dades: xmlReader.assessmentCriteria},
                                     {title: qsTr('Instruments'), dades: xmlReader.assessmentInstruments}
                                 ]});

        sectionsModel.append({title: qsTr('Continguts'), editor: 'XmlMultipleListEditor', model: [
                                     {title: qsTr('Coneixements'), dades: xmlReader.contentsKnowledge},
                                     {title: qsTr('Habilitats'), dades: xmlReader.contentsHabilities},
                                     {title: qsTr('Llenguatge'), dades: xmlReader.contentsLanguage},
                                     {title: qsTr('Valors'), dades: xmlReader.contentsValues}
                                 ]});
        sectionsModel.append({title: qsTr('Recursos'), editor: 'XmlListEditor', model: xmlReader.resources});
        sectionsModel.append({title: qsTr('Referències'), editor: 'XmlListEditor', model: xmlReader.references});
        sectionsModel.append({title: qsTr('Activitats'), editor: 'XmlListEditor', model: xmlReader.activities});
        sectionsModel.append({title: qsTr('Comentaris'), editor: 'XmlTextEditor', model: xmlReader.comments});
    }

    Component.onCompleted: {
        reload();

        xmlReader.objectives.push({text: 'hola'});
        xmlReader.objectives = [{text: 'res'},{text: 'un altre exemple'}];

        var a = xmlReader.objectives;
        for (var prop in a) {
            console.log(prop + '-' + a[prop]);
        }

        reload();
    }
}
