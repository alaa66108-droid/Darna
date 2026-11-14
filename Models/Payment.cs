using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Darana.Models;

[Table("Payment")]
public class Payment
{
    public static readonly Dictionary<string, string> METHODS = new()
    {
        ["Mada"] = "مدى", ["Visa"] = "Visa", ["Mastercard"] = "Mastercard", ["Apple Pay"] = "Apple Pay",
    };

    [Key, Column("paymentID")] public int PaymentID { get; set; }
    [Column("subscriptionID")] public int SubscriptionID { get; set; }
    [Column("paymentDate")] public DateTime PaymentDate { get; set; }
    [Column("amount")] public decimal Amount { get; set; }
    [Column("paymentStatus")] public string PaymentStatus { get; set; } = "Pending";
    [Column("paymentMethod")] public string PaymentMethod { get; set; } = "";
    [Column("transactionRef")] public string? TransactionRef { get; set; }

    public Subscription? Subscription { get; set; }

    [NotMapped] public string InvoiceRef => Support.Ref.Invoice(this);
}
