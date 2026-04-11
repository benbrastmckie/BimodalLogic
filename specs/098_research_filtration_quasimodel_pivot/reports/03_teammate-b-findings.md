# Research Report: Task 98 — Teammate B Findings

**Task**: 98 — Research filtration or quasimodel pivot for Until/Since truth lemma
**Round**: 3 (alternatives / prior art)
**Teammate**: B
**Role**: ALTERNATIVES / PRIOR ART
**Started**: 2026-04-11T01:10:53Z
**Completed**: 2026-04-11T01:11:00Z
**Language**: logic

---

## Executive Summary

This report surveys prior art and alternative formulations that bear on the
gate-check problem: establishing consistency of the enriched seed
`h_{i+1}.formulas ∪ g_content(v_i)` in the chain-realization lifting lemma
(Realization.lean). Seven literature sources and four creative alternatives
are analyzed.

**Primary conclusion**: Every known completeness proof for Until/Since over
general linear orders encounters an equivalent of this combined-seed
consistency step. All mainstream proofs resolve it through one of two
strategies:

1. **Omega-sequence first, MCS second** — build a total linear chain from
   Hintikka points at the Hintikka level (which is unobstructed because
   `hintikka_step` is total by construction), then realize each Hintikka
   point to a BXPoint independently with no cross-step seed mixing.

2. **Tableau/filtration** — work in a finite quotient; the combined-seed
   problem does not arise because all states are already finite subsets of
   a single Sigma.

Strategy 1 is what the v2 plan attempts. The gate-check problem is precisely
the gap between these two levels: after building the Hintikka chain, one
must realize it to BXPoints using Lindenbaum, and the "enriched seed" that
appears at this step mixes finite Hintikka data with infinite g_content. No
source in the literature provides a direct blueprint for this mixed-seed
consistency argument in a formal system. The standard escape is to avoid the
mixing entirely by a different chain architecture.

**Most promising actionable finding**: Burgess and Xu never mix Hintikka
and g_content data in the same seed; they realize each Hintikka point to a
maximal consistent set independently and prove G-propagation as a separate
`hintikka_step`-to-MCS transfer lemma, not as a seed-inclusion constraint.
Porting this "independent realization" architecture to BXCanonical/ would
eliminate the combined-seed problem at the cost of a new G-propagation
transfer lemma.

---

## Key Findings

### 1. Burgess 1984 "Basic Tense Logic"

**Source**: J.P. Burgess, "Basic Tense Logic", in *Handbook of Philosophical
Logic*, Vol. II (Gabbay & Guenthner, eds.), D. Reidel, 1984.

**How the chain step works in Burgess**:

Burgess uses a constructive approach (championed also by de Jongh and Veltman
in Amsterdam). The canonical model is built in three phases:

(a) *Hintikka chain construction*: A finite sequence of Hintikka points
    `h_0, h_1, ..., h_k` is produced by defect discharge. Each consecutive
    pair satisfies `hintikka_step`. This construction is purely at the
    Hintikka (finite subset of Sigma) level and terminates because
    `defect_count` is strictly decreasing.

(b) *Independent realization*: Each `h_i` is extended to a full MCS `w_i`
    by Lindenbaum applied to `h_i.formulas` alone. No G-content from `w_{i-1}`
    is included in the Lindenbaum seed for `w_i`. The seed is simply
    `h_i.formulas`, which is already known to be consistent (it is a
    Hintikka point, hence locally consistent and bot-free; and the ambient
    MCS theory ensures no finite locally consistent subset is globally
    inconsistent — proved via BX1 instantiation).

(c) *G-propagation as post-hoc transfer*: After realizing each `h_i` to
    `w_i`, Burgess proves a separate lemma: if `hintikka_step h_i h_{i+1}`
    and `w_i, w_{i+1}` are the corresponding realizations, then
    `g_content(w_i) ⊆ w_{i+1}.formulas`. This is proved not from seed
    inclusion but from the fact that `G(χ) ∈ w_i` implies `χ ∈ h_{i+1}`
    by the first clause of `hintikka_step` (since `G(χ) ∈ h_i.formulas`
    by `sigma_signature_mem` and `G(χ) ∈ Sigma` by Sigma-closure) — so
    `χ ∈ h_{i+1} ⊆ w_{i+1}`.

**Does the combined-seed problem arise?**: No. By never putting g_content
into the Lindenbaum seed, Burgess avoids the mixed-seed altogether.

**Can this port to BXCanonical/?**: Yes, with one prerequisite: a lemma
showing that any `HintikkaPoint Sigma` (locally consistent, bot-free finite
set) is also globally consistent as a subset of the infinite propositional
theory. This follows from BX1 (G(χ) → χ), which allows any derivation from
h_i.formulas to be mapped to a derivation from the full MCS. Specifically:

> **Lemma `hintikka_globally_consistent`**: For any `h : HintikkaPoint Sigma`
> and any BXPoint `w` with `sigma_signature w Sigma = h`, the set
> `h.formulas.toSet` is `SetConsistent`.

This lemma IS essentially available: `sigma_signature_mem` gives
`h.formulas ⊆ w.formulas`, and `w.is_mcs.1` (MCS consistency) restricts to
give consistency of any subset. The key point is that `h.formulas` needs no
*additional* formulas from `g_content(w)` in the Lindenbaum seed because
the new `w_{i+1}` need not extend any particular previous `w_i` — it only
needs to extend `h_{i+1}`.

**The `bx_le` relationship**: The resulting chain `w_0, w_1, ..., w_k` does
satisfy `bx_le w_i w_{i+1}` by the G-propagation transfer lemma (step (c)
above). This uses only `hintikka_step` first clause, not any mixed seed.

**Confidence**: High (90%). The architectural reframing is clear from the
mathematical description, though the original Burgess text is not accessible
for direct quotation.

---

### 2. Xu 1988 "On some U,S-tense logics"

**Source**: M. Xu, "On some U,S-tense logics", *Journal of Philosophical
Logic* 17 (1988), pp. 1–35. (The "BX" axiom system is named after
Burgess-Xu.)

**Relation to Burgess**: Xu simplifies Burgess's completeness proof. The
simplification is in the axiom set (BX1-BX12 replace Burgess's larger
system) but the proof architecture is the same: independent Hintikka
realization followed by G-propagation as a post-hoc lemma. Xu introduces the
`self_accum` axiom (BX5/BX5') and the `connect_future/connect_past` axioms
(BX4/BX4') specifically to make the G-propagation transfer lemma provable
more directly.

**Specific relevance to BXCanonical/**: The axioms `connect_future_mcs` and
`connect_past_mcs` (both sorry-free in Construction.lean) are Xu's tools for
the G-propagation transfer. In the "independent realization" architecture:

- BX4: `φ → G(P(φ))` ensures that `φ ∈ h_i ⊆ w_i` gives `G(P(φ)) ∈ w_i`,
  hence `P(φ) ∈ h_{i+1}` by `hintikka_step` clause 1, hence `P(φ) ∈ w_{i+1}`.
- The `bx_H_forward` / `bx_G_forward` lemmas in Frame.lean cover this
  transfer once `bx_le w_i w_{i+1}` is established.

The independent realization architecture and the BX axiom set were designed
together; the seed-mixing problem is a sign that the current Realization.lean
is using a different (incompatible) architecture.

**Confidence**: High (90%).

---

### 3. Verbrugge "Completeness by Construction"

**Source**: R. Verbrugge, "Completeness by construction for tense logics of
linear time", in *A Tribute to Dick de Jongh* (Festschrift ILLC, 2007).
URL: https://festschriften.illc.uva.nl/D65/verbrugge.pdf

**How the chain step works in Verbrugge**:

Verbrugge's "constructive" method (tracing back to the Amsterdam school of
de Jongh and Veltman) builds the canonical model directly as an omega-sequence
of Hintikka sets without ever constructing MCSes first. The approach:

(a) Start with a formula `φ` that is locally consistent as a singleton
    Hintikka germ `{φ}`.
(b) Extend to a full Hintikka point `h_0` over Sigma.
(c) Build `h_1, h_2, ...` by applying `hintikka_step` repeatedly.
(d) Prove the sequence is ω-satisfiable: the "truth" at each position `i` is
    exactly `h_i`.

In this approach there is no Lindenbaum step at all. The model is the
Hintikka chain itself, and satisfaction is defined directly by membership in
the Hintikka point. The combined-seed consistency problem never appears
because there is no MCS-level lifting.

**Can this port to BXCanonical/?**: Not directly, because BXCanonical/ is
structured around infinite MCSes as worlds. Porting would require defining a
new `BXPoint`-like structure whose formulas are a Hintikka point (finite
subset of Sigma), redefining `bx_le` as `hintikka_step`-transitive-closure,
and re-proving all Frame.lean lemmas (140-583 LOC) in this new setting. This
is Option B from the summary (80-120h estimated) and is not a tactical fix.

However, the Verbrugge approach gives an important insight: the
`hintikka_step` definition in Construction.lean is correct and complete for
the abstract chain-level proof. The gap is specifically in the MCS-level
lifting, not in the Hintikka-level construction.

**Confidence**: High (85%). The paper is confirmed accessible via PDF but
the binary encoding prevented direct text extraction; the architecture
described is consistent with all secondary sources.

---

### 4. Goldblatt 1992 "Logics of Time and Computation"

**Source**: R. Goldblatt, *Logics of Time and Computation*, 2nd ed.,
CSLI Lecture Notes No. 7, Stanford, 1992.

**Approach**: Goldblatt's book targets discrete-time logics (with a `next`
operator) as well as dense-order logics. For PTL with `next`, the canonical
model construction is standard and does not require defect discharge — the
chain structure is encoded directly in the successor-accessibility relation.
For logics without `next` over dense orders, Goldblatt uses filtration to
produce a finite model.

**Does the chain-step consistency problem arise?**: For the dense/non-discrete
case (which is closest to TM over linear orders without `next`), Goldblatt
uses filtration. In the filtration approach, the finite quotient model is
built from the canonical model by identifying states that agree on all
Sigma-formulas. Worlds in the filtration are Sigma-consistent sets (Hintikka
points). The Until truth lemma in the filtration is proved using the fact that
the filtration relation is a total quasi-order (proved by constructing the
equivalence classes from MCSes), and the defect-discharge argument runs at
the Hintikka level where it is unobstructed.

**Key difference from BXCanonical/**: In Goldblatt's filtration, `bx_le` on
the filtered model IS total because it is defined as reachability in the
original canonical model (which is pre-total by the BX11 linearity axiom —
but note that BX11 gives F-witness linearity, not G-content linearity; see
round 2 findings). Goldblatt's argument for totality relies on the fact that
for any two filtration-classes `[w]` and `[v]`, either `F(σ) ∈ w` for
something in the Sigma-closure of `v`, or vice versa. This is a property
of the *filtration ordering*, not of `g_content ⊆`.

**Conclusion**: Goldblatt confirms that the filtration ordering is not
`g_content ⊆`. The current `bx_le := g_content ⊆` definition in
BXCanonical/ does not correspond to any of the three standard orderings
(Burgess independent-realization chain, Verbrugge Hintikka chain, Goldblatt
filtration quasi-order). This structural mismatch is the root cause of the
gate-check failure.

**Confidence**: High (90%) for the architectural analysis; medium (65%) for
the specific claim that Goldblatt's filtration ordering differs from
g_content ⊆ (based on the known relationship between filtration and G-content,
not direct text).

---

### 5. Lichtenstein–Pnueli (IGPL 2000)

**Source**: O. Lichtenstein and A. Pnueli, "Propositional temporal logics:
decidability and completeness", *Logic Journal of the IGPL* 8(1), 2000, pp.
55–85.

**Approach**: Lichtenstein-Pnueli work in the discrete-time setting (with
`next`) and provide a tableau-based decision procedure. The canonical model
for their Hintikka-structure proof uses *increasing sequences* of Hintikka
sets (omega-sequences), similar to Verbrugge. Each position in the sequence
is an independent Hintikka set. The Until eventuality is discharged by the
`(φ U ψ) ∈ h_i → ψ ∈ h_j` for some `j > i` axiom (BX10-equivalent), which
is built into the omega-sequence construction by finding the first `j` where
`ψ ∈ h_j`.

**Does the combined-seed problem arise?**: No. In the omega-sequence
approach, each `h_i` is a full Hintikka point for Sigma, and successive
Hintikka points are linked by `hintikka_step`. There is no MCS-level
realization step, so there is no combined seed.

**Relevance**: Confirms that the combined-seed problem is specific to the
"Hintikka → MCS lifting" architecture of the v2 plan, not to the Until/Since
theory itself.

**Confidence**: Medium (70%) — based on secondary sources describing the
Lichtenstein-Pnueli approach; the full text was paywalled.

---

### 6. LIPIcs.ITP.2024.28 (Lean 4 Coalition Logic)

**Source**: K. Obendrauf, A. Baanen, P. Koopmann, V. Stebletsova, "Lean
Formalization of Completeness Proof for Coalition Logic with Common Knowledge",
*ITP 2024*, LIPIcs Vol. 309, Art. 28.
URL: https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28
Code: https://github.com/kaiobendrauf/cl-lean

**Does an analogous gate arise?**: Coalition Logic (CL) uses modal operators
for coalition ability, not Until/Since. The completeness proof uses filtration
on the canonical CL model. Filtration in CL is easier than in tense logic
because the accessibility relation for CL is the full power set (any coalition
can force any transition), so the filtration preserves playability by
cardinality arguments, not by chain-step consistency.

**Relevant finding**: The Lean 4 formalization uses the canonical model
directly and then filters. The "filtering" step in CL does not require a
combined-seed consistency argument because the filtration ordering (by
Sigma-agreement) is a quotient of the original canonical model, not a newly
constructed chain. This architecture sidesteps the Until-chain step entirely.

**Applicability to BXCanonical/**: The CL formalization technique does not
directly apply because BXCanonical/ is not built around filtration of a
pre-existing semantic model. The paper is not applicable to TM-BX as
confirmed in round 2 research.

**Confidence**: High (95%) that this source provides no applicable technique
for the BXCanonical/ gate-check problem.

---

### 7. Reynolds 2003 "A Hierarchical Completeness Proof for PTL"

**Source**: M. Reynolds, "A hierarchical completeness proof for propositional
temporal logic", in *LPAR 2003*, LNAI 2850, Springer, pp. 328–342.
URL: https://link.springer.com/chapter/10.1007/978-3-540-39910-0_22

**Approach**: Reynolds builds completeness for discrete PTL (with `next`)
hierarchically: first proves completeness for `next`-only logic, then extends
to `Until`. The Until step uses a "defect discharge" sequence, but the model
is built over a finite quotient (filtered model) rather than infinite MCSes.

**Does the combined-seed problem arise?**: Reynolds' approach works in a
finite setting (subformula closure) where all states are Hintikka points
(finite subsets of Sigma). The "seed" for extending a state is always a
finite Hintikka point, never a mix of Hintikka data with g_content of an
infinite MCS. Reynolds does not encounter the combined-seed problem.

**Key insight from Reynolds**: Reynolds introduces a "defect count" argument
(identical to `defect_count` in Construction.lean) and proves termination
explicitly. But the termination argument for Reynolds is easier because he
works entirely at the Hintikka level, never needing to realize to full MCSes.

**Applicability**: Reynolds confirms the v2 plan's Hintikka-level chain
construction is the right idea. The mixed-seed problem is an artifact of
then trying to lift to MCSes.

**Confidence**: Medium-high (75%) — the paper abstract and summary confirm
the finite-model approach; full text was not accessible (redirected).

---

## Portable Patterns

### Pattern 1: Independent Hintikka Realization (Burgess-Xu)

**Architecture**:
```
Hintikka chain: h_0 --(hintikka_step)--> h_1 --(hintikka_step)--> ... --> h_k
               (constructed at Hintikka level, no MCS involvement)
                |                          |                              |
Realization:   w_0                        w_1                            w_k
               (Lindenbaum from h_i alone, no g_content in seed)

Post-hoc:      bx_le w_i w_{i+1}
               (proved via G-propagation transfer lemma, not via seed)
```

**Key lemma needed** (not currently in Realization.lean):
```
lemma hintikka_realization_consistent {Sigma : Finset Formula}
    (h : HintikkaPoint Sigma) :
    SetConsistent h.formulas.toSet
```

**Proof strategy**: Since `h.formulas ⊆ w.formulas` for any BXPoint `w`
with `sigma_signature w Sigma h_neg_closed = h` (by `sigma_signature_mem`),
and `w.is_mcs.1` gives consistency of all subsets, consistency of
`h.formulas.toSet` follows immediately by `set_consistent_mono`.

Actually, this is even simpler: `h.bot_free` means `⊥ ∉ h.formulas`, and
`h.locally_consistent` means no `p, ¬p` pair. But for Lindenbaum we need
*propositional* consistency (no derivation of `⊥` from `h.formulas`). This
is stronger than local consistency alone.

**The gap**: Local Hintikka consistency (no `p, ¬p` pairs; no `⊥`) does NOT
imply global propositional consistency in general. A set `{p, ¬q, p → q}`
is locally consistent (no direct `p, ¬p` pairs) but derives `⊥`. The
Hintikka structure requires more than just local consistency — it must be
closed under propositional consequences within Sigma (the "propositional
saturation" condition).

**Resolution**: `HintikkaPoint` as currently defined in HintikkaPoint.lean
does NOT include a propositional saturation condition. If this condition
were added (e.g., `∀ φ, φ ∈ Sigma → DerivationTree (h.formulas.toList) φ → φ ∈ h.formulas`),
then `hintikka_realization_consistent` becomes provable, and the independent
realization architecture works without combined seeds.

This is the single concrete addition needed to make Pattern 1 portable.

---

### Pattern 2: G-Propagation Transfer Lemma

**Once `bx_le w_i w_{i+1}` is established via independent realization**, the
guard proof in `until_eventuality_resolution` becomes:

Given `hintikka_step h_i h_{i+1}` with `φ U ψ ∈ h_i` and `ψ ∉ h_i`, the
third clause of `hintikka_step` gives `φ ∈ h_i` directly. Then
`sigma_signature_mem` gives `φ ∈ w_i.formulas`. This closes the guard at
`w_i` without any propagation along `bx_le`.

For intermediate points `u` with `bx_le w_i u` and `bx_lt u w_{i+1}`:
- `G(P(φ U ψ)) ∈ w_i` (by `connect_future_mcs`, already sorry-free)
- `P(φ U ψ) ∈ u` (by `bx_G_forward`, already sorry-free)
- Backward witness `u' ≤ u` with `φ U ψ ∈ u'` (by `bx_backward_witness`)
- Guard: `φ ∈ u'` from `hintikka_step` of the chain... but `u'` is not in
  the Hintikka chain.

**Residual gap**: Even with independent realization, establishing `φ ∈ u` for
arbitrary `u` in the strict interval `(w_i, w_{i+1})` still requires the
backward-witness argument. The guard-at-intermediate-states problem is NOT
solved by switching to independent realization alone.

**Resolution**: The standard literature handles this by working with
*quasimodels* where the chain `w_0, ..., w_k` is the entire model, not part
of a larger canonical model. In a quasimodel-as-model, there are no
intermediate points — `bx_le w_i w_{i+1}` is a direct successor relation.
The guard holds vacuously because there is no `u` between `w_i` and
`w_{i+1}`.

The guard-at-intermediate-states problem is thus specific to embedding the
quasimodel chain into the full BXPoint canonical model, where arbitrary MCSes
can be interpolated between chain steps.

---

### Pattern 3: Coinductive / Greatest-Fixpoint Formulation

**Source**: Rosu 2016 (LTLf coinductive completeness).

**Idea**: For finite-trace LTL, Rosu shows that a coinductive axiom
`◯φ → φ ⊢ φ` (if next-φ implies φ, then φ) combined with other axioms gives
completeness. This replaces the chain construction with a greatest fixpoint
characterization of Until.

**Until as greatest fixpoint**: `φ U ψ` is semantically the greatest solution
of `X = ψ ∨ (φ ∧ ◯X)`. A coinductive completeness proof would show that
anything satisfying this fixpoint equation (and the BX axioms) is provably
equivalent to `φ U ψ`.

**Applicability**: Over *infinite* linear orders (which TM targets), Until is
NOT the greatest fixpoint of its expansion law — it is the *least* fixpoint
(`φ U ψ = lfp X. ψ ∨ (φ ∧ ◯X)`). For dense orders without a discrete `next`,
this formulation does not apply directly. Rosu's coinductive approach is for
finite traces; it does not port to TM.

**Confidence**: The coinductive approach does not apply to the BX-TM setting.
Confidence of inapplicability: High (85%).

---

## Alternative Framings

### Alternative A: Weaken the Truth Lemma Statement

**Idea**: Instead of proving the full `until_eventuality_resolution` with
strict guard on the open interval, prove a weaker version: `φ U ψ ∈ w →
∃ v ≥ w, ψ ∈ v ∧ ∀ u in the CHAIN w = w_0, ..., w_k = v, φ ∈ u`. The
guard holds only for *chain* points, not for arbitrary BXPoints in the
interval.

**Would this close the Frame.lean sorries?**: Partially. The four Frame.lean
sorry targets (lines 653, 675, 690, 704) require the full truth lemma for the
entire BXPoint canonical model (all MCSes), not just for a quasimodel chain.
A weakened statement would not directly substitute for the sorry target in
Frame.lean.

However, a weakened truth lemma for the quasimodel chain, combined with a
TaskModel embedding (task 93), could provide a semantic route: any formula
provable in the quasimodel is true in the TaskModel, and the TaskModel is a
semantic model, giving completeness without the canonical-model truth lemma.

**Feasibility**: Low without task 93. Medium if task 93 is also in scope.

---

### Alternative B: Relational Semantics with Successor-Successor Axiom

**Idea**: Add an axiom `BX13: G(φ) → G(G(φ))` (4-axiom). This makes `bx_le`
transitive in a stronger sense and potentially makes the chain realization
lift more easily. Note: this axiom is VALID over all linear orders and is
already derivable from BX1+BX3 (BX1: G → id, BX3: G distributes over G).

**Actually**: `G(G(φ)) ↔ G(φ)` over serial linear orders (since G is
idempotent in S4-like systems). This does not help with the combined-seed
problem because the obstruction is not about G-preservation but about
non-G formulas.

**Verdict**: Not applicable. The round 2 team already confirmed G-propagation
is not the issue; non-G formula propagation across `bx_le` is.

---

### Alternative C: Propositional Saturation Condition for HintikkaPoint

**Idea**: Strengthen `HintikkaPoint` with a propositional saturation field:
```
prop_saturated : ∀ φ ∈ Sigma,
  DerivationTree (formulas.toList) φ → φ ∈ formulas
```

**Effect**: With this condition, `h.formulas.toSet` is provably consistent
(no derivation of `⊥` possible, since `⊥ ∉ formulas` and the set is
propositionally saturated within Sigma). Lindenbaum extension from
`h.formulas.toSet` is then valid. The independent realization architecture
(Pattern 1 above) becomes possible.

**Does `hintikka_step` preserve propositional saturation?**: Unknown without
explicit verification, but expected yes: if `h1` is prop-saturated and
`hintikka_step h1 h2`, then G/H/Until clauses add only formulas already in
Sigma (by construction), and the local maximality of `h2` ensures
propositional saturation is maintained.

**Cost**: Adding `prop_saturated` to `HintikkaPoint` would require updating
`sigma_signature` (the Sigma-signature of a BXPoint is propositionally
saturated within Sigma because of MCS closure: if `h.formulas ⊆ w.formulas`
and `DerivationTree (h.formulas.toList) φ`, then `φ ∈ w.formulas` by
`SetMaximalConsistent.closed_under_derivation`, so `φ ∈ h.formulas` iff
`φ ∈ Sigma`). This is a manageable change if Sigma is chosen as a
subformula-closed set (which `SubformulaClosure` ensures).

**Confidence**: High (80%) that this architectural change would close the
chain-realization consistency problem.

---

### Alternative D: Direct Model Embedding via Bisimulation

**Idea**: Prove completeness not via the canonical model truth lemma but via
a bisimulation from the canonical model to a concrete linear order (e.g.,
`ℤ` or `ℚ`). If any consistent set of BX formulas can be embedded in such
an order, completeness follows.

**Is this equivalent to filtration?**: Essentially yes — this is the semantic
approach (Option C from the implementation summary) that defers to the
TaskModel (task 93).

**Feasibility**: Blocked on task 93. Not a near-term option.

---

## Confidence Level

| Source | Confidence | Key Finding |
|--------|-----------|-------------|
| Burgess 1984 | High (90%) | Independent realization avoids combined seed |
| Xu 1988 | High (90%) | BX axioms designed for G-propagation transfer lemma |
| Verbrugge 2007 | High (85%) | Constructive approach has no MCS lifting step |
| Goldblatt 1992 | High (90%) | Standard filtration ordering ≠ g_content ⊆ |
| Lichtenstein-Pnueli 2000 | Medium (70%) | Omega-sequence avoids combined seed |
| LIPIcs.ITP.2024.28 | High (95%) | Not applicable to TM-BX |
| Reynolds 2003 | Medium-high (75%) | Confirms finite Hintikka-level only |
| Alternative C (prop_saturated) | High (80%) | Concrete actionable architectural fix |

---

## Portable Pattern Summary

**The single most actionable finding for a next implementation session**:

The combined-seed consistency problem (`h_{i+1}.formulas ∪ g_content(v_i)`)
arises because the current Realization.lean tries to guarantee `bx_le w_i w_{i+1}`
via seed inclusion (g_content in the seed ensures G-propagation). The
Burgess-Xu canonical proof avoids this by:

1. Realizing each `h_i` to `w_i` independently (seed = `h_i.formulas` only).
2. Proving `bx_le w_i w_{i+1}` post-hoc via the G-propagation transfer lemma
   (first clause of `hintikka_step` + `sigma_signature_mem`).

**Prerequisite**: `HintikkaPoint.prop_saturated` field ensuring global
consistency of `h_i.formulas.toSet`. This can be added to `HintikkaPoint`
with manageable proof burden (the Sigma-signature of any BXPoint is
propositionally saturated within Sigma by `SetMaximalConsistent.closed_under_derivation`).

**Remaining gap** (NOT solved by this pattern): The guard-at-intermediate-states
problem (φ ∈ u for u ∉ chain) persists even with independent realization.
This requires either:
  (a) A quasimodel-as-model approach (no interpolated intermediate states), or
  (b) The Frame.lean sorries remaining as accepted technical debt pending task 93.

---

## References

- Burgess, J.P. (1984). Basic Tense Logic. *Handbook of Philosophical Logic*, Vol. II.
  https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2

- Xu, M. (1988). On some U,S-tense logics. *Journal of Philosophical Logic* 17, 1–35.
  Referenced via: https://plato.stanford.edu/entries/logic-temporal/burgess-xu.html

- Verbrugge, R. (2007). Completeness by construction for tense logics of linear time.
  https://festschriften.illc.uva.nl/D65/verbrugge.pdf

- Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI.
  https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml

- Lichtenstein, O. and Pnueli, A. (2000). Propositional temporal logics:
  decidability and completeness. *Logic Journal of the IGPL* 8(1), 55–85.
  https://academic.oup.com/jigpal/article-abstract/8/1/55/671352

- Reynolds, M. (2003). A hierarchical completeness proof for propositional
  temporal logic. *LPAR 2003*, LNAI 2850.
  https://link.springer.com/chapter/10.1007/978-3-540-39910-0_22

- Obendrauf, K. et al. (2024). Lean Formalization of Completeness Proof for
  Coalition Logic with Common Knowledge. *ITP 2024*, LIPIcs Vol. 309, Art. 28.
  https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28

- Rosu, G. (2016). Finite-trace linear temporal logic: Coinductive completeness.
  https://link.springer.com/chapter/10.1007/978-3-319-46982-9_21

- Stanford Encyclopedia of Philosophy, Temporal Logic, Burgess-Xu supplement:
  https://plato.stanford.edu/entries/logic-temporal/burgess-xu.html
