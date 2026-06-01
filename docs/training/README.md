# docs/training/

Training data pipeline documentation for the BMLogic-Bench project.

**Audience**: ML researchers and contributors working on neural proof search,
dataset publishing, and training data generation.

---

## Documents

| File | Description |
|---|---|
| [PIPELINE.md](PIPELINE.md) | Dual-signal training data pipeline — all 6 Lean modules, JSON schemas, BimodalHarness integration |
| [PUBLISHING_GUIDE.md](PUBLISHING_GUIDE.md) | Consumer quick-start and maintainer workflow for publishing to Hugging Face Hub |

---

## Related Directories

| Path | Description |
|---|---|
| [`data/`](../../data/) | Canonical JSONL dataset files and metadata |
| [`data/hf-dataset/`](../../data/hf-dataset/) | Upload tooling, dataset card, and validation scripts |

For the full operator-level publishing workflow (account setup, validation
steps, troubleshooting), see
[`data/hf-dataset/PUBLISHING.md`](../../data/hf-dataset/PUBLISHING.md).
