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

        public static dynamic Launch(string procedure, List<Param_> param_ = null)
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

                int i = cmd.ExecuteNonQuery();

                bool success = (i > 0) ? true : false;

                return new
                {
                    succ = success,
                    message = ""
                };
            }
            catch (Exception ex)
            {
                return new
                {
                    success = false,
                    message = ex.Message
                };
            }
            finally
            {
                connection.Close();
            }
        }
    }
}

     