using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("ServiceOffering")]
public class ServiceOffering
{
    [Key, Column("serviceOfferingID")] public int ServiceOfferingID { get; set; }
    [Column("serviceProviderID")] public int ServiceProviderID { get; set; }
    [Column("serviceID")] public int ServiceID { get; set; }
    [Column("serviceAreaID")] public int ServiceAreaID { get; set; }

    public ServiceProvider? Provider { get; set; }

    public Service? Service { get; set; }

    public ServiceArea? Area { get; set; }

    public List<ServiceRequest> Requests { get; set; } = new();

    public List<Appointment> Appointments { get; set; } = new();

    [NotMapped] public int LiveCount { get; set; }
    [NotMapped] public int UsedCount { get; set; }
    [NotMapped] public int ApptCount { get; set; }
}
