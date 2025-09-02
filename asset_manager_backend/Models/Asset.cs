using System.ComponentModel.DataAnnotations;

namespace asset_manager_backend.Models
{
    public enum AssetStatus
    {
        Available,
        InUse,
        Retired
    }

    public class Asset
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Type { get; set; } = string.Empty; 

        [Required]
        [DataType(DataType.Date)]
        [CustomValidation(typeof(Asset), nameof(ValidatePurchaseDate))]
        public DateTime PurchaseDate { get; set; }

        [Required]
        public string AssignedTo { get; set; } = string.Empty;

        [Required]
        public AssetStatus Status { get; set; }

        public static ValidationResult? ValidatePurchaseDate(DateTime date, ValidationContext context)
        {
            if (date > DateTime.UtcNow)
            {
                return new ValidationResult("Purchase date cannot be in the future.");
            }
            return ValidationResult.Success;
        }
    }
}
