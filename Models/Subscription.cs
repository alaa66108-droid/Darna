using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("Subscription")]
public class Subscription
{
    [Key, Column("subscriptionID")] public int SubscriptionID { get; set; }
    [Column("serviceProviderID")] public int ServiceProviderID { get; set; }
    [Column("subscriptionPlanID")] public int SubscriptionPlanID { get; set; }
    [Column("startDate")] public DateTime StartDate { get; set; }
    [Column("subscriptionStatus")] public string SubscriptionStatus { get; set; } = "Pending";

    public SubscriptionPlan? Plan { get; set; }

    public ServiceProvider? Provider { get; set; }

    public Payment? Payment { get; set; }

    [NotMapped] public DateTime EndDate => StartDate.Date.AddMonths(Plan!.Duration);

    public bool IsCurrent()
    {
        var t = DateTime.Today;
        return SubscriptionStatus == "Active" && StartDate.Date <= t && EndDate > t;
    }

    public int DaysLeft() => Math.Max(0, (int)(EndDate - DateTime.Today).TotalDays);
}
