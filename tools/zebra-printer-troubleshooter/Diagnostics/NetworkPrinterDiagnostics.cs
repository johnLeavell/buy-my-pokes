using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text;

namespace ZebraPrinterPortTroubleshooter.Diagnostics;

public sealed record PingResult(bool Success, string Detail);

public sealed record TcpPortResult(bool Success, string Detail);

public static class NetworkPrinterDiagnostics
{
    public static PingResult TestPing(string host, int timeoutMs = 2000)
    {
        try
        {
            using var ping = new Ping();
            var reply = ping.Send(host, timeoutMs);
            return reply.Status == IPStatus.Success
                ? new PingResult(true, $"Reply from {reply.Address} in {reply.RoundtripTime} ms")
                : new PingResult(false,
                    $"Ping failed: {reply.Status}. The printer may be off, asleep, on a different subnet/VLAN, or blocking ICMP.");
        }
        catch (Exception ex)
        {
            return new PingResult(false, $"Could not ping host: {ex.Message}");
        }
    }

    public static TcpPortResult TestTcpPort(string host, int port, int timeoutMs = 3000)
    {
        using var client = new TcpClient();
        try
        {
            if (!client.ConnectAsync(host, port).Wait(timeoutMs))
            {
                return new TcpPortResult(false,
                    $"Timed out connecting to {host}:{port}. Check the printer's IP, that it's on the same network, and that no firewall is blocking the port.");
            }

            return new TcpPortResult(true, $"Successfully connected to {host}:{port}.");
        }
        catch (Exception ex)
        {
            return new TcpPortResult(false, $"Connection to {host}:{port} failed: {ex.GetBaseException().Message}");
        }
    }

    public static string? SendStatusQuery(string host, int port, int timeoutMs = 3000)
    {
        using var client = new TcpClient();
        try
        {
            if (!client.ConnectAsync(host, port).Wait(timeoutMs)) return null;

            using var stream = client.GetStream();
            stream.WriteTimeout = timeoutMs;
            stream.ReadTimeout = timeoutMs;

            var payload = Encoding.ASCII.GetBytes("~HS\r\n");
            stream.Write(payload, 0, payload.Length);

            var buffer = new byte[4096];
            var read = stream.Read(buffer, 0, buffer.Length);
            return read > 0 ? Encoding.ASCII.GetString(buffer, 0, read) : null;
        }
        catch
        {
            return null;
        }
    }
}
