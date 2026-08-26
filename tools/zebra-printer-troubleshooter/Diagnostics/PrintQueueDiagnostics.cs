using System.Management;

namespace ZebraPrinterPortTroubleshooter.Diagnostics;

public sealed record PrinterInfo(
    string Name,
    string PortName,
    string DriverName,
    bool WorkOffline,
    bool Default,
    string PrinterStatus,
    int JobCount);

public static class PrintQueueDiagnostics
{
    public static List<PrinterInfo> GetZebraPrinters()
    {
        var printers = new List<PrinterInfo>();
        using var searcher = new ManagementObjectSearcher(
            "SELECT Name, PortName, DriverName, WorkOffline, Default, PrinterStatus FROM Win32_Printer " +
            "WHERE Name LIKE '%Zebra%' OR DriverName LIKE '%Zebra%' OR DriverName LIKE '%ZDesigner%'");

        foreach (ManagementObject printer in searcher.Get())
        {
            var name = printer["Name"]?.ToString() ?? "(unknown)";
            printers.Add(new PrinterInfo(
                name,
                printer["PortName"]?.ToString() ?? "(unknown)",
                printer["DriverName"]?.ToString() ?? "(unknown)",
                printer["WorkOffline"] is bool workOffline && workOffline,
                printer["Default"] is bool isDefault && isDefault,
                DescribeStatus(printer["PrinterStatus"]),
                GetJobCount(name)));
        }

        return printers;
    }

    private static string DescribeStatus(object? status) => Convert.ToInt32(status ?? -1) switch
    {
        3 => "Idle",
        4 => "Printing",
        5 => "Warmup",
        6 => "Stopped printing",
        7 => "Offline",
        _ => status?.ToString() ?? "Unknown"
    };

    private static int GetJobCount(string printerName)
    {
        var escaped = printerName.Replace("\\", "\\\\").Replace("'", "\\'");
        using var searcher = new ManagementObjectSearcher(
            $"SELECT __RELPATH FROM Win32_PrintJob WHERE Name LIKE '{escaped},%'");
        return searcher.Get().Count;
    }
}
