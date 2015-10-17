#ifndef XMLGRID_H
#define XMLGRID_H

#include <QObject>
#include <QVariantMap>
#include "xmlmodel.h"

class XmlGrid : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString xml READ xml WRITE setXml NOTIFY xmlChanged)
    Q_PROPERTY(XmlModel* variables READ variables NOTIFY variablesChanged)
    Q_PROPERTY(XmlModel* records READ records NOTIFY recordsChanged)

public:
    explicit XmlGrid(QObject *parent = 0);

    bool addVariable(const QString &variable);
    bool addValues(const QVariantMap &values);

    // Getters

    const QString &source();
    QString xml();

    XmlModel *records();
    XmlModel *variables();

    // Setters

    void setSource(const QString &);
    void setXml(const QString &);

signals:
    void sourceChanged();
    void xmlChanged();
    void recordsChanged();
    void variablesChanged();

public slots:

private:
    QString innerSource;
    QDomDocument document;
    QDomElement planningRoot;

    // Models
    XmlModel modelVariables;
    XmlModel modelRecords;
};

#endif // XMLGRID_H
