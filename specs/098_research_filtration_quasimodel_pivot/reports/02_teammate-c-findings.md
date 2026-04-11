# Teammate C Findings: Critical Analysis of bx_le Non-Totality Claim

- **Task**: 98 — Research filtration or quasimodel pivot for Until/Since truth lemma
- **Teammate**: C (Critic)
- **Role**: Critically examine the "genuine mathematical gap" claim
- **Date**: 2026-04-10
- **Artifact**: 02_teammate-c-findings.md

---

## Key Findings

### Finding 1: The "Non-Totality" Claim Is CORRECT but MISDIAGNOSED

The claim that `bx_le` is not a total order is **mathematically correct** — two MCSes can have
incomparable `g_content` sets without any contradiction from BX1-BX12. However, the diagnosis
"non-totality is the gap" is **misdiagnosed** at the level of root cause.

The real root cause is that `bx_le := g_content ⊆` is **the wrong definition** for Until/Since
completeness. It is a good definition for G/H box-modality completeness (it supports
`bx_G_forward` and `bx_H_forward` efficiently) but it is structurally incapable of supporting
the Until truth lemma's guard condition.

**Why this matters**: Previous implementation attempts have been trying to make `g_content ⊆`
work for Until by finding auxiliary lemmas (totality, BX7 exploitation, locus control). This
is the wrong approach — it is trying to fix the definition's deficiency with lemmas rather than
recognising the definition was never designed to support Until guards.

### Finding 2: Standard Canonical Models for Until/Since Do NOT Use G-Content Inclusion

In the standard literature (Burgess 1982/1984, Xu 1988, Venema 1993, Reynolds 1996), the
canonical model ordering for Until/Since completeness is **not** defined as `g_content ⊆`. The
standard approaches use one of:

(a) **Type-based ordering**: A total pre-order on MCSes where `w ≤ v` is defined via explicit
    Until-witness types — essentially, `v` is a successor of `w` if the Until formulas in `w`
    propagate appropriately to `v` according to a defect-discharge relation. This relation is
    defined to be total by construction (using a Koenig/Lindenbaum argument that explicitly
    builds the chain to be linear).

(b) **Quasimodel ordering**: The ordering is defined on Hintikka sets (finite subformula-closed
    structures) with an explicit one-step relation that incorporates Until-discharge as a
    primitive condition. The canonical ordering is total by the construction of the quasimodel
    chain (built inductively with defect-count as termination measure).

(c) **Omega-sequence "Henkin" construction**: The canonical model is a specific omega-sequence
    of MCSes (a thread) where each thread is built to be linearly ordered by construction, and
    the Until truth lemma is proved along each thread separately.

What Burgess 1984 and Goldblatt 1992 (cited in `Frame.lean:33`) **actually** prove is:
completeness by constructing a model that **is** linear from the outset. The MCS space is NOT
taken as the model as-is; rather, specific maximal paths (linear chains) through the MCS space
are extracted. The `g_content ⊆` relation does not appear as the canonical ordering in these
proofs — it is used as an auxiliary tool for constructing the seeds of new MCSes.

### Finding 3: BX11 Does Not Force g_content-Totality and Was Never Intended To

The docstring in `Realization.lean` correctly notes that BX11 (temporal linearity) is a
formula-level axiom: `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`. This axiom
forces **F-witnesses** to be linearly ordered **as formulas within one MCS**, not as a
relation between distinct MCSes.

BX11 saying "if F(φ) and F(ψ) hold now, the two witnesses are ordered" is a **semantic claim
about the underlying model**, not a proof-theoretic claim about the `bx_le` ordering on the
canonical space. No BX axiom directly produces `bx_le w v ∨ bx_le v w` for arbitrary `w, v`.

There is no axiom in BX1-BX12 of the form `G(φ) ∈ w ∨ G(φ) ∈ v` for arbitrary `φ, w, v`.
Such a claim would be equivalent to saying the canonical space is already a linear order, which
would make the completeness proof trivially easy and would be a wildly strong axiom.

### Finding 4: The Totality Gap Is Real, but Totality Is the Wrong Target

Previous implementation attempts (Phase 0 diagnostic, spawn analysis) correctly identified that
the six sorries all require lifting formulas along `bx_le` that are NOT of form `G(χ)`. They
then tried to derive totality as a missing auxiliary lemma. This is the **wrong target** for
two reasons:

(a) **Totality is not derivable** from BX1-BX12 at the MCS level. A countermodel for totality
    can be constructed: take two atoms p, q, and two MCSes where `G(p) ∈ w, p ∉ v` and
    `G(q) ∈ v, q ∉ w`. BX11 forces the F-witnesses to be ordered *for any specific formula*,
    but does NOT force all MCSes to be comparable. The gap is genuine.

(b) **Even if totality held**, it would not close the sorries as written. The guard proof at
    `Realization.lean:282` needs `φ ∈ u` given `φ ∈ u'` and `bx_le u' u`. This requires
    arbitrary formula propagation along `bx_le`, not just totality. Totality would tell us
    `bx_le u u' ∨ bx_le u' u` but neither direction propagates `φ` — `bx_le u' u` propagates
    only `G(χ)` not `χ`, and `bx_le u u'` goes the wrong direction.

### Finding 5: The Quasimodel Approach Is Not Just an "Escape Hatch" — It Is Canonical

The Teammate A report (01_filtration-quasimodel-pivot.md) recommends the Hintikka-set
quasimodel pivot as the natural approach. This is correct, and from a critical standpoint,
**the quasimodel approach is the standard approach** that the literature (Burgess/Goldblatt/
Reynolds) actually uses. The `g_content ⊆` canonical ordering in `Frame.lean` was a shortcut
that works for G/H but was never developed with Until/Since completeness in mind.

The specific advantage of quasimodel ordering: in a quasimodel chain `h0, h1, ..., hk`, the
ordering is defined to make the chain linear **by construction**. The guard `φ ∈ hi` for
`i < k` is proved by the defect-discharge property, which says: if `φ U ψ ∈ hi` and `ψ ∉ hi`,
then `φ ∈ hi` and `φ U ψ ∈ h(i+1)`. This uses BX9 (`until_elim`) applied locally at each
finite Hintikka point, not the problematic global propagation along `bx_le`.

### Finding 6: What Previous Agents Are Missing — The Shared Blind Spot

Both previous implementation agents share the same blind spot: they treat `bx_le := g_content ⊆`
as **fixed** and try to prove the sorry targets within that framework. The Realization.lean
docstring itself acknowledges four alternatives (Until-induction axiom, goal-weakening,
restructured canonical model, quasimodel filtration) but the implementation code consistently
tries to work around the gap rather than taking option (3) or (4).

The blind spot is **anchoring on the canonical order** rather than questioning it. Both agents
search for:
- New lemmas about `bx_le` (locus control, totality, interval properties)
- New axioms that would force `bx_le` to behave better
- Alternative proof strategies that still rely on `bx_le` for the guard

None of them ask: "should `bx_le` be replaced with a different ordering for this step?"

---

## Root Cause Diagnosis

**Primary cause**: `bx_le := g_content ⊆` is optimised for G/H modalities and is structurally
incapable of supporting Until/Since truth lemmas without additional structure. It is a partial
order on an unconstrained MCS space; Until/Since completeness requires a **total** (linear)
order on the canonical model. This is not a deficiency of the BX axiom system — the axioms
are complete — but a deficiency of the canonical model **definition** used in this formalization.

**Secondary cause**: The four sorry targets as formulated assume `bx_le`'s guard semantics
(`bx_le w u ∧ bx_le u v ∧ ¬bx_le v u → φ ∈ u`) which encode half-open interval membership
using the non-total `bx_le`. Standard completeness proofs for Until do NOT use this guard
formulation because their canonical orderings are total, making the strict interval
`bx_lt u v := bx_le u v ∧ ¬bx_le v u` decidable between any two points.

---

## Recommended Approach

### Recommendation: Local Quasimodel Pivot (Confirms Teammate A's finding)

The correct fix is option (3)/(4) from the `Realization.lean` docstring: **restructure the
canonical model ordering for Until/Since specifically**. The cleanest approach is:

1. **Keep `bx_le := g_content ⊆` for the G/H/Box truth lemmas** — these are already proved
   and correct. Do not touch them.

2. **Prove Until/Since via a separate quasimodel chain construction**. The chain is built at
   the Hintikka point level (already scaffolded in `HintikkaPoint.lean` and `Construction.lean`)
   using the defect-discharge relation (`hintikka_step` in `Construction.lean:44`).

3. **The guard proof in the quasimodel is local**: at each step in the chain, `hintikka_step`
   directly requires `φ ∈ hi` when `φ U ψ ∈ hi` and `ψ ∉ hi` (from `until_elim` / BX9). No
   propagation along a non-total order is needed.

4. **Realization from quasimodel to BXPoints**: use the existing `sigma_signature` projection
   (`HintikkaPoint.lean`) to lift back to the BXPoint level for the truth lemma conclusion.

### What Needs Changing in the Code

The sorry targets in `Realization.lean` (lines 282, 286, 373, 374, 346, 404) cannot be
patched within the current `bx_le` framework. They need to be:
- **Replaced** with versions that use the quasimodel chain construction, OR
- **Bypassed** by proving the truth lemma for Until/Since via a completely separate path that
  does not invoke `until_eventuality_resolution` / `until_backward` as currently formulated.

The existing quasimodel scaffolding in `Construction.lean` is the right foundation. The
missing piece is the **realization lemma**: showing that a quasimodel chain of Hintikka points
can be embedded into a sequence of BXPoints respecting `bx_le`. This requires the
`sigma_signature_consistent` and `sigma_signature_maximal` properties from `HintikkaPoint.lean`,
combined with the defect-discharge guarantee from `quasimodel_chain_exists` (stub in
`Construction.lean:99`).

---

## Evidence and Examples

### Example: Why g_content Propagation Fails for Until (Concrete)

Let `p, q` be atoms, and let `φ := p`, `ψ := q`. Consider MCSes:
- `w`: contains `p U q`, `¬q`, `G(p U q)` (so `G(p U q) ∈ w`, hence `bx_le w v` for any `v`
  with `p U q ∈ v`)
- `u`: some MCS with `bx_le w u` and `bx_le u v`; `p U q` is NOT a G-formula so it need not
  be in `g_content(w)`. Even if `G(p U q) ∈ w`, so `p U q ∈ u`, BX9 gives `p ∨ q ∈ u`.
  But to conclude `p ∈ u` we need `q ∉ u` — this requires that `u` is strictly before `v`
  (where `q ∈ v`), i.e., `¬bx_le v u`. But `bx_le v u` vs `¬bx_le v u` is exactly the
  totality question — two incomparable MCSes can have `q ∈ v` and `bx_le u v` and `bx_le v u`
  simultaneously (since `bx_le` is not antisymmetric either).

This shows the sorry targets are not just "missing lemmas" but are asking for properties
that the `bx_le` framework simply cannot deliver.

### Example: How Quasimodel Avoids the Problem

In the quasimodel approach, the chain `h0, h1, ..., hk` is built so that:
- `hintikka_step h_i h_{i+1}` holds (G-propagation + H-backward + Until-discharge)
- The Until-discharge clause directly says: if `φ U ψ ∈ h_i` and `ψ ∉ h_i`, then
  `φ ∈ h_i` (from the `until_elim` condition in `hintikka_step`).

So `φ ∈ h_i` for `i < k` is proved **at the definition level** of `hintikka_step`, not by
formula propagation. The guard is built into the chain structure, not derived from an ordering.

### Example: Standard Literature Approach (Reynolds 1996)

Reynolds' completeness proof for Until/Since on linear orders works as follows:
1. For a consistent formula `α`, build a "type sequence" — an omega-sequence of MCSes where
   consecutive MCSes satisfy a one-step step relation encoding Until persistence and discharge.
2. The step relation is defined to include: "if `φ U ψ ∈ w_n` and `ψ ∉ w_n`, then
   `φ ∈ w_n` and `φ U ψ ∈ w_{n+1}`". This makes the ordering total by construction.
3. The truth lemma for Until is proved by induction on the position in the omega-sequence,
   not by reasoning about `g_content ⊆` between arbitrary MCSes.

This structure is already partially encoded in `hintikka_step` (`Construction.lean:44`) and
`defect_count` (`Construction.lean:74`). The existing scaffolding is substantially correct.

---

## Confidence Level

**High confidence** (90%) on the following claims:
- `bx_le := g_content ⊆` is not total and is the wrong definition for Until/Since guards
- The sorry targets as formulated cannot be closed within the `bx_le` framework
- The quasimodel/Hintikka approach is the standard and correct technique
- The existing `Construction.lean` scaffolding is pointed in the right direction

**Medium confidence** (70%) on:
- The specific amount of rework required (depends on how `sigma_signature` is formalized)
- Whether the existing `hintikka_step` definition is complete enough to support the
  realization lemma without modification

**Lower confidence** (50%) on:
- Whether there exists a simpler single-lemma fix (e.g., adding BX13 = `(φ U ψ) → G((φ U ψ) ∨ ψ)`)
  that would close the sorries without the full quasimodel pivot. This requires a separate
  soundness check. If such an axiom is sound, it might allow `g_content ⊆` to propagate
  `(φ U ψ)` and thereby enable the BX5+BX9 argument to go through. This is worth checking
  before committing to the full quasimodel pivot.

---

## Summary for Synthesis

The core critical finding is:

> **The "genuine mathematical gap" claim is correct in diagnosis but wrong in framing.**
> The gap is not "bx_le needs to be total" but rather "bx_le is the wrong ordering for
> Until/Since guards." Two previous implementation agents have been trying to close six
> sorries that are unprovable within the current `bx_le` framework — not because of
> missing auxiliary lemmas, but because the definition of `bx_le` was never designed to
> support Until/Since truth lemmas. The standard literature (Burgess/Reynolds/Verbrugge)
> uses quasimodel/type-sequence constructions where the ordering is total by construction,
> not derived from g-content inclusion. The existing `Construction.lean` and `HintikkaPoint.lean`
> scaffolding represents the correct path forward and should be completed rather than patched.

The six sorries should be considered **WONTFIX under the current bx_le framework** and
instead be addressed by completing the quasimodel construction already scaffolded in the
codebase.
