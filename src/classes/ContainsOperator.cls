public class ContainsOperator extends Operator {
    public override String getLabel(){
        return System.Label.Operator_contains;
    }
    
    public override boolean interpret(Object leftOperand, Object rightOperand) {
        boolean result = false;
        if (leftOperand instanceOf String && rightOperand instanceOf String){
            result = ((String) leftOperand).contains((String) rightOperand);
        }
        return result;
    }
    
    public override string getSoqlCriteria (String fieldName, Object value) {
        if (value instanceOf string) {
            value = '\'%' + value + '%\'';
        }
        return fieldName + ' LIKE' + value;
    }
       
    public override string getName() {
        return 'contains';
    }
    
    static testMethod void testOperatorClass() {
        Operator op = new ContainsOperator ();
        System.AssertEquals(op.getSelectOption().getValue(), op.getName());
        System.AssertEquals(op.getSelectOption().getLabel(), op.getLabel());
        System.AssertEquals(op.interpret('FooBaz','Foo'),true);
        System.AssertEquals(op.interpret('BarBax','Foo'),false);
        System.Assert(op.getSoqlCriteria('x','x')!=null);  
    }
}