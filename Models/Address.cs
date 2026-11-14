using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("Address")]
public class Address
{
    [Key, Column("addressID")] public int AddressID { get; set; }
    [Column("homeOwnerID")] public int HomeOwnerID { get; set; }
    [Column("street")] public string Street { get; set; } = "";
    [Column("district")] public string District { get; set; } = "";
    [Column("city")] public string City { get; set; } = "";
    [Column("region")] public string Region { get; set; } = "";
    [Column("postalCode")] public string PostalCode { get; set; } = "";

    public HomeOwner? Owner { get; set; }

    public List<Project> Projects { get; set; } = new();

    [NotMapped] public int ProjectsCount { get; set; }

    [NotMapped] public string Line1 => Street + "، حي " + District;

    [NotMapped] public string Line2 => City + "، " + Region + " · " + PostalCode;

    public Dictionary<string, string?> ToArray() => new()
    {
        ["region"] = Region, ["city"] = City, ["district"] = District, ["street"] = Street, ["postalCode"] = PostalCode,
    };
}
