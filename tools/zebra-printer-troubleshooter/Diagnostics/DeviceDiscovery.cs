using System.Management;

namespace ZebraPrinterPortTroubleshooter.Diagnostics;

public sealed record ZebraDeviceInfo(string Name, string DeviceId, string Status, string PnpClass, string? ComPort);

public static class DeviceDiscovery
{
    public static List<ZebraDeviceInfo> FindZebraDevices()
    {
        var results = new List<ZebraDeviceInfo>();
        using var searcher = new ManagementObjectSearcher(
            "SELECT Name, DeviceID, Status, PNPClass FROM Win32_PnPEntity WHERE Name LIKE '%Zebra%'");

        foreach (ManagementObject device in searcher.Get())
        {
            var name = device["Name"]?.ToString() ?? "(unknown)";
            var deviceId = device["DeviceID"]?.ToString() ?? "(unknown)";
            var status = device["Status"]?.ToString() ?? "(unknown)";
            var pnpClass = device["PNPClass"]?.ToString() ?? "(unknown)";

            results.Add(new ZebraDeviceInfo(name, deviceId, status, pnpClass, ExtractComPort(name)));
        }

        return results;
    }

    private static string? ExtractComPort(string deviceName)
    {
        var start = deviceName.LastIndexOf("(COM", StringComparison.OrdinalIgnoreCase);
        if (start < 0) return null;

        var end = deviceName.IndexOf(')', start);
        return end < 0 ? null : deviceName.Substring(start + 1, end - start - 1);
    }
}
