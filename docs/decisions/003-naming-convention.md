# 003: Naming convention

**Date:** 2026-10-14

## Decision
Every machine is named ROLE + two-digit number. The name says what the machine does.

| Prefix | Meaning | Lab machines |
|---|---|---|
| CORE-RTR | Core router | CORE-RTR01 |
| EDGE-FW | Edge firewall | EDGE-FW01 |
| DC | Domain controller | DC01 |
| WS | User workstation | WS01 |
| MGMT | Admin workstation | MGMT01 |
| LNX-SVC | Linux services server | LNX-SVC01 |
| LNX-WEB | Linux web server | LNX-WEB01 |
| SIEM | Log and security monitoring | SIEM01 |
| GUEST | Guest or visitor device | GUEST01 |

## Rules
- Capitals, with hyphens between words. No spaces.
- The Hyper-V VM name, its folder and the computer name inside the OS are all the same.
- A second machine with the same role gets 02, for example DC02.

## Reason
Anyone can tell what a machine does from its name. The numbers leave room to grow.