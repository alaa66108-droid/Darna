using Darana.Data;
using Darana.Support;
using Darana.Support.Exceptions;
using Darana.Support.Http;
using Darana.Support.Middleware;
using Darana.Support.Providers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConsoleKernel = Darana.Support.Console.Kernel;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(o => o.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddMemoryCache();
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(o =>
{
    o.Cookie.Name = builder.Configuration["Session:Cookie"] ?? "darana_session";
    o.Cookie.HttpOnly = true;
    o.IdleTimeout = TimeSpan.FromMinutes(builder.Configuration.GetValue("Session:Lifetime", 120));
});
builder.Services.AddHttpContextAccessor();
builder.Services.AddSingleton<RateLimiter>();

builder.Services.AddLocalization(o => o.ResourcesPath = "Resources");

builder.Services.AddCors();

builder.Services.AddAppServiceProvider(builder.Configuration);
builder.Services.AddAuthServiceProvider();
builder.Services.AddRouteServiceProvider();

builder.Services.AddControllersWithViews(o =>
{
    o.Filters.Add<TrimStrings>();
    o.Filters.Add<Handler>();
    o.Filters.Add(new AutoValidateAntiforgeryTokenAttribute());
    o.SuppressImplicitRequiredAttributeForNonNullableReferenceTypes = true;
})
.AddViewLocalization()
.AddSessionStateTempDataProvider();

builder.Services.AddAntiforgery(o =>
{
    o.FormFieldName = VerifyCsrfToken.FormFieldName;
    o.HeaderName = VerifyCsrfToken.HeaderName;
});

builder.WebHost.ConfigureKestrel(k => k.Limits.MaxRequestBodySize = 6 * 10240L * 1024);

var app = builder.Build();

Mailer.Logger = app.Services.GetRequiredService<ILoggerFactory>().CreateLogger("Darana.Mail");
Simulate.Http = app.Services.GetRequiredService<IHttpContextAccessor>();
Simulate.Env = app.Environment;
Portfolio.WebRoot = app.Environment.WebRootPath ?? Path.Combine(app.Environment.ContentRootPath, "wwwroot");
SignedUrl.Key = app.Configuration["App:Key"] ?? "";

if (ConsoleKernel.Handle(args, app.Services))
{
    return;
}

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/");
}

app.UseKernelMiddleware();
app.UseStaticFiles();

app.Use(async (ctx, next) =>
{
    if (HttpMethods.IsPost(ctx.Request.Method) && ctx.Request.HasFormContentType)
    {
        var spoof = (await ctx.Request.ReadFormAsync())["_method"].ToString().ToUpperInvariant();
        if (spoof is "PUT" or "PATCH" or "DELETE") ctx.Request.Method = spoof;
    }

    await next();
});

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
