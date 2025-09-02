// Add to Models/User.cs 
using System.ComponentModel.DataAnnotations; using System.Text.Json.Serialization;

namespace asset_manager_backend.Models
{
    public class User
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [Required]
        public string Role { get; set; } = "User"; // Admin or User
    }
}