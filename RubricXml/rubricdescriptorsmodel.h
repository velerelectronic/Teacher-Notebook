#ifndef RUBRICDESCRIPTORSMODEL_H
#define RUBRICDESCRIPTORSMODEL_H

#include <QAbstractListModel>
#include <QDomElement>
#include <QMetaType>

#include "RubricXml/rubriccriteria.h"

class RubricDescriptorsModel: public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum DescriptorRoles {
        Identifier = Qt::UserRole + 1,
        Title = Qt::UserRole + 2,
        Description = Qt::UserRole + 3,
        Level = Qt::UserRole + 4,
        Definition = Qt::UserRole + 5,
        Score = Qt::UserRole + 6
    };

    explicit RubricDescriptorsModel(QAbstractListModel *parent = 0);
    RubricDescriptorsModel(const RubricDescriptorsModel &original);
    ~RubricDescriptorsModel();

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
    Q_INVOKABLE QVariantMap get(int index);
    void                    setDomRoot(QDomElement domroot);

    Q_INVOKABLE bool        append(QVariantMap values);

signals:
    int     countChanged();

private:
    QString         fieldNameForRole(int role) const;

    QDomElement             innerCriteriumDomRoot;
    QHash<int, QByteArray>  innerRoles;
};

Q_DECLARE_METATYPE(RubricDescriptorsModel)

#endif // RUBRICDESCRIPTORSMODEL_H
