# 001: Hypervisor – Hyper-V

**Date:** 2026-10-12

## Context
The lab needs to run about a dozen VMs on one PC, with VLAN-tagged virtual networks.
Host: Ryzen 5 3600 (6 cores / 12 threads), 16 GB RAM, 2 TB storage, Windows 11 Pro.
Virtualization (AMD SVM) was off in the BIOS. I turned it on and checked it in Task Manager.

## Options considered
- Hyper-V (built into Windows Pro)
- VirtualBox (free download)

## Decision
Hyper-V.

## Reason
- Already included with Windows 11 Pro, so there's nothing extra to install.
- Supports VLAN IDs on virtual network cards, which the lab needs for real VLANs.

## Consequences
- 16 GB RAM limits how many VMs can run at once, so I'll only run the ones each phase needs.