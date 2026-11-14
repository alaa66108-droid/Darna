using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("Service")]
public class Service
{
    public static readonly Dictionary<string, (string Label, int Phase)> CATEGORIES = new()
    {
        ["Structural"] = ("الأعمال الإنشائية", 1),
        ["MEP"] = ("الأعمال الكهروميكانيكية", 2),
        ["Finishing"] = ("أعمال التشطيب", 3),
        ["Carpentry"] = ("النجارة والمطابخ", 4),
        ["Exterior"] = ("الواجهات والحدائق", 4),
    };

    public static readonly Dictionary<int, string> PHASES = new()
    {
        [1] = "الأساسات", [2] = "التمديدات", [3] = "التشطيب", [4] = "اللمسات النهائية",
    };

    public static readonly Dictionary<string, string> IMAGES = new()
    {
        ["Structural"] = "im-arch", ["MEP"] = "im-int", ["Finishing"] = "im-paint", ["Carpentry"] = "im-kitchen", ["Exterior"] = "im-garden",
    };

    [Key, Column("serviceID")] public int ServiceID { get; set; }
    [Column("adminID")] public int AdminID { get; set; }
    [Column("serviceCategory")] public string ServiceCategory { get; set; } = "";
    [Column("serviceName")] public string ServiceName { get; set; } = "";
    [Column("description")] public string Description { get; set; } = "";
    [Column("iconClass")] public string IconClass { get; set; } = "bi-tools";

    public static string Image(string? category) => category != null && IMAGES.TryGetValue(category, out var i) ? i : "im-paint";

    public static List<string> CategoriesOfPhase(int phase) => CATEGORIES.Where(c => c.Value.Phase == phase).Select(c => c.Key).ToList();

    public List<ServiceOffering> Offerings { get; set; } = new();

    [NotMapped] public int OfferingsCount { get; set; }

    [NotMapped] public string CategoryLabel => CATEGORIES.TryGetValue(ServiceCategory, out var c) ? c.Label : ServiceCategory;

    [NotMapped] public int Phase => CATEGORIES.TryGetValue(ServiceCategory, out var c) ? c.Phase : 1;
}
