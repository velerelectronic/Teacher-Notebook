#ifndef RUBRICXML_H
#define RUBRICXML_H

#include <QObject>
#include <QDomDocument>
#include <QDomElement>
#include <QVariantList>
#include <QVariantMap>
#include <QAbstractListModel>

#include "RubricXml/rubriccriteria.h"
#include "RubricXml/rubricpopulationmodel.h"
#include "RubricXml/rubricassessmentmodel.h"

class RubricCriteria;

class RubricAssessmentModel;

class RubricXml : public QObject
{
    Q_OBJECT

    Q_PROPERTY(RubricCriteria* criteria READ criteria NOTIFY criteriaChanged)
    Q_PROPERTY(RubricPopulationModel* population READ population NOTIFY populationChanged)
    Q_PROPERTY(RubricAssessmentModel* assessment READ assessment NOTIFY assessmentChanged)

    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString xml READ xml WRITE setXml NOTIFY xmlChanged)

    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)

public:

    explicit RubricXml(QObject *parent = 0);

    Q_INVOKABLE void    createEmptyRubric();
    Q_INVOKABLE QVariantList getDescriptors(int criterium);
    Q_INVOKABLE void loadXml();
    Q_INVOKABLE bool saveXmlIntoFile();
    Q_INVOKABLE void setDescriptors(const QVariantList &map);

    // Getters
    RubricAssessmentModel   *assessment();
    RubricCriteria          *criteria();
    RubricPopulationModel   *population();

    QString                 description();
    QString                 source();
    QString                 title();
    QString                 xml();

    // Setters
    void    setDescription(QString description);
    void    setSource(QString source);
    void    setTitle(QString title);
    void    setXml(QString xml);

signals:
    void    assessmentChanged();
    void    criteriaChanged();
    void    descriptionChanged();
    void    populationChanged();
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
    RubricPopulationModel  *innerPopulationModel;
    QString                 innerSource;
    QString                 innerVersion = "1.0";
};

#endif // RUBRICXML_H
