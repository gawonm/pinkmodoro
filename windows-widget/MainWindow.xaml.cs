using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Text.Json;
using System.Windows;
using Microsoft.Web.WebView2.Core;

namespace PinkmodoroWidget;

public partial class MainWindow : Window
{
    // Point this at your own GitHub Pages URL if you fork the repo under a different owner.
    private const string SiteUrl = "https://gawonm.github.io/pinkmodoro/";

    // Mirrors the site's CSS phase accent colors (index.html's --c-focus/--c-short/--c-long)
    // and track color (--line), so the tray pie matches the in-page progress wedge.
    private static readonly Dictionary<string, Color> PhaseColors = new()
    {
        ["focus"] = Color.FromArgb(0xE0, 0xAE, 0xB2),
        ["short"] = Color.FromArgb(0xA9, 0xC0, 0xE0),
        ["long"] = Color.FromArgb(0xC3, 0xB3, 0xCA),
    };
    private static readonly Color TrackColor = Color.FromArgb(0xEC, 0xE3, 0xE6);

    private System.Windows.Forms.NotifyIcon? _trayIcon;
    private bool _isExiting;
    private IntPtr _currentTrayIconHandle = IntPtr.Zero;

    [DllImport("user32.dll")]
    private static extern bool DestroyIcon(IntPtr handle);

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

    // Receives postMessage calls from the web app's JS (window.chrome.webview.postMessage).
    //   type "notify": shows a native Windows notification via the tray icon's balloon tip,
    //     since WebView2's support for the web Notification API is unreliable.
    //   type "tray": redraws the tray icon as a progress pie matching the page's own
    //     countdown wedge (same ratio/phase/running state as updateFavicon() in index.html).
    private void CoreWebView2_WebMessageReceived(object? sender, CoreWebView2WebMessageReceivedEventArgs e)
    {
        try
        {
            using var doc = JsonDocument.Parse(e.WebMessageAsJson);
            var root = doc.RootElement;
            if (!root.TryGetProperty("type", out var typeProp)) return;

            switch (typeProp.GetString())
            {
                case "notify":
                    var title = root.TryGetProperty("title", out var t) ? t.GetString() ?? "핑크모도로" : "핑크모도로";
                    var body = root.TryGetProperty("body", out var b) ? b.GetString() ?? "" : "";
                    _trayIcon?.ShowBalloonTip(5000, title, body, System.Windows.Forms.ToolTipIcon.None);
                    break;

                case "tray":
                    var ratio = root.TryGetProperty("ratio", out var r) ? r.GetDouble() : 0;
                    var phase = root.TryGetProperty("phase", out var p) ? p.GetString() ?? "focus" : "focus";
                    var running = root.TryGetProperty("running", out var ru) && ru.GetBoolean();
                    UpdateTrayIcon(ratio, phase, running);
                    break;
            }
        }
        catch
        {
            // malformed payload from the page; ignore
        }
    }

    private void UpdateTrayIcon(double ratio, string phase, bool running)
    {
        if (_trayIcon == null) return;

        ratio = Math.Clamp(ratio, 0, 1);
        var fillColor = PhaseColors.TryGetValue(phase, out var c) ? c : PhaseColors["focus"];
        var alpha = running ? 255 : 140;

        using var bitmap = new Bitmap(32, 32);
        using (var g = Graphics.FromImage(bitmap))
        {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.Clear(Color.Transparent);

            using var trackBrush = new SolidBrush(Color.FromArgb(alpha, TrackColor));
            g.FillEllipse(trackBrush, 1, 1, 30, 30);

            if (ratio > 0.001)
            {
                using var fillBrush = new SolidBrush(Color.FromArgb(alpha, fillColor));
                var sweep = (float)(ratio * 360.0);
                g.FillPie(fillBrush, 1, 1, 30, 30, -90, sweep);
            }
        }

        // NotifyIcon.Icon doesn't take ownership of the HICON, so the previous handle must
        // be destroyed manually once the new one is assigned - otherwise this leaks a GDI
        // handle on every tick while the timer runs.
        var newHandle = bitmap.GetHicon();
        _trayIcon.Icon = System.Drawing.Icon.FromHandle(newHandle);
        if (_currentTrayIconHandle != IntPtr.Zero)
        {
            DestroyIcon(_currentTrayIconHandle);
        }
        _currentTrayIconHandle = newHandle;
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
        if (_currentTrayIconHandle != IntPtr.Zero)
        {
            DestroyIcon(_currentTrayIconHandle);
            _currentTrayIconHandle = IntPtr.Zero;
        }
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
