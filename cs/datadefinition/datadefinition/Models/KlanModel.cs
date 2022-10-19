using System.Data;
using MySql.Data.MySqlClient;

namespace mvc_connect_model_to_mysql.Models
{
    public class KlanModel
    {
        private IConfiguration _configuration;
        private string _connectionString;

        public KlanModel(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration["ConnectionString"];
        }

        public DataTable GetAllKlan()
        {
            MySqlConnection connection = new(_connectionString);
            connection.Open();
            MySqlDataAdapter adapter = new("SELECT * FROM Klan;", connection);
            DataSet ds = new();
            adapter.Fill(ds, "result");
            DataTable factories = ds.Tables["result"] ?? new DataTable();
            connection.Close();

            return factories;
        }
    }
}
