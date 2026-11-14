using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Darana.Data;

namespace Darana.Models;

[Table("ServiceArea")]
public class ServiceArea
{
    [Key, Column("serviceAreaID")] public int ServiceAreaID { get; set; }
    [Column("adminID")] public int AdminID { get; set; }
    [Column("region")] public string Region { get; set; } = "";
    [Column("city")] public string City { get; set; } = "";

    public List<ServiceOffering> Offerings { get; set; } = new();

    [NotMapped] public int OfferingsCount { get; set; }

    public static Dictionary<string, List<string>> Regions(AppDbContext db)
    {
        var output = new Dictionary<string, List<string>>();
        foreach (var a in db.ServiceAreas.OrderBy(x => x.ServiceAreaID).ToList())
        {
            if (!output.ContainsKey(a.Region)) output[a.Region] = new List<string>();
            output[a.Region].Add(a.City);
        }
        return output;
    }
}
