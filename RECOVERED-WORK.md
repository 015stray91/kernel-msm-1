# Recovered Custom Work

This branch carries the AnyRealm custom sources recovered from the repository
history after the default branch was reset onto a nested history.

The full pre-rewrite tree still exists at commit
`094a4446e73cd4856e850a5989d08b09cc92112e` (71,115 files). This branch takes the
current branch tip and lays the recovered custom files back on top, so the work
is visible and reviewable without rewriting anything.

## What is here

- `fs/koto/` — the Kotoamatsukami matrix engine (four variants, the EUD loading
  gate, `hybrid_mount`, `hidden-objects`, the built-ins)
- `fs/koto/colonel/` — the kernel tier (SProf), the environment spoof
- `fs/susfs.c`, `include/linux/susfs*.h` — SUSFS
- `fs/zeromount.c`, `include/linux/zeromount.h` — zeromount
- `include/user/` — the user-space set (`supercall.h`, `KOTOAMATSUKAMI-CORE`,
  `Kds`, `Zromount`, `KSUsafty`, `Continue`, the susfs addendum)
- `drivers/soc/qcom/eud.c` — the EUD driver
- `arch/arm64/configs/` — `ksu-nh.defconfig` and the staged fragment chain
- `build.config.anyrealm.kernel`, `nuki-colonel.config`, `scripts/kconfig/merge_nuki.py`
- `.github/workflows/build-genevn.yml`

Every file is byte-identical to the object still held by the repository.
