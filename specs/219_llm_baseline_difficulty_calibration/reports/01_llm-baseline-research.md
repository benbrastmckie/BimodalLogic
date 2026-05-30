# Research Report: Task #219

**Task**: 219 - LLM Baseline Difficulty Calibration
**Started**: 2026-05-29T16:00:00Z
**Completed**: 2026-05-29T17:00:00Z
**Effort**: 3 hours
**Dependencies**: Task 216 (NL paraphrase augmentation - COMPLETED)
**Sources/Inputs**:
- `data/bmlogic-bench.jsonl` (727 records, direct inspection)
- `data/bmlogic-bench_metadata.json` (benchmark metadata)
- `data/bmlogic-bench-splits.json` (cross-logic transfer splits)
- `data/README.md` (data directory documentation)
- `data/scripts/prompt_template.txt` (existing LLM prompt template)
- `docs/research/competitive-landscape.md` (competitive analysis)
- `docs/training/PIPELINE.md` (training pipeline documentation)
- Anthropic Models API documentation (platform.claude.com)
- ArXiv: LTLBench (2407.05434) - temporal logic LLM evaluation
- ArXiv: "Can Large Language Models Learn Formal Logic?" (2504.20213)
- EleutherAI lm-evaluation-harness documentation
- Web search: LLM formal logic evaluation practices (2025)
**Artifacts**:
- `specs/219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md`
**Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

---

## Executive Summary

- The bmlogic-bench dataset (727 records, 4 tiers, 46.8% valid) has full NL paraphrase coverage from task 216, enabling both symbolic and NL-based LLM evaluation immediately.
- The benchmark has a deliberate class imbalance: `easy` tier is 94% invalid, while `medium`/`hard`/`very_hard` are near 50/50 — the random baseline accuracy is approximately 53% overall (label-weighted), not a simple 50%.
- Three models are feasible with current infrastructure: GPT-4o via `openai==2.31.0` (OPENAI_API_KEY set), Claude Sonnet via the Anthropic API (ANTHROPIC key needs install of `anthropic` package or alternative route), and a 7B model via Ollama's OpenAI-compatible endpoint once Ollama is running.
- A lightweight custom Python evaluation harness is preferred over lm-eval-harness for this task: simpler to configure, supports both symbolic and NL inputs, handles rate limits, and produces per-tier accuracy tables directly.
- The nearest comparable benchmark (LTLBench, 2024) found LLMs struggle significantly on complex temporal logic tasks; bimodal logic with both modal and temporal operators is expected to be harder.
- Key evaluation dimensions: zero-shot vs chain-of-thought (two prompt modes), symbolic formula vs NL paraphrase (two input modes), and accuracy broken down by difficulty tier and logic fragment (propositional/modal/temporal/bimodal).

---

## Context & Scope

Task 219 establishes LLM baseline difficulty calibration for bmlogic-bench, the stratified evaluation benchmark for bimodal logic TM (combining S5 modal logic with LTL temporal logic). This research phase covers:

1. Dataset structure and schema for all fields relevant to evaluation
2. NL paraphrase availability confirmed from task 216
3. API access, Python environment, and model selection
4. Prompt design for zero-shot and chain-of-thought classification
5. Evaluation metrics and reporting structure
6. Evaluation framework selection

---

## Findings

### 1. Dataset Structure

**File**: `data/bmlogic-bench.jsonl`  
**Records**: 727  
**Schema fields relevant to evaluation**:

| Field | Type | Example | Use |
|-------|------|---------|-----|
| `id` | string | `bmlogic-bench-00001` | Record identifier |
| `formula_str` | string | `((U(r, q) → p) → p)` | Symbolic input to LLM |
| `formula_ast` | JSON object | `{"tag": "imp", ...}` | Structural analysis |
| `label` | string | `"valid"` or `"invalid"` | Ground truth |
| `difficulty_tier` | string | `easy/medium/hard/very_hard` | Tier stratification |
| `metrics.modalDepth` | int | 0–3 | Modal nesting depth |
| `metrics.temporalDepth` | int | 0–3 | Temporal nesting depth |
| `metrics.complexity` | int | 1–63 | AST node count |
| `metrics.impCount` | int | 0–7 | Implication count |
| `nl_paraphrase` | string | `"If (if ...)..."` | NL input to LLM (from task 216) |
| `nl_paraphrase_method` | string | `rule_based/rule_based_complex` | Paraphrase provenance |
| `proof_trace` | JSON or null | `{"height": 0, ...}` | Available for valid formulas |
| `countermodel` | JSON or null | `{"trueAtoms": [], ...}` | Available for invalid formulas |

**Operator vocabulary** (12 operators): `atom`, `bot`, `top`, `neg`, `conj`, `disj`, `imp`, `box`, `dia`, `untl`, `snce` (plus derived: `neg`, `top`, `next`, `eventually`, `yesterday`).  
**Unicode symbols used in formula_str**: `□` (box), `◇` (dia), `U()` (until), `S()` (since), `⊥` (bot), `→` (imp).

### 2. Label and Tier Distribution

| Tier | Total | Valid | Invalid | Valid% | Random Baseline |
|------|-------|-------|---------|--------|----------------|
| easy | 50 | 3 | 47 | 6.0% | 6% (always-invalid) |
| medium | 300 | 150 | 150 | 50.0% | 50% |
| hard | 262 | 131 | 131 | 50.0% | 50% |
| very_hard | 115 | 56 | 59 | 48.7% | ~49% |
| **Total** | **727** | **340** | **387** | **46.8%** | **~47%** |

**Implication for random baseline**: A random model that always predicts "invalid" achieves ~53.2% accuracy overall. A genuinely random (50/50) model achieves approximately 46.8% × 50% + 53.2% × 50% = 50% overall, but only ~6% on easy tier and ~50% on others. The meaningful random baseline is **always-predict-invalid** at 53.2%, which an LLM must beat to demonstrate above-chance performance.

**Cross-logic transfer splits** (from `bmlogic-bench-splits.json`):
| Fragment | Records | Valid% | Notes |
|----------|---------|--------|-------|
| propositional-only | 97 | 58.8% | Comparable to FOLIO/ProofWriter |
| modal-only | 144 | 62.5% | S5 modal logic |
| temporal-only | 247 | 40.1% | Comparable to LTLBench |
| bimodal | 239 | 39.3% | Unique to bmlogic-bench |

**Depth ranges**:
- Modal depth: 0–3 (avg: easy=0.16, medium=0.87, hard=0.34, very_hard=0.70)
- Temporal depth: 0–3 (avg: easy=0.64, medium=0.75, hard=1.09, very_hard=0.74)
- Complexity: 1–63 (AST node count)

**Note**: The difficulty tier is based on a composite heuristic of complexity, modal depth, temporal depth, and impCount — not a single axis. This explains the non-monotone depth averages across tiers.

### 3. NL Paraphrase Coverage (Task 216 Output)

All 727 records have `nl_paraphrase` and `nl_paraphrase_method` fields:
- `rule_based`: 635 records (87.3%) — formulas with modalDepth + temporalDepth ≤ 2
- `rule_based_complex`: 92 records (12.7%) — formulas with modalDepth + temporalDepth ≥ 3

Paraphrases are English sentences using no formal symbols. Examples:
- Formula: `((U(r, q) → p) → p)` → "If (if (proposition q holds until proposition r holds), then proposition p holds), then proposition p holds."
- Formula: `(⊥ → U(q, □r))` → "If a contradiction, then (necessarily(proposition r holds) until proposition q holds)."

The NL paraphrases are available for both evaluation input modes: LLMs can be evaluated on (a) raw symbolic formula_str with operator glossary, or (b) English NL paraphrase.

### 4. Python Environment and API Access

**Available**:
- Python 3.12.13 (Nix environment)
- `openai==2.31.0` (installed) — supports GPT-4o via OPENAI_API_KEY (set)
- `requests==2.33.1` (installed) — supports any HTTP API
- `numpy==2.4.0`, `pandas==2.3.3` (installed) — data analysis
- `torch==2.11.0` (installed) — local model inference if needed
- OPENAI_API_KEY: set
- OLLAMA_API_KEY: set (but Ollama server not currently running at localhost:11434)

**Not available (needs install)**:
- `anthropic` SDK — ANTHROPIC_DEFAULT_OPUS_MODEL env var exists but anthropic package not in nix store
- `transformers` — not installed; local HuggingFace model inference not available
- `lm-evaluation-harness` — not installed

**Workaround for Anthropic API**: The `openai` package v2.x supports a custom `base_url` and can be pointed at Anthropic's OpenAI-compatible endpoint (`https://api.anthropic.com/v1`) or the native API can be called via `requests` with the Anthropic HTTP format.

**Recommended approach**: Install `anthropic` package via `pip install anthropic` (or build a thin `requests`-based wrapper), use `openai.OpenAI` for GPT-4o, and use Ollama's OpenAI-compatible endpoint for the open 7B model.

### 5. Model Selection

**Tier 1 (Frontier)**:
- **GPT-4o** (`gpt-4o-2024-11-20` or `gpt-4o`) via OpenAI API — strong reasoning, widely benchmarked, directly accessible
- **Claude Sonnet 4.6** (`claude-sonnet-4-6`) via Anthropic API — fast, strong reasoning, $3/MTok input — requires `anthropic` package install

**Tier 2 (Open/Local 7B)**:
- **Llama 3.1 8B Instruct** via Ollama (`llama3.1:8b`) — leading open model in its class, OpenAI-compatible API
- **Mistral 7B Instruct** via Ollama (`mistral:7b`) — fast, OpenAI-compatible, 4.1GB
- **DeepSeek-R1:7B** via Ollama — chain-of-thought specialized, best local math at 7B class
- **Qwen 2.5 7B** via Ollama — strong reasoning, well-benchmarked

**Recommended selection**: GPT-4o, Claude Sonnet 4.6, and one 7B model (Llama 3.1 8B or DeepSeek-R1:7B for CoT focus). Requires Ollama service to be started (`ollama serve`).

### 6. Prompt Design

**Two prompt modes** should be evaluated:

**Mode A: Zero-Shot Direct (symbolic)**
```
You are evaluating whether a formula of bimodal logic TM is valid (provable) or invalid (has a countermodel).

OPERATORS:
- □φ: "it is necessarily the case that φ" (S5 modal necessity)
- ◇φ: "it is possible that φ" (S5 modal possibility)
- U(φ, ψ): "ψ holds at some future time, and φ holds at every intermediate time until then" (Until)
- S(φ, ψ): "ψ held at some past time, and φ has held at every intermediate time since then" (Since)
- ⊥: contradiction (falsum)
- →: implication

Formula: {formula_str}

Is this formula valid or invalid in bimodal logic TM?
Answer with exactly one word: "valid" or "invalid".
```

**Mode B: Chain-of-Thought (symbolic)**
```
You are evaluating whether a formula of bimodal logic TM is valid (provable) or invalid (has a countermodel).

[OPERATOR GLOSSARY - same as above]

Formula: {formula_str}

Think step by step:
1. Identify the top-level structure of the formula.
2. Consider whether the formula holds in all S5+LTL models (valid) or has a counterexample (invalid).
3. State your conclusion.

Final answer (valid or invalid): 
```

**Mode C: Zero-Shot Direct (NL paraphrase)**
```
You are evaluating whether a logical claim is provable or has a counterexample.

Claim: {nl_paraphrase}

Is this claim necessarily true in all possible worlds and times (valid), or can it fail (invalid)?
Answer with exactly one word: "valid" or "invalid".
```

**Mode D: Chain-of-Thought (NL paraphrase)**
```
[Same as Mode C but with "Think step by step..." instruction]
```

**Output parsing**: Extract the last occurrence of "valid" or "invalid" (case-insensitive) from the response. For direct-answer modes, enforce a system prompt requesting single-word output. For CoT modes, parse the final answer line.

**Special cases to handle**:
- Refusal to answer (treat as abstention, report separately)
- Neither "valid" nor "invalid" found (parse error, report rate)
- Both words present (take last occurrence or the final answer line)

### 7. Evaluation Metrics

**Primary metrics** (per model, per prompt mode):

| Metric | Description |
|--------|-------------|
| `accuracy` | Correct predictions / total predictions |
| `accuracy_by_tier` | Accuracy for each of easy/medium/hard/very_hard |
| `accuracy_by_fragment` | Accuracy for propositional/modal/temporal/bimodal splits |
| `accuracy_by_label` | Accuracy separately for valid formulas and invalid formulas |
| `parse_error_rate` | Fraction of responses with no parseable label |
| `abstention_rate` | Fraction of model refusals |

**Correlation analysis**:
- Pearson/Spearman correlation between error rate and `modalDepth`
- Pearson/Spearman correlation between error rate and `temporalDepth`
- Pearson/Spearman correlation between error rate and `complexity`
- Breakdown by `nl_paraphrase_method` (rule_based vs rule_based_complex)

**Baselines to include**:
- Always-invalid: 53.2% overall (actual random baseline given label imbalance)
- Always-valid: 46.8% overall
- Random 50/50: ~50% (weighted by tier)
- Majority-class-per-tier: easy=94%, medium=50%, hard=50%, very_hard=51%

**CoT vs direct gap**: For each model, report delta accuracy between Mode A/C (direct) and Mode B/D (CoT). This is the chain-of-thought benefit.

**NL vs symbolic gap**: For each model, report delta accuracy between symbolic and NL-paraphrase inputs.

### 8. Evaluation Framework

**Recommended approach**: Custom lightweight Python script (not lm-eval-harness).

**Rationale**:
- lm-eval-harness is not installed and requires significant configuration
- Custom script is ~200 lines, directly supports all 4 prompt modes
- Custom script produces per-tier CSV output needed for the baselines README
- Custom script handles rate limiting, retries, cost tracking, and progress checkpointing

**Script architecture**:
```
data/scripts/run_baseline_eval.py
  - load_benchmark(path: str) -> List[Record]
  - build_prompt(record: Record, mode: str) -> str  # modes: direct_sym, cot_sym, direct_nl, cot_nl
  - call_openai(prompt, model, client) -> str
  - call_anthropic(prompt, model, client) -> str
  - call_ollama(prompt, model, base_url) -> str
  - parse_label(response: str) -> str | None
  - evaluate(records, model, mode, call_fn) -> Results
  - compute_metrics(results: Results) -> MetricsTable
  - save_results(results, output_dir)
  - main() -> argparse CLI
```

**Output structure**:
```
data/baselines/
  raw/
    gpt4o_direct_sym.jsonl       # per-record: id, response, parsed_label, correct
    gpt4o_cot_sym.jsonl
    claude_sonnet_direct_sym.jsonl
    claude_sonnet_cot_sym.jsonl
    claude_sonnet_direct_nl.jsonl
    llama31_direct_sym.jsonl
    ...
  metrics/
    gpt4o_metrics.json
    claude_sonnet_metrics.json
    llama31_metrics.json
  README.md                       # Human-readable results with methodology
```

**Cost estimate** (727 records × 4 modes × 3 models):
- GPT-4o: ~2000 tokens/record × 2 modes × 727 ≈ 3M tokens input → ~$9
- Claude Sonnet 4.6: ~2000 tokens × 2 modes × 727 ≈ 3M tokens → ~$9
- 7B via Ollama: local, free

**Rate limits**: OpenAI and Anthropic both allow batch processing with ~1-2 second delays between requests. For 727 × 2 = 1454 calls per model, expect ~30-45 minutes per frontier model.

### 9. Comparable Benchmark Results (Context)

**LTLBench (2024)** — closest comparable:
- 2,000 LTL satisfiability classification problems
- Benchmarked 12 LLMs across 5 prompting methods
- Key finding: LLMs "still struggle with complex temporal reasoning" with non-linear performance changes as formula complexity increases
- No specific accuracy figures were obtainable from the abstract (paper at arxiv.org/abs/2407.05434)

**Synthetic Boolean logic (2025)**:
- Fine-tuned Llama-8B achieved 98% on Boolean proof tasks (fine-tuned, not zero-shot)
- GPT-4o achieved ~70% on few-shot Boolean logic tasks (far lower than fine-tuned)

**Implication for bimodal logic**:
- Expected zero-shot accuracy range for frontier models: 50–65% (near random on hard/very_hard tiers)
- Modal + temporal combination likely harder than LTL-only
- CoT prompting expected to provide 5–15% improvement over direct for complex formulas
- NL paraphrase input may hurt performance for very complex formulas (ambiguity of nested English) but help for simpler ones

**ProofWriter comparison**: LLMs achieve 80–95% on propositional-depth-1 ProofWriter but drop to 50–60% at depth 5. BMLogic-bench medium/hard tiers involve depth-1 to depth-3 bimodal operators; accuracy in the 50–65% range for frontier models is plausible.

### 10. Context Gap Identified

The project lacks a documented evaluation methodology file. The `data/baselines/` directory does not yet exist. The `data/README.md` mentions LLM baseline calibration as a research gap (competitive-landscape.md R4 priority). No existing Python evaluation infrastructure covers API-based LLM testing.

---

## Decisions

1. **Custom Python script over lm-eval-harness**: lm-eval-harness is not installed, requires configuration, and is heavier than needed. A 200-line custom script is sufficient and more maintainable.
2. **Four prompt modes**: Direct and CoT, each with symbolic and NL-paraphrase input. This covers the task requirement for "symbolic formula input" and "NL paraphrase input (if available from R1)."
3. **Three models**: GPT-4o (OpenAI API), Claude Sonnet 4.6 (Anthropic API), and Llama 3.1 8B or DeepSeek-R1:7B via Ollama for the open 7B model.
4. **Anthropic access approach**: Use `anthropic` Python package (installable via pip) or implement a thin `requests` wrapper for the Anthropic Messages API.
5. **Random baseline**: Use always-predict-invalid (53.2%) as the primary random baseline, not 50%, to reflect actual label distribution.
6. **Output directory**: `data/baselines/` with `raw/` for per-record JSONL and `metrics/` for aggregated JSON, plus `README.md` as the published results document.
7. **Evaluation order**: Run GPT-4o first (most reliable, cheapest per token at this scale), then Claude Sonnet, then 7B model.

---

## Recommendations

1. **Implement the evaluation script** at `data/scripts/run_baseline_eval.py` using the four-mode architecture described above. This is the primary deliverable of the implementation phase.
2. **Install the anthropic package** before running: `pip install anthropic` or use a virtualenv approach. Alternatively, implement a thin requests-based wrapper using `ANTHROPIC_API_KEY` (check if this env var exists or needs to be set from `ANTHROPIC_DEFAULT_OPUS_MODEL`).
3. **Start Ollama service** (`ollama serve`) and pull the chosen 7B model (`ollama pull llama3.1:8b` or `ollama pull deepseek-r1:7b`) before running the 7B evaluation.
4. **Run on full benchmark** (all 727 records) for all tiers. Do not subsample — the benchmark is small enough for full evaluation.
5. **Run symbolic input for all models first**, then NL-paraphrase input for frontier models only (Claude and GPT-4o). The 7B model can be evaluated on symbolic only to conserve time.
6. **Checkpoint progress**: Save results incrementally to JSONL files to allow resume on failure.
7. **Publish results** in `data/baselines/README.md` with: methodology section, per-model per-tier accuracy table, random baseline comparison, CoT vs direct delta table, NL vs symbolic delta table, and depth correlation table.

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Anthropic API key not set as `ANTHROPIC_API_KEY` | Medium | Check env; ANTHROPIC_DEFAULT_OPUS_MODEL var suggests Claude access exists; may need to extract API key from Claude Code configuration |
| Ollama not installed or 7B model too large for RAM | Medium | Fall back to GPT-4o-mini (cheap) as the "small model" baseline instead of local 7B |
| Rate limit errors from OpenAI | Low | Use exponential backoff and 1-2 second delays between requests |
| NL paraphrase quality issues for depth-3+ formulas | Low | Report accuracy separately for `rule_based` vs `rule_based_complex` subsets |
| LLM refusals on logic classification | Very low | Logic classification is benign; refusals unlikely |
| Cost overrun | Low | 727 records × 4 modes × 2 frontier models ≈ $18 total — acceptable |
| Parse failure (no "valid"/"invalid" in response) | Medium | Enforce strict output format in system prompt; report parse_error_rate |

---

## Context Extension Recommendations

- **Topic**: LLM evaluation methodology for formal logic benchmarks
- **Gap**: No existing context file documents how to structure API-based LLM evaluation scripts, output formats, or per-tier reporting conventions for this project.
- **Recommendation**: After implementation, create `docs/research/llm-baseline-methodology.md` documenting the evaluation approach, prompt templates, and results interpretation conventions for reproducibility.

---

## Appendix

### A. Record Schema (complete, 14 fields in bmlogic-bench.jsonl v1.1)

```
id, split, formula_str, formula_ast, frame_class, label, proof_trace,
countermodel, pattern_key, metrics, benchmark_category, source,
difficulty_tier, nl_paraphrase, nl_paraphrase_method
```

### B. Key File Paths

| File | Purpose |
|------|---------|
| `data/bmlogic-bench.jsonl` | Primary evaluation input (727 records) |
| `data/bmlogic-bench_metadata.json` | Statistics and augmentation provenance |
| `data/bmlogic-bench-splits.json` | Cross-logic split membership |
| `data/scripts/prompt_template.txt` | Existing NL paraphrase LLM prompt (reference) |
| `data/baselines/` | Target directory (to be created) |
| `data/scripts/run_baseline_eval.py` | Target evaluation script (to be implemented) |

### C. Search Queries Used

- "LLM evaluation formal logic provability classification zero-shot chain-of-thought 2025"
- "GPT-4o Claude Sonnet evaluation modal logic temporal logic accuracy benchmark 2025"
- "LTLBench LLM evaluation temporal logic accuracy results open source models 2024 2025"
- "lm-evaluation-harness custom task JSONL binary classification prompt template 2025"
- "OpenAI API GPT-4o zero-shot chain of thought prompting formal reasoning accuracy 2025"
- "Ollama local LLM API evaluation 7B model Llama Mistral binary classification accuracy benchmark"
- "open source 7B model formal logic reasoning accuracy Llama-3 Mistral Qwen evaluation results 2025"
- "LLM provability theorem proving classification prompt design valid invalid binary output parsing 2024"

### D. References

- LTLBench paper: https://arxiv.org/abs/2407.05434
- "Can Large Language Models Learn Formal Logic?": https://arxiv.org/pdf/2504.20213
- EleutherAI lm-evaluation-harness: https://github.com/EleutherAI/lm-evaluation-harness
- Anthropic Models API: https://platform.claude.com/docs/en/about-claude/models/overview
- Ollama library: https://ollama.com/library
- OpenAI Python SDK: https://github.com/openai/openai-python
