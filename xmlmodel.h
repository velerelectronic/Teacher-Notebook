#ifndef XMLMODEL_H
#define XMLMODEL_H

#include <QObject>
#include <QXmlQuery>

class XmlModel : public QObject
{
    Q_OBJECT
public:
    explicit XmlModel(QObject *parent = 0);

    Q_PROPERTY(QString source
               READ source
               WRITE setSource
               NOTIFY sourceChanged)

    Q_PROPERTY(QString tagName
               READ tagName
               WRITE setTagName
               NOTIFY tagNameChanged)

    Q_PROPERTY(QStringList list
               READ list
               WRITE setList
               NOTIFY listChanged)

    QString source();
    QString tagName();
    QStringList list();

signals:
    void sourceChanged(QString);
    void tagNameChanged(QString);
    void listChanged(QStringList);

public slots:
    void setSource(QString &);
    void setTagName(QString &);
    void setList(QStringList &);

private:
    QString innerSource;
    QString innerTagName;
    QXmlQuery xmlQuery;
    QStringList innerList;

    void recalculateList();
};

#endif // XMLMODEL_H
