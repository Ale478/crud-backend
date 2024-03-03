using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;

namespace crudcore.Models.Response
{
    public class UserResponse
    {

        public string Email { get; set; }

        public string Token { get; set; }
        public int Success { get; internal set; }
        public string Msg { get; internal set; }
        public string Error { get; internal set; }
    }
}
