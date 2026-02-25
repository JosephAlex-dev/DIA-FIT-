namespace DiaFit.API.DTOs
{
    public class FoodAnalysisRequest
    {
        public string FoodName { get; set; } = string.Empty;
        public float Calories { get; set; }
        public float CarbohydratesGrams { get; set; }
        public float ProteinGrams { get; set; }
        public float FatGrams { get; set; }
    }

    public class FoodAnalysisResult
    {
        public string FoodName { get; set; } = string.Empty;
        public string Suitability { get; set; } = string.Empty; // Suitable | Limited | NotRecommended
        public string Reason { get; set; } = string.Empty;
        public string Tip { get; set; } = string.Empty;
        public float GlycemicScore { get; set; } // 0-100, lower = better for diabetics
        public List<string> Warnings { get; set; } = new();
    }
}
