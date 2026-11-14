using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using Darana.Support;

namespace Darana.Models.Concerns;

public abstract class IsActor
{
    [Column("firstName")] public string FirstName { get; set; } = "";
    [Column("lastName")] public string LastName { get; set; } = "";
    [Column("email")] public string Email { get; set; } = "";
    [Column("phoneNumber")] public string PhoneNumber { get; set; } = "";
    [Column("DOB")] public DateTime DOB { get; set; }
    [JsonIgnore, Column("password")] public string Password { get; set; } = "";
    [Column("registrationDate")] public DateTime RegistrationDate { get; set; }

    public abstract int GetKey();

    public abstract string GetKeyName();

    [NotMapped] public virtual string? AccountStatusValue => null;

    public string GetAuthPassword() => Password;

    public string? GetRememberTokenName() => null;

    [NotMapped] public string FullName => (FirstName + " " + LastName).Trim();

    [NotMapped] public string Initials => Fmt.Initials(FirstName, LastName);

    public bool IsSuspended() => (AccountStatusValue ?? "Active") == "Suspended";
}
