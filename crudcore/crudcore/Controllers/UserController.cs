using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;
using crudcore.Models;


namespace crudcore.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly string connectionsql;

        public UserController(IConfiguration config)
        {
            connectionsql = config.GetConnectionString("Connection");
        }


    }
}
