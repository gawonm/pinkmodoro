# PINKMODORO — Context

Live: https://gawonm.github.io/pinkmodoro/ (GitHub Pages, deployed from this repo's `index.html` / `pomodoro-timer.html` / `sw.js` / `manifest.json`)

## Gotcha: recording demos of the live site with Claude-in-Chrome

The live production URL is a real, user-facing site whose `localStorage` holds the
user's actual usage data (checklist items, notes, session log). Claude-in-Chrome
operates on the user's real logged-in Chrome profile, not an isolated sandbox — so
any demo/GIF recording session against the live URL (task input, notes popover,
checklist, quick-start, session log, etc.) will write test/dummy entries directly
into that real `localStorage`.

**Practice:** after every Claude-in-Chrome recording/testing session against the
live site, clear `localStorage` on https://gawonm.github.io/pinkmodoro/ before
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
