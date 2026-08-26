using ZebraPrinterPortTroubleshooter.Diagnostics;

var report = new DiagnosticReport();

while (true)
{
    PrintMenu();
    var choice = Console.ReadLine()?.Trim();

    switch (choice)
    {
        case "1":
            RunDeviceDiscovery();
            break;
        case "2":
            RunComPortDiagnostics();
            break;
        case "3":
            RunNetworkDiagnostics();
            break;
        case "4":
            RunPrintQueueDiagnostics();
            break;
        case "5":
            var path = report.Save();
            Console.WriteLine($"\nReport saved to: {path}\n");
            break;
        case "0":
        case "q":
        case "Q":
            return;
        default:
            Console.WriteLine("Unrecognized option.\n");
            break;
    }
}

void PrintMenu()
{
    Console.WriteLine("Zebra Mobile Printer - Windows Port Troubleshooter");
    Console.WriteLine("1) Discover Zebra devices (USB / Bluetooth / drivers)");
    Console.WriteLine("2) List and test COM/serial ports");
    Console.WriteLine("3) Test a network printer (Wi-Fi / Ethernet)");
    Console.WriteLine("4) Check Windows print queue and driver status");
    Console.WriteLine("5) Save diagnostic report to Desktop");
    Console.WriteLine("0) Exit");
    Console.Write("> ");
}

void RunDeviceDiscovery()
{
    Console.WriteLine("\nScanning Windows Plug and Play devices for 'Zebra'...\n");

    List<ZebraDeviceInfo> devices;
    try
    {
        devices = DeviceDiscovery.FindZebraDevices();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Could not query Windows device management (WMI): {ex.Message}\n");
        return;
    }

    if (devices.Count == 0)
    {
        Console.WriteLine("No Zebra devices found. Check that the printer is powered on, connected " +
                           "(USB cable / paired over Bluetooth), and that its driver is installed.\n");
        report.AddSection("Device Discovery", new[] { "No Zebra devices found." });
        return;
    }

    var lines = new List<string>();
    foreach (var device in devices)
    {
        var portInfo = device.ComPort is not null ? $" -> {device.ComPort}" : "";
        var line = $"[{device.Status}] {device.Name}{portInfo}  (Class: {device.PnpClass})";
        Console.WriteLine(line);
        lines.Add(line);
    }

    Console.WriteLine();
    report.AddSection("Device Discovery", lines);
}

void RunComPortDiagnostics()
{
    var ports = SerialPortDiagnostics.GetAvailablePortNames();
    if (ports.Count == 0)
    {
        Console.WriteLine("\nNo COM ports found on this system.\n");
        report.AddSection("COM Port Tests", new[] { "No COM ports found." });
        return;
    }

    Console.WriteLine($"\nFound {ports.Count} COM port(s): {string.Join(", ", ports)}");
    Console.Write("Test all of them? (Y/n): ");
    var testAll = Console.ReadLine()?.Trim().ToLowerInvariant() != "n";

    var targets = ports;
    if (!testAll)
    {
        Console.Write("Enter port name to test (e.g. COM5): ");
        var single = Console.ReadLine()?.Trim();
        if (string.IsNullOrWhiteSpace(single))
        {
            Console.WriteLine("No port entered.\n");
            return;
        }

        targets = new List<string> { single };
    }

    var lines = new List<string>();
    foreach (var portName in targets)
    {
        Console.WriteLine($"\nTesting {portName}...");
        var result = SerialPortDiagnostics.TestPort(portName);
        Console.WriteLine($"  State: {result.State}");
        Console.WriteLine($"  {result.Detail}");
        if (result.Response is not null)
        {
            Console.WriteLine($"  Printer response: {result.Response.Trim()}");
        }

        lines.Add($"{portName}: {result.State} - {result.Detail}" +
                  (result.Response is not null ? $" | Response: {result.Response.Trim()}" : ""));
    }

    Console.WriteLine();
    report.AddSection("COM Port Tests", lines);
}

void RunNetworkDiagnostics()
{
    Console.Write("\nEnter printer IP address or hostname: ");
    var host = Console.ReadLine()?.Trim();
    if (string.IsNullOrWhiteSpace(host))
    {
        Console.WriteLine("No host entered.\n");
        return;
    }

    var lines = new List<string>();

    var ping = NetworkPrinterDiagnostics.TestPing(host);
    Console.WriteLine($"\nPing {host}: {(ping.Success ? "OK" : "FAILED")} - {ping.Detail}");
    lines.Add($"Ping {host}: {(ping.Success ? "OK" : "FAILED")} - {ping.Detail}");

    foreach (var port in new[] { 6101, 9100 })
    {
        var tcp = NetworkPrinterDiagnostics.TestTcpPort(host, port);
        Console.WriteLine($"TCP {host}:{port}: {(tcp.Success ? "OPEN" : "CLOSED/BLOCKED")} - {tcp.Detail}");
        lines.Add($"TCP {host}:{port}: {(tcp.Success ? "OPEN" : "CLOSED/BLOCKED")} - {tcp.Detail}");

        if (!tcp.Success)
        {
            continue;
        }

        var status = NetworkPrinterDiagnostics.SendStatusQuery(host, port);
        if (status is null)
        {
            continue;
        }

        Console.WriteLine($"  Printer responded to ~HS on port {port}: {status.Trim()}");
        lines.Add($"  ~HS response on {port}: {status.Trim()}");
    }

    Console.WriteLine("\nNotes: Zebra printers typically listen on TCP 6101 (native printing) and " +
                       "sometimes 9100 (raw/JetDirect-style). If both are closed, check the printer's " +
                       "network settings menu, confirm it has a valid IP on the same subnet, and check " +
                       "for firewalls between this PC and the printer.\n");
    report.AddSection($"Network Test ({host})", lines);
}

void RunPrintQueueDiagnostics()
{
    Console.WriteLine("\nChecking Windows printers and print queue for Zebra devices...\n");

    List<PrinterInfo> printers;
    try
    {
        printers = PrintQueueDiagnostics.GetZebraPrinters();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Could not query Windows print system (WMI): {ex.Message}\n");
        return;
    }

    if (printers.Count == 0)
    {
        Console.WriteLine("No Zebra printers installed in Windows. Install the Zebra printer driver " +
                           "(Zebra Setup Utilities / ZDesigner driver) and add the printer using the correct port.\n");
        report.AddSection("Print Queue", new[] { "No Zebra printers installed." });
        return;
    }

    var lines = new List<string>();
    foreach (var printer in printers)
    {
        var flags = new List<string>();
        if (printer.Default) flags.Add("DEFAULT");
        if (printer.WorkOffline) flags.Add("SET TO WORK OFFLINE");

        var line = $"{printer.Name} -> Port: {printer.PortName}, Driver: {printer.DriverName}, " +
                   $"Status: {printer.PrinterStatus}, Jobs queued: {printer.JobCount}" +
                   (flags.Count > 0 ? $" [{string.Join(", ", flags)}]" : "");
        Console.WriteLine(line);
        lines.Add(line);

        if (printer.WorkOffline)
        {
            Console.WriteLine("  -> This printer is set to 'Work Offline' in Windows. Right-click it in " +
                               "Settings > Printers & scanners and turn this off.");
        }

        if (printer.JobCount > 3)
        {
            Console.WriteLine("  -> Multiple jobs are stuck in the queue. Try clearing it: open services.msc " +
                               "and restart 'Print Spooler', or from an elevated prompt run:");
            Console.WriteLine("     net stop spooler && del /Q %systemroot%\\System32\\spool\\PRINTERS\\* && net start spooler");
        }
    }

    Console.WriteLine();
    report.AddSection("Print Queue", lines);
}
