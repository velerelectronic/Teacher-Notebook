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

    Q_PROPERTY(XmlModel* unitTitle READ unitTitle WRITE setUnitTitle NOTIFY unitTitleChanged)
    Q_PROPERTY(XmlModel* project READ project WRITE setProject NOTIFY projectChanged)
    Q_PROPERTY(XmlModel* author READ author WRITE setAuthor NOTIFY authorChanged)
    Q_PROPERTY(XmlModel* support READ support WRITE setSupport NOTIFY supportChanged)
    Q_PROPERTY(XmlModel* group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(XmlModel* areas READ areas WRITE setAreas NOTIFY areasChanged)
    Q_PROPERTY(XmlModel* keywords READ keywords WRITE setKeywords NOTIFY keywordsChanged)
    Q_PROPERTY(XmlModel* timing READ timing WRITE setTiming NOTIFY timingChanged)

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

    void setUnitTitle(XmlModel *);
    void setProject(XmlModel *);
    void setAuthor(XmlModel *);
    void setSupport(XmlModel *);
    void setGroup(XmlModel *);
    void setAreas(XmlModel *);
    void setKeywords(XmlModel *);
    void setTiming(XmlModel *);

    void setIntroduction(XmlModel *);
    void setObjectives(XmlModel *);

    void setCompetenceLing(XmlModel *);
    void setCompetenceMat(XmlModel *);
    void setCompetenceTic(XmlModel *);
    void setCompetenceSoc(XmlModel *);
    void setCompetenceCult(XmlModel *);
    void setCompetenceLearn(XmlModel *);
    void setCompetenceAuto(XmlModel *);

    void setAssessmentTasks(XmlModel *);
    void setAssessmentCriteria(XmlModel *);
    void setAssessmentInstruments(XmlModel *);

    void setContentsKnowledge(XmlModel *);
    void setContentsHabilities(XmlModel *);
    void setContentsLanguage(XmlModel *);
    void setContentsValues(XmlModel *);

    void setResources(XmlModel *);
    void setReferences(XmlModel *);
    void setActivities(XmlModel *);
    void setComments(XmlModel *);

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
