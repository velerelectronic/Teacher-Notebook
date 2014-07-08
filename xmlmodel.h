#include <QObject>
#include <QDomDocument>
#include <QVariantList>

#ifndef XMLMODEL_H
#define XMLMODEL_H

class XmlModel : public QObject
{
    Q_OBJECT

public:
    explicit XmlModel(QObject *parent = 0);
    explicit XmlModel(QObject *parent, const QDomElement &, const QString &tagname);
    XmlModel(const XmlModel &);
    XmlModel operator= (const XmlModel &);

    Q_PROPERTY(QString tagName READ tagName NOTIFY tagNameChanged)

    Q_PROPERTY(QVariantList list READ list WRITE setList NOTIFY listChanged)

    const QString &tagName();
    const QVariantList &list();
    void setRootElement(const QDomElement &);

    void recalculateList();

signals:
    void tagNameChanged(QString);
    void listChanged(QVariantList);

public slots:
    void setTagName(const QString &);
    void setList(const QVariantList &);

private:
    QString innerTagName;
    QDomElement rootElement;
    QVariantList innerList;

};

#endif // XMLMODEL_H
