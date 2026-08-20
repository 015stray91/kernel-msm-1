# SPDX-License-Identifier: GPL-2.0
# Makefile for AnyRealm Kotoamatsukami Stealth Engine
# kpm_eud modules are modular variants for the "module matrix"
# Can be loaded singly or mixed combinations

obj-y += main.o
obj-y += hybrid_mount.o
obj-y += Continue.o
obj-y += KOTOAMATSUKAMI-CORE.o
obj-y += KSUsafty.o
obj-y += nethunter_box.o
obj-y += Virtualspace.o
obj-y += Zromount.o
obj-y += hidden-objects.o
obj-y += kde.o

# kpm_eud modular variants - selectable for module matrix
# Single: make M=fs/koto modules
# Mixed: load combinations of .ko files
kpm_eud-hiddnobj-exp-test-load-objs := kpm_eud_hiddnobj-exp-test-load.o
kpm_eud-infusdobj-exp-test-load-objs := kpm_eud_infusdobj-exp-test-load.o
kpm_eud-outoftree-exp-test-load-objs := kpm_eud_outoftree-exp-test-load.o
kpm_eud-upstrm-exp-test-load-objs := kpm_eud_upstrm-exp-test-load.o

# Allow modular build: make M=fs/koto modules
# Or mixed: insmod combinations of the .ko files
obj-m += $(kpm_eud-hiddnobj-exp-test-load-objs) $(kpm_eud-infusdobj-exp-test-load-objs) $(kpm_eud-outoftree-exp-test-load-objs) $(kpm_eud-upstrm-exp-test-load-objs)
