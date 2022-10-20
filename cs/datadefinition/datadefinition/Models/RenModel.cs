using System;
using System.Data;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Mvc;
using MySql.Data.MySqlClient;

namespace mvc_connect_model_to_mysql.Models
{
    public class RenModel
    {
        private IConfiguration _configuration;
        private string _connectionString;

        public RenModel(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration["ConnectionString"];
        }

        public DataTable GetAllRenar()
        {    
            MySqlConnection connection = new(_connectionString);
            connection.Open();
            MySqlDataAdapter adapter = new("SELECT * FROM Ren;", connection);
            DataSet ds = new();
            adapter.Fill(ds, "result");
            DataTable renar = ds.Tables["result"] ?? new DataTable();
            connection.Close();

            return renar;
        }

        public DataTable SearchRenar(string nr)
        {
            if (nr == null) {
                Console.WriteLine("Nr must not be null");
                return new DataTable();
            }

            MySqlConnection connection = new(_connectionString);
            connection.Open();
            MySqlDataAdapter adapter = new("SELECT * FROM Ren WHERE nr LIKE @nr;", connection);
            adapter.SelectCommand.Parameters.AddWithValue("@nr", string.Format("%{0}%", nr));
            DataSet ds = new();
            adapter.Fill(ds, "result");
            DataTable renar = ds.Tables["result"] ?? new DataTable();
            connection.Close();

            return renar;
        }


        public bool InsertRen(string nr, int klan, int underart, int stank, string spann)
        {
            if (!nr.All(Char.IsDigit) || nr.Count() != 11)
            {
                Console.WriteLine("Nr must be numeric and contain 11 digits");
                return false;
            }

            try
            {
                MySqlConnection connection = new(_connectionString);
                connection.Open();
                MySqlCommand command = new("INSERT INTO Ren(nr, klan, underart, stank, spann, lön, typ) VALUES (@nr, @klan, @underart, @stank, @spann, 2000, 'tjänste');", connection);
                command.Parameters.AddWithValue("@nr", nr);
                command.Parameters.AddWithValue("@klan", klan);
                command.Parameters.AddWithValue("@underart", underart);
                command.Parameters.AddWithValue("@stank", stank);
                command.Parameters.AddWithValue("@spann", spann);
                int affectedRows = command.ExecuteNonQuery();

                Console.WriteLine(nr);

                connection.Close();

                return affectedRows > 0;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                return false;
            }
        }

        public bool DeleteRen(string nr)
        {
            try
            {
                MySqlConnection connection = new(_connectionString);
                connection.Open();
                MySqlCommand command = new("DELETE FROM Ren WHERE nr = @nr;", connection);
                command.Parameters.AddWithValue("@nr", nr);
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

        public bool PensioneraRen(string nr, string burknr, string smak, int fabrik)
        {
            try
            {
                MySqlConnection connection = new(_connectionString);
                connection.Open();
                // CALL PensioneraRen("11111111111", "307.2461-307.2467", 0, "Tvärgo korv");
                MySqlCommand command = new("CALL PensioneraRen(@nr, @burknr, @fabrik, @smak)", connection);
                command.Parameters.AddWithValue("@nr", nr);
                command.Parameters.AddWithValue("@burknr", burknr);
                command.Parameters.AddWithValue("@fabrik", fabrik);
                command.Parameters.AddWithValue("@smak", smak);
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