using crudcore.Models;
using crudcore.Models.Request;
using System.Security.Cryptography;
using System.Text;
using crudcore.Models.Response;
using crudcore.Resources;

namespace crudcore.Services
{
    public class UserService : IUserService
    {
        private readonly DbcrudcoreContext context;

    public UserService(DbcrudcoreContext context)
    {
        this.context = context;
    }
        public UserResponse Auth(AuthRequest model)
        {
            UserResponse userResponse = new UserResponse();
            string encryptedPass = EncriptarPassword(model.Password);
            Response response = new Response();

            string errorMessage;
            bool isValid = DBData.ValidateUser(model.Email, encryptedPass, out errorMessage);

            if (!isValid)
            {
       
                userResponse = null;
            }
            else {
                userResponse.Email = model.Email;
            }

           

            return userResponse;
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
    }

}
