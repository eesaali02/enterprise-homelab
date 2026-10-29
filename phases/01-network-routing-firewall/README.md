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

## 2026-10-25 Turned on Routing and NAT (RRAS)
* Installed routing role 
![Install Routing Role](screenshots/install_routing_role.png)

* Installed RRAS, custom config: LAN routing + NAT. NAT enabled on OUTSIDE (public interface)
![RRAS](screenshots/rras-nat.png)

* Routing table: 4 connected routes (10.10.10/20/30/40.0/24, next hop 0.0.0.0) + default route 0.0.0.0/0 via OUTSIDE.
* Why the router knows these networks without typed routes: giving an adapter an IP + mask creates a "connected route" automatically. Static routes are only needed for networks the router isn't directly attached to.
* Forwarding is Enabled on all adapters (RRAS turned this on).
![Routing Table](screenshots/routing-table.png)

## 2026-10-28 – Built GUEST01 and tested routing
* Built GUEST01 from Kali's pre-built Hyper-V image (2026.2): Gen 2, 2 vCPU, 2 GB dynamic RAM, Secure Boot off (Kali doesn't support it), LAB-CORE switch, VLAN 40.
* Static test address 10.10.40.50/24, gateway 10.10.40.1, DNS 1.1.1.1 (set with nmcli). Outside the guest DHCP range (.100-.200) so it won't clash later.
* Added a firewall rule on CORE-RTR01 to allow ping (ICMPv4 echo). Windows blocks ping replies by default. To be tightened in Task 8.

### Test results (before filters)
| From | To | Test | Expected | Actual |
|---|---|---|---|---|
| GUEST01 | 10.10.40.1 (own gateway) | ping | Reply | Reply |
| GUEST01 | 10.10.10.1 (Servers gateway) | ping | Reply (no filters yet) | Reply |
| GUEST01 | 1.1.1.1 (internet) | ping | Reply via NAT | Reply |
| GUEST01 | google.com | ping | Reply (DNS works) | Reply |
| GUEST01 | 1.1.1.1 | traceroute | First hop 10.10.40.1 | First hop 10.10.40.1 |

* TTL was 128 from 10.10.40.1 but 127 from 10.10.10.1. Each router hop lowers TTL by 1, which proves the packet was routed through CORE-RTR01.
* Policy gap found: Guest can reach the Servers VLAN. Expected at this stage, and fixed by the Guest filter in Task 8.
* Troubleshooting: some pings failed partway through testing. Cause: the Hyper-V VLAN ID and Kali's IP didn't match. Lesson: change both together.

![Tests before filters](screenshots/guest01-tests-before-filters.png)

### Travelling client test
* Moved GUEST01 to VLAN 10 (Hyper-V VLAN ID 10 + IP 10.10.10.50/24). Gateway and internet both reachable, then moved back to VLAN 40.

![VLAN 10 test](screenshots/guest01-vlan10-test.png)

## 2026-10-28 – Guest filter (router)
* RRAS > IPv4 > General > VLAN40-Guest > Inbound Filters: drop source 10.10.40.0/24 to destination 10.10.0.0/16. Action: "Receive all packets except those that meet the criteria".
* Result: GUEST01 can no longer reach 10.10.10.1 (100% loss) but still reaches 1.1.1.1 and google.com.
* Known limitation: RRAS filters are stateless (no memory of connections). If Management connects to a Guest device, the replies to 10.10.30.x are dropped too. pfSense (Phase 4) is stateful and fixes this.

![Guest filter](screenshots/rras-guest-filter.png)
![After filter](screenshots/guest01-tests-after-filter.png)



