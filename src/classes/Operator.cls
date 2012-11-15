public abstract class Operator {
    public abstract string getLabel();
    public abstract boolean interpret (Object leftOperand, Object rightOperand);
    public abstract string getSoqlCriteria (String FieldName, Object value);
    public abstract string getName();

    public SelectOption getSelectOption () {
        return new SelectOption (getName(), getLabel());
    }
}