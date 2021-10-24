using System.Collections.Generic;
using MicroServicesFramework.Auth.Admin.Web.Configuration.Identity;

namespace MicroServicesFramework.Auth.Admin.Web.Configuration.IdentityServer
{
    public class Client : global::IdentityServer4.Models.Client
    {
        public List<Claim> ClientClaims { get; set; } = new List<Claim>();
    }
}






