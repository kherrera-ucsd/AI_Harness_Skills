---
name: ucsd-holiday-calendars
description: Share ready-to-import UC San Diego holiday and curtailment calendar (.ics) files, or build matching files for additional years when the user asks for UCSD time-off calendars.
---

# UCSD Holiday Calendars

Provide the packaged `.ics` files in `assets/` when someone asks for UCSD holiday calendars, campus closure dates, or shareable time-off invites. These are all-day events configured to show as **Out of Office** and block free/busy time in Outlook, Microsoft Teams scheduling, Google Calendar, and Apple Calendar.

## Packaged Calendars

- `assets/2026/`: Veterans Day (Nov 11), Thanksgiving (Nov 26–27), Winter Holiday (Dec 24–25), New Year Holiday (Dec 31–Jan 1), and Winter Curtailment (Dec 28–30, charged to vacation/comp/LWOP)
- `assets/2027/`: MLK Day (Jan 18), Presidents' Day (Feb 15), Farmworkers Day (Mar 26), Memorial Day (May 31), Juneteenth (Jun 18), Independence Day observed (Jul 5), Labor Day (Sep 6)

Sources: Blink [Holiday Closures](https://blink.ucsd.edu/HR/benefits/time-off/holidayclosures.html) and the [2026–2027 Academic & Administrative Calendar](https://blink.ucsd.edu/_files/Registrar/calendars/2026-2027-AcadAdmin-Calendar.pdf). Curtailment applies to the main campus only; UC San Diego Health hospitals and clinics remain open.

## Sharing With Teams

- Share files as attachments via email, Teams chat, or a shared drive. Recipients import them; importing does not send invitations.
- Outlook: File > Open & Export > Open Calendar > select the `.ics`, or drag the file onto the calendar. In Outlook on the web, use Add calendar > Upload from file.
- Google Calendar: Settings > Import & Export > Select file, then choose a destination calendar.
- Apple Calendar: File > Import, then choose a calendar.
- Each recipient imports into their own calendar, so each person's copy blocks their own free/busy. For a team-wide view, import into a shared/team calendar once instead.

## Adding Future Years

When asked for years without packaged files, pull official dates from Blink's holiday closures page or the Registrar's academic calendar PDF before generating anything. Author one all-day `VEVENT` per holiday (or one spanning event for multi-day closures) with:

- `DTSTART;VALUE=DATE` and exclusive `DTEND;VALUE=DATE` (e.g., a Nov 11 event ends Nov 12)
- `TRANSP:OPAQUE` and `X-MICROSOFT-CDO-BUSYSTATUS:OOF` so the event blocks time and shows as Out of Office
- `X-MICROSOFT-CDO-ALLDAYEVENT:TRUE` and a unique, stable `UID`
- CRLF line endings per RFC 5545

Name files `<holiday>-<year>.ics` in `assets/<year>/`, copy them into the matching `holidays-<year>/` workspace folder when one exists, and state which dates came from which source.
