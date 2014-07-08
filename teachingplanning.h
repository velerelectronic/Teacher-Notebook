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

    Q_PROPERTY(QVariantList basicData READ basicData WRITE setBasicData NOTIFY basicDataChanged)

    Q_PROPERTY(QVariantList introduction READ introduction WRITE setIntroduction NOTIFY introductionChanged)
    Q_PROPERTY(QVariantList objectives READ objectives WRITE setObjectives NOTIFY objectivesChanged)

    Q_PROPERTY(QVariantList competenceLing READ competenceLing WRITE setCompetenceLing NOTIFY competenceLingChanged)
    Q_PROPERTY(QVariantList competenceMat READ competenceMat WRITE setCompetenceMat NOTIFY competenceMatChanged)
    Q_PROPERTY(QVariantList competenceTic READ competenceTic WRITE setCompetenceTic NOTIFY competenceTicChanged)
    Q_PROPERTY(QVariantList competenceSoc READ competenceSoc WRITE setCompetenceSoc NOTIFY competenceSocChanged)
    Q_PROPERTY(QVariantList competenceCult READ competenceCult WRITE setCompetenceCult NOTIFY competenceCultChanged)
    Q_PROPERTY(QVariantList competenceLearn READ competenceLearn WRITE setCompetenceLearn NOTIFY competenceLearnChanged)
    Q_PROPERTY(QVariantList competenceAuto READ competenceAuto WRITE setCompetenceAuto NOTIFY competenceAutoChanged)

    Q_PROPERTY(QVariantList assessmentTasks READ assessmentTasks WRITE setAssessmentTasks NOTIFY assessmentTasksChanged)
    Q_PROPERTY(QVariantList assessmentCriteria READ assessmentCriteria WRITE setAssessmentCriteria NOTIFY assessmentCriteriaChanged)
    Q_PROPERTY(QVariantList assessmentInstruments READ assessmentInstruments WRITE setAssessmentInstruments NOTIFY assessmentInstrumentsChanged)

    Q_PROPERTY(QVariantList contentsKnowledge READ contentsKnowledge WRITE setContentsKnowledge NOTIFY contentsKnowledgeChanged)
    Q_PROPERTY(QVariantList contentsHabilities READ contentsHabilities WRITE setContentsHabilities NOTIFY contentsHabilitiesChanged)
    Q_PROPERTY(QVariantList contentsLanguage READ contentsLanguage WRITE setContentsLanguage NOTIFY contentsLanguageChanged)
    Q_PROPERTY(QVariantList contentsValues READ contentsValues WRITE setContentsValues NOTIFY contentsValuesChanged)

    Q_PROPERTY(QVariantList resources READ resources WRITE setResources NOTIFY resourcesChanged)
    Q_PROPERTY(QVariantList references READ references WRITE setReferences NOTIFY referencesChanged)
    Q_PROPERTY(QVariantList activities READ activities WRITE setActivities NOTIFY activitiesChanged)
    Q_PROPERTY(QVariantList comments READ comments WRITE setComments NOTIFY commentsChanged)

public:
    explicit TeachingPlanning(QObject *parent = 0);

    Q_INVOKABLE void loadXml();

    const QString &source();
    QString xml();

    QVariantList basicData();

    QVariantList introduction();
    QVariantList objectives();

    QVariantList competenceLing();
    QVariantList competenceMat();
    QVariantList competenceTic();
    QVariantList competenceSoc();
    QVariantList competenceCult();
    QVariantList competenceLearn();
    QVariantList competenceAuto();

    QVariantList assessmentTasks();
    QVariantList assessmentCriteria();
    QVariantList assessmentInstruments();

    QVariantList contentsKnowledge();
    QVariantList contentsHabilities();
    QVariantList contentsLanguage();
    QVariantList contentsValues();

    QVariantList resources();
    QVariantList references();
    QVariantList activities();
    QVariantList comments();

    // Setters

    void setSource(const QString &);
    void setXml(const QString &);

    void setBasicData(const QVariantList &);

    void setIntroduction(const QVariantList &);
    void setObjectives(const QVariantList &);

    void setCompetenceLing(const QVariantList &);
    void setCompetenceMat(const QVariantList &);
    void setCompetenceTic(const QVariantList &);
    void setCompetenceSoc(const QVariantList &);
    void setCompetenceCult(const QVariantList &);
    void setCompetenceLearn(const QVariantList &);
    void setCompetenceAuto(const QVariantList &);

    void setAssessmentTasks(const QVariantList &);
    void setAssessmentCriteria(const QVariantList &);
    void setAssessmentInstruments(const QVariantList &);

    void setContentsKnowledge(const QVariantList &);
    void setContentsHabilities(const QVariantList &);
    void setContentsLanguage(const QVariantList &);
    void setContentsValues(const QVariantList &);

    void setResources(const QVariantList &);
    void setReferences(const QVariantList &);
    void setActivities(const QVariantList &);
    void setComments(const QVariantList &);

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
};

#endif // TEACHINGPLANNING_H
