# Teammate C (Critic) Findings: Task #226

**Task**: Build standalone Z3 countermodel generator for negative training signal
**Date**: 2026-05-30
**Focus**: Critical gaps, unvalidated assumptions, and soundness risks

## Key Findings

### 1. CRITICAL: Existing Countermodels Are Atom-Only — Z3 Would Produce a Different Species

The current training data (`data/bmlogic-bench.jsonl`) has 376/387 invalid formulas with countermodels, but these are exclusively `SimpleCountermodel` with keys `{trueAtoms, falseAtoms, formula}`. They record ONLY which propositional atoms are true/false — no world histories, no task relations, no temporal structure.

A Z3 countermodel (with finite worlds, time steps, task relations) would produce a fundamentally different object. **The task description conflates two different things**:
- "Negative training signal" (the formula is invalid) — this already EXISTS for 376 formulas
- "Structured countermodel" (a full semantic witness) — this does NOT exist anywhere

**Question the task must answer**: Is the goal (a) to produce *richer* countermodels for formulas already known to be invalid, or (b) to determine invalidity for *new* formulas not yet classified? The existing system already knows which formulas are invalid via the Lean tableau.

### 2. CRITICAL: WorldHistory Has Structural Constraints That Massively Complicate Z3 Encoding

From `WorldHistory.lean:69-97`, a WorldHistory requires:
- **Convex domain**: `∀ x z, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y`
- **respects_task**: `∀ s t (hs : domain s) (ht : domain t), s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)`

The convexity constraint means you cannot have a history that exists at times 1 and 3 but not 2. In Z3, if you're modeling a bounded time domain `{0, 1, ..., M-1}`, this is naturally satisfied (the full interval is convex). But the `respects_task` constraint means:

**Every pair of time points in a history must satisfy the task relation with the appropriate duration.** This is not just frame axioms on the frame — it's a constraint on EACH history independently.

For N worlds and M time steps with K histories for the box quantifier, you need K × M × M constraints just from `respects_task`. The ~800-1200 LOC estimate from prior research probably underestimates this.

### 3. CRITICAL: Box Quantifies Over Omega (Shift-Closed), Not Just "All Histories"

From `Truth.lean:127`: `| Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ`

From `Truth.lean:295`: `ShiftClosed Omega := ∀ σ ∈ Omega, ∀ (Δ : D), WorldHistory.time_shift σ Δ ∈ Omega`

This means Omega must be **closed under time-shift**. For a finite Z3 model, you need to enumerate a set of histories that is shift-closed. With bounded time domain {0,...,M-1}, time-shifting a history by Δ changes its domain — so shift-closure in a bounded setting is non-trivial.

**Soundness implication**: If the Z3 model uses K histories but those K histories are not shift-closed, the box semantics may be wrong. A countermodel found under a non-shift-closed set might not be a valid countermodel in the Lean sense.

**Mitigation**: Use `Omega = Set.univ` (all histories over the finite frame), which is trivially shift-closed. But then box quantifies over ALL possible histories on N worlds × M times — which is `N^M` histories. For N=2, M=3 that's 8 histories. For N=3, M=4 that's 81. This combinatorial explosion IS the performance problem.

### 4. Atoms-Outside-Domain Semantics Creates a Subtlety for Bounded Models

From `Truth.lean:124`: `| Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`

Atoms are FALSE at times outside the history's domain. In a bounded Z3 model where all histories have domain `{0,...,M-1}`, this issue vanishes (all times are in domain). But if you model partial histories (to capture the full semantics), atoms become three-valued: true, false, or "outside domain."

For soundness, the simplest approach is: all histories have the same full domain `{0,...,M-1}`. This is sound (it's a valid special case of the general semantics) but means you cannot find countermodels that require histories with different domains.

### 5. Forward_Comp Is Satisfiable in Bounded Models — But Only Under Non-Trivial Conditions

`TaskFrame.lean:114`: `forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v`

With M time steps (durations {0,...,M-1}), `x + y` might exceed M-1. Options:
- Model durations as unbounded integers (Z3 handles this) but then there exist durations with no corresponding time points
- Model durations modulo M (violates the linear order structure)
- **Accept that forward_comp holds vacuously for x + y > M-1** because there's no time (t + x + y) in the bounded time domain to test against

This last option is the correct approach for soundness: forward_comp only matters for times actually present in histories. Since all histories have domain {0,...,M-1}, if s + x + y > M-1, the triple (w at s, u at s+x, v at s+x+y) cannot all exist in one history, so forward_comp's antecedent is never satisfied for that case. **This is sound but means bounded models might miss some countermodels.**

### 6. The 800-1200 LOC Estimate Is Plausible But Only for Base Frame Without Full History Enumeration

If the implementation:
- Uses bounded integer time {0,...,M-1}
- Models N concrete world states as bitvectors or enums
- Gives ALL histories the full domain {0,...,M-1}
- Enumerates all possible histories (N^M of them) for box
- Uses `Omega = Set.univ` (all histories)

Then the encoding is:
- Frame axioms (nullity_identity, forward_comp, converse): ~100 lines
- History array declarations (state at each time for each history): ~50 lines
- respects_task for each history: ~50 lines
- Formula encoding (recursive, 6 cases): ~200 lines
- Model extraction: ~150 lines
- Formula JSON parsing: ~100 lines
- Orchestration/CLI: ~150-200 lines

**Total: ~800-1000 lines** — plausible. BUT: if N=2, M=2, you have 4 histories × box requires quantifying over all 4. At N=3, M=3 you have 27 histories. The Z3 encoding blows up in constraint count, not line count.

### 7. The "Metalogic Soundness Proof" Is Far-Fetched for This Phase

The task mentions "metalogic to establish at least the soundness of the Z3 implementation." This would require:
- Formalizing in Lean what the Z3 encoding DOES (a model of the Python code's semantics)
- Proving that any satisfying assignment to the Z3 variables constitutes a valid `TaskFrame + TaskModel + WorldHistory + truth_at` triple that falsifies the formula

This is essentially a verified compiler/encoder proof. While conceptually achievable, it's a separate multi-hundred-line formalization effort in Lean, and would need to be updated every time the Z3 encoding changes. **This should be a follow-up task, not part of initial implementation.**

A more practical soundness validation: run the Z3 oracle on all 387 known-invalid formulas, verify its countermodels match the Lean tableau's classification. Cross-validation, not formal verification.

### 8. Training Data Integration Gap

The existing `data/bmlogic-bench.jsonl` already has countermodels (SimpleCountermodel) for 376/387 invalid formulas. The `scripts/generate_dataset.py` converts this to PyTorch tensors using only PatternKey features (5 dimensions: modalDepth, temporalDepth, impCount, complexity, topOperator).

A Z3 structured countermodel would need a new tensor encoding — graph-based (GNN) or sequence-based (world state sequences). This is downstream work (like BimodalHarness task 20) but should inform the countermodel schema design NOW so the output format is consumable.

### 9. No pyproject.toml Exists — Python Infrastructure Is Ad-Hoc Scripts

The existing Python files in `scripts/` are standalone scripts with no package management. Adding Z3 (which requires `z3-solver` pip package) means either:
- Adding a `pyproject.toml` and proper package structure
- Keeping it as standalone scripts with a `requirements.txt`
- Using nix to manage the Z3 dependency

Since this is primarily a Lean repo, the lightweight approach (scripts + requirements.txt) probably fits better than a full Python package. But the Z3 oracle will be complex enough to benefit from a proper package with tests.

## Recommended Approach (Mitigation Strategies)

1. **Start with the simplest sound encoding**: N worlds, M time steps, full-domain histories, `Omega = Set.univ` (enumerate all N^M histories). This is sound by construction.

2. **Accept incompleteness explicitly**: The finite-bounded encoding cannot find all countermodels (those requiring larger N or M). Start with N=2, M=2, escalate to N=3, M=3 on timeout.

3. **Cross-validate against existing data**: Run on the 387 known-invalid formulas. The oracle should find countermodels for a large fraction (not all — some may require larger bounds).

4. **Defer formal soundness proof**: Use empirical cross-validation first. A formal soundness proof in Lean is a separate task worth flagging.

5. **Design the output schema to be richer than SimpleCountermodel**: Include world states, time assignments, task relation edges, and the evaluation point. This enables downstream GNN encoding.

6. **Use scripts/ directory with requirements.txt**: Don't over-engineer the Python packaging for a Lean-primary repo.

## Evidence/Examples

| Finding | Source File | Line(s) |
|---------|-------------|---------|
| Atom domain check | `Theories/Bimodal/Semantics/Truth.lean` | 124 |
| Box over Omega | `Theories/Bimodal/Semantics/Truth.lean` | 127 |
| ShiftClosed def | `Theories/Bimodal/Semantics/Truth.lean` | 295 |
| WorldHistory convexity | `Theories/Bimodal/Semantics/WorldHistory.lean` | 81 |
| WorldHistory respects_task | `Theories/Bimodal/Semantics/WorldHistory.lean` | 96-97 |
| Forward_comp axiom | `Theories/Bimodal/Semantics/TaskFrame.lean` | 114 |
| SimpleCountermodel (atom-only) | `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` | 47-54 |
| Formula.toJson schema | `Theories/Bimodal/Automation/DataExport.lean` | 96-116 |
| Existing training data | `data/bmlogic-bench.jsonl` | 387 invalid, 376 with countermodels |
| FiniteTaskFrame | `Theories/Bimodal/Semantics/TaskFrame.lean` | 284-287 |

## Confidence Level

**High** — These are direct observations from the Lean source code. The semantic constraints (convexity, respects_task, ShiftClosed) are structural requirements that any sound Z3 encoding must satisfy or explicitly restrict. The LOC estimate and integration concerns are medium-confidence judgments.
