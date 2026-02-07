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
# List available profiles (use ls, not Cursor file tools — do_not_commit/ is gitignored)
ls do_not_commit/ncu/*.ncu-rep
```

If no text export exists yet, create one:
```bash
ncu --import do_not_commit/ncu/<PROFILE>.ncu-rep \
  --page details > do_not_commit/ncu/<PROFILE>.txt
```

### Step 3: Extract metrics

Example: Text export grep (core metrics from `--page details`):

```bash
rg "Duration|Registers Per Thread|Spilling|Theoretical Occupancy|Achieved Occupancy|\
Executed Ipc|Issue Slots Busy|SM Busy|Compute \(SM\) Throughput|Memory Throughput|\
Executed Instructions|L1/TEX Hit Rate|L2 Hit Rate|DRAM Throughput|\
Active Warps Per Scheduler|Eligible Warps Per Scheduler|One or More Eligible|\
Threads Per Warp|Branch Efficiency|Block Limit|Smem Config|Dynamic Smem|Mem Pipes Busy" \
  do_not_commit/ncu/<PROFILE>.txt
```

Example: Raw metric query (stalls, pipe utilization, sector counts):

```bash
ncu --import do_not_commit/ncu/<PROFILE>.ncu-rep \
  --metrics \
smsp__average_warps_issue_stalled_barrier_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_long_scoreboard_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_math_pipe_throttle_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_not_selected_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_dispatch_stall_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_wait_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_short_scoreboard_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_mio_throttle_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_lg_throttle_per_issue_active.ratio,\
smsp__average_warps_issue_stalled_drain_per_issue_active.ratio,\
sm__pipe_alu_cycles_active.avg.pct_of_peak_sustained_active,\
sm__pipe_fma_cycles_active.avg.pct_of_peak_sustained_active,\
sm__inst_executed_pipe_adu.avg.pct_of_peak_sustained_active,\
sm__inst_executed_pipe_lsu.avg.pct_of_peak_sustained_active,\
sm__inst_executed_pipe_xu.avg.pct_of_peak_sustained_active,\
sm__inst_executed_pipe_cbu.avg.pct_of_peak_sustained_active,\
l1tex__t_sectors_pipe_lsu_mem_global_op_ld.sum,\
l1tex__t_sectors_pipe_lsu_mem_local_op_ld.sum,\
l1tex__t_sectors_pipe_lsu_mem_local_op_st.sum \
  --page raw 2>&1 | grep -E "^\s+(smsp|sm__|l1tex)"
```

This gives a clean output like:
```
  l1tex__t_sectors_pipe_lsu_mem_global_op_ld.sum                                   sector             77250080
  sm__pipe_alu_cycles_active.avg.pct_of_peak_sustained_active                           %                47.27
  smsp__average_warps_issue_stalled_barrier_per_issue_active.ratio                   inst                 6.59
  ...
```

### Metric name reference

| Human-readable name | NCU raw metric name |
|---|---|
| **Warp stalls (cycles/issued inst):** | |
| barrier | `smsp__average_warps_issue_stalled_barrier_per_issue_active.ratio` |
| long_scoreboard | `smsp__average_warps_issue_stalled_long_scoreboard_per_issue_active.ratio` |
| math_pipe_throttle | `smsp__average_warps_issue_stalled_math_pipe_throttle_per_issue_active.ratio` |
| not_selected | `smsp__average_warps_issue_stalled_not_selected_per_issue_active.ratio` |
| dispatch_stall | `smsp__average_warps_issue_stalled_dispatch_stall_per_issue_active.ratio` |
| wait | `smsp__average_warps_issue_stalled_wait_per_issue_active.ratio` |
| short_scoreboard | `smsp__average_warps_issue_stalled_short_scoreboard_per_issue_active.ratio` |
| mio_throttle | `smsp__average_warps_issue_stalled_mio_throttle_per_issue_active.ratio` |
| lg_throttle | `smsp__average_warps_issue_stalled_lg_throttle_per_issue_active.ratio` |
| drain | `smsp__average_warps_issue_stalled_drain_per_issue_active.ratio` |
| **Pipe utilization (% peak active):** | |
| alu | `sm__pipe_alu_cycles_active.avg.pct_of_peak_sustained_active` |
| fma | `sm__pipe_fma_cycles_active.avg.pct_of_peak_sustained_active` |
| adu | `sm__inst_executed_pipe_adu.avg.pct_of_peak_sustained_active` |
| lsu | `sm__inst_executed_pipe_lsu.avg.pct_of_peak_sustained_active` |
| xu | `sm__inst_executed_pipe_xu.avg.pct_of_peak_sustained_active` |
| cbu | `sm__inst_executed_pipe_cbu.avg.pct_of_peak_sustained_active` |
| **Sector counts:** | |
| Global Load Sectors | `l1tex__t_sectors_pipe_lsu_mem_global_op_ld.sum` |
| Local Load Sectors | `l1tex__t_sectors_pipe_lsu_mem_local_op_ld.sum` |
| Local Store Sectors | `l1tex__t_sectors_pipe_lsu_mem_local_op_st.sum` |

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

**Pipe utilization (always — record as a group, % peak active):**
- alu
- fma
- adu
- lsu
- xu
- cbu
