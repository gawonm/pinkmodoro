using System;
using System.ComponentModel;
using System.Text.Json;
using System.Windows;
using Microsoft.Web.WebView2.Core;

namespace PinkmodoroWidget;

public partial class MainWindow : Window
{
    // Point this at your own GitHub Pages URL if you fork the repo under a different owner.
    private const string SiteUrl = "https://gawonm.github.io/pinkmodoro/";

    private System.Windows.Forms.NotifyIcon? _trayIcon;
    private bool _isExiting;

    public MainWindow()
    {
        InitializeComponent();
        SetupTrayIcon();
        Loaded += MainWindow_Loaded;
    }

    private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        await webView.EnsureCoreWebView2Async();
        webView.CoreWebView2.Navigate(SiteUrl);
        webView.CoreWebView2.WebMessageReceived += CoreWebView2_WebMessageReceived;
        webView.CoreWebView2.DocumentTitleChanged += CoreWebView2_DocumentTitleChanged;
    }

    // Mirrors the page's document.title (e.g. "24:59 · 집중" while running, or
    // "핑크모도로" when idle) into the tray icon's tooltip text. Windows shows
    // this automatically on hover and hides it when the pointer leaves, so no
    // custom hover-tracking code is needed.
    private void CoreWebView2_DocumentTitleChanged(object? sender, object e)
    {
        if (_trayIcon == null) return;
        var title = webView.CoreWebView2.DocumentTitle;
        if (string.IsNullOrEmpty(title)) return;
        _trayIcon.Text = title.Length > 60 ? title[..60] : title;
    }

    // Receives postMessage calls from the web app's JS (window.chrome.webview.postMessage)
    // and shows a native Windows notification via the tray icon's balloon tip, since
    // WebView2's support for the web Notification API is unreliable.
    private void CoreWebView2_WebMessageReceived(object? sender, CoreWebView2WebMessageReceivedEventArgs e)
    {
        try
        {
            using var doc = JsonDocument.Parse(e.WebMessageAsJson);
            var root = doc.RootElement;
            if (root.TryGetProperty("type", out var typeProp) && typeProp.GetString() == "notify")
            {
                var title = root.TryGetProperty("title", out var t) ? t.GetString() ?? "핑크모도로" : "핑크모도로";
                var body = root.TryGetProperty("body", out var b) ? b.GetString() ?? "" : "";
                _trayIcon?.ShowBalloonTip(5000, title, body, System.Windows.Forms.ToolTipIcon.None);
            }
        }
        catch
        {
            // malformed payload from the page; ignore
        }
    }

    private void SetupTrayIcon()
    {
        _trayIcon = new System.Windows.Forms.NotifyIcon
        {
            Icon = new System.Drawing.Icon("Assets/AppIcon.ico"),
            Visible = true,
            Text = "핑크모도로"
        };

        var menu = new System.Windows.Forms.ContextMenuStrip();
        menu.Items.Add("열기/숨기기", null, (_, _) => ToggleVisibility());
        menu.Items.Add("종료", null, (_, _) => ExitApp());
        _trayIcon.ContextMenuStrip = menu;

        _trayIcon.DoubleClick += (_, _) => ToggleVisibility();
    }

    private void ToggleVisibility()
    {
        if (IsVisible)
        {
            Hide();
        }
        else
        {
            Show();
            WindowState = WindowState.Normal;
            Activate();
        }
    }

    private void ExitApp()
    {
        _isExiting = true;
        _trayIcon?.Dispose();
        Close();
    }

    protected override void OnStateChanged(EventArgs e)
    {
        if (WindowState == WindowState.Minimized)
        {
            Hide();
        }
        base.OnStateChanged(e);
    }

    protected override void OnClosing(CancelEventArgs e)
    {
        if (!_isExiting)
        {
            e.Cancel = true;
            Hide();
            return;
        }
        base.OnClosing(e);
    }
}
