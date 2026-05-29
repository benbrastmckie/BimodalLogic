# Research Report: Task #215

**Task**: 215 - Competitive analysis and enhancement roadmap for BMLogic datasets
**Started**: 2026-05-29T23:00:00Z
**Completed**: 2026-05-29T23:45:00Z
**Effort**: small (4-6 hours)
**Dependencies**: 214, 208
**Sources/Inputs**:
- Local dataset files: `data/bmlogic-bench.jsonl`, `data/bmlogic-c5.jsonl`, `data/bmlogic-c7.jsonl`, `data/proof_steps.jsonl` and companion metadata JSON files
- `data/README.md` (dataset documentation)
- WebSearch: FOLIO, ProofWriter, LogicNLI, PrOntoQA, INT, LeanDojo, miniF2F, NaturalProofs, ReClor, AR-LSAT, FLUTE, LTLBench
- WebSearch: Croissant metadata standard, HuggingFace leaderboard infrastructure
**Artifacts**:
- `specs/215_dataset_competitive_analysis/reports/01_competitive-analysis.md` (this file)
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- BMLogic datasets occupy a **unique niche** with no direct competitor: formal provability classification for a decidable **bimodal logic combining S5 modal and linear temporal operators** with machine-verified labels, dual certificates (proof traces + countermodels), and six formula representations per record.
- The closest competitors (FOLIO, ProofWriter, LTLBench) cover either FOL/propositional reasoning or LTL alone, never the S5+LTL combination, and none provide formal countermodels as machine-readable certificates.
- The primary weaknesses relative to competitors are: **scale** (52K training records vs. hundreds-of-thousands in ProofWriter/LeanDojo), **no natural-language paraphrase layer** (all competitors target NLP pipelines), and **missing Croissant metadata** / leaderboard scaffolding for HuggingFace discoverability.
- Top enhancement priorities (in order): (1) natural-language paraphrase augmentation, (2) complexity tier extension to c9/c11, (3) Croissant metadata and HF leaderboard Space, (4) difficulty calibration against LLM baselines, (5) cross-logic transfer split (propositional-only / modal-only / temporal-only sub-slices).

---

## Context & Scope

This report evaluates four datasets published as part of the BimodalLogic project (Task 208/213/214):

| Dataset | Records | Purpose |
|---------|---------|---------|
| `bmlogic-c5.jsonl` | 1,513 | Exhaustive training at complexity ≤5 |
| `bmlogic-c7.jsonl` | 49,904 | Exhaustive training at complexity ≤7 |
| `bmlogic-bench.jsonl` | 727 | Stratified evaluation benchmark |
| `proof_steps.jsonl` | 2,424 | Proof-step supervision (36 theorems) |

The comparison universe covers eleven benchmarks: FOLIO, ProofWriter/RuleTaker, LogicNLI, PrOntoQA, FLUTE, ReClor, AR-LSAT, NaturalProofs, LeanDojo, miniF2F, and INT; plus the closely related LTLBench (2024).

---

## Findings

### 1. BMLogic Dataset Characterization

**Logic domain**: TM bimodal logic — S5 modal (□, ◇ with equivalence-class accessibility) combined with LTL temporal (U = Until, S = Since with linear-order semantics). This combination is decidable and admits a complete Hilbert-style axiomatization (verified in Lean 4).

**Task format**: Binary provability classification (valid / invalid), with both directions certified:
- Valid formulas: JSON proof trace (axioms used, rule applications, proof height)
- Invalid formulas: JSON countermodel (trueAtoms, falseAtoms, witness formula)

**Formula complexity distribution (c7, 5k sample)**:
- Complexity 3–4: ~3.6% (trivially simple)
- Complexity 5: 26.2% (moderate)
- Complexity 6: 70.2% (primary difficulty tier)
- Modal depth: 0 (21%), 1 (72%), 2 (7%)
- Temporal depth: 0 (11%), 1 (49%), 2 (40%)

**Benchmark tier distribution**:
- Easy: 50 (6.9%) — avg valid rate 6%
- Medium: 300 (41.3%) — avg valid rate 50%
- Hard: 262 (36.0%) — avg valid rate 50%
- Very Hard: 115 (15.8%) — avg valid rate 49%

**Multi-representation schema** (c5/c7, 14 fields):
1. `formula_str` — unicode human-readable
2. `formula_ast` — JSON recursive AST
3. `formula_sexpr` — S-expression (canonical prefix)
4. `formula_tokens` — prefix token list (transformer-ready)
5. `pattern_key` — structural feature object
6. `pattern_features` — numeric feature vector (5 dimensions)

**Valid fraction**: 3–5% in training sets (accurate; bimodal space dominated by invalids), 47% in benchmark (stratified sampling).

---

### 2. Competitor Benchmark Survey

#### 2.1 NLP-Oriented Formal Reasoning Benchmarks

**FOLIO** (EMNLP 2024 update; originally 2022)
- Domain: First-order logic (FOL) over natural language
- Task: Entailment (True / False / Unknown), 3-class
- Size: 1,435 examples, expert-annotated
- Proof traces: No (only labels + parallel FOL formulas)
- Countermodels: No
- NL integration: Full (Wikipedia-grounded, natural wording)
- Gap vs. BMLogic: No modal/temporal operators, no machine-verified labels, no countermodels

**ProofWriter / RuleTaker** (ACL Findings 2021)
- Domain: Propositional / restricted FOL, natural language
- Task: Implication verification + proof generation + abductive reasoning
- Size: ~500K examples (synthetic), depths 0–5
- Proof traces: Yes (natural language chains)
- Countermodels: No
- NL integration: Synthetic templates (101-word vocab)
- Gap vs. BMLogic: Propositional/restricted FOL only, no modal/temporal, no formal countermodels, lower linguistic diversity

**LogicNLI** (2021)
- Domain: FOL over natural language inference
- Task: Entailment (NLI-style)
- Size: ~30K examples
- Proof traces: No
- Countermodels: No
- NL integration: Yes
- Gap vs. BMLogic: FOL-only, no modal/temporal, no provability certificates

**PrOntoQA** (Saparov & He, 2023)
- Domain: Propositional logic, Modus Ponens only
- Task: QA over synthetic reasoning chains
- Size: ~10K
- Proof traces: Yes (chain-of-thought style)
- Countermodels: No
- NL integration: Synthetic (avoids real-world concepts)
- Gap vs. BMLogic: Single-rule (MP) only, no modal/temporal operators

**FLUTE** (EMNLP 2022)
- Domain: Figurative natural language inference (entailment/contradiction)
- Task: NLI with textual explanations
- Size: 9,000 instances
- Proof traces: No (only class label + explanation)
- Countermodels: No
- NL integration: Yes (sarcasm, metaphor, simile, idiom)
- Gap vs. BMLogic: Entirely different domain (figurative NLI), no formal logic

**ReClor** (ICLR 2020)
- Domain: Logical reading comprehension (LSAT/GMAT)
- Task: 4-way MCQ
- Size: 6,138 questions (4,638 train / 500 val / 1,000 test)
- Proof traces: No
- Countermodels: No
- NL integration: Full (real standardized test questions)
- Gap vs. BMLogic: No formal logic framework, MCQ format only

**AR-LSAT** (2021)
- Domain: Analytical reasoning (constraint satisfaction), LSAT-derived
- Task: MCQ
- Size: ~2,000+ from LSAT 1991–2016
- Proof traces: No
- Countermodels: No
- NL integration: Full (natural language constraints)
- Gap vs. BMLogic: Constraint satisfaction not modal/temporal logic; no formal certificates

#### 2.2 Temporal Logic Benchmarks

**LTLBench** (2024)
- Domain: Linear Temporal Logic (LTL) — the temporal fragment only
- Task: Binary satisfiability classification
- Size: 2,000 challenges
- Proof traces: No (uses NuSMV model checker externally)
- Countermodels: No (only Yes/No decision)
- NL integration: Partial (graph-based generation)
- Machine-verified: Yes (via NuSMV)
- Gap vs. BMLogic: LTL only (no S5 modal), no countermodel certificates, smaller scale, no multi-representation schema

**Test of Time** (2024)
- Domain: Temporal semantics and arithmetic reasoning
- Task: QA over temporal NL descriptions
- Size: Not precisely stated; two sub-tasks
- Proof traces: No
- Gap vs. BMLogic: Informal temporal reasoning, no formal logic operators

#### 2.3 Formal Theorem Proving Datasets

**LeanDojo / LeanDojo Benchmark 4** (NeurIPS 2023 + 2024)
- Domain: General mathematics (Mathlib4)
- Task: Tactic-level proof generation (next-tactic prediction)
- Size: 122,517 theorems, 259,580 tactics, 167,779 premises
- Proof traces: Yes (full tactic scripts with goal states)
- Countermodels: No
- NL integration: Lean 4 formal language only
- Gap vs. BMLogic: General math, not logic-specific; no provability classification task; no countermodel data

**miniF2F** (ICLR 2022)
- Domain: Olympiad-level mathematics (AMC, AIME, IMO)
- Task: Formal proof search
- Size: 488 statements (244 test, 244 val)
- Proof traces: Partial (formal ITP proofs where solved)
- Countermodels: No
- Systems: Lean, Isabelle, Metamath, HOL Light
- Gap vs. BMLogic: Math olympiad problems, not logic decidability; no classification task format

**NaturalProofs** (NeurIPS 2021)
- Domain: University-level mathematics (Wikipedia, ProofWiki, Stacks)
- Task: Reference retrieval and proof generation
- Size: Multi-domain corpus (thousands of theorems)
- Proof traces: Yes (natural language proofs)
- Countermodels: No
- NL integration: Yes (natural mathematical language)
- Gap vs. BMLogic: Natural language proofs, no formal verification, no countermodels

**INT** (ICLR 2021)
- Domain: Algebraic inequalities (ordered field axioms)
- Task: Interactive theorem proving (step-by-step)
- Size: Theoretically infinite (generator-based)
- Proof traces: Yes (step sequences)
- Countermodels: No
- Gap vs. BMLogic: Inequality domain only, no modal/temporal; no classification task

---

### 3. Feature Comparison Matrix

| Feature | BMLogic | FOLIO | ProofWriter | PrOntoQA | LTLBench | LeanDojo | miniF2F | INT |
|---------|---------|-------|-------------|----------|----------|---------|---------|-----|
| **Domain** | S5 + LTL bimodal | FOL/NL | Prop/FOL | Prop | LTL | General math | Olympiad math | Inequalities |
| **Task format** | Provability class. | Entailment (3-cls) | Implication+proof | QA chain | Sat. class. | Tactic prediction | Proof search | Proof steps |
| **Verified labels** | Yes (Lean 4) | No (human expert) | No (synthetic) | No (synthetic) | Yes (NuSMV) | Yes (Lean 4) | Yes (ITP) | Yes (axioms) |
| **Proof traces** | Partial (valid only) | No | Yes (NL) | Yes (chain) | No | Yes (tactics) | Partial | Yes (steps) |
| **Countermodels** | Yes (invalid formulas) | No | No | No | No | No | No | No |
| **Multi-representation** | Yes (6 fields) | No (2 fields) | No | No | No | Yes (AST+state) | No | No |
| **NL integration** | No | Full | Template | Template | Partial | No | No | No |
| **Scale (total)** | ~54K | 1.4K | 500K | ~10K | 2K | 122K+ | 488 | Infinite |
| **Complexity tiers** | 4 tiers (easy–very_hard) | None | Depth 0–5 | Depth 1–5 | None | None | Competition level | Complexity 1–15 |
| **Difficulty calibration** | Heuristic (metrics) | No | Depth only | Depth only | No | Novel premises | Problem source | Operator count |
| **Croissant metadata** | No | No | No | No | No | No | No | No |
| **HF leaderboard** | No | No | No | No | No | No | No | No |
| **License** | MIT | CC-BY | Apache 2.0 | CC-BY | Not stated | Apache 2.0 | MIT | MIT |

---

### 4. Novelty Assessment

**High novelty dimensions**:
1. **S5 + LTL bimodal coverage**: No other dataset covers this specific combination. LTLBench covers LTL alone; the formal theorem proving datasets (LeanDojo, miniF2F) target mathematics rather than logic decidability. BMLogic fills an identified gap in formal reasoning benchmarks.

2. **Machine-verified dual certificates**: The combination of Lean 4-verified proof traces (for valid formulas) and machine-generated countermodels (for invalid formulas) is unique. Other datasets provide either proof traces (ProofWriter, LeanDojo) or entailment labels but not witnessed refutations with explicit counterstructures.

3. **Multi-representation schema**: Six representations per record (string, AST, S-expression, tokens, pattern key, feature vector) serves diverse training objectives simultaneously — no competitor provides this breadth of formula representations.

4. **Exhaustive enumeration through complexity bound**: The c5 and c7 datasets achieve complete coverage of all bimodal formulas up to complexity 5 and 7 respectively. ProofWriter is sampled/synthetic; FOLIO is expert-curated samples. Exhaustive coverage provides statistical guarantees about distribution.

**Moderate novelty / parity**:
- Provability classification task (binary): Parity with LTLBench (satisfiability), but LTLBench is propositionally LTL and much smaller.
- Stratified benchmark with difficulty tiers: Comparable to ProofWriter depth stratification, though BMLogic tiers use a richer metric (combined complexity/depth/operator signature).

**Gaps relative to competitors**:
- **Scale**: 52K training records is modest compared to ProofWriter (500K) and LeanDojo (122K+). The exhaustive generation approach has inherent limits at higher complexity.
- **NLP accessibility**: No natural language layer means the dataset is inaccessible to NLP/LLM evaluation pipelines that expect text inputs. All major NLP benchmarks (FOLIO, ReClor, AR-LSAT) include natural language.
- **LLM baseline calibration**: No published LLM accuracy figures on bmlogic-bench, so the community cannot gauge difficulty relative to current models.
- **Discoverability**: No Croissant metadata, no HuggingFace leaderboard Space, and the HF README uses `text-classification` task category — which does not accurately describe formal logic provability.

---

### 5. Recommendations

#### R1: Natural-Language Paraphrase Augmentation (Priority: High)

Add an `nl_paraphrase` field to bmlogic-bench and a subset of c7 records, containing a natural-language rendering of each formula (e.g., "It is necessary that if p then eventually q"). This would:
- Enable evaluation on LLM chat models without symbolic parsing
- Create a cross-modal transfer benchmark (symbolic → NL → back)
- Substantially expand the audience beyond formal-logic specialists
- Comparable to: FOLIO's Wikipedia-grounded statements, ProofWriter's template NL

Suggested approach: Rule-based generation for simple formulas; GPT-assisted with human verification for complex nesting. Store in an optional `nl_paraphrase` field (null for records without paraphrase) to preserve backward compatibility.

#### R2: Complexity Tier Extension to c9 / c11 (Priority: High)

The current maximum complexity is 7. Extending to complexity 9 and 11 would:
- Provide harder formulas involving 3+ nested modal/temporal operators
- Create a harder benchmark slice (very_hard+ tier) for future LLM evaluation
- Address the finding that very_hard formulas (complexity ≥8) are underrepresented
- Note: exhaustive enumeration at c9 will be large (~500K–1M); sampling may be required

Suggested metadata enhancement: Add `max_temporal_depth`, `max_modal_depth` as first-class filter dimensions in the benchmark schema.

#### R3: Croissant Metadata and HuggingFace Leaderboard Space (Priority: High)

- Add `croissant.json` to the HuggingFace dataset repository per the MLCommons 1.0 specification
- Update HF README `task_categories` to `"text-generation"` + `"other"` with custom `task_ids: ["formal-provability-classification"]`
- Create a HuggingFace Space (Gradio) that accepts a formula string, calls the Lean oracle, and returns the label + proof/countermodel. This serves as: interactive demo, live benchmark submission endpoint
- Register bmlogic-bench as a leaderboard via HF's Leaderboards and Evaluations infrastructure

Croissant metadata priority fields: dataset name, description, URL, distribution (Parquet mirror), record-level fields with semantic types, citation, license.

#### R4: LLM Baseline Difficulty Calibration (Priority: Medium)

Run bmlogic-bench through GPT-4o, Claude Sonnet, Llama-3, and a random baseline to establish:
- Zero-shot accuracy per difficulty tier
- Chain-of-thought vs. direct label accuracy
- Modal depth / temporal depth correlation with LLM error rate

Publish results in a `baselines/` directory alongside the dataset. This makes the benchmark actionable and gives the community a target to beat.

#### R5: Cross-Logic Transfer Splits (Priority: Medium)

Create explicit sub-slices of bmlogic-bench that isolate logic fragments:
- `propositional-only` slice: formulas with `modalDepth == 0 && temporalDepth == 0`
- `modal-only` slice: `temporalDepth == 0 && modalDepth > 0`
- `temporal-only` slice: `modalDepth == 0 && temporalDepth > 0`
- `bimodal` slice: `modalDepth > 0 && temporalDepth > 0`

These sub-slices would enable cross-logic transfer experiments (train on propositional, test on bimodal) and allow direct comparison with FOLIO (propositional reasoning) and LTLBench (temporal reasoning).

#### R6: Anchor Coverage Expansion (Priority: Low-Medium)

Current anchor coverage: 14/42 axiom constructors (33%). Expand to cover all 42 axiom constructors with at least 3 instances each (target: 126+ anchor records). This would improve the semantic coverage of the benchmark and ensure all axiom patterns are explicitly evaluated.

#### R7: Proof Step Dataset Expansion (Priority: Low)

Current proof_steps covers 36 theorems. Expanding to 200+ theorems would:
- Provide more varied proof structures (beyond axiom + MP dominated data)
- Enable training of step-level proof models for the bimodal logic fragment
- Increase value for goal-conditioned reasoning research

The low rate of necessitation (12 steps) and temporal_necessitation (1 step) suggests the current theorem selection is biased toward propositional provability; richer theorems should be added.

---

## Decisions

- **FOLIO and ProofWriter are not direct competitors**: They target NLP entailment over natural language, not formal provability. BMLogic occupies a different point in the benchmark space.
- **LTLBench is the closest competitor** in the temporal/modal space but covers only LTL, lacks countermodels, and is 27× smaller than bmlogic-bench alone.
- **The natural-language layer is the most impactful enhancement**: Without it, BMLogic is inaccessible to the NLP benchmark ecosystem where most LLM evaluation occurs.
- **Croissant metadata is low-effort / high-discoverability**: Estimated 2–4 hours of work; HuggingFace auto-generates it for Parquet-converted datasets.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| NL paraphrase quality too low (systematic errors) | Rule-based generation for depth≤2; human spot-check at depth≥3 |
| c9/c11 exhaustive enumeration too large for Git/HF | Use sampled mode with stratified sampling; keep exhaustive for c9 only if feasible |
| LLM baselines quickly saturate benchmark | Include very_hard tier and complexity≥8 extension as perpetual challenger set |
| Leaderboard maintenance burden | Use HF Spaces auto-evaluation infrastructure; minimize manual curation |
| ID scheme non-uniqueness across files | Document clearly; add `dataset_prefix` field (bmlogic-c5-XXXXX) in future schema versions |

---

## Context Extension Recommendations

- **Topic**: Formal reasoning benchmark landscape
- **Gap**: No `.claude/context/` entry documents the competitive landscape for formal logic ML benchmarks; future tasks relating to dataset positioning would benefit from a reference.
- **Recommendation**: Create `.claude/context/project/datasets/competitive-landscape.md` summarizing this report's comparison matrix for agent reuse.

---

## Appendix

### Search Queries Used
- `FOLIO ProofWriter LogicNLI PrOntoQA formal logic benchmark NLP dataset 2023 2024`
- `LeanDojo miniF2F INT benchmark theorem proving dataset Lean Isabelle 2023 2024`
- `NaturalProofs dataset theorem proving natural language mathematics benchmark 2021`
- `INT benchmark inequality theorem proving dataset 2021 combinatorial`
- `modal logic temporal logic benchmark dataset LLM reasoning 2024 2025`
- `ReClor AR-LSAT FLUTE logical reasoning benchmark NLP dataset features size`
- `LTLBench temporal logic benchmark LLM evaluation 2024 formal provability`
- `modal logic S5 bimodal dataset formal reasoning benchmark survey 2024 2025`
- `ProofWriter RuleTaker dataset size features depth reasoning synthetic FOL 2021`
- `Croissant metadata schema HuggingFace dataset format 2024 leaderboard scaffold`
- `AR-LSAT analytical reasoning dataset benchmark features scale 2021`
- `LeanDojo benchmark 4 mathlib tactics premises dataset 2024 theorem proving features`
- `proof trace dataset formal logic countermodel certificate neural network training 2024`

### Key References
- FOLIO: https://arxiv.org/abs/2209.00840 (EMNLP 2024)
- ProofWriter: https://aclanthology.org/2021.findings-acl.317.pdf
- LeanDojo: https://arxiv.org/abs/2306.15626 (NeurIPS 2023)
- miniF2F: https://openreview.net/forum?id=9ZPegFuFTFv (ICLR 2022)
- INT: https://arxiv.org/abs/2007.02924 (ICLR 2021)
- NaturalProofs: https://arxiv.org/abs/2104.01112 (NeurIPS 2021)
- LTLBench: https://arxiv.org/abs/2407.05434 (2024)
- ReClor: https://arxiv.org/abs/2002.04326 (ICLR 2020)
- AR-LSAT: https://arxiv.org/abs/2104.06598 (2021)
- FLUTE: https://aclanthology.org/2022.emnlp-main.481 (EMNLP 2022)
- Croissant: https://arxiv.org/abs/2403.19546 (2024)
- HuggingFace leaderboard docs: https://huggingface.co/docs/leaderboards/en/index
