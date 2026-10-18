# Traffic policy

**Default rule: anything not listed below is blocked.**

## Rules
| From | To | Allowed | Why |
|---|---|---|---|
| Workstations | Servers | AD, DNS, NTP, file shares (SMB), HTTPS | Users need to log in, look up names, get the time, open shared files and use the intranet. |
| Workstations | Workstations | Nothing | Stops malware spreading from one PC to the next. |
| Workstations | Internet | Web browsing | ... |
| Servers | Internet | Updates only | ... |
| Management | Servers, Workstations, Guest | Admin tools (RDP, SSH, WinRM, HTTPS) | ... |
| Servers, Workstations | Management | Wazuh agent traffic only (TCP 1514, 1515 to SIEM01) | Every machine sends its logs to the SIEM. Nothing else should reach the admin network. |
| Guest | Anything internal | Nothing | ... |
| Guest | Guest | Nothing | ... |
| Guest | Internet | Web browsing, public DNS | Visitors get internet, nothing more. |
| VPN users | (decided in Phase 4) | | |

## Summary
Management is the most trusted network because it controls everything else, so almost nothing is allowed into it. Guest is the least trusted, so it can only reach the internet. Workstations get only the specific server services employees need, and nothing is allowed unless there's a reason.