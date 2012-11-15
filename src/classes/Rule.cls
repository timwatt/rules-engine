public virtual with sharing class Rule {
    private Double mScore;
    private Rule__c mRule;
    private List<Criteria__c> mCriteria;
    private List<Candidate_Criteria__c> mCandidateCriteria;
    private List<SObject> mCandidates;
  
   
    private static List<Rule> GenerateRulesFromRuleSObjectMap(Map<Id, Rule__c> ruleMap){
        Map<Id, List<Criteria__c>> ruleCriteria = new Map<Id, List<Criteria__c>>();
        Map<Id, List<Candidate_Criteria__c>> ruleCandidateCriteria = new Map<Id, List<Candidate_Criteria__c>>();
        List<Rule> rules = new List<Rule>();
        for (Criteria__c c : [select id, (select value__c, score__c from criteria_values__r), operator__c, rule__c,
                                                                                                    Relationship_Name__c, Field__c, is_required__c
                                                                                                    from Criteria__c
                                                                                                    where Rule__c in :ruleMap.keyset()]) {
            if (ruleCriteria.containsKey(c.rule__c)==false) {
                ruleCriteria.put(c.rule__c, new List<Criteria__c>());
            }
            
            ruleCriteria.get(c.rule__c).add(c);                         
        }
        for (Candidate_Criteria__c cc : [select id,  rule__c, Source_Field__c, Score__c, Target_Field__c, is_required__c
                                                                                                    from Candidate_Criteria__c
                                                                                                    where Rule__c in :ruleMap.keyset()]) {
            if (ruleCandidateCriteria.containsKey(cc.rule__c)==false)   {
                ruleCandidateCriteria.put(cc.rule__c, new List<Candidate_Criteria__c>());
            }

            ruleCandidateCriteria.get(cc.rule__c).add(cc);                          
        }
        
        
        for (Rule__c r : ruleMap.values()){
            rules.add(new Rule(r, ruleCriteria.get(r.id), ruleCandidateCriteria.get(r.id)));
        }
        return rules;       
    }
    public  static Rule GenerateRuleFromSObject(Rule__c ruleRecord) {
        return Rule.GenerateRulesFromRuleSObjectMap(new Map<id,rule__c>{ruleRecord.id=>ruleRecord})[0];
    }
    public static Map<Id, Rule> GenerateRulesAsMap(String sobjType) {
     return GenerateRulesAsMap(Schema.getGlobalDescribe().get(sobjType));
       
    }
    public static Map<Id, Rule> GenerateRulesAsMap(SObjectType sobjType) {
        Map<Id, Rule> rulesMap = new Map<Id, Rule>();
        for (Rule r : GenerateRules(sobjType)) {
            rulesMap.put(r.id, r);
        }
        return rulesMap;
    }
    public static List<Rule> GenerateRules (SObjectType sobjType) {     
        String objName = sobjType.getDescribe().getLocalName();
        Map<Id, Rule__c> ruleMap = new Map<Id, Rule__c>([select id,object__c, name, score__c, OwnerId, output_field__c, output_value__c, return_score__c, Minimum_Score__c, 
                                                candidate_output_field__c, candidate_object__c,
                                                (select  operator__c, Relationship_Name__c,field__c from Criteria__r)
                                                from Rule__c
                                                where Object__c = :objName
                                                order by score__c]);
        return GenerateRulesFromRuleSObjectMap(ruleMap);
    }
    public static List<Rule> GenerateRules(SObjectType sobjType, Set<ID> filterRulesIdList) {
        String objName = sobjType.getDescribe().getLocalName();
        Map<Id, Rule__c> ruleMap = new Map<Id, Rule__c>([select id,object__c, name, score__c, OwnerId, output_field__c, output_value__c, return_score__c, Minimum_Score__c, 
                                                candidate_output_field__c, candidate_object__c,
                                                (select  operator__c, Relationship_Name__c,field__c from Criteria__r)
                                                from Rule__c
                                                where Object__c = :objName and Id in :filterRulesIdList
                                                order by score__c]);
        return GenerateRulesFromRuleSObjectMap(ruleMap);
        
    }

    public Rule(Rule__c rule, List<Criteria__c> criteria,List<Candidate_Criteria__c> candidateCriteria){
            this.mRule = rule;
            this.mCriteria = criteria;
            this.mCandidateCriteria = candidateCriteria;
    }
    
    public String OutputField {
        get { return mRule.output_field__c;}
    }
    public String OutputValue {
        get { return mRule.output_value__c;}
    }
    public String ObjectTypeName {
        get {return mRule.object__c;}
    }
    private string nName;
    public String Name {
        get {
             if (nName == null) {
              nName =  mRule.Name;
             }
             return nName;
        }
    }
    public Id Id {
        get {return mRule.Id;}
    }
    public Double RuleScore {
        get { return mRule.score__c;}
    }
    public Boolean ReturnScore {
        get { return mRule.return_score__c;}
    }
    public String CandidateOutputField {
        get { return mRule.candidate_output_field__c;}
    }   
    public Map<String,List<String>> Fields {
        get {
            Map<String,List<String>> fieldMap = new Map<String,List<String>>();
            fieldMap.put(mRule.object__c, new List<String>());
            for (Criteria__c sc : mRule.Criteria__r) {                  
                if ( sc.relationship_name__c!=null && sc.relationship_name__c!='') {
                    if (fieldMap.containsKey(sc.relationship_name__c)==false) {
                        fieldMap.put(sc.relationship_name__c, new List<String>());
                    }
                    fieldMap.get(sc.relationship_name__c).add(sc.field__c);
                } else if (sc.field__c !=null & sc.field__c != '') {
                    fieldMap.get(mRule.object__c).add(sc.field__c);
                }
            }
            return fieldMap;
        }
    }   
    public List<SObject> Candidates {
        get {
            if (mCandidates==null && CandidateCriteria!=null && CandidateCriteria.IsEmpty()==false) {
                List<SObject>queryResults;
                List<String> restrictList = new List<String>(); //TODO
                SOQLBuilder sb = new SOQLBuilder(mRule.candidate_object__c);
                for (Candidate_Criteria__c c : CandidateCriteria) {
                    sb.addField(c.Target_Field__c);     
                }
        
                if (restrictList != null){
                    String restrict='';
                    for (String candidateId : restrictList) {
                        restrict += (restrict != '' ? ', ' : '') + candidateId; 
                    }
                    if (restrict!='') {
                          sb.addCriteria('id in (' + restrict + ')', true);
                    }
                }

                
                mCandidates = Database.query(sb.getSOQL());         
            }
            return mCandidates;
        }
    }       
    public List<Candidate_Criteria__c> CandidateCriteria {
        get {
            return mCandidateCriteria;
        }
    }
    public List<Criteria__c> RuleCriteria {
        get {
            return mCriteria;
        }
    }
 
    private Double scoreCriteria(SObject targetRecord, Criteria__c critieria){
        Double score = 0;
        Operator op = OperatorBuilder.getOperator(critieria.operator__c);
        for (Criteria_Values__c cv : critieria.criteria_values__r){
                if (cv.score__c != null){
                score += op.interpret( targetRecord.get(critieria.Field__c), cv.value__c) ? cv.score__c : 0;
                }
        }
        return score;
    }
    private Double scoreCandidateCriteria(SObject candidateRecord, SObject targetRecord, Candidate_Criteria__c critieria){
        Double score = 0;
        Operator op = new EqualsOperator();
        score = op.interpret( targetRecord.get(critieria.Source_Field__c), 
                        candidateRecord.get(critieria.Target_Field__c)) ? critieria.score__c : 0;
        return score;
    }
            
    public RuleProcessingResult executeRule(SObject targetRecord) {
        return executeRule(targetRecord, targetRecord);
    }   
    public RuleProcessingResult executeRule(SObject targetRecord, SObject relatedRecords){
        RuleProcessingResult result = new RuleProcessingResult(Candidates);
        Long failedRequiredCriteria = 0;
        // generate rule score <--- this score is used when comparing to other rules to determine which one wins
        if (RuleCriteria !=null) {
            for (Criteria__c c : RuleCriteria){
                Double score = 0;
    
                if (c.relationship_name__c == '' || c.relationship_name__c == null ) {
                    score = scoreCriteria(targetRecord, c);
                } else if ( relatedRecords.getSObjects(c.relationship_name__c) != null && relatedRecords.getSObjects(c.relationship_name__c).IsEmpty()==false){
                    //it is looking at the related records so loop through all of them and score them individually              
                    for (Sobject o : relatedRecords.getSObjects(c.relationship_name__c)) {
                        score += scoreCriteria(o, c);
                    }
                }
                result.score += score;
                failedRequiredCriteria += (c.is_Required__c && score <= 0) ? 1 : 0;
            }
        }
        result.hasPassed = (failedRequiredCriteria == 0 && (mRule.minimum_score__c ==null || result.score > mRule.minimum_score__c));
        
        // score the individual Candidates <---- this score is used to determine which candidate is the "best" for this rule
        if (CandidateCriteria != null && CandidateCriteria.IsEmpty()==false) {
            for (Candidate candidate : result.candidates) {
                for (Candidate_Criteria__c c : CandidateCriteria) {
                    candidate.score+=scoreCandidateCriteria(candidate.record, targetRecord, c);
                }
            }
        }
        System.Debug('Rule results for  ' + this.Name  + ' is ' + result);

        
        return result;
    }
        
    public class RuleProcessingResult {
        private Candidate mWinningCandidate;
        public boolean hasPassed = false;
        public double  score = 0;
        public List<Candidate> candidates;
        
        public RuleProcessingResult(List<SObject> candidates) {
            this.candidates = new List<Candidate>();
            if (candidates !=null && candidates.IsEmpty()==false) {
                for (SObject c : candidates) {
                    this.candidates.add(new Candidate(c));
                }
            }
        }
        
        public Candidate winningCandidate{
            get {
                if (mWinningCandidate == null && candidates !=null && candidates.IsEmpty()==false) {
                    for (Candidate c : candidates){
                        if (mWinningCandidate==null || c.Score > mWinningCandidate.Score) {
                            mWinningCandidate = c;
                        }
                    }
                }
                return mWinningCandidate;
            }
        }
    }
    public class Candidate {
        public SObject record;
        public double score = 0;
        public Candidate (SObject record){
            this.record = record;
        }
    }
    
   
}