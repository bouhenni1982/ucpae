using System.Windows.Automation;

namespace Ucpae.AccessibilityWorker;

internal sealed class UiaEventMonitor : IDisposable
{
    public event EventHandler<ScreenEvent>? EventRaised;

    public void Start()
    {
        Automation.AddAutomationFocusChangedEventHandler(OnFocusChanged);
    }

    private void OnFocusChanged(object src, AutomationFocusChangedEventArgs args)
    {
        if (src is not AutomationElement element)
        {
            return;
        }

        var name = element.Current.Name ?? "Unnamed";
        var role = element.Current.ControlType?.ProgrammaticName?.Replace("ControlType.", "").ToLowerInvariant() ?? "control";

        EventRaised?.Invoke(this, new ScreenEvent(
            "focus",
            role,
            name,
            element.Current.AutomationId ?? string.Empty,
            "windows"));
    }

    public void Dispose()
    {
        Automation.RemoveAllEventHandlers();
    }
}

internal sealed record ScreenEvent(
    string Type,
    string Role,
    string Name,
    string PackageName,
    string SourcePlatform);
