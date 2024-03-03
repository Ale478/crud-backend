using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;
using crudcore.Models;
using crudcore.Resources;
using Newtonsoft.Json;
using System.Text;
using System.Security.Cryptography;
using crudcore.Models.Request;
using crudcore.Models.Response;
using crudcore.Services;

namespace crudcore.Controllers
{
    [ApiController]
    [Route("Login")]
    public class LoginController : ControllerBase
    {

        private IUserService _userService;

        public LoginController(IUserService userService)
        {
            _userService = userService;
        }


        [HttpPost]
        [Route("Authenticate")]
        public IActionResult Authenticate([FromBody] AuthRequest model)
        {
            Response response = new Response();

            var userResponse = _userService.Auth(model);

            if (userResponse == null)
            {
                response.Success = 0;
                response.Msg = "Incorrect user or password";
                return BadRequest(response);
            }
            else
            {

                response.Success = 1;
                response.Data = userResponse;

                return Ok(response);

            }


        }



        [HttpPost]
        [Route("Register")]
        public UserResult Register(TUser user)
        {
            string encryptedPass = EncriptarPassword(user.Pass);

            List<Param_> param_ = new List<Param_>
    {
        new Param_("@FirstName", user.FirstName),
        new Param_("@LastName ", user.LastName),
        new Param_("@Username ", user.Username),
        new Param_("@Email", user.Email),
        new Param_("@Pass", encryptedPass),
        new Param_("@IdStatus", user.IdStatus)
    };

            return DBData.UserCreate("sp_CreateUser", param_);
        }

        private string EncriptarPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] inputBytes = Encoding.ASCII.GetBytes(password);
                byte[] hash = sha256.ComputeHash(inputBytes);

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < hash.Length; i++)
                {
                    sb.Append(hash[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }

        [HttpPost]
        [Route("Login")]
        public dynamic Login(TUser user)
        {
            string encryptedPass = EncriptarPassword(user.Pass);

            bool success = DBData.ValidateUser(user.Email, encryptedPass, out string errorMessage);

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
