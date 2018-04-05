import QtQuick 2.7
import PersonalTypes 1.0

SqlTableModel {
    id: model

    tableName: 'space_items'
    fieldNames: [
        'caption',
        'qmlPage',
        'pageProperties',
        'itemIndex',
        'itemX',
        'itemY',
        'itemWidth',
        'itemHeight'
    ]
    primaryKey: 'caption'

    creationString: 'caption TEXT PRIMARY KEY ON CONFLICT IGNORE, qmlPage TEXT, pageProperties TEXT, itemIndex INTEGER, itemX INTEGER, itemY INTEGER, itemWidth INTEGER, itemHeight INTEGER'
    initStatements: [
        //"DROP TABLE IF EXISTS " + tableName,
        "DROP TRIGGER IF EXISTS reorder_space_items",
        "CREATE TRIGGER IF NOT EXISTS reorder_space_items
         AFTER UPDATE OF itemIndex ON " + tableName + " FOR EACH ROW
         BEGIN
             UPDATE " + tableName + " SET itemIndex=itemIndex-1 WHERE caption IN (
                 SELECT caption FROM " + tableName + " WHERE caption != NEW.caption AND itemIndex > OLD.itemIndex
             );
         END",

        "DROP TRIGGER IF EXISTS add_space_number",
        "CREATE TRIGGER IF NOT EXISTS add_space_number
             BEFORE INSERT ON " + tableName + " FOR EACH ROW
             WHEN EXISTS (SELECT caption FROM " + tableName + " WHERE caption=NEW.caption)
             BEGIN
                 INSERT INTO " + tableName + "(
                     caption, qmlPage, pageProperties, itemIndex, itemX, itemY, itemWidth, itemHeight)
                 SELECT
                     NEW.caption || '(' || (COUNT(caption)+1) || ')',
                     NEW.qmlPage, NEW.pageProperties, NEW.itemIndex, NEW.itemX, NEW.itemY, NEW.itemWidth, NEW.itemHeight
                     FROM " + tableName + " WHERE SUBSTR(caption,1,LENGTH(NEW.caption))=NEW.caption;
             END"
    ]
}
