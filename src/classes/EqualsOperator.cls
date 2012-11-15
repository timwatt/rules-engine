public class EqualsOperator extends Operator {
    public override String getLabel() {
         return System.Label.Operator_Equals;
    }
    public override boolean interpret ( Object leftOperand, Object rightOperand) {
        //TODO: This needs to handle the various data types
        return leftOperand == rightOperand;
    }
    
    public override string getSoqlCriteria (String fieldName, Object value) {
        if (value instanceOf string) {
            value = '\'' + value + '\'';
        }
        return fieldName + '=' + value;
    }
       
    public override string getName() {
        return 'equals';
    }
    
    static testMethod void testOperatorClass() {
        Operator op = new EqualsOperator();
        System.AssertEquals(op.getName(), 'equals');
        System.AssertEquals(op.getSelectOption().getValue(), op.getName());
        System.AssertEquals(op.getSelectOption().getLabel(), op.getLabel());
        System.AssertEquals(5==5, op.interpret(5,5));
        System.Assert(op.getSoqlCriteria('x','x')!=null);
 
    }
}