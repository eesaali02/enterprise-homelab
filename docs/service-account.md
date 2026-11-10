\# Service account register



Every non-human account in corp.lab.internal. Passwords are never written here. Classic account passwords are stored only in KeePassXC.



| Account | Type | Owner | Purpose | Where used | SPN | Password rotation |

|---|---|---|---|---|---|---|

| svc-web | Classic user account | Eesa Ali | Runs the intranet web service | LNX-WEB01 (Phase 3) | HTTP/lnx-web01.corp.lab.internal | Manual: yearly, and when anyone who knew it leaves. Never expires (to avoid outages). |

| gmsa-uptime$ | Group Managed Service Account | Eesa Ali | Runs the uptime monitor scheduled task | MGMT01 (Phase 6) | None | Automatic by Windows every 30 days |



Rules:

\* New service accounts go in CORP > Service Accounts and are added to this register the same day.

\* Prefer a gMSA whenever the software supports it.

\* Service accounts are denied interactive logon by Group Policy (GPO\_SVC\_DenyLogon, Task 9).

