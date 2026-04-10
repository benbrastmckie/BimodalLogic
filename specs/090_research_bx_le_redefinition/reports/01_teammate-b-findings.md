# Teammate B Findings — Option B Deep Dive (Henkin Enrichment)

**Task**: 90 — Decide between Option A (redefine bx_le via Until-witnesses) and Option B
(Henkin-closure enrichment) for closing 4 Until/Since truth-lemma sorries in Frame.lean
**Role**: Teammate B — Alternative Approach Analyzer
**Date**: 2026-04-10
**Focus**: Option B deep dive

---

## Burgess 1984 Henkin Witness Pattern (1-2 paragraphs)

In "Basic Tense Logic" (1984, appearing in Gabbay and Guenthner's *Handbook of Philosophical
Logic*), Burgess proves completeness for Until/Since on various linear orders using a step-by-step
chain construction. The key technique for handling Until-eventualities is a "Henkin witness"
enrichment applied during the Lindenbaum extension: rather than extending an arbitrary consistent
set to a maximal consistent set by a simple Zorn-based chain, the construction interleaves the
Lindenbaum extension with the injection of Until-witnesses. Concretely, given a formula `φ U ψ`
in a consistent set S, Burgess adds a fresh propositional letter (or a suitable formula) acting
as a "witness variable" that encodes the eventual truth of ψ. The final MCS is required to be
not merely maximal consistent but also "Until-saturated": for every `φ U ψ ∈ M`, there exists
a chain-successor `M'` with `ψ ∈ M'` and `φ ∈ M_i` for all chain positions between `M` and
`M'`. This enrichment happens at the construction level — the Lindenbaum lemma is replaced by
a richer "Henkin-Lindenbaum" lemma producing Until-saturated MCS rather than plain MCS.

The result is that the canonical model's accessibility relation can still be defined as
`g_content(M) ⊆ M'` (the standard MCS ordering), but NOW every `φ U ψ ∈ M` has a concrete
witness already built into the chain by construction. The four sorries in `Frame.lean` are
precisely the places where the plain Lindenbaum approach fails to deliver witnesses: the
standard `set_lindenbaum` produces an MCS that is maximally consistent but NOT Until-saturated.
Option B proposes replacing or enriching the Lindenbaum construction so that every MCS emerging
from the construction is already saturated with Until-witnesses — making `bx_le` (still defined
via g_content) sufficient to close the four sorries without redefinition.

---

## Concrete Application to This Codebase (file, lemma, construction)

### Current Architecture

The relevant chain of constructions is:

1. **`set_lindenbaum`** in `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` (line ~291):
   Zorn-based extension of any consistent set to a `SetMaximalConsistent` set. Plain MCS — no
   Until-saturation property.

2. **`forward_temporal_witness_seed_consistent`** in `Bundle/WitnessSeed.lean` (line ~81):
   Given `F(ψ) ∈ M`, the seed `{ψ} ∪ g_content(M)` is consistent. This is the existing
   F-witness construction — successfully used in `bx_forward_witness` in `Frame.lean` (line 164).

3. **`bx_forward_witness`** in `Frame.lean` (line 164): Works because F(ψ) → F-seed consistency
   → `set_lindenbaum` → BXPoint. No Until-saturation needed because F is an existential operator
   with a one-step witness.

4. **`bx_until_eventuality_resolution`** in `Frame.lean` (line 632): **SORRY**. This needs a
   BXPoint `v ≥ w` with `ψ ∈ v` AND for ALL intermediate `u` with `w ≤ u < v`, `φ ∈ u`. The
   single-step witness from `bx_forward_witness` does not supply the guard condition. Until-
   saturation of the constructed witness MCS would need to guarantee this.

### What Option B Means Concretely

Option B = replace `set_lindenbaum` with a richer `set_lindenbaum_until_saturated` that:
- Takes an input consistent set S (possibly containing `φ U ψ` formulas)
- Produces an MCS M ⊇ S that is "Until-saturated": for every `φ U ψ ∈ M`, there exists a
  concrete chain member `M'` with `ψ ∈ M'` and guard `φ` on the interval.

OR, more architecturally: augment the `BXPoint`-level `bx_forward_witness` / `bx_G_backward`
construction with an additional Until-witness enrichment step that, after extending to an MCS,
further extends the chain to inject Until-witnesses.

**Key file**: `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`
**Key lemma to add or replace**: `set_lindenbaum_until_sat` — a richer Lindenbaum that produces
Until-saturated MCS
**Alternative site**: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — add a
`bx_until_chain_construction` that uses iterative Lindenbaum extension for each Until formula

---

## How the 4 Sorries Close Without Redefining bx_le

Under Option B, the hope is that the 4 sorries close as follows:

### Sorry 1: `bx_until_eventuality_resolution` (line 632)

**Target**: Given `φ U ψ ∈ w`, `ψ ∉ w`, find `v ≥ w` (in bx_le) with `ψ ∈ v` and guard `φ`
on `[w, v)`.

**Option B mechanism**: Build a Burgess-style forward chain from `w`:
1. Starting from `w.formulas`, note `F(ψ) ∈ w` (by BX10: `φ U ψ → F(ψ)`).
2. At each step of the chain, if the current MCS `M_i` contains `φ U ψ`, either `ψ ∈ M_i`
   (done) or extend via `g_content(M_i) ∪ {φ U ψ}` seed using BX5/BX6 to propagate Until.
3. By BX10 + fair scheduling, the chain eventually reaches `M_k` with `ψ ∈ M_k`.
4. All intermediate `M_i` (for `i < k`) satisfy `φ ∈ M_i` because `φ U ψ ∈ M_i` (guard) and
   BX9 (`φ U ψ → φ ∨ ψ`) gives `φ ∈ M_i` since `ψ ∉ M_i`.

**Critical gap**: The chain positions form a Nat-indexed (not a "BXPoint with bx_le") family.
The guard condition in `bx_until_eventuality_resolution` is stated over ALL BXPoints `u` with
`bx_le w u` and `bx_le u v ∧ ¬bx_le v u`. This is a **universal quantifier over all BXPoints**,
not just chain members. Option B can only deliver the guard for the specific chain it constructs
— it does NOT deliver the guard for arbitrary BXPoints between `w` and `v` in the bx_le ordering.

**Verdict**: Option B partially addresses the forward direction but CANNOT close the universal
guard quantifier `∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas` without
bx_le being total/linear. The sorries in `Frame.lean` have the guard stated over arbitrary
BXPoints. This means:

- IF the signature of `bx_until_eventuality_resolution` is weakened to only quantify over chain
  members (not all BXPoints), Option B becomes viable.
- IF the signature remains as stated (universal guard over all BXPoints), Option B cannot close
  this sorry without either (a) proving bx_le totality (which requires `temp_linearity`), or
  (b) redefining bx_le (which is Option A).

### Sorry 2: `bx_until_backward` (line 664)

**Target**: Given `v ≥ w`, `ψ ∈ v`, guard `φ` on `[w, v)`, derive `φ U ψ ∈ w`.

**Option B mechanism**: BX4 (connectedness: `φ → G(P(φ))`). If `¬(φ U ψ) ∈ w`, by BX4 we get
`G(P(¬(φ U ψ))) ∈ w`, hence `P(¬(φ U ψ)) ∈ v` (since `bx_le w v`). From `bx_backward_witness`,
find `u ≤ v` with `¬(φ U ψ) ∈ u`. Then from `ψ ∈ v` + BX8 (`ψ → φ U ψ`), contradiction at `v`.
But we need `w ≤ u` to apply the guard — same linearity blocker as before.

**Verdict**: Same issue. Option B does not help here without bx_le totality.

### Sorries 3 and 4: `bx_since_eventuality_resolution`, `bx_since_backward` (lines 683, 697)

Mirror of Sorries 1 and 2 in the past direction. Same blocker.

---

## Prior Art in Repo (Dovetailed/Ultrafilter/FMCS parallels)

### DovetailedChain.lean (DEPRECATED)
`Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`

This module IS a Henkin-enrichment attempt — it builds a dovetailed omega chain that
"fair-schedules" resolution of F-obligations. It has the same architectural goal as Option B.
The module is **deprecated** because all 6 of its sorries stem from the X-vs-G mismatch
(line 42-48 of the file):

> "All 6 sorries in this module stem from a single architectural mismatch: Lindenbaum seeds
> provide **bot-Until-level** consistency, but Until persistence through chain steps requires
> **g_content-level** propagation."

This is directly relevant: the DovetailedChain already tried the Henkin enrichment strategy
at the FMCS/chain level and failed for the same mathematical reason Option B faces at the
BXCanonical level.

### UltrafilterChain.lean
`Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

Works with ultrafilters of the Lindenbaum algebra. Provides `R_G` (g_content-based temporal
relation) and `R_Box` (modal relation). The construction handles modal witnesses well but does
NOT address Until-saturation — the `UltrafilterChain` structure has no Until-coherence properties.

### UntilSinceCoherence.lean
`Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean`

This module is the closest prior art to Option B. It provides:
- `backward_until_reflexive`: The trivial case `ψ ∈ M → φ U ψ ∈ M`
- `backward_until_from_step`: Parameterized backward Until for FMCS over Int, given a
  step-transfer hypothesis

The step-transfer hypothesis `h_step` is exactly the Henkin-enrichment property: it says
"if `φ U ψ ∈ fam.mcs (r+1)` and `φ ∈ fam.mcs r`, then `φ U ψ ∈ fam.mcs r`." This is the
"pull-back" property that Henkin-enriched chains must satisfy. The module already has the
inductive machinery — it just needs a chain construction that provides `h_step`. No such
chain construction exists in the codebase.

### SuccRelation.lean / SuccChainFMCS.lean
`Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`

The `Succ` relation has an `f_content` step condition: F-obligations either resolve or defer.
This is an F-level Henkin enrichment but does NOT handle `φ U ψ` differently from `F(φ)`.
The `f_nesting_is_bounded` issue (documented in SuccChainFMCS.lean, task 55) further blocks
using Succ for Until-enrichment.

### Summary of Prior Art

| Construction | Henkin-enriched? | Until-saturated? | Status |
|--------------|-----------------|------------------|--------|
| `set_lindenbaum` | No | No | Working |
| `forward_temporal_witness_seed` | F-only | No | Working |
| `DovetailedChain` | F-only (bot-Until) | No | Deprecated (X-vs-G blocked) |
| `SuccChainFMCS` | F-only | No | Deprecated (nesting) |
| `UntilSinceCoherence` (parameterized) | Step-param | Yes (if h_step provided) | Working infrastructure |
| `UltrafilterChain` | No | No | Working |

No existing construction provides full Until-saturation. The `UntilSinceCoherence` parameterized
theorems are reusable once a chain with the step property exists.

---

## Impact on Existing Box-Direction Proof (should be unchanged)

The Box-direction proof (`bx_modal_witness`, `bx_modal_equiv_of_bx_le`,
`box_preserved_along_bx_le`) is entirely based on:
- `bx_le w v` (g_content subset relation) — unchanged
- S5 axioms (`modal_4`, `modal_5_collapse`, `modal_b`, `modal_t`) — unchanged
- `g_content_closed_derivation` — unchanged

Under Option B, `bx_le` is NOT redefined. The Lindenbaum construction change is additive
(produces a richer MCS, which is still an MCS). The Box proof does not depend on the Until-
saturation property, so **the Box-direction proof survives completely unchanged** under Option B.

This is the one clear advantage of Option B over Option A: the modal equivalence infrastructure
(`bx_modal_equiv`, `bx_modal_equiv_refl/symm/trans`, `box_preserved_along_bx_le`) remains
intact without reproofs.

---

## Impact on TaskModel Embedding (Completeness.lean:154)

`BXCanonical/Completeness.lean` line 154 has a sorry for the canonical TaskModel construction.
This sorry depends on multiple things beyond the 4 Frame.lean sorries:

1. Embedding BXPoints into a `TaskFrame` (requires defining the frame structure)
2. G/H truth lemma cases requiring non-constant histories visiting multiple BXPoints
3. The 4 Until/Since eventuality resolution lemmas (Frame.lean sorries)

Under Option B, the 4 Until/Since sorries would only close if Option B succeeds. However,
Option B's fundamental limitation (it cannot close the universal-guard quantifier without
bx_le totality) means the 4 Frame.lean sorries likely remain open under pure Option B
(without `temp_linearity`). Therefore:

**Option B alone does NOT help close Completeness.lean:154.**

If `temp_linearity` is added (recommended by task 88 and task 89 research), Option B becomes
irrelevant because bx_le totality makes the direct canonical approach (Option A or a straight
proof) tractable. Under `temp_linearity`:
- bx_le is a total linear order
- The canonical BXPoint set forms a linear order of MCS
- Until-witnesses follow the ordering directly
- No Henkin enrichment needed

---

## Complexity Estimate (lines of Lean, hours)

### Optimistic estimate (if signature is weakened to chain-only guard)

Option B requires:
1. A "Until-saturated Lindenbaum" lemma or a Burgess-style chain construction over omega steps:
   approximately 300-500 lines of Lean
2. Proving step-transfer property for the constructed chain: ~100 lines
3. Connecting the chain-based witnesses to BXPoint witnesses: ~100 lines
4. Connecting to `UntilSinceCoherence.backward_until_from_step` infrastructure: ~50 lines

**Total**: ~550-750 lines, estimated **15-25 hours** (optimistic, assuming signature weakening
is acceptable)

### Pessimistic estimate (universal guard as stated in Frame.lean)

If the `bx_until_eventuality_resolution` signature stays as written (guard over ALL BXPoints),
Option B cannot close the sorry without bx_le totality. This makes Option B infeasible at
**0% confidence** for the exact signatures in `Frame.lean` lines 632-637 and 664-668.

The universal guard `∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas`
requires establishing that between ANY two chain-related BXPoints, ALL intermediate BXPoints
satisfy the guard. This is a statement about the GLOBAL BXPoint ordering, not just the
specific chain being constructed.

**Total for pessimistic path**: Infeasible (40-80 hours, and ultimately not closeable as stated)

---

## Confidence Level: low

Option B as classically described (Henkin-enrich the MCS closure) is **infeasible** for the
exact signatures in `Frame.lean` without either:
1. `temp_linearity` (which makes Option B redundant), or
2. Weakening the signatures of the 4 Frame.lean lemmas to chain-indexed rather than
   BXPoint-universal, which would also require changing `TruthLemma.lean` and the overall
   proof architecture.

The core problem: Burgess 1984's Henkin enrichment works for CHAIN-based canonical models
(Int-indexed or omega-indexed MCS chains). The BXCanonical approach uses a SET-based model
(all MCS simultaneously) with a partial ordering. Henkin enrichment is well-suited for chain
models but poorly suited for set-models with partial orderings, because the universal guard
quantifier requires knowing that ALL BXPoints in an interval satisfy the guard — and an
enriched-seed construction only produces a single chain, not all possible BXPoints.

The prior attempt (DovetailedChain.lean) is direct evidence that Henkin enrichment at the
chain level fails for this codebase (6 sorries, deprecated). DovetailedChain.lean tried
exactly the same strategy at the FMCS/Bundle level.

**Confidence: low (20% that Option B can close sorries as stated; 0% without signature
changes or `temp_linearity`)**

---

## Recommended: Option B? No

**Option B is NOT recommended.** Here is the justification:

### Why Option B Fails

1. **Universal guard blocker**: The 4 Frame.lean sorries have universal quantification over
   ALL BXPoints, not just chain members. Henkin enrichment produces a specific chain with the
   saturation property, but this does not extend to arbitrary BXPoints. Without bx_le totality
   (which requires `temp_linearity`), the guard condition cannot be proved.

2. **DovetailedChain precedent**: The DovetailedChain.lean module already attempted the
   Henkin-enrichment strategy at the Bundle/FMCS level and failed for the same reason: the
   X-vs-G mismatch. The same mismatch occurs at the BXCanonical level.

3. **bx_le is left unchanged but the problem isn't bx_le**: The root cause is NOT that bx_le
   is the wrong ordering. The root cause is that the BXPoint universe (all MCS) with bx_le
   is not a linear order. Option B does not address this.

4. **Complexity without payoff**: Option B would require 300-750 lines of new Lean infrastructure
   (the Henkin-Lindenbaum construction) that duplicates existing failed attempts in DovetailedChain
   and SuccChainFMCS, for a proof that is either infeasible (as stated) or requires signature
   changes that break TruthLemma.lean.

### What Is Actually Recommended

Based on the prior task 89 synthesis (90% confidence) and this analysis:

**Priority 1 (2-4h)**: Re-add `temp_linearity` axiom. This makes bx_le a total linear order,
which directly unblocks all 4 sorries via standard canonical model techniques. Both Option A
and the direct guard proof become straightforward under total bx_le. Option B becomes unnecessary.

**Priority 2 (8-16h, WITH temp_linearity)**: Close the 4 sorries directly using the total bx_le
ordering — NO Henkin enrichment needed, NO redefinition of bx_le needed.

**Option A assessment**: If `temp_linearity` is not re-added, Option A (redefine bx_le via
Until-witnesses) has the same linearity problem: Until-witnesses only order Until-formula witnesses,
not ALL formulas. Without `temp_linearity`, Option A has the same 15% confidence as reported in
task 89 research.

**The fundamental conclusion**: BOTH Option A and Option B are workarounds for a missing axiom.
Re-adding `temp_linearity` (mathematically correct, semantically valid, 2-4h effort) makes both
options unnecessary.
