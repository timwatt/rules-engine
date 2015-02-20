public with sharing class RuleEntryController {
    private Criteria__c mCriteria;
    private transient Rule__c mRule;
    public pageReference doNothing(){
        mCriteria = null;
        return null;
    }

    public PageReference DeleteCriteria() {
        string CriteriaId = ApexPages.CurrentPage().getParameters().get('DelId');
        if (CriteriaId!='' && CriteriaId!=null) {
            Criteria__c c = new Criteria__c(Id=CriteriaId);
            delete c;
            mRule = null;
        }
        mCriteria=null;
        return null;
    }
     public PageReference SaveCriteria() {
        Criteria.Related_Object_Type__c = RelationshipMap.get(Criteria.Relationship_Name__c).getDescribe().getName();
        Criteria.Field_Label__c = mFieldMap.get(Criteria.field__c).getDescribe().Label;
        Criteria.Field_Data_Type__c = (string)mFieldMap.get(Criteria.field__c).getDescribe().getType().name();
        upsert criteria;

        if (newCriteriaValue.value__c !=null && newCriteriaValue.value__c != '') {
            newCriteriaValue.criteria_values__c=criteria.id;
            insert newCriteriaValue;
        }

       if (criteria.criteria_values__r!=null && criteria.Criteria_values__r.IsEmpty()==false) {
            update criteria.criteria_values__r;
       }
        mCriteria = null;
        mRule = null;
        return null;
     }
    private ApexPages.StandardController mController;
     public RuleEntryController() {

    }
    public RuleEntryController(ApexPages.StandardController controller) {
       mController = controller;
    }
    public Rule__c RuleRecord {
      get {
          if (mRule ==null && mController!=null && mController.getRecord()!=null) {
              Id ruleId = mController.getRecord().getSobjectType() == Rule__c.sObjectType? mController.getId() : (id)mController.getRecord().get('Rule__c');
              mRule = [select id, Object__c,(select id, name, relationship_name__c,field__c,Field_Label__c, operator__c from criteria__r) from Rule__c where id = :ruleId];
          }
          return mRule;
      }
      set {mRule=value;}
    }
    public RuleSoqlBuilder getRuleSOQLBuilder() {
        Rule ruleObj = Rule.GenerateRuleFromSObject(this.ruleRecord);
        RuleSoqlBuilder sb = new RuleSoqlBuilder(ruleObj);
        sb.addRuleCriteria();
        return sb;
    }
    public list<sobject> getMatchingResults() {
        RuleSoqlBuilder soql = getRuleSOQLBuilder();
        List<Sobject> results = null;
        try {
            MatchingResultsCount = Database.Query(soql.getSOQL()).size();
            soql.RowLimit=5;
            results = Database.Query(soql.getSOQL());
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return results;
    }

    public integer MatchingResultsCount{get;set;}
    public Criteria_Values__c newCriteriaValue {get;set;}
    public Criteria__c Criteria {
    get {
          string CriteriaId = ApexPages.CurrentPage().getParameters().get('CriteriaId');

         if (mCriteria == null  && CriteriaId!=null) {
            mCriteria = [select id,name,operator__c, rule__c,Field__c, Field_Label__c, Field_Data_Type__c,
                 Relationship_Name__c, Related_Object_Type__c, (select value__c, score__c from criteria_values__r) from Criteria__c where id=:CriteriaId];
                newCriteriaValue = new Criteria_Values__c();
         } else if (mCriteria==null) {
            mCriteria = new Criteria__c(Rule__c = RuleRecord.id);
             newCriteriaValue = new Criteria_Values__c();
         }

         return mCriteria;
     }
    }
    private transient Map<String, Schema.SObjectType> mGlobalDescribe;
    public Map<String, Schema.SObjectType> GlobalDescribe {
        get {
            if (mGlobalDescribe ==null) {
                mGlobalDescribe = Schema.getGlobalDescribe();
            }
            return mGlobalDescribe;
        }
    }
    public String DrivingObject {
        get {
           if (Criteria!=null && Criteria.Relationship_Name__c != null && Criteria.Relationship_Name__c !='') {
                return RelationshipMap.get(Criteria.Relationship_Name__c).getDescribe().getName();
           } else {
                return RuleRecord.Object__c;
            }

        }
    }
    private transient List<string> mObjectKeys;
    public List<string> ObjectKeys {
        get {
            if (mObjectKeys==null) {
              mObjectKeys = new List<String>();

              Map<String, String> keyMap= new Map<String, String>();
              for (String fd : GlobalDescribe.keyset()) {
                   keyMap.put(GlobalDescribe.get(fd).getDescribe().Label,fd);
              }
              List<String> fkeys = new List<String>();
              fkeys.addAll(keyMap.keyset());
              fkeys.sort();

               for (String k : fkeys) {
                    mObjectKeys.add(keyMap.get(k));
               }

            }
            return mObjectKeys;
        }
    }
    private transient Map<String, Schema.SObjectField> mFieldMap;
    private  transient List<SelectOption> mFieldOptions;
    public List<SelectOption> FieldOptions {
        get {
            if (mFieldOptions ==null && GlobalDescribe.containsKey(DrivingObject)) {
                mFieldOptions = new  List<SelectOption>();
                mFieldMap = GlobalDescribe.get(DrivingObject).getDescribe().fields.getMap();
                Map<String, String> keyMap= new Map<String, String>();
                for (String fd : mFieldMap.keyset()) {
                   keyMap.put(mFieldMap.get(fd).getDescribe().Label,fd);
                }
                List<String> fkeys = new List<String>();
                fKeys.addAll(keyMap.keyset());
                fKeys.sort();
                mFieldOptions.add (new SelectOption('', '---None---'));
                for (String k : fkeys) {
                    mFieldOptions.add(new SelectOption(keyMap.get(k),k));
                }

            }
            return mFieldOptions;
        }
    }
    private transient Map<String, Schema.SObjectType> mRelationshipMap;
    public Map<String, Schema.SObjectType> RelationshipMap {
        get {
                if (mRelationshipMap ==null) {
                    List<Schema.ChildRelationship> M = GlobalDescribe.get(RuleRecord.Object__c).getDescribe().getChildRelationships();
                    mRelationshipMap= new Map<String, Schema.SObjectType>();
                    for (Schema.ChildRelationship cr : M) {
                       mRelationshipMap.put(cr.getRelationshipName(), cr.getChildSObject());
                    }
                }
                return mRelationshipMap;
        }
    }

    private transient List<SelectOption> mRelationshipOptions;
    public List<SelectOption> RelationshipOptions {
        get {
            if (mRelationshipOptions ==null && RuleRecord!=null) {
                mRelationshipOptions = new  List<SelectOption>();

                List<String> fkeys = new List<String>();
                fKeys.addAll(RelationshipMap.keyset());
                fKeys.sort();
                mRelationshipOptions.add (new SelectOption('', '---None---'));
                for (String k : fkeys) {
                    if (k !=null)
                        mRelationshipOptions.add(new SelectOption(k,k));
                }

            }
            return mRelationshipOptions;
        }
    }

    private transient List<SelectOption> mObjectOptions;
    public List<SelectOption> ObjectOptions {
        get {
            if (mObjectOptions==null) {
                mObjectOptions = new List<SelectOption>();
                for (String k : ObjectKeys) {
                    mObjectOptions.add(new SelectOption(k, GlobalDescribe.get(k).getDescribe().label));
                }
            }
            return mObjectOptions;
        }
    }

}
