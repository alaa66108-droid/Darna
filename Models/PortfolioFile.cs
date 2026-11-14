using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("PortfolioFile")]
public class PortfolioFile
{
    [Key, Column("portfolioFileID")] public int PortfolioFileID { get; set; }
    [Column("serviceProviderID")] public int ServiceProviderID { get; set; }
    [Column("fileName")] public string FileName { get; set; } = "";
    [Column("fileType")] public string FileType { get; set; } = "";
    [Column("filePath")] public string FilePath { get; set; } = "";
    [Column("lastUpdatedDate")] public DateTime LastUpdatedDate { get; set; }
    [Column("fileSize")] public int FileSize { get; set; }

    public ServiceProvider? Provider { get; set; }

    [NotMapped] public string Url => "~/" + FilePath;

    public bool IsImage() => FileType is "JPG" or "PNG";

    [NotMapped] public string Icon => IsImage() ? "bi-file-earmark-image" : "bi-file-earmark-pdf";

    [NotMapped] public string SizeMb => (Math.Max(FileSize, 1) / 1048576.0).ToString("0.0", System.Globalization.CultureInfo.InvariantCulture);
}
