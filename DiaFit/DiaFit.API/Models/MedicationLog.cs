namespace DiaFit.API.Models
{
    public class MedicationLog
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User? User { get; set; }

        public string MedicationName { get; set; } = string.Empty;
        public float DosageMg { get; set; }
        public string Frequency { get; set; } = "Once Daily"; // Once Daily | Twice Daily | As Needed
        public bool IsTaken { get; set; } = false;
        public string? Notes { get; set; }
        public DateTime ScheduledAt { get; set; }
        public DateTime? TakenAt { get; set; }
        public DateTime LoggedAt { get; set; } = DateTime.UtcNow;
    }
}
