/**
* Builds dynamic SOQL statements. The resulting statement is accessed through getSOQL and can then
* be executed via database.query().
*/
public virtual class SOQLBuilder{
    private String objectType;
    private Map<String, Set<String>> fieldMap = new Map<String, Set<String>>() ;
    private Map<String, String> criteriaMap = new Map<String, String>();   
    private Map<String, List<String>> sortMap = new Map<String, List<String>>() ;
    private list<string> groupList = new List<String>();
    private set<string> groupSet = new set<String>();
    private map<string,string> fieldAliasMap = new Map<string,string>();
    private List<String> sortSet = new List<String>();
    public integer RowLimit {get;set;}
    public boolean Descending {get;set;}
    
    public SOQLBuilder (String objectType, boolean IncludeId) {
        this.objectType = objectType;
        if (IncludeId) {
            this.addField(objectType, 'id');
        }
        this.RowLimit=10000;
        this.Descending = false;
    }
    public SOQLBuilder (String objectType) {
        this(objectType,true);
    }
    public SOQLBuilder addAllFields() {
        for (string fieldToken:SchemaManager.getDescribe(this.objectType).fields.getMap().keyset()) {
            if(SchemaManager.getFieldDescribe(this.objectType, fieldToken).isAccessible()) {
                this.addField(fieldToken);
            }
        }
        return this;   
    }
    public SOQLBuilder addSortField(String sortField) {
       this.addSortField(this.objectType,sortField);
       return this;
    }    
    public SOQLBuilder addSortField(String objectTypeName, String sortField) {
        if (sortMap.containsKey(objectTypeName)==false) {
            sortMap.put (objectTypeName, new list<String>());
        }
        sortMap.get(objectTypeName).add(sortField);
        return this;
    }    
    public SOQLBuilder addFields(String[] fields) {
       this.addFields(this.objectType,fields );
       return this;
    }
    public SOQLBuilder addFields(set<String> fields) {
        this.addFields(new list<String>(fields));
        return this;
    }
    public SOQLBuilder addFields(String objectTypeName, String[] fields ) {
        for (String f : fields) {
            this.addField(objectTypeName, f);
        }
        return this;
    }
    public SOQLBuilder addField(String fieldName) {
        this.addField(this.objectType, fieldName);
        return this;
    }   
    
    public SOQLBuilder addField(String fieldName, String fieldAlias, Boolean groupBy) {
        if (groupBy) {     
            this.addGroupBy(fieldName);
        } 
        
         this.addField(this.objectType, fieldName);
        
        
        if (fieldAlias!=null) {
            System.debug('Putting ' + fieldName.toUpperCase() + ' in map with value ' + fieldAlias);
            fieldAliasMap.put(fieldName.toUpperCase(), fieldAlias);
        }
        return this;
    }  
    public SOQLBuilder addField(String objectTypeName, String fieldName) {
        if (fieldMap.containsKey(objectTypeName)==false) {
            fieldMap.put (objectTypeName, new Set<String>());
        }
        fieldMap.get(objectTypeName).add(fieldName.toUpperCase());
        return this;
    }    
    public SOQLBuilder addGroupBy(string fieldName) {
        if (groupList ==null) {
            groupList = new List<string>();
            groupSet = new Set<string>();
        }
        if (groupSet.contains(fieldName)==false) {
            groupList.add(fieldName);
            groupSet.add(fieldName);
        }
        return this;
    }
    public SOQLBuilder addCriteria(String criteria, Boolean isAND) {
        this.addCriteria(this.objectType,criteria, isAND);
        return this;
    }    
    public SOQLBuilder addCriteria(String objectTypeName,String criteria, Boolean isAND) {
        String newCriteria =  criteria;
        String operator = isAND ? ' AND ' : ' OR ';
        if (criteriaMap.containsKey(objectTypeName) && criteriaMap.get(objectTypeName)!='') {
            newCriteria = criteriaMap.get(objectTypeName) + ' ' + operator + ' ' + criteria;
           // newCriteria = '((' + criteriaMap.get(objectTypeName) + ') ' + operator + ' ' + criteria  + ')';        
        }
        criteriaMap.put(objectTypeName, newCriteria);
        return this;
    }  
    private String getFieldsAsString(String objectTypeName) {
        return getFieldsAsString(objectTypeName,false,null);
    }        
    private String getFieldsAsString(String objectTypeName, boolean showAlias, string function) {       
        String soql='';
        if (fieldMap.containsKey(objectTypeName) ) {
            soql= ' ';
            boolean isFirst = true;
            for (String field : fieldMap.get(objectTypeName)) {
                string f = field;
                 if (function!=null) {
                     f = function + '(' + f + ')';
                 }
                 if (isFirst == false) {
                     soql += ', ' + f;
                 } else {
                     isFirst = false;
                     soql += f;
                 }
                 System.debug('looking for field ' + field + ' in map ' + fieldAliasMap.containsKey(field));
                 
                 if (showAlias && fieldAliasMap.containsKey(field)) {
                     soql += ' ' + fieldAliasMap.get(field);
                 }
            }
        }
        return soql;
    }    
    private String getCriteriaAsString(String objectTypeName) {
        return getCriteriaAsString(objectTypeName, true);
    }  
    private String getCriteriaAsString(String objectTypeName, boolean includeWhere) {       
        String soql='';
        if (criteriaMap.containsKey(objectTypeName) && criteriaMap.get(objectTypeName)!='') {
            if (includeWhere) {
                soql = ' where ';
            }
            soql+= criteriaMap.get(objectTypeName);
        }
        return soql;
    }    
     private String getSortAsString(String objectTypeName) {       
        String soql='';
        if (sortMap.containsKey(objectTypeName) ) {
            soql= ' ORDER BY ';
            soql+= String.join(sortMap.get(objectTypeName), ', ');
        }
        return soql;
    }   
    private string getGroupByAsString() {
        String soql='';
        if (groupList!=null && groupList.IsEmpty()==false) {
            soql= ' GROUP BY ';
            soql+= String.join(groupList, ', ');
        }
        return soql;
    } 
    public String getSOSL(String Keyword) {
        String sosl = 'FIND \'' + Keyword + '\' IN ALL FIELDS RETURNING ';
        sosl += this.objectType + ' (' + getFieldsAsString(this.objectType);
        sosl += getCriteriaAsString(this.objectType);
        sosl +=')';
        return sosl;
    }
    
    
    public String getSOQL(Boolean includeLimit) {
         String soql =  'select ' + getFieldsAsString(this.objectType,groupList.IsEmpty()==false,null);
        
        for (String o : fieldMap.keyset()) {
            if (o != this.objectType) {
                soql += ', (select ' + getFieldsAsString(o) + ' from ' + o + getCriteriaAsString(o) +  getSortAsString(o) + ')';
            }
        }        
        soql += ' from ' + this.objectType + getCriteriaAsString(this.objectType) + getGroupByAsString() +   getSortAsString(this.objectType) ;
        
        
        if (includeLimit) {
            soql += ' LIMIT ' + this.RowLimit;
        }
        return soql; 
    }
    public string getCriteria(boolean includeWhere) {
        string soql = '';
        for (String objectType : criteriaMap.keySet()) {
          if (soql!='') {
              soql = ' AND ';
          }
          soql += getCriteriaAsString(objectType,false);
        }
        
        if (includeWhere) {
            soql = 'WHERE ' + soql;
        }
        return soql;
     
    }
    public string getUniqueCounts() {
        return 'select ' + getFieldsAsString(this.objectType,true,'count_distinct') +  ' from ' + this.objectType + getCriteriaAsString(this.objectType);
    }
    
    public string getCountSOQL() {
        return 'select count() from ' +  + this.objectType + getCriteriaAsString(this.objectType);
    }
    
    public String getSOQL() {
      return getSOQL(true);
    }
    public SOQLBuilder cloneSOQLBuilder() {
        SOQLBuilder newBuilder = new SOQLBuilder(this.objectType);
        newBuilder.fieldMap = this.fieldMap.clone();
        newBuilder.criteriaMap = this.criteriaMap.clone();
        newBuilder.sortSet = this.sortSet.clone();
        return newBuilder;
    }
    static testMethod void testSOQLBuilder() {
        SOQLBuilder sb = new SOQLBuilder('Account');
        sb.addField('Name');
        sb.addField('Contacts', 'LastName');
        sb.addCriteria('Id <> null', true);
        sb.addCriteria('Contacts', 'LastName=\'Test\'', true);
        sb.addSortField('Name');
        System.Debug(sb.getSOQL());
        Database.Query(sb.getSOQL());
    }
}