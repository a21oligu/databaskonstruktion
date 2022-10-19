using Microsoft.AspNetCore.Mvc;
using mvc_connect_model_to_mysql.Models;

namespace datadefinition.Controllers
{
    public class RenController : Controller
    {
        private readonly IConfiguration _configuration;

        public RenController(IConfiguration conf)
        {
            _configuration = conf;
        }

        public IActionResult Index(string nr)
        {
            RenModel renModel = new RenModel(_configuration);
            ViewBag.RenarTable = nr != null ? renModel.SearchRenar(nr) : renModel.GetAllRenar();
            ViewBag.Search = nr;
            return View();
        }

        public IActionResult Spann()
        {
            SpannModel spannModel = new SpannModel(_configuration);
            ViewBag.SpannTable = spannModel.GetAllSpann();
            return View();
        }

        public IActionResult New()
        {
            SpannModel spannModel = new SpannModel(_configuration);
            ViewBag.SpannTable = spannModel.GetAllSpann();

            KlanModel klanModel = new KlanModel(_configuration);
            ViewBag.KlanTable = klanModel.GetAllKlan();

            UnderartModel underartModel = new UnderartModel(_configuration);
            ViewBag.UnderartTable = underartModel.GetAllUnderart();

            StankModel stankModel = new StankModel(_configuration);
            ViewBag.StankTable = stankModel.GetAllStank();

            return View();
        }

        public IActionResult InsertRen(string nr, int klan, int underart, int stank, string spann)
        {
            RenModel renModel = new RenModel(_configuration);
            bool success = renModel.InsertRen(nr, klan, underart, stank, spann);
            return success ? RedirectToAction("Index", "Ren", new { nr = nr }) : RedirectToAction("New", "Ren");
        }

        public IActionResult DeleteRen(string nr)
        {
            RenModel renModel = new RenModel(_configuration);
            renModel.DeleteRen(nr);
            return RedirectToAction("Index", "Ren");
        }

        private string GenerateBurkNr()
        {
            string result = "";
            Random rnd = new Random();
            for(int i = 0; i < 14; i++)
            {
                result += rnd.Next(0, 9);
            }
            return result;
        }

        public IActionResult Pensionera(string nr)
        {
            if (nr == null || nr == "")
            {
                return RedirectToAction("Index");
            }

            FabrikModel fabrikModel = new FabrikModel(_configuration);
            ViewBag.Nr = nr;
            ViewBag.FabrikTable = fabrikModel.GetAllFactories();
            return View();
        }

        public IActionResult PensioneraRen(string nr, string smak, int fabrik)
        {
            RenModel renModel = new RenModel(_configuration);
            string burknr = GenerateBurkNr();
            bool success = renModel.PensioneraRen(nr, burknr, smak, fabrik);
            return success ? RedirectToAction("Index", new { nr = nr }) : RedirectToAction("Index");
        }
    }
}
