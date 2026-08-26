using System.IO.Ports;
using System.Threading;

namespace ZebraPrinterPortTroubleshooter.Diagnostics;

public enum ComPortState
{
    InUseByAnotherProcess,
    DoesNotExist,
    OpenedButNoResponse,
    OpenedAndResponded,
    Error
}

public sealed record ComPortResult(string PortName, ComPortState State, string Detail, string? Response);

public static class SerialPortDiagnostics
{
    public static IReadOnlyList<string> GetAvailablePortNames() =>
        SerialPort.GetPortNames().Distinct().OrderBy(NaturalPortSort).ToList();

    public static ComPortResult TestPort(string portName, int baudRate = 9600, int timeoutMs = 2000)
    {
        using var port = new SerialPort(portName, baudRate, Parity.None, 8, StopBits.One)
        {
            ReadTimeout = timeoutMs,
            WriteTimeout = timeoutMs,
            DtrEnable = true,
            RtsEnable = true
        };

        try
        {
            port.Open();
        }
        catch (UnauthorizedAccessException)
        {
            return new ComPortResult(portName, ComPortState.InUseByAnotherProcess,
                "Port is already open in another application (or a stale handle wasn't released). Close other printer software (Zebra Setup Utilities, terminal apps, another instance of this tool) and retry.",
                null);
        }
        catch (IOException ex)
        {
            return new ComPortResult(portName, ComPortState.DoesNotExist,
                $"Could not open the port ({ex.Message}). It may have been unplugged, or Windows re-numbered it after reconnecting the printer.",
                null);
        }
        catch (Exception ex)
        {
            return new ComPortResult(portName, ComPortState.Error, ex.Message, null);
        }

        try
        {
            port.DiscardInBuffer();
            port.Write("~HS\r\n");

            var response = string.Empty;
            var deadline = DateTime.UtcNow.AddMilliseconds(timeoutMs);
            while (string.IsNullOrEmpty(response) && DateTime.UtcNow < deadline)
            {
                Thread.Sleep(100);
                response = port.ReadExisting();
            }

            if (!string.IsNullOrWhiteSpace(response))
            {
                return new ComPortResult(portName, ComPortState.OpenedAndResponded,
                    "Port opened and the printer responded to a ~HS status request.", response);
            }

            return new ComPortResult(portName, ComPortState.OpenedButNoResponse,
                "Port opened but the printer did not respond to ~HS. It may be a different device on this port, powered off, asleep, or using a different baud rate.",
                null);
        }
        catch (Exception ex)
        {
            return new ComPortResult(portName, ComPortState.Error, ex.Message, null);
        }
        finally
        {
            if (port.IsOpen) port.Close();
        }
    }

    private static int NaturalPortSort(string portName)
    {
        var digits = new string(portName.Where(char.IsDigit).ToArray());
        return int.TryParse(digits, out var n) ? n : 0;
    }
}
