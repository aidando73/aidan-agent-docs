# Debug Process for Agents

When working on a hard-to-diagnose issue, **maintain a debug log** in this file (or a task-specific debug doc). The purpose is to prevent future agents from re-trying failed approaches and to preserve institutional knowledge.

---

## The Debug Protocol

Whenever you're investigating a bug, hang, performance regression, or any issue that isn't immediately obvious:

### 1. Before you start: Check existing debug logs

Search this file and `ideas.md` (or the project's working doc) for keywords related to your issue. Someone may have already tried what you're about to try.

### 2. Document as you go

For each attempt, record:

```
### Attempt N: <short description>

**Hypothesis:** Why you think this might work.
**What you did:** Exact commands, code changes, config changes.
**Result:** What happened. Include exact error messages, timings, or output.
**Conclusion:** What this tells us. Why it worked/failed. What it rules out.
```

### 3. Maintain the "What to try next" list

After each attempt, update the "What to try next" section. Add new ideas that emerged, remove or check off things you've tried, and re-prioritize based on what you learned.

### 4. Summarize key differences

When comparing a working case vs a broken case (e.g., a minimal repro that works vs the real code that hangs), maintain a table of **key differences**. This is often the fastest path to root cause — systematically eliminate differences until you find the one that matters.

---

## Active Debug Logs

### NCU Profiling Hangs on TMA + mbarrier Kernels (v22 pos_emb_interp)

**Status:** Open — not yet root-caused.

**Symptom:** `ncu --set full` hangs at "Profiling ... 0%" on the first kernel replay pass for the v22 kernel (which uses `cp.async.bulk` + mbarrier double-buffered pipeline). NCU warns: "Launching the workload is taking more time than expected." The kernel runs correctly without NCU (benchmark passes, numerics correct).

**Environment:**
- GPU: NVIDIA B200 (SM 100 / compute_10.0)
- NCU: 2025.3.1.0 (build 36398880)
- Kernel: `pos_emb_interp_bicubic_kernel_v22` (launched via PyTorch)
- Related files:
  - `py/fireworks/csrc/nvidia/pos_emb_interp_v22.cu` — the actual kernel
  - `ncu_tma_repro/repro.cu` — standalone minimal reproduction attempt

---

#### Attempt 1: Default kernel replay (`ncu --set full`)

**Hypothesis:** Standard profiling should work.
**What we did:** `ncu --set full --kernel-name regex:"pos_emb_interp_bicubic_kernel_v22.*" --launch-skip 5 --launch-count 3 ...`
**Result:** **Hangs** at "Profiling ... 0%" on the first replay pass. Every time.
**Conclusion:** Something about the v22 kernel breaks NCU's kernel replay mechanism.

#### Attempt 2: `--replay-mode range`

**Hypothesis:** Range replay might avoid the hang by using a different replay strategy.
**What we did:** Added `--replay-mode range` to the NCU command.
**Result:** **Errors** — incompatible with `--kernel-name` and `--import-source` flags. NCU refuses to run.
**Conclusion:** Not a viable workaround with our standard profiling flags.

#### Attempt 3: Standalone TMA repro (`ncu_tma_repro/repro.cu`)

**Hypothesis:** If we can reproduce the hang in a minimal standalone binary, we can isolate the root cause and potentially file a bug with NVIDIA.
**What we did:** Created `ncu_tma_repro/repro.cu` — same double-buffered `cp.async.bulk` + mbarrier parity pattern, same smem layout (32KB + 8B mbar), same `__launch_bounds__(256,7)`, same workload scale (61K blocks, dim=1152).
**Result:** **Does NOT hang** with NCU. Profiles fine.
**Conclusion:** The TMA + mbarrier pattern alone is not sufficient to trigger the hang. Something else in the actual v22 kernel is involved. The repro compiles to ~32 registers vs the actual v22 which has significantly more register pressure.

#### Attempt 4: Collect fewer metrics (`--section SpeedOfLight` only)

**Hypothesis:** If the hang is caused by specific metric collection passes (SASS patching), collecting fewer metrics might avoid the problematic passes.
**What we did:** `ncu --section SpeedOfLight ...` (9 replay passes instead of ~39 for `--set full`).
**Result:**
- `--section SpeedOfLight` alone: **works** (9 passes complete successfully)
- Adding more sections beyond SpeedOfLight: **hangs** (gets to 0% on first instrumented pass)
**Conclusion:** **Confirms the issue is SASS-patching-related.** Specific metric collection passes (beyond the basic SpeedOfLight set) require SASS instrumentation that breaks mbarrier replay. The mbarrier wait loop likely gets patched in a way that deadlocks.

#### Attempt 5: Remove `__launch_bounds__` from v22

**Hypothesis:** Higher register pressure (from launch bounds capping) might interact poorly with NCU's SASS patching.
**What we did:** Removed `__launch_bounds__` from v22 kernel, rebuilt, re-profiled with `ncu --set full`.
**Result:** **Still hangs.**
**Conclusion:** Not a register pressure issue. The hang is independent of `__launch_bounds__`.

---

#### Key Differences: Repro (works) vs Actual v22 (hangs)

```
Factor                          Repro (works)                  Actual v22 (hangs)
------------------------------  -----------------------------  --------------------------------
Launch context                  Raw CUDA (main → cudaLaunch)   PyTorch (torch.ops → at::cuda)
Grid shape                      1D (61420, 1, 1)               2D with early-exit blocks
Register pressure               ~32 regs                       Higher (bicubic coeffs, coords)
Coordinate math                 Simple index clamping           floorf(), int div/mod, int64 ops
Memory inputs                   Single float* weight            int64 grid_thws, int32 patch_offsets
                                                                (via at::from_blob → .to(device))
__launch_bounds__               (256, 7)                       (256, 7) — tested without too
SMEM layout                     32KB + 8B mbar                 Same
TMA pattern                     Same cp.async.bulk + mbar      Same
```

---

#### What to Try Next

Prioritized by expected information gain:

1. **`--replay-mode application`** — Re-runs the entire program per metric pass (slowest but safest). If this works, it confirms kernel replay is the problem and gives us a working (if slow) profiling path. This is the highest-priority next step.

2. **Launch through PyTorch in repro** — Wrap the repro kernel as a custom torch op and launch via `torch.ops.custom.repro_kernel(...)`. If it hangs, PyTorch's CUDA context/stream setup is the trigger. If it doesn't hang, the issue is kernel-specific (coordinate math, register pressure, grid shape).

3. **Profile with `--launch-count 1 --launch-skip 0` on single-image workload** — Smaller grid (5,476 blocks instead of 61K). Tests whether grid size / number of early-exit blocks matters.

4. **Incrementally add complexity to repro** — Since the repro works, add one factor at a time from the "Key Differences" table until it hangs:
   - Add floorf() / int div/mod coordinate math
   - Add 2D grid with early-exit
   - Add int64 loads
   - Increase register pressure with dummy variables
   This is the most systematic approach to finding the root cause.

5. **File NVIDIA bug report** — If `--replay-mode application` works, we have a workaround and can file a bug with NVIDIA showing that kernel replay + mbarrier + SASS patching deadlocks. Include the standalone repro (which works) and a description of what makes the actual kernel hang.

---

## Template: New Debug Log Entry

Copy this template when starting a new investigation:

```markdown
### <Issue Title>

**Status:** Open / Resolved / Won't Fix
**Symptom:** <What goes wrong — exact error messages, behavior>
**Environment:** <GPU, driver, CUDA, relevant tool versions>
**Related files:** <Kernel files, repros, profiles>

---

#### Attempt N: <short description>

**Hypothesis:** <Why you think this might work>
**What you did:** <Exact commands, code changes>
**Result:** <What happened — exact output>
**Conclusion:** <What this tells us>

---

#### Key Differences: <Working Case> vs <Broken Case>

(table)

---

#### What to Try Next

1. ...
2. ...
```
