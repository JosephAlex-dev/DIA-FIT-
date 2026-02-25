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
    public class EmergencyContactController : ControllerBase
    {
        private readonly AppDbContext _db;
        public EmergencyContactController(AppDbContext db) => _db = db;

        private int GetUserId() => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "0");

        // GET api/emergencycontact
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var contacts = await _db.EmergencyContacts
                .Where(ec => ec.UserId == GetUserId())
                .OrderByDescending(ec => ec.IsPrimary)
                .ToListAsync();
            return Ok(contacts);
        }

        // GET api/emergencycontact/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var contact = await _db.EmergencyContacts.FirstOrDefaultAsync(ec => ec.Id == id && ec.UserId == GetUserId());
            return contact == null ? NotFound() : Ok(contact);
        }

        // POST api/emergencycontact
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] EmergencyContact contact)
        {
            contact.UserId = GetUserId();
            contact.CreatedAt = DateTime.UtcNow;
            _db.EmergencyContacts.Add(contact);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = contact.Id }, contact);
        }

        // PUT api/emergencycontact/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] EmergencyContact updated)
        {
            var contact = await _db.EmergencyContacts.FirstOrDefaultAsync(ec => ec.Id == id && ec.UserId == GetUserId());
            if (contact == null) return NotFound();

            contact.Name = updated.Name;
            contact.PhoneNumber = updated.PhoneNumber;
            contact.Relationship = updated.Relationship;
            contact.IsPrimary = updated.IsPrimary;
            await _db.SaveChangesAsync();
            return Ok(contact);
        }

        // DELETE api/emergencycontact/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var contact = await _db.EmergencyContacts.FirstOrDefaultAsync(ec => ec.Id == id && ec.UserId == GetUserId());
            if (contact == null) return NotFound();
            _db.EmergencyContacts.Remove(contact);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}
