using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;
using crudcore.Models;
using crudcore.Resources;
using Newtonsoft.Json;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;


namespace crudcore.Controllers
{
    [ApiController]
    [Route("User")]

    public class UserController : ControllerBase
    {
        [HttpGet]
        [Route("Read")]
        public dynamic ReadUser(int? idUser = null, bool? showAllUsers = null)
        {
            List<Param_> param_ = new List<Param_>();


            if (idUser.HasValue)
            {
                param_.Add(new Param_("@IdUser", idUser.Value.ToString()));
            }

            if (showAllUsers.HasValue)
            {

                param_.Add(new Param_("@ShowAllUsers", showAllUsers.Value.ToString()));
            }

            DataTable tUser = DBData.List_("sp_ReadUser", param_);

            string jsonUser = JsonConvert.SerializeObject(tUser);

            return new
            {
                success = true,
                message = "exito",
                result = new
                {
                    user = JsonConvert.DeserializeObject<List<TUser>>(jsonUser)
                }
            };
        }

        [HttpPost]
        [Route("CreateUser")]

        public dynamic UserCreate(TUser user)
        {
            List<Param_> param_ = new List<Param_>
        {
            new Param_("@FirstName", user.FirstName),
            new Param_("@LastName ", user.LastName),
            new Param_("@Username ", user.Username),
            new Param_("@Email", user.Email),
            new Param_("@Pass", user.Pass),
            new Param_("@IdStatus", user.IdStatus)

        };

            dynamic result = DBData.Launch("sp_CreateUser", param_);

            return new
            {
                succ = result.success,
                msge = result.message,
                result = ""
            };
        }

    }

}

   
 
   
