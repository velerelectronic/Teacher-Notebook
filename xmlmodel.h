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
    XmlModel(const XmlModel &);
    XmlModel &operator= (const XmlModel &);
    ~XmlModel();

    Q_PROPERTY(QString source
               READ source
               WRITE setSource
               NOTIFY sourceChanged)

    Q_PROPERTY(QString tagName
               READ tagName
               WRITE setTagName
               NOTIFY tagNameChanged)

    Q_PROPERTY(QVariantList list
               READ list
               WRITE setList
               NOTIFY listChanged)

    QString source();
    QString tagName();
    const QVariantList &list();
    void setRootElement(const QDomElement &);

signals:
    void sourceChanged(QString);
    void tagNameChanged(QString);
    void listChanged(QVariantList);

public slots:
    void setSource(const QString &);
    void setTagName(const QString &);
    void setList(const QVariantList &);

private:
    QString innerSource;
    QString innerTagName;
    QVariantList innerList;
    QDomElement rootElement;

    void recalculateList();

};

#endif // XMLMODEL_H
