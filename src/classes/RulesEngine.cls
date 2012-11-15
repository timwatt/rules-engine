public class RulesEngine{
    SObjectType objType;
    String objName;
    List<Rule> rules; 
    Sobject sourceRecord;
    Id sourceRecordId;

    enum RuleType {
        Scoring,
        Assignment,
        MatchOnly
    }
    private RuleType rType;
   
    public RulesEngine(SObjectType sobjType, string RType) {
        this.objType = sobjType;
        this.objName = sobjType.getDescribe().getLocalName();
        this.rType = (RType=='Scoring' ? RuleType.Scoring : RuleType.Assignment);     
        this.rules = Rule.GenerateRules(sobjType);
    }
    public RulesEngine(Sobject sourceRecord) {
        this.objType = sourceRecord.getSObjectType();
        this.objName = this.objType.getDescribe().getLocalName();
        this.sourceRecord = sourceRecord;
        this.sourceRecordId = this.sourceRecord.id;
        this.rules = Rule.GenerateRules(this.objType);
    }
    private SObject getRecordFromList(SObject searchRecord, List<SObject> recordList) {
        SObject returnObj = searchRecord;
        for (SObject o : recordList){
            if (o.id == searchRecord.id){
                returnObj = o;
                break;
            }
        }
        return returnObj;
    }

    public List<Rule> getListOfMatchingRules(List<Rule> rules) {
       List<Rule> passingRules = new List<Rule>();
      
       if (rules !=null && Rules.IsEmpty()==false) {
            SOQLBuilder sb = new RuleSOQLBuilder(rules);
            sb.addCriteria('Id = :sourceRecordId', true);
            Sobject s = database.query(sb.getSoql());
            for (Rule r: rules) {
                if (r.executeRule(s).hasPassed) {
                    passingRules.add(r);
                }
            }
        }
        return passingRules;
    }
    public List<SObject> ProcessRules (Map<Id,SObject> assigneeList) {
        SOQLBuilder sb = new RuleSOQLBuilder(this.rules);
        Set<Id> ids = assigneeList.keyset();
        sb.addCriteria('Id in :ids' , true);
        List<SObject> relatedRecords = Database.query(sb.getSOQL());
        
        for (SObject obj:assigneeList.values()) {

            if ( rType == RuleType.Scoring) {
                //scoring
                Double totalScore = 0;
                for (Rule r : rules) {
                     Rule.RuleProcessingResult result = r.executeRule(obj,getRecordFromList(obj, relatedRecords)); 
                     totalScore += result.Score;
                    if (r.ReturnScore) {
                         obj.put(r.outputField,totalScore);
                    } else {
                         obj.put(r.outputField,r.OutputValue);
                    }
                 }
            } else {
                //assignment
                for (Rule r : rules) {
                    boolean isAssigned = false;
                    //TODO: Assignment needs to take into account the rule score to determine which rule wins
                    Rule.RuleProcessingResult result = r.executeRule(obj,getRecordFromList(obj, relatedRecords)); 
                    if (isAssigned == false && result.hasPassed) {
                       if (r.outputField!=null) {
                            if (r.ReturnScore) {
                                 obj.put(r.outputField,r.RuleScore);
                            } else {
                                 obj.put(r.outputField,r.OutputValue);
                            }
                        }
                        if (result.candidates != null && r.CandidateOutputField!=null ) {
                            obj.put(r.CandidateOutputField, result.winningCandidate.record.id);
                        }
                        isAssigned=true;
                    }
                }
            }
        }
       return assigneeList.values();
    }
    
  }