using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Darana.Models.Concerns;

namespace Darana.Models;

[Table("Admin")]
public class Admin : IsActor
{
    public const string GUARD = "admin";

    [Key, Column("adminID")] public int AdminID { get; set; }
    [Column("jobTitle")] public string JobTitle { get; set; } = "";

    public override int GetKey() => AdminID;
    public override string GetKeyName() => "adminID";
}
