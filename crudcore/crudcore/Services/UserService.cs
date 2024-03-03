using crudcore.Models;
using crudcore.Models.Request;
using System.Security.Cryptography;
using System.Text;
using crudcore.Models.Response;
using crudcore.Resources;
using crudcore.Models.Commons;
using Microsoft.Extensions.Options;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;

namespace crudcore.Services
{
    public class UserService : IUserService
    {
        private readonly JwtConfig _jwtConfig;

        public UserService(IOptions<JwtConfig> jwtconfig)
        {
            _jwtConfig = jwtconfig.Value;
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
                userResponse.Token = GetToken(model);
            }

           

            return userResponse;
        }

        private string GetToken(AuthRequest model)
        {
            var tokenHandler = new JwtSecurityTokenHandler();

            var user = DBData.GetUserByEmail(model.Email);
            if (user == null)
            {
                return null;
            }

            var key = Encoding.ASCII.GetBytes(_jwtConfig.SecretKey);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(
                    new Claim[]
                    {
                        new Claim(ClaimTypes.NameIdentifier, user.IdUser.ToString())
                    }
                    ),
                Expires = DateTime.UtcNow.AddDays(1),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            var tokenString = tokenHandler.WriteToken(token);

            return tokenString;
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
