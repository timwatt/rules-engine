public class OperatorBuilder {
    public class OperatorNotFoundException extends Exception {} 
    static List<Operator> operators = new List<operator>();
    static {
        //Note: Operators should be added in order that they
        // should be displayed in the list of SelectOption. This
        // is the only place you need to register new operators
        operators.add(new EqualsOperator());
        operators.add(new NotEqualsOperator());
        operators.add(new ContainsOperator());
        operators.add(new DoesNotContainOperator());
        operators.add(new StartsWithOperator());
        operators.add(new GreaterThanOperator());
        operators.add(new LessThanOperator());
        operators.add(new GreaterThanEqualsOperator());
        operators.add(new LessThanEqualsOperator());
        operators.add(new IncludesOperator());
        operators.add(new ExcludesOperator());
    }
    
    
    public static Operator getOperator(String name) {
        Operator returnOperator = null;
        for (Operator op : operators) {
            if (name!=null && name.toLowerCase().equals(op.getName())) {
                returnOperator = op;
                break;
            }
        }
        if (returnOperator==null) {
            throw new OperatorNotFoundException('Cannot find ' + name);
        }
        return returnOperator;
    }
    
    public static List<SelectOption> getOperatorsAsSelectOption() {
        Map<String,List<SelectOption>> so = new Map<String,List<SelectOption>>();
        for (Operator op : operators) {
           if (so.containsKey(op.getLabel())==false) {
               so.put(op.getLabel(), new List<SelectOption>());
           }
           so.get(op.getLabel()).add(op.getSelectOption());
        }
        
        List<String> keys = new List<String>();
        keys.addAll(so.KeySet());
        keys.sort();
        
        List<SelectOption> sortedOptions = new List<SelectOption>();
        for (String key : keys) {
            sortedOptions.addAll(so.get(key));
        }
        return sortedOptions;
    }
    
    static testmethod void testOperatorBuilder() {
        for (Operator op : operators) {
            System.AssertEquals(op.getName(), OperatorBuilder.getOperator(op.getName()).getName());
        }
        
        System.Debug(OperatorBuilder.getOperatorsAsSelectOption());
    }
}