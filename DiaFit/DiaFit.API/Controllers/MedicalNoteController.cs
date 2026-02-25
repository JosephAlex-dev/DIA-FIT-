using DiaFit.API.Data;
using DiaFit.API.Models;
using DiaFit.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace DiaFit.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MedicalNoteController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly EncryptionService _encryption;

        public MedicalNoteController(AppDbContext db, EncryptionService encryption)
        {
            _db = db;
            _encryption = encryption;
        }

        private int GetUserId() => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "0");

        // GET api/medicalnote
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var notes = await _db.MedicalNotes
                .Where(mn => mn.UserId == GetUserId())
                .OrderByDescending(mn => mn.UpdatedAt)
                .ToListAsync();

            // Decrypt content for response
            var result = notes.Select(n => new
            {
                n.Id, n.Title,
                Content = _encryption.Decrypt(n.EncryptedContent),
                n.IsEmergencyUnlockable, n.CreatedAt, n.UpdatedAt
            });
            return Ok(result);
        }

        // GET api/medicalnote/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var note = await _db.MedicalNotes.FirstOrDefaultAsync(mn => mn.Id == id && mn.UserId == GetUserId());
            if (note == null) return NotFound();

            return Ok(new
            {
                note.Id, note.Title,
                Content = _encryption.Decrypt(note.EncryptedContent),
                note.IsEmergencyUnlockable, note.CreatedAt, note.UpdatedAt
            });
        }

        // POST api/medicalnote
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] MedicalNoteRequest request)
        {
            var note = new MedicalNote
            {
                UserId = GetUserId(),
                Title = request.Title,
                EncryptedContent = _encryption.Encrypt(request.Content),
                IsEmergencyUnlockable = request.IsEmergencyUnlockable,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _db.MedicalNotes.Add(note);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = note.Id }, new { note.Id, note.Title });
        }

        // PUT api/medicalnote/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] MedicalNoteRequest request)
        {
            var note = await _db.MedicalNotes.FirstOrDefaultAsync(mn => mn.Id == id && mn.UserId == GetUserId());
            if (note == null) return NotFound();

            note.Title = request.Title;
            note.EncryptedContent = _encryption.Encrypt(request.Content);
            note.IsEmergencyUnlockable = request.IsEmergencyUnlockable;
            note.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
            return Ok(new { note.Id, note.Title, note.UpdatedAt });
        }

        // DELETE api/medicalnote/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var note = await _db.MedicalNotes.FirstOrDefaultAsync(mn => mn.Id == id && mn.UserId == GetUserId());
            if (note == null) return NotFound();
            _db.MedicalNotes.Remove(note);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }

    public class MedicalNoteRequest
    {
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public bool IsEmergencyUnlockable { get; set; } = false;
    }
}
