#include <QFile>
#include <QDebug>
#include <QVariantList>

#include "teachingplanning.h"
#include "xmlmodel.h"

#define TAG_BASIC_DATA QString("basicdata")
#define TAG_BASIC_DATA_UNIT_TITLE QString("unittitle")
#define TAG_BASIC_DATA_PROJECT QString("project")
#define TAG_BASIC_DATA_AUTHOR QString("author")
#define TAG_BASIC_DATA_SUPPORT QString("support")
#define TAG_BASIC_DATA_GROUP QString("group")
#define TAG_BASIC_DATA_AREAS QString("areas")
#define TAG_BASIC_DATA_KEYWORDS QString("keywords")
#define TAG_BASIC_DATA_TIMING QString("timing")

#define TAG_INTRODUCTION QString("introduction")
#define TAG_OBJECTIVES QString("objectives")
#define TAG_SINGLE_OBJECTIVE QString("objective")

#define TAG_COMPETENCES QString("competences")
#define TAG_COMPETENCE_LING QString("ling")
#define TAG_COMPETENCE_MAT QString("mat")
#define TAG_COMPETENCE_TIC QString("tic")
#define TAG_COMPETENCE_SOC QString("social")
#define TAG_COMPETENCE_CULT QString("cult")
#define TAG_COMPETENCE_LEARN QString("learn")
#define TAG_COMPETENCE_AUTO QString("auto")

#define TAG_ASSESSMENT QString("assessment")
#define TAG_ASSESSMENT_TASK QString("task")
#define TAG_ASSESSMENT_CRITERIUM QString("criterium")
#define TAG_ASSESSMENT_INSTRUMENT QString("instrument")

#define TAG_CONTENTS QString("contents")
#define TAG_CONTENTS_KNOWLEDGE QString("knowledge")
#define TAG_CONTENTS_HABILITIES QString("habilities")
#define TAG_CONTENTS_LANGUAGE QString("language")
#define TAG_CONTENTS_VALUES QString("values")

#define TAG_RESOURCES QString("resources")
#define TAG_SINGLE_RESOURCE QString("resource")

#define TAG_REFERENCES QString("references")
#define TAG_SINGLE_REFERENCE QString("item")

#define TAG_ACTIVITIES QString("activities")
#define TAG_SINGLE_ACTIVITY QString("activity")

#define TAG_COMMENTS QString("comments")
#define TAG_SINGLE_COMMENT QString("comment")

TeachingPlanning::TeachingPlanning(QObject *parent) :
    QObject(parent)
{
}


// Source

const QString &TeachingPlanning::source() {
    return innerSource;
}

void TeachingPlanning::setSource(const QString &source) {
    innerSource = source;
    if (innerSource.startsWith("file://"))
        innerSource.remove(0,7);
    loadXml();
    emit sourceChanged();
}

// Xml

QString TeachingPlanning::xml() {
    return QString(document.toString());
}

void TeachingPlanning::setXml(const QString &xml) {
    document.setContent(xml);
    QDomNodeList domlist = document.elementsByTagName("planning");
    planningRoot = domlist.item(0).toElement();
    emit TeachingPlanning::xmlChanged();
    emit TeachingPlanning::documentLoaded();
    emit xmlChanged();
    qDebug() << "Final càrrega XML";
}

// Basic data

QVariantList TeachingPlanning::basicData() {
    XmlModel model(this);
    model.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));

    QStringList listBasicData;
    listBasicData << TAG_BASIC_DATA_UNIT_TITLE << TAG_BASIC_DATA_PROJECT << TAG_BASIC_DATA_AUTHOR << TAG_BASIC_DATA_SUPPORT
    << TAG_BASIC_DATA_GROUP << TAG_BASIC_DATA_AREAS << TAG_BASIC_DATA_KEYWORDS << TAG_BASIC_DATA_TIMING;

    QVariantList result;
    for (int i=0; i<listBasicData.length(); i++) {
        model.setTagName(listBasicData.at(i));
        model.recalculateList();
        result += model.list();
    }
    return result;
}

void TeachingPlanning::setBasicData(const QVariantList &) {

}

// Introduction

QVariantList TeachingPlanning::introduction() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_INTRODUCTION),"").list();
}

void TeachingPlanning::setIntroduction(const QVariantList &list) {

}

// Objectives

QVariantList TeachingPlanning::objectives() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_OBJECTIVES),TAG_SINGLE_OBJECTIVE).list();
}

void TeachingPlanning::setObjectives(const QVariantList &list) {

}

// Competences

QVariantList TeachingPlanning::competenceLing() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_LING).list();
}

QVariantList TeachingPlanning::competenceMat() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_MAT).list();
}

QVariantList TeachingPlanning::competenceTic() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_TIC).list();
}

QVariantList TeachingPlanning::competenceSoc() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_SOC).list();
}

QVariantList TeachingPlanning::competenceCult() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_CULT).list();
}

QVariantList TeachingPlanning::competenceLearn() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_LEARN).list();
}

QVariantList TeachingPlanning::competenceAuto() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_AUTO).list();
}

void TeachingPlanning::setCompetenceLing(const QVariantList &) {

}

void TeachingPlanning::setCompetenceMat(const QVariantList &) {

}

void TeachingPlanning::setCompetenceTic(const QVariantList &) {

}

void TeachingPlanning::setCompetenceSoc(const QVariantList &) {

}

void TeachingPlanning::setCompetenceCult(const QVariantList &) {

}

void TeachingPlanning::setCompetenceLearn(const QVariantList &) {

}

void TeachingPlanning::setCompetenceAuto(const QVariantList &) {

}


// Assessment: tasks, criteria, instruments

QVariantList TeachingPlanning::assessmentTasks() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_ASSESSMENT),TAG_ASSESSMENT_TASK).list();
}

QVariantList TeachingPlanning::assessmentCriteria() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_ASSESSMENT),TAG_ASSESSMENT_CRITERIUM).list();
}

QVariantList TeachingPlanning::assessmentInstruments() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_ASSESSMENT),TAG_ASSESSMENT_INSTRUMENT).list();
}

void TeachingPlanning::setAssessmentTasks(const QVariantList &) {

}

void TeachingPlanning::setAssessmentCriteria(const QVariantList &) {

}

void TeachingPlanning::setAssessmentInstruments(const QVariantList &) {

}


// Contents: knowledge, habilities, language, values

QVariantList TeachingPlanning::contentsKnowledge() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_CONTENTS),TAG_CONTENTS_KNOWLEDGE).list();
}

QVariantList TeachingPlanning::contentsHabilities() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_CONTENTS),TAG_CONTENTS_HABILITIES).list();

}

QVariantList TeachingPlanning::contentsLanguage() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_CONTENTS),TAG_CONTENTS_LANGUAGE).list();

}

QVariantList TeachingPlanning::contentsValues() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_CONTENTS),TAG_CONTENTS_VALUES).list();

}

void TeachingPlanning::setContentsKnowledge(const QVariantList &) {

}

void TeachingPlanning::setContentsHabilities(const QVariantList &) {

}

void TeachingPlanning::setContentsLanguage(const QVariantList &) {

}

void TeachingPlanning::setContentsValues(const QVariantList &) {

}

// Resources

QVariantList TeachingPlanning::resources() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_RESOURCES),TAG_SINGLE_RESOURCE).list();
}

void TeachingPlanning::setResources(const QVariantList &) {

}

// References

QVariantList TeachingPlanning::references() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_REFERENCES),TAG_SINGLE_REFERENCE).list();
}

void TeachingPlanning::setReferences(const QVariantList &) {

}

// Activities

QVariantList TeachingPlanning::activities() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_ACTIVITIES),TAG_SINGLE_ACTIVITY).list();
}

void TeachingPlanning::setActivities(const QVariantList &) {

}

// Comments

QVariantList TeachingPlanning::comments() {
    return XmlModel(this,planningRoot.firstChildElement(TAG_COMMENTS),TAG_SINGLE_COMMENT).list();
}

void TeachingPlanning::setComments(const QVariantList &) {

}

// Private functions

void TeachingPlanning::loadXml() {
    QFile xfile(innerSource);

    qDebug() << "Carregant XML";
    if (xfile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        setXml(xfile.readAll());
    }
    xfile.close();
}
