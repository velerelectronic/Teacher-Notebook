#include <QAbstractListModel>
#include <QList>
#include <MarkDownItem/markdownitem.h>
#include "MarkDownParser/markdownparser.h"

#ifndef MARKDOWNITEMMODEL_H
#define MARKDOWNITEMMODEL_H

class MarkDownItemModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum MarkDownRoles {
        TypeRole = Qt::UserRole + 1,
        TextRole = Qt::UserRole + 2
    };

    MarkDownItemModel(QObject *parent = 0);

    Q_INVOKABLE int parseMarkDown(QString text);

protected:
    QVariant                data(const QModelIndex &index, int role) const;
    Qt::ItemFlags           flags(const QModelIndex &index) const;
    QHash<int,QByteArray>   roleNames() const;
    int                     rowCount(const QModelIndex &parent = QModelIndex()) const;
    bool                    setData(const QModelIndex &index, const QVariant &value, int role);

private:
    QList<MarkDownItem> innerItems;
    MarkDownParser      mdParser;
};

#endif // MARKDOWNITEMMODEL_H
