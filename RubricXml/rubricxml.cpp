#include <QObject>
#include <QFile>
#include <QVariantList>
#include <QDebug>
#include "rubricxml.h"
#include "rubricindividualsmodel.h"
#include "rubricassessmentmodel.h"

RubricXml::RubricXml(QObject *parent) : QObject(parent)
{
    innerCriteria = new RubricCriteria(this);
    innerIndividualsModel = new RubricIndividualsModel(this);
    innerAssessmentModel = new RubricAssessmentModel(this);
}

RubricAssessmentModel *RubricXml::assessment() {
    return innerAssessmentModel;
}

RubricCriteria *RubricXml::criteria() {
    return innerCriteria;
}

const QString &RubricXml::description() {
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

const QString &RubricXml::group() {
    return mainRubricRoot.attribute("group");
}

RubricIndividualsModel *RubricXml::individuals() {
    return innerIndividualsModel;
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

void RubricXml::setDescriptors(const QVariantList &map) {

}

void RubricXml::setSource(const QString &source) {
    innerSource = source;
    if (innerSource.startsWith("file://"))
        innerSource.remove(0,7);
    loadXml();
    emit sourceChanged();
}

void RubricXml::setXml(const QString &xml) {
    qDebug() << "Setting XML";
    document.setContent(xml);
    xmlChanged();

    QDomNodeList domlist = document.elementsByTagName("rubric");
    mainRubricRoot = domlist.item(0).toElement();

    innerCriteria->setDomRoot(mainRubricRoot);

    innerIndividualsModel->setDomRoot(mainRubricRoot.elementsByTagName("group").at(0).toElement());

    innerAssessmentModel->setDomRoot(mainRubricRoot.elementsByTagName("assessment").at(0).toElement());
    criteriaChanged();
    individualsChanged();
    assessmentChanged();
}

const QString &RubricXml::source() {
    return innerSource;
}

const QString &RubricXml::title() {
    return mainRubricRoot.attribute("title");
}

const QString &RubricXml::xml() {
    return mainRubricRoot.ownerDocument().toString();
}
