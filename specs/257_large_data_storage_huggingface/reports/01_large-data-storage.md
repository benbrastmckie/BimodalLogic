# Research Report: Task #257

**Task**: 257 - Investigate large data storage alternatives to Git LFS using Hugging Face
**Started**: 2026-06-01T12:00:00Z
**Completed**: 2026-06-01T12:45:00Z
**Effort**: M (3-4 hours estimated; 45 min research)
**Dependencies**: Informs tasks 245 (cross-repo data sync), 247 (pipeline validation)
**Sources/Inputs**:
- Local codebase: `.gitattributes`, `data/` directory, `data/hf-dataset/`, `data/README.md`, `data/hf-dataset/PUBLISHING.md`, `data/hf-dataset/upload.py`
- Git LFS status: `git lfs ls-files -s`, `git lfs env`, `git lfs track`
- Web: GitHub LFS billing docs, Hugging Face Hub storage-limits docs, DVC comparison articles, BFG Repo-Cleaner docs
**Artifacts**:
- `specs/257_large_data_storage_huggingface/reports/01_large-data-storage.md`
**Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

---

## Executive Summary

- The BimodalLogic repo already has a complete Hugging Face Hub publishing pipeline in `data/hf-dataset/` — the migration infrastructure exists and only requires an upload token and execution.
- Git LFS is tracking 4 file patterns; currently 2 LFS files are stored (~52 MB `bmlogic-c7.jsonl` + ~53 MB `proof_steps.jsonl`). The c9 and c11 files don't yet exist but are planned and tracked.
- GitHub LFS (as of Nov 2024) offers a generous 250 GiB free tier for storage AND bandwidth per month — the current usage (~105 MB) is well within free limits now, but will exceed them as complexity-9/11 datasets grow.
- Hugging Face Hub is the clear recommendation: it is purpose-built for ML datasets, offers effectively unlimited public storage for community datasets, provides built-in versioning (Git + Xet backend), and the project's publishing tooling is already written.
- Migration path is straightforward: upload to HF Hub (already scripted), remove LFS tracking from GitHub (edit `.gitattributes` + BFG history rewrite or just stop pushing new LFS objects), and update `data/README.md` and `BimodalHarness` sync scripts with HF download instructions.
- DVC is not recommended for this use case — it adds significant tooling complexity with no benefit over HF Hub when the dataset is already structured for public ML consumption.

---

## Context & Scope

The BimodalLogic repository generates JSONL training datasets for a bimodal logic ML project. The downstream consumer is [BimodalHarness](https://github.com/benbrastmckie/BimodalHarness). Current tracked LFS patterns are:

```
data/bmlogic-c7.jsonl    (currently ~52 MB, tracked)
data/bmlogic-c9.jsonl    (planned multi-hour compute, tracked but not yet generated)
data/bmlogic-c11.jsonl   (planned multi-hour compute, tracked but not yet generated)
data/proof_steps.jsonl   (currently ~53 MB, tracked)
```

The `data/hf-dataset/` subdirectory already contains:
- `upload.py` — complete upload script supporting 4 dataset configs (default/bench, c5, c7, proof-steps)
- `validate.py` — pre-upload validation with expected record counts
- `README.md` — HF dataset card with YAML frontmatter for 4 configs
- `PUBLISHING.md` — step-by-step publishing instructions

The dataset is intended to be published under `logos-labs/bmlogic-bench` on Hugging Face.

Research questions: (1) What are GitHub LFS limits and costs at scale? (2) What does HF Hub offer? (3) How does DVC compare? (4) What is the migration path? (5) How does BimodalHarness reference the data?

---

## Findings

### 1. GitHub Git LFS — Limits and Costs

As of November 2024, GitHub changed from data-pack billing to metered billing:

| Resource | Free Allocation | Additional Cost |
|----------|----------------|-----------------|
| LFS Storage | 250 GiB/month | $0.10/GiB/month |
| LFS Bandwidth | 250 GiB/month | $0.10/GiB/month |
| Max file size | 2 GB (Free) / 4 GB (Team) / 5 GB (Enterprise) | — |

**Current usage**: ~105 MB stored (c7 + proof_steps). This is negligible against the 250 GiB free tier. However:
- `bmlogic-c9.jsonl` at complexity-9 is estimated to be hundreds of MB to a few GB
- `bmlogic-c11.jsonl` at complexity-11 could be 5-20 GB
- Every `git clone` of the repo downloads all LFS objects by default, which charges bandwidth against the repo owner
- Bandwidth costs scale with every BimodalHarness `make sync-data` pull, every CI run, and every collaborator clone
- LFS stores every version of each file; regenerated datasets double (or more) the storage footprint

**Structural problems with LFS for ML data**:
- LFS is not designed for ML data versioning — no dataset viewer, no Parquet auto-conversion, no metadata schema display
- Cloning BimodalLogic forces downloading ~100+ MB of binary data even for contributors who only want to work on Lean code
- GitHub does not provide a CDN optimized for large ML file distribution

### 2. Hugging Face Hub — Capabilities and Limits

HF Hub is purpose-built for the ML ecosystem and offers significantly better properties for dataset hosting:

**Storage model (as of 2026)**:

| Account type | Public storage | Private storage |
|---|---|---|
| Free user/org | Best-effort (generous for community datasets) | 100 GB |
| PRO ($9/mo) | Up to 10 TB | 1 TB + pay-as-you-go |
| Team/Enterprise | 12+ TB + 1 TB/seat | 1 TB/seat |

For public datasets with genuine community value, HF Hub provides effectively unlimited storage — the current bmlogic-bench dataset with a complete dataset card, Croissant metadata, and clear ML utility qualifies. HF explicitly offers storage grants for high-impact open-source work via `datasets@huggingface.co`.

**Key capabilities**:
- Git-backed versioning with commit history, branches, and tags — supports pinning to a specific dataset version via commit SHA or branch name
- Xet storage backend (replacing LFS, acquired from XetHub Aug 2024) — chunked deduplication, only uploads changed chunks, faster uploads/downloads
- Automatic Parquet conversion for JSONL files — enables the interactive dataset viewer on the Hub UI
- Built-in CDN (CloudFront) for downloads
- `datasets` library integration: `load_dataset("logos-labs/bmlogic-bench")` or `load_dataset("logos-labs/bmlogic-bench", "bmlogic-c7")`
- `huggingface_hub.hf_hub_download()` for downloading individual files with revision pinning
- Rate limits: generous for public datasets; CI pipelines use HF tokens for authenticated access

**File and repo limits**:
- No per-repo size limit for public datasets
- Max single file: 500 GB hard limit (recommended: <200 GB per file)
- Recommended: <100k files per repo, <10k files per folder
- Current bmlogic datasets are small relative to these limits

**Versioning patterns**:
```python
# Download specific file at specific revision
from huggingface_hub import hf_hub_download
path = hf_hub_download(
    repo_id="logos-labs/bmlogic-bench",
    filename="data/bmlogic-c7.jsonl",
    repo_type="dataset",
    revision="v1.2"   # branch, tag, or commit SHA
)

# Load directly with datasets library
from datasets import load_dataset
ds = load_dataset("logos-labs/bmlogic-bench", "bmlogic-c7", split="train")

# Download without datasets library (for CI/shell scripts)
# huggingface-cli download logos-labs/bmlogic-bench data/bmlogic-c7.jsonl --repo-type dataset
```

### 3. DVC (Data Version Control)

DVC is an ML-oriented version control tool that tracks data files via `.dvc` pointer files committed to git, with actual data stored in a configurable remote (S3, GCS, Azure Blob, SSH, HF Hub, etc.).

**Pros**:
- Remote-agnostic: can back to S3, GCS, local NFS, SSH, or HF Hub
- Pipeline reproducibility: tracks data + code + metrics together
- Good for teams doing frequent experiments with data mutations
- DVC v3.31+ supports importing directly from HF Hub repos

**Cons for this use case**:
- Adds a mandatory DVC toolchain dependency to any downstream consumer (BimodalHarness, CI systems)
- BimodalHarness is a Python ML project — adding DVC requires `dvc` install and `dvc pull` in every environment
- The datasets are generated artifacts (not manually curated), so the "experiment tracking" value is minimal
- The HF Hub already provides versioning, branching, and commit history natively
- DVC does not provide the dataset viewer, Parquet conversion, or ML ecosystem integrations that HF Hub does

**Verdict**: DVC is best when you need multi-cloud or private remote storage and deep pipeline tracking. For public ML dataset distribution, HF Hub is simpler and provides more value.

### 4. Other Alternatives Considered

| Option | Assessment |
|---|---|
| GitHub Release Assets | Free, no bandwidth charges, but manual upload, no versioning, 2 GB per file limit, no ML ecosystem integration |
| Zenodo | Excellent for archival/citation (DOI assignment), but 50 GB per record limit, no streaming, not designed for iterative ML dataset updates |
| AWS Open Data | Requires AWS account and S3 bucket management; good for very large datasets (>1 TB); overkill for current scale |
| Oxen.ai | Emerging ML data platform, Git-like, but smaller community and ecosystem than HF Hub |

### 5. Current Project State: HF Hub Already Partially Set Up

The project is further along than the task description implies:

1. `data/hf-dataset/upload.py` — complete, tested upload script
2. `data/hf-dataset/validate.py` — pre-upload validation
3. `data/hf-dataset/README.md` — dataset card with YAML frontmatter configuring 4 dataset configs
4. `data/hf-dataset/PUBLISHING.md` — publishing instructions
5. `data/croissant.json` — MLCommons Croissant 1.0 metadata
6. `data/dataset-card.md` — preserved original HF dataset card

The upload script publishes 4 configs: `default` (bench, test split), `bmlogic-c5` (train), `bmlogic-c7` (train), `proof-steps` (train). The target repo is `logos-labs/bmlogic-bench`.

**What is missing**:
- The `logos-labs` HuggingFace organization does not appear to have been created yet (or upload not executed)
- No download script in `BimodalHarness` that pulls from HF Hub instead of syncing via `make sync-data`
- The `.gitattributes` still tracks the large files via LFS; these should be removed once data is on HF Hub

### 6. Migration Path from Git LFS to HF Hub

**Phase 1: Upload data to HF Hub (no destructive changes)**
1. Create `logos-labs` HF organization (if not exists): `https://huggingface.co/organizations/new`
2. Generate HF write token: `https://huggingface.co/settings/tokens`
3. Run existing validation: `cd data/hf-dataset && python validate.py`
4. Run upload: `python upload.py --token $HF_TOKEN`
5. Verify dataset card renders correctly on HF Hub UI
6. Pin the version: create a git tag on the HF dataset repo (`v1.0`)

**Phase 2: Update downstream consumers**
1. In `BimodalHarness`, replace `make sync-data` with an HF download script:
   ```bash
   huggingface-cli download logos-labs/bmlogic-bench \
     --repo-type dataset \
     --local-dir data/bimodal/ \
     --include "*.jsonl"
   ```
   Or in Python:
   ```python
   from huggingface_hub import snapshot_download
   snapshot_download(repo_id="logos-labs/bmlogic-bench", repo_type="dataset",
                     local_dir="data/bimodal/", ignore_patterns=["*.md"])
   ```
2. Update `BimodalHarness` README with HF Hub dataset link and download instructions
3. Update `BimodalLogic/data/README.md` to reference HF Hub as canonical source

**Phase 3: Remove LFS from BimodalLogic (optional, recommended)**
1. Stop tracking large files in `.gitattributes`:
   ```bash
   # Edit .gitattributes: remove or comment out LFS lines for data/*.jsonl
   ```
2. For future generated files, store locally (not in git) and push to HF Hub via `upload.py`
3. Optionally rewrite git history to remove existing LFS objects (prevents future bandwidth charges):
   - Use BFG Repo-Cleaner: `java -jar bfg.jar --strip-blobs-bigger-than 50M your-repo.git`
   - Or use `git lfs migrate export --include="data/*.jsonl"` to convert existing LFS objects to regular files, then run `git filter-repo` to remove them
   - Note: history rewrite requires all collaborators to re-clone; coordinate timing
4. Alternatively (simpler): leave LFS history as-is but stop adding new LFS objects; over time the old objects become unreferenced and can be pruned via GitHub's LFS management UI

### 7. Integration Pattern for CI/CD

For CI pipelines in BimodalLogic that regenerate datasets and publish updates:

```yaml
# .github/workflows/publish-dataset.yml (example)
- name: Upload to HF Hub
  env:
    HF_TOKEN: ${{ secrets.HF_TOKEN }}
  run: |
    cd data/hf-dataset
    pip install -r requirements.txt
    python validate.py
    python upload.py --token $HF_TOKEN
```

For BimodalHarness CI that needs fresh data:
```yaml
- name: Download dataset from HF Hub
  run: |
    pip install huggingface_hub
    python -c "
    from huggingface_hub import snapshot_download
    snapshot_download('logos-labs/bmlogic-bench', repo_type='dataset',
                      local_dir='data/bimodal/', revision='v1.0')
    "
```

The `revision` parameter allows pinning to a specific version, ensuring reproducible training runs.

---

## Decisions

1. **Recommended primary host**: Hugging Face Hub (`logos-labs/bmlogic-bench`). The infrastructure is already built; this is the right choice for a public ML dataset.
2. **Git LFS future policy**: Stop adding new LFS-tracked files once the HF upload is complete. Remove LFS tracking from `.gitattributes`. Existing LFS objects can remain in git history initially to avoid disruptive rewrite.
3. **DVC**: Not recommended for this use case. No action needed.
4. **BimodalHarness sync**: Replace `make sync-data` with `huggingface_hub` download targeting a pinned revision.

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| HF Hub "best-effort" public storage for free orgs may be throttled if downloads spike | Low (dataset has modest download volume now) | Upgrade to PRO or apply for storage grant if dataset becomes widely used |
| History rewrite (Phase 3) breaks existing clones / CI | Medium if done | Coordinate timing; announce to all collaborators; update CI to re-clone |
| `logos-labs` org doesn't exist on HF Hub | Medium | Create org before upload; use personal account as interim |
| HF Hub outage blocks BimodalHarness training | Low (HF has high availability) | Cache data locally in BimodalHarness; pin to a revision so fallback cache is stable |
| Large complexity-9/11 files exceed single-file-size best practices | Low (expected <10 GB each) | HF recommends <200 GB; split into chunks if needed |
| Upload script DATASET_CONFIGS has hardcoded expected record counts (49904 for c7) | Medium (will break for regenerated datasets) | Update `upload.py` EXPECTED_COUNTS when regenerating at new sizes |

---

## Context Extension Recommendations

- **Topic**: HF Hub dataset publishing workflow for this project
- **Gap**: No `.claude/context/` entry documents the HF publishing pipeline, how to update expected record counts in `upload.py`, or how BimodalHarness should reference dataset versions
- **Recommendation**: Add a short context file (`.context/data-pipeline.md`) documenting: HF dataset repo name, how to upload, revision pinning strategy, and the relationship between BimodalLogic data generation and BimodalHarness consumption.

---

## Appendix

### References

- [GitHub Git LFS Billing Docs](https://docs.github.com/billing/managing-billing-for-git-large-file-storage/about-billing-for-git-large-file-storage)
- [HF Hub Storage Limits](https://huggingface.co/docs/hub/storage-limits)
- [HF Hub: Share a Dataset](https://huggingface.co/docs/datasets/upload_dataset)
- [HF Hub: Download Files](https://huggingface.co/docs/huggingface_hub/guides/download)
- [HF Hub: Datasets Downloading](https://huggingface.co/docs/hub/en/datasets-downloading)
- [DVC vs Git LFS vs lakeFS Comparison](https://lakefs.io/blog/dvc-vs-git-vs-dolt-vs-lakefs/)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [Removing Files from Git LFS (GitHub Docs)](https://docs.github.com/en/repositories/working-with-files/managing-large-files/removing-files-from-git-large-file-storage)
- [HF Migrating Hub from Git LFS to Xet](https://huggingface.co/blog/migrating-the-hub-to-xet)

### Search Queries Used

- `GitHub Git LFS storage limits costs bandwidth 2025 2026`
- `Hugging Face Hub dataset repository external data host versioning 2025`
- `DVC data version control vs Git LFS vs Hugging Face comparison 2025`
- `Hugging Face Hub dataset storage limits free tier pricing 2025 2026`
- `migrate from Git LFS to Hugging Face Hub dataset remove LFS history`
- `huggingface_hub python download dataset from HF Hub CI integration reference external repo`
- `formal methods machine learning datasets external storage Zenodo GitHub release assets best practice`

### Current LFS State (as of 2026-06-01)

```
Tracked patterns (.gitattributes):
  data/bmlogic-c7.jsonl    filter=lfs diff=lfs merge=lfs -text
  data/bmlogic-c9.jsonl    filter=lfs diff=lfs merge=lfs -text
  data/bmlogic-c11.jsonl   filter=lfs diff=lfs merge=lfs -text
  data/proof_steps.jsonl   filter=lfs diff=lfs merge=lfs -text

Currently stored in LFS:
  a7ef5759bc * data/bmlogic-c7.jsonl    (52 MB)
  2891c97043 * data/proof_steps.jsonl   (53 MB)

Remote: git@github.com:benbrastmckie/ProofChecker.git
LFS Endpoint: https://github.com/benbrastmckie/ProofChecker.git/info/lfs
```

### Data Directory Summary

```
data/
├── bmlogic-c5.jsonl             1.3 MB  (not LFS tracked — small enough)
├── bmlogic-c7.jsonl            50   MB  (LFS tracked)
├── proof_steps.jsonl           51   MB  (LFS tracked)
├── bmlogic-bench.jsonl        766   KB  (not LFS tracked)
├── bmlogic-bench-candidates.jsonl  1.8 MB
├── bmlogic-bench-validated.jsonl   2.1 MB
├── croissant.json              23   KB
├── dataset-card.md             15   KB
├── hf-dataset/                 (HF publishing tooling)
│   ├── upload.py
│   ├── validate.py
│   ├── README.md               (dataset card)
│   ├── PUBLISHING.md
│   └── requirements.txt
└── scripts/                    (generation and curation scripts)
```
