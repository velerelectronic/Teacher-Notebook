#ifndef MARKDOWNPARSER_H
#define MARKDOWNPARSER_H

#include <QObject>
#include <QString>
#include <QChar>
#include "MarkDownItem/markdownitem.h"

class MarkDownParser : public QObject
{
    Q_OBJECT
public:
    explicit MarkDownParser(QObject *parent = 0);

    enum MarkDownTypes {
        Whole = 0,
        Text = 1,
        Paragraph = 2,
        Link = 3,
        Enumeration = 4,
        List = 5,
        Heading = 6,
        Bold = 7,
        Italics = 8,
        BoldAndItalics = 9,
        Underline = 10,
        CheckList = 11,
        Other = 50
    };

signals:

public slots:
    Q_INVOKABLE QStringList getParagraphs();
    Q_INVOKABLE QString toHtml(QString text);

public:
    MarkDownItem parseSingleToken(QString text, int &relativePos);

private:
    QChar nextChar;
    QString interText;

    QString parseToken(QRegExp suffix);
    QString parseTokenAlt(QString suffix, int relativePos = 0);
    QString parseAsParagraph(QString text);


    bool getNextChar();
    /*
    QString parseParagrah();
    QString parseWord();
    QString parseEmphasis();
    QString parseHeading();
    QString parseLink();
    */
};

#endif // MARKDOWNPARSER_H
