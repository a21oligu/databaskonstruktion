using System.Data;
using MySql.Data.MySqlClient;

namespace mvc_connect_model_to_mysql.Models
{
    public class FabrikModel
    {
        private IConfiguration _configuration;
        private string _connectionString;

        public FabrikModel(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration["ConnectionString"];
        }

        public DataTable GetAllFactories()
        {
            MySqlConnection connection = new(_connectionString);
            connection.Open();
            MySqlDataAdapter adapter = new("SELECT * FROM Fabrik;", connection);
            DataSet ds = new();
            adapter.Fill(ds, "result");
            DataTable factories = ds.Tables["result"] ?? new DataTable();
            connection.Close();

            return factories;
        }
    }
}
