public class GreaterThanOperator extends Operator{
    public override String getLabel() {
         return System.Label.Operator_Greater_Than;
    }
    public override boolean interpret ( Object leftOperand, Object rightOperand) {
        boolean result = false;
        if (leftOperand instanceOf Date && rightOperand instanceOf Date){
            //If the date on the left side occurs after the date on the right the value is negative
            result = ((Date) leftOperand).daysBetween((Date) rightOperand) < 0;
        } else if (leftOperand instanceOf DateTime && rightOperand instanceOf DateTime){
            result = ((DateTime) leftOperand).getTime() > ((DateTime) rightOperand).getTime();
        } else if (leftOperand instanceOf Integer && rightOperand instanceOf Integer){
            result = (Integer) leftOperand > (Integer) rightOperand;
        } else if (leftOperand instanceOf Long && rightOperand instanceOf Long){
            result = (Long) leftOperand > (Long) rightOperand;
        } else if (leftOperand instanceOf Double && rightOperand instanceOf Double){
            result = (Double) leftOperand > (Double) rightOperand;
        } else if (leftOperand instanceOf Integer && rightOperand instanceOf Integer){
            result = (Integer) leftOperand > (Integer) rightOperand;
        } else if (leftOperand instanceOf Decimal && rightOperand instanceOf Decimal){
            result = (Decimal) leftOperand > (Decimal) rightOperand;
        }
        return result;
    }
    
    public override string getSoqlCriteria (String fieldName, Object value) {
        if (value instanceOf string) {
            value = '\'' + value + '\'';
        }
        return fieldName + '>' + value;
    }
       
    public override string getName() {
        return 'greather than';
    }
    
    static testMethod void testOperatorClass() {
        Operator op = new GreaterThanOperator();
        System.AssertEquals(op.getSelectOption().getValue(), op.getName());
        System.AssertEquals(op.getSelectOption().getLabel(), op.getLabel());
        System.AssertEquals(5>4, op.interpret(5,4));
        System.AssertEquals(5>4, op.interpret(Decimal.valueOf(5),Decimal.valueOf(4)));
        System.AssertEquals(5>4, op.interpret(Long.valueOf('5'),Long.valueOf('4')));
        System.AssertEquals(5>4, op.interpret(Double.valueOf(5),Double.valueOf(4)));
        System.AssertEquals(5>4, op.interpret(Date.today()+1,Date.today())); 
        System.Assert(op.getSoqlCriteria('x','x')!=null);
 
    }
}