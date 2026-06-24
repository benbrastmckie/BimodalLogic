# v35 Phase 0 — Decision Gate: Route A vs Route B (COMMITTED)

- **Task**: 305 (rabinovich_ea_formula_implementation, lean4)
- **Plan**: plans/35_zone-split-gated.md
- **Date**: 2026-06-24
- **Phase**: 0 (decision gate, read-only spike — no `.lean` edits)

## DECISION: **Route A (fix-in-place bounded 3-way zone-split)**

Per the plan's explicit decision criterion (lines 186-191): "Choose Route B (re-anchor) iff G1
yields a *type-checkable* bridge-lemma signature whose only obligations are at depth 0 or reuse
`US_expressively_complete_over_Z` directly (no depth-(k+1) construction obligation). Otherwise
choose Route A. Tie / ambiguity defaults to Route A."

G1 yields **no** such depth-0-only bridge (it is in fact circular — see below). Therefore the
criterion selects **Route A**. This is not a tie/default; G1 is a decisive NO.

## Spike Evidence (verifiable, ground truth)

### Baseline state (confirmed before any work)
- `lake build` → **GREEN** ("Build completed successfully (1700 jobs)").
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` →
  axioms `["propext","sorryAx","Classical.choice","Lean.ofReduceBool","Lean.trustCompiler","Quot.sound"]`.
  So `completeness_discrete` currently depends on **`sorryAx`** (NOT yet sorry-free).
- The "2 axioms" baseline = the two *acceptable, non-sorry* project axioms beyond standard Lean
  (`propext`, `Classical.choice`, `Quot.sound`): namely **`Lean.ofReduceBool` + `Lean.trustCompiler`**
  (from `native_decide` in the Syntax layer; documented at Completeness.lean:368-369). There are
  **zero top-level `axiom` declarations** in the build path (`grep '^axiom ' Theories/` excluding
  Boneyard → empty). The genuine blocker is the single `sorryAx`.
- Live code sorries on the build path that feed `completeness_discrete`: **KampPrior.lean:391 (n=1,
  critical) and :394 (n>=2, off-path)** — confirmed below. (CaseAnalysis.lean:3376/3383 sorries are
  on the compiled path via Theorem6 but are NOT in the `completeness_discrete` cone — `lean_verify`
  reports only one `sorryAx` source and the audit comment Completeness.lean:355-358 traces it solely
  through the KampPrior chain.)

### Live sorry chain (audit comment Completeness.lean:355-358, confirmed by reading the code)
```
completeness_discrete
  → countermodel_discrete_reynolds_v2
  → ... → no_gaps_discrete_model_surgery        (GoodStructuresModelSurgery.lean)
  → US_expressively_complete_over_prior          (PriorExpressiveness.lean:346)
  → kamp_prior_expressive_completeness           (KampPrior.lean:520)
  → nf_characterizable_temporal_prior (k+1 arm)  (KampPrior.lean:437, uses ONLY arity n=1)
  → nf_nvar_exist_all_depths ... k 1             (KampPrior.lean:252, k+1/n=1 arm)
  → **sorry at KampPrior.lean:391**
```

### G1 — Re-anchor viability (Route B): **NO type-checkable depth-0 bridge; circular.**

The two expressive-completeness results are over **fundamentally different structure types**:

| | `US_expressively_complete_over_Z` (Theorem.lean:357, **sorry-free**, re-anchor target) | `US_expressively_complete_over_prior` (PriorExpressiveness.lean:346, **live consumer**) |
|---|---|---|
| Structure | `IntStructureFromSig sig` (concrete `Int` time, QuantifierElimination.lean:39) | arbitrary `OrderedMonadicStructure sig` |
| Time type | `Int` | `M.carrier` (arbitrary) |
| atomMap | `sig.preds → Atom` (specific `Atom.mk_fresh "p" …`) | `Formula → sig.preds` (arbitrary surjective `h_surj`) |
| Truth pred | `Separation.int_truth` (Separation/Defs.lean:42, over `IntStructure`) | `temporal_truth` (over `OrderedMonadicStructure`) |
| Hypotheses | none (separation theorem) | `semantic_prior_UZ` / `semantic_prior_SZ` |

The **live call site** (`invariant_formula_constant` inside `no_gaps_discrete_model_surgery`,
GoodStructuresModelSurgery.lean:1266-1269) invokes
`US_expressively_complete_over_prior atomMap h_surj φ` on an **arbitrary working structure
`M : OrderedMonadicStructure sig`** with `h_prior_UZ`/`h_prior_SZ` and immediately consumes
`temporal_truth M atomMap t T_φ`. It does **not** have a concrete `Int` model in hand.

To route through `US_expressively_complete_over_Z` we would need a bridge lemma of shape:
```
(arbitrary M : OrderedMonadicStructure sig, semantic_prior_UZ/SZ, temporal_truth)
   ⟶  (IntStructureFromSig sig, Int time, Separation.int_truth, atomMap : preds→Atom)
```
This is **not** a depth-0 obligation. It requires:
1. Transferring an arbitrary Prior-structure `M` to a concrete `Int` model — which is *exactly the
   content of* `no_gaps_discrete_model_surgery` (the consumer we are trying to bypass). **Circular.**
2. Reconciling two distinct truth predicates (`temporal_truth` vs `Separation.int_truth`) and two
   distinct atomMap codomains; **no existing bridging lemma** connects them
   (`grep "US_expressively_complete_over_Z"` → only self-references in its own docstring; there is no
   lemma linking it to `OrderedMonadicStructure`/`temporal_truth`).

**Verdict: G1 = non-viable.** This *upholds* report 24's "non-viable (HIGH)" verdict; Teammate C's
F2 evidence does not overcome the structure-type gap (the bridge it imagines presupposes the very
model-surgery it would replace). **Overturned premise: NONE** — the gate confirms the prior verdict
rather than overturning it.

### G2 — Hypothesis faithfulness: `semantic_prior_UZ` "first occurrence" is **adequate** for the discrete target.

- `semantic_prior_UZ` is the `abbrev` at PriorDefs.lean:22, taken as a hypothesis throughout the
  Prior chain.
- `prior_UZ_first_transition` (GoodStructuresModelSurgery.lean:116) is **already proved sorry-free**
  and is the lemma the live surgery uses for "first occurrence": from `semantic_prior_UZ` +
  `SuccOrder`/`PredOrder` it delivers a first-transition point `c` with
  `temporal_truth c ψ ∧ ¬ temporal_truth (succ c) ψ`. The discrete target (`SuccOrder`/`PredOrder`
  carrier) consumes this directly.
- `HasAttainedINF`/infimum machinery (PriorINF.lean) exists but is **not required** on the live
  discrete path. So no reformulation to infimum adequacy (Prop 4.2) is needed.
- **Verdict: G2 = `semantic_prior_UZ` is honestly adequate.** No change to the hypothesis shape.

### Bonus finding (settles Phase 4 gating in advance)
`nf_nvar_exist_all_depths` is consumed **only** at **arity n=1** — via `nf_characterizable_temporal_prior`
(KampPrior.lean:469, `nf_nvar_exist_all_depths_fn atomMap h_surj k 1`) and via its own internal
recursion `ih_exist_1` (KampPrior.lean:313, also `k 1`). No live consumer ever requests n>=2.
Therefore **KampPrior.lean:394 (n+2 arm) is genuinely off the live path** of `completeness_discrete`.
Phase 4 should be **verification-only** (confirm dead, leave documented off-path sorry), per the
plan's Phase 4 gating.

## H6 Refutation Ledger
- Overturns no prior premise. **Confirms** report 24's Route-B "non-viable" verdict with concrete
  structure-type + circularity evidence.
- The Approach-5 pair-formula / mutual char-exist / k+2 NF-disjunction remain **FORBIDDEN** (H6
  guardrail 2). This gate does not reopen them.

## Committed consequence (H6 guardrail 1)
From here, **Route A is the single live route.** Route B is closed; reopening requires a new gate
with written justification overturning the circularity evidence above.

## Verification (Phase 0 exit)
- `lake build`: GREEN (1700 jobs) — unchanged, no `.lean` edits in this phase.
- Baseline preserved: KampPrior.lean:391/394 sorries present; single `sorryAx` in
  `completeness_discrete`; acceptable axioms `Lean.ofReduceBool`/`Lean.trustCompiler` unchanged.
- This handoff names exactly one route (A) and states the decision-criterion outcome (G1 = no
  depth-0 bridge) and overturned premise (none).
