using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Net.NetworkInformation;
using System.Text.Json.Serialization;

namespace crudcore.Models;

public partial class TUser
{
    [JsonIgnore]
    public string IdUser { get; set; }

    public string FirstName { get; set; }

    public string LastName { get; set; }

    public string Username { get; set; }

    public string Email { get; set; }

    public string Pass { get; set; }

    public string IdStatus { get; set; }

    public string UserCreation { get; set; }

    public DateTime DateCreation { get; set; }

    public string UserModification { get; set; }

    public DateTime DateModification { get; set; }

    [ForeignKey("IdStatus")]
    public TStatus T_Status { get; set; }
}
