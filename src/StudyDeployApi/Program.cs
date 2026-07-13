var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
	options.AddPolicy("frontend", policy =>
	{
		policy
			.AllowAnyHeader()
			.AllowAnyMethod()
			.AllowAnyOrigin();
	});
});

var app = builder.Build();

var startedAtUtc = DateTimeOffset.UtcNow;

app.UseCors("frontend");

app.MapGet("/", () =>
{
	return Results.Ok(new
	{
		name = "StudyDeployApi V5",
		purpose = "Simple WeatherForecast API for ACA and AKS learning V5",
		deploymentTarget = Environment.GetEnvironmentVariable("DEPLOYMENT_TARGET") ?? "local"
	});
});

app.MapGet("/health", () =>
{
	var uptimeSeconds = Math.Round((DateTimeOffset.UtcNow - startedAtUtc).TotalSeconds, 0);
	return Results.Ok(new { status = "ok", uptimeSeconds });
});

app.MapGet("/weatherforecast", () =>
{
	var summaries = new[]
	{
		"Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
	};

	var forecast = Enumerable.Range(1, 5).Select(index => new WeatherForecast(
		DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
		Random.Shared.Next(-20, 55),
		summaries[Random.Shared.Next(summaries.Length)]));

	return Results.Ok(forecast);
});

app.Run();

internal sealed record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
	public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
