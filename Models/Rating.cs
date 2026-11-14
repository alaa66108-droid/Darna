using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("Rating")]
public class Rating
{
    [Key, Column("ratingID")] public int RatingID { get; set; }
    [Column("serviceRequestID")] public int ServiceRequestID { get; set; }
    [Column("qualityRating")] public int QualityRating { get; set; }
    [Column("timeRating")] public int TimeRating { get; set; }
    [Column("costRating")] public int CostRating { get; set; }
    [Column("ratingDate")] public DateTime RatingDate { get; set; }

    public ServiceRequest? Request { get; set; }

    [NotMapped] public double Average => Math.Round((QualityRating + TimeRating + CostRating) / 3.0, 1, MidpointRounding.AwayFromZero);
}
