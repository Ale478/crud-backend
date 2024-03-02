using Azure.Identity;
using crudcore.Models;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;
using System.Data;
using System.Data.SqlClient;
using System.Net.NetworkInformation;
using System.Reflection;
using System.Reflection.Metadata;



namespace crudcore.Resources
{
    public class DBData
    {
        public static string connectionsql = "Server=DESKTOP-EU85N82;Database=DBCRUDCORE;Trusted_Connection=True; TrustServerCertificate=True";
        public static DataSet ListTables(string procedure, List<Param_> param_ = null)
        {
            SqlConnection connection = new SqlConnection(connectionsql);

            try
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand(procedure, connection);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (param_ != null)
                {
                    foreach (var param__ in param_)
                    {
                        cmd.Parameters.AddWithValue(param__.Name_, param__.Value_);
                    }
                }
                DataSet tabla = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(tabla);


                return tabla;
            }
            catch (Exception ex)
            {
                return null;
            }
            finally
            {
                connection.Close();
            }
        }
        public static DataTable List_(string procedure, List<Param_> param_ = null)
        {
            SqlConnection connection = new SqlConnection(connectionsql);

            try
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand(procedure, connection);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (param_ != null)
                {
                    foreach (var param__ in param_)
                    {
                        cmd.Parameters.AddWithValue(param__.Name_, param__.Value_);
                    }
                }
                DataTable tabla = new DataTable();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(tabla);


                return tabla;
            }
            catch (Exception ex)
            {
                return null;
            }
            finally
            {
                connection.Close();
            }
        }
        public static AuditLogResult List_AuditLogs(string procedure, List<Param_> param_ = null)
        {
            SqlConnection connection = new SqlConnection(connectionsql);
            AuditLogResult result = new AuditLogResult();

            try
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand(procedure, connection);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (param_ != null)
                {
                    foreach (var param__ in param_)
                    {
                        cmd.Parameters.AddWithValue(param__.Name_, param__.Value_);
                    }
                }

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        var auditLogs = new List<TAuditLog>();
                        while (reader.Read())
                        {
                            var auditLog = new TAuditLog
                            {
                                IdAuditLog = reader.GetInt32(0).ToString(),
                                IdUser = reader.GetInt32(1).ToString(),
                                AuditType = reader.GetString(2),
                                AuditDate = reader.GetDateTime(3),
                                UserName = reader.GetString(4)
                            };
                            auditLogs.Add(auditLog);
                        }
                        result.AuditLogs = auditLogs;
                    }
                    else
                    {
                        result.AuditLogs = new List<TAuditLog>();
                    }
                }
                result.Success = true;
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Message = $"Error executing stored procedure '{procedure}': {ex.Message}";
            }
            finally
            {
                connection.Close();
            }

            return result;
        }


        public static UserResult UserCreate(string procedure, List<Param_> param_ = null)
        {
            SqlConnection connection = new SqlConnection(connectionsql);
            UserResult result = new UserResult();

            try
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand(procedure, connection);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (param_ != null)
                {
                    foreach (var param__ in param_)
                    {
                        cmd.Parameters.AddWithValue(param__.Name_, param__.Value_);
                    }
                }

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            result.Success = reader.GetBoolean(0);
                            result.Message = reader.GetString(1);
                        }
                    }
                    else
                    {
                        result.Success = false;
                        result.Message = "No rows returned";
                    }
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Message = ex.Message;
            }
            finally
            {
                connection.Close();
            }

            return result;
        }



        public static UpdateUserResult UpdateResult(string procedure, List<Param_> param_ = null)
        {
            SqlConnection connection = new SqlConnection(connectionsql);
            UpdateUserResult result = new UpdateUserResult();

            try
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand(procedure, connection);
                cmd.CommandType = CommandType.StoredProcedure;

                if (param_ != null)
                {
                    foreach (var param__ in param_)
                    {
                        cmd.Parameters.AddWithValue(param__.Name_, param__.Value_);
                    }
                }

                int rowsAffected = cmd.ExecuteNonQuery();

                if (rowsAffected > 0)
                {
                    result.Success = true;
                    result.Message = "User updated successfully.";
                }
                else
                {
                    result.Success = false;
                    result.Message = "No rows updated.";
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Message = ex.Message;
            }
            finally
            {
                connection.Close();
            }

            return result;
        }

        public static UpdateUserResult DeleteUser(int idUser, string modifyBy)
        {
            SqlConnection connection = new SqlConnection(connectionsql);
            UpdateUserResult result = new UpdateUserResult();

            try
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("sp_DeleteUser", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@IdUser", idUser);
                cmd.Parameters.AddWithValue("@ModifyBy", modifyBy);

                int rowsAffected = cmd.ExecuteNonQuery();

                if (rowsAffected > 0)
                {
                    result.Success = true;
                    result.Message = "User deleted successfully.";
                }
                else
                {
                    result.Success = false;
                    result.Message = "No rows deleted.";
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Message = ex.Message;
            }
            finally
            {
                connection.Close();
            }

            return result;
        }
        public static bool ValidateUser(string email, string pass, out string errorMessage)
        {
            SqlConnection connection = new SqlConnection(connectionsql);
            bool result = false;

            try
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("sp_ValidateUser", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@Pass", pass);

                SqlParameter successParam = cmd.Parameters.Add("@Success", SqlDbType.Bit);
                successParam.Direction = ParameterDirection.Output;

                SqlParameter errorParam = cmd.Parameters.Add("@ErrorMessage", SqlDbType.NVarChar, 500);
                errorParam.Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                result = (bool)successParam.Value;
                errorMessage = (string)errorParam.Value;
            }
            catch (Exception ex)
            {
                result = false;
                errorMessage = ex.Message;
            }
            finally
            {
                connection.Close();
            }

            return result;
        }

    }
}


