using MicroServicesFramework.Auth.Shared.Configuration.Identity;
using MicroServicesFramework.Auth.Web.Configuration.Interfaces;

namespace MicroServicesFramework.Auth.Web.Configuration
{
    public class RootConfiguration : IRootConfiguration
    {
        public AdminConfiguration AdminConfiguration { get; } = new AdminConfiguration();
        public RegisterConfiguration RegisterConfiguration { get; } = new RegisterConfiguration();
    }
}





