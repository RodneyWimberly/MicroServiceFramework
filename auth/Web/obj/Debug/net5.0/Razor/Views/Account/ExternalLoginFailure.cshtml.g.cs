#pragma checksum "D:\msf\auth\Web\Views\Account\ExternalLoginFailure.cshtml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "d55ea66cdb0a3fbf2fb4cd6865f48a9234b986b8"
// <auto-generated/>
#pragma warning disable 1591
[assembly: global::Microsoft.AspNetCore.Razor.Hosting.RazorCompiledItemAttribute(typeof(AspNetCore.Views_Account_ExternalLoginFailure), @"mvc.1.0.view", @"/Views/Account/ExternalLoginFailure.cshtml")]
namespace AspNetCore
{
    #line hidden
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.AspNetCore.Mvc.ViewFeatures;
#nullable restore
#line 2 "D:\msf\auth\Web\Views\Account\ExternalLoginFailure.cshtml"
using Microsoft.AspNetCore.Mvc.Localization;

#line default
#line hidden
#nullable disable
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"d55ea66cdb0a3fbf2fb4cd6865f48a9234b986b8", @"/Views/Account/ExternalLoginFailure.cshtml")]
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"e36dd9a20ab71656b96ee97d127868d09e1cef08", @"/Views/_ViewImports.cshtml")]
    public class Views_Account_ExternalLoginFailure : global::Microsoft.AspNetCore.Mvc.Razor.RazorPage<dynamic>
    {
        #pragma warning disable 1998
        public async override global::System.Threading.Tasks.Task ExecuteAsync()
        {
#nullable restore
#line 3 "D:\msf\auth\Web\Views\Account\ExternalLoginFailure.cshtml"
  
    ViewData["Title"] = Localizer["Title"];

#line default
#line hidden
#nullable disable
            WriteLiteral("\r\n<header>\r\n    <h2>");
#nullable restore
#line 8 "D:\msf\auth\Web\Views\Account\ExternalLoginFailure.cshtml"
   Write(ViewData["Title"]);

#line default
#line hidden
#nullable disable
            WriteLiteral(".</h2>\r\n    <p class=\"text-danger\">");
#nullable restore
#line 9 "D:\msf\auth\Web\Views\Account\ExternalLoginFailure.cshtml"
                      Write(Localizer["Error"]);

#line default
#line hidden
#nullable disable
            WriteLiteral("</p>\r\n</header>\r\n\r\n\r\n\r\n\r\n\r\n");
        }
        #pragma warning restore 1998
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public IViewLocalizer Localizer { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public IUrlHelper UrlHelper { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.ViewFeatures.IModelExpressionProvider ModelExpressionProvider { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IUrlHelper Url { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IViewComponentHelper Component { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IJsonHelper Json { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IHtmlHelper<dynamic> Html { get; private set; }
    }
}
#pragma warning restore 1591