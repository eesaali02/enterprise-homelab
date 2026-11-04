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


