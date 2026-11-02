# Enterprise Network Lab – Network Design

Living document. Updated at the end of each phase.

## 1. Requirements
- Separate networks for servers, staff PCs, IT admins and guests, so a problem in one can't spread to the others.
- Guests get internet access only.
- Only IT (the Management network) can remotely administer systems.
- All lab machines can reach the internet for updates.
- Everything runs on one PC (HOST01) using Hyper-V.

## 2. Addressing plan
Full detail: ipam/lab-ipam.xlsx

| VLAN | Name | Subnet | Gateway |
|---|---|---|---|
| 10 | Servers | 10.10.10.0/24 | 10.10.10.1 |
| 20 | Workstations | 10.10.20.0/24 | 10.10.20.1 |
| 30 | Management | 10.10.30.0/24 | 10.10.30.1 |
| 40 | Guest | 10.10.40.0/24 | 10.10.40.1 |
| 99 | Transit (Phase 4) | 10.10.99.0/29 | – |

/24 everywhere keeps the maths simple while learning.

## 3. Routing design
- One Hyper-V Private switch (LAB-CORE) carries all four VLANs, separated by VLAN ID, like a physical switch with tagged ports.
- CORE-RTR01 (Windows Server 2025, RRAS) has one adapter per VLAN plus one OUTSIDE adapter on the Hyper-V Default Switch.
- The router knows the four networks through connected routes (created automatically from each adapter's IP and mask). A default route via OUTSIDE handles everything else.
- NAT on OUTSIDE lets the whole lab share one outside address to reach the internet.

![Logical diagram](docs/diagrams/logical.png)

## 4. Security policy
Full policy: docs/traffic-policy.md. Default rule: block anything not explicitly allowed.

How it's enforced in Phase 1:
- **Router filter (RRAS, stateless):** drops anything from Guest (10.10.40.0/24) headed to 10.10.0.0/16.
- **Host firewall (Windows Defender, stateful):** RDP to CORE-RTR01 only from Management. Ping only from VLANs 10, 20 and 30. Dropped packets are logged.

Tested: 8 tests, all passed (see phases/01 notes).

## 5. Known limitations
- RRAS filters are stateless, so Management can't yet manage Guest devices (replies are dropped). Fixed by pfSense in Phase 4.
- Single router = single point of failure. Acceptable for a lab.

## 6. Identity (Active Directory)

**Domain:** corp.lab.internal (one forest, one domain). Domain controller: DC01 (10.10.10.10), also the DNS server.

### OU tree
CORP is the top level. Everything the company creates lives under it, so it's kept apart from Windows' built-in containers.

    corp.lab.internal
    └── CORP
        ├── Users
        │   ├── Finance
        │   ├── HR
        │   ├── Sales
        │   └── IT
        ├── Computers
        │   ├── Workstations
        │   ├── Servers
        │   └── Admin Workstations
        ├── Groups
        ├── Service Accounts
        └── Admin Accounts

### Naming standards
| Object | Pattern | Example |
|---|---|---|
| Normal user | first.last | sarah.khan |
| Admin account (separate from the daily account) | adm-first.last | adm-eesa.ali |
| Role group (who people are) | GG_Dept_Role | GG_Finance_Staff |
| Resource group (what they can access) | DL_Resource_Access | DL_FinanceShare_RW |
| Classic service account | svc-purpose | svc-web |
| Managed service account (gMSA) | gmsa-purpose | gmsa-uptime |
| Group Policy | GPO_Scope_Purpose | GPO_WS_Baseline |

### Group model (AGDLP)
Accounts go into Global role groups, Global groups go into Domain Local resource groups, and Permissions are only ever granted to the resource groups.
Example: sarah.khan → GG_Finance_Staff → DL_FinanceShare_RW → Modify on the Finance share.
Why: when someone changes roles, you change one group membership, not dozens of permissions.

### GPO inventory
| GPO | Purpose | Linked to |
|---|---|---|
| GPO_Domain_Password | Password and lockout policy | Domain root (password policy only works there) |
| GPO_WS_Baseline | Logon banner, block USB storage, firewall on with logging | CORP/Computers/Workstations |
| GPO_SRV_Firewall | RDP and WinRM only from 10.10.30.0/24 | CORP/Computers/Servers + Domain Controllers |
| GPO_All_Audit | Advanced audit: logons, account changes, process creation | CORP/Computers + Domain Controllers |
| GPO_All_PSLogging | PowerShell module and script block logging | CORP/Computers + Domain Controllers |
| GPO_User_DriveMaps | Map department shares, targeted by group | CORP/Users |
| GPO_SVC_DenyLogon | Service accounts can't log on interactively | CORP/Computers + Domain Controllers |

Note: DC01 lives in the built-in Domain Controllers OU, not CORP/Computers/Servers, so server GPOs are linked there too.
