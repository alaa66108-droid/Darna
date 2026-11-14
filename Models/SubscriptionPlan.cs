using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("SubscriptionPlan")]
public class SubscriptionPlan
{
    [Key, Column("SubscriptionPlanID")] public int SubscriptionPlanID { get; set; }
    [Column("adminID")] public int AdminID { get; set; }
    [Column("planName")] public string PlanName { get; set; } = "";
    [Column("description")] public string Description { get; set; } = "";
    [Column("price")] public decimal Price { get; set; }
    [Column("duration")] public int Duration { get; set; }

    public List<Subscription> Subscriptions { get; set; } = new();

    [NotMapped] public int SubscriptionsCount { get; set; }
}
