using MicroServicesFramework.Auth.Shared.Configuration.Identity;

namespace MicroServicesFramework.Auth.Web.Configuration.Interfaces
{
    public interface IRootConfiguration
    {
        AdminConfiguration AdminConfiguration { get; }

        RegisterConfiguration RegisterConfiguration { get; }
    }
}





