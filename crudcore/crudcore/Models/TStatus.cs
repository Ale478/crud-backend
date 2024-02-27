using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace crudcore.Models;

public partial class TStatus
{
    public string IdStatus { get; set; }

    public string? StatusName { get; set; }

    public string? StatusDescription { get; set; }

    public string? UserCreation { get; set; }

    public DateTime? DateCreation { get; set; }

    public string? UserModification { get; set; }

    public DateTime? DateModification { get; set; }

    [JsonIgnore]
    public virtual ICollection<TUser> TUsers { get; set; } = new List<TUser>();
}
