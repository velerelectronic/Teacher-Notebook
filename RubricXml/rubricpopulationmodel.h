#ifndef RUBRICPOPULATIONMODEL_H
#define RUBRICPOPULATIONMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QDomElement>
#include <QMetaType>


class RubricPopulationModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum DescriptorRoles {
        GroupName = Qt::UserRole + 1,
        Identifier = Qt::UserRole + 2,
        Name = Qt::UserRole + 3
    };

    explicit RubricPopulationModel(QObject *parent = 0);
    RubricPopulationModel(const RubricPopulationModel &original);
    ~RubricPopulationModel();

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
    void    countChanged();

public slots:

private:
    QDomElement             innerPopulationDomRoot;
    QHash<int, QByteArray>  innerRoles;

};
Q_DECLARE_METATYPE(RubricPopulationModel)


#endif // RUBRICPOPULATIONMODEL_H
