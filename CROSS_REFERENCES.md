# Cross-References - kernel-msm-1

The Colonel build is a tiered orchestration. This repo is the SOURCE, but it's pulled by:

```
Kernel-1 (orchestrator)
  https://github.com/015stray91/Kernel-1
  -> config/default.config references this repo as REPO_KERNEL

Super-Builders (build pipeline)
  https://github.com/015stray91/Super-Builders
  -> colonel/ = Tier 3 with Clang 17 wrapper
  -> android12-5.10/build-helpers/ = local build helpers
  -> references this repo as REPO_KERNEL

Kotoamatsukami (Clang 17 wrapper - outermost)
  https://github.com/015stray91/Kotoamatsukami
  -> compiler/clang_wrapper_static.sh = the static wrapper
  -> references this repo for the colonel source

KernelSU-Next (KPM source)
  https://github.com/015stray91/KernelSU-Next
  -> cloned into kernel-source/kernel/KernelSU during build
  -> KSU seal patches applied at step 4 of build-genevn-nuki.yml
```

## Pre-staged Toolchains
Referenced BEFORE cloning (so they're ready):
- snapdragon-toolchain: tools/toolchains/snapdragon-toolchain/
  - clang-r416183b (Clang 12.0.5)
  - gcc-linaro-7.5.0
- Clang 17 from apt (for the wrapper)
- Kotoamatsukami plugin (built during CI)

## Build Flow (out to in)
1. Clang 17 wrapper (Kotoamatsukami) - flattens code
2. Kernel-1 (orchestrator) - structures the build
3. Super-Builders (pipeline) - clones + patches + compiles
4. kernel-msm-1 (this repo) - source code
5. snapdragon-toolchain (Clang 12 + GCC) - actual compilation
