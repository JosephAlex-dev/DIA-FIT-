using DiaFit.API.Data;
using DiaFit.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace DiaFit.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DietLogController : ControllerBase
    {
        private readonly AppDbContext _db;
        public DietLogController(AppDbContext db) => _db = db;

        private int GetUserId() => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "0");

        // GET api/dietlog
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var logs = await _db.DietLogs
                .Where(d => d.UserId == GetUserId())
                .OrderByDescending(d => d.LoggedAt)
                .ToListAsync();
            return Ok(logs);
        }

        // GET api/dietlog/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var log = await _db.DietLogs.FirstOrDefaultAsync(d => d.Id == id && d.UserId == GetUserId());
            return log == null ? NotFound() : Ok(log);
        }

        // POST api/dietlog
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] DietLog log)
        {
            log.UserId = GetUserId();
            log.LoggedAt = DateTime.UtcNow;
            _db.DietLogs.Add(log);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = log.Id }, log);
        }

        // PUT api/dietlog/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] DietLog updated)
        {
            var log = await _db.DietLogs.FirstOrDefaultAsync(d => d.Id == id && d.UserId == GetUserId());
            if (log == null) return NotFound();

            log.FoodName = updated.FoodName;
            log.MealType = updated.MealType;
            log.Calories = updated.Calories;
            log.CarbohydratesGrams = updated.CarbohydratesGrams;
            log.ProteinGrams = updated.ProteinGrams;
            log.FatGrams = updated.FatGrams;
            log.SuitabilityResult = updated.SuitabilityResult;
            log.Notes = updated.Notes;
            await _db.SaveChangesAsync();
            return Ok(log);
        }

        // DELETE api/dietlog/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var log = await _db.DietLogs.FirstOrDefaultAsync(d => d.Id == id && d.UserId == GetUserId());
            if (log == null) return NotFound();
            _db.DietLogs.Remove(log);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}
