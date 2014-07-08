#include <QXmlResultItems>
#include <QDebug>
#include <QFile>
#include "programacioaulamodel.h"

ProgramacioAulaModel::ProgramacioAulaModel(QObject *parent) :
    QObject(parent)
{
}

QString ProgramacioAulaModel::source() {
    return msource;
}

void ProgramacioAulaModel::setSource(const QString &source) {
    msource = source;
    loadXML();
}


void ProgramacioAulaModel::loadXML(){
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

QVariantList ProgramacioAulaModel::basicData() {
//    return subElements(planningRoot,"basicData");
}


QString ProgramacioAulaModel::xml() {

}


// Introduction

QString ProgramacioAulaModel::introduction() {
//    return elementText(planningRoot,"introduction");
}

void ProgramacioAulaModel::setIntroduction(QString &intro) {
//    intro;
}

// Objectives

XmlModel ProgramacioAulaModel::objectives() {
    XmlModel model(this);
    model.setRootElement(planningRoot.firstChildElement(TAG_OBJECTIVES));
    model.setTagName(TAG_SINGLE_OBJECTIVE);
    return model;
}

void ProgramacioAulaModel::setObjectives(const XmlModel &objectives) {

}

//  Competences

QVariantList ProgramacioAulaModel::competences() {

}

QVariantList ProgramacioAulaModel::competenceLing() {

}

QVariantList ProgramacioAulaModel::competenceMat() {

}

QVariantList ProgramacioAulaModel::competenceTic() {

}

QVariantList ProgramacioAulaModel::competenceSoc() {

}

QVariantList ProgramacioAulaModel::competenceCult() {

}

QVariantList ProgramacioAulaModel::competenceLearn() {

}

QVariantList ProgramacioAulaModel::competenceAuto() {

}

QVariantList ProgramacioAulaModel::assessmentTasks() {

}

QVariantList ProgramacioAulaModel::assessmentCriteria() {

}

QVariantList ProgramacioAulaModel::assessmentInstruments() {

}

QVariantList ProgramacioAulaModel::contentsKnowledge() {

}

QVariantList ProgramacioAulaModel::contentsHabilities() {

}

QVariantList ProgramacioAulaModel::contentsLanguage() {

}

QVariantList ProgramacioAulaModel::contentsValues() {

}

QVariantList ProgramacioAulaModel::resources() {

}

QVariantList ProgramacioAulaModel::references() {

}

QVariantList ProgramacioAulaModel::activities() {

}

QString ProgramacioAulaModel::comments() {

}


// Private methods


QString ProgramacioAulaModel::printHtml() {

}
