#include <QFile>
#include <QVariantMap>
#include <QVariantList>
#include <QDebug>
#include "XmlReader.h"

XmlReader::XmlReader(QObject *parent) : QObject(parent) {

}

QString XmlReader::source() {
    return msource;
}

QString XmlReader::xml() {
    return document.toString();
}

void XmlReader::setSource(const QString &source) {
    msource = source;
    loadXML();
}


void XmlReader::loadXML(){

    // Setup the full path to the XML file
    //	And open a QFile for use by the XmlStreamReader

    QFile xfile(msource);

    if (xfile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        document.setContent(&xfile);
    }
    xfile.close();

    QDomNodeList domlist = document.elementsByTagName("planning");
    planningRoot = domlist.item(0).toElement();
}

QVariantList XmlReader::basicData() {
    return subElements(planningRoot,"basicData");
}


// Introduction

QString XmlReader::introduction() {
    return elementText(planningRoot,"introduction");
}

void XmlReader::setIntroduction(QString &intro) {
    intro;
}

// Objectives

QVariantList XmlReader::objectives() {
    return getElementsText(planningRoot,TAG_OBJECTIVES,TAG_SINGLE_OBJECTIVE);
}

void XmlReader::setObjectives(const QVariantList &objectives) {
    qDebug() << planningRoot.toElement().toDocument().toString();

    setElementsText(planningRoot,TAG_OBJECTIVES,TAG_SINGLE_OBJECTIVE,objectives);

    objectivesChanged(objectives);
}

//  Competences

QVariantList XmlReader::competences() {
    return elementsUnder(planningRoot,"competences");
}

QVariantList XmlReader::competenceLing() {
    QDomElement competences = planningRoot.elementsByTagName("competences").item(0).toElement();
    return subElements(competences,"ling");
}

QVariantList XmlReader::competenceMat() {
    QDomElement competences = planningRoot.elementsByTagName("competences").item(0).toElement();
    return subElements(competences,"mat");
}

QVariantList XmlReader::competenceTic() {
    QDomElement competences = planningRoot.elementsByTagName("competences").item(0).toElement();
    return subElements(competences,"tic");
}

QVariantList XmlReader::competenceSoc() {
    QDomElement competences = planningRoot.elementsByTagName("competences").item(0).toElement();
    return subElements(competences,"soc");
}

QVariantList XmlReader::competenceCult() {
    QDomElement competences = planningRoot.elementsByTagName("competences").item(0).toElement();
    return subElements(competences,"cult");
}

QVariantList XmlReader::competenceLearn() {
    QDomElement competences = planningRoot.elementsByTagName("competences").item(0).toElement();
    return subElements(competences,"apren");
}

QVariantList XmlReader::competenceAuto() {
    QDomElement competences = planningRoot.elementsByTagName("competences").item(0).toElement();
    return subElements(competences,"auto");
}

QVariantList XmlReader::assessmentTasks() {
    QDomElement tasks = planningRoot.elementsByTagName("assessment").item(0).toElement();
    return subElements(tasks,"task");
}

QVariantList XmlReader::assessmentCriteria() {
    QDomElement criteria = planningRoot.elementsByTagName("assessment").item(0).toElement();
    return subElements(criteria,"criterium");
}

QVariantList XmlReader::assessmentInstruments() {
    QDomElement instruments = planningRoot.elementsByTagName("assessment").item(0).toElement();
    return subElements(instruments,"instrument");
}

QVariantList XmlReader::contentsKnowledge() {
    QDomElement contents = planningRoot.elementsByTagName("contents").item(0).toElement();
    return subElements(contents,"concept");
}

QVariantList XmlReader::contentsHabilities() {
    QDomElement contents = planningRoot.elementsByTagName("contents").item(0).toElement();
    return subElements(contents,"hability");
}

QVariantList XmlReader::contentsLanguage() {
    QDomElement contents = planningRoot.elementsByTagName("contents").item(0).toElement();
    return subElements(contents,"language");
}

QVariantList XmlReader::contentsValues() {
    QDomElement contents = planningRoot.elementsByTagName("contents").item(0).toElement();
    return subElements(contents,"value");
}

QVariantList XmlReader::resources() {
    return subElements(planningRoot,"resource");
}

QVariantList XmlReader::references() {
    return subElements(planningRoot,"reference");
}

QVariantList XmlReader::activities() {
    QDomElement activities = planningRoot.elementsByTagName("activities").item(0).toElement();
    return subElements(activities,"activity");
}

QString XmlReader::comments() {
    return elementText(planningRoot,"comments");
}


// Private methods


QString XmlReader::elementText(QDomElement rootElement,QString tagName) {
    QDomElement intro = rootElement.elementsByTagName(tagName).item(0).toElement();
    return intro.text();
}


QVariantList XmlReader::getElementsText(QDomElement &rootElement,QString element,QString subElement) {
    QVariantList result;
    QDomElement parentNode = rootElement.elementsByTagName(element).item(0).toElement();

    QDomElement traverse = parentNode.firstChildElement(subElement);

    while (!traverse.isNull()) {
        QVariantMap object;
        object["text"] = traverse.text();
        result << object;

        traverse = traverse.nextSiblingElement(subElement);
    }
    return result;
}

void XmlReader::setElementsText(QDomElement rootElement,QString element,QString subElement,QVariantList subTexts) {
    QDomElement parentNode = rootElement.elementsByTagName(element).item(0).toElement();
    QDomElement traverse = parentNode.firstChildElement(subElement);

    while (!traverse.isNull()) {
        qDebug() << traverse.tagName() << traverse.text();
        QDomElement removeNode = traverse;
        traverse = traverse.nextSiblingElement(subElement);
        parentNode.removeChild(removeNode);
    }
    for (int i=0; i<subTexts.length(); i++) {
        QDomElement newElement = document.createElement(subElement);
        newElement.appendChild(document.createTextNode(subTexts[i].toMap()["text"].toString()));
        parentNode.appendChild(newElement);
    }
}

QVariantList XmlReader::subElements(QDomElement rootElement,QString subElementName) {
    QVariantList result;
    QDomNodeList list = rootElement.elementsByTagName(subElementName);
    for (int i=0; i<list.length(); i++) {
        QVariantMap map;
        map["text"] = list.item(i).toElement().text();
        result << map;
    }
    return result;
}

QVariantList XmlReader::elementsUnder(QDomElement rootElement, QString elementName) {
    QVariantList result;
    QDomNodeList list = rootElement.elementsByTagName(elementName).item(0).toElement().childNodes();
    for (int i=0; i<list.length(); i++) {
        QVariantMap map;
        map["text"] = list.item(i).toElement().text();
        result << map;
    }
    return result;
}


QString XmlReader::printHtml() {
    return document.toElement().elementsByTagName("objectives").item(0).toDocument().toString();
}
