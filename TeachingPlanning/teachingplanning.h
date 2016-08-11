#ifndef TEACHINGPLANNING_H
#define TEACHINGPLANNING_H

#include <QObject>
#include <QDomDocument>
#include <QVariantList>
#include "xmlmodel.h"

class TeachingPlanning : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString xml READ xml WRITE setXml NOTIFY xmlChanged)

    Q_PROPERTY(XmlModel* unitTitle READ unitTitle NOTIFY unitTitleChanged)
    Q_PROPERTY(XmlModel* project READ project NOTIFY projectChanged)
    Q_PROPERTY(XmlModel* author READ author NOTIFY authorChanged)
    Q_PROPERTY(XmlModel* support READ support NOTIFY supportChanged)
    Q_PROPERTY(XmlModel* group READ group NOTIFY groupChanged)
    Q_PROPERTY(XmlModel* areas READ areas NOTIFY areasChanged)
    Q_PROPERTY(XmlModel* keywords READ keywords NOTIFY keywordsChanged)
    Q_PROPERTY(XmlModel* timing READ timing NOTIFY timingChanged)

    Q_PROPERTY(XmlModel* introduction READ introduction NOTIFY introductionChanged)
    Q_PROPERTY(XmlModel* objectives READ objectives NOTIFY objectivesChanged)

    Q_PROPERTY(XmlModel* competenceLing READ competenceLing NOTIFY competenceLingChanged)
    Q_PROPERTY(XmlModel* competenceMat READ competenceMat NOTIFY competenceMatChanged)
    Q_PROPERTY(XmlModel* competenceTic READ competenceTic NOTIFY competenceTicChanged)
    Q_PROPERTY(XmlModel* competenceSoc READ competenceSoc NOTIFY competenceSocChanged)
    Q_PROPERTY(XmlModel* competenceCult READ competenceCult NOTIFY competenceCultChanged)
    Q_PROPERTY(XmlModel* competenceLearn READ competenceLearn NOTIFY competenceLearnChanged)
    Q_PROPERTY(XmlModel* competenceAuto READ competenceAuto NOTIFY competenceAutoChanged)

    Q_PROPERTY(XmlModel* assessmentTasks READ assessmentTasks NOTIFY assessmentTasksChanged)
    Q_PROPERTY(XmlModel* assessmentCriteria READ assessmentCriteria NOTIFY assessmentCriteriaChanged)
    Q_PROPERTY(XmlModel* assessmentInstruments READ assessmentInstruments NOTIFY assessmentInstrumentsChanged)

    Q_PROPERTY(XmlModel* contentsKnowledge READ contentsKnowledge NOTIFY contentsKnowledgeChanged)
    Q_PROPERTY(XmlModel* contentsHabilities READ contentsHabilities NOTIFY contentsHabilitiesChanged)
    Q_PROPERTY(XmlModel* contentsLanguage READ contentsLanguage NOTIFY contentsLanguageChanged)
    Q_PROPERTY(XmlModel* contentsValues READ contentsValues NOTIFY contentsValuesChanged)

    Q_PROPERTY(XmlModel* resources READ resources NOTIFY resourcesChanged)
    Q_PROPERTY(XmlModel* references READ references NOTIFY referencesChanged)
    Q_PROPERTY(XmlModel* activities READ activities NOTIFY activitiesChanged)
    Q_PROPERTY(XmlModel* comments READ comments NOTIFY commentsChanged)

public:
    explicit TeachingPlanning(QObject *parent = 0);

    Q_INVOKABLE bool create();
    Q_INVOKABLE void loadXml();
    Q_INVOKABLE bool save();

    // Getters

    const QString &source();
    QString xml();

    XmlModel *unitTitle();
    XmlModel *project();
    XmlModel *author();
    XmlModel *support();
    XmlModel *group();
    XmlModel *areas();
    XmlModel *keywords();
    XmlModel *timing();

    XmlModel *introduction();
    XmlModel *objectives();

    XmlModel *competenceLing();
    XmlModel *competenceMat();
    XmlModel *competenceTic();
    XmlModel *competenceSoc();
    XmlModel *competenceCult();
    XmlModel *competenceLearn();
    XmlModel *competenceAuto();

    XmlModel *assessmentTasks();
    XmlModel *assessmentCriteria();
    XmlModel *assessmentInstruments();

    XmlModel *contentsKnowledge();
    XmlModel *contentsHabilities();
    XmlModel *contentsLanguage();
    XmlModel *contentsValues();

    XmlModel *resources();
    XmlModel *references();
    XmlModel *activities();
    XmlModel *comments();

    // Setters

    void setSource(const QString &);
    void setXml(const QString &);

signals:
    void sourceChanged();
    void xmlChanged();
    void documentLoaded();

    void unitTitleChanged();
    void projectChanged();
    void authorChanged();
    void supportChanged();
    void groupChanged();
    void areasChanged();
    void keywordsChanged();
    void timingChanged();

    void introductionChanged();
    void objectivesChanged();

    void competenceLingChanged();
    void competenceMatChanged();
    void competenceTicChanged();
    void competenceSocChanged();
    void competenceCultChanged();
    void competenceLearnChanged();
    void competenceAutoChanged();

    void assessmentTasksChanged();
    void assessmentCriteriaChanged();
    void assessmentInstrumentsChanged();

    void contentsKnowledgeChanged();
    void contentsHabilitiesChanged();
    void contentsLanguageChanged();
    void contentsValuesChanged();


    void resourcesChanged();
    void referencesChanged();
    void activitiesChanged();
    void commentsChanged();

public slots:

private:
    QString innerSource;
    QDomDocument document;
    QDomElement planningRoot;

    // Models
    XmlModel modelUnitTitle;
    XmlModel modelProject;
    XmlModel modelAuthor;
    XmlModel modelSupport;
    XmlModel modelGroup;
    XmlModel modelAreas;
    XmlModel modelKeywords;
    XmlModel modelTiming;

    XmlModel modelIntroduction;
    XmlModel modelObjectives;

    XmlModel modelCompetenceLing;
    XmlModel modelCompetenceMat;
    XmlModel modelCompetenceTic;
    XmlModel modelCompetenceSoc;
    XmlModel modelCompetenceCult;
    XmlModel modelCompetenceLearn;
    XmlModel modelCompetenceAuto;

    XmlModel modelAssessmentTasks;
    XmlModel modelAssessmentCriteria;
    XmlModel modelAssessmentInstruments;

    XmlModel modelContentsKnowledge;
    XmlModel modelContentsHabilities;
    XmlModel modelContentsLanguage;
    XmlModel modelContentsValues;

    XmlModel modelResources;
    XmlModel modelReferences;
    XmlModel modelActivities;
    XmlModel modelComments;
};

#endif // TEACHINGPLANNING_H
