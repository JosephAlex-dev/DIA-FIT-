namespace DiaFit.API.Models
{
    public class DietLog
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User? User { get; set; }

        public string FoodName { get; set; } = string.Empty;
        public string MealType { get; set; } = "Lunch"; // Breakfast | Lunch | Dinner | Snack
        public float Calories { get; set; }
        public float CarbohydratesGrams { get; set; }
        public float ProteinGrams { get; set; }
        public float FatGrams { get; set; }
        public string SuitabilityResult { get; set; } = "Unknown"; // Suitable | Limited | NotRecommended | Unknown
        public string? Notes { get; set; }
        public DateTime LoggedAt { get; set; } = DateTime.UtcNow;
    }
}
