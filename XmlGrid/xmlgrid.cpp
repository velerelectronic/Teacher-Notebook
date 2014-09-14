#include "xmlgrid.h"


XmlGrid::XmlGrid(QObject *parent) :
    QObject(parent)
{
}

bool XmlGrid::addValues(const QVariantMap &values) {

}

bool XmlGrid::addVariable(const QString &variable) {

}

XmlModel *XmlGrid::records() {

}

void XmlGrid::setSource(const QString &source) {
    innerSource = source;
    if (innerSource.startsWith("file://"))
        innerSource.remove(0,7);
    //loadXml();
    emit sourceChanged();
}

void XmlGrid::setXml(const QString &xml) {
    document.setContent(xml);
    QDomNodeList domlist = document.elementsByTagName("grid");
    planningRoot = domlist.item(0).toElement();
    emit xmlChanged();

    emit variablesChanged();
    emit recordsChanged();
}

const QString &XmlGrid::source() {
    return innerSource;
}

XmlModel *XmlGrid::variables() {

}

QString XmlGrid::xml() {
    return QString(document.toString());
}
