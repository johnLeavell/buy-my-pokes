# Zebra Mobile Printer - Windows Port Troubleshooter

A small C# console app for diagnosing the port issues that are most common
with Zebra mobile printers (ZQ, QLn, ZQ5xx, etc.) on Windows: USB/CDC and
Bluetooth SPP virtual COM ports, Wi-Fi/Ethernet TCP ports, and the Windows
print queue/driver configuration.

This app is Windows-only and unrelated to the Rails application in this
repository; it lives under `tools/` as a standalone utility.

## Requirements

- Windows 10/11
- [.NET 8 SDK](https://dotnet.microsoft.com/download)

## Build and run

```
cd tools/zebra-printer-troubleshooter
dotnet run
```

To produce a single portable `.exe` you can copy to another machine:

```
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

The output will be in `bin/Release/net8.0-windows/win-x64/publish/`.

## What it checks

1. **Device discovery** - scans Windows Plug and Play devices for anything
   named "Zebra" (USB, Bluetooth, network) and shows the COM port Windows
   assigned it, if any.
2. **COM/serial port tests** - lists all COM ports on the system and, for
   each one, tries to open it and send a `~HS` (host status) ZPL command.
   Reports whether the port is free, already in use by another app/driver,
   missing/unplugged, or responded correctly.
3. **Network printer test** - pings a given IP/hostname and checks whether
   TCP ports 6101 (Zebra's native printing port) and 9100 (raw/JetDirect
   style) are reachable, sending a `~HS` query if a connection succeeds.
4. **Print queue check** - looks at printers installed in Windows whose name
   or driver mentions Zebra/ZDesigner, reporting the assigned port, driver,
   status, "Work Offline" flag, and how many jobs are stuck in the queue.
5. **Save report** - writes everything collected in the session to a
   timestamped text file on the Desktop, handy for attaching to an IT or
   Zebra support ticket.

## Common root causes this tool helps surface

- Printer's virtual COM port changed after a reconnect/re-pair (device
  discovery + COM port list).
- Port held open by another process, e.g. Zebra Setup Utilities or a stale
  handle from a crashed app (`InUseByAnotherProcess` state).
- Wrong port selected in the application/driver vs. what Windows assigned.
- Printer set to "Work Offline" in Windows.
- Print Spooler stuck with queued jobs.
- Network printer unreachable due to wrong IP, wrong subnet, or a firewall
  blocking port 6101/9100.
