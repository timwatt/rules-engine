/* 
 * Copyright (c) 2012, salesforce.com <http://salesforce.com> , inc.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided 
 * that the following conditions are met:
 * 
 *    Redistributions of source code must retain the above copyright notice, this list of conditions and the 
 *    following disclaimer.
 *  
 *    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and 
 *    the following disclaimer in the documentation and/or other materials provided with the distribution. 
 *    
 *    Neither the name of salesforce.com <http://salesforce.com> , inc. nor the names of its contributors may be used to endorse or 
 *    promote products derived from this software without specific prior written permission.
 *  
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR 
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */

public with sharing class SchemaManager  {
    private static Map<String, Schema.SObjectType> schemaMap;
    private static Map<String, Schema.DescribeSObjectResult> objectCache = new Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Map<String, SObjectField>> objectFieldCache = new Map<String, Map<String, SObjectField>>();

    public static Map<String,Schema.SObjectType> getSchema() {
        if(schemaMap == null) {
            schemaMap = Schema.getGlobalDescribe();
        }
        return schemaMap;
    }

    public static Schema.SObjectType getObject(String objNameOrId) {
        Schema.SObjectType type = getSchema().get(objNameOrId);
        return type != null ? type : getObjectForId(objNameOrId);
    }

    public static Schema.SObjectType getObjectForId(String id) {
        if (id == null) return null;
        for(Schema.SObjectType objType : getSchema().values()) {
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            if(objDescribe.getKeyPrefix() != null && id.startsWith(objDescribe.getKeyPrefix())) {
                return objType;
            }
        }

        return null;
    }

    public static DescribeSObjectResult getDescribe(String name) {
        return getDescribe(getObject(name));
    }

    public static DescribeSObjectResult getDescribe(SObjectType objType) {
        DescribeSObjectResult descInfo = objectCache.get(objType + '');
        if (descInfo == null) {
            descInfo = objType.getDescribe();
            objectCache.put(objType + '', descInfo);
        }
        return descInfo;
    }

    public static Schema.DescribeFieldResult getFieldDescribe(String objType, String fieldName) {
        return getFieldDescribe(getObject(objType), fieldName);
    }

    public static Schema.DescribeFieldResult getFieldDescribe(SObjectType objType, String fieldName) {
        if (objType == null || fieldName == null) return null;
        Map<String, SObjectField> fieldMap = objectFieldCache.get(objType + '');
        if (fieldMap == null) {
            DescribeSObjectResult descInfo = getDescribe(objType);
            if (descInfo != null) {
                fieldMap = descInfo.fields.getMap();
                objectFieldCache.put(objType + '', fieldMap);
            }
        }
        System.debug(fieldName);
        SObjectField field =  (fieldMap != null) ? fieldMap.get(fieldName) : null;
        System.debug(field);
        return (field != null) ? field.getDescribe() : null;
    }

    public static boolean isReferenceField(SObjectType objType, String fieldName) {
        Schema.DescribeFieldResult fieldDesc = getFieldDescribe(objType, fieldName);
        return (fieldDesc.getType() == Schema.DisplayType.Reference);
    }

    public static boolean isTranslatableField(SObjectType objType, String fieldName) {
        if (fieldName.toLowerCase() == 'recordtype.name') {
            return true;
        }
        Schema.DescribeFieldResult fieldDesc = getFieldDescribe(objType, fieldName);
        if (fieldName == null || fieldDesc == null) {
            return false;
        }
        return (fieldDesc.getType() == Schema.DisplayType.Picklist
            || fieldDesc.getType() == Schema.DisplayType.MultiPicklist);
    }

    public static String getNameFieldForReferenceField(SObjectType objType, String fieldName) {
        Schema.DescribeFieldResult fieldDesc = getFieldDescribe(objType, fieldName);
        return getNameFieldForReferenceField(fieldDesc);
    }
    
    public static String getNameFieldForReferenceField(Schema.DescribeFieldResult fieldDesc) {
        if (fieldDesc.getType() == Schema.DisplayType.Reference) {
            SObjectType parentType = fieldDesc.getReferenceTo()[0];
            if ('Case'.equalsIgnoreCase('' + parentType))
               return fieldDesc.getRelationshipName() + '.Subject';
            else return fieldDesc.getRelationshipName() + '.Name';
        }
        return fieldDesc.getName();
    }

    public static boolean isFieldAccessible(SObjectType objType, String fieldPath) {
        boolean isAccessible = false;
        Schema.DescribeSObjectResult objDesc = getDescribe(objType);
        if (objDesc.isAccessible()) {
            String fieldName = fieldPath;
            System.debug(fieldPath);
            if (fieldPath.indexOf('.') > 0) {
                fieldName = fieldPath.split('\\.')[0];
                if (fieldName.toLowerCase().endsWith('__r')) {
                    fieldName = fieldName.subString(0, fieldName.length()-1) + 'c';
                } else {
                    fieldName += 'Id'; //FIX: This is kind of a hack as there is no way to get field entry from relationship name
                }
            }

            Schema.DescribeFieldResult fieldDesc = getFieldDescribe(objType, fieldName);
            if (fieldDesc != null && fieldDesc.isAccessible()) {
                if (fieldDesc.getType() == Schema.DisplayType.Reference) { //FIX: Check that for custom relationships, __r is used in path
                    if (fieldDesc.isNamePointing()) isAccessible = true; //FIX: Check the limited fields accessible for name pointing
                    else if (fieldPath.indexOf('.') > 0) {
                        String childPath = fieldPath.subString(fieldPath.indexOf('.') + 1); //FIX: Index overflow for case like "Account."
                        System.debug(childPath);
                        isAccessible = isFieldAccessible(fieldDesc.getReferenceTo()[0], childPath);
                    } else isAccessible = true;
                } else {
                    isAccessible = true;
                }
            }
        }
        System.debug('isAccessible: ' + isAccessible);

        return isAccessible;
    }

    public static boolean isFieldAccessible(Schema.DescribeFieldResult fieldDesc, String fieldPath) {
        boolean isAccessible = false;
        if (fieldDesc != null && fieldDesc.isAccessible()) {
            if (fieldDesc.getType() == Schema.DisplayType.Reference) { //FIX: Check that for custom relationships, __r is used in path
                if (fieldDesc.isNamePointing()) isAccessible = true; //FIX: Check the limited fields accessible for name pointing
                else if (fieldPath.indexOf('.') > 0) {
                    String childPath = fieldPath.subString(fieldPath.indexOf('.') + 1); //FIX: Index overflow for case like "Account."
                    System.debug(childPath);
                    isAccessible = isFieldAccessible(fieldDesc.getReferenceTo()[0], childPath);
            }
        } else {
                isAccessible = true;
        }
        }

    System.debug(fieldPath + ' isAccessible?: ' + isAccessible);
    return isAccessible;
    }
}