# Phase 0: Prepare the PC and the project

Learning notes for this phase, written the same day you do the work:

* what you set out to do and what you actually did
* commands you ran, and what each part of the command does
* screenshots of results, saved in `screenshots/`
* test results: what you expected and what happened
* problems you hit and how you solved them, with the ServiceNow incident or change number

End the phase with a short summary of what you learned and what you would do differently.



## 2026-10-12 – Enabled virtualization

* Task Manager > Performance > CPU showed "Virtualization: Disabled"
(but "Hyper-V support: Yes", meaning the CPU supports it).
* Fixed it: BIOS > SVM Mode > Enabled. On AMD it's called SVM, not VT-x.
* Checked again: Task Manager now shows "Virtualization: Enabled".

![Virtualization enabled](screenshots/virtualization-enabled.png)

## 2026-10-14 – Turned on Hyper-V
* Confirmed Windows 11 Pro (Settings > System > About), which supports Hyper-V.
* Turned on Hyper-V in "Turn Windows features on or off" (Management Tools + Platform), then rebooted.
* Checked: Hyper-V Manager opens and shows my PC. Task Manager now says "A hypervisor has been detected."

![Hyper-V Manager](screenshots/hyperv-manager.png)

