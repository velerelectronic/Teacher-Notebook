#include "markdownitem.h"

MarkDownItem::MarkDownItem() {

}

MarkDownItem::MarkDownItem(QString text, int type)
{
    innerText = text;
    innerType = type;
    subTexts.clear();
}

MarkDownItem::MarkDownItem(const MarkDownItem &item) {
    innerText = item.innerText;
    innerType = item.innerType;
    subTexts = item.subTexts; // Revise if this is a deep copy
}

void MarkDownItem::appendSubText(QString text) {
    subTexts.append(text);
}

void MarkDownItem::clearSubTexts() {
    subTexts.clear();
}

QStringList MarkDownItem::getParameters() const {
    return subTexts;
}

QString MarkDownItem::getText() const {
    return innerText;
}

int MarkDownItem::getType() const {
    return innerType;
}

MarkDownItem MarkDownItem::operator =(const MarkDownItem &item) {
    innerText = item.innerText;
    innerType = item.innerType;
    subTexts = item.subTexts; // Revise if this is a deep copy;
    return *this;
}

void MarkDownItem::setText(QString text) {
    innerText = text;
}

void MarkDownItem::setType(int type) {
    innerType = type;
}
