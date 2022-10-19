using System.Data;
using MySql.Data.MySqlClient;

namespace mvc_connect_model_to_mysql.Models
{
    public class UnderartModel
    {
        private IConfiguration _configuration;
        private string _connectionString;

        public UnderartModel(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration["ConnectionString"];
        }

        public DataTable GetAllUnderart()
        {
            MySqlConnection connection = new(_connectionString);
            connection.Open();
            MySqlDataAdapter adapter = new("SELECT * FROM Underart;", connection);
            DataSet ds = new();
            adapter.Fill(ds, "result");
            DataTable factories = ds.Tables["result"] ?? new DataTable();
            connection.Close();

            return factories;
        }
    }
}
