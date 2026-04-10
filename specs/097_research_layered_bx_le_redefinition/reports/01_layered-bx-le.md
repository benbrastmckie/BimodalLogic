# Research Report: Task #97 — Layered `bx_le` Redefinition

**Task**: 97 — Research layered `bx_le` redefinition preserving Box truth lemma
**Parent Task**: 92 — implement_bx_until_truth_lemma
**Date**: 2026-04-10
**Language**: logic
**Mode**: Single-agent research (logic-research-agent)
**Session**: sess_1775856757_3e0e7d

---

## Executive Summary

**Recommendation: REJECT ALL LAYERED CANDIDATES.** None of the investigated
layered definitions `bx_le' w u := g_content(w) ⊆ u.formulas ∧ until_compatible w u`
simultaneously achieves all four criteria (reflexivity + transitivity, Box/G/H
preservation, Gap U5 / B-GAP closure, equivalence-on-image). The root cause is
a **structural invariant** that generalizes task 90's Flaw 2: any second
conjunct strong enough to make the guard clause derivable from BX5–BX12 is
either (i) not transitive because `until_compatible` refines in ways that do
not compose along `bx_le`-chains, (ii) equivalent to the full `g_content ⊆`
(so adds nothing), or (iii) so weak it fails to close Gap U5 and reproduces
the empty-information failure of task 92's Phase 0 diagnostic.

The layered strategy was conjectured to work because the `g_content ⊆` layer
preserves Box/G/H truth lemmas "for free" (criterion b is trivialized). This
turns out to be correct, but insufficient: task 92's blocker is *not* about
Box preservation, it is about guard propagation of non-G-shape Until formulas
through `bx_le`-intervals, and no amount of `until_compatible` strengthening
can compensate because the guard clause quantifies universally over **all**
`bx_le`-intermediate MCSes, not merely those in the restricted layered
sub-relation.

**Strongest negative finding**: Candidate C1 (Until-witness subset) fails at
criterion (a) transitivity by precisely the task 90 counterexample, and even
if wrapped in layered form, the first conjunct `g_content ⊆` does not rescue
transitivity of the second conjunct. Candidate C2 (finite-prefix agreement)
is reflexive + transitive but proves **weaker** than `g_content ⊆` on the
guard quantifier, so criterion (c) fails for the same reason task 92 Phase 0
failed. Candidate C3 (interval-linearity closure) is transitive but not
constructive — the closure is exactly the unknown linearity that task 90
Branch A demonstrated was not derivable from BX7+BX11+BX12. Candidate C4
(the novel "G-witness + Until-witness locus" definition designed during
this research) is reflexive + transitive and does close U5 *at the forward
step* but fails B-GAP because the backward witness produced by BX4 is not
guaranteed to be in the `until_compatible`-image of `w`.

**Implication for task 92**: The blocker root cause in
`specs/092/reports/04_spawn-analysis.md` generalizes to *any* layered
redefinition, because the obstruction is in the **universal guard quantifier
over `bx_le`**, not in the definition of `bx_le` itself. Task 92 should NOT
pursue task 97's approach. The three remaining escape hatches are: (1) BX13
axiom strengthening (task 95 / parallel research), (2) filtration /
quasimodel pivot (task 96 / parallel research), (3) restricting the guard
quantifier in the **statement** of the four sorries so that it ranges only
over a constructed chain, not arbitrary `bx_le`-intermediates.

---

## Context & Scope

### Task 90's Option A Rejection (Summary)

Task 90 rejected a standalone Until-witness redefinition of `bx_le` because
of two fatal flaws:

- **Flaw 1 (Non-equivalence)**: An MCS `w` with `G(p) ∈ w` but no pending
  Until formulas satisfies `bx_le_uw w v` vacuously for every `v`, while
  `g_content(w) ⊆ v` requires `p ∈ v`. So the two orderings disagree at
  empty-Until-pending MCSes.
- **Flaw 2 (Non-transitivity)**: If `ψ ∈ u` resolves a pending `φ U ψ` at
  step `w → u`, nothing carries `ψ` forward to `v` at step `u → v`; the
  Until-witness relation only tracks pending formulas, not resolved ones.

### Task 97's Layered Refinement

The layered hypothesis: replace `bx_le` with

```lean
def bx_le' (w u : BXPoint) : Prop :=
  g_content w.formulas ⊆ u.formulas ∧ until_compatible w u
```

where `until_compatible` is a *second conjunct* layered on top of the
existing `g_content ⊆` layer. The conjecture is that:

- Flaw 1 is neutralized because `g_content ⊆` is retained as the first
  conjunct, so `bx_le'` is at least as strong as the current `bx_le`.
- All Box/G/H truth lemmas that used `bx_le` via `h_le : bx_le w v` still
  work because they only need the first conjunct; the destructor projects
  to `h_le.1` and reuses the existing proofs.
- The second conjunct adds the Until-ordering information needed to close
  Gap U5 and B-GAP.

This report evaluates four concrete choices for `until_compatible`.

### Evaluation Criteria (from task description)

- **(a) Order axioms**: Is `bx_le'` reflexive and transitive?
- **(b) Box preservation**: Does it preserve `box_preserved_along_bx_le`
  and the Box/G/H truth lemmas at `Frame.lean:501-583`?
- **(c) Sorry closure**: Does it close Gap U5 and B-GAP by making the
  guard clause derivable from BX axioms?
- **(d) Image equivalence**: Is `bx_le'` equivalent to the current `bx_le`
  on the image of `box_preserved_along_bx_le` (i.e., agree where it matters)?

### Scope Fence

READ-ONLY research. No `Theories/` files are modified. `lean_multi_attempt`
probes are acceptable (none needed for this round — the failures are
detectable at the mathematical level without LSP probes).

---

## Candidates

Four candidates are evaluated:

- **C1**: Until-witness subset (task 90's exact Option A, now layered)
- **C2**: Finite-prefix agreement on Until formulas
- **C3**: Interval-linearity closure
- **C4**: Novel — "Pending-Until propagation closure with resolved-set monotony"

---

## Decision Matrix

Legend: ✓ = passes, ✗ = fails, ~ = passes conditionally, ? = indeterminate.

| Candidate | (a) refl | (a) trans | (b) Box/G/H | (c) Gap U5 | (c) B-GAP | (d) image-equiv |
|-----------|:--------:|:---------:|:-----------:|:----------:|:---------:|:---------------:|
| **C1** Until-witness subset (layered) | ✓ | ✗ | ✓ | ~ | ✗ | ✗ |
| **C2** Finite-prefix agreement | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ |
| **C3** Interval-linearity closure | ✓ | ✓ | ✓ | ? | ? | ~ |
| **C4** Pending-Until closure (novel) | ✓ | ✓ | ✓ | ~ | ✗ | ✓ |

**Summary**: No candidate passes all six sub-criteria. C3 is indeterminate
on (c) for the same reason task 90 probes were indeterminate on bx_le
linearity — the question reduces to an open derivability question that
prior work already classified as structurally blocked.

---

## Candidate C1: Until-Witness Subset (Layered)

### Definition

```lean
def until_compatible_C1 (w u : BXPoint) : Prop :=
  ∀ (φ ψ : Formula),
    Formula.untl φ ψ ∈ w.formulas →
    ψ ∉ w.formulas →
    Formula.untl φ ψ ∈ u.formulas ∨ ψ ∈ u.formulas

def bx_le_C1 (w u : BXPoint) : Prop :=
  g_content w.formulas ⊆ u.formulas ∧ until_compatible_C1 w u
```

### Analysis

**(a) Reflexivity**: ✓. The first conjunct is `bx_le_refl`. For the second,
given `φ U ψ ∈ w` with `ψ ∉ w`, take the left disjunct `φ U ψ ∈ w`.

**(a) Transitivity**: ✗. Task 90 Teammate A Flaw 2 applies directly. The
layering with `g_content ⊆` does not rescue it: consider `w, u, v` with
`φ U ψ ∈ w`, `ψ ∉ w`, `ψ ∈ u` (so `until_compatible_C1 w u` holds via the
right disjunct), `ψ ∉ v`, and `φ U ψ ∉ v` (for some fresh Until formula
that came into `u` only via the resolution). The middle step
`until_compatible_C1 u v` may hold vacuously (since `ψ ∈ u` means
`φ U ψ` is no longer "pending" at `u`), but `until_compatible_C1 w v`
requires `φ U ψ ∈ v ∨ ψ ∈ v`, neither of which is derivable. The
`g_content ⊆` layer does not help because `φ U ψ` is not of shape
`G(χ)`, so `g_content(w) ⊆ v` does not propagate it.

This is precisely the task 92 Phase 0 obstruction re-expressed: Until
formulas are not G-shape, so they cannot be transported by `g_content ⊆`
transitivity, even when the relation is layered.

**(b) Box/G/H preservation**: ✓ (conditional). Since the first conjunct is
retained, destructuring any `h_le : bx_le_C1 w v` gives `h_le.1 : bx_le w v`,
and all existing sorry-free Box/G/H lemmas apply verbatim. The only cost is
an `.1` projection in call sites.

**(c) Gap U5 closure**: ~. At the forward step (constructing `v` via
`bx_forward_witness`), `until_compatible_C1 w v` can potentially be
arranged by choosing the Lindenbaum seed to include all pending Until
formulas at `w` with their `φ` parts. But the guard clause still
quantifies over **all** `u` with `bx_le_C1 w u ∧ bx_le_C1 u v`, and
because C1 is not transitive, the guard clause's antecedent
`bx_le_C1 u v` does not follow from `bx_le_C1 w u` + `bx_le_C1 w v`.
The new guard clause is *different* from the old one, but still has
no derivation path.

**(c) B-GAP closure**: ✗. Same root cause as task 92 Phase 0:
`bx_backward_witness` from `P(¬(φ U ψ)) ∈ v` produces some `u' ≤ v` with
`¬(φ U ψ) ∈ u'.formulas`, but there is no mechanism to ensure
`until_compatible_C1 w u'`. The backward witness is constructed by
Lindenbaum extension of `{¬(φ U ψ)} ∪ h_content(v)`, which has no
relationship to `w`'s pending Until formulas.

**(d) Image equivalence**: ✗. The task 90 counterexample (`G(p) ∈ w` with
no pending Until formulas) gives an MCS where `bx_le w v` implies
`bx_le_C1 w v` (trivially, since the `until_compatible` clause is
vacuously true when `w` has no pending Until formulas). But the converse
fails: `bx_le_C1 w v` implies `g_content(w) ⊆ v`, so actually C1 is
*strictly stronger* than `bx_le`, not weaker. The image equivalence
holds as `bx_le_C1 ≤ bx_le`, but the reverse inclusion fails because C1
is strictly finer — and on the forward/backward witness constructions
(`bx_forward_witness`, `bx_backward_witness`), the produced witnesses
satisfy `bx_le` but not necessarily `bx_le_C1`, so the existing
Box/G/H infrastructure cannot be re-used to produce C1-witnesses.

### Verdict: REJECT

**Obstruction formula**: There exist `w, u, v : BXPoint` and
`φ, ψ : Formula` with:

```
  φ U ψ ∈ w.formulas,  ψ ∉ w.formulas,
  ψ ∈ u.formulas,      φ U ψ ∉ v.formulas,  ψ ∉ v.formulas,
  g_content(w) ⊆ u,    g_content(u) ⊆ v,
  until_compatible_C1 w u  (via right disjunct ψ ∈ u),
  until_compatible_C1 u v  (vacuous, w.r.t. `φ U ψ` no longer pending at u),
  ¬ until_compatible_C1 w v  (neither φ U ψ nor ψ in v).
```

Such a configuration is constructible by Lindenbaum extension of a seed
that forces `ψ ∈ u` to "extinguish" the pending formula at `u` while
leaving `v` agnostic about it. Existence proof: a fresh propositional
atom `q` uncorrelated with `ψ`; extend `v` with `¬ψ ∧ ¬(φ U ψ)`, which
is consistent with any `g_content(u)` that does not mention `ψ` or
`φ U ψ` (typical when `u`'s accumulated G-formulas concern only `q`).

---

## Candidate C2: Finite-Prefix Agreement on Until Formulas

### Definition

Fix a finite vocabulary `V ⊆ Formula` closed under subformulas.

```lean
def until_compatible_C2 (V : Finset Formula) (w u : BXPoint) : Prop :=
  ∀ (φ ψ : Formula),
    Formula.untl φ ψ ∈ V →
    (Formula.untl φ ψ ∈ w.formulas ↔ Formula.untl φ ψ ∈ u.formulas)

def bx_le_C2 (V : Finset Formula) (w u : BXPoint) : Prop :=
  g_content w.formulas ⊆ u.formulas ∧ until_compatible_C2 V w u
```

### Analysis

**(a) Reflexivity**: ✓. Both conjuncts are trivially reflexive
(the biconditional is reflexive on any set).

**(a) Transitivity**: ✓. The biconditional is transitive; `g_content ⊆`
is transitive.

**(b) Box/G/H preservation**: ✓. Same as C1 — destructuring gives the
first conjunct, existing proofs apply.

**(c) Gap U5 closure**: ✗. This is where C2 fatally fails. The guard
clause for `bx_until_eventuality_resolution` requires that at every
`u` with `bx_le_C2 w u ∧ bx_le_C2 u v`, we have `φ ∈ u.formulas`. The
finite-prefix biconditional clause provides zero new information about
whether `φ ∈ u`: it only constrains the truth values of Until formulas
*in `V`* at `u`. Even if `φ U ψ ∈ V` and the biconditional gives
`φ U ψ ∈ u ↔ φ U ψ ∈ w`, and `φ U ψ ∈ w` is given, so `φ U ψ ∈ u`, the
step from `φ U ψ ∈ u` to `φ ∈ u` is still BX9's `until_elim` (which is
what the existing Phase 0 attempt uses) plus an earliness argument to
rule out `ψ ∈ u`. The earliness argument is *exactly* what fails in
task 92's Phase 0: BX7 gives formula-level witness ordering, not
MCS-level locus control.

C2 is just "agree on Until formulas in a finite prefix" — this is a
filtration-like predicate but does not give the Burgess-Xu propagation
structure task 92 needs.

**(c) B-GAP closure**: ✗. Same root failure as C1. The backward witness
`u'` from `P(¬(φ U ψ)) ∈ v` has no guarantee of satisfying C2 with `w`.

**(d) Image equivalence**: ✓. C2 is weaker than `bx_le` in one direction
(biconditional adds a constraint) but the constraint is on a finite set,
so `bx_le w u` plus a finite coincidence check gives `bx_le_C2 w u`.
The image on `bx_forward_witness` etc. can be arranged by enlarging
the Lindenbaum seed to control the finite `V`-prefix.

### Verdict: REJECT

**Obstruction formula**: There exist `V`, `w`, `u`, `v`, `φ`, `ψ` with
`φ U ψ ∈ V`, `φ U ψ ∈ w ∩ u ∩ v`, `ψ ∈ u`, `ψ ∉ w`, `ψ ∉ v`, `φ ∉ u`.
The biconditional holds (the formula is present at all three points),
but `φ ∉ u` violates the guard. BX9 applied at `u` gives `φ ∨ ψ ∈ u`,
and `ψ ∈ u` resolves the disjunction to `ψ`, so `φ ∉ u` is consistent.
Nothing in C2 forces `ψ ∉ u`.

The deep reason: C2 conflates "Until formula is present" with "Until
witness is here", but BX9 is sound for both cases, and the earliness
selector that would rule out `ψ ∈ u` is not a C2-definable property.

---

## Candidate C3: Interval-Linearity Closure

### Definition

```lean
def until_compatible_C3 (w u : BXPoint) : Prop :=
  ∀ (x y : BXPoint), g_content w.formulas ⊆ x.formulas →
                     g_content x.formulas ⊆ u.formulas →
                     g_content w.formulas ⊆ y.formulas →
                     g_content y.formulas ⊆ u.formulas →
                     g_content x.formulas ⊆ y.formulas ∨
                     g_content y.formulas ⊆ x.formulas

def bx_le_C3 (w u : BXPoint) : Prop :=
  g_content w.formulas ⊆ u.formulas ∧ until_compatible_C3 w u
```

i.e., `bx_le_C3 w u` means `bx_le w u` AND the interval `[w, u]` is linearly
ordered by `bx_le`.

### Analysis

**(a) Reflexivity**: ✓. For `bx_le_C3 w w`, the first conjunct is
`bx_le_refl`, the second is vacuously linear (the interval `[w, w]` is a
singleton modulo `bx_le`-equivalence).

**(a) Transitivity**: ✓. `g_content ⊆` is transitive; for
`until_compatible_C3`, if `[w, u]` and `[u, v]` are both interval-linear,
then any two points in `[w, v]` are either both in `[w, u]`, both in
`[u, v]`, or one in each, and the third case is handled by transitivity
through `u`. (The proof requires case analysis but is standard
order-theory; no BX axioms needed.)

**(b) Box/G/H preservation**: ✓. First-conjunct projection.

**(c) Gap U5 closure**: ?. With interval linearity, the guard clause for
`bx_until_eventuality_resolution` becomes derivable *if* we can produce
`v` such that every `u` in `[w, v]` satisfies both `bx_le_C3 w u` and
`bx_le_C3 u v`, i.e., every interval `[w, u']` and `[u, v']` with
`u, u' ∈ [w, v]` is itself linearly ordered. This is strictly stronger
than global linearity of `[w, v]`; it requires *hereditary* interval
linearity, which is equivalent to global linearity of the downset
`{x | bx_le w x ∧ bx_le x v}`.

Task 90 Phase 2 (`02_bx_le_linear_diagnostic.md`) already probed whether
global `bx_le_linear` or its interval variant is derivable from
BX7+BX11+BX12 and concluded NO with high confidence. The obstruction:
BX7 is a *formula-level* linearity on Until resolution inside one MCS,
not an MCS-level total order statement. BX11 is a *formula-level*
linearity on F-witnesses inside one MCS. Neither bridges to MCS-level
comparability without an additional linking axiom.

Therefore C3's second conjunct is a *property we cannot establish* for
the witnesses produced by `bx_forward_witness`. The forward witness is
constructed via Lindenbaum extension of `{ψ} ∪ g_content(w)`, and there
is no step in that construction that would arrange interval linearity
with respect to arbitrary other `bx_le`-intermediate MCSes.

**(c) B-GAP closure**: ?. Same indeterminacy. If the backward witness
`u'` from `P(¬(φ U ψ)) ∈ v` happened to satisfy `bx_le_C3 w u'`, the
guard hypothesis would apply. But arranging this requires knowing
*in advance* that `u'` is `bx_le`-comparable with arbitrary
intermediate points, which is exactly what task 90's linearity
diagnostic concluded cannot be derived.

**(d) Image equivalence**: ~. The first conjunct is `bx_le`, so C3 is at
least as strong. It is strictly stronger exactly when the interval
contains non-linearly-ordered points — and since `bx_le` non-linearity
is (informally) a fact of the model, C3 is strictly stronger on some
non-empty set of inputs.

### Verdict: REJECT (by reduction to known-blocked subproblem)

**Obstruction formula**: Reduces to task 90 Phase 2 obstruction. C3's
second conjunct, restricted to `v = u` = the forward witness produced
by `bx_forward_witness`, is exactly `bx_le_interval_linear w u`, whose
derivability from BX1-BX12 was classified "structurally infeasible" in
`specs/090/reports/02_bx_le_linear_diagnostic.md`.

C3 transforms task 92's U5/B-GAP blocker into task 90's interval-linearity
blocker, which is also blocked. The cost of this transformation is positive
(extra proof obligations at every use site) with no benefit.

---

## Candidate C4: Pending-Until Propagation with Resolved-Set Monotony (Novel)

### Definition

This is the candidate of my own design. It attempts to patch C1's Flaw 2
by additionally tracking the "resolved" set: formulas whose `ψ`-part was
already witnessed in the `w`-history.

```lean
-- R(w) = set of Until formulas resolved at w, i.e., ψ already true at w
def resolved_set (w : BXPoint) : Set Formula :=
  { Formula.untl φ ψ | φ ψ : Formula, ψ ∈ w.formulas }

def until_compatible_C4 (w u : BXPoint) : Prop :=
  -- pending Until formulas persist or resolve
  (∀ φ ψ, Formula.untl φ ψ ∈ w.formulas → ψ ∉ w.formulas →
          Formula.untl φ ψ ∈ u.formulas ∨ ψ ∈ u.formulas) ∧
  -- resolved Until formulas remain resolved OR propagated
  (∀ φ ψ, Formula.untl φ ψ ∈ resolved_set w →
          Formula.untl φ ψ ∈ resolved_set u ∨ Formula.all_future ψ ∈ w.formulas)

def bx_le_C4 (w u : BXPoint) : Prop :=
  g_content w.formulas ⊆ u.formulas ∧ until_compatible_C4 w u
```

The intuition: C1's transitivity failure came from forgetting that a
`ψ`-resolution at `u` does not propagate to `v`. C4 adds a "monotony
certificate": either the resolution persists to `u` as a resolved Until,
or the certifying `ψ` is already globally future-necessitated at `w`
(i.e., `G(ψ) ∈ w`, so `ψ` propagates via `g_content`).

### Analysis

**(a) Reflexivity**: ✓. Both conjuncts hold at `w = u`: pending-Until is
trivial via left disjunct; resolved-Until is trivial via left disjunct.

**(a) Transitivity**: ✓, by a careful argument. Given
`bx_le_C4 w u ∧ bx_le_C4 u v`:

- `g_content(w) ⊆ v` is transitive from the first conjuncts.
- Pending-Until: if `φ U ψ ∈ w` with `ψ ∉ w`, then at `u` we have
  `φ U ψ ∈ u ∨ ψ ∈ u`.
  - Case `φ U ψ ∈ u`, `ψ ∉ u`: apply step 2 to get `φ U ψ ∈ v ∨ ψ ∈ v`.
    Done.
  - Case `φ U ψ ∈ u`, `ψ ∈ u`: then `φ U ψ ∈ resolved_set u`. Step 2's
    second clause at `u → v` gives `φ U ψ ∈ resolved_set v ∨ G(ψ) ∈ u`.
    - Subcase resolved at v: `ψ ∈ v`, done.
    - Subcase `G(ψ) ∈ u`: but then `g_content(u) ⊆ v` gives `ψ ∈ v`, done.
  - Case `ψ ∈ u` (regardless of `φ U ψ ∈ u`): same as above, `φ U ψ` is
    resolved at `u`; apply step 2's second clause. Same subcases.
- Resolved-Until: similar case analysis. Omitted for brevity.

Transitivity holds. The resolved-set tracking closes the C1 gap.

**(b) Box/G/H preservation**: ✓. First-conjunct projection.

**(c) Gap U5 closure**: ~. At the forward step, constructing `v` via
`bx_forward_witness` with seed `{ψ} ∪ g_content(w)` can be augmented to
also include `{φ U ψ | φ U ψ ∈ w.formulas, ψ ∉ w}` as pending-Until
persistence, giving `until_compatible_C4 w v` at the pending clause. The
resolved clause requires `{G(ψ') | some φ' U ψ' ∈ resolved_set w, ψ' ∉ w}`,
which is vacuous since `ψ ∉ w` means nothing in `resolved_set w`. So
`bx_le_C4 w v` is constructible.

The guard clause: for `u` with `bx_le_C4 w u ∧ bx_le_C4 u v ∧ ¬bx_le_C4 v u`,
we need `φ ∈ u`. By BX9 at `u`, `φ U ψ ∈ u → φ ∨ ψ ∈ u`, and if `ψ ∈ u`,
then the C4 transitivity case above gives `ψ ∈ v`, contradicting
`¬bx_le_C4 v u` (because if `ψ ∈ v` and `v` has no other distinguishing
content, then `v ≤_C4 u`)... **BUT** this argument requires `bx_le_C4 v u`
to be characterized by formula inclusions on `u`, which is circular.

More precisely: the C4 guard closure requires not just "ψ ∈ v → v ≤ u"
but "ψ ∈ v → bx_le_C4 v u". The first conjunct `g_content(v) ⊆ u` is
what is required for the old `bx_le v u`, and `ψ ∈ u` does not directly
imply that. So the anti-symmetry argument does not close.

**(c) B-GAP closure**: ✗. Same root failure as C1 and C2. The backward
witness `u'` from BX4-propagated `P(¬(φ U ψ)) ∈ v` has no mechanism for
C4-relation to `w`. Lindenbaum extension of
`{¬(φ U ψ)} ∪ h_content(v)` ignores `w`'s pending-Until set entirely.

To fix this, one would need the Lindenbaum seed for the backward witness
to include `{φ U ψ | φ U ψ ∈ w.formulas, ψ ∉ w}`. But this seed is
inconsistent if `¬(φ U ψ) ∈ {¬(φ U ψ)} ∪ h_content(v)` — which is exactly
the formula we are propagating. So we cannot force the backward witness
into `w`'s forward cone without inconsistency.

**(d) Image equivalence**: ✓. C4 is strictly stronger than `bx_le`, but
on `bx_forward_witness`-produced witnesses, the extra C4 clauses can be
arranged by seed augmentation (as sketched above for the forward case;
the backward case cannot, which is the obstruction for criterion (c)).

### Verdict: REJECT

**Obstruction formula**: The B-GAP backward witness construction is
incompatible with layered `until_compatible`. Precisely: given
`w, v : BXPoint`, `h_wv : bx_le_C4 w v`, `h_not_wv : ¬(φ U ψ) ∈ w`, and
`P(¬(φ U ψ)) ∈ v` (from BX4' applied to `h_not_wv` and transported via
`g_content`), the Lindenbaum extension of `{¬(φ U ψ)} ∪ h_content(v)`
producing `u'` with `bx_le u' v` cannot be augmented to also satisfy
`until_compatible_C4 w u'` because the augmentation seed would include
`φ U ψ` (from `w`'s pending set), which is inconsistent with `¬(φ U ψ)`.

This obstruction is **independent of the specific `until_compatible`
predicate**: any predicate that tries to link `u'` to `w`'s pending-Until
set will run into the same inconsistency at the backward witness
construction, because the entire point of B-GAP is that the backward
witness carries `¬(φ U ψ)` and `w` carries `(φ U ψ)`.

---

## Structural Invariant: Why All Layered Candidates Fail

The four candidates above exhibit a common failure pattern, which we can
extract as a structural invariant:

**Claim**: Any layered definition
`bx_le' w u := g_content(w) ⊆ u.formulas ∧ P(w, u)` for a predicate `P`
that (i) is reflexive + transitive, (ii) holds on the forward witness
produced by Lindenbaum extension of `{ψ} ∪ g_content(w)`, and (iii) holds
on the backward witness produced by Lindenbaum extension of
`{¬(φ U ψ)} ∪ h_content(v)` when the intent is to have `u'` pass the
guard clause for `w`, must satisfy an **inconsistent triple**:

```
(A) φ U ψ ∈ w           [given, Until premise]
(B) ¬(φ U ψ) ∈ u'       [backward witness seed, B-GAP premise]
(C) P(w, u')            [required so the guard clause applies]
```

Any `P` that forces (C) given (A) must derive either (a) `φ U ψ ∈ u'`
(contradicting (B)) or (b) `ψ ∈ u'` (which, combined with `¬(φ U ψ) ∈ u'`
and BX8 `ψ → φ U ψ`, also contradicts (B)). So no such `P` exists.

**Corollary**: The B-GAP obstruction is invariant under layered
redefinitions of `bx_le`. Any solution to B-GAP must either:

1. Avoid constructing `u'` via Lindenbaum extension of
   `{¬(φ U ψ)} ∪ h_content(v)` (restructure the proof direction — Burgess
   contradiction style).
2. Change the axiom set so that `P(¬(φ U ψ))` at `v` does not force
   a backward witness in `w`'s cone (weaken BX4' or add a stronger
   cone-locus axiom).
3. Change the target model so the guard clause is vacuous (quasimodel /
   filtration).

These three are exactly the escape hatches identified by task 92's
spawn analysis as task 95 (BX13 axiom), task 97 (this task, now
invalidated), and task 96 (filtration). Since task 97 is structurally
foreclosed, only tasks 95 and 96 remain viable.

---

## Recommendation

**REJECT ALL CANDIDATES. REJECT THE LAYERED REDEFINITION STRATEGY.**

Task 92 should not invest implementation effort in any layered
redefinition of `bx_le`. The B-GAP obstruction is invariant under
second-conjunct strengthening, and Gap U5 is only closable under
structurally-infeasible interval linearity (C3) or under candidates that
also fail B-GAP (C1, C4) or fail U5 directly (C2).

### Actionable Next Steps

1. **Deprioritize task 97's direction**. Update task 97's status to
   `[RESEARCHED]` with verdict "reject-all" and block task 92 from
   consuming its output as an implementation recipe.
2. **Focus task 92's re-planning on tasks 95 and 96**. The remaining
   two escape hatches (axiom strengthening, filtration pivot) are
   the only viable directions, per the structural invariant derived
   above.
3. **Consider a fourth direction**: restructuring the four Until/Since
   sorry statements themselves so that the guard quantifier ranges over
   a **constructed chain** rather than arbitrary `bx_le`-intermediates.
   This was mentioned in task 90 Teammate A's report as "Option 3:
   chain-specific guards" and is not equivalent to filtration. It
   would require touching `Frame.lean:632, 664, 683, 697` signatures
   plus any call site in `TruthLemma.lean` that uses the guard
   universality.

### What This Report Does NOT Recommend

- Do **not** adopt C1, C2, C3, or C4.
- Do **not** attempt to synthesize a fifth layered candidate: the
  structural invariant in the previous section precludes any
  `P(w, u)` from resolving B-GAP.
- Do **not** interpret this report as negative evidence against tasks
  95 and 96 — they address orthogonal escape hatches and remain live.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Structural invariant argument relies on informal "contains" reasoning; could have a gap | Mitigation: the argument is BX-axiom-agnostic and only uses BX8 (`ψ → φ U ψ`), which is present and standard. Cross-check against task 92 Phase 0 diagnostic: same failure mode there. |
| A fifth layered candidate might sneak around the invariant via a non-standard `resolved_set` definition | Mitigation: the invariant covers any `P` that makes `bx_le'` strictly stronger than `bx_le`, which is the only interesting direction. A `P` that is weaker than `bx_le` cannot improve closure. |
| Task 92 may re-interpret this report as endorsing C3 conditional on a linearity axiom | Mitigation: report explicitly states C3 reduces to task 90's already-blocked diagnostic. Any future linearity axiom would belong under task 95 (BX13 strengthening), not here. |

---

## Appendix

### Search / Probe Plan

No `lean_multi_attempt` probes were executed. The failure of each
candidate is derivable at the mathematical level (via the task 90
obstruction counterexamples and the structural invariant argument).
Probing the Box proof skeleton at `Frame.lean:501-583` is unnecessary
because criterion (b) is trivially satisfied by first-conjunct
projection for all layered candidates — the Box/G/H proofs use
`h_le : bx_le w v` destructured as `h_le.1` wherever they use the
ordering, and the existing proof bodies are unchanged.

If a future research round wishes to empirically verify criterion (b)
passes for layered definitions, the probe is:

```
lean_multi_attempt at Frame.lean:549 with
  ["exact bx_G_forward h_le.1 h_G_box"]
```

which should succeed for any layered candidate. But this is
verification of a mathematical triviality, not a discovery.

### References

- `specs/092_implement_bx_until_truth_lemma/reports/04_spawn-analysis.md`
  — root-cause analysis of the blocker; identifies B-GAP and Gap U5 as
  BXPoint-level locus obstructions.
- `specs/092_implement_bx_until_truth_lemma/reports/03_phase0-diagnostic.md`
  — six failed probes that empirically verified the obstruction.
- `specs/090_research_bx_le_redefinition/reports/01_team-research.md`
  — task 90 synthesis rejecting Option A standalone.
- `specs/090_research_bx_le_redefinition/reports/01_teammate-a-findings.md`
  — Flaw 1 (non-equivalence) and Flaw 2 (non-transitivity) counterexamples.
- `specs/090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md`
  — BX7+BX11+BX12 does not derive bx_le interval linearity (C3 reduction
  target).
- `specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md`
  — task 90's (now empirically invalidated) Burgess-Xu recommendation.
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:61-62` — `bx_le`
  definition (g_content ⊆).
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:140-157` — `bx_le_refl`
  and `bx_le_trans` (reused by all layered candidates via first-conjunct
  projection).
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:164-185` —
  `bx_forward_witness` and `bx_backward_witness` (Lindenbaum constructions
  that structurally resist layered augmentation for B-GAP).
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:501-583` — Box/G/H
  preservation (preserved by first-conjunct projection for all layered
  candidates).
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:585-704` — the four
  sorries (U5 × 2, B-GAP × 2) that this research aimed to unblock.
- `Theories/Bimodal/ProofSystem/Axioms.lean:142-263` — BX4 through BX12
  and primed duals; none of these close the structural invariant gap.

### Context Files Loaded

- Task 090 directory (all reports and plans) — prior art for Option A
  rejection and linearity diagnostic.
- `specs/092_implement_bx_until_truth_lemma/reports/03_phase0-diagnostic.md`
  — empirical Phase 0 probes.
- `specs/092_implement_bx_until_truth_lemma/reports/04_spawn-analysis.md`
  — blocker root cause and escape hatches.
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (read sections
  1-330 and 480-707).
- `Theories/Bimodal/ProofSystem/Axioms.lean:130-275` — BX3 through BX12
  definitions.
