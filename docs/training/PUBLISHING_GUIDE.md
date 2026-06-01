# BMLogic-Bench Publishing Guide

Guide for ML researchers to download and publish the BMLogic-Bench dataset on
Hugging Face Hub.

> **Status (2026-06-01)**: The dataset has **not yet been published** to Hugging Face.
> Upload is pending. The canonical URL — once live — will be:
> <https://huggingface.co/datasets/logos-labs/bmlogic-bench>

---

## Overview

**BMLogic-Bench** is a formal-reasoning benchmark and training dataset for bimodal
(modal + temporal) logic. It is hosted at `logos-labs/bmlogic-bench` on the Hugging
Face Datasets Hub.

### Dataset Configurations

| Config | Split | Records | Purpose |
|---|---|---|---|
| `default` (bmlogic-bench) | `test` | 727 | Evaluation benchmark (stratified) |
| `bmlogic-c5` | `train` | 1,513 | Training — complexity ≤ 5, exhaustive |
| `bmlogic-c7` | `train` | 49,904 | Training — complexity ≤ 7, exhaustive |
| `proof-steps` | `train` | 2,424 | Proof-step supervision (36 theorems) |

All records use a 16-field JSONL schema. The `bmlogic-c7` file is ~52 MB;
plan for a multi-minute download on slower connections.

---

## Quick Start for Consumers

### Python API

```python
from datasets import load_dataset

# Evaluation benchmark (727 records, test split)
ds_bench = load_dataset("logos-labs/bmlogic-bench")
print(ds_bench)
# DatasetDict({'test': Dataset({features: [...], num_rows: 727})})

# Training sets
ds_c5    = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c5")   # 1,513
ds_c7    = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c7")   # 49,904
ds_proof = load_dataset("logos-labs/bmlogic-bench", "proof-steps")  # 2,424

# Pin a specific version for reproducible experiments
ds_v1 = load_dataset("logos-labs/bmlogic-bench", revision="v1.0")
```

### CLI Download

```bash
pip install huggingface_hub

# Download all configs to data/
huggingface-cli download logos-labs/bmlogic-bench \
    --repo-type dataset \
    --local-dir data/
```

> **NixOS**: `huggingface-cli` is provided by the `python3Packages.huggingface-hub`
> Nix package — there is no standalone top-level Nix package for it. Use:
> ```bash
> nix-shell -p python3Packages.huggingface-hub
> huggingface-cli download logos-labs/bmlogic-bench --repo-type dataset --local-dir data/
> ```

### Downstream Consumer Setup

If your pipeline previously used `git lfs pull` for these files:

1. Remove the `lfs: true` flag from your checkout action (or local `git lfs pull` step).
2. Add a download step using `datasets.load_dataset(...)` or `huggingface-cli download`.
3. Use `revision="v1.0"` for reproducible downloads.

---

## Publishing Workflow for Maintainers

This section summarises the key commands. For full details — including prerequisite
account setup, troubleshooting, and NeurIPS-specific extras — see the operator guide:
[`data/hf-dataset/PUBLISHING.md`](../../data/hf-dataset/PUBLISHING.md).

### Prerequisites

- Hugging Face account with write access to the `logos-labs` organization
- API token (Write scope) from <https://huggingface.co/settings/tokens>

### Step 1 — Install Dependencies

```bash
cd data/hf-dataset/
pip install -r requirements.txt
```

Installs: `datasets>=2.19.0`, `huggingface_hub>=0.23.0`, `pyarrow>=14.0.0`,
`pyyaml>=6.0`.

#### NixOS Users

On NixOS the Nix store is read-only, so bare `pip install` will fail. Use one of
the following approaches instead:

**Ephemeral (nix-shell)** — no system changes required:

```bash
nix-shell -p python3Packages.datasets python3Packages.huggingface-hub \
              python3Packages.pyarrow python3Packages.pyyaml
# Then run the publish steps inside the shell (Steps 2-5 below).
```

**Persistent (home-manager)** — add to `home.packages` in `home.nix`:

```nix
python3Packages.datasets
python3Packages.huggingface-hub
python3Packages.pyarrow
python3Packages.pyyaml
```

**Virtual environment fallback** — useful when the nixpkgs version of a package
is older than required:

```bash
nix-shell -p python3
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

### Step 2 — Validate Packaging

```bash
python validate.py
```

Expected: all 5 checks pass (YAML frontmatter + one check per config). Do not
proceed if any check fails.

### Step 3 — Dry Run

```bash
python upload.py --dry-run
```

Loads all four configs locally and prints record counts and schemas without pushing
anything. Verify counts match the table in [Overview](#overview).

### Step 4 — Upload

> **NixOS note**: Use the `HF_TOKEN` environment variable (shown below) rather than
> `huggingface-cli login` to avoid keyring dependency issues common on minimal NixOS
> installs.

```bash
# Using an environment variable (recommended):
export HF_TOKEN=your_token_here
python upload.py

# Or pass the token directly:
python upload.py --token YOUR_HF_TOKEN

# Upload a single config (useful for testing):
python upload.py --token YOUR_HF_TOKEN --config bmlogic-c5

# Upload to a non-default repository:
python upload.py --repo your-org/your-repo --token YOUR_HF_TOKEN
```

The script loads each config, pushes it to the Hub, and uploads the dataset card
(`data/hf-dataset/README.md`). Hugging Face will auto-convert JSONL to Parquet.

### Step 5 — Post-Publish Verification

After upload, verify the dataset is accessible (see the next section).

---

## Post-Publish Verification

### Python Check

```python
from datasets import load_dataset

ds_bench = load_dataset("logos-labs/bmlogic-bench")
ds_c5    = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c5")
ds_c7    = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c7")
ds_proof = load_dataset("logos-labs/bmlogic-bench", "proof-steps")

assert len(ds_bench["test"])     == 727
assert len(ds_c5["train"])       == 1513
assert len(ds_c7["train"])       == 49904
assert len(ds_proof["train"])    == 2424
print("All record counts verified.")
```

### Browser

Visit the dataset card in a browser:

```
https://huggingface.co/datasets/logos-labs/bmlogic-bench
```

---

## NeurIPS Submission Extras

For NeurIPS 2026 Datasets and Benchmarks Track, two additional steps are required
after the initial upload.

### Croissant Metadata

Hugging Face auto-generates a Croissant metadata file. Download it from:

```
https://huggingface.co/datasets/logos-labs/bmlogic-bench/resolve/main/croissant.json
```

Include this file in the NeurIPS submission appendix or supplementary materials.

A pre-generated `data/croissant.json` is also checked in to this repository; see
[`data/README.md`](../../data/README.md#croissant-metadata) for validation commands.

### RAI Fields

Add Responsible AI (RAI) metadata fields to `data/hf-dataset/README.md` YAML
frontmatter, then re-upload:

```yaml
# Append to the YAML frontmatter, after the 'configs' section:
rai:
  intended_uses: >
    Evaluate and fine-tune language models on formal reasoning tasks.
    Research on bimodal (modal + temporal) logic reasoning.
  out_of_scope_uses: >
    Not suitable for safety-critical formal verification without human expert review.
    Not designed for classical propositional logic benchmarking.
  considerations: >
    Dataset contains only synthetic formal logic data. No personal information.
    Class imbalance in training data (~4% valid) should be addressed during
    model training.
```

After adding RAI fields:

```bash
python upload.py --token YOUR_HF_TOKEN
```

---

## Dataset Card and Schema Maintenance

The dataset card lives at `data/hf-dataset/README.md` (YAML frontmatter read by
Hugging Face) and is uploaded automatically by `upload.py`.

**Schema synchronization rule**: Whenever the JSONL schema changes (new fields,
renamed fields, changed field types), update **both**:

1. `data/croissant.json` — RecordSet field definitions for the affected distribution
2. `data/hf-dataset/README.md` — YAML frontmatter configs and dataset card schema
   documentation

After any schema change, re-run `python validate.py` and then re-upload via
`python upload.py --token YOUR_HF_TOKEN`.

---

## Troubleshooting

### Authentication Error

```
huggingface_hub.utils._errors.RepositoryNotFoundError
```

Ensure your token has **Write** scope and is authorized for the `logos-labs`
organization. Tokens are managed at <https://huggingface.co/settings/tokens>.

### Repository Not Found (404)

Create the repository manually at <https://huggingface.co/new-dataset>, or grant
your token org-admin access so `push_to_hub()` can create it automatically.

### Upload Timeout

`bmlogic-c7.jsonl` is ~52 MB. If upload times out on a slow connection, reduce the
shard size:

```bash
python upload.py --token YOUR_HF_TOKEN --max-shard-size 25MB
```

### Schema Inference Warnings

If the datasets library prints warnings about complex nested fields, these are
informational only. The data is still uploaded correctly.

### pip install fails on NixOS

On NixOS the system Python environment is read-only. A bare `pip install` will
fail with a permission error or "externally managed environment" message.

Use `nix-shell` to get all required packages without modifying your system:

```bash
nix-shell -p python3Packages.datasets python3Packages.huggingface-hub \
              python3Packages.pyarrow python3Packages.pyyaml
```

Or create a virtual environment inside a `nix-shell`:

```bash
nix-shell -p python3
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

See [Step 1 — Install Dependencies](#step-1--install-dependencies) for the full
NixOS setup options.

---

## Related Documentation

| Document | Description |
|---|---|
| [`data/hf-dataset/PUBLISHING.md`](../../data/hf-dataset/PUBLISHING.md) | Full operator guide with account setup |
| [`data/README.md`](../../data/README.md) | Dataset inventory, Croissant validation, download commands |
| [`docs/training/PIPELINE.md`](PIPELINE.md) | Dual-signal training pipeline (Lean modules, JSON schemas) |
