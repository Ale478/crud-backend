using crudcore.Models;

namespace crudcore.Resources
{
    public class AuditLogResult
    {
        public List<TAuditLog> AuditLogs { get; set; }
        public bool Success { get; set; }
        public string Message { get; set; }
        public string Result { get; set; }
    }
}
