# Publishing BMLogic-Bench to HuggingFace Hub

This guide walks through publishing the BMLogic-Bench dataset to
`logos-labs/bmlogic-bench` on HuggingFace Datasets Hub.

## Prerequisites

Before starting, you need:

1. **HuggingFace account** at https://huggingface.co
2. **logos-labs organization** created on HuggingFace (or use your own org/username)
   - Create at: https://huggingface.co/organizations/new
3. **Repository created** (optional — `push_to_hub()` creates it automatically with appropriate permissions)
4. **API token** with write access
   - Generate at: https://huggingface.co/settings/tokens
   - Select "Write" scope

## Step 1: Install Dependencies

From the `hf-dataset/` directory:

```bash
pip install -r requirements.txt
```

This installs:
- `datasets>=2.19.0` — HuggingFace Datasets library
- `huggingface_hub>=0.23.0` — Hub API client
- `pyarrow>=14.0.0` — Arrow serialization (used by datasets)
- `pyyaml>=6.0` — YAML parsing for README.md validation

## Step 2: Validate Packaging

Run the validation script to confirm all data files are in order:

```bash
python validate.py
```

Expected output: All 5 checks pass with exit code 0:
- README.md YAML frontmatter valid (4 configs)
- bmlogic-bench: 727 records, all required fields non-null
- bmlogic-c5: 1,513 records, all required fields non-null
- bmlogic-c7: 49,904 records, all required fields non-null
- proof-steps: 2,424 records, all required fields non-null

If any check fails, do not proceed to upload. Fix the issue first.

## Step 3: Dry Run

Load all four dataset configurations locally without pushing to HuggingFace:

```bash
python upload.py --dry-run
```

This will:
- Load each JSONL file using the `datasets` library
- Print record counts and schema information
- Exit without pushing anything

Verify the output shows all four configs loading with correct record counts:
- default (bmlogic-bench): 727 records
- bmlogic-c5: 1,513 records
- bmlogic-c7: 49,904 records
- proof-steps: 2,424 records

## Step 4: Publish

Upload all four configs to HuggingFace Hub:

```bash
python upload.py --token YOUR_HF_TOKEN
```

Or, if you set the `HF_TOKEN` environment variable:

```bash
export HF_TOKEN=your_token_here
python upload.py
```

To upload to a different repository:

```bash
python upload.py --repo your-username/your-repo-name --token YOUR_HF_TOKEN
```

To upload a single config (e.g., for testing):

```bash
python upload.py --token YOUR_HF_TOKEN --config bmlogic-c5
```

**Note**: `bmlogic-c7.jsonl` is ~52 MB. Upload may take several minutes depending on
your connection speed.

The script will:
1. Load each JSONL configuration
2. Push each config to the Hub with the correct config name and split
3. Upload the README.md as the dataset card
4. Print a success message with the dataset URL

## Step 5: Post-Publish Verification

After upload, verify the dataset is accessible:

```python
from datasets import load_dataset

# Load default config (evaluation benchmark)
ds = load_dataset("logos-labs/bmlogic-bench")
print(ds)  # DatasetDict({'test': Dataset({features: [...], num_rows: 727})})

# Load training data
train_small = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c5")
train_large = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c7")
proof_steps = load_dataset("logos-labs/bmlogic-bench", "proof-steps")

# Quick count check
assert len(ds["test"]) == 727
assert len(train_small["train"]) == 1513
assert len(train_large["train"]) == 49904
assert len(proof_steps["train"]) == 2424
print("All checks passed!")
```

You can also view the dataset card in a browser at:
```
https://huggingface.co/datasets/logos-labs/bmlogic-bench
```

## Step 6: NeurIPS Submission Extras

For NeurIPS 2026 Datasets and Benchmarks Track submission, two additional steps are required:

### 6a: Download Croissant Metadata

After upload, HuggingFace auto-generates a Croissant metadata file. Download it from:
```
https://huggingface.co/datasets/logos-labs/bmlogic-bench/resolve/main/croissant.json
```

Include this file in the NeurIPS submission appendix or supplementary materials.

### 6b: Add RAI (Responsible AI) Fields

HuggingFace supports optional RAI metadata fields in the dataset card YAML frontmatter.
Add these manually to `hf-dataset/README.md` and re-upload (or edit via the Hub web interface):

```yaml
# Add to YAML frontmatter, after the 'configs' section:
rai:
  # Intended use cases for the dataset
  intended_uses: >
    Evaluate and fine-tune language models on formal reasoning tasks.
    Research on bimodal (modal + temporal) logic reasoning.
  # Known harmful or inappropriate use cases
  out_of_scope_uses: >
    Not suitable for safety-critical formal verification without human expert review.
    Not designed for classical propositional logic benchmarking.
  # Ethical considerations
  considerations: >
    Dataset contains only synthetic formal logic data. No personal information.
    Class imbalance in training data (~4% valid) should be addressed during model training.
```

After adding RAI fields, re-run `python upload.py --token YOUR_HF_TOKEN` to update the dataset card.

## Troubleshooting

### Authentication Error
```
huggingface_hub.utils._errors.RepositoryNotFoundError
```
Ensure your token has write access to the `logos-labs` organization.

### Repository Not Found
```
404 Client Error
```
Create the repository manually at:
```
https://huggingface.co/new-dataset
```
Or let `push_to_hub()` create it automatically (requires org admin access).

### Upload Timeout
For large files (bmlogic-c7.jsonl at ~52 MB), upload may time out on slow connections.
Use a lower `--max-shard-size` to reduce individual file sizes:
```bash
python upload.py --token YOUR_HF_TOKEN --max-shard-size 25MB
```

### Schema Inference Error
If the dataset library fails to infer the schema from nested JSON fields, the script
handles this by loading as generic JSON. If you see warnings about complex nested fields,
they are informational only — the data is still uploaded correctly.

## File Structure

The `hf-dataset/` directory contains:
```
hf-dataset/
├── README.md          # Dataset card with YAML frontmatter (HF reads this)
├── upload.py          # Upload script (this directory must be your working dir)
├── validate.py        # Validation script
├── requirements.txt   # Python dependencies
├── PUBLISHING.md      # This file
└── data/              # Symlinks to data/ directory in repo root
    ├── bmlogic-bench.jsonl  -> ../../data/bmlogic-bench.jsonl
    ├── bmlogic-c5.jsonl     -> ../../data/bmlogic-c5.jsonl
    ├── bmlogic-c7.jsonl     -> ../../data/bmlogic-c7.jsonl
    └── proof_steps.jsonl    -> ../../data/proof_steps.jsonl
```

The symlinks point to the canonical data files in `data/`. The data files themselves
are not duplicated. When HuggingFace Hub uploads the files, it follows the symlinks
and uploads the actual JSONL content.
