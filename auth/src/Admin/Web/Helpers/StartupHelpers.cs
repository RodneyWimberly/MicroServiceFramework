using MicroServicesFramework.Auth.Admin.Web.Configuration;
using MicroServicesFramework.Auth.Admin.Web.Configuration.ApplicationParts;
using MicroServicesFramework.Auth.Admin.Web.Configuration.Constants;
using MicroServicesFramework.Auth.Admin.Web.Configuration.Interfaces;
using MicroServicesFramework.Auth.Admin.Web.ExceptionHandling;
using MicroServicesFramework.Auth.Admin.Web.Helpers.Localization;
using IdentityModel;
using IdentityServer4;
using IdentityServer4.EntityFramework.Options;
using MicroServicesFramework.Auth.Data.MySql.Extensions;
using MicroServicesFramework.Auth.Data.PostgreSQL.Extensions;
using MicroServicesFramework.Auth.Data.Shared.Configuration;
using MicroServicesFramework.Auth.Data.SqlServer.Extensions;
using MicroServicesFramework.Auth.Shared.Authentication;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.DataProtection.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Skoruba.AuditLogging.EntityFramework.DbContexts;
using Skoruba.AuditLogging.EntityFramework.Entities;
using Skoruba.AuditLogging.EntityFramework.Extensions;
using Skoruba.AuditLogging.EntityFramework.Repositories;
using Skoruba.AuditLogging.EntityFramework.Services;
using Skoruba.IdentityServer4.Admin.BusinessLogic.Identity.Dtos.Identity;
using Skoruba.IdentityServer4.Admin.BusinessLogic.Services;
using Skoruba.IdentityServer4.Admin.BusinessLogic.Services.Interfaces;
using Skoruba.IdentityServer4.Admin.EntityFramework.Helpers;
using Skoruba.IdentityServer4.Admin.EntityFramework.Interfaces;
using Skoruba.IdentityServer4.Admin.EntityFramework.Repositories;
using Skoruba.IdentityServer4.Admin.EntityFramework.Repositories.Interfaces;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace MicroServicesFramework.Auth.Admin.Web.Helpers
{
    public static class StartupHelpers
    {
        public static void AddCertificateForwardingForNginx(this IServiceCollection services)
        {
            services.AddCertificateForwarding(options =>
            {
                options.CertificateHeader = "X-SSL-CERT";
                options.HeaderConverter = (headerValue) =>
                {
                    if (string.IsNullOrWhiteSpace(headerValue))
                    {
                        return null;
                    }

                    return new X509Certificate2(Encoding.UTF8.GetBytes(Uri.UnescapeDataString(headerValue)));
                };
            });
        }

        public static IIdentityServerBuilder AddSigningCredential(this IIdentityServerBuilder builder,
            string rsaFile = "./keys/identityserver.test.rsa.p12", string rsaPassword = "changeit",
            string ecdsaFile = "./keys/identityserver.test.ecdsa.p12", string ecdsaPassword = "changeit")
        {
            // create random RS256 key
            builder.AddDeveloperSigningCredential();

            // use an RSA-based certificate with RS256
            X509Certificate2 rsaCert = new X509Certificate2(rsaFile, rsaPassword);
            builder.AddSigningCredential(rsaCert, "RS256");

            // ...and PS256
            builder.AddSigningCredential(rsaCert, "PS256");

            // or manually extract ECDSA key from certificate (directly using the certificate is not support by Microsoft right now)
            X509Certificate2 ecCert = new X509Certificate2(ecdsaFile, ecdsaPassword);
            ECDsaSecurityKey key = new ECDsaSecurityKey(ecCert.GetECDsaPrivateKey())
            {
                KeyId = CryptoRandom.CreateUniqueId(16, CryptoRandom.OutputFormat.Hex)
            };

            return builder.AddSigningCredential(key, IdentityServerConstants.ECDsaSigningAlgorithm.ES256);
        }

        public static IServiceCollection AddAuditEventLogging<TAuditLoggingDbContext, TAuditLog>(this IServiceCollection services, IConfiguration configuration)
            where TAuditLog : AuditLog, new()
            where TAuditLoggingDbContext : IAuditLoggingDbContext<TAuditLog>
        {
            AuditLoggingConfiguration auditLoggingConfiguration = configuration.GetSection(nameof(AuditLoggingConfiguration)).Get<AuditLoggingConfiguration>();

            services.AddAuditLogging(options => { options.Source = auditLoggingConfiguration.Source; })
                .AddDefaultHttpEventData(subjectOptions =>
                    {
                        subjectOptions.SubjectIdentifierClaim = auditLoggingConfiguration.SubjectIdentifierClaim;
                        subjectOptions.SubjectNameClaim = auditLoggingConfiguration.SubjectNameClaim;
                    },
                    actionOptions =>
                    {
                        actionOptions.IncludeFormVariables = auditLoggingConfiguration.IncludeFormVariables;
                    })
                .AddAuditSinks<DatabaseAuditEventLoggerSink<TAuditLog>>();

            // repository for library
            services.AddTransient<IAuditLoggingRepository<TAuditLog>, AuditLoggingRepository<TAuditLoggingDbContext, TAuditLog>>();

            // repository and service for admin
            services.AddTransient<IAuditLogRepository<TAuditLog>, AuditLogRepository<TAuditLoggingDbContext, TAuditLog>>();
            services.AddTransient<IAuditLogService, AuditLogService<TAuditLog>>();

            return services;
        }

        /// <summary>
        /// Register DbContexts for IdentityServer ConfigurationStore and PersistedGrants, Identity and Logging
        /// Configure the connection strings in AppSettings.json
        /// </summary>
        /// <typeparam name="TConfigurationDbContext"></typeparam>
        /// <typeparam name="TPersistedGrantDbContext"></typeparam>
        /// <typeparam name="TLogDbContext"></typeparam>
        /// <typeparam name="TIdentityDbContext"></typeparam>
        /// <typeparam name="TAuditLoggingDbContext"></typeparam>
        /// <param name="services"></param>
        /// <param name="configuration"></param>
        public static void RegisterDbContexts<TIdentityDbContext, TConfigurationDbContext, TPersistedGrantDbContext, TLogDbContext, TAuditLoggingDbContext, TDataProtectionDbContext>(this IServiceCollection services, IConfiguration configuration)
            where TIdentityDbContext : DbContext
            where TPersistedGrantDbContext : DbContext, IAdminPersistedGrantDbContext
            where TConfigurationDbContext : DbContext, IAdminConfigurationDbContext
            where TLogDbContext : DbContext, IAdminLogDbContext
            where TAuditLoggingDbContext : DbContext, IAuditLoggingDbContext<AuditLog>
            where TDataProtectionDbContext : DbContext, IDataProtectionKeyContext
        {
            DatabaseProviderConfiguration databaseProvider = configuration.GetSection(nameof(DatabaseProviderConfiguration)).Get<DatabaseProviderConfiguration>();

            string identityConnectionString = configuration.GetConnectionString(ConfigurationConsts.IdentityDbConnectionStringKey);
            string configurationConnectionString = configuration.GetConnectionString(ConfigurationConsts.ConfigurationDbConnectionStringKey);
            string persistedGrantsConnectionString = configuration.GetConnectionString(ConfigurationConsts.PersistedGrantDbConnectionStringKey);
            string errorLoggingConnectionString = configuration.GetConnectionString(ConfigurationConsts.AdminLogDbConnectionStringKey);
            string auditLoggingConnectionString = configuration.GetConnectionString(ConfigurationConsts.AdminAuditLogDbConnectionStringKey);
            string dataProtectionConnectionString = configuration.GetConnectionString(ConfigurationConsts.DataProtectionDbConnectionStringKey);

            switch (databaseProvider.ProviderType)
            {
                case DatabaseProviderType.SqlServer:
                    services.RegisterSqlServerDbContexts<TIdentityDbContext, TConfigurationDbContext, TPersistedGrantDbContext, TLogDbContext, TAuditLoggingDbContext, TDataProtectionDbContext>(identityConnectionString, configurationConnectionString, persistedGrantsConnectionString, errorLoggingConnectionString, auditLoggingConnectionString, dataProtectionConnectionString);
                    break;
                case DatabaseProviderType.PostgreSQL:
                    services.RegisterNpgSqlDbContexts<TIdentityDbContext, TConfigurationDbContext, TPersistedGrantDbContext, TLogDbContext, TAuditLoggingDbContext, TDataProtectionDbContext>(identityConnectionString, configurationConnectionString, persistedGrantsConnectionString, errorLoggingConnectionString, auditLoggingConnectionString, dataProtectionConnectionString);
                    break;
                case DatabaseProviderType.MySql:
                    services.RegisterMySqlDbContexts<TIdentityDbContext, TConfigurationDbContext, TPersistedGrantDbContext, TLogDbContext, TAuditLoggingDbContext, TDataProtectionDbContext>(identityConnectionString, configurationConnectionString, persistedGrantsConnectionString, errorLoggingConnectionString, auditLoggingConnectionString, dataProtectionConnectionString);
                    break;

                default:
                    throw new ArgumentOutOfRangeException(nameof(databaseProvider.ProviderType), $@"The value needs to be one of {string.Join(", ", Enum.GetNames(typeof(DatabaseProviderType)))}.");
            }
        }

        /// <summary>
        /// Register in memory DbContexts for IdentityServer ConfigurationStore and PersistedGrants, Identity and Logging
        /// For testing purpose only
        /// </summary>
        /// <typeparam name="TConfigurationDbContext"></typeparam>
        /// <typeparam name="TPersistedGrantDbContext"></typeparam>
        /// <typeparam name="TLogDbContext"></typeparam>
        /// <typeparam name="TIdentityDbContext"></typeparam>
        /// <typeparam name="TAuditLoggingDbContext"></typeparam>
        /// <param name="services"></param>
        public static void RegisterDbContextsStaging<TIdentityDbContext, TConfigurationDbContext, TPersistedGrantDbContext, TLogDbContext, TAuditLoggingDbContext, TDataProtectionDbContext>(this IServiceCollection services)
            where TIdentityDbContext : DbContext
            where TPersistedGrantDbContext : DbContext, IAdminPersistedGrantDbContext
            where TConfigurationDbContext : DbContext, IAdminConfigurationDbContext
            where TLogDbContext : DbContext, IAdminLogDbContext
            where TAuditLoggingDbContext : DbContext, IAuditLoggingDbContext<AuditLog>
            where TDataProtectionDbContext : DbContext, IDataProtectionKeyContext
        {
            string persistedGrantsDatabaseName = Guid.NewGuid().ToString();
            string configurationDatabaseName = Guid.NewGuid().ToString();
            string logDatabaseName = Guid.NewGuid().ToString();
            string identityDatabaseName = Guid.NewGuid().ToString();
            string auditLoggingDatabaseName = Guid.NewGuid().ToString();
            string dataProtectionDatabaseName = Guid.NewGuid().ToString();

            OperationalStoreOptions operationalStoreOptions = new OperationalStoreOptions();
            services.AddSingleton(operationalStoreOptions);

            ConfigurationStoreOptions storeOptions = new ConfigurationStoreOptions();
            services.AddSingleton(storeOptions);

            services.AddDbContext<TIdentityDbContext>(optionsBuilder => optionsBuilder.UseInMemoryDatabase(identityDatabaseName));
            services.AddDbContext<TPersistedGrantDbContext>(optionsBuilder => optionsBuilder.UseInMemoryDatabase(persistedGrantsDatabaseName));
            services.AddDbContext<TConfigurationDbContext>(optionsBuilder => optionsBuilder.UseInMemoryDatabase(configurationDatabaseName));
            services.AddDbContext<TLogDbContext>(optionsBuilder => optionsBuilder.UseInMemoryDatabase(logDatabaseName));
            services.AddDbContext<TAuditLoggingDbContext>(optionsBuilder => optionsBuilder.UseInMemoryDatabase(auditLoggingDatabaseName));
            services.AddDbContext<TDataProtectionDbContext>(optionsBuilder => optionsBuilder.UseInMemoryDatabase(dataProtectionDatabaseName));
        }

        /// <summary>
        /// Using of Forwarded Headers, Hsts, XXssProtection and Csp
        /// </summary>
        /// <param name="app"></param>
        /// <param name="configuration"></param>
        public static void UseSecurityHeaders(this IApplicationBuilder app, IConfiguration configuration)
        {
            ForwardedHeadersOptions forwardingOptions = new ForwardedHeadersOptions()
            {
                ForwardedHeaders = ForwardedHeaders.All
            };

            forwardingOptions.KnownNetworks.Clear();
            forwardingOptions.KnownProxies.Clear();

            app.UseForwardedHeaders(forwardingOptions);

            app.UseXXssProtection(options => options.EnabledWithBlockMode());
            app.UseXContentTypeOptions();
            app.UseXfo(options => options.SameOrigin());
            app.UseReferrerPolicy(options => options.NoReferrer());


            // CSP Configuration to be able to use external resources
            List<string> cspTrustedDomains = new List<string>();
            configuration.GetSection(ConfigurationConsts.CspTrustedDomainsKey).Bind(cspTrustedDomains);
            if (cspTrustedDomains.Any())
            {
                app.UseCsp(csp =>
                {
                    csp.ImageSources(options =>
                    {
                        options.SelfSrc = true;
                        options.CustomSources = cspTrustedDomains;
                        options.Enabled = true;
                    });
                    csp.FontSources(options =>
                    {
                        options.SelfSrc = true;
                        options.CustomSources = cspTrustedDomains;
                        options.Enabled = true;
                    });
                    csp.ScriptSources(options =>
                    {
                        options.SelfSrc = true;
                        options.CustomSources = cspTrustedDomains;
                        options.Enabled = true;
                        options.UnsafeInlineSrc = true;
                        options.UnsafeEvalSrc = true;
                    });
                    csp.StyleSources(options =>
                    {
                        options.SelfSrc = true;
                        options.CustomSources = cspTrustedDomains;
                        options.Enabled = true;
                        options.UnsafeInlineSrc = true;
                    });
                    csp.DefaultSources(options =>
                    {
                        options.SelfSrc = true;
                        options.CustomSources = cspTrustedDomains;
                        options.Enabled = true;
                    });
                });
            }
        }

        /// <summary>
        /// Add middleware for localization
        /// </summary>
        /// <param name="app"></param>
        public static void ConfigureLocalization(this IApplicationBuilder app)
        {
            IOptions<RequestLocalizationOptions> options = app.ApplicationServices.GetService<IOptions<RequestLocalizationOptions>>();
            app.UseRequestLocalization(options.Value);
        }

        /// <summary>
        /// Add authorization policies
        /// </summary>
        /// <param name="services"></param>
        public static void AddAuthorizationPolicies(this IServiceCollection services, IRootConfiguration rootConfiguration)
        {
            services.AddAuthorization(options =>
            {
                options.AddPolicy(AuthorizationConsts.AdministrationPolicy,
                    policy => policy.RequireRole(rootConfiguration.AdminConfiguration.AdministrationRole));
            });
        }

        /// <summary>
        /// Add exception filter for controller
        /// </summary>
        /// <param name="services"></param>
        public static void AddMvcExceptionFilters(this IServiceCollection services)
        {
            //Exception handling
            services.AddScoped<ControllerExceptionFilterAttribute>();
        }

        /// <summary>
        /// Register services for MVC and localization including available languages
        /// </summary>
        /// <param name="services"></param>
        public static void AddMvcWithLocalization<TUserDto, TRoleDto, TUser, TRole, TKey, TUserClaim, TUserRole, TUserLogin, TRoleClaim, TUserToken,
            TUsersDto, TRolesDto, TUserRolesDto, TUserClaimsDto,
            TUserProviderDto, TUserProvidersDto, TUserChangePasswordDto, TRoleClaimsDto, TUserClaimDto, TRoleClaimDto>(this IServiceCollection services, IConfiguration configuration)
            where TUserDto : UserDto<TKey>, new()
            where TRoleDto : RoleDto<TKey>, new()
            where TUser : IdentityUser<TKey>
            where TRole : IdentityRole<TKey>
            where TKey : IEquatable<TKey>
            where TUserClaim : IdentityUserClaim<TKey>
            where TUserRole : IdentityUserRole<TKey>
            where TUserLogin : IdentityUserLogin<TKey>
            where TRoleClaim : IdentityRoleClaim<TKey>
            where TUserToken : IdentityUserToken<TKey>
            where TUsersDto : UsersDto<TUserDto, TKey>
            where TRolesDto : RolesDto<TRoleDto, TKey>
            where TUserRolesDto : UserRolesDto<TRoleDto, TKey>
            where TUserClaimsDto : UserClaimsDto<TUserClaimDto, TKey>
            where TUserProviderDto : UserProviderDto<TKey>
            where TUserProvidersDto : UserProvidersDto<TUserProviderDto, TKey>
            where TUserChangePasswordDto : UserChangePasswordDto<TKey>
            where TRoleClaimsDto : RoleClaimsDto<TRoleClaimDto, TKey>
            where TUserClaimDto : UserClaimDto<TKey>
            where TRoleClaimDto : RoleClaimDto<TKey>
        {
            services.AddSingleton<ITempDataProvider, CookieTempDataProvider>();

            services.AddLocalization(opts => { opts.ResourcesPath = ConfigurationConsts.ResourcesPath; });

            services.TryAddTransient(typeof(IGenericControllerLocalizer<>), typeof(GenericControllerLocalizer<>));

            services.AddControllersWithViews(o =>
                {
                    o.Conventions.Add(new GenericControllerRouteConvention());
                })
                .AddViewLocalization(
                    LanguageViewLocationExpanderFormat.Suffix,
                    opts => { opts.ResourcesPath = ConfigurationConsts.ResourcesPath; })
                .AddDataAnnotationsLocalization()
                .ConfigureApplicationPartManager(m =>
                {
                    m.FeatureProviders.Add(new GenericTypeControllerFeatureProvider<TUserDto, TRoleDto, TUser, TRole, TKey, TUserClaim, TUserRole, TUserLogin, TRoleClaim, TUserToken,
                        TUsersDto, TRolesDto, TUserRolesDto, TUserClaimsDto,
                        TUserProviderDto, TUserProvidersDto, TUserChangePasswordDto, TRoleClaimsDto, TUserClaimDto, TRoleClaimDto>());
                });

            CultureConfiguration cultureConfiguration = configuration.GetSection(nameof(CultureConfiguration)).Get<CultureConfiguration>();
            services.Configure<RequestLocalizationOptions>(
            opts =>
            {
                // If cultures are specified in the configuration, use them (making sure they are among the available cultures),
                // otherwise use all the available cultures
                string[] supportedCultureCodes = (cultureConfiguration?.Cultures?.Count > 0 ?
                    cultureConfiguration.Cultures.Intersect(CultureConfiguration.AvailableCultures) :
                    CultureConfiguration.AvailableCultures).ToArray();

                if (!supportedCultureCodes.Any())
                {
                    supportedCultureCodes = CultureConfiguration.AvailableCultures;
                }

                List<CultureInfo> supportedCultures = supportedCultureCodes.Select(c => new CultureInfo(c)).ToList();

                // If the default culture is specified use it, otherwise use CultureConfiguration.DefaultRequestCulture ("en")
                string defaultCultureCode = string.IsNullOrEmpty(cultureConfiguration?.DefaultCulture) ?
                    CultureConfiguration.DefaultRequestCulture : cultureConfiguration?.DefaultCulture;

                // If the default culture is not among the supported cultures, use the first supported culture as default
                if (!supportedCultureCodes.Contains(defaultCultureCode))
                {
                    defaultCultureCode = supportedCultureCodes.FirstOrDefault();
                }

                opts.DefaultRequestCulture = new RequestCulture(defaultCultureCode);
                opts.SupportedCultures = supportedCultures;
                opts.SupportedUICultures = supportedCultures;
            });
        }

        public static void AddAuthenticationServicesStaging<TContext, TUserIdentity, TUserIdentityRole>(
            this IServiceCollection services)
            where TContext : DbContext where TUserIdentity : class where TUserIdentityRole : class
        {
            services.AddIdentity<TUserIdentity, TUserIdentityRole>(options =>
                {
                    options.User.RequireUniqueEmail = true;
                })
                .AddEntityFrameworkStores<TContext>()
                .AddDefaultTokenProviders();

            services.AddAuthentication(options =>
                {
                    options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                    options.DefaultChallengeScheme = CookieAuthenticationDefaults.AuthenticationScheme;

                    options.DefaultAuthenticateScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                    options.DefaultForbidScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                    options.DefaultSignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                    options.DefaultSignOutScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                })
                .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme);
        }

        /// <summary>
        /// Register services for authentication, including Identity.
        /// For production mode is used OpenId Connect middleware which is connected to IdentityServer4 instance.
        /// For testing purpose is used cookie middleware with fake login url.
        /// </summary>
        /// <typeparam name="TContext"></typeparam>
        /// <typeparam name="TUserIdentity"></typeparam>
        /// <typeparam name="TUserIdentityRole"></typeparam>
        /// <param name="services"></param>
        /// <param name="configuration"></param>
        public static void AddAuthenticationServices<TContext, TUserIdentity, TUserIdentityRole>(this IServiceCollection services, IConfiguration configuration)
            where TContext : DbContext where TUserIdentity : class where TUserIdentityRole : class
        {
            AdminConfiguration adminConfiguration = configuration.GetSection(nameof(AdminConfiguration)).Get<AdminConfiguration>();

            services.Configure<CookiePolicyOptions>(options =>
            {
                options.MinimumSameSitePolicy = SameSiteMode.Unspecified;
                options.Secure = CookieSecurePolicy.SameAsRequest;
                options.OnAppendCookie = cookieContext =>
                    AuthenticationHelpers.CheckSameSite(cookieContext.Context, cookieContext.CookieOptions);
                options.OnDeleteCookie = cookieContext =>
                    AuthenticationHelpers.CheckSameSite(cookieContext.Context, cookieContext.CookieOptions);
            });

            services
                .AddIdentity<TUserIdentity, TUserIdentityRole>(options => configuration.GetSection(nameof(IdentityOptions)).Bind(options))
                .AddEntityFrameworkStores<TContext>()
                .AddDefaultTokenProviders();

            services.AddAntiforgery(options =>
            {
                options.SuppressXFrameOptionsHeader = true;
                options.Cookie.SameSite = SameSiteMode.Strict;
                options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
            });
            services.AddDistributedMemoryCache();
            services.AddOidcStateDataFormatterCache(AuthenticationConsts.OidcAuthenticationScheme, CookieAuthenticationDefaults.AuthenticationScheme);
            services.AddAuthentication(options =>
            {
                options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = AuthenticationConsts.OidcAuthenticationScheme;
                options.DefaultAuthenticateScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.DefaultForbidScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.DefaultSignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.DefaultSignOutScheme = CookieAuthenticationDefaults.AuthenticationScheme;
            })
                .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
                    {
                        options.ExpireTimeSpan = TimeSpan.FromHours(8);
                        options.SlidingExpiration = true;
                        options.Cookie.Name = adminConfiguration.IdentityAdminCookieName;
                        options.Events.OnSigningIn = context =>
                        {
                            context.CookieOptions.Expires = DateTimeOffset.UtcNow.AddDays(30);
                            context.Properties.IsPersistent = true;
                            return Task.CompletedTask;
                        };
                    })
                .AddOpenIdConnect(AuthenticationConsts.OidcAuthenticationScheme, options =>
                {
                    options.ProtocolValidator.RequireNonce = false;
                    options.SignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                    options.CorrelationCookie.Path = "/";
                    options.Authority = adminConfiguration.IdentityServerBaseUrl;
                    options.RequireHttpsMetadata = adminConfiguration.RequireHttpsMetadata;
                    options.ClientId = adminConfiguration.ClientId;
                    options.ClientSecret = adminConfiguration.ClientSecret;
                    options.ResponseType = adminConfiguration.OidcResponseType;

                    options.Scope.Clear();
                    foreach (string scope in adminConfiguration.Scopes)
                    {
                        options.Scope.Add(scope);
                    }

                    options.ClaimActions.MapJsonKey(adminConfiguration.TokenValidationClaimRole, adminConfiguration.TokenValidationClaimRole, adminConfiguration.TokenValidationClaimRole);

                    options.SaveTokens = true;
                    options.RemoteAuthenticationTimeout = TimeSpan.FromMinutes(15);
                    options.GetClaimsFromUserInfoEndpoint = true;

                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        NameClaimType = adminConfiguration.TokenValidationClaimName,
                        RoleClaimType = adminConfiguration.TokenValidationClaimRole
                    };

                    options.Events = new OpenIdConnectEvents
                    {
                        OnMessageReceived = context =>
                        {

                            context.Properties.IsPersistent = true;
                            context.Properties.ExpiresUtc = new DateTimeOffset(DateTime.Now.AddHours(adminConfiguration.IdentityAdminCookieExpiresUtcHours));
                            return Task.CompletedTask;
                        },
                        OnRedirectToIdentityProvider = context =>
                        {
                            context.ProtocolMessage.RedirectUri = adminConfiguration.IdentityAdminRedirectUri;
                            return Task.CompletedTask;
                        }
                    };
                });
            services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromMinutes(2);
                options.Cookie.HttpOnly = true;
                options.Cookie.SameSite = SameSiteMode.None;
                options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
            });
        }

        public static void AddIdSHealthChecks<TConfigurationDbContext, TPersistedGrantDbContext, TIdentityDbContext, TLogDbContext, TAuditLoggingDbContext, TDataProtectionDbContext>(this IServiceCollection services, IConfiguration configuration, AdminConfiguration adminConfiguration)
            where TConfigurationDbContext : DbContext, IAdminConfigurationDbContext
            where TPersistedGrantDbContext : DbContext, IAdminPersistedGrantDbContext
            where TIdentityDbContext : DbContext
            where TLogDbContext : DbContext, IAdminLogDbContext
            where TAuditLoggingDbContext : DbContext, IAuditLoggingDbContext<AuditLog>
            where TDataProtectionDbContext : DbContext, IDataProtectionKeyContext
        {
            string configurationDbConnectionString = configuration.GetConnectionString(ConfigurationConsts.ConfigurationDbConnectionStringKey);
            string persistedGrantsDbConnectionString = configuration.GetConnectionString(ConfigurationConsts.PersistedGrantDbConnectionStringKey);
            string identityDbConnectionString = configuration.GetConnectionString(ConfigurationConsts.IdentityDbConnectionStringKey);
            string logDbConnectionString = configuration.GetConnectionString(ConfigurationConsts.AdminLogDbConnectionStringKey);
            string auditLogDbConnectionString = configuration.GetConnectionString(ConfigurationConsts.AdminAuditLogDbConnectionStringKey);
            string dataProtectionDbConnectionString = configuration.GetConnectionString(ConfigurationConsts.DataProtectionDbConnectionStringKey);

            string identityServerUri = adminConfiguration.IdentityServerBaseUrl;
            IHealthChecksBuilder healthChecksBuilder = services.AddHealthChecks()
                //.AddDbContextCheck<TConfigurationDbContext>("ConfigurationDbContext")
                //.AddDbContextCheck<TPersistedGrantDbContext>("PersistedGrantsDbContext")
                //.AddDbContextCheck<TIdentityDbContext>("IdentityDbContext")
                //.AddDbContextCheck<TLogDbContext>("LogDbContext")
                //.AddDbContextCheck<TAuditLoggingDbContext>("AuditLogDbContext")
                //.AddDbContextCheck<TDataProtectionDbContext>("DataProtectionDbContext")

                .AddIdentityServer(new Uri(identityServerUri), "Identity Server");

            ServiceProvider serviceProvider = services.BuildServiceProvider();
            IServiceScopeFactory scopeFactory = serviceProvider.GetRequiredService<IServiceScopeFactory>();
            using (IServiceScope scope = scopeFactory.CreateScope())
            {
                string configurationTableName = DbContextHelpers.GetEntityTable<TConfigurationDbContext>(scope.ServiceProvider);
                string persistedGrantTableName = DbContextHelpers.GetEntityTable<TPersistedGrantDbContext>(scope.ServiceProvider);
                string identityTableName = DbContextHelpers.GetEntityTable<TIdentityDbContext>(scope.ServiceProvider);
                string logTableName = DbContextHelpers.GetEntityTable<TLogDbContext>(scope.ServiceProvider);
                string auditLogTableName = DbContextHelpers.GetEntityTable<TAuditLoggingDbContext>(scope.ServiceProvider);
                string dataProtectionTableName = DbContextHelpers.GetEntityTable<TDataProtectionDbContext>(scope.ServiceProvider);

                DatabaseProviderConfiguration databaseProvider = configuration.GetSection(nameof(DatabaseProviderConfiguration)).Get<DatabaseProviderConfiguration>();
                /*  switch (databaseProvider.ProviderType)
                 {
                     case DatabaseProviderType.SqlServer:
                         healthChecksBuilder
                             .AddSqlServer(configurationDbConnectionString, name: "ConfigurationDb",
                                 healthQuery: $"SELECT TOP 1 * FROM dbo.[{configurationTableName}]")
                             .AddSqlServer(persistedGrantsDbConnectionString, name: "PersistentGrantsDb",
                                 healthQuery: $"SELECT TOP 1 * FROM dbo.[{persistedGrantTableName}]")
                             .AddSqlServer(identityDbConnectionString, name: "IdentityDb",
                                 healthQuery: $"SELECT TOP 1 * FROM dbo.[{identityTableName}]")
                             .AddSqlServer(logDbConnectionString, name: "LogDb",
                                 healthQuery: $"SELECT TOP 1 * FROM dbo.[{logTableName}]")
                             .AddSqlServer(auditLogDbConnectionString, name: "AuditLogDb",
                                 healthQuery: $"SELECT TOP 1 * FROM dbo.[{auditLogTableName}]")
                             .AddSqlServer(dataProtectionDbConnectionString, name: "DataProtectionDb",
                                 healthQuery: $"SELECT TOP 1 * FROM dbo.[{dataProtectionTableName}]");
                         break;
                     case DatabaseProviderType.PostgreSQL:
                         healthChecksBuilder
                             .AddNpgSql(configurationDbConnectionString, name: "ConfigurationDb",
                                 healthQuery: $"SELECT * FROM \"{configurationTableName}\" LIMIT 1")
                             .AddNpgSql(persistedGrantsDbConnectionString, name: "PersistentGrantsDb",
                                 healthQuery: $"SELECT * FROM \"{persistedGrantTableName}\" LIMIT 1")
                             .AddNpgSql(identityDbConnectionString, name: "IdentityDb",
                                 healthQuery: $"SELECT * FROM \"{identityTableName}\" LIMIT 1")
                             .AddNpgSql(logDbConnectionString, name: "LogDb",
                                 healthQuery: $"SELECT * FROM \"{logTableName}\" LIMIT 1")
                             .AddNpgSql(auditLogDbConnectionString, name: "AuditLogDb",
                                 healthQuery: $"SELECT * FROM \"{auditLogTableName}\"  LIMIT 1")
                             .AddNpgSql(dataProtectionDbConnectionString, name: "DataProtectionDb",
                                 healthQuery: $"SELECT * FROM \"{dataProtectionTableName}\"  LIMIT 1");
                         break;
                 case DatabaseProviderType.MySql:
                        healthChecksBuilder
                            .AddMySql(configurationDbConnectionString, name: "ConfigurationDb")
                            .AddMySql(persistedGrantsDbConnectionString, name: "PersistentGrantsDb")
                            .AddMySql(identityDbConnectionString, name: "IdentityDb")
                            .AddMySql(logDbConnectionString, name: "LogDb")
                            .AddMySql(auditLogDbConnectionString, name: "AuditLogDb")
                            .AddMySql(dataProtectionDbConnectionString, name: "DataProtectionDb");
                        break;
                     default:
                         throw new NotImplementedException($"Health checks not defined for database provider {databaseProvider.ProviderType}");
                 }*/
            }
        }
    }
}






