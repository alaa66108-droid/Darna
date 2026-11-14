using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Darana.Models.Concerns;

namespace Darana.Models;

[Table("HomeOwner")]
public class HomeOwner : IsActor
{
    public const string GUARD = "owner";

    [Key, Column("homeOwnerID")] public int HomeOwnerID { get; set; }
    [Column("adminID")] public int? AdminID { get; set; }
    [Column("accountStatus")] public string AccountStatus { get; set; } = "Active";

    public override int GetKey() => HomeOwnerID;
    public override string GetKeyName() => "homeOwnerID";
    [NotMapped] public override string? AccountStatusValue => AccountStatus;

    public List<Address> Addresses { get; set; } = new();

    public List<Project> Projects { get; set; } = new();

    [NotMapped] public int ProjectsCount { get; set; }

    public Admin? Admin { get; set; }
}
