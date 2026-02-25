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
    public class HealthLogController : ControllerBase
    {
        private readonly AppDbContext _db;
        public HealthLogController(AppDbContext db) => _db = db;

        private int GetUserId() => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "0");

        // GET api/healthlog
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var logs = await _db.HealthLogs
                .Where(h => h.UserId == GetUserId())
                .OrderByDescending(h => h.LoggedAt)
                .ToListAsync();
            return Ok(logs);
        }

        // GET api/healthlog/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var log = await _db.HealthLogs.FirstOrDefaultAsync(h => h.Id == id && h.UserId == GetUserId());
            return log == null ? NotFound() : Ok(log);
        }

        // POST api/healthlog
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] HealthLog log)
        {
            log.UserId = GetUserId();
            log.LoggedAt = DateTime.UtcNow;
            _db.HealthLogs.Add(log);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = log.Id }, log);
        }

        // PUT api/healthlog/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] HealthLog updated)
        {
            var log = await _db.HealthLogs.FirstOrDefaultAsync(h => h.Id == id && h.UserId == GetUserId());
            if (log == null) return NotFound();

            log.BloodSugarLevel = updated.BloodSugarLevel;
            log.MeasurementType = updated.MeasurementType;
            log.StepsCount = updated.StepsCount;
            log.HeartRate = updated.HeartRate;
            log.Notes = updated.Notes;
            await _db.SaveChangesAsync();
            return Ok(log);
        }

        // DELETE api/healthlog/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var log = await _db.HealthLogs.FirstOrDefaultAsync(h => h.Id == id && h.UserId == GetUserId());
            if (log == null) return NotFound();
            _db.HealthLogs.Remove(log);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}
