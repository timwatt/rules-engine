public  with sharing class RuleSOQLBuilder extends SOQLBuilder {
    private Rule rule;
    public RuleSOQLBuilder (Rule rule) {
        super(rule.ObjectTypeName);
        this.rule = rule;
        addFieldsFromRule(rule);
    }
    
    public RuleSOQLBuilder (List<Rule> rules) {
        super(rules[0].ObjectTypeName);
        for (Rule r : rules) {
            addFieldsFromRule(r);
        }
    }
    
    private void addFieldsFromRule(Rule rule) {
     for (String s : rule.fields.keyset()) {
            if (s == rule.ObjectTypeName) {
                this.addFields(rule.fields.get(s));
            } else {
                this.addFields(s, rule.fields.get(s));
            }
        }
    }
    
    public void addRuleCriteria() {
        if (rule.RuleCriteria!=null) {
            for (Criteria__c c:rule.RuleCriteria){
                string operator = c.operator__c;
                string condition;
                string field = c.field__c;
             /*   if (c.relationship_name__c!=''  && c.relationship_name__c!=null) {
                    field = c.relationship_name__c + '.' + field;
                }*/

                for (Criteria_Values__c cv : c.Criteria_Values__r) {
                    System.Debug('add rule criteria value');
               
                    object targetValue = cv.value__c;
                    Operator op = OperatorBuilder.getOperator(c.operator__c);
                    if (c.relationship_name__c!=''  && c.relationship_name__c!=null) {
                        addCriteria(c.relationship_name__c, op.getSoqlCriteria(field,targetValue),true);
                    } else {
                        addCriteria(op.getSoqlCriteria(field,targetValue),true);
                    }
                 }
            }
        }
    }
 }