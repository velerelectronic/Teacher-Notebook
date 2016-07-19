#ifndef RUBRICASSESSMENTMODEL_H
#define RUBRICASSESSMENTMODEL_H

#include <QAbstractListModel>
#include <QDomElement>
#include <QMetaType>

#include "RubricXml/rubriccriteria.h"

class RubricXml;

class RubricAssessmentModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString periodStart READ periodStart WRITE setPeriodStart NOTIFY periodStartChanged)
    Q_PROPERTY(QString periodEnd READ periodEnd WRITE setPeriodEnd NOTIFY periodEndChanged)

public:
    enum DescriptorRoles {
        Criterium = Qt::UserRole + 1,
        Individual = Qt::UserRole + 2,
        Descriptor = Qt::UserRole + 3,
        Comment = Qt::UserRole + 4,
        Time = Qt::UserRole + 5
    };

    explicit RubricAssessmentModel(RubricXml *parent = 0);
    RubricAssessmentModel(const RubricAssessmentModel &original);
    ~RubricAssessmentModel();

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
    QString                 periodEnd();
    QString                 periodStart();
    void                    setDomRoot(QDomElement domroot);
    void                    setPeriodEnd(QString end);
    void                    setPeriodStart(QString start);

signals:
    void    countChanged();
    void    periodEndChanged();
    void    periodStartChanged();

public slots:
    void    processXmlChanges();

private:
    QDomElement             innerAssessmentDomRoot;
    QHash<int, QByteArray>  innerRoles;
};

Q_DECLARE_METATYPE(RubricAssessmentModel)


#endif // RUBRICASSESSMENTMODEL_H
