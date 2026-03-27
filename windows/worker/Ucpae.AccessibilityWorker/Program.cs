using System.Text.Json;

namespace Ucpae.AccessibilityWorker;

internal static class Program
{
    private static async Task Main()
    {
        using var monitor = new UiaEventMonitor();
        monitor.EventRaised += async (_, screenEvent) =>
        {
            var json = JsonSerializer.Serialize(screenEvent);
            await Console.Out.WriteLineAsync(json);
            await Console.Out.FlushAsync();
        };

        monitor.Start();
        await Task.Delay(Timeout.InfiniteTimeSpan);
    }
}
