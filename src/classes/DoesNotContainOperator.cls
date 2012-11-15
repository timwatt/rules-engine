public class DoesNotContainOperator extends Operator {
    public override String getLabel(){
        return System.Label.Operator_Does_Not_Contain;
    }
    
    public override boolean interpret(Object leftOperand, Object rightOperand) {
        boolean result = false;
        if (leftOperand instanceOf String && rightOperand instanceOf String){
            result = !((String) leftOperand).contains((String) rightOperand);
        }
        return result;
    }
    
    public override string getSoqlCriteria (String fieldName, Object value) {
        if (value instanceOf string) {
            value = '\'%' + value + '%\'';
        }
        return fieldName + ' NOT LIKE' + value;
    }
       
    public override string getName() {
        return 'does not contain';
    }
    
    static testMethod void testOperatorClass() {
        Operator op = new DoesNotContainOperator ();
        System.AssertEquals(op.getSelectOption().getValue(), op.getName());
        System.AssertEquals(op.getSelectOption().getLabel(), op.getLabel());
        System.AssertEquals(op.interpret('FooBaz','Foo'),false);
        System.AssertEquals(op.interpret('BarBax','Foo'),true);
        System.Assert(op.getSoqlCriteria('x','x')!=null);  
    }
}