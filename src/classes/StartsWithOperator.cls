public class StartsWithOperator extends Operator{
    public override String getLabel() {
         return System.Label.Operator_Starts_With;
    }
    public override boolean interpret ( Object leftOperand, Object rightOperand) {
        boolean result = false;
        if (leftOperand instanceOf String && rightOperand instanceOf String){
            result = ((String) leftOperand).startsWith((String) rightOperand);
        }
        return result;
    }
    
    public override string getSoqlCriteria (String fieldName, Object value) {
        if (value instanceOf string) {
            value = '\'' + value + '%\'';
        }
        return fieldName + ' LIKE ' + value;
    }
       
    public override string getName() {
        return 'starts with';
    }
    
    static testMethod void testOperatorClass() {
        Operator op = new StartsWithOperator();
        System.AssertEquals(op.getSelectOption().getValue(), op.getName());
        System.AssertEquals(op.getSelectOption().getLabel(), op.getLabel());
        System.AssertEquals(5==4, op.interpret(5,4));
        System.Assert(op.getSoqlCriteria('x','x')!=null);
 
    }
}