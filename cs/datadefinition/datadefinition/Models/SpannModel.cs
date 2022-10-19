using System.Data;
using MySql.Data.MySqlClient;

namespace mvc_connect_model_to_mysql.Models
{
    public class SpannModel
    {
        private IConfiguration _configuration;
        private string _connectionString;

        public SpannModel(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration["ConnectionString"];
        }

        public DataTable GetAllSpann()
        {
            MySqlConnection connection = new(_connectionString);
            connection.Open();
            MySqlDataAdapter adapter = new("SELECT * FROM Spann;", connection);
            DataSet ds = new();
            adapter.Fill(ds, "result");
            DataTable spann = ds.Tables["result"] ?? new DataTable();
            connection.Close();

            return spann;
        }

        public bool Delete(string namn)
        {
            try
            {
                MySqlConnection connection = new(_connectionString);
                connection.Open();
                MySqlCommand command = new("DELETE FROM Spann WHERE namn = @namn;", connection);
                command.Parameters.AddWithValue("@namn", namn);
                int affectedRows = command.ExecuteNonQuery();
                connection.Close();

                return affectedRows > 0;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                return false;
            }
        }
    }
}
