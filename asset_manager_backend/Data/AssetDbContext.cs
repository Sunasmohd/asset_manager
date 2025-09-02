using Microsoft.EntityFrameworkCore;
using asset_manager_backend.Models;
using Microsoft.AspNetCore.Identity;

namespace asset_manager_backend.Data
{
    public class AssetDbContext : DbContext
    {
        public DbSet<Asset> Assets { get; set; }
        public DbSet<User> Users { get; set; } 

        public AssetDbContext(DbContextOptions<AssetDbContext> options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Asset>().Property(a => a.Status).HasConversion<string>();

            var hasher = new PasswordHasher<User>();
            var adminUser = new User
            {
                Id = 1,
                Username = "admin",
                PasswordHash = "",
                Role = "Admin"
            };
            adminUser.PasswordHash = hasher.HashPassword(adminUser, "Admin123!");

            var regularUser = new User
            {
                Id = 2,
                Username = "user",
                PasswordHash = "",
                Role = "User"
            };
            regularUser.PasswordHash = hasher.HashPassword(regularUser, "User123!");
            modelBuilder.Entity<User>().HasData(adminUser, regularUser);
        }
    }
}