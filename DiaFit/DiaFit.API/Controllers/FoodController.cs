using DiaFit.API.DTOs;
using DiaFit.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DiaFit.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FoodController : ControllerBase
    {
        private readonly FoodAnalysisService _foodService;
        public FoodController(FoodAnalysisService foodService) => _foodService = foodService;

        // POST api/food/analyze
        [HttpPost("analyze")]
        public IActionResult Analyze([FromBody] FoodAnalysisRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.FoodName))
                return BadRequest(new { message = "Food name is required." });

            var result = _foodService.Analyze(request);
            return Ok(result);
        }
    }
}
