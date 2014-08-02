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
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    int count();
    XmlModel &operator=(XmlModel &);
    void print();
    const QString &tagName();
    void recalculateList();

    void setRootElement(const QDomElement &);

signals:
    void countChanged();
    void tagNameChanged(const QString &);
    void updated();

public slots:
    void setTagName(const QString &tagName);
    XmlModel *readList(const QDomElement &, const QString &tagname);
    bool toDomElement();

    // Invokable from QML
    Q_INVOKABLE bool insertObject(int index,const QString &contents);
    Q_INVOKABLE bool updateObject(int index,const QString &contents);

private:
    QString innerTagName;
    QDomElement rootElement;

    void recalculateDomElement();

};

// Q_DECLARE_METATYPE(XmlModel)

#endif // XMLMODEL_H
