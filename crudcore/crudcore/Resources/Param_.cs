namespace crudcore.Resources
{
    public class Param_
    {

        public Param_( string name, string value)
        {
            Name_ = name;
            Value_ = value;
        }
        public string Name_ { get; set; }

        public string Value_ { get; set; }
    }
}
