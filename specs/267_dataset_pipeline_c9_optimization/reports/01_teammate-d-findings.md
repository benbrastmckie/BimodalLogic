# Teammate D: Horizons — Strategic Direction
# Task 267: Dataset Pipeline C9 Optimization

**Role**: Strategic/Horizons Researcher  
**Date**: 2026-06-02  
**Focus**: Long-term alignment, dataset quality vs. quantity, research artifact value

---

## Key Findings

### 1. Strategic Alignment: Dataset Pipeline vs. Core Roadmap

The project's primary stated goal is the **BX Completeness and Publication** roadmap. The ROADMAP.md identifies a very specific critical path:

```
Task 155 (EF-game infrastructure) 
  → Task 202 (Reynolds k-equivalence bypass) 
  → sorry-free completeness_discrete
  → Post-completeness structural refactor
  → Publication
```

**The dataset pipeline is NOT on this critical path.** Dataset generation is an ML training infrastructure concern (for BimodalHarness / bmlogic-bench) that runs in parallel with — but does not block — the core completeness proof work.

This matters for prioritization: if developer attention is limited, spending cycles on c9 exhaustive generation must be weighed against the cost to tasks 155 and 202. That said, dataset generation is already largely automated and generates research value independently. The strategic question is not "should we do it" but "what should we optimize for."

### 2. Dataset Size vs. Dataset Quality

The current pipeline produces exhaustive enumeration within fixed structural bounds (3 atoms, modal depth 2, temporal depth 2, complexity up to N). The resulting datasets are complete within these bounds but are not curated for research utility.

**Key quality observation**: The c8 dataset contains 252,900 records with 19,721 timeouts (7.8%) and 487 wall-clock timeouts. Of the valid records:
- Many are provably valid via the structural pre-filter (vacuous implication patterns, double-box, bot-temporal antecedents)
- The `InterestingnessMetrics` system already classifies these as "trivial" (SNT=0, score=0)

**The interestingness infrastructure is underutilized.** The existing 7-tier scoring system (trivial through remarkable) is computed for every record, but datasets are not filtered or weighted by this score. A quality-filtered dataset of 10,000 "interesting" formulas (tier >= moderate, i.e., score >= 300) may be more valuable for ML training than 1.6M exhaustive c9 records of variable quality.

Concretely, the interestingness score captures:
- **Operator diversity**: whether both modal and temporal operators appear
- **Proof depth ratio**: non-trivial proof structure
- **Axiom layer diversity**: cross-layer reasoning (propositional + modal + temporal + interaction)
- **Interaction axiom dependency**: whether `modal_future` is used (genuine bimodal reasoning)

Formulas scoring high on all dimensions are exactly the ones that stress-test bimodal reasoning. A curriculum that starts with "basic" formulas and progresses to "remarkable" ones would be more effective than uniform random sampling from c9.

### 3. Multi-Frame-Class Datasets: Overlooked High-Value Item

The `FrameClass` type has three variants:
- `Base` — all strict linear orders (current pipeline default)
- `Dense` — densely ordered (Q-like frames)
- `Discrete` — discretely ordered (Z-like frames)

**All current datasets use only `Base`.** The `labelFormula` function already accepts a `fc : FrameClass` parameter (default `.Base`), so the infrastructure to generate Dense and Discrete datasets already exists.

Why does this matter strategically?

1. **Different validity distributions**: A formula valid over Base may be invalid over Dense (e.g., density-specific axioms like `GGp → Gp` distinguish these classes). A Dense or Discrete dataset would contain different valid/invalid labels for many of the same formulas, creating a richer training signal.

2. **Frame class identification as a task**: An ML model trained on multi-frame-class data could learn to predict not just validity, but which frame class(es) a formula is valid over — a more semantically deep capability.

3. **Research artifact value**: A benchmark covering three frame classes would be distinctive in the ML-for-formal-reasoning space. Most benchmarks cover a single logical system.

4. **c8 is already feasible**: The c8 dataset was generated in ~2 hours total (with wall-clock timeout handling). Generating Dense and Discrete c8 datasets adds 2 additional runs of similar cost. This is low-effort for significant diversity.

**Recommendation**: Before investing in c9 exhaustive generation (1.6M formulas, 5-10 hours), generate Dense and Discrete variants of c7 or c8. This diversifies the dataset along the most semantically meaningful axis of the logic at lower computational cost.

### 4. bmlogic-bench as a Publishable Research Artifact

The project already has significant publication infrastructure:
- A Croissant 1.0 metadata file (`data/croissant.json`)
- A dataset card (`data/hf-dataset/README.md`) for HuggingFace
- Natural language paraphrases for the bmlogic-bench evaluation set (task accomplished per data/README.md)
- Cross-logic transfer splits (`bmlogic-bench-splits.json`)

**What makes ML benchmarks high-impact** (from GLUE, SuperGLUE, BIG-Bench):

| Feature | Current State | Gap |
|---------|--------------|-----|
| Clear task definition | Good (validity + frame class) | Could add proof step prediction |
| Multiple splits (train/dev/test) | Partial (bmlogic-bench-splits.json) | Official c9 test split needed |
| Difficulty tiers / curriculum | Computed but not enforced | Interestingness-stratified splits |
| Baseline results | Missing | Need at least one LLM baseline |
| Leaderboard / evaluation server | Missing | HF evaluation endpoint |
| Accompanying paper | Missing | Critical for community adoption |

The most significant gap is the **absence of a companion paper or technical report**. Without a citable reference, the dataset will have limited community uptake even if published on HuggingFace. The BimodalLogic formalization project (BX completeness proof) is itself a strong research contribution — a dataset paper could accompany or follow the completeness publication.

**Concrete recommendation**: Structure the bmlogic-bench paper around the combination of (1) a formally verified decision procedure (the Lean 4 formalization is the ground truth for labels), (2) multi-frame-class labeled data, and (3) the interestingness metric as a difficulty model. This is a unique position in the ML-for-formal-reasoning space.

### 5. Automation Infrastructure: Dataset Factory

The current generation workflow requires manual CLI invocation of `lake exe BimodalDataGen -- --max-complexity 9`. This is adequate for a research prototype but brittle for:

- Reproducible dataset versioning (different researchers may invoke with different parameters)
- Incremental regeneration after decision procedure changes
- Integration with CI/CD to ensure the dataset stays synchronized with the codebase

**What a "dataset factory" would add**:

1. **Declarative configuration**: A `data/config.yaml` specifying the target datasets, their parameters, and their completion status. The factory checks this and generates missing datasets.

2. **Checkpoint/resume by default**: The c8 generation already uses checkpointing (`.checkpoint.partial` files), but this is ad hoc. A factory would make checkpointing a first-class feature.

3. **Automatic HF upload**: After successful generation and validation, the factory could invoke `data/hf-dataset/upload.py` to publish. The HF infrastructure is already in place (task 257 confirmed the upload pipeline exists).

4. **Dataset drift detection**: When the decision procedure changes (e.g., after fuel strategy optimization), the factory could detect that cached datasets are stale and trigger regeneration.

The HuggingFace integration (task 257) specifically noted that the upload pipeline is already written and only requires an access token. A dataset factory would complete this loop. **This is a relatively small engineering task with significant operational value.**

---

## Strategic Recommendations

### Priority 1 (High impact, low cost): Generate Dense and Discrete Frame Class Datasets

Generate Dense and Discrete variants of the c7 dataset. Each is a ~30-second run using the existing infrastructure (c7 = 42,416 formulas, c7 Dense/Discrete will have different validity distributions). This diversifies the dataset along the most semantically meaningful axis without touching c9.

Implementation: Invoke `labelFormula` with `fc := .Dense` and `fc := .Discrete` in the `labelBatch` call chain. The generator already supports this via the `--frame-class` CLI flag mentioned in `DatasetGenerator.lean`'s module docstring (task 261 v3).

### Priority 2 (Medium impact, medium cost): Interestingness-Stratified Dataset Slices

Create curated dataset slices filtered by interestingness tier:
- A "hard formulas" slice: interestingness tier >= "interesting" (score >= 700)
- A "bimodal interaction" slice: SNT=3 (genuine bimodal) AND interaction_axiom_dep=true
- A curriculum slice: one representative formula per tier per complexity level

These slices can be derived from existing data without any new generation. They would make bmlogic-bench more useful for ML training (curriculum learning, hard example mining) and more distinctive as a research artifact.

### Priority 3 (Medium impact, high cost): C9 Exhaustive Generation

C9 generation is estimated at 1.59M formulas with ~5-10 hours of wall-clock time using the 5-second wall-clock timeout. The bottleneck (temporal-to-temporal-box feedback patterns) has been characterized but not eliminated.

**Before investing in exhaustive c9**, the team should ask: does the ML use case actually need 1.6M formulas, or would 100K well-chosen formulas from c9 suffice? If the answer is "well-chosen formulas," then stratified c9 sampling (already piloted in `bmlogic-c9-sample.jsonl`) is more efficient and should replace exhaustive c9 as the goal.

If exhaustive c9 is genuinely needed, the remaining bottleneck is the "temporal-to-temporal(box)" pattern class that creates exponentially branching tableaux. This requires either: (a) a new structural pre-filter that identifies these patterns as valid/invalid without running the tableau, or (b) a faster proof procedure for this specific pattern class. This is a harder engineering problem than the bot-temporal pre-filter implemented in task 265.

### Priority 4 (Low impact currently, high strategic value): Dataset Factory + HF Integration

Build the declarative dataset factory as described above. This is most valuable if the project intends to publish bmlogic-bench and maintain it over time. The HF upload pipeline exists; the factory closes the loop.

---

## Creative and Unconventional Ideas

### Idea A: "Anti-dataset" — Hard Negatives from the Decision Procedure

The 19,721 timeouts in c8 are currently labeled "timeout" and are of limited ML training value (the model can't learn from "we don't know"). But these are exactly the formulas the decision procedure finds hardest — they are hard for both the prover and, potentially, for an ML model.

**Proposal**: Use the interestingness metrics on the timeout formulas to identify which ones are structurally interesting (high SNT, high OD, interaction axiom would be needed). Then invest specifically in resolving these formulas by hand or with enhanced proof search. A dataset where the hard cases are labeled (even if it takes more computation) is more valuable than one where the hard cases are absent.

Alternatively: label timeout formulas with "unknown" and train a model to predict whether a formula is valid, invalid, or undecidable-by-this-procedure. This is a harder task but more scientifically interesting.

### Idea B: Proof Step Dataset Focused on Cross-Modal Interaction

The `proof_steps.jsonl` dataset (10,063 records) is already generated, but it covers all proof steps uniformly. The most scientifically interesting proof steps for bimodal reasoning are those that use the `modal_future` axiom (the unique cross-modal interaction axiom in TM).

**Proposal**: Generate a targeted "interaction-heavy" proof step dataset by:
1. Filtering existing formulas for those with `interaction_axiom_dep=true`
2. Running the proof step extractor specifically on these formulas
3. Creating a "bimodal bridge" dataset focused on the modal-temporal interaction

This is a small targeted dataset (probably 1,000-5,000 formulas) but captures the unique scientific contribution of TM — the combination of S5 and temporal logic.

### Idea C: EF-Game Dataset from the Completeness Proof Infrastructure

Task 155 built EF-game (Ehrenfeucht-Fraisse game) expressiveness infrastructure for the Reynolds k-equivalence bypass. EF games are themselves interesting objects: given two structures, the EF game characterizes whether they satisfy the same formulas up to quantifier depth k.

**Proposal**: Generate a dataset of EF-game instances from the infrastructure built in task 155. Each record would be: (structure 1, structure 2, k, label: k-equivalent or not). This is a completely different kind of dataset — not formula classification but structure comparison — and could be a separate research artifact.

This is speculative and would require significant new code, but it leverages the expensive completeness proof infrastructure in a new way.

### Idea D: Continuous Dataset Improvement via "Proof Gap Closing" Feedback Loop

Currently, formulas that timeout are labeled "timeout" and forgotten. But each timeout represents a gap in the proof procedure — a formula the procedure cannot handle. These gaps have a structure (the characterization from tasks 264-266 shows they cluster into pattern classes).

**Proposal**: Create a feedback loop:
1. Generate a dataset; identify timeout patterns
2. Implement structural rules to handle new patterns (like the bot-temporal pre-filter in task 265)
3. Regenerate with the improved procedure; the timeout rate drops
4. Repeat

This is already happening implicitly across tasks 264-266, but making it explicit as a "continuous improvement" process would give it a structure and goal: reduce the timeout rate to <1% at c9.

---

## Confidence Assessment

| Finding | Confidence | Basis |
|---------|------------|-------|
| Dataset pipeline not on completeness critical path | HIGH | ROADMAP.md critical path is explicit and unambiguous |
| Interestingness metrics underutilized | HIGH | Data confirms all datasets generated without interestingness filtering |
| Dense/Discrete datasets absent but feasible | HIGH | FrameClass type exists, `labelFormula` parameter exists, infrastructure confirmed |
| Publication gap without companion paper | HIGH | Standard ML benchmark practice; no paper cited in data/ |
| C9 exhaustive = 5-10 hours, ~1.6M formulas | HIGH | Confirmed by c8 scaling data and formula count estimates |
| Dataset factory would close HF upload loop | MEDIUM | HF upload pipeline exists (task 257 confirmed); factory design is straightforward |
| EF-game dataset is feasible | LOW | Speculative; requires new code and task 155 infrastructure in working state |
| Hard-negative timeout labeling is valuable | MEDIUM | Good idea in principle; depends on whether ML use case needs it |

---

## Summary for Synthesis

**The core tension in task 267**: The project asks "how do we generate more c9 formulas faster?" but the strategic question is "what dataset would be most valuable?"

The answers diverge. More c9 formulas exhaustively are expensive and provide diminishing returns in semantic diversity (same Base frame class, similar formula structure). Less but better-curated data — filtered by interestingness tier, covering Dense and Discrete frame classes, paired with a companion paper — would have substantially higher research impact.

**Recommended focus shift**: c9 generation should target quality over completeness. A 100K-record stratified c9 sample, combined with Dense/Discrete c7 datasets and interestingness-stratified slices from the existing c8 dataset, provides a richer training and benchmark resource than exhaustive c9 alone.

The wall-clock timeout infrastructure from task 266 (5-second limit per formula) is the right approach for exhaustive generation if pursued. The remaining optimization needed is a structural pre-filter for the "temporal-to-temporal(box)" pattern class (the bottleneck identified in task 266). This should be the focus of any further decision procedure optimization, not fuel strategy changes.
