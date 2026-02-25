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
    public class MedicationLogController : ControllerBase
    {
        private readonly AppDbContext _db;
        public MedicationLogController(AppDbContext db) => _db = db;

        private int GetUserId() => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "0");

        // GET api/medicationlog
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var logs = await _db.MedicationLogs
                .Where(m => m.UserId == GetUserId())
                .OrderByDescending(m => m.ScheduledAt)
                .ToListAsync();
            return Ok(logs);
        }

        // GET api/medicationlog/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var log = await _db.MedicationLogs.FirstOrDefaultAsync(m => m.Id == id && m.UserId == GetUserId());
            return log == null ? NotFound() : Ok(log);
        }

        // POST api/medicationlog
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] MedicationLog log)
        {
            log.UserId = GetUserId();
            log.LoggedAt = DateTime.UtcNow;
            _db.MedicationLogs.Add(log);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = log.Id }, log);
        }

        // PATCH api/medicationlog/{id}/taken — mark as taken
        [HttpPatch("{id}/taken")]
        public async Task<IActionResult> MarkTaken(int id)
        {
            var log = await _db.MedicationLogs.FirstOrDefaultAsync(m => m.Id == id && m.UserId == GetUserId());
            if (log == null) return NotFound();
            log.IsTaken = true;
            log.TakenAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
            return Ok(log);
        }

        // PUT api/medicationlog/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] MedicationLog updated)
        {
            var log = await _db.MedicationLogs.FirstOrDefaultAsync(m => m.Id == id && m.UserId == GetUserId());
            if (log == null) return NotFound();

            log.MedicationName = updated.MedicationName;
            log.DosageMg = updated.DosageMg;
            log.Frequency = updated.Frequency;
            log.ScheduledAt = updated.ScheduledAt;
            log.Notes = updated.Notes;
            await _db.SaveChangesAsync();
            return Ok(log);
        }

        // DELETE api/medicationlog/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var log = await _db.MedicationLogs.FirstOrDefaultAsync(m => m.Id == id && m.UserId == GetUserId());
            if (log == null) return NotFound();
            _db.MedicationLogs.Remove(log);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}
