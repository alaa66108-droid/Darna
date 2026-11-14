using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("ServiceRequest")]
public class ServiceRequest
{
    public static readonly string[] LIVE = { "Pending", "Accepted", "In Progress" };

    [Key, Column("serviceRequestID")] public int ServiceRequestID { get; set; }
    [Column("projectID")] public int ProjectID { get; set; }
    [Column("serviceOfferingID")] public int ServiceOfferingID { get; set; }
    [Column("startDate")] public DateTime StartDate { get; set; }
    [Column("serviceProgress")] public int ServiceProgress { get; set; }
    [Column("serviceStatus")] public string ServiceStatus { get; set; } = "Pending";
    [Column("requestDate")] public DateTime RequestDate { get; set; }
    [Column("statusUpdatedAt")] public DateTime StatusUpdatedAt { get; set; }

    public Project? Project { get; set; }

    public ServiceOffering? Offering { get; set; }

    public Rating? Rating { get; set; }

    [NotMapped] public string Ref => Support.Ref.Request(this);

    public bool IsUnavailable() => ServiceStatus == "Pending" && Project!.IsDeleted();

    public bool IsOverdue() => ServiceStatus == "Accepted" && StartDate.Date < DateTime.Today;

    [NotMapped]
    public string State
    {
        get
        {
            if (IsUnavailable()) return "unavailable";
            if (ServiceStatus == "Accepted") return IsOverdue() ? "overdue" : "upcoming";
            return ServiceStatus;
        }
    }

    public bool IsLive() => LIVE.Contains(ServiceStatus);
}
