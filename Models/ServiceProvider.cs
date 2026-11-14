using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Darana.Models.Concerns;
using Darana.Support;

namespace Darana.Models;

[Table("ServiceProvider")]
public class ServiceProvider : IsActor
{
    public const string GUARD = "provider";

    public static readonly Dictionary<string, string[]> CLASSES = new()
    {
        ["Small"] = new[] { "صغيرة", "فرد أو فريق صغير" },
        ["Medium"] = new[] { "متوسطة", "مؤسسة بفريق عمل متوسط" },
        ["Large"] = new[] { "كبيرة", "شركة بفرق عمل متعددة" },
    };

    [Key, Column("serviceProviderID")] public int ServiceProviderID { get; set; }
    [Column("adminID")] public int? AdminID { get; set; }
    [Column("accountStatus")] public string AccountStatus { get; set; } = "Active";
    [Column("whatsappNumber")] public string WhatsappNumber { get; set; } = "";
    [Column("yearsOfExperince")] public int YearsOfExperince { get; set; }
    [Column("socialMediaLink")] public string? SocialMediaLink { get; set; }
    [Column("approvalStatus")] public string ApprovalStatus { get; set; } = "Pending";
    [Column("classificationType")] public string ClassificationType { get; set; } = "";

    public override int GetKey() => ServiceProviderID;
    public override string GetKeyName() => "serviceProviderID";
    [NotMapped] public override string? AccountStatusValue => AccountStatus;

    public List<ServiceOffering> Offerings { get; set; } = new();

    public List<PortfolioFile> Portfolio { get; set; } = new();

    [NotMapped] public int PortfolioCount { get; set; }

    public List<Subscription> Subscriptions { get; set; } = new();

    public Admin? Admin { get; set; }

    [NotMapped] public string Ref => Support.Ref.Provider(ServiceProviderID);

    [NotMapped] public string ClassLabel => CLASSES.TryGetValue(ClassificationType, out var c) ? c[0] : ClassificationType;

    [NotMapped] public string ClassFact => "مؤسسة " + ClassLabel;

    public bool IsApproved() => ApprovalStatus == "Approved";
}
