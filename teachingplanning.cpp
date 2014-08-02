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

    emit basicDataChanged();
    emit introductionChanged();

    connect(&modelObjectives,SIGNAL(updated()),this,SIGNAL(objectivesChanged()));
    emit objectivesChanged();
    emit competenceLingChanged();
    emit competenceMatChanged();
    emit competenceTicChanged();
    emit competenceSocChanged();
    emit competenceCultChanged();
    emit competenceLearnChanged();
    emit competenceAutoChanged();

    emit assessmentTasksChanged();
    emit assessmentCriteriaChanged();
    emit assessmentInstrumentsChanged();

    emit contentsKnowledgeChanged();
    emit contentsHabilitiesChanged();
    emit contentsLanguageChanged();
    emit contentsValuesChanged();

    emit resourcesChanged();
    emit referencesChanged();
    emit commentsChanged();
    emit activitiesChanged();
}

// Basic data

XmlModel *TeachingPlanning::basicData() {
    modelBasicData.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));

    QStringList listBasicData;
    listBasicData << TAG_BASIC_DATA_UNIT_TITLE << TAG_BASIC_DATA_PROJECT << TAG_BASIC_DATA_AUTHOR << TAG_BASIC_DATA_SUPPORT
    << TAG_BASIC_DATA_GROUP << TAG_BASIC_DATA_AREAS << TAG_BASIC_DATA_KEYWORDS << TAG_BASIC_DATA_TIMING;

    QStringList result;
    for (int i=0; i<listBasicData.length(); i++) {
        modelBasicData.setTagName(listBasicData.at(i));
        modelBasicData.recalculateList();
        result << modelBasicData.stringList();
    }
    modelBasicData.setStringList(result);
    return &modelBasicData;
}

void TeachingPlanning::setBasicData(const XmlModel *) {

}

// Introduction

XmlModel *TeachingPlanning::introduction() {
    return modelIntroduction.readList(planningRoot.firstChildElement(TAG_INTRODUCTION),"");
}

void TeachingPlanning::setIntroduction(XmlModel *list) {

}

// Objectives

XmlModel *TeachingPlanning::objectives() {
    return modelObjectives.readList(planningRoot.firstChildElement(TAG_OBJECTIVES),TAG_SINGLE_OBJECTIVE);
}

void TeachingPlanning::setObjectives(XmlModel *list) {
    qDebug() << "setting objectives";
//    model->setRootElement(planningRoot.firstChildElement(TAG_OBJECTIVES));
//    model->setStringList(&list);
    list->setRootElement(planningRoot.firstChildElement(TAG_OBJECTIVES));
    list->toDomElement();
    objectivesChanged();
}

// Competences

XmlModel *TeachingPlanning::competenceLing() {
    return modelCompetenceLing.readList(planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_LING);
}

XmlModel *TeachingPlanning::competenceMat() {
    return modelCompetenceMat.readList(planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_MAT);
}

XmlModel *TeachingPlanning::competenceTic() {
    return modelCompetenceTic.readList(planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_TIC);
}

XmlModel *TeachingPlanning::competenceSoc() {
    return modelCompetenceSoc.readList(planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_SOC);
}

XmlModel *TeachingPlanning::competenceCult() {
    return modelCompetenceCult.readList(planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_CULT);
}

XmlModel *TeachingPlanning::competenceLearn() {
    return modelCompetenceLearn.readList(planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_LEARN);
}

XmlModel *TeachingPlanning::competenceAuto() {
    return modelCompetenceAuto.readList(planningRoot.firstChildElement(TAG_COMPETENCES),TAG_COMPETENCE_AUTO);
}

void TeachingPlanning::setCompetenceLing(const XmlModel *) {

}

void TeachingPlanning::setCompetenceMat(const XmlModel *) {

}

void TeachingPlanning::setCompetenceTic(const XmlModel *) {

}

void TeachingPlanning::setCompetenceSoc(const XmlModel *) {

}

void TeachingPlanning::setCompetenceCult(const XmlModel *) {

}

void TeachingPlanning::setCompetenceLearn(const XmlModel *) {

}

void TeachingPlanning::setCompetenceAuto(const XmlModel *) {

}


// Assessment: tasks, criteria, instruments

XmlModel *TeachingPlanning::assessmentTasks() {
    return modelAssessmentTasks.readList(planningRoot.firstChildElement(TAG_ASSESSMENT),TAG_ASSESSMENT_TASK);
}

XmlModel *TeachingPlanning::assessmentCriteria() {
    return modelAssessmentCriteria.readList(planningRoot.firstChildElement(TAG_ASSESSMENT),TAG_ASSESSMENT_CRITERIUM);
}

XmlModel *TeachingPlanning::assessmentInstruments() {
    return modelAssessmentInstruments.readList(planningRoot.firstChildElement(TAG_ASSESSMENT),TAG_ASSESSMENT_INSTRUMENT);
}

void TeachingPlanning::setAssessmentTasks(const XmlModel *) {

}

void TeachingPlanning::setAssessmentCriteria(const XmlModel *) {

}

void TeachingPlanning::setAssessmentInstruments(const XmlModel *) {

}


// Contents: knowledge, habilities, language, values

XmlModel *TeachingPlanning::contentsKnowledge() {
    return modelContentsKnowledge.readList(planningRoot.firstChildElement(TAG_CONTENTS),TAG_CONTENTS_KNOWLEDGE);
}

XmlModel *TeachingPlanning::contentsHabilities() {
    return modelContentsHabilities.readList(planningRoot.firstChildElement(TAG_CONTENTS),TAG_CONTENTS_HABILITIES);

}

XmlModel *TeachingPlanning::contentsLanguage() {
    return modelContentsLanguage.readList(planningRoot.firstChildElement(TAG_CONTENTS),TAG_CONTENTS_LANGUAGE);

}

XmlModel *TeachingPlanning::contentsValues() {
    return modelContentsValues.readList(planningRoot.firstChildElement(TAG_CONTENTS),TAG_CONTENTS_VALUES);

}

void TeachingPlanning::setContentsKnowledge(const XmlModel *) {

}

void TeachingPlanning::setContentsHabilities(const XmlModel *) {

}

void TeachingPlanning::setContentsLanguage(const XmlModel *) {

}

void TeachingPlanning::setContentsValues(const XmlModel *) {

}

// Resources

XmlModel *TeachingPlanning::resources() {
    return modelResources.readList(planningRoot.firstChildElement(TAG_RESOURCES),TAG_SINGLE_RESOURCE);
}

void TeachingPlanning::setResources(const XmlModel *) {

}

// References

XmlModel *TeachingPlanning::references() {
    return modelReferences.readList(planningRoot.firstChildElement(TAG_REFERENCES),TAG_SINGLE_REFERENCE);
}

void TeachingPlanning::setReferences(const XmlModel *) {

}

// Activities

XmlModel *TeachingPlanning::activities() {
    return modelActivities.readList(planningRoot.firstChildElement(TAG_ACTIVITIES),TAG_SINGLE_ACTIVITY);
}

void TeachingPlanning::setActivities(const XmlModel *) {

}

// Comments

XmlModel *TeachingPlanning::comments() {
    return modelComments.readList(planningRoot.firstChildElement(TAG_COMMENTS),TAG_SINGLE_COMMENT);
}

void TeachingPlanning::setComments(const XmlModel *) {

}

// Private functions

void TeachingPlanning::loadXml() {
    qDebug() << innerSource;
    QFile xfile(innerSource);

    qDebug() << "Carregant XML";
    if (xfile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString contents = xfile.readAll();
        setXml(contents);
    }
    xfile.close();
}

bool TeachingPlanning::save() {
    modelBasicData.toDomElement();
    modelIntroduction.toDomElement();
    modelObjectives.toDomElement();

    modelCompetenceLing.toDomElement();
    modelCompetenceMat.toDomElement();
    modelCompetenceTic.toDomElement();
    modelCompetenceSoc.toDomElement();
    modelCompetenceCult.toDomElement();
    modelCompetenceLearn.toDomElement();
    modelCompetenceAuto.toDomElement();

    modelAssessmentTasks.toDomElement();
    modelAssessmentCriteria.toDomElement();
    modelAssessmentInstruments.toDomElement();

    modelContentsKnowledge.toDomElement();
    modelContentsHabilities.toDomElement();
    modelContentsLanguage.toDomElement();
    modelContentsValues.toDomElement();

    modelResources.toDomElement();
    modelReferences.toDomElement();
    modelActivities.toDomElement();
    modelComments.toDomElement();

    qDebug() << document.toString();
}
