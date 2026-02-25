using DiaFit.API.DTOs;
using DiaFit.API.Services;
using Xunit;

namespace DiaFit.Tests
{
    public class FoodAnalysisTests
    {
        private readonly FoodAnalysisService _service = new();

        [Theory]
        [InlineData("Sugar", 400, 100, 0, 0, "NotRecommended")]
        [InlineData("Ice Cream", 350, 55, 5, 18, "NotRecommended")]
        [InlineData("Grilled Chicken", 200, 0, 35, 5, "Suitable")]
        [InlineData("Spinach Salad", 80, 8, 5, 2, "Suitable")]
        [InlineData("Brown Rice", 220, 45, 5, 2, "Limited")]
        [InlineData("Banana", 100, 25, 1, 0, "Limited")]
        public void Analyze_ReturnsCorrectSuitability(string food, float cal, float carb, float protein, float fat, string expected)
        {
            var req = new FoodAnalysisRequest { FoodName = food, Calories = cal, CarbohydratesGrams = carb, ProteinGrams = protein, FatGrams = fat };
            var result = _service.Analyze(req);
            Assert.Equal(expected, result.Suitability);
        }

        [Fact]
        public void Analyze_HighCarbs_AddsWarning()
        {
            var req = new FoodAnalysisRequest { FoodName = "Pasta", Calories = 400, CarbohydratesGrams = 80, ProteinGrams = 10, FatGrams = 5 };
            var result = _service.Analyze(req);
            Assert.Contains(result.Warnings, w => w.Contains("carbohydrate"));
        }

        [Fact]
        public void Analyze_HighCalories_AddsWarning()
        {
            var req = new FoodAnalysisRequest { FoodName = "Fried Chicken", Calories = 700, CarbohydratesGrams = 20, ProteinGrams = 35, FatGrams = 40 };
            var result = _service.Analyze(req);
            Assert.Contains(result.Warnings, w => w.Contains("calorie"));
        }

        [Fact]
        public void Analyze_GlycemicScoreIsClamped()
        {
            var req = new FoodAnalysisRequest { FoodName = "Pure Sugar", Calories = 10000, CarbohydratesGrams = 10000, ProteinGrams = 0, FatGrams = 0 };
            var result = _service.Analyze(req);
            Assert.InRange(result.GlycemicScore, 0f, 100f);
        }

        [Fact]
        public void Analyze_ResultHasNonEmptyReasonAndTip()
        {
            var req = new FoodAnalysisRequest { FoodName = "Apple", Calories = 95, CarbohydratesGrams = 25, ProteinGrams = 0, FatGrams = 0 };
            var result = _service.Analyze(req);
            Assert.NotEmpty(result.Reason);
            Assert.NotEmpty(result.Tip);
        }
    }

    public class EncryptionTests
    {
        private readonly EncryptionService _service;

    public EncryptionTests()
    {
        // Build config manually using MemoryConfigurationSource — no extension method needed
        var source = new Microsoft.Extensions.Configuration.Memory.MemoryConfigurationSource
        {
            InitialData = new Dictionary<string, string?> { ["Encryption:Key"] = "TestKey12345678TestKey12345678AB" }
        };
        var config = new Microsoft.Extensions.Configuration.ConfigurationBuilder()
            .Add(source)
            .Build();
        _service = new EncryptionService(config);
    }

        [Fact]
        public void EncryptDecrypt_RoundTrip_ReturnsOriginal()
        {
            const string original = "Patient has Type 2 Diabetes. On Metformin 500mg.";
            var encrypted = _service.Encrypt(original);
            var decrypted = _service.Decrypt(encrypted);
            Assert.Equal(original, decrypted);
        }

        [Fact]
        public void Encrypt_ProducesDifferentOutputThanInput()
        {
            const string plain = "secret medical note";
            var encrypted = _service.Encrypt(plain);
            Assert.NotEqual(plain, encrypted);
        }

        [Fact]
        public void Encrypt_ReturnsBase64String()
        {
            var encrypted = _service.Encrypt("test");
            var bytes = Convert.FromBase64String(encrypted);
            Assert.NotEmpty(bytes);
        }
    }
}
