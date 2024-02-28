using Azure.Identity;
using crudcore.Models;
using System.Data;
using System.Data.SqlClient;
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

        public static UserCreateResult UserCreate(string procedure, List<Param_> param_ = null)
        {
            SqlConnection connection = new SqlConnection(connectionsql);
            UserCreateResult result = new UserCreateResult();

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
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (param_ != null)
                {
                    foreach (var param__ in param_)
                    {
                        if (string.IsNullOrEmpty(param__.Value_))
                        {
                            throw new ArgumentException($"El valor del parámetro '{param__.Name_}' no puede ser nulo o vacío.");
                        }
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
    }
}