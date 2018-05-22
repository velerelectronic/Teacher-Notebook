#include "markdownparser.h"

#include <QString>
#include <QRegExp>
#include <QRegularExpression>
#include <QTextList>
#include <QTextBlock>
#include <QTextDocument>
#include <QDebug>

MarkDownParser::MarkDownParser(QObject *parent) :
    QObject(parent)
{
}

bool MarkDownParser::getNextChar() {
    if (interText.size()>0) {
        nextChar = interText.at(0);
        interText.remove(0,1);
        return true;
    } else
        return false;
}

QStringList MarkDownParser::getParagraphs() {

}

QString MarkDownParser::toHtml(QString text) {
    interText = text;
    return parseTokenAlt(text);
    if (getNextChar())
        return "<p>" + parseToken(QRegExp("$")) + "</p>";
    else
        return "";
}

void MarkDownParser::parseIntoCursor(const QString &text, QTextCursor &cursor) {
    QString enumString("(?:\\d+\\.\\s+)((?:[^\\n]|(?:\\n[^\\n]))+)(?:\\n\\n|\\n$|$)");

    QRegularExpression rx(QString("(\\n*#\\s+([^\\n\\n]+)\\n{2,})")
               + "|(\\*\\s+(?:((?:[^\\n]|\\n[^\\n])+)(?:\\n{2,}|\\n$|$)))"
               + "|((?:" + "(?:\\d+\\.\\s+)(?:(?:[^\\n]|(?:\\n[^\\n]))+)(?:\\n\\n|\\n$|$)" + ")+)"
               + "|(((?:\\n[^\\n]|[^\\n])+)\\n{2,})"
               + "|(\\*{3}([^\\*]+)\\*{3})"
               + "|(\\*{2}([^\\*]+)\\*{2})"
               + "|(\\*([^\\*]+)\\*)"
               + "|(_{2}([^__]+)_{2})"
               + "|(\\[(x?|\\s)\\]\\s+((?:.|.\\n)*)(\\n\\n|\\n$|$))"
               + "|(\\[\\[([^\\]]+)\\|(.+)\\]\\])"
               + "|(\\[\\[([^\\]]+)\\]\\])"
               + "|(\\[([^\\]\\s]+)((?:\\s+)([^\\]]+))?\\])"
//               + "|((.+)(?:\\n\\n|\\n$|$))"
               );

    int relativePos = 0;
    QRegularExpressionMatch match = rx.match(text, relativePos);

    while (match.hasMatch()) {
        // Insert first characters before the first match
        cursor.insertText(text.mid(relativePos, match.capturedStart() - relativePos));

        // Analyze subTexts

        QTextCharFormat prevCharFormat = cursor.charFormat();
        QTextBlockFormat prevBlockFormat = cursor.blockFormat();

        if (match.captured(1) != "") {
            // Heading (first level?)
            QTextBlockFormat blockFormat;
            blockFormat.setTopMargin(20);
            QTextCharFormat charFormat;

            charFormat.setFontWeight(QFont::ExtraBold);
            charFormat.setFontPointSize(20);

            cursor.insertBlock(blockFormat, charFormat);
            parseIntoCursor(match.captured(2), cursor);
            blockFormat.setTopMargin(10);
            blockFormat.setBottomMargin(10);
            cursor.insertBlock(blockFormat);
        }

        if (match.captured(3) != "") {
            // List
            // We need to parse list items

            QTextListFormat listFormat;
            cursor.beginEditBlock();
            listFormat.setStyle(QTextListFormat::ListCircle);

            cursor.insertList(listFormat);
            //cursor.insertText(match.captured(4));
            parseIntoCursor(match.captured(4), cursor);
            cursor.insertBlock();
            QTextBlockFormat paragraphFormat;
            paragraphFormat.setTopMargin(10);
            paragraphFormat.setBottomMargin(10);
            cursor.mergeBlockFormat(paragraphFormat);

            cursor.endEditBlock();

            qDebug() << "LIST" << match.captured(4);
        }

        if (match.captured(5) != "") {
            // Enumeration
            // We need to parse list items

            qDebug() << "ENUM ALL" << match.captured(5);

            cursor.beginEditBlock();
            QTextListFormat enumerationFormat;
            enumerationFormat.setStyle(QTextListFormat::ListDecimal);
            cursor.insertList(enumerationFormat);
            QTextBlockFormat paragraphFormat;
            paragraphFormat.setTopMargin(10);
            paragraphFormat.setBottomMargin(10);

            QRegularExpression enumList(enumString);
            QRegularExpressionMatchIterator enumIterator = enumList.globalMatch(match.captured(5));
            while (enumIterator.hasNext()) {
                QRegularExpressionMatch enumMatch = enumIterator.next();
                parseIntoCursor(enumMatch.captured(1), cursor);
                qDebug() << "ENUM ITEM" << enumMatch.captured(1);
                cursor.insertBlock();
                cursor.mergeBlockFormat(paragraphFormat);
            }
            cursor.endEditBlock();
            //cursor.movePosition(QTextCursor::NextBlock);

        }

        if (match.captured(6) != "") {
            // Paragraph

            QTextBlockFormat paragraphFormat;
            paragraphFormat.setTopMargin(10);
            paragraphFormat.setBottomMargin(10);

            cursor.insertBlock();
            cursor.mergeBlockFormat(paragraphFormat);

            //subCursor.movePosition(QTextCursor::NextBlock);
            parseIntoCursor(match.captured(7), cursor);
        }

        if (match.captured(8) != "") {
            // Bold and italics

            QTextCharFormat charFormat;
            charFormat.setFontWeight(QFont::Bold);
            charFormat.setFontItalic(true);
            cursor.mergeCharFormat(charFormat);
            parseIntoCursor(match.captured(9), cursor);
        }

        if (match.captured(10) != "") {
            // Bold
            QTextCharFormat charFormat;
            charFormat.setFontWeight(QFont::Bold);
            cursor.mergeCharFormat(charFormat);
            parseIntoCursor(match.captured(11), cursor);
        }

        if (match.captured(12) != "") {
            // Italics
            QTextCharFormat charFormat;
            charFormat.setFontItalic(true);
            cursor.mergeCharFormat(charFormat);
            parseIntoCursor(match.captured(13), cursor);
        }

        if (match.captured(14) != "") {
            // Underline
            QTextCharFormat charFormat;
            charFormat.setFontUnderline(true);
            cursor.mergeCharFormat(charFormat);
            parseIntoCursor(match.captured(15), cursor);
        }


        if (match.captured(16) != "") {
            // Checklist
            cursor.insertText(match.captured(16));

            /*
            item.setText(match.captured(17));
            item.setType(MarkDownItem::CheckList);
            item.appendSubText(match.captured(18));
            item.appendSubText(match.captured(19));
            item.appendSubText(match.captured(20));
            */
        }

        if (match.captured(20) != "") {
            // Link
            QTextCharFormat format;
            format.setAnchorHref(match.captured(21));
            format.setForeground(QBrush(QColor(0,0,255)));
            format.setUnderlineColor(QColor(0,0,255));
            format.setFontUnderline(true);
            cursor.setCharFormat(format);
            cursor.insertText(match.captured(22));
        }

        if (match.captured(23) != "") {
            // Link

            QTextCharFormat format;
            format.setAnchorHref(match.captured(24));
            format.setForeground(QBrush(QColor(0,0,255)));
            format.setUnderlineColor(QColor(0,0,255));
            format.setFontUnderline(true);
            cursor.setCharFormat(format);
            cursor.insertText(match.captured(24));

        }

        if (match.captured(25) != "") {
            // Link
            //cursor.insertText(match.captured(25));

            QTextCharFormat format;
            format.setAnchorHref(match.captured(26));
            format.setForeground(QBrush(QColor(0,0,255)));
            format.setUnderlineColor(QColor(0,0,255));
            format.setFontUnderline(true);
            cursor.setCharFormat(format);
            if (match.captured(27) != "")
                parseIntoCursor(match.captured(28), cursor);
            else
                cursor.insertText(match.captured(26));
        }


        cursor.setCharFormat(prevCharFormat);
        cursor.setBlockFormat(prevBlockFormat);

        relativePos = match.capturedEnd();
        match = rx.match(text, relativePos);
    }
    // Insert last text after the last match
    if (relativePos < text.length())
        cursor.insertText(text.mid(relativePos));
}

QString MarkDownParser::parseTokenAlt(QString infix, int relativePos) {
    QString output = "";

    QRegularExpression rx(QString("(\\n*#\\s+([^\\n\\n]+)\\n{2,})")
               + "|(\\*\\s+((?:[^\\n]|\\n[^\\n])+(?:\\n{2,}|\\n$|$)))"
               + "|((?:\\d+\\.\\s+(?:[^\\n]|(?:[^\\n]\\n))+(?:\\n\\n|\\n$|$))+)"
               + "|(((?:\\n[^\\n]|[^\\n])+)\\n{2,})"
               + "|(\\*{3}([^\\*]+)\\*{3})"
               + "|(\\*{2}([^\\*]+)\\*{2})"
               + "|(\\*([^\\*]+)\\*)"
               + "|(_{2}([^_]+)_{2})"
               + "|(\\[(x?|\\s)\\]\\s+((?:.|.\\n)*)(\\n\\n|\\n$|$))"
               + "|(\\[\\[([^\\]]+)\\|(.+)\\]\\])"
               + "|(\\[\\[([^\\]]+)\\]\\])"
               + "|(\\[([^\\]\\s]+)((?:\\s+)([^\\]]+))?\\])"
//               + "|((.+)(?:\\n\\n|\\n$|$))"
               );

    QRegularExpression innerNumbering("\\d+\\.\\s+((?:[^\\n]|(?:[^\\n]\\n))+)(?:\\n\\n|\\n$|$)");

    int pos = 0;

    while (pos < infix.length()) {
        QRegularExpressionMatch match = rx.match(infix, pos);

        if (match.capturedStart()>-1) {
            output += infix.mid(pos, match.capturedStart()-pos);

            int n = 1;
            if (match.captured(n) != "") {
                output += "<h1>" + parseTokenAlt(match.captured(n+1), relativePos + match.capturedStart(n+1)) + "</h1>";
            }
            n = n + 2;
            if (match.captured(n) != "") {
                output += "<ul>";

                QRegularExpression rxsub("^\\*(?:\\s*)([^\\n]+)(?:\\n|$)");
                QRegularExpressionMatchIterator j=rxsub.globalMatch(match.captured(n));
                while (j.hasNext()) {
                    QRegularExpressionMatch submatch = j.next();
                    output += "<li>" + parseTokenAlt(submatch.captured(1), relativePos + match.capturedStart(n) + submatch.capturedStart(1)) + "</li>";
                }

                output += "</ul>";
            }
            n = n + 2;
            if (match.captured(n) != "") {
                output += "<ol>";

                QRegularExpressionMatchIterator j=innerNumbering.globalMatch(match.captured(n));
                while (j.hasNext()) {
                    QRegularExpressionMatch submatch = j.next();
                    output += "<li>" + parseTokenAlt(submatch.captured(1), relativePos + match.capturedStart(n) + submatch.capturedStart(1)) + "</li>";
                }

                output += "</ol>";
            }
            n = n+1;
            if (match.captured(n) != "") {
                output += "<p>" + parseTokenAlt(match.captured(n+1), relativePos + match.capturedStart(n+1)) + "</p><br/>";
            }
            n = n + 2;
            if (match.captured(n) != "") {
                output += "<b><i>" + parseTokenAlt(match.captured(n+1), relativePos + match.capturedStart(n+1)) + "</i></b>";
            }
            n = n + 2;
            if (match.captured(n) != "") {
                output += "<b>" + parseTokenAlt(match.captured(n+1), relativePos + match.capturedStart(n+1)) + "</b>";
            }
            n = n + 2;
            if (match.captured(n) != "") {
                output += "<i>" + parseTokenAlt(match.captured(n+1), relativePos + match.capturedStart(n+1)) + "</i>";
            }
            n = n + 2;
            if (match.captured(n) != "") {
                output += "<u>" + parseTokenAlt(match.captured(n+1), relativePos + match.capturedStart(n+1)) + "</u>";
            }
            n = n + 2;

            if (match.captured(n) != "") {
                QString optionValue = match.captured(n+1);
                QString optionText = parseTokenAlt(match.captured(n+2), match.capturedStart(n+2));
                QString optionDisplay = (optionValue == "x")?"x":"&nbsp;";
                QString pos = QString::number(relativePos + match.capturedStart(n+1)-1);
                QString len = QString::number(match.capturedLength(n) - match.capturedLength(n+3));
                output += "<a href=\"notebook://checkmark?mark=" + optionValue + "&position=" + pos + "&length=" + len + "\">[" + optionDisplay + "] " + optionText + "</a>";
            }
            n = n + 4;

            if (match.captured(n) != "") {
                output += "<a href=\"" + parseTokenAlt(match.captured(n+1), relativePos + match.capturedStart(n+1)) + "\">" + parseTokenAlt(match.captured(n+2), relativePos + match.capturedStart(n+2)) + "</a>";
            }
            n = n + 3;
            if (match.captured(n) != "") {
                QString link = parseTokenAlt(match.captured(n+1), relativePos + match.capturedStart(n+1));
                output += "<a href=\"" + link + "\">" + link + "</a>";
            }
            n = n + 2;

            if (match.captured(n) != "") {
                QString link = match.captured(n+1);
                QString text;
                if (match.captured(n+2) != "") {
                    text = parseTokenAlt(match.captured(n+3), relativePos + match.capturedStart(n+3));
                    n = n + 3;
                } else {
                    text = link;
                    n = n + 2;
                }
                output += "<a href=\"" + link + "\">" + text + "</a>";
            }

            /*
            if (match.captured(n) != "") {
                output += "<p>" + match.captured(n+1) + "</p>";
            }
            n = n + 2;
            */

            pos = match.capturedEnd();
        } else {
            output += infix.mid(pos);

            pos = infix.length();
        }
    }

    return output;
}

MarkDownItem MarkDownParser::parseSingleToken(QString text, int &relativePos) {
    // text: the main processed text string
    // relativePos: the position inside text

    QRegularExpression rx(QString("(\\n*#\\s+([^\\n\\n]+)\\n{2,})")
               + "|(\\*\\s+((?:[^\\n]|\\n[^\\n])+(?:\\n{2,}|\\n$|$)))"
               + "|((\\d+\\.\\s+(?:[^\\n]|(?:[^\\n]\\n))+(?:\\n\\n|\\n$|$))+)"
               + "|(((?:\\n[^\\n]|[^\\n])+)\\n{2,})"
               + "|(\\*{3}([^\\*]+)\\*{3})"
               + "|(\\*{2}([^\\*]+)\\*{2})"
               + "|(\\*([^\\*]+)\\*)"
               + "|(_{2}([^_]+)_{2})"
               + "|(\\[(x?|\\s)\\]\\s+((?:.|.\\n)*)(\\n\\n|\\n$|$))"
               + "|(\\[([^\\]\\s]+)((?:\\s+)([^\\]]+))?\\])"
               + "|(\\[\\[([^\\]]+)\\|(.+)\\]\\])"
               + "|(\\[\\[([^\\]]+)\\]\\])"
//               + "|((.+)(?:\\n\\n|\\n$|$))"
               );

    QRegularExpressionMatch match = rx.match(text, relativePos);

    MarkDownItem item;

    if (match.hasMatch()) {
        if (match.capturedStart() == relativePos) {
            int n = 1;
            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Heading);
                item.appendSubText(match.captured(n+1));
            }
            n = n + 2;
            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::List);
                item.appendSubText(match.captured(n+1));

                // We need to parse list items
            }
            n = n + 2;
            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Enumeration);
                item.appendSubText(match.captured(n+1));

                // We need to parse list items
            }
            n = n+2;
            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Paragraph);
                item.appendSubText(match.captured(n+1));
            }
            n = n + 2;
            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::BoldAndItalics);
                item.appendSubText(match.captured(n+1));
            }
            n = n + 2;
            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Bold);
                item.appendSubText(match.captured(n+1));
            }
            n = n + 2;
            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Heading);
                item.appendSubText(match.captured(n+1));
            }
            n = n + 2;
            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Underline);
                item.appendSubText(match.captured(n+1));
            }
            n = n + 2;

            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::CheckList);
                item.appendSubText(match.captured(n+1));
                item.appendSubText(match.captured(n+2));
                item.appendSubText(match.captured(n+3));
            }
            n = n + 4;

            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Link);
                item.appendSubText(match.captured(n+1));
                item.appendSubText(match.captured(n+2));
                QString link = match.captured(n+1);
                QString text;
                if (match.captured(n+2) != "") {
                    item.appendSubText(match.captured(n+3));
                    n = n + 3;
                } else {
                    n = n + 2;
                }
            }

            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Link);
                item.appendSubText(match.captured(n+1));
                item.appendSubText(match.captured(n+2));
            }
            n = n + 3;

            if (match.captured(n) != "") {
                item.setText(match.captured(n));
                item.setType(MarkDownItem::Link);
                item.appendSubText(match.captured(n+1));
            }
            n = n + 2;

            relativePos = match.capturedEnd();
        } else {
            relativePos = match.capturedStart();
            item.setText(text.mid(relativePos, match.capturedStart() - relativePos));
            item.setType(MarkDownItem::Text);
        }
    } else {
        relativePos = -1;
        item.setText(text.mid(relativePos));
        item.setType(MarkDownItem::Text);
    }

    return item;
}

QString MarkDownParser::parseToken(QRegExp suffix) {
    QString output = "";

    bool sameToken = true;

    while (sameToken) {
        QString partialOutput = "";
        if (suffix.indexIn(interText)==0) {
            interText.remove(0,suffix.matchedLength());
            partialOutput = nextChar;
            sameToken = false;
        } else {
            QChar prefix = nextChar;
            if ((prefix == '\n') || (prefix == '\r')) {
                if (getNextChar()) {
                    if ((nextChar == '\n') || (nextChar == '\r')) {
                        partialOutput = "</p>";
                        if (getNextChar()) {
                            if ((nextChar == ' ') || (nextChar == '\t')) {
                                if (getNextChar()) {
                                    partialOutput += "<blockquote>" + parseToken(QRegExp("(\\n|\\r)(\\n|\\r)")) + "</blockquote>";
                                    if (!getNextChar())
                                        sameToken = false;
                                } else {
                                    sameToken = false;
                                }
                            }
                            partialOutput += "<p>";
                        } else
                            sameToken = false;
                    } else {
                        partialOutput = " ";
                    }
                } else {
                    partialOutput = "";
                    sameToken = false;
                }
            } else if ((prefix==' ') || (prefix == '\t')) {
                // Remove initial spaces
                bool removing = true;
                while ((removing) && (getNextChar())) {
                    if ((nextChar!=' ') && (nextChar!='\t')) {
                        removing = false;
                    }
                }
                if (removing) {
                    sameToken = false;
                } else {
                    partialOutput = " ";
                }
            } else if (prefix == '*') {
                if (getNextChar()) {
                    if (nextChar == '*') {
                        if (getNextChar()) {
                            partialOutput = "<b>" + parseToken(QRegExp("\\*\\*")) + "</b>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            partialOutput = "**";
                            sameToken = false;
                        }
                    } else {
                        partialOutput += prefix;
                        partialOutput += nextChar;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '_') {
                if (getNextChar()) {
                    if (nextChar == '_') {
                        if (getNextChar()) {
                            partialOutput = "<u>" + parseToken(QRegExp("\\_\\_")) + "</u>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            partialOutput = "__";
                            sameToken = false;
                        }
                    } else {
                        partialOutput += prefix;
                        partialOutput += nextChar;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '@') {
                if (getNextChar()) {
                    if (nextChar == '@') {
                        if (getNextChar()) {
                            partialOutput = "<mark style=\"background-color: yellow\">" + parseToken(QRegExp("@@")) + "</mark>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            partialOutput = "@@";
                            sameToken = false;
                        }
                    } else {
                        partialOutput += prefix;
                        partialOutput += nextChar;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '#') {
                if (getNextChar()) {
                    if (nextChar == '#') {
                        if (getNextChar()) {
                            partialOutput = "<h2>" + parseToken(QRegExp("(\\n|\\r)")) + "</h2>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            partialOutput = "##";
                        }
                    } else {
                        partialOutput = "<h1>" + parseToken(QRegExp("(\\n|\\r)")) + "</h1>";
                        if (!getNextChar())
                            sameToken = false;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '[') {
                if (getNextChar()) {
                    if (nextChar == '[') {
                        if (getNextChar()) {
                            QString reference = parseToken(QRegExp("\\]\\]"));
                            partialOutput = "<a href=\"" + reference + "\">" + reference + "</a>";
                            if (!getNextChar())
                                sameToken = false;
                        } else {
                            sameToken = false;
                        }
                    } else {
                        partialOutput += prefix;
                        partialOutput += nextChar;
                    }
                } else {
                    partialOutput = prefix;
                }
            } else if (prefix == '!') {
                partialOutput = prefix;
                if (!getNextChar())
                    sameToken = false;
            } else {
                partialOutput = prefix;
                if (!getNextChar())
                    sameToken = false;
            }
        }
        output += partialOutput;
    }

    return output;
}

