# Enterprise Homelab

A small enterprise network built on one PC with Hyper-V, documented as if it were being handed over to a company.

**Build window:** Sep 30 to Nov 30, 2026

## What the lab contains

- Four segmented VLANs (Servers, Workstations, Management, Guest) routed by Windows Server RRAS
- Active Directory with Group Policy, service accounts, security groups and delegated permissions
- Ubuntu servers providing DNS (BIND9), DHCP (Kea), NTP (chrony) and a web server (Nginx)
- A pfSense edge firewall with VLANs, NAT, Suricata IDS/IPS and VPN access
- Wireshark analysis of DNS, DHCP, Kerberos, SMB and HTTPS traffic
- Python tools for inventory, port scanning, DNS queries, uptime monitoring and firewall log parsing
- A Wazuh SIEM with detections for failed logons, new admin accounts, PowerShell execution and port scans
- A troubleshooting challenge with deliberately injected faults

## Where things live in this repository

| Folder | What goes here |
| --- | --- |
| `docs/design/` | The network design document, written for a company audience. It grows one section per phase. |
| `docs/decisions/` | One short record per design decision: what was chosen, what was rejected, and why. |
| `docs/diagrams/` | draw.io source files, plus a PNG export of each so they display on GitHub. |
| `docs/presentation/` | The final slide decks and demo notes (Phase 9). |
| `ipam/` | The IP address management spreadsheet: every subnet, gateway, DHCP range and static address. |
| `phases/` | Day-to-day learning notes, one folder per phase, with a `screenshots/` folder in each. |
| `configs/` | Exported configuration: GPO backups, Linux service configs, the encrypted pfSense backup, Wazuh rules. |
| `scripts/` | Python and PowerShell tools, each with its own README. |
| `captures/` | Annotated Wireshark captures (`.pcapng`). |
| `detections/` | The detection register for the SOC phase. |
| `troubleshooting/` | The fault-injection script and the troubleshooting scorecard. |
| `tracking/` | Exports from ProjectLibre, Jira and ServiceNow, so the project history survives outside those tools. |

## Tools used alongside this repository

- **ProjectLibre:** schedule, milestones and baseline
- **Jira (Free):** one Epic per phase, one Story per step
- **ServiceNow Personal Developer Instance:** change requests, incidents, CMDB and knowledge articles

Notes here reference ServiceNow record numbers (for example a change number) instead of copying their contents.

## Rules for this repository

This repository is **public**. Before every commit, check that it contains none of the following:

- Passwords, API keys, or the Wazuh or pfSense admin credentials
- Private keys or certificates' private halves (`.key`, `.pem`, `.pfx`)
- The TLS key log file used to decrypt Wireshark captures
- Unencrypted pfSense configuration backups

The `.gitignore` blocks the common cases, but it is not a substitute for looking at what you stage.
