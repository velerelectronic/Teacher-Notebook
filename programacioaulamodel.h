#include <QObject>
#include <QVariantList>
#include "xmlmodel.h"

#ifndef PROGRAMACIOAULAMODEL_H
#define PROGRAMACIOAULAMODEL_H

#define TAG_OBJECTIVES QString("objectives")
#define TAG_SINGLE_OBJECTIVE QString("objective")

class ProgramacioAulaModel : public QObject
{
    Q_OBJECT
public:
    explicit ProgramacioAulaModel(QObject *parent = 0);

    Q_PROPERTY(QString source
               READ source
               WRITE setSource
               NOTIFY sourceChanged)

    Q_PROPERTY(QString xml
               READ xml)

    Q_PROPERTY(QVariantList basicData
               READ basicData)

    Q_PROPERTY(QString introduction
               READ introduction
               //WRITE setIntroduction
               NOTIFY introductionChanged)

    Q_PROPERTY(XmlModel objectives
               READ objectives
               WRITE setObjectives
               NOTIFY objectivesChanged)

    Q_PROPERTY(QVariantList competences
               READ competences
               //WRITE setCompetences
               NOTIFY competencesChanged)

    Q_PROPERTY(QVariantList competenceLing
               READ competenceLing
               //WRITE setCompetenceLing
               NOTIFY competenceLingChanged)

    Q_PROPERTY(QVariantList competenceMat
               READ competenceMat
               //WRITE setCompetenceMat
               NOTIFY competenceMatChanged)

    Q_PROPERTY(QVariantList competenceTic
               READ competenceTic
               //WRITE setCompetenceTic
               NOTIFY competenceTicChanged)

    Q_PROPERTY(QVariantList competenceSoc
               READ competenceSoc
               //WRITE setCompetenceSoc
               NOTIFY competenceSocChanged)

    Q_PROPERTY(QVariantList competenceCult
               READ competenceCult
               //WRITE setCompetenceCult
               NOTIFY competenceCultChanged)

    Q_PROPERTY(QVariantList competenceLearn
               READ competenceLearn
               //WRITE setCompetenceLearn
               NOTIFY competenceLearnChanged)

    Q_PROPERTY(QVariantList competenceAuto
               READ competenceAuto
               //WRITE setCompetenceAuto
               NOTIFY competenceAutoChanged)

    Q_PROPERTY(QVariantList assessmentTasks
               READ assessmentTasks
               //WRITE setAssessmentTasks
               NOTIFY assessmentTasksChanged)

    Q_PROPERTY(QVariantList assessmentCriteria
               READ assessmentCriteria
               //WRITE setAssessmentCriteria
               NOTIFY assessmentCriteriaChanged)

    Q_PROPERTY(QVariantList assessmentInstruments
               READ assessmentInstruments
               //WRITE setAssessmentInstruments
               NOTIFY assessmentInstrumentsChanged)

    Q_PROPERTY(QVariantList contentsKnowledge
               READ contentsKnowledge
               //WRITE setContentsKnowledge
               NOTIFY contentsKnowledgeChanged)

    Q_PROPERTY(QVariantList contentsHabilities
               READ contentsHabilities
               //WRITE setContentsHabilities
               NOTIFY contentsHabilitiesChanged)

    Q_PROPERTY(QVariantList contentsLanguage
               READ contentsLanguage
               //WRITE setContentsLanguage
               NOTIFY contentsLanguageChanged)

    Q_PROPERTY(QVariantList contentsValues
               READ contentsValues
               //WRITE setContentsValues
               NOTIFY contentsValuesChanged)

    Q_PROPERTY(QVariantList resources
               READ resources
               //WRITE setResources
               NOTIFY resourcesChanged)

    Q_PROPERTY(QVariantList references
               READ references
               //WRITE setReferences
               NOTIFY referencesChanged)

    Q_PROPERTY(QVariantList activities
               READ activities
               //WRITE setActivities
               NOTIFY activitiesChanged)

    Q_PROPERTY(QString comments
               READ comments
               //WRITE setComments
               NOTIFY commentsChanged)

    Q_INVOKABLE void loadXML();

    QString source();
    QString xml();
    QVariantList basicData();
    QString introduction();
    XmlModel objectives();
    QVariantList competences();

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
    QString comments();

signals:
    void sourceChanged(const QString &source);
    void error(const QString &msg);
    void introductionChanged(const QString &introduction);
    void objectivesChanged(const XmlModel &);

    void competencesChanged(const QVariantList &);
    void competenceLingChanged(const QVariantList &);
    void competenceMatChanged(const QVariantList &);
    void competenceTicChanged(const QVariantList &);
    void competenceSocChanged(const QVariantList &);
    void competenceCultChanged(const QVariantList &);
    void competenceLearnChanged(const QVariantList &);
    void competenceAutoChanged(const QVariantList &);

    void assessmentTasksChanged(const QVariantList &);
    void assessmentCriteriaChanged(const QVariantList &);
    void assessmentInstrumentsChanged(const QVariantList &);
    void contentsKnowledgeChanged(const QVariantList &);
    void contentsHabilitiesChanged(const QVariantList &);
    void contentsLanguageChanged(const QVariantList &);
    void contentsValuesChanged(const QVariantList &);
    void resourcesChanged(const QVariantList &);
    void referencesChanged(const QVariantList &);
    void activitiesChanged(const QVariantList &);
    void commentsChanged(const QString &);

public slots:
    void setSource(const QString &);

    void setIntroduction(QString &);
    void setObjectives(const XmlModel &);

    QString printHtml();

private:
    QString msource;
    QDomDocument document;
    QDomElement planningRoot;

};

#endif // PROGRAMACIOAULAMODEL_H
