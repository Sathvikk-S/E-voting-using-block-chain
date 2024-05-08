using Microsoft.AspNetCore.Mvc;

namespace BallotService.Controllers
{
    [ApiController]
    public class BallotController : Controller
    {
        private List<string> _items = new List<string>();

        [HttpPost]
        public IActionResult SetVote(string party)
        {
            if (!string.IsNullOrWhiteSpace(party))
            {
                _items.Add(party);
            }
            return Ok();
        }

        [HttpGet]
        public IActionResult GetVotes() 
        {
            if( _items.Count == 0)
            {
                return Ok("No data to display");
            }
            return Ok(_items.ToArray());
        }
    }
}
