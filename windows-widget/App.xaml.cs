using System;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Threading;

namespace PinkmodoroWidget;

public partial class App : Application
{
    // Without these, an exception on the WPF dispatcher thread (e.g. inside an
    // async void event handler) crashes the whole process with no dialog and
    // no log - exactly what happened before this was added (Windows Event
    // Viewer showed 0xc000041d, STATUS_FATAL_USER_CALLBACK_EXCEPTION, with no
    // indication of which line threw). Now it shows what broke instead.
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        DispatcherUnhandledException += (_, args) =>
        {
            System.Windows.MessageBox.Show(
                args.Exception.ToString(),
                "핑크모도로 위젯 오류",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
            args.Handled = true;
        };

        AppDomain.CurrentDomain.UnhandledException += (_, args) =>
        {
            System.Windows.MessageBox.Show(
                (args.ExceptionObject as Exception)?.ToString() ?? args.ExceptionObject?.ToString() ?? "알 수 없는 오류",
                "핑크모도로 위젯 오류 (치명적)",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
        };

        TaskScheduler.UnobservedTaskException += (_, args) =>
        {
            args.SetObserved();
        };
    }
}
