/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary
import FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization
import FormalSystem.Metalogic.Decidability.RaySummary
import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti

/-!
# Axiom-profile evidence for the `k`-type summary substrate

This module is **permanent evidence**, not a conventional test, on the pattern of
`PeriodicExtensionAxiomTest.lean`. The `KTypeSummary/` cluster is Büchi's complementation chain
transposed to monadic `k`-types over the `ℤ` time axis, and every headline theorem of that chain
is stated in the tree as proved on the **standard profile** `[propext, Classical.choice,
Quot.sound]` with no `sorryAx`. A claim of that shape kept only in prose rots the moment anyone
edits a proof; here each is pinned with `#guard_msgs` + `#print axioms`, so a red build is the
signal that a profile moved.

## What is pinned

| Row | Chain step | Guard |
|---|---|---|
| infinite Ramsey for pairs, the Ramsey ingredient | 4 | `Nat.exists_strictMono_const_pair_colour` |
| its in-tree alias | 4 | `infinite_ramsey_pairs` |
| the summary alphabet is finite | 2 | `kType_finite` |
| a block is the sum of its segments | 3′ | `kEquiv_zFiber_segSum` |
| the Ramsey cover | 4 | `family_cover`, `exists_matching_factorization` |
| saturation core | 5a | `kEquiv_zFiber_of_matching_segments`, `kTypeOf_zFiber_eq_of_sameTriple` |
| saturation proper, finite-family cover | 5b | `family_saturation`, `target_eq_union_of_families` |
| the `⊡` bridge (seam interface) | — | `plusStab_iff_seamSummary` |
| every depth-`≤ k` sentence target is `k`-type-determined | 5b | `determinedByKType_eval` |
| the single-family bundle is seam decidedness | seam interface | `exists_presents_iff` |
| the hypothesis-free `⊡` bridge over `Hit` | seam interface | `plusStab_iff_forall_hit` |
| the multi-family bridge | seam interface | `plusStab_iff_presentsMulti` |
| the multi-family bundle, inhabited | seam interface | `presentsMulti_seamTrace` |
| B3a: the computable `k`-type is the classical one | 1′ | `kTypeOfFin_eq` |
| B3b: composition on representatives | 1′ | `kTypeOf_listSeg_append_congr` |
| B1: the `⊡` bridge over any finite signature | seam interface | `plusStab_iff_forall_hitSig` |
| B2a: the closure trace is an anchored local run | seam interface | `clTrace_localRun` |
| B2a: an anchored run is the closure trace | seam interface | `eq_clTrace_of_localRun_anchored` |
| B3b: the computable `hitOf`, characterized | seam interface | `mem_hitOf_iff` |
| the realization hypothesis | seam interface | `Presented`, `presented_localRun` |
| the per-model bridge under it | seam interface | `hit_eq_hitOf_of_presented` |
| the `⊡` bridge over `hitOf` under it | seam interface | `plusStab_iff_forall_hitOf_of_presented` |

Rows for the later steps are appended as their modules land.

## What this does **not** pin, and why

Nothing here measures a decidability result, because the cluster proves none: saturation is
proved for `k`-type-determined targets over coloured `ℤ`-blocks. The seam interface states the
`⊡` bridge over the realized family triples **without** a hypothesis bundle
(`plusStab_iff_forall_hit`, `RaySummary/SeamMulti.lean`; its signature-generic form
`plusStab_iff_forall_hitSig`, `RaySummary/Closure.lean`), and the realizability device beside it
is pinned above exactly as far as it reaches: the computable `k`-type of a finite segment
(`kTypeOfFin_eq`, `KTypeSummary/KTypeFin.lean`), composition on representatives
(`kTypeOf_listSeg_append_congr`, `RaySummary/Compose.lean`), the trace of a history as the unique
anchored local run over the closure alphabet (`clTrace_localRun`,
`eq_clTrace_of_localRun_anchored`, `RaySummary/Trace.lean`), the computable realized-triple set
`hitOf` of a finite labelled presentation with its characterization (`mem_hitOf_iff`,
`RaySummary/HitOf.lean`), and the per-model bridge `hit_eq_hitOf_of_presented`, under which a
seam's `HitCl` **is** `hitOf`. That bridge is **conditional** on the realization hypothesis
`Presented` — the closure traces of the seam's splices are exactly the traces of the
presentation's runs — which this tree discharges for **no** non-trivial model: constructing a
regular model from a presentation (HWZ 2000, Theorem 14 ⇐, for the `⊡` fibre) is a successor
record, and the wired probe `quasistate_does_not_determine_hit`
(`specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean`) is the
machine-checked reason the hypothesis must carry joint realization through the seam rather than
per-time quasistate data. So "`Hit` computed" is never the claim: `hitOf` is computable on
presentations (`KTypeFinEvalTest.lean` runs it), a seam's `HitCl` is the image of its ray pairs
under the trace map (`hitCl_eq_iUnion` — a theorem, not a computation, since `SeqPair` is not
finite), and `presentsMulti_seamTrace`'s `Bool` is still `decide` under `open Classical`. The
single-family bundle `Presents` is, by `exists_presents_iff`, inhabited exactly when the seam is
`⊡`-decided — a seam condition, not a reduction. Every result is under `[F.IsRegular]` over the
`ℤ` time axis in the L⁺ language; the cited fixtures are forward-only, and no backward
Bool-fixture bridge exists. A green build of this file therefore certifies the axiom profiles,
not adequacy and not decidability.

## When one of these guards fires

The expected block is updated **in the same commit as the change that moved it**, with the move
justified there — never on its own to turn a red build green. A profile that has grown an axiom
outside the standard three, or that reports `sorryAx`, is a regression to investigate, not an
expectation to rewrite.
-/

namespace BimodalTest.Metalogic

/-! ## Step 4's ingredient: infinite Ramsey for pairs

The `Classical.choice` here is genuine and expected: the proof builds a descending chain of
infinite sets by `Exists.choose` and picks the infinitely-often colour by a second pigeonhole.
-/

/-- info: 'Nat.exists_strictMono_const_pair_colour' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms Nat.exists_strictMono_const_pair_colour

/-- info: 'FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs

/-! ## Step 2: the summary alphabet is finite -/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kType_finite' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.kType_finite

/-! ## Step 3′: a block is the ordered sum of its segments

The `Classical.choice` is inherited from `k_equiv_of_iso` and the order-isomorphism machinery
(`StrictMono.orderIsoOfSurjective`); nothing about the chain adds to it.
-/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kEquiv_zFiber_segSum' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.kEquiv_zFiber_segSum

/-! ## Step 4: the Ramsey cover

Infinite Ramsey for pairs is applied twice, once per orientation of the time axis; the
`Classical.choice` is the one the Ramsey ingredient already carries.
-/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.family_cover' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.family_cover

/-- info: 'FormalSystem.Metalogic.WeakCanonical.exists_matching_factorization' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.exists_matching_factorization

/-! ## Step 5a: the saturation core

Assembly of the segment-sum lemma and the mixing lemma; the `Classical.choice` is theirs.
-/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kEquiv_zFiber_of_matching_segments' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.kEquiv_zFiber_of_matching_segments

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kTypeOf_zFiber_eq_of_sameTriple' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.kTypeOf_zFiber_eq_of_sameTriple

/-! ## Step 5b: saturation for `k`-type-determined targets

These two rows pin saturation **for targets determined by the block's `k`-type** and nothing
more: no decidability result is measured here because the cluster proves none, and no claim that
any `⊡` condition is such a target is made anywhere in the tree. The `Classical.choice` is the
Ramsey cover's.
-/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.family_saturation' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.family_saturation

/-- info: 'FormalSystem.Metalogic.WeakCanonical.target_eq_union_of_families' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.target_eq_union_of_families

/-! ## The seam interface: the `⊡` bridge

`plusStab_iff_seamSummary` is stated against the hypothesis bundle `Presents` and discharges
nothing; its profile inherits `Classical.choice` through `plusStab_iff_omega`'s
`FrameOver.worldHistoryOfStepPath` (the `PeriodicExtensionAxiomTest.lean` precedent for a
choice-carrying row), so a profile here that *lost* `Classical.choice` would be a welcome
measurement to record, not a defect. What it certifies is the axiom profile of the bridge — not
that any seam is ever presented.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_seamSummary' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_seamSummary

/-! ## Step 5b, sentence level: every depth-`≤ k` sentence target is `k`-type-determined

`determinedByKType_eval` is `determinedByKType_nfEval` lifted through Doets's Lemma 1.1
(`doets_lemma_1_1`); it is the shape in which the seam interface's `determined` field is
discharged for an arbitrary sentence target. The `Classical.choice` is `doets_lemma_1_1`'s.
-/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.determinedByKType_eval' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.determinedByKType_eval

/-! ## The seam interface, corrected: the characterization and the hypothesis-free bridge

`exists_presents_iff` pins the obstruction — the single-family bundle is inhabited iff the seam
is `⊡`-decided — and `plusStab_iff_forall_hit` pins the bridge that needs no bundle: `⊡φ` at
the seam iff the two-letter target holds on every block of every realized family triple. The
multi-family bundle's bridge `plusStab_iff_presentsMulti` and its inhabitant
`presentsMulti_seamTrace` are pinned beside them. What a green build certifies is the four
profiles — not that `Hit` is computed (it is not; the device rows below say exactly what is),
not a decision procedure, not decidability.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_presents_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_presents_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hit' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hit

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_presentsMulti' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_presentsMulti

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.presentsMulti_seamTrace' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.presentsMulti_seamTrace

/-! ## The realizability device, B3a and the composition half of B3b

`kTypeOfFin_eq` says the computable `k`-type of a finite decidable structure is the library's
classical `kTypeOf` (which is `Classical.dec` by design), and `kTypeOf_listSeg_append_congr` is
composition on representatives — the `k`-type of a concatenation of label lists depends only on
the `k`-types of the parts, the two-point instance of the mixing lemma
`kEquiv_orderedSum_of_kEquiv_colour`. The `Classical.choice` is `kTypeOf`'s and
`k_equiv_of_iso`'s. That the *definitions* `kTypeOfFin`, `listSeg` and `hitOf` nonetheless
evaluate is witnessed by `KTypeFinEvalTest.lean`, not here.
-/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kTypeOfFin_eq' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.kTypeOfFin_eq

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_append_congr' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_append_congr

/-! ## B1 and B2a: the closure alphabet, and the trace as the unique anchored local run

`plusStab_iff_forall_hitSig` is the hypothesis-free `⊡` bridge over an arbitrary finite
signature with distinguished `now`/`phi` letters and any trace map anchored by them; the
two-letter `plusStab_iff_forall_hit` above is its instance. `clTrace_localRun` is the soundness
half of HWZ 2000's Theorem 14 in the direction that reads types off a model (the closure trace
of a history satisfies every local run condition) and `eq_clTrace_of_localRun_anchored` its
uniqueness half (an anchored local run over the closure alphabet is the trace of its history).
Theorem 14 ⇐ — a model from a colouring — is absent from this tree. The `Classical.choice` is
the seam machinery's, through `plusStab_iff_omega`.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hitSig' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hitSig

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.clTrace_localRun' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.clTrace_localRun

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.eq_clTrace_of_localRun_anchored' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.eq_clTrace_of_localRun_anchored

/-! ## The read-out half of B3b, and the per-model bridge under `Presented`

`mem_hitOf_iff` characterizes the computable `hitOf` of a finite labelled presentation as exactly
the family triples of its runs' traces, at every anchor and every depth `1 ≤ k` — a statement
about presentations, with no model in it. `Presented` is the realization hypothesis (the seam's
closure traces are exactly the presentation's run traces), `presented_localRun` shows the run
conditions are inherited under it, and `hit_eq_hitOf_of_presented` /
`plusStab_iff_forall_hitOf_of_presented` are the per-model bridge and the `⊡` bridge under it.
These four rows pin the profiles of a **conditional** result: the hypothesis is discharged for
no non-trivial model, the corollary decides nothing, and the `Classical.choice` enters as in
every seam row above.
-/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.mem_hitOf_iff' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.mem_hitOf_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Presented' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.Presented

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.presented_localRun' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.presented_localRun

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.hit_eq_hitOf_of_presented' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.hit_eq_hitOf_of_presented

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hitOf_of_presented' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hitOf_of_presented

end BimodalTest.Metalogic
