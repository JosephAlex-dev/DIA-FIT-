namespace DiaFit.API.Models
{
    public class HealthLog
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User? User { get; set; }

        public float BloodSugarLevel { get; set; }   // mg/dL
        public string MeasurementType { get; set; } = "Fasting"; // Fasting | PostMeal | Random
        public int? StepsCount { get; set; }
        public int? HeartRate { get; set; }           // bpm
        public string? Notes { get; set; }
        public DateTime LoggedAt { get; set; } = DateTime.UtcNow;
    }
}
