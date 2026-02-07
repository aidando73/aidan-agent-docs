---
name: fetch-ncu-metrics
description: Extract metrics from NCU (Nsight Compute) profiles and record them in progress.md. Use when the user asks to "fetch metrics", "get NCU data", "grab metrics from the profile", "check the NCU numbers", or references specific NCU metrics they want extracted. Also use when the user asks about kernel performance data like occupancy, throughput, stall reasons, IPC, register usage, etc.
---

# Fetch NCU Metrics

Extract metrics from NCU `.ncu-rep` profiles and record results in `progress.md`.

## Workflow

### Step 1: Understand what metrics are needed

**If the user provided file context** (e.g., cursor on a line in progress.md):
- Read surrounding lines to understand which kernel version, workload, and metrics they're referring to.
- Look for nearby profile paths (e.g., `do_not_commit/ncu/pos_emb_interp_v26_...ncu-rep`).

**If no file context but the request is clear** (e.g., "get v26 occupancy"):
- Identify the kernel version and workload from the request.
- Find the matching profile in `do_not_commit/ncu/` or referenced in `progress.md`.

**If unclear**, ask directly:
- Which kernel version?
- Which workload (e.g., 10-image 1024x1024,1280x1024)?
- Which metrics? (Or "all relevant" — overfetching is fine.)

### Step 2: Find the profile

Profiles are stored at `do_not_commit/ncu/<name>.ncu-rep` and referenced in `progress.md`.

```bash
# List available profiles
ls do_not_commit/ncu/*.ncu-rep
```

If no text export exists yet, create one:
```bash
ncu --import do_not_commit/ncu/<PROFILE>.ncu-rep \
  --page details > do_not_commit/ncu/<PROFILE>.txt
```

### Step 3: Extract metrics

Use whichever `--page` mode gets what you need. When in doubt, overfetch — extra metrics are fine.

```bash
# Detailed summary (most common — has duration, occupancy, throughput, stalls, etc.)
ncu --import do_not_commit/ncu/<PROFILE>.ncu-rep --page details

# Raw metrics (all counters — use when you need specific counter names)
ncu --import do_not_commit/ncu/<PROFILE>.ncu-rep --page raw

# Grep for specific metrics from raw output
ncu --import do_not_commit/ncu/<PROFILE>.ncu-rep --page raw 2>/dev/null \
  | grep -E "metric_name_1|metric_name_2"
```

Common metric patterns to grep for:
- Occupancy: `occupancy`
- Stalls: `stall`
- IPC: `ipc`
- L1/L2 throughput: `l1tex|lts__t`
- DRAM: `dram__bytes`
- Registers: `launch__registers_per_thread`
- FLOPs: `flop|ffma|fadd|fmul`
- Spills: `local_load|local_store|spill`
- Peak sustained bandwidth: `peak_sustained`

### Step 4: Record in progress.md

**Always record** unless Aidan explicitly says not to.

Use ASCII table format:

```
Metric                                      v<A>            v<B>            Change
------------------------------------------------------------------------------------
Duration                                    490 us          420 us          14.3% faster
Registers Per Thread                        32              32              same
Achieved Occupancy                          88.40%          91.20%          +2.8pp
Executed IPC Active                         3.26            3.41            +4.6%
L1/TEX Hit Rate                             22.70%          25.10%          +2.4pp
L2 Hit Rate                                 92.44%          93.10%          +0.7pp
Warp Stall long_scoreboard                  2.60            2.10            19.2% better
```

Format rules:
- Right-align numbers
- Use commas for thousands (6,940,460 not 6940460)
- Change column: "X% faster/slower", "+X%/−X%", "+Xpp" for percentage points, "same"
- Include ALL metrics that might be relevant — overfetching is encouraged
- For comparison tables, include a baseline column (usually v23 or whatever the previous stable version is)

## Aidan's Standard Metrics

Always fetch these unless there's a reason not to.

**Core (always):**
- Duration
- Registers Per Thread
- Local Memory Spilling Requests
- Local Memory Spilling Request Overhead
- Theoretical Occupancy
- Achieved Occupancy
- Executed IPC Active
- Issue Slots Busy / SM Busy
- Compute (SM) Throughput
- Memory Throughput
- Executed Instructions

**Memory hierarchy (always):**
- L1/TEX Hit Rate
- L2 Hit Rate
- DRAM Throughput
- Global Load Sectors
- Local Load Sectors (if spilling)
- Local Store Sectors (if spilling)

**Scheduler (always):**
- Active Warps Per Scheduler
- Eligible Warps Per Scheduler
- One or More Eligible (scheduler)
- Avg. Active Threads Per Warp
- Branch Efficiency

**Occupancy limiters (always):**
- Block Limit Registers
- Block Limit Shared Mem
- Block Limit Warps
- Smem Config Size
- Dynamic Smem Per Block

**Warp stalls (always — record as a group, cycles per issued inst):**
- barrier
- long_scoreboard
- math_pipe_throttle
- not_selected
- dispatch_stall
- wait
- short_scoreboard
- mio_throttle
- lg_throttle
- drain
- Total (Warp Cycles Per Issued Instruction)
