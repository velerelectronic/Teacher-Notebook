#include <QObject>
#include <QDomDocument>
#include <QVariantList>
#include <QStringListModel>
#include <QAbstractListModel>

#ifndef XMLMODEL_H
#define XMLMODEL_H

class XmlModel : public QAbstractListModel
{
    Q_OBJECT

public:
    int RolesNumber = 0;

    explicit XmlModel(QObject *parent = 0);

    XmlModel(const XmlModel &original);
    ~XmlModel();

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString tagName READ tagName NOTIFY tagNameChanged)
    Q_PROPERTY(QStringList roles READ roles WRITE setRoles NOTIFY rolesChanged)

    // Redefine superclass
    QVariant                data(const QModelIndex &index, int role) const;
    Qt::ItemFlags           flags(const QModelIndex &index) const;
    bool                    insertRows(int row, int count, const QModelIndex &parent = QModelIndex());
    bool                    removeRows(int row, int count, const QModelIndex &parent = QModelIndex());
    QHash<int, QByteArray>  roleNames() const;
    int                     rowCount(const QModelIndex &parent = QModelIndex()) const;
    bool                    setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role);
    bool                    setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole);

    // Specific of this new class
    Q_INVOKABLE bool        append(QVariantMap values);
    int                     count();
    Q_INVOKABLE QVariantMap get(int index);
    QStringList             roles();
    void                    setRoles(QStringList roles);
    void                    setRootElement(const QDomElement &);
    void                    setTagName(const QString &tagName);
    const QString           &tagName();


signals:
    void countChanged();
    void updated();
    void rolesChanged();
    void tagNameChanged(const QString &);

    // Invokable from QML
//    Q_INVOKABLE bool insertObject(int index,const QString &contents);
//    Q_INVOKABLE bool removeObject(int index);
//    Q_INVOKABLE bool updateObject(int index,const QString &contents);


private:
    QString                 innerTagName;
    QHash<int, QByteArray>  innerRoles;
    QDomElement             innerRootElement;

};


// Q_DECLARE_METATYPE(XmlModel)

#endif // XMLMODEL_H
