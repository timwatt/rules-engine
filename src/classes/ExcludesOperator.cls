public class ExcludesOperator extends Operator {
    public override String getLabel(){
        return System.Label.Operator_Includes;
    }
    
    public override boolean interpret(Object leftOperand, Object rightOperand) {
        boolean result = false;
        if (leftOperand instanceOf String && rightOperand instanceOf String){
            result = !((String) leftOperand).contains(';' + (String) rightOperand+';')
                   &&!((String) leftOperand).startsWith((String) rightOperand+';')
                   &&!((String) leftOperand).endsWith(';'+(String) rightOperand)
                   &&!((String) leftOperand).equals((String) rightOperand);
        }
        return result;
    }
    
    public override string getSoqlCriteria (String fieldName, Object value) {
        if (value instanceOf string) {
            value = '\'' + value + '\'';
        }
        return fieldName + ' EXCLUDES' + value;
    }
       
    public override string getName() {
        return 'excludes';
    }
    
    static testMethod void testOperatorClass() {
        Operator op = new ExcludesOperator ();
        System.AssertEquals(op.getSelectOption().getValue(), op.getName());
        System.AssertEquals(op.getSelectOption().getLabel(), op.getLabel());
        
        System.AssertEquals(op.interpret('Foo;Baz','Foo'),false);
        System.AssertEquals(op.interpret('Bar;Bax','Foo'),true);
        
        System.Assert(op.getSoqlCriteria('x','x')!=null);  
    }
}