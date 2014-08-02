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

    Q_PROPERTY(XmlModel* basicData READ basicData WRITE setBasicData NOTIFY basicDataChanged)

    Q_PROPERTY(XmlModel* introduction READ introduction WRITE setIntroduction NOTIFY introductionChanged)
    Q_PROPERTY(XmlModel* objectives READ objectives WRITE setObjectives NOTIFY objectivesChanged)

    Q_PROPERTY(XmlModel* competenceLing READ competenceLing WRITE setCompetenceLing NOTIFY competenceLingChanged)
    Q_PROPERTY(XmlModel* competenceMat READ competenceMat WRITE setCompetenceMat NOTIFY competenceMatChanged)
    Q_PROPERTY(XmlModel* competenceTic READ competenceTic WRITE setCompetenceTic NOTIFY competenceTicChanged)
    Q_PROPERTY(XmlModel* competenceSoc READ competenceSoc WRITE setCompetenceSoc NOTIFY competenceSocChanged)
    Q_PROPERTY(XmlModel* competenceCult READ competenceCult WRITE setCompetenceCult NOTIFY competenceCultChanged)
    Q_PROPERTY(XmlModel* competenceLearn READ competenceLearn WRITE setCompetenceLearn NOTIFY competenceLearnChanged)
    Q_PROPERTY(XmlModel* competenceAuto READ competenceAuto WRITE setCompetenceAuto NOTIFY competenceAutoChanged)

    Q_PROPERTY(XmlModel* assessmentTasks READ assessmentTasks WRITE setAssessmentTasks NOTIFY assessmentTasksChanged)
    Q_PROPERTY(XmlModel* assessmentCriteria READ assessmentCriteria WRITE setAssessmentCriteria NOTIFY assessmentCriteriaChanged)
    Q_PROPERTY(XmlModel* assessmentInstruments READ assessmentInstruments WRITE setAssessmentInstruments NOTIFY assessmentInstrumentsChanged)

    Q_PROPERTY(XmlModel* contentsKnowledge READ contentsKnowledge WRITE setContentsKnowledge NOTIFY contentsKnowledgeChanged)
    Q_PROPERTY(XmlModel* contentsHabilities READ contentsHabilities WRITE setContentsHabilities NOTIFY contentsHabilitiesChanged)
    Q_PROPERTY(XmlModel* contentsLanguage READ contentsLanguage WRITE setContentsLanguage NOTIFY contentsLanguageChanged)
    Q_PROPERTY(XmlModel* contentsValues READ contentsValues WRITE setContentsValues NOTIFY contentsValuesChanged)

    Q_PROPERTY(XmlModel* resources READ resources WRITE setResources NOTIFY resourcesChanged)
    Q_PROPERTY(XmlModel* references READ references WRITE setReferences NOTIFY referencesChanged)
    Q_PROPERTY(XmlModel* activities READ activities WRITE setActivities NOTIFY activitiesChanged)
    Q_PROPERTY(XmlModel* comments READ comments WRITE setComments NOTIFY commentsChanged)

public:
    explicit TeachingPlanning(QObject *parent = 0);

    Q_INVOKABLE void loadXml();
    Q_INVOKABLE bool save();

    const QString &source();
    QString xml();

    XmlModel *basicData();

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

    void setBasicData(const XmlModel *);

    void setIntroduction(XmlModel *);
    void setObjectives(XmlModel *);

    void setCompetenceLing(const XmlModel *);
    void setCompetenceMat(const XmlModel *);
    void setCompetenceTic(const XmlModel *);
    void setCompetenceSoc(const XmlModel *);
    void setCompetenceCult(const XmlModel *);
    void setCompetenceLearn(const XmlModel *);
    void setCompetenceAuto(const XmlModel *);

    void setAssessmentTasks(const XmlModel *);
    void setAssessmentCriteria(const XmlModel *);
    void setAssessmentInstruments(const XmlModel *);

    void setContentsKnowledge(const XmlModel *);
    void setContentsHabilities(const XmlModel *);
    void setContentsLanguage(const XmlModel *);
    void setContentsValues(const XmlModel *);

    void setResources(const XmlModel *);
    void setReferences(const XmlModel *);
    void setActivities(const XmlModel *);
    void setComments(const XmlModel *);

signals:
    void sourceChanged();
    void xmlChanged();
    void documentLoaded();

    void basicDataChanged();
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
    XmlModel modelBasicData;
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
