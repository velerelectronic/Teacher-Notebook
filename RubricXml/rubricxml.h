#ifndef RUBRICXML_H
#define RUBRICXML_H

#include <QObject>
#include <QDomDocument>
#include <QDomElement>
#include <QVariantList>
#include <QVariantMap>
#include <QAbstractListModel>

#include "RubricXml/rubriccriteria.h"
#include "RubricXml/rubricindividualsmodel.h"
#include "RubricXml/rubricassessmentmodel.h"

class RubricCriteria;

class RubricAssessmentModel;

class RubricXml : public QObject
{
    Q_OBJECT

    Q_PROPERTY(RubricCriteria* criteria READ criteria NOTIFY criteriaChanged)
    Q_PROPERTY(RubricIndividualsModel* individuals READ individuals NOTIFY individualsChanged)
    Q_PROPERTY(RubricAssessmentModel* assessment READ assessment NOTIFY assessmentChanged)

    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString xml READ xml WRITE setXml NOTIFY xmlChanged)

    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(QString group READ group NOTIFY groupChanged)

public:

    explicit RubricXml(QObject *parent = 0);

    Q_INVOKABLE QVariantList getDescriptors(int criterium);
    Q_INVOKABLE void loadXml();
    Q_INVOKABLE void setDescriptors(const QVariantList &map);

    // Getters
    RubricAssessmentModel   *assessment();
    RubricCriteria          *criteria();
    RubricIndividualsModel  *individuals();

    const QString           &description();
    const QString           &group();
    const QString           &source();
    const QString           &title();
    const QString           &xml();

    // Setters
    void setSource(const QString &source);
    void setXml(const QString &xml);

signals:
    void    assessmentChanged();
    void    criteriaChanged();
    void    descriptionChanged();
    void    groupChanged();
    void    individualsChanged();
    void    sourceChanged();
    void    titleChanged();
    void    xmlChanged();

public:
    QDomElement     mainRubricRoot;

private:
    QVariantList    getNodesAttributesList(const QDomNodeList &list);

    QDomDocument            document;
    RubricAssessmentModel   *innerAssessmentModel;
    RubricCriteria          *innerCriteria;
    RubricIndividualsModel  *innerIndividualsModel;
    QString                 innerSource;
};

#endif // RUBRICXML_H
