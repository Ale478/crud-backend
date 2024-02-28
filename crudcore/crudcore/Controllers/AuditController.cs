using crudcore.Models;
using crudcore.Resources;
using Microsoft.AspNetCore.Mvc;

namespace crudcore.Controllers
{
    [ApiController]
    [Route("Audit")]

    public class AuditController : Controller
    {
        [HttpGet]
        [Route("AuditLogs")]
        public IActionResult AuditLogs(int? pageSize = null, int? pageNumber = null, bool? includeDate = null, DateTime? startDate = null, DateTime? endDate = null)
        {
            List<Param_> parameters = new List<Param_>();

            if (pageSize.HasValue)
            {
                parameters.Add(new Param_("@PageSize", pageSize.Value.ToString()));
            }

            if (pageNumber.HasValue)
            {
                parameters.Add(new Param_("@PageNumber", pageNumber.Value.ToString()));
            }

            if (includeDate.HasValue)
            {
                parameters.Add(new Param_("@IncludeDate", includeDate.Value.ToString()));
            }

            if (startDate.HasValue)
            {
                parameters.Add(new Param_("@StartDate", startDate.Value.ToString("yyyy-MM-dd HH:mm:ss.fff")));
            }

            if (endDate.HasValue)
            {
                parameters.Add(new Param_("@EndDate", endDate.Value.ToString("yyyy-MM-dd HH:mm:ss.fff")));
            }

            var result = DBData.List_AuditLogs("sp_GetAuditLogs", parameters);

            if (result.Success)
            {
                return Ok(new
                {
                    success = true,
                    message = "exito",
                    result = new
                    {
                        auditLogs = result.AuditLogs
                    }
                });
            }
            else
            {
                return BadRequest(new
                {
                    success = false,
                    message = result.Message,
                    result = new
                    {
                        auditLogs = new List<TAuditLog>()
                    }
                });
            }
        }
    }
}


   