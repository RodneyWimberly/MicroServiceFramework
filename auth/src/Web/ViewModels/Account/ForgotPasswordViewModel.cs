using MicroServicesFramework.Auth.Shared.Configuration.Identity;
using System.ComponentModel.DataAnnotations;

namespace MicroServicesFramework.Auth.Web.ViewModels.Account
{
    public class ForgotPasswordViewModel
    {
        [Required]
        public LoginResolutionPolicy? Policy { get; set; }
        //[Required]
        [EmailAddress]
        public string Email { get; set; }

        public string Username { get; set; }
    }
}






