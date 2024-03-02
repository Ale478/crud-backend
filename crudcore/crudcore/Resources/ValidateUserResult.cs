using crudcore.Models;

namespace crudcore.Resources
{

    public class ValidateUserResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public string ErrorMessage { get; internal set; }
    }
}
