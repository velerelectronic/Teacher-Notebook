#ifndef RUBRICCRITERIA_H
#define RUBRICCRITERIA_H

#include <QObject>
#include <QAbstractListModel>
#include <QHash>
#include <QDomElement>

#include "RubricXml/rubricxml.h"
#include "RubricXml/rubricdescriptorsmodel.h"


class RubricXml;
class RubricDescriptorsModel;

class RubricCriteria : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count   NOTIFY countChanged)

public:
    enum CriteriumRoles {
        Title = Qt::UserRole + 1,
        Description = Qt::UserRole + 2,
        Weight = Qt::UserRole + 3,
        Order = Qt::UserRole + 4,
        Descriptors = Qt::UserRole + 5
    };

    explicit RubricCriteria(RubricXml *parent = 0);
    RubricCriteria(const RubricCriteria &original);
    ~RubricCriteria();

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
    int                     count();
    void                    setDomRoot(QDomElement domroot);

    Q_INVOKABLE bool        append(QVariantMap values);

signals:
    void     countChanged();

private:
    QString         fieldNameForRole(int role) const;

    QDomElement             innerRubricDomRoot;
    RubricXml               *innerRubricXmlParent;
};

#endif // RUBRICCRITERIA_H
