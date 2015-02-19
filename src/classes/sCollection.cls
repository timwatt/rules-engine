public class sCollection {

  /*
      This class provides static methods to convert sObject lists into maps and
      sets that are keyed to any String or Id field value from that sObject.
      There are methods to accept the field argument as either a string or an
      sObjectField token.
  */

  public static map<Id, sObject> idMap(list<sObject> sObjs, sObjectField idField) {
    map<Id, sObject> idMap = new map<Id, sObject>();
    for (sObject sObj : sObjs) {
      idMap.put((Id) sObj.get(idField), sObj);
    }
    return idMap;
  }

  public static map<Id, sObject> idMap(list<sObject> sObjs, String idField) {
    map<Id, sObject> idMap = new map<Id, sObject>();
    for (sObject sObj : sObjs) {
      idMap.put((Id) sObj.get(idField), sObj);
    }
    return idMap;
  }

  public static map<String, sObject> stringMap(list<sObject> sObjs, sObjectField stringField) {
    map<String, sObject> stringMap = new map<String, sObject>();
    for (sObject sObj : sObjs) {
      stringMap.put((String) sObj.get(stringField), sObj);
    }
    return stringMap;
  }

  public static map<String, sObject> stringMap(list<sObject> sObjs, String stringField) {
    map<String, sObject> stringMap = new map<String, sObject>();
    for (sObject sObj : sObjs) {
      stringMap.put((String) String.valueOf(sObj.get(stringField)), sObj);
    }
    return stringMap;
  }

  public static map<Date, sObject> dateMap(list<sObject> sObjs, sObjectField stringField) {
    map<Date, sObject> dateMap = new map<Date, sObject>();
    for (sObject sObj : sObjs) {
      dateMap.put((Date) sObj.get(stringField), sObj);
    }
    return dateMap;
  }

  public static map<Date, sObject> dateMap(list<sObject> sObjs, String stringField) {
    map<Date, sObject> dateMap = new map<Date, sObject>();
    for (sObject sObj : sObjs) {
      dateMap.put((Date) sObj.get(stringField), sObj);
    }
    return dateMap;
  }

  public static set<String> stringSet(list<sObject> sObjs, sObjectField field) {
    set<String> fieldSet = new set<String>();
    for (sObject sObj : sObjs) {
      fieldSet.add((String) sObj.get(field));
    }
    return fieldSet;
  }

  public static set<String> stringSet(list<sObject> sObjs, String field) {
    set<String> fieldSet = new set<String>();
    for (sObject sObj : sObjs) {
      fieldSet.add((String) sObj.get(field));
    }
    return fieldSet;
  }

  public static set<Id> idSet(list<sObject> sObjs, sObjectField field) {
    set<Id> fieldSet = new set<Id>();
    for (sObject sObj : sObjs) {
      fieldSet.add((Id) sObj.get(field));
    }
    return fieldSet;
  }

  public static set<Id> idSet(list<sObject> sObjs, String field) {
    set<Id> fieldSet = new set<Id>();
    for (sObject sObj : sObjs) {
      fieldSet.add((Id) sObj.get(field));
    }
    return fieldSet;
  }

  public static map<Id, list<sObject>> idListMap (list<sObject> sObjs, sObjectField idField) {
    map<Id, list<sObject>> listMap = new map<Id, list<sObject>>();
    for (sObject sObj : sObjs) {
      Id sObjId = (Id) sObj.get(idField);
      list<sObject> temp = listMap.get(sObjId) == null ? new list<sObject>() : listMap.get(sObjId);
      temp.add(sObj);
      listMap.put(sObjId, temp);
    }
    return listMap;
  }

  public static map<Id, list<sObject>> idListMap (list<sObject> sObjs, String idField) {
    map<Id, list<sObject>> listMap = new map<Id, list<sObject>>();
    for (sObject sObj : sObjs) {
      Id sObjId = (Id) sObj.get(idField);
      list<sObject> temp = listMap.get(sObjId) == null ? new list<sObject>() : listMap.get(sObjId);
      temp.add(sObj);
      listMap.put(sObjId, temp);
    }
    return listMap;
  }

  public static map<String, list<sObject>> stringListMap (list<sObject> sObjs, sObjectField StringField) {
    map<String, list<sObject>> listMap = new map<String, list<sObject>>();
    for (sObject sObj : sObjs) {
      String sObjId = (String) sObj.get(StringField);
      list<sObject> temp = listMap.get(sObjId) == null ? new list<sObject>() : listMap.get(sObjId);
      temp.add(sObj);
      listMap.put(sObjId, temp);
    }
    return listMap;
  }

  public static map<String, list<sObject>> stringListMap (list<sObject> sObjs, String StringField) {
    map<String, list<sObject>> listMap = new map<String, list<sObject>>();
    for (sObject sObj : sObjs) {
      String sObjId = (String) sObj.get(StringField);
      list<sObject> temp = listMap.get(sObjId) == null ? new list<sObject>() : listMap.get(sObjId);
      temp.add(sObj);
      listMap.put(sObjId, temp);
    }
    return listMap;
  }

  public static map<Id, set<String>> idListSet (list<sObject> sObjs, sObjectField idField, sObjectField setField) {
    map<Id, set<string>> listMap = new map<Id, set<string>>();
    for (sObject sObj : sObjs) {
      Id sObjId = (Id) sObj.get(idField);
      set<string> temp = listMap.get(sObjId) == null ? new set<string>() : listMap.get(sObjId);
      temp.add((string)sObj.get(setField));
      listMap.put(sObjId, temp);
    }
    return listMap;
  }

  public static map<Id, set<String>> idListSet (list<sObject> sObjs, string idField, string setField) {
    map<Id, set<string>> listMap = new map<Id, set<string>>();
    for (sObject sObj : sObjs) {
      Id sObjId = (Id) sObj.get(idField);
      set<string> temp = listMap.get(sObjId) == null ? new set<string>() : listMap.get(sObjId);
      temp.add((string)sObj.get(setField));
      listMap.put(sObjId, temp);
    }
    return listMap;
  }

  public static list<sObject> puts(list<sObject> sObjs, sObjectField field, list<Object> values) {
    integer i = 0;
    while (i < values.size() && i < sObjs.size()) {
      sObjs[i].put(field, values[i]);
      i++;
    }
    return sObjs;
  }

  public static list<sObject> puts(list<sObject> sObjs, sObjectField field, Object value) {
    for (sObject sObj : sObjs) {
      sObj.put(field, value);
    }
    return sObjs;
  }

  public static list<sObject> puts(list<sObject> sObjs, String field, Object value) {
    for (sObject sObj : sObjs) {
      sObj.put(field, value);
    }
    return sObjs;
  }

  public static list<sObject> flatten(map<Id, list<sObject>> mapList) {
    list<sObject> sObjs = new list<sObject>();
    for (Id mapId : mapList.keySet()) {
      sObjs.addAll(mapList.get(mapId));
    }
    return sObjs;
  }

  public static list<sObject> flatten(map<String, list<sObject>> mapList) {
    list<sObject> sObjs = new list<sObject>();
    for (String mapId : mapList.keySet()) {
      sObjs.addAll(mapList.get(mapId));
    }
    return sObjs;
  }

  public static list<sObject> filter(list<sObject> objs, Schema.sobjectField field, object value) {
    list<sObject> filteredList = new list<sObject>();
    for (sObject sObj : objs) {
      if (sObj.get(field) == value) {
        filteredList.add(sObj);
      }
    }
    return filteredList;
  }

  public static list<sObject> filter(list<sObject> objs, String field, object value) {
    list<sObject> filteredList = new list<sObject>();
    for (sObject sObj : objs) {
      if (sObj.get(field) == value) {
        filteredList.add(sObj);
      }
    }
    return filteredList;
  }

  public static list<sObject> filterNotEqual(list<sObject> objs, Schema.sobjectField field, object value) {
    list<sObject> filteredList = new list<sObject>();
    for (sObject sObj : objs) {
      if (sObj.get(field) != value) {
        filteredList.add(sObj);
      }
    }
    return filteredList;
  }

  public static list<sObject> filterNotEqual(list<sObject> objs, String field, object value) {
    list<sObject> filteredList = new list<sObject>();
    for (sObject sObj : objs) {
      if (sObj.get(field) != value) {
        filteredList.add(sObj);
      }
    }
    return filteredList;
  }
  public static list<sObject> sortByString(map<String, sObject> objs) {
    list<String> keys = new List<String>();
    list<sObject> values = new list<sObject>();
    keys.addAll(objs.keySet());
    keys.sort();
    for (String key : keys) {
      values.add(objs.get(key));
    }
    return values;
  }

  public static list<sObject> sortByString(map<String, list<sObject>> objs) {
    list<String> keys = new List<String>();
    list<sObject> values = new list<sObject>();
    keys.addAll(objs.keySet());
    keys.sort();
    for (String key : keys) {
      values.addAll(objs.get(key));
    }
    return values;
  }

  public static list<list<sObject>> partition(list<sObject> sobjs, integer size) {
    list<list<sObject>> partitionedRecords = new list<list<sObject>> {new list<sObject>()};
    list<sObject> records;
    integer iteration = 0;
    sObject sObj;
    for (integer i = 0; i < sObjs.size(); i++) {
      sObj = sobjs[i];
      partitionedRecords[iteration].add(sObj);
      if (Math.mod(i + 1, size) == 0 && i + 1 < sObjs.size()) {
        partitionedRecords.add(new List<sObject>());
        iteration += 1;
      }
    }

    return partitionedRecords;
  }

  public static list<list<Id>> idPartition(list<Id> sobjs, integer size) {
    list<list<Id>> partitionedRecords = new list<list<Id>> {new list<Id>()};
    list<Id> records;
    integer iteration = 0;
    Id sObj;
    for (integer i = 0; i < sObjs.size(); i++) {
      sObj = sobjs[i];
      partitionedRecords[iteration].add(sObj);
      if (Math.mod(i + 1, size) == 0 && i + 1 < sObjs.size()) {
        partitionedRecords.add(new List<Id>());
        iteration += 1;
      }
    }

    return partitionedRecords;
  }

  
 

}