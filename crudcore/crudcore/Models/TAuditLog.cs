using System;
using System.Collections.Generic;

namespace crudcore.Models;

public partial class TAuditLog
{
    public string IdAuditLog { get; set; }

    public string IdUser { get; set; }

    public string AuditType { get; set; }

    public DateTime AuditDate { get; set; }

    public string UserName { get; set; }
}
