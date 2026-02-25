namespace DiaFit.API.Models
{
    public class MedicalNote
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User? User { get; set; }

        public string Title { get; set; } = string.Empty;
        public string EncryptedContent { get; set; } = string.Empty; // AES-256 encrypted
        public bool IsEmergencyUnlockable { get; set; } = false; // Can be viewed during emergency
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
