using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("Appointment")]
public class Appointment
{
    [Key, Column("appointmentID")] public int AppointmentID { get; set; }
    [Column("projectID")] public int ProjectID { get; set; }
    [Column("serviceOfferingID")] public int ServiceOfferingID { get; set; }
    [Column("appointmentDate")] public DateTime AppointmentDate { get; set; }
    [Column("appointmentTime")] public TimeSpan AppointmentTime { get; set; }
    [Column("description")] public string? Description { get; set; }
    [Column("appointmentStatus")] public string AppointmentStatus { get; set; } = "Pending";

    public Project? Project { get; set; }

    public ServiceOffering? Offering { get; set; }

    [NotMapped]
    public string ShownStatus =>
        AppointmentStatus == "Accepted" && AppointmentDate.Date < DateTime.Today ? "Completed" : AppointmentStatus;

    [NotMapped] public string TimeHm => AppointmentTime.ToString(@"hh\:mm");

    [NotMapped] public string TimeString => AppointmentTime.ToString(@"hh\:mm\:ss");

    public bool IsUpcoming() => AppointmentStatus is "Pending" or "Accepted" && AppointmentDate.Date >= DateTime.Today;
}
