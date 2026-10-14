# 002: VM storage location

**Date:** 2026-10-14

## Context
The lab needs about 350 GB for VMs and checkpoints. My Windows drive doesn't have enough free space.

## Options considered
- Windows drive (C:): faster, but not enough space
- Second drive (E:): plenty of space

## Decision
Store all VMs and ISOs on E:\HomeLab. Hyper-V's default paths now point there.

## Consequences
- E: is an HDD, so VMs will boot and run slower. I'll run only the VMs each phase needs.