#include <QObject>
#include <QFile>
#include <QVariantList>
#include <QDebug>
#include "rubricxml.h"
#include "rubricpopulationmodel.h"
#include "rubricassessmentmodel.h"

RubricXml::RubricXml(QObject *parent) : QObject(parent)
{
    innerCriteria = new RubricCriteria(this);
    innerPopulationModel = new RubricPopulationModel(this);
    innerAssessmentModel = new RubricAssessmentModel(this);

    connect(this, SIGNAL(assessmentChanged()), innerAssessmentModel, SLOT(processXmlChanges()));
}

RubricAssessmentModel *RubricXml::assessment() {
    return innerAssessmentModel;
}

void RubricXml::createEmptyRubric() {
    setXml("<rubric version=\"" + innerVersion + "\"><population/><assessment/></rubric>");
}

RubricCriteria *RubricXml::criteria() {
    return innerCriteria;
}

QString RubricXml::description() {
    return mainRubricRoot.attribute("description");
}

QVariantList RubricXml::getDescriptors(int criterium) {
    QDomNodeList descriptorsList = mainRubricRoot.elementsByTagName("criterium").at(criterium).toElement().elementsByTagName("descriptor");
    return getNodesAttributesList(descriptorsList);
}

QVariantList RubricXml::getNodesAttributesList(const QDomNodeList &list) {
    // It extracts the attributes and values from a list of document nodes
    // and builds a new list with associative arrays.
    QVariantList returnList;
    for (int i=0; i<list.length(); i++) {
        QVariantMap object;
        QDomNamedNodeMap attrList = list.item(i).attributes();
        for (int j=0; j<attrList.length(); j++) {
            QDomAttr attr = attrList.item(j).toAttr();
            object.insert(attr.name(), attr.value());
        }
        returnList.append(object);
    }
    return returnList;
}

RubricPopulationModel *RubricXml::population() {
    return innerPopulationModel;
}


void RubricXml::loadXml() {
    QFile xfile(innerSource);

    qDebug() << "Carregant XML" << innerSource;
    if (xfile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString contents = xfile.readAll();
        setXml(contents);
        qDebug() << contents;
    }
    xfile.close();

    emit xmlChanged();
}

void RubricXml::setDescription(QString description) {
    document.elementsByTagName("rubric").at(0).toElement().setAttribute("description", description);
    descriptionChanged();
    xmlChanged();
}


void RubricXml::setDescriptors(const QVariantList &map) {

}

void RubricXml::setSource(QString source) {
    innerSource = source;
    if (innerSource.startsWith("file://"))
        innerSource.remove(0,7);
    loadXml();
    emit sourceChanged();
}

void RubricXml::setTitle(QString title) {
    document.elementsByTagName("rubric").at(0).toElement().setAttribute("title", title);
    titleChanged();
    xmlChanged();
}

void RubricXml::setXml(QString string) {
    document.setContent(string);
    xmlChanged();

    QDomNodeList domlist = document.elementsByTagName("rubric");
    mainRubricRoot = domlist.item(0).toElement();

    innerCriteria->setDomRoot(mainRubricRoot);

    innerPopulationModel->setDomRoot(mainRubricRoot.elementsByTagName("population").at(0).toElement());

    innerAssessmentModel->setDomRoot(mainRubricRoot.elementsByTagName("assessment").at(0).toElement());

    titleChanged();
    descriptionChanged();
    criteriaChanged();
    populationChanged();
    assessmentChanged();
}

QString RubricXml::source() {
    return innerSource;
}

QString RubricXml::title() {
    return mainRubricRoot.attribute("title");
}

QString RubricXml::xml() {
    return document.toString();
}
