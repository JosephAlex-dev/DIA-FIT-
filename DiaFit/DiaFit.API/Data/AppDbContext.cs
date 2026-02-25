using Microsoft.EntityFrameworkCore;
using DiaFit.API.Models;

namespace DiaFit.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<HealthLog> HealthLogs { get; set; }
        public DbSet<DietLog> DietLogs { get; set; }
        public DbSet<MedicationLog> MedicationLogs { get; set; }
        public DbSet<EmergencyContact> EmergencyContacts { get; set; }
        public DbSet<MedicalNote> MedicalNotes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // User
            modelBuilder.Entity<User>(e =>
            {
                e.HasKey(u => u.Id);
                e.HasIndex(u => u.Email).IsUnique();
                e.Property(u => u.FullName).IsRequired().HasMaxLength(100);
                e.Property(u => u.Email).IsRequired().HasMaxLength(150);
                e.Property(u => u.PasswordHash).IsRequired();
                e.Property(u => u.Role).IsRequired().HasMaxLength(50);
            });

            // HealthLog
            modelBuilder.Entity<HealthLog>(e =>
            {
                e.HasKey(h => h.Id);
                e.HasOne(h => h.User).WithMany().HasForeignKey(h => h.UserId).OnDelete(DeleteBehavior.Cascade);
                e.Property(h => h.MeasurementType).HasMaxLength(50);
            });

            // DietLog
            modelBuilder.Entity<DietLog>(e =>
            {
                e.HasKey(d => d.Id);
                e.HasOne(d => d.User).WithMany().HasForeignKey(d => d.UserId).OnDelete(DeleteBehavior.Cascade);
                e.Property(d => d.FoodName).IsRequired().HasMaxLength(200);
                e.Property(d => d.MealType).HasMaxLength(50);
                e.Property(d => d.SuitabilityResult).HasMaxLength(50);
            });

            // MedicationLog
            modelBuilder.Entity<MedicationLog>(e =>
            {
                e.HasKey(m => m.Id);
                e.HasOne(m => m.User).WithMany().HasForeignKey(m => m.UserId).OnDelete(DeleteBehavior.Cascade);
                e.Property(m => m.MedicationName).IsRequired().HasMaxLength(200);
                e.Property(m => m.Frequency).HasMaxLength(50);
            });

            // EmergencyContact
            modelBuilder.Entity<EmergencyContact>(e =>
            {
                e.HasKey(ec => ec.Id);
                e.HasOne(ec => ec.User).WithMany().HasForeignKey(ec => ec.UserId).OnDelete(DeleteBehavior.Cascade);
                e.Property(ec => ec.Name).IsRequired().HasMaxLength(100);
                e.Property(ec => ec.PhoneNumber).IsRequired().HasMaxLength(20);
                e.Property(ec => ec.Relationship).HasMaxLength(50);
            });

            // MedicalNote
            modelBuilder.Entity<MedicalNote>(e =>
            {
                e.HasKey(mn => mn.Id);
                e.HasOne(mn => mn.User).WithMany().HasForeignKey(mn => mn.UserId).OnDelete(DeleteBehavior.Cascade);
                e.Property(mn => mn.Title).IsRequired().HasMaxLength(200);
                e.Property(mn => mn.EncryptedContent).IsRequired();
            });
        }
    }
}

