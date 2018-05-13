#include <QStringList>

#ifndef MARKDOWNITEM_H
#define MARKDOWNITEM_H


class MarkDownItem
{
    // A mark down item must contain:
    // * The original text
    // * The item type
    // * And all subtexts, not processed

public:
    MarkDownItem();
    MarkDownItem(QString text, int type);
    MarkDownItem(const MarkDownItem &item);

    MarkDownItem operator =(const MarkDownItem &item);

    typedef enum MarkDownItemTypes {
        Paragraph = Qt::UserRole + 1,
        Text = Qt::UserRole + 2,
        Table = Qt::UserRole + 3
    } mdtypes;

    QStringList getParameters() const;
    QString     getText() const;
    int         getType() const;

    void        appendSubText(QString text);
    void        clearSubTexts();
    void        setText(QString text);
    void        setType(int type);

protected:
    QString         innerText;
    int             innerType;
    QStringList     subTexts;
};

#endif // MARKDOWNITEM_H
