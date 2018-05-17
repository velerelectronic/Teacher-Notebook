#include <QStringList>
#include <QObject>

#ifndef MARKDOWNITEM_H
#define MARKDOWNITEM_H


class MarkDownItem : public QObject
{
    Q_OBJECT

    // A mark down item must contain:
    // * The original text
    // * The item type
    // * And all subtexts, not processed

public:
    MarkDownItem();
    MarkDownItem(QString text, int type);
    MarkDownItem(const MarkDownItem &item);

    MarkDownItem operator =(const MarkDownItem &item);

    Q_PROPERTY(int Body READ BodyCode NOTIFY BodyChanged)
    Q_PROPERTY(int CheckList READ CheckListCode NOTIFY CheckListChanged)
    Q_PROPERTY(int Heading READ HeadingCode NOTIFY HeadingChanged)
    Q_PROPERTY(int Link READ LinkCode NOTIFY LinkChanged)
    Q_PROPERTY(int Paragraph READ ParagraphCode NOTIFY ParagraphChanged)
    Q_PROPERTY(int Text READ TextCode NOTIFY TextChanged)
    Q_PROPERTY(int Table READ TableCode NOTIFY TableChanged)
    Q_PROPERTY(int WholeWord READ WholeWordCode NOTIFY WholeWordChanged)

    typedef enum MarkDownItemTypes {
        Body        = Qt::UserRole,
        Paragraph   = Qt::UserRole + 1,
        Table       = Qt::UserRole + 2,
        Text        = Qt::UserRole + 3,
        WholeWord   = Qt::UserRole + 4,
        Link        = Qt::UserRole + 5,
        Enumeration = Qt::UserRole + 6,
        List        = Qt::UserRole + 7,
        Heading     = Qt::UserRole + 8,
        Bold        = Qt::UserRole + 9,
        Italics     = Qt::UserRole + 10,
        BoldAndItalics = Qt::UserRole + 11,
        Underline   = Qt::UserRole + 12,
        CheckList   = Qt::UserRole + 13,
        Other       = Qt::UserRole + 50

    } mdtypes;

    int     BodyCode() { return MarkDownItemTypes::Body; }
    int     CheckListCode() { return MarkDownItemTypes::CheckList; }
    int     HeadingCode() { return MarkDownItemTypes::Heading; }
    int     LinkCode() { return MarkDownItemTypes::Link; }
    int     ParagraphCode() { return MarkDownItemTypes::Paragraph; }
    int     TextCode() { return MarkDownItemTypes::Text; }
    int     TableCode() { return MarkDownItemTypes::Table; }
    int     WholeWordCode() { return MarkDownItemTypes::WholeWord; }

    QStringList getParameters() const;
    QString     getText() const;
    int         getType() const;

    void        appendSubText(QString text);
    void        clearSubTexts();
    void        setText(QString text);
    void        setType(int type);

signals:
    void    BodyChanged();
    void    CheckListChanged();
    void    HeadingChanged();
    void    LinkChanged();
    void    ParagraphChanged();
    void    TableChanged();
    void    TextChanged();
    void    WholeWordChanged();

protected:
    QString         innerText;
    int             innerType;
    QStringList     subTexts;
};

#endif // MARKDOWNITEM_H
