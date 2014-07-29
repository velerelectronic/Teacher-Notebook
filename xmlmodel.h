#include <QObject>
#include <QDomDocument>
#include <QVariantList>
#include <QStringListModel>

#ifndef XMLMODEL_H
#define XMLMODEL_H

class XmlModel : public QStringListModel
{
    Q_OBJECT

public:
    explicit XmlModel(QObject *parent = 0);

    XmlModel(const XmlModel &);
    ~XmlModel();

    Q_PROPERTY(QString tagName READ tagName NOTIFY tagNameChanged)

    XmlModel &operator=(XmlModel &);
    void print();
    const QString &tagName();
    void recalculateList();

    void setRootElement(const QDomElement &);

signals:
    void tagNameChanged(const QString &);

public slots:
    void setTagName(const QString &tagName);
    XmlModel *readList(const QDomElement &, const QString &tagname);
    bool toDomElement(const QString &tagName);

private:
    QString innerTagName;
    QDomElement rootElement;

    void recalculateDomElement();

};

// Q_DECLARE_METATYPE(XmlModel)

#endif // XMLMODEL_H
