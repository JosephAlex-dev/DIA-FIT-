using DiaFit.API.DTOs;

namespace DiaFit.API.Services
{
    /// <summary>
    /// Rule-based AI food suitability analyzer for diabetic patients.
    /// Uses carbohydrate content, calorie density, and glycemic impact score.
    /// Can be replaced/extended with an ONNX ML.NET model in Phase 13.
    /// </summary>
    public class FoodAnalysisService
    {
        // High-glycemic foods that are not recommended for diabetics
        private static readonly HashSet<string> _notRecommended = new(StringComparer.OrdinalIgnoreCase)
        {
            "sugar", "candy", "soda", "juice", "cake", "cookie", "donut", "white bread",
            "white rice", "chips", "ice cream", "chocolate", "pizza", "french fries",
            "burger", "waffle", "pancake", "syrup", "honey", "jam", "jelly"
        };

        // Foods that are suitable in limited quantities
        private static readonly HashSet<string> _limited = new(StringComparer.OrdinalIgnoreCase)
        {
            "banana", "mango", "grape", "potato", "corn", "pasta", "oats",
            "whole wheat bread", "brown rice", "fruit", "milk", "yogurt", "carrot"
        };

        // Foods that are generally suitable for diabetics
        private static readonly HashSet<string> _suitable = new(StringComparer.OrdinalIgnoreCase)
        {
            "salad", "broccoli", "spinach", "egg", "chicken", "fish", "salmon",
            "tofu", "lentils", "beans", "nuts", "almonds", "avocado", "cucumber",
            "tomato", "cabbage", "cauliflower", "mushroom", "apple", "berries"
        };

        public FoodAnalysisResult Analyze(FoodAnalysisRequest request)
        {
            var result = new FoodAnalysisResult
            {
                FoodName = request.FoodName,
                GlycemicScore = CalculateGlycemicScore(request)
            };

            // Check name-based rules first
            string foodLower = request.FoodName.ToLower();
            bool nameMatched = false;

            foreach (var food in _notRecommended)
            {
                if (foodLower.Contains(food)) { nameMatched = true; result.Suitability = "NotRecommended"; break; }
            }
            if (!nameMatched)
            {
                foreach (var food in _limited)
                {
                    if (foodLower.Contains(food)) { nameMatched = true; result.Suitability = "Limited"; break; }
                }
            }
            if (!nameMatched)
            {
                foreach (var food in _suitable)
                {
                    if (foodLower.Contains(food)) { nameMatched = true; result.Suitability = "Suitable"; break; }
                }
            }

            // Fall back to nutritional rules if name not recognized
            if (!nameMatched)
            {
                result.Suitability = result.GlycemicScore switch
                {
                    > 70 => "NotRecommended",
                    > 40 => "Limited",
                    _ => "Suitable"
                };
            }

            // Add warnings and tips
            if (request.CarbohydratesGrams > 60)
                result.Warnings.Add("⚠️ High carbohydrate content — may spike blood sugar.");
            if (request.Calories > 600)
                result.Warnings.Add("⚠️ High calorie density — consider a smaller portion.");
            if (request.FatGrams > 30)
                result.Warnings.Add("⚠️ High fat content — monitor insulin response.");

            result.Reason = result.Suitability switch
            {
                "Suitable" => $"{request.FoodName} has a low glycemic impact and is generally safe for diabetics.",
                "Limited" => $"{request.FoodName} can raise blood sugar moderately — consume in small portions.",
                "NotRecommended" => $"{request.FoodName} has a high glycemic impact and is not recommended for diabetics.",
                _ => "Unable to determine suitability."
            };

            result.Tip = result.Suitability switch
            {
                "Suitable" => "✅ Go ahead — pair with protein for balanced nutrition.",
                "Limited" => "⚠️ Limit to half portion and monitor your blood sugar afterwards.",
                "NotRecommended" => "🚫 Avoid or replace with a low-GI alternative.",
                _ => ""
            };

            return result;
        }

        private float CalculateGlycemicScore(FoodAnalysisRequest req)
        {
            // Simplified glycemic impact formula (carb-heavy = higher score)
            float carbWeight = req.CarbohydratesGrams * 0.6f;
            float calWeight = req.Calories * 0.05f;
            float proteinBenefit = req.ProteinGrams * 0.3f;
            float fatBenefit = req.FatGrams * 0.1f;
            float score = carbWeight + calWeight - proteinBenefit - fatBenefit;
            return Math.Clamp(score, 0f, 100f);
        }
    }
}
