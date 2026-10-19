# Phase 1: Multi-subnet network, RRAS routing and Windows Firewall

Learning notes for this phase, written the same day you do the work:

- what you set out to do and what you actually did
- commands you ran, and what each part of the command does
- screenshots of results, saved in `screenshots/`
- test results: what you expected and what happened
- problems you hit and how you solved them, with the ServiceNow incident or change number

End the phase with a short summary of what you learned and what you would do differently.

## 2026-10-18 – Planning
* Created the IPAM sheet (ipam/lab-ipam.xlsx) and the traffic policy (docs/traffic-policy.md).
* Raised change CHG0030001 "Build core network", planned Oct 19-23.

* CHG0030001 approved by Network group and CAB (on their behalf), moved to Implement.

## 2026-10-19 LAB-CORE virtual private switch created on Hyper-V
![LAB-CORE Virtual Private Switch](screenshots/LAB-CORE-created.png)

## CORE-RTR01 Created on Hyper-V
* Generation 2, 2048 MB Dynamic Memory, Default Switch, 2 virual processors, Network Adapters for LAB-CORE switch with VLAN IDs 10, 20, 30 and 40.
* Installed from bootable image file.

![CORE-RTR01](screenshots/CORE-RTR01.png)

* VM login: use Ctrl+Alt+End (not Ctrl+Alt+Del) inside a Hyper-V window.

## CORE-RTR01 adapters
Matched Hyper-V adapters to Windows adapters by MAC address, then renamed them.

| MAC | VLAN | Windows name | IP |
|---|---|---|---|
| 00155D880100 | Default Switch | OUTSIDE | DHCP |
| 00155D880101 | 10 | VLAN10-Servers | 10.10.10.1/24 |
| 00155D880102 | 20 | VLAN20-Workstations | 10.10.20.1/24 |
| 00155D880103 | 30 | VLAN30-Management | 10.10.30.1/24 |
| 00155D880104 | 40 | VLAN40-Guest | 10.10.40.1/24 |

* No default gateway on the VLAN adapters: the router is the gateway for those networks.

![Interfaces](screenshots/Interfaces.png)