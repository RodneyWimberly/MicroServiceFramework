using IdentityServer4.Models;
using System.Collections.Generic;
using Client = MicroServicesFramework.Auth.Admin.Web.Configuration.IdentityServer.Client;

namespace MicroServicesFramework.Auth.Admin.Web.Configuration
{
    public class IdentityServerDataConfiguration
    {
        public List<Client> Clients { get; set; } = new List<Client>();
        public List<IdentityResource> IdentityResources { get; set; } = new List<IdentityResource>();
        public List<ApiResource> ApiResources { get; set; } = new List<ApiResource>();
        public List<ApiScope> ApiScopes { get; set; } = new List<ApiScope>();
    }
}






