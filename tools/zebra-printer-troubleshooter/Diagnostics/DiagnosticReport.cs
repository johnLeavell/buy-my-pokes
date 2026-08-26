using System.Text;

namespace ZebraPrinterPortTroubleshooter.Diagnostics;

public sealed class DiagnosticReport
{
    private readonly StringBuilder _builder = new();

    public DiagnosticReport()
    {
        _builder.AppendLine("Zebra Printer Port Troubleshooter - Diagnostic Report");
        _builder.AppendLine($"Generated: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
        _builder.AppendLine(new string('=', 60));
    }

    public void AddSection(string title, IEnumerable<string> lines)
    {
        _builder.AppendLine();
        _builder.AppendLine(title);
        _builder.AppendLine(new string('-', title.Length));
        foreach (var line in lines)
        {
            _builder.AppendLine(line);
        }
    }

    public string Save()
    {
        var path = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.Desktop),
            $"ZebraPortDiagnostics_{DateTime.Now:yyyyMMdd_HHmmss}.txt");
        File.WriteAllText(path, _builder.ToString());
        return path;
    }
}
