#ifndef RUBRICINDIVIDUALSMODEL_H
#define RUBRICINDIVIDUALSMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QDomElement>
#include <QMetaType>


class RubricIndividualsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString groupName READ groupName NOTIFY groupNameChanged)

public:
    enum DescriptorRoles {
        GroupName = Qt::UserRole + 1,
        Identifier = Qt::UserRole + 2,
        Name = Qt::UserRole + 3
    };

    explicit RubricIndividualsModel(QObject *parent = 0);
    RubricIndividualsModel(const RubricIndividualsModel &original);
    ~RubricIndividualsModel();

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
    QString                 groupName();
    void                    setDomRoot(QDomElement domroot);
    void                    setGroupName(QString name);

signals:
    void    countChanged();
    void    groupNameChanged();

public slots:

private:
    QDomElement             innerGroupDomRoot;
    QString                 innerGroupName;

};
Q_DECLARE_METATYPE(RubricIndividualsModel)


#endif // RUBRICINDIVIDUALSMODEL_H
