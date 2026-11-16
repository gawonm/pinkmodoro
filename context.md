# PINKMODORO — Context

Live: https://pinkmodoro.vercel.app/ (Vercel, primary — canonical / og:url point here)
Old: https://gawonm.github.io/pinkmodoro/ (GitHub Pages, still deployed from the same files: `index.html` / `pomodoro-timer.html` / `sw.js` / `manifest.json`)

Both addresses serve the same `index.html`. localStorage is per-origin, so the old address shows a
"we moved" banner that hands its records to the new address via postMessage (see "Moving to the new
address" in `index.html`). The macOS/Windows widgets still load the old address on purpose so their
existing records stay; the banner is hidden inside the widgets.

## Gotcha: recording demos of the live site with Claude-in-Chrome

The live production URL is a real, user-facing site whose `localStorage` holds the
user's actual usage data (checklist items, notes, session log). Claude-in-Chrome
operates on the user's real logged-in Chrome profile, not an isolated sandbox — so
any demo/GIF recording session against the live URL (task input, notes popover,
checklist, quick-start, session log, etc.) will write test/dummy entries directly
into that real `localStorage`.

**Practice:** after every Claude-in-Chrome recording/testing session against the
live site, clear `localStorage` on the address you tested (https://pinkmodoro.vercel.app/ or the old https://gawonm.github.io/pinkmodoro/) before
ending the session, so dummy demo data doesn't get mixed into the user's real
usage history. Do this via the same real browser (Claude-in-Chrome), not the
sandboxed Browser pane.

## Gotcha: `resize_window` doesn't actually reflow the page

`mcp__claude-in-chrome__resize_window` reports success but does not change the
page's actual rendered viewport in this environment (`window.innerWidth` stays at
the desktop width regardless). Don't rely on it to produce a mobile/vertical
layout for recording. Instead, record at the normal desktop size and convert to
vertical afterward (crop + blurred-background letterbox) — see
`scripts/make_vertical_gif.py` if it exists, or recreate the same approach.
