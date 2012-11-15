public class NotEqualsOperator extends Operator{
    public override String getLabel() {
         return System.Label.Operator_Not_Equal;
    }
    public override boolean interpret ( Object leftOperand, Object rightOperand) {
        return leftOperand != rightOperand;
    }
    
    public override string getSoqlCriteria (String fieldName, Object value) {
        if (value instanceOf string) {
            value = '\'' + value + '\'';
        }
        return fieldName + '!=' + value;
    }
       
    public override string getName() {
        return 'not equal to';
    }
    
    static testMethod void testOperatorClass() {
        Operator op = new NotEqualsOperator();
        System.AssertEquals(op.getSelectOption().getValue(), op.getName());
        System.AssertEquals(op.getSelectOption().getLabel(), op.getLabel());
        System.AssertEquals(5!=4, op.interpret(5,4));
        System.Assert(op.getSoqlCriteria('x','x')!=null);
 
    }
}