using crudcore.Models;
using crudcore.Models.Request;
using crudcore.Models.Response;
using System.Security.Cryptography;
using System.Text;
namespace crudcore.Services
{
    public interface IUserService
    {
        UserResponse Auth(AuthRequest model);
    }

    
}
