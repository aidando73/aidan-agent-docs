---
name: ncu-cli
description: Reference for NVIDIA Nsight Compute (ncu) CLI flags and common usage patterns. Use when running NCU commands to profile, export, or query CUDA kernels. Consult this before constructing any ncu command to avoid flag mistakes.
---

# NCU CLI Reference

**This skill is the authoritative reference for `ncu` CLI flags.** Always consult it before constructing NCU commands. If you encounter an NCU CLI error (unrecognized option, wrong flag, etc.), fix the command AND update this skill via the `/edit-agent-docs` process so the mistake is never repeated.

## Self-improvement protocol

If an `ncu` command fails due to a wrong flag or syntax:
1. Fix the command using `ncu --help` or the error message
2. Update this skill file with the correction
3. Commit and push via `/edit-agent-docs`

## Common commands

### Profile a kernel

```bash
ncu --set full --import-source yes \
  --kernel-name regex:"<kernel_name_pattern>" \
  --launch-skip <N> --launch-count <N> \
  --force-overwrite --export <output_path>.ncu-rep \
  <program> [args...]
```

Key flags:
- `--set full` — collect all metric sections (most comprehensive)
- `--set basic` — collect basic metrics only (faster, default if `--set` omitted)
- `--import-source yes` — embed CUDA source in profile for source-level metrics
- `--kernel-name regex:"pattern"` or `-k regex:"pattern"` — filter to specific kernel(s)
- `--launch-skip N` or `-s N` — skip first N kernel launches (warmup)
- `--launch-count N` or `-c N` — profile only N kernel launches
- `--force-overwrite` or `-f` — overwrite existing output file
- `--export <path>` or `-o <path>` — save profile to .ncu-rep file

### Export profile to text

```bash
# Detailed metrics (recommended for analysis)
ncu --import <path>.ncu-rep --page details > <path>.txt

# Raw metrics (all available, very verbose)
ncu --import <path>.ncu-rep --page raw > <path>_raw.txt
```

Key flags:
- `--import <path>` or `-i <path>` — read from existing .ncu-rep file
- `--page details` — human-readable metrics with analysis (default)
- `--page raw` — all raw metric values

### Query specific metrics from a profile

```bash
ncu --import <path>.ncu-rep \
  --metrics <metric1>,<metric2>,... \
  --page raw
```

### List available kernels in a profile

```bash
ncu --import <path>.ncu-rep --print-summary per-kernel --page raw
```

### List kernel names during profiling

Use `--print-kernel-base demangled` to see readable kernel names:

```bash
ncu --print-kernel-base demangled \
  --launch-skip <N> --launch-count <N> \
  <program> [args...]
```

## Flags that DON'T exist (common mistakes)

These are flags that look plausible but **do not exist** in NCU:

| Wrong flag | What to use instead |
|---|---|
| `--list-kernels` | `--print-summary per-kernel` (for imported profiles) or just run with `--print-kernel-base demangled` |

## Flag reference (verified)

### Profiling control
| Flag | Short | Description |
|---|---|---|
| `--set <name>` | | Section set: `full`, `basic`, `detailed`, etc. |
| `--section <name>` | | Collect specific section |
| `--metrics <list>` | | Comma-separated metric names |
| `--kernel-name <filter>` | `-k` | Filter by kernel name (supports `regex:`) |
| `--kernel-name-base <mode>` | | `function` (default), `demangled`, `mangled` |
| `--launch-skip <N>` | `-s` | Skip first N launches |
| `--launch-count <N>` | `-c` | Profile only N launches |
| `--import-source yes` | | Embed CUDA source in profile |

### Output
| Flag | Short | Description |
|---|---|---|
| `--export <path>` | `-o` | Save profile to .ncu-rep |
| `--force-overwrite` | `-f` | Overwrite existing output |
| `--import <path>` | `-i` | Read existing .ncu-rep |
| `--page <mode>` | | Output page: `details`, `raw`, `source` |
| `--print-kernel-base <mode>` | | Kernel name format: `demangled`, `function`, `mangled` |
| `--print-summary <mode>` | | Summary mode: `none`, `per-kernel`, `per-gpu` |
| `--print-details <mode>` | | Detail level: `header`, `all` |
| `--csv` | | Comma-separated output |

### Filtering
| Flag | Short | Description |
|---|---|---|
| `--kernel-id <id>` | | Filter by kernel ID |
| `--target-processes <mode>` | | `all` or `application-only` |

### Misc
| Flag | Short | Description |
|---|---|---|
| `--help` | `-h` | Print help |
| `--version` | `-v` | Print version |
| `--query-metrics` | | List available metrics for device |
| `--list-sets` | | List available section sets |
| `--list-sections` | | List available sections |
| `--list-chips` | | List supported GPU chips |
