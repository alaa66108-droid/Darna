using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("Project")]
public class Project
{
    [Key, Column("projectID")] public int ProjectID { get; set; }
    [Column("homeOwnerID")] public int HomeOwnerID { get; set; }
    [Column("addressID")] public int AddressID { get; set; }
    [Column("projectName")] public string ProjectName { get; set; } = "";
    [Column("startDate")] public DateTime StartDate { get; set; }
    [Column("projectStatus")] public string ProjectStatus { get; set; } = "Active";

    public HomeOwner? Owner { get; set; }

    public Address? Address { get; set; }

    public List<ServiceRequest> Requests { get; set; } = new();

    public List<Appointment> Appointments { get; set; } = new();

    [NotMapped] public string Ref => Support.Ref.Project(this);

    public bool IsDeleted() => ProjectStatus == "Deleted";

    public bool IsActive() => ProjectStatus == "Active";

    public IEnumerable<ServiceRequest> WorkingRequests() =>
        Requests.Where(r => r.ServiceStatus is "Accepted" or "In Progress" or "Completed");

    public int Progress()
    {
        var rs = WorkingRequests().ToList();
        return rs.Count > 0 ? (int)Math.Round(rs.Average(r => r.ServiceProgress), MidpointRounding.AwayFromZero) : 0;
    }

    public int Phase()
    {
        var p = 0;
        foreach (var r in WorkingRequests())
        {
            p = Math.Max(p, r.Offering!.Service!.Phase);
        }
        return p;
    }

    public int ProviderCount() => WorkingRequests().Select(r => r.Offering!.ServiceProviderID).Distinct().Count();
}
