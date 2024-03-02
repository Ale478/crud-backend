using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;
using crudcore.Models;
using crudcore.Resources;
using Newtonsoft.Json;

namespace crudcore.Controllers
{
    [ApiController]
    [Route("Login")]
    public class LoginController : ControllerBase
    {
        

        [HttpPost]
        [Route("Login")]
        public dynamic Login(TUser user)
        {
            bool success = DBData.ValidateUser(user.Email, user.Pass, out string errorMessage);

            if (success)
            {
                return new { Success = true, Message = "Login successful." };
            }
            else
            {
                return new { Success = false, Message = errorMessage };
            }
        }
    }
}
