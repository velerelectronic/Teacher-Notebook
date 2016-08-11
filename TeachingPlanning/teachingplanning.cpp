#include <QFile>
#include <QDebug>
#include <QVariantList>
#include <QString>
#include <stdio.h>

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


bool TeachingPlanning::create() {
    QString blankDocument = "<planning version=\"1.0\"><basicdata><unittitle/><project/><author/><support/><group/><areas/><keywords/><timing/></basicdata><introduction/><objectives/><competences/><assessment/><contents/><resources/><references/><activities/><comments/></planning>";
    document.setContent(blankDocument);
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

    emit unitTitleChanged();
    emit projectChanged();
    emit authorChanged();
    emit supportChanged();
    emit groupChanged();
    emit areasChanged();
    emit keywordsChanged();
    emit timingChanged();

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

XmlModel *TeachingPlanning::unitTitle() {
    modelUnitTitle.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));
    modelUnitTitle.setTagName(TAG_BASIC_DATA_UNIT_TITLE);
    return &modelUnitTitle;
}

XmlModel *TeachingPlanning::project() {
    modelProject.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));
    modelProject.setTagName(TAG_BASIC_DATA_PROJECT);
    return &modelProject;
}

XmlModel *TeachingPlanning::author() {
    modelAuthor.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));
    modelAuthor.setTagName(TAG_BASIC_DATA_AUTHOR);
    return &modelAuthor;
}

XmlModel *TeachingPlanning::support() {
    modelSupport.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));
    modelSupport.setTagName(TAG_BASIC_DATA_SUPPORT);
    return &modelSupport;
}

XmlModel *TeachingPlanning::group() {
    modelGroup.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));
    modelGroup.setTagName(TAG_BASIC_DATA_GROUP);
    return &modelGroup;
}

XmlModel *TeachingPlanning::areas() {
    modelAreas.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));
    modelAreas.setTagName(TAG_BASIC_DATA_AREAS);
    return &modelAreas;
}

XmlModel *TeachingPlanning::keywords() {
    modelKeywords.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));
    modelKeywords.setTagName(TAG_BASIC_DATA_KEYWORDS);
    return &modelKeywords;
}

XmlModel *TeachingPlanning::timing() {
    modelTiming.setRootElement(planningRoot.firstChildElement(TAG_BASIC_DATA));
    modelTiming.setTagName(TAG_BASIC_DATA_TIMING);
    return &modelTiming;
}



// Introduction

XmlModel *TeachingPlanning::introduction() {
    modelIntroduction.setRootElement(planningRoot.firstChildElement(TAG_INTRODUCTION));
    return &modelIntroduction;
}

// Objectives

XmlModel *TeachingPlanning::objectives() {
    modelIntroduction.setRootElement(planningRoot.firstChildElement(TAG_OBJECTIVES));
    modelIntroduction.setTagName(TAG_SINGLE_OBJECTIVE);
    return &modelIntroduction;
}

// Competences

XmlModel *TeachingPlanning::competenceLing() {
    modelCompetenceLing.setRootElement(planningRoot.firstChildElement(TAG_COMPETENCES));
    modelCompetenceLing.setTagName(TAG_COMPETENCE_LING);
    return &modelCompetenceLing;
}

XmlModel *TeachingPlanning::competenceMat() {
    modelCompetenceMat.setRootElement(planningRoot.firstChildElement(TAG_COMPETENCES));
    modelCompetenceMat.setTagName(TAG_COMPETENCE_MAT);
    return &modelCompetenceMat;
}

XmlModel *TeachingPlanning::competenceTic() {
    modelCompetenceTic.setRootElement(planningRoot.firstChildElement(TAG_COMPETENCES));
    modelCompetenceTic.setTagName(TAG_COMPETENCE_TIC);
    return &modelCompetenceTic;
}

XmlModel *TeachingPlanning::competenceSoc() {
    modelCompetenceSoc.setRootElement(planningRoot.firstChildElement(TAG_COMPETENCES));
    modelCompetenceSoc.setTagName(TAG_COMPETENCE_SOC);
    return &modelCompetenceSoc;
}

XmlModel *TeachingPlanning::competenceCult() {
    modelCompetenceCult.setRootElement(planningRoot.firstChildElement(TAG_COMPETENCES));
    modelCompetenceCult.setTagName(TAG_COMPETENCE_CULT);
    return &modelCompetenceCult;
}

XmlModel *TeachingPlanning::competenceLearn() {
    modelCompetenceLearn.setRootElement(planningRoot.firstChildElement(TAG_COMPETENCES));
    modelCompetenceLearn.setTagName(TAG_COMPETENCE_LEARN);
    return &modelCompetenceLearn;
}

XmlModel *TeachingPlanning::competenceAuto() {
    modelCompetenceAuto.setRootElement(planningRoot.firstChildElement(TAG_COMPETENCES));
    modelCompetenceAuto.setTagName(TAG_COMPETENCE_AUTO);
    return &modelCompetenceAuto;
}



// Assessment: tasks, criteria, instruments

XmlModel *TeachingPlanning::assessmentTasks() {
    modelAssessmentTasks.setRootElement(planningRoot.firstChildElement(TAG_ASSESSMENT));
    modelAssessmentTasks.setTagName(TAG_ASSESSMENT_TASK);
    return &modelAssessmentTasks;
}

XmlModel *TeachingPlanning::assessmentCriteria() {
    modelAssessmentCriteria.setRootElement(planningRoot.firstChildElement(TAG_ASSESSMENT));
    modelAssessmentCriteria.setTagName(TAG_ASSESSMENT_CRITERIUM);
    return &modelAssessmentCriteria;
}

XmlModel *TeachingPlanning::assessmentInstruments() {
    modelAssessmentInstruments.setRootElement(planningRoot.firstChildElement(TAG_ASSESSMENT));
    modelAssessmentInstruments.setTagName(TAG_ASSESSMENT_INSTRUMENT);
    return &modelAssessmentInstruments;
}


// Contents: knowledge, habilities, language, values

XmlModel *TeachingPlanning::contentsKnowledge() {
    modelContentsKnowledge.setRootElement(planningRoot.firstChildElement(TAG_CONTENTS));
    modelContentsKnowledge.setTagName(TAG_CONTENTS_KNOWLEDGE);
    return &modelContentsKnowledge;
}

XmlModel *TeachingPlanning::contentsHabilities() {
    modelContentsHabilities.setRootElement(planningRoot.firstChildElement(TAG_CONTENTS));
    modelContentsHabilities.setTagName(TAG_CONTENTS_HABILITIES);
    return &modelContentsHabilities;
}

XmlModel *TeachingPlanning::contentsLanguage() {
    modelContentsLanguage.setRootElement(planningRoot.firstChildElement(TAG_CONTENTS));
    modelContentsLanguage.setTagName(TAG_CONTENTS_LANGUAGE);
    return &modelContentsLanguage;
}

XmlModel *TeachingPlanning::contentsValues() {
    modelContentsValues.setRootElement(planningRoot.firstChildElement(TAG_CONTENTS));
    modelContentsValues.setTagName(TAG_CONTENTS_VALUES);
    return &modelContentsValues;
}


// Resources

XmlModel *TeachingPlanning::resources() {
    modelResources.setRootElement(planningRoot.firstChildElement(TAG_RESOURCES));
    modelResources.setTagName(TAG_SINGLE_RESOURCE);
    return &modelResources;
}

// References

XmlModel *TeachingPlanning::references() {
    modelReferences.setRootElement(planningRoot.firstChildElement(TAG_REFERENCES));
    modelReferences.setTagName(TAG_SINGLE_REFERENCE);
    return &modelReferences;
}

// Activities

XmlModel *TeachingPlanning::activities() {
    modelActivities.setRootElement(planningRoot.firstChildElement(TAG_ACTIVITIES));
    modelActivities.setTagName(TAG_SINGLE_ACTIVITY);
    return &modelActivities;
}

// Comments

XmlModel *TeachingPlanning::comments() {
    modelComments.setRootElement(planningRoot.firstChildElement(TAG_COMMENTS));
    modelComments.setTagName(TAG_SINGLE_COMMENT);
    return &modelComments;
}

// Private functions

void TeachingPlanning::loadXml() {
    QFile xfile(innerSource);

    qDebug() << "Carregant XML";
    if (xfile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString contents = xfile.readAll();
        setXml(contents);
    }
    xfile.close();
    emit xmlChanged();
}

bool TeachingPlanning::save() {
    QFile xfile(innerSource);

    if (xfile.open(QIODevice::WriteOnly)) {
        QByteArray text = document.toString().toUtf8();
        if (xfile.write(text)==qstrlen(text)) {
            xfile.close();
            return true;
        }
    }
    xfile.close();
    return false;
}

