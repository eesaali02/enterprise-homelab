## 2026-11-02 – Identity design and change
* Wrote the Identity section of docs/network-design.md before building anything: OU tree, naming standards, AGDLP group model and GPO inventory.
* Raised change CHG0030004 "Build Active Directory domain corp.lab.internal (Phase 2)", approved by Network group and CAB, moved to Implement.

## 2026-11-04 – Built DC01
* Gen 2, 2 vCPU, 2 GB dynamic RAM (min 1.5, max 3 GB), 60 GB disk, LAB-CORE VLAN 10.
* Windows Server 2025 Standard Evaluation (Desktop Experience).
* Static IP 10.10.10.10/24, gateway 10.10.10.1, DNS 127.0.0.1 (it will be its own DNS server once promoted).
* Checkpoint "CHG0030004-pre-promotion" taken (backout plan).

## 2026-11-04 – Promoted DC01
* Installed AD DS + DNS, created new forest corp.lab.internal (NetBIOS name CORP).
* DSRM password stored in KeePassXC only (it's the emergency repair password for AD).
* Domain admin login: CORP\Administrator.
* Checked: Get-ADDomain shows corp.lab.internal, DC01 is a Global Catalog at 10.10.10.10.
![DCO1 Promoted](screenshots/dc01-promoted.png)

## 2026-11-04 – AD and DNS health
* dcdiag issue: "DC01 is not advertising as a time server" (Advertising + LocatorCheck failed).
  - Why it matters: Kerberos logins fail if a PC's clock is more than 5 minutes off the DC.
  - Cause: Hyper-V time sync was overriding the DC's clock, and the DC wasn't set as a reliable source.
  - Fix: disabled Hyper-V Time Synchronization for DC01 (Microsoft best practice for virtual DCs), then w32tm /config /manualpeerlist:"time.windows.com,0x8 pool.ntp.org,0x8" /syncfromflags:manual /reliable:yes /update.
* DFSREvent and SystemLog errors were from the first boot after promotion. They clear after 24 hours.

* SRV record _ldap._tcp.dc._msdcs.corp.lab.internal points to DC01 on port 389. This is how clients find a domain controller, which is why failed domain joins are usually DNS problems.
![Resolve DNS Name](screenshots/resolve-dns-name.png)
* Reverse lookup zones added for 10.10.10, 10.10.20, 10.10.30, plus a PTR record for DC01.
![Reverse Lookup Records](screenshots/reverse-lookup-zones.png)
* DNS forwarders: 1.1.1.1 and 8.8.8.8 (CORE-RTR01 doesn't run DNS). To be changed to LNX-SVC01 in Phase 3.
* Tests: google.com resolves, 10.10.10.10 reverse-resolves to DC01.
![DNS Forwarders](screenshots/set-dns-forwarders.png)

## 2026-11-04 - Build the OU tree
* Created CORP and its five children in the GUI to match the design doc (docs\netowrk-desing.md).
![CORP OU and Children](screenshots/corp-and-children.png)
 *Created sub OU's beneath Users and Computers using PowerShell.
![Sub OU's](screenshots\sub-ous.png)
*Redirected new computers by default to the workstations OU using DN (Distinguished Name) that maps the path to the OU.
![Redirect Computers](screenshots/redirect-computers.png)
![Final OU Tree](screenshots/ou-tree.png)

## 2026-11-05 – Users and groups (AGDLP)

### Users
* Created sarah.khan by hand in ADUC first, to see every field a new user needs.
* Created the rest with scripts/powershell/New-LabUsers.ps1, which reads scripts/powershell/users.csv (FirstName, LastName, Department) and creates each user in their department OU.
  - Logon name built as first.last (lower case), UPN first.last@corp.lab.internal.
  - Starting password typed in at runtime with Read-Host -AsSecureString, never stored in the script or the CSV.
  - Accounts enabled, and must change password at first logon.
  - Tested with -WhatIf before running for real.
* Copied the files into DC01 with Copy-VMFile (later, scripts will run from MGMT01).
![Users created](screenshots/users-created.png)

### Groups
| Group | Scope | Type | Members |
|---|---|---|---|
| GG_Finance_Staff / GG_HR_Staff / GG_Sales_Staff / GG_IT_Staff | Global | Security | Users from each department OU |
| GG_Helpdesk | Global | Security | One IT user (for Task 7) |
| DL_FinanceShare_RW | Domain Local | Security | GG_Finance_Staff |
| DL_FinanceShare_R | Domain Local | Security | (empty, ready for read-only access) |

* Security vs Distribution: only Security groups can be given permissions. Distribution groups are for email lists.
* Filled the department groups with one loop: each OU name matches its group name (Finance → GG_Finance_Staff).

### Finance share
* Folder C:\Shares\Finance, shared as \\DC01\Finance.
* Share permissions: Authenticated Users = Change, Administrators = Full. Kept simple on purpose, with real control in NTFS.
* NTFS on C:\Shares\Finance: inheritance disabled, Users removed, DL_FinanceShare_RW = Modify, DL_FinanceShare_R = Read & execute, Administrators/SYSTEM = Full.
* Share and NTFS permissions combine, and the most restrictive wins.
* Mistake fixed: first set NTFS on the parent C:\Shares instead of C:\Shares\Finance. Moved it to the Finance folder, so future department folders don't inherit Finance's permissions.

### Test (Effective Access)
| User | Expected | Result |
|---|---|---|
| Finance user | Modify | Modify |
| HR user | No access | No access |

![Finance user](screenshots/finance-effective-access.png)
![HR user](screenshots/hr-effective-access.png)

## 2026-11-05 – Built WS01 and joined it to the domain

### Build
* Gen 2, 2 vCPU, 4 GB startup RAM (dynamic, min 2 GB, max 4 GB), 64 GB disk, LAB-CORE VLAN 20.
* Windows 11 Enterprise Evaluation. Windows 11 needs a TPM, so I turned on the virtual TPM in Hyper-V (Settings > Security) before first boot.

### Network
| Setting | Value |
|---|---|
| Adapter name | VLAN20-Workstations |
| IP | 10.10.20.50/24 (temporary static until DHCP in Phase 3) |
| Gateway | 10.10.20.1 |
| DNS | 10.10.10.10 (DC01) |

* Why DNS must be DC01: clients find a domain controller by asking DNS for its SRV records (_ldap._tcp.dc._msdcs.corp.lab.internal), and those only exist in DC01's DNS. Public DNS (1.1.1.1) has never heard of corp.lab.internal, so the join would fail. That's why most failed joins are DNS problems.
* Tested before joining: ping 10.10.10.10 and Resolve-DnsName corp.lab.internal both worked.

### Domain join (GUI)
* sysdm.cpl > Change: renamed to WS01 and joined corp.lab.internal with CORP\Administrator, then restarted.
* WS01 landed in CORP > Computers > Workstations, which proves the redircmp from Task 4 works.
* First login as a domain user (CORP\sarah.khan) forced a password change. That's because the script set "must change password at next logon": the admin knew the starting password, so the user sets one only they know.

![WS01 joined](screenshots/ws01-joined.png)

## 2026-11-05 – Built MGMT01 and joined it to the domain

### Build
* Same specs as WS01, but in LAB-CORE VLAN 30.

### Network
| Setting | Value |
|---|---|
| Adapter name | VLAN30-Management |
| IP | 10.10.30.20/24 (from IPAM sheet) |
| Gateway | 10.10.30.1 |
| DNS | 10.10.10.10 (DC01) |

### Domain join (PowerShell)
* Command: Add-Computer -DomainName corp.lab.internal -NewName MGMT01 -Credential CORP\Administrator -Restart (renames, joins and restarts in one step, with one reboot instead of two).
* Mistake along the way:
  - Put Rename-Computer and Add-Computer on one line with no ; between them, so PowerShell read the second command as a value for the first.
* Problem: the domain join succeeded, but the rename failed ("directory service is busy"). The earlier Rename-Computer had already queued a rename waiting on a restart, and it clashed with -NewName.
* Fix: restarted, logged in as .\localadmin, then [renamed with Rename-Computer -NewName MGMT01 -DomainCredential CORP\Administrator -Restart
* Lesson: restart after every rename before doing anything else, and rename a domain-joined PC with -DomainCredential so AD is updated too.
* Checked: MGMT01 appears in CORP > Computers > Workstations with no leftover DESKTOP-... object.

## 2026-11-08 – MGMT01 as the admin workstation

### Moved to Admin Workstations
* Moved MGMT01 from CORP > Computers > Workstations to CORP > Computers > Admin Workstations, so it'll get admin-PC policies instead of normal workstation ones.
* Why redircmp didn't put it there automatically: It was setup to put all computers into CORP > Computers > Workstations.

### Separate admin account
* Created adm-eesa.ali in CORP > Admin Accounts and added it to Domain Admins.
* Domain Admins = built-in group with full control of the whole domain (every user, PC, DC and GPO). It lives in the built-in Users container.
* The Admin Accounts OU only organizes accounts. Membership of the Domain Admins group is what grants the rights.
* Why a separate admin account: ...

### RSAT on MGMT01
* Logged in as CORP\adm-eesa.ali and installed RSAT: Active Directory, Group Policy Management, DNS.
* Checked: ADUC on MGMT01 shows the whole domain, and Get-ADUser works from MGMT01.
* From now on, admin work is done from MGMT01, not on DC01's console.
