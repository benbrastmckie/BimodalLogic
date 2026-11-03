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
| the Hit-level weakening of that hypothesis | seam interface | `HitPresented` |
| the weakening made explicit | seam interface | `hitPresented_of_presented` |
| (S): the `untl` clause from decidable per-edge data | B2b | `untl_iff_of_UCoh_ULive` |
| (S): the `snce` clause, proved outright | B2b | `snce_iff_of_SCoh_SLive` |
| (S): no `box` letter in a `box`/`stab`-free closure | B2b | `not_box_mem_plusSubformulaClosure` |
| (S): no `stab` letter either | B2b | `not_stab_mem_plusSubformulaClosure` |
| (S): a consistent presentation's paths are local runs | B2b | `cons_localRun` |
| (S): a run's trace is anchored to its history | B2b | `anchored_runTrace_of_boxStabFree` |
| (S): **the hypothesis DISCHARGED** for a constructed model | B2b | `presented_modelOf` |
| (S): its Hit-level corollary | B2b | `hitCl_modelOf_eq_hitOf` |
| (C), the general row: the headline | seam interface | `exists_hitPresented` |
| (C): the seam assembly, model-free | seam interface | `exists_periodic_subfamily` |
| (C): the composition law of the profile | seam interface | `profile_append_congr` |

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
presentation's runs — which this tree now discharges for a model
CONSTRUCTED from the presentation and for no other: constructing a regular model from a
presentation (HWZ 2000, Theorem 14 ⇐, for the `⊡` fibre) is requirement (S), landed in
`RaySummary/Realize.lean` for `box`/`stab`-free `φ` at ONE seam under the eleven-field bundle
`Cons` (`presented_modelOf`, `hitCl_modelOf_eq_hitOf`, pinned in the last section below), while
`Probe735.not_presented` continues to refute it for every finite presentation on a model not so
constructed. The wired probe `quasistate_does_not_determine_hit`
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

-- The file crosses the package-wide `longFile` limit (`lakefile.toml`, 1500): this is one
-- axiom-profile ledger for the summary layer and its requirement sections stay together, so the
-- `#guard_msgs` block for a declaration sits beside the prose that says what it certifies.
set_option linter.style.longFile 1800

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

/-! ## The run-level bridge and the liveness decider under `Presented` — conditional

`plusStab_iff_forall_run_of_presented` (`RaySummary/Trace.lean`) reads `⊡φ` at the seam, under
`Presented`, as the run-level condition that every run anchored at the seam time carries `clPhi φ`
at its `now` state; `onRun_iff_live` (`RaySummary/StabCheck.lean`) characterizes the states on
some anchored run as the `now` states live in both `now`-free step graphs, so that condition is
decided by `stabCheckSig`; `stabCheck_iff_of_presented` and `decidableStabOfPresented` compose
the two. These four rows pin the profiles of a **conditional** result, and `Presented` is refuted
as a completeness carrier by the wired probe
`specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` (`Probe735.not_presented`):
on fixture model A at the seam with `φ := Fp` no finite presentation satisfies it, so these four
rows are vacuous on that fixture, and the existing four rows above are vacuous on it for the same
reason. None of the four is a decision procedure for `⊡` on any model in the tree, and nothing
here mentions validity.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_run_of_presented' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_run_of_presented

/-- info: 'FormalSystem.Metalogic.WeakCanonical.onRun_iff_live' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.onRun_iff_live

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stabCheck_iff_of_presented' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stabCheck_iff_of_presented

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.decidableStabOfPresented' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.decidableStabOfPresented

/-! ## The Hit-level weakening of the hypothesis — satisfiable, with the size exhibited as a count

`HitPresented` (`RaySummary/Trace.lean`) is the **Hit-level weakening** of `Presented`: it demands
equality of the realized FAMILY-TRIPLE sets (`HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`)
rather than equality of the TRACE sets, and `hitPresented_of_presented` makes that weakening
explicit — `Presented` implies it at every depth `1 ≤ k`, by `hit_eq_hitOf_of_presented`
verbatim. The converse is not proved and is not expected.

Unlike the `Presented` rows above, these two are **not** vacuous on fixture model A. The
trace-level hypothesis has no inhabitant there for any finite presentation
(`specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`, `Probe735.not_presented`),
while the Hit-level one does, at every depth `1 ≤ k`: that discharge is
`Probe745.hitPresented_modelA` in the wired probe
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`, which this module cannot
import — probes sit outside the Lake build graph and are compiled by
`scripts/check-evidence-probes.sh` instead. The two facts hold side by side on the same fixture,
at the same seam, for the same `φ`, because trace-set equality is what the refutation reaches and
family-triple equality is not.

The probe's discharge reads `HitPresented … (labOf (presentationSize k)) (stepOf (presentationSize
k)) k` with `presentationSize k := Nat.card (KType (clSig Fp) k)` written into the statement — the
presentation size is EXHIBITED, as a COUNT of depth-`k` types over the closure alphabet of `Fp`,
and nothing else (the `anchorCells_ncard_le` disclaimer, in the same words: it is not a complexity
bound of any kind; it counts, it does not time anything, and it must not be described as a bound
on any procedure's running time). The four library rows after the first two pin what that
exhibition rests on: the pigeonhole periodicity of the `k`-type of a constant block with the
threshold and period bounded by that count (`kTypeOf_listSeg_replicate_eventually_periodic_bounded`,
`RaySummary/Compose.lean`, with its recorded unbounded corollary), the keystone that a segment
with the `k`-type of a nonempty constant block is a nonempty constant block
(`segZ_const_of_kTypeOf_eq_replicate`), and the cut surgery that deletes `p` positions of a run
held inside one segment of a `SegmentFactorization` while keeping the triple
(`inFamily_of_shrink_run`, both `RaySummary/Transport.lean`; shrink direction only, under an
explicit single-segment containment hypothesis that the probe discharges on model A). The
general every-model statement of (C) is the last section of this file (`exists_hitPresented`,
with its two load-bearing lemmas). Neither of the first two rows measures a
decidability result and neither mentions validity: `HitPresented` is one seam's hypothesis, and
`Decidable (PlusValidZTime φ)` is not stated in this tree in any form, conditional or otherwise.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.HitPresented' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.HitPresented

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.hitPresented_of_presented' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.hitPresented_of_presented

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_replicate_eventually_periodic_bounded' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms
  FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_replicate_eventually_periodic_bounded

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_replicate_eventually_periodic' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_replicate_eventually_periodic

/-- info: 'FormalSystem.Metalogic.WeakCanonical.segZ_const_of_kTypeOf_eq_replicate' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.segZ_const_of_kTypeOf_eq_replicate

/-- info: 'FormalSystem.Metalogic.WeakCanonical.inFamily_of_shrink_run' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.inFamily_of_shrink_run

/-! ## Requirement (S): the realization hypothesis DISCHARGED for a constructed model

The eight rows below pin the eight Goals of the B2b soundness construction
(`FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean`, plus the two closure-vacuity
lemmas in `FormalSystem/PlusLanguage/Subformulas.lean`). Unlike every `Presented` row above,
these are **not** conditional on a hypothesis nobody inhabits: the last two discharge
`Presented` itself, for a model CONSTRUCTED from the presentation.

**What these eight rows certify.** That each of the eight declarations is proved on the standard
profile `[propext, Classical.choice, Quot.sound]` with no `sorryAx` — nothing more. An axiom
profile is not a statement about what a theorem says, so none of the eight rows certifies the
scope, and the scope is where this construction is restricted.

**What they do NOT certify, stated here rather than left to be inferred.**

* **Not validity.** `Decidable (PlusValidZTime φ)` is not stated in the tree in any form, and
  `hitCl_modelOf_eq_hitOf` is not a step toward it: it speaks of ONE seam `(τ, t)` of ONE
  constructed model. Requirements (C) and (S) of the `RaySummary/README.md` verdict together
  still speak of one seam; the lift to validity is requirement (W), open.
* **Not the whole language.** `presented_modelOf` and `hitCl_modelOf_eq_hitOf` carry
  `hφ : φ.BoxStabFree`. On `box`/`stab`-bearing `φ` the construction is degenerate by a named
  mechanism — `frameOf`'s step relation is time-constant, so `modelOf`'s `box` anchor is
  time-invariant and its `stab` letters collapse (`plusStateLocal_stab_iff`'s semantic half) —
  and that fragment is assigned to requirement (W), not claimed here.
* **Not a refutation of the refutation.** `Probe735.not_presented` refutes `Presented` for every
  finite presentation on fixture model A, which is NOT constructed from a presentation. (S)
  quantifies the other way. Both stand; neither retires the other, and both wired probes stay.
* **No complexity bound**, upper or lower, for the construction, for `hitOf`, or for the
  decidable `Cons` checks. The `Cons` conditions are decidable on a `[Fintype Q]` and are
  exercised by `#guard`s in `KTypeFinEvalTest.lean` at the probe fixture size only, as witnesses
  of computability and nothing else.
* **No finite-fibre and no finite-width assumption.** The only finiteness in any of the eight
  statements is `[Fintype Q]` on the PRESENTATION; the constructed model's carrier `ℤ × Q` is
  infinite (`frameOf_not_finite_worldState`), so `not_finite_width_fmp` is not contradicted.
* **Nothing backward by symmetry.** `snce_iff_of_SCoh_SLive` is proved outright and is not
  transported from `untl_iff_of_UCoh_ULive`; no backward Bool-fixture bridge exists in this tree.

**One note on `cons_localRun`'s premise.** `Cons` carries **eleven** fields, not the ten the
plan enumerated. The eleventh, `nowUnique`, was derived from `presented_modelOf`'s own
obligation rather than assembled with the rest: without it the other ten admit two mutually
unreachable `now`-marked components, whose splices through a seam cannot cover the whole run
set. It is documented at the field, and `cons_localRun` does not read it.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.untl_iff_of_UCoh_ULive' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.untl_iff_of_UCoh_ULive

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.snce_iff_of_SCoh_SLive' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.snce_iff_of_SCoh_SLive

/-- info: 'FormalSystem.PlusLanguage.not_box_mem_plusSubformulaClosure' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.PlusLanguage.not_box_mem_plusSubformulaClosure

/-- info: 'FormalSystem.PlusLanguage.not_stab_mem_plusSubformulaClosure' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.PlusLanguage.not_stab_mem_plusSubformulaClosure

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cons_localRun' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cons_localRun

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.anchored_runTrace_of_boxStabFree' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.anchored_runTrace_of_boxStabFree

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.presented_modelOf' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.presented_modelOf

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.hitCl_modelOf_eq_hitOf' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.hitCl_modelOf_eq_hitOf

/-! ## Requirement (C), the general row (`RaySummary/Profile.lean`, `Periodic.lean`,
`HitComplete.lean`)

Three pins. `exists_hitPresented` is the completeness half of the run layer for EVERY regular
`ℤ`-model: at every seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled
presentation with `Fintype.card Q ≤ sizeBound φ k` satisfies `HitPresented M τ t φ lab step k`,
and `sizeBound φ k = N ^ 3 * (4 * P ^ 2 + 1)` — `N` depth-`k` types over the closure alphabet,
`P` their profiles — is EXHIBITED in the statement: a count of types and profiles, not a
complexity bound of any kind. The two load-bearing lemmas are pinned beside it:
`profile_append_congr`, the composition law of the σ-star profile of a finite word (the summary
that composes under the Kleene star of a type where bare `k`-types do not), and
`exists_periodic_subfamily`, the model-free seam assembly (every family triple of a colouring
with `now` exactly at `t` is realized by a bounded bi-ultimately-periodic colouring whose own
triples all belong to the original's). What they do not say: `Decidable (PlusValidZTime φ)` in
any form — one seam of one model; the lift is requirement (W) — nothing about `⊡(Pp)`, and no
retirement of `Probe735.not_presented`, which refutes the trace-level `Presented` that this
Hit-level theorem does not use. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented

/-- info: 'FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily

/-- info: 'FormalSystem.Metalogic.WeakCanonical.profile_append_congr' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.profile_append_congr

/-! ## Requirement (W): the anchor layer (`PlusTruth.lean`, `RaySummary/AnchorLayer.lean`)

Nineteen pins, one per Goal of the (W) anchor-layer plan: the quantifier collapse
`box_time_invariant` / `box_global` (`PlusTruth.lean`; `□ψ` is a per-model datum on every
`TaskFrame`), the closure types and cells (`tpOf`, `mem_tpOf_iff`, `tpOf_timeShift`, `cellAt`,
`cellAt_eq_cellAt`), the four fixpoint equations (`bot_not_mem_tpOf`, `imp_mem_tpOf_iff`,
`box_mem_tpOf_iff`, `stab_mem_tpOf_iff`), the finite object and its completeness for EVERY
model (`anchorCells`, `AnchorCons`, `anchorCons_anchorCells` — no presentation, no finiteness,
no regularity hypothesis), the finiteness and the bound (`anchorCells_finite`,
`anchorCells_ncard_le`), and the decidable checker on a concrete finite object (`AnchorConsFin`,
`decidableAnchorConsFin`, `anchorConsFin_iff`).

**What these pins certify, and what they do not.** They certify the standard axiom profile
`[propext, Classical.choice, Quot.sound]` on each declaration and nothing else. They certify no
claim about `PlusValidZTime`: the anchor layer is the half of requirement (W) the semantics lets
one state on every model, and the run layer — the `untl`/`snce` nesting, the lift from one seam
to validity — is BLOCKED on three named obligations (`RaySummary/README.md`, "(W): what landed
and what did not"). `decidableAnchorConsFin` is an instance on a `Finset (Finset (Finset
PlusFormula))` literal and decides nothing about any model; `anchorCells_ncard_le` counts cells
and is not a complexity bound. -/

/-- info: 'FormalSystem.PlusLanguage.box_time_invariant' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.PlusLanguage.box_time_invariant

/-- info: 'FormalSystem.PlusLanguage.box_global' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.PlusLanguage.box_global

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.mem_tpOf_iff' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.mem_tpOf_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_timeShift' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf_timeShift

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cellAt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_eq_cellAt' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cellAt_eq_cellAt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.bot_not_mem_tpOf' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.bot_not_mem_tpOf

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.imp_mem_tpOf_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.imp_mem_tpOf_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.box_mem_tpOf_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.box_mem_tpOf_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_mem_tpOf_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stab_mem_tpOf_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.anchorCells' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.anchorCells

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.AnchorCons' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.AnchorCons

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.anchorCons_anchorCells' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.anchorCons_anchorCells

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.anchorCells_finite' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.anchorCells_finite

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.anchorCells_ncard_le' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.anchorCells_ncard_le

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.AnchorConsFin' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.AnchorConsFin

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.decidableAnchorConsFin' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.decidableAnchorConsFin

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.anchorConsFin_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.anchorConsFin_iff

/-! ## Requirement (W): the run layer's frame scheme (`RaySummary/RunLayer.lean`)

Twenty pins, one per Goal of the (W) run-layer frame-scheme plan: the branching core
transcribed from the wired probe `b2b-frame-constructor-branching.lean` (`FwdFinBranch`,
`BwdFinBranch`, `iterS_fwd_finite`, `iterS_bwd_finite`, `fib_finite_of_finBranch`,
`saturation_of_finBranch`), the parallel constructor with `[Finite W]` replaced by two-sided
finite branching in its one `Saturation` slot (`ofSlicedStepFinBranch`,
`ofSlicedStepFinBranch_isRegular`, `ofSlicedStepFinBranch_step`,
`ofSlicedStepFinBranch_not_finite_worldState`, `ofSlicedStepFinBranch_mem_HF_iff`), the deadline
ladder (`Drift`, `Count`, `Rlad`, `Rlad_fwd`, `Rlad_bwd`, `Rlad_slice_infinite`) and the frame it
yields (`ladderFrame`, `ladderFrame_isRegular`, `ladderFrame_step`). Eleven further pins, in the
section after this one, cover `RaySummary/LadderModel.lean` beside the ladder's: the record that
`ladderFrame`'s own seriality hypotheses are unsatisfiable (`no_fwd`, `no_bwd_of_idle`), the
admissibility set and carrier (`Adm`, `LadderState`, `ladderState_nonempty`), the restricted
relation with its branching (`RladAdm`, `RladAdm_fwd`, `RladAdm_bwd`), and the frame and model on
the admissible carrier (`ladderFrameAdm`, `ladderFrameAdm_isRegular`, `ladderModel`).

**What these pins certify, and what they do not.** They certify the standard axiom profile
`[propext, Classical.choice, Quot.sound]` (or no axioms at all, for the five definitions
`FwdFinBranch`, `BwdFinBranch`, `Drift`, `Count`, `Rlad`) on each declaration and nothing else.
They certify no claim about `PlusValidZTime`: the frame scheme is the regularity part of the run
layer's first obligation, with `[Finite Q]` on the OBJECT only and an infinite slice
(`Rlad_slice_infinite`); no realization theorem is pinned because none exists (the run layer's
phase 2, open), nothing is pinned about `HitPresented`, and no pin is a complexity bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.FwdFinBranch' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.FwdFinBranch

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.BwdFinBranch' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.BwdFinBranch

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.iterS_fwd_finite' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.iterS_fwd_finite

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.iterS_bwd_finite' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.iterS_bwd_finite

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.fib_finite_of_finBranch' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.fib_finite_of_finBranch

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.saturation_of_finBranch' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.saturation_of_finBranch

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch_isRegular' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch_isRegular

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch_step' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch_step

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch_not_finite_worldState' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
-- linter.style.longLine: the fully qualified name makes this `#print axioms` line 104 characters,
-- and the line cannot be broken (the command takes one identifier). Deleting the suppression makes
-- the linter's warning part of the captured message, so `#guard_msgs` fails on a correct profile.
set_option linter.style.longLine false in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch_not_finite_worldState

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch_mem_HF_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ofSlicedStepFinBranch_mem_HF_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Drift' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.Drift

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Count' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.Count

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Rlad' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.Rlad

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Rlad_fwd' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.Rlad_fwd

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Rlad_bwd' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.Rlad_bwd

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Rlad_slice_infinite' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.Rlad_slice_infinite

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame_isRegular' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame_isRegular

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame_step' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ladderFrame_step

/-! ## Requirement (W): the admissible ladder carrier (`RaySummary/LadderModel.lean`)

Eleven pins, one per declaration of the module. `no_fwd` and `no_bwd_of_idle` record that
`ladderFrame`'s own seriality hypotheses are unsatisfiable — for every object, and for every
object with an idle state — so `Adm` (`{c | pend q = false → c = 0}`) is a restriction of the
CARRIER; `LadderState` is that carrier with `ladderState_nonempty` its inhabitant; `RladAdm` is
`Rlad` on the underlying triples with `RladAdm_fwd`/`RladAdm_bwd` pulled back along
`Subtype.val`; `ladderFrameAdm` is the frame through `ofSlicedStepFinBranch` with
`ladderFrameAdm_isRegular`, and `ladderModel` the model whose valuation reads the object
component only.

**What these pins certify, and what they do not.** The standard profile
`[propext, Classical.choice, Quot.sound]` or a strict subset of it (`no_bwd_of_idle` is
`[propext]`, `ladderState_nonempty` is `[Classical.choice]`, and the three definitions `Adm`,
`LadderState`, `RladAdm` carry no axiom at all) on each declaration, and nothing else. No
realization theorem is pinned because none exists: the stabilization of `ladderModel`'s cells in
the counter pair is refuted by the wired probe `ladder-cell-refutation.lean`, no index of a
ladder cell is claimed, nothing is pinned about `HitPresented` or `PlusValidZTime`, and no pin is
a complexity bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.no_fwd' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.no_fwd

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.no_bwd_of_idle' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.no_bwd_of_idle

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Adm' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.Adm

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LadderState' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.LadderState

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ladderState_nonempty' depends on axioms: [Classical.choice] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ladderState_nonempty

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.RladAdm' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.RladAdm

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.RladAdm_fwd' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.RladAdm_fwd

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.RladAdm_bwd' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.RladAdm_bwd

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ladderFrameAdm' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ladderFrameAdm

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ladderFrameAdm_isRegular' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ladderFrameAdm_isRegular

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.ladderModel' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.ladderModel

/-! ## Requirement (W): the definitional layer of the ladder's realization statement
(`RaySummary/LadderRealize.lean`)

Three pins, one per declaration of the module: `typeOfCl`, the projection out of the landed
closure component `ClType`; `certChain`, the bi-infinite certificate chain over the product
carrier `Q × ClType φ × CK Tc Tn P B` (`relK` between consecutive positions, `certLocK` at every
position, and the two temporal obligations read as formula membership in the closure component);
and `LadderCons`, the consistency bundle — `certAdmK` on a candidate set together with the
maximality clause `Dmax ⊆ R`, the acceptance conditions `certStabK` and `certBoxK` included
through `certAdmK` and never dropped.

**What these pins certify, and what they do not.** The standard profile
`[propext, Classical.choice, Quot.sound]` on each of the three declarations, and nothing else.
All three are DEFINITIONS: the module holds no theorem, so no pin here is a realization theorem,
a soundness claim, or a lift. Nothing is pinned about `HitPresented` or `PlusValidZTime`, no
index of a ladder cell is claimed at any parameters, `certChain` carries no `⊡`-nesting-depth
stratification, and no pin is a complexity bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.typeOfCl' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.typeOfCl

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.certChain' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.certChain

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LadderCons' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.LadderCons

/-! ## Requirement (W): the rigid anchors of a ladder history
(`RaySummary/LadderAgree.lean`)

Twenty-two pins, one per declaration of the module. `stab_mem_tpOf_iff_cell` is the cell-level
reading of the `⊡` bit of a realized type. The rest are the RIGID ANCHORS of a ladder history and
the accessors they are stated at: the four readings of `Count` along a path
(`cntAt_succ_of_pend_pend`, `cntAt_eq_zero_of_pend_idle`, `cntAt_eq_nxtAt_of_idle_pend`,
`cntAt_eq_zero_of_idle`), the rigid pending region (`cntAt_sub_of_pend`, `not_pend_of_count`,
`cntAt_add_of_pend_back`), the rigidity of the countdown under a fixed object walk
(`cntAt_eq_of_obj_eq`), and the window the `1`-Lipschitz next-deadline register imposes with its
dichotomy (`nxtAt_lipschitz`, `cntAt_le_nxtAt_succ_of_idle_past`, `pend_past_of_nxtAt_lt`), and
the reading of a class collision of the counter quotient off its coordinates
(`kappa_eq_components`, `eq_or_both_ge_of_min_eq`, `clipIdx_regime_of_eq` — at `2 ≤ B` a collision
at a fixed next deadline cannot straddle the two regimes).

**What these pins certify, and what they do not.** The standard profile or a strict subset of it
on each declaration — `[propext, Classical.choice, Quot.sound]` on `stab_mem_tpOf_iff_cell`,
`[propext, Quot.sound]` or `[propext]` on the anchor theorems, and no axiom at all on the four
definitions and the three one-line projections — and nothing else. They do NOT pin the agreement
of class-equivalent cells: that statement is not landed, and the module's own docstring records
the three obstructions on its record. Nothing is pinned about `HitPresented` or `PlusValidZTime`,
no index of a ladder cell is claimed at any parameters, no certificate object is named, and no pin
is a complexity bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_mem_tpOf_iff_cell' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stab_mem_tpOf_iff_cell

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.objAt' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.objAt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.nxtAt' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.nxtAt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.IsLadderPath' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.IsLadderPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.isLadderPath_components' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.isLadderPath_components

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.objAt_step' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.objAt_step

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_zero_of_idle' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_zero_of_idle

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_drift' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_drift

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_succ_of_pend_pend' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_succ_of_pend_pend

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_zero_of_pend_idle' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_zero_of_pend_idle

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_nxtAt_of_idle_pend' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_nxtAt_of_idle_pend

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_sub_of_pend' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_sub_of_pend

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.not_pend_of_count' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.not_pend_of_count

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_of_obj_eq' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_of_obj_eq

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_lipschitz' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_lipschitz

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_add_of_pend_back' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_add_of_pend_back

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_le_nxtAt_succ_of_idle_past' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_le_nxtAt_succ_of_idle_past

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pend_past_of_nxtAt_lt' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pend_past_of_nxtAt_lt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_eq_components' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.kappa_eq_components

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.eq_or_both_ge_of_min_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.eq_or_both_ge_of_min_eq

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.clipIdx_regime_of_eq' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.clipIdx_regime_of_eq

/-! ## Requirement (W): the pumping replacement, admissibility half
(`RaySummary/LadderAgree.lean`)

Twenty-four further pins, one per declaration of the module's replacement layer. The segment: a
pending region at least as long as the object count carries an object cycle
(`objCycleLens_of_segment`, `exists_objCycle_of_card_le_cnt`) whose length divides `P + 1` under
`(K1)` (`objCycle_dvd_succ_of_paramsOk`, `exists_pumpSeg_of_card_le_cnt`), so repeating it leaves
the residue coordinate of `kappa` fixed. The surgery: `spliceObj`/`spliceCnt` and their four
accessors, the segment's interior (`spliceSeg`), the step relation of the spliced walk
(`spliceObj_step`), the three local readings of `Count` on the spliced countdown
(`spliceCnt_idle`, `spliceCnt_pend_pend`, `spliceCnt_pend_idle`) and the payoff
(`spliceCnt_add_of_mem_region`, `spliceObj_eq_of_le`, `spliced_at_region`) — the countdown at a
position of the region moves by EXACTLY the cycle length while the object state stays put, the
move `cntAt_eq_of_obj_eq` forbids on a fixed walk. The lift: `exists_ladderPath_of_walk` repackages
`RunLayer.lean`'s `exists_rlad_hist_of_walk` on the admissible carrier, and
`exists_spliced_ladderPath` applies it to the splice under the pin side condition. The side
condition's necessity and its discharge: `nxtAt_lipschitz_two_sided` and
`pinCompat_of_ladderPath` (the region-start countdowns of EVERY ladder path are pairwise
compatible, so the condition is forced and not an artefact), and
`spliceObj_pend_of_lt_of_pend_past`/`exists_spliced_ladderPath_of_pend_past` (in the
pending-forever-into-the-past regime the spliced walk's region starts are the original's
displaced by the cycle length, so the condition discharges and the surgery is unconditional).

**What these pins certify, and what they do not.** The standard profile or a strict subset of it
on each declaration, and nothing else. They pin the ADMISSIBILITY half of the pumping
replacement: the surgery exists, it is a ladder path, and it moves the countdown by a divisor of
`P + 1`. They do NOT pin preservation of the realized TYPE under the surgery — the model-level
half, which is not landed and which the module's own docstring records as the standing
obstruction — and they therefore do NOT pin the agreement of class-equivalent cells. In the
regime where the side condition is not discharged the surgery is available only under that
condition, whose discharge is the cascade the parameter condition `(K2)` sizes. Nothing is pinned
about `HitPresented` or `PlusValidZTime`, no index of a ladder cell is claimed at any parameters,
no certificate object is named, and no pin is a complexity bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.objCycleLens_of_segment' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.objCycleLens_of_segment

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_objCycle_of_card_le_cnt' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_objCycle_of_card_le_cnt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.objCycle_dvd_succ_of_paramsOk' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.objCycle_dvd_succ_of_paramsOk

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_pumpSeg_of_card_le_cnt' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_pumpSeg_of_card_le_cnt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceObj' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceObj

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_of_lt' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_of_lt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_of_ge' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_of_ge

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_of_lt' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_of_lt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_of_ge' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_of_ge

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceSeg' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceSeg

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_step' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_step

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_idle' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_idle

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_pend_pend' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_pend_pend

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_pend_idle' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_pend_idle

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_add_of_mem_region' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceCnt_add_of_mem_region

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_eq_of_le' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_eq_of_le

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_lipschitz_two_sided' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_lipschitz_two_sided

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pinCompat_of_ladderPath' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pinCompat_of_ladderPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_of_walk' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_of_walk

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_spliced_ladderPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_spliced_ladderPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliced_at_region' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliced_at_region

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_pend_of_lt_of_pend_past' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_pend_of_lt_of_pend_past

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_spliced_ladderPath_of_pend_past' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_spliced_ladderPath_of_pend_past

/-! ## Requirement (W): the type layer of the replacement — the bridge and the clause audit
(`RaySummary/LadderAgree.lean`)

Seventeen further pins, one per declaration of the module's type layer. The two TEMPORAL fixpoint
readings of a closure type, which the anchor layer does not land (`untl_mem_tpOf_iff`,
`snce_mem_tpOf_iff`): with the anchor layer's `⊥`, `→`, `□` and `⊡` equations they are the local
coherence conditions the type sequence along a path satisfies. The BRIDGE between the two layers
the module speaks in — a ladder path is an offset step path of `RladAdm` at every offset because
`Rlad` ignores its time argument (`isSlicedStepPath_iff_isLadderPath`), every ladder path is a
world history of the ladder frame (`exists_hist_of_isLadderPath`) and every world history is a
ladder path up to its origin's offset (`exists_isLadderPath_of_hist`), so the cell of a ladder
state is exactly what the ladder paths through it realize, with no offset left over
(`mem_cellAt_ladder_iff`). The INDEX MAPS of the splice: the retraction along which the spliced
walk is the original (`spliceIdx`, its two readings, `spliceObj_eq_objAt_spliceIdx`) and the order
embedding it retracts (`spliceEmb`, `spliceEmb_monotone`, `spliceIdx_spliceEmb`). And the CLAUSE
AUDIT of what a replacement argument owes: the `□` letters transfer under every replacement
whatsoever because their bit names no path (`box_mem_tpOf_transfer`), and the ATOMIC letters read
the object walk at the position and nothing else (`atom_mem_tpOf_ladder_iff`), so they transfer
whenever the object at the position does (`atom_mem_tpOf_transfer_of_objAt_eq`) — which
`spliceObj_eq_of_le` says the splice arranges.

**What these pins certify, and what they do not.** The standard profile or a strict subset of it
on each declaration, and nothing else. They pin the TYPE-LEVEL STATEMENT LAYER of the replacement
and the two clause families that transfer for free; they do NOT pin any transfer of a temporal
letter or of a `⊡` letter across the splice, and they do not pin the agreement of
class-equivalent cells, which is not landed. `spliceIdx_seam_lt` is pinned as an OBSTRUCTION
record, not as a step of a proof: the retraction drops back by the block length at the seam, so a
temporal witness found in the second copy of the pumped block retracts to a position that need not
be later than the position being evaluated, and the index maps alone therefore do not transport
`untl_mem_tpOf_iff`'s right-hand side. Nothing here is a finite-fibre or finite-width hypothesis,
no certificate object is named, and no pin is a complexity bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.untl_mem_tpOf_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.untl_mem_tpOf_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.snce_mem_tpOf_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.snce_mem_tpOf_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.box_mem_tpOf_transfer' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.box_mem_tpOf_transfer

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx_of_lt' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx_of_lt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx_of_ge' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx_of_ge

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_eq_objAt_spliceIdx' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceObj_eq_objAt_spliceIdx

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceEmb' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceEmb

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceEmb_monotone' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceEmb_monotone

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx_spliceEmb' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx_spliceEmb

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx_seam_lt' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.spliceIdx_seam_lt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.isSlicedStepPath_iff_isLadderPath' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.isSlicedStepPath_iff_isLadderPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_hist_of_isLadderPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_hist_of_isLadderPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_isLadderPath_of_hist' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_isLadderPath_of_hist

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_ladder_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_ladder_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.atom_mem_tpOf_ladder_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.atom_mem_tpOf_ladder_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.atom_mem_tpOf_transfer_of_objAt_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.atom_mem_tpOf_transfer_of_objAt_eq

/-! ## Requirement (W): the truth-transport layer, half (i)
(`RaySummary/LadderAgree.lean`)

Eleven further pins, one per declaration of the module's transport layer. The `⊡`-nesting depth
and the pinned-letter predicate (`stabDepth`, `StabPinned`) with the three facts an induction on
that depth steps by (`stabDepth_stab`, `stabDepth_arg_le_of_le_succ`, `stabDepth_le_sup` — the
depth is bounded on a closure by a `φ`-determined quantity, so the induction terminates) and the
two bridges to the hypothesis the transport statements take (`stabPinned_of_stabDepth_le`,
`stabPinned_false_of_mem_closure`). Then HALF (i) itself: two ladder paths with the SAME object
walk satisfy the same closure formulas at every position, for every formula whose `⊡` letters are
pinned (`truthAt_iff_of_objAt_eq_of_stabPinned`), its reading on closure types
(`tpOf_eq_of_objAt_eq_of_pinned`) and the stab-free instance (`tpOf_stabFree_eq_of_objAt_eq`). And
its NON-VACUITY (`exists_ladderPath_pair_nxtAt_ne`): `cntAt_eq_of_obj_eq` fixes the countdown from
the walk, but the next-deadline register only has to drift, so two ladder paths can share an object
walk and differ at every position in `n` — the pair half (i) transports between.

**What these pins certify, and what they do not.** The standard profile or a strict subset of it
on each declaration, and nothing else. Half (i) is stated RELATIVE to the pinned-letter parameter,
which is what an induction on `⊡`-nesting depth can consume; the stab-free statement is its
instance and not its shape. These pins do NOT certify half (ii), splice invariance: no statement
here transports a type between paths with DIFFERENT object walks, which is what pumping produces,
and the agreement of class-equivalent cells remains unlanded. No certificate object and no
certificate-side periodicity identifier is named anywhere in the module, no finite-fibre or
finite-width hypothesis appears, and no pin is a complexity bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stabDepth' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stabDepth

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.StabPinned' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.StabPinned

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stabDepth_stab' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stabDepth_stab

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stabDepth_arg_le_of_le_succ' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stabDepth_arg_le_of_le_succ

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stabDepth_le_sup' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stabDepth_le_sup

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stabPinned_of_stabDepth_le' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stabPinned_of_stabDepth_le

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stabPinned_false_of_mem_closure' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stabPinned_false_of_mem_closure

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.truthAt_iff_of_objAt_eq_of_stabPinned' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.truthAt_iff_of_objAt_eq_of_stabPinned

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_of_objAt_eq_of_pinned' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_of_objAt_eq_of_pinned

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_stabFree_eq_of_objAt_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf_stabFree_eq_of_objAt_eq

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_pair_nxtAt_ne' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_pair_nxtAt_ne

/-! ## Requirement (W): the alternative-history construction
(`RaySummary/LadderAgree.lean`)

Ten further pins, one per declaration of the module's alternative-history layer. The
CONSTRUCTION (`altWalkPath`) and its three accessor readings (`objAt_altWalkPath`,
`cntAt_altWalkPath`, `nxtAt_altWalkPath`): a walk agreeing with a ladder path's PEND PROFILE at
every position carries that path's `cntAt` and `nxtAt` verbatim, the admissibility side condition
transporting through the pend equality alone. Its LADDER-PATH property
(`altWalkPath_isLadderPath`): the `step` clause is the hypothesis and the other three clauses of
`Rlad` transfer with the original's own counters, because each of them reads the object only
through `pend`. Its POSITIONWISE STATE IDENTITY (`altWalkPath_eq_of_objAt_eq`): at every position
the relabelling leaves alone the alternative path is at the IDENTICAL ladder state, not merely a
class-equivalent one, with no finiteness in the statement. The CELL-LEVEL COROLLARY
(`mem_cellAt_of_altWalkPath`): the cell at a ladder state contains the type realized by every
pend-profile-preserving relabelling of every path through it. And NON-VACUITY
(`altPend_altW'`, `exists_altLadderPath`, `altWalkPath_not_vacuous`): a three-state object, a
ladder path with a real pending region, a relabelling that moves one PENDING position, and the
compiled fact that the alternative path differs from the original there — so the corollary is not
a restatement of `mem_cellAt_ladder_iff`.

**What these pins certify, and what they do not.** The standard profile or a strict subset of it
on each declaration, and nothing else. They certify a construction that ENLARGES a cell, not one
that preserves a type: nothing here says the alternative history realizes the SAME type as the
original, and in general it does not. These pins are therefore NOT a repair of half (ii), which
is refuted rather than open, and they are not a conditional, positionwise-narrowed or
raised-`Tc` restatement of it. The agreement of class-equivalent cells remains unlanded. No
certificate object and no certificate-side periodicity identifier is named anywhere in the
construction, no finite-fibre or finite-width hypothesis appears, and no pin is a bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.altWalkPath' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.altWalkPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.objAt_altWalkPath' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.objAt_altWalkPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_altWalkPath' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_altWalkPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_altWalkPath' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_altWalkPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.altWalkPath_isLadderPath' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.altWalkPath_isLadderPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.altWalkPath_eq_of_objAt_eq' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.altWalkPath_eq_of_objAt_eq

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.altPend_altW'' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.altPend_altW'

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_altLadderPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_altLadderPath

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.altWalkPath_not_vacuous' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.altWalkPath_not_vacuous

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_altWalkPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_altWalkPath

/-! ## Requirement (W): the atom-valuation closure agreement
(`RaySummary/LadderAgree.lean`)

Seven further pins, one per declaration of the module's atom-valuation transport layer. The NARROW
FRAGMENT (`StabBoxFree`) and its restriction to a closure with no `⊡` and no `□` member
(`stabBoxFree_of_mem_closure`): `StabPinned`'s shape with the `box` arm tightened to `False` and
the pinned-letter parameter dropped, since the narrow fragment asks nothing of the letter inside a
`□` and excludes the letter outright. Then the TRANSPORT itself at the weaker hypothesis
(`truthAt_iff_of_lab_eq_of_stabBoxFree`, with `tpOf_stabBoxFree_eq_of_lab_eq` on closure types):
two ladder paths whose object walks carry the SAME ATOM ROW at every position satisfy the same
stab-free, box-free closure formulas at every position. The hypothesis is POINTWISE `lab`
agreement, not object-walk equality — the latter is half (i), and these pins are not a second
pinning of it. Then the WIDENED form (`truthAt_iff_of_lab_eq_of_stabPinned`, with
`tpOf_stabFree_eq_of_lab_eq` its stab-free type-level instance): the `box` arm widens, because the
`box` clause quantifies over all histories and all times of the model and the two compared
histories live in the SAME model, so nothing has to be excluded. And the INSTANCE over the
alternative-history construction (`tpOf_eq_of_altWalkPath_of_lab_eq`): a pend-profile-preserving
relabelling that leaves every atom row alone realizes the same stab-free closure type as the
original.

**What these pins certify, and what they do not.** The standard profile or a strict subset of it
on each declaration, and nothing else. They certify a transport whose hypothesis is weaker than
half (i)'s by exactly the non-injectivity of `lab`, and nothing more: the relabelling may move the
object state at a position, but no statement here moves that state's ATOM ROW. These pins are
therefore NOT a repair of half (ii), which is refuted rather than open — the refuted statement is
about the SPLICE, which lengthens a pending region and changes which positions exist, and no
hypothesis here constrains such a surgery. They are not a conditional, positionwise-narrowed or
raised-`Tc` restatement of it either. The agreement of class-equivalent cells remains unlanded: no
statement here mentions `kappa`, a counter class or a cell's constancy on one. No certificate
object and no certificate-side periodicity identifier is named anywhere in the layer, no
finite-fibre or finite-width hypothesis appears, and no pin is a bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.StabBoxFree' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.StabBoxFree

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stabBoxFree_of_mem_closure' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stabBoxFree_of_mem_closure

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.truthAt_iff_of_lab_eq_of_stabBoxFree' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.truthAt_iff_of_lab_eq_of_stabBoxFree

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_stabBoxFree_eq_of_lab_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf_stabBoxFree_eq_of_lab_eq

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.truthAt_iff_of_lab_eq_of_stabPinned' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.truthAt_iff_of_lab_eq_of_stabPinned

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_stabFree_eq_of_lab_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf_stabFree_eq_of_lab_eq

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_of_altWalkPath_of_lab_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_of_altWalkPath_of_lab_eq

/-! ## Requirement (W): the countdown rigidity of the atom-valuation agreement, and the obligation
of the depth-`0` cell-level agreement

The pins below are the eight declarations the cell-level route's own question landed. Four are the
RIGIDITY: `cntAt_eq_of_pend_eq` (the countdown is a function of the PEND PROFILE alone — the proof
of `cntAt_eq_of_obj_eq` at the hypothesis it actually consumes, with `cntAt_eq_of_obj_eq` left
exactly as it stands), `PendFactorsLab` and `pendFactorsLab_of_atom` (the pending bit factors
through the atom row, which happens as soon as the labelling carries the pending bit as one of its
atoms), and `cntAt_eq_of_lab_eq_of_pendFactorsLab` (under that condition the atom-valuation
transport cannot move a countdown anywhere). Two are the CONSTRUCTION the route named and its
refutation: `AtomPreservingCountMove` and `atomPreservingCountMove_refuted`. Two are the
OBLIGATION and the fact that its hypothesis is never empty: `CellLEZeroConstOfKappaEq`, stated as a
schema and proved nowhere, and `kappa_eq_of_shift`, by which `kappa`-collisions with `c ≠ c'` exist
at every parameter tuple whatsoever.

**What these pins certify, and what they do not.** A strict subset of the standard profile on each
declaration, and nothing else. They certify that the ONE construction the cell-level route named is
unavailable for every object whose pending bit is readable in the language — and the realization
statement quantifies over every `lab`, so no such object is excluded. The pin on
`CellLEZeroConstOfKappaEq` certifies the schema's axiom profile only, never its truth value: the
schema is a definition, and its REFUTATION at the parameter conditions the obligation was filed
against (the probe's frozen `ParamsOkPre`, whose `(K4)` reads the backward exactness depth alone)
is carried by the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`
(`Probe836A.cellLEZeroConstOfKappaEqPre_refuted`, with non-vacuity on both sides as the conjuncts of
`Probe836A.exists_refuting_cell_collision`), through the register's forward window rather than
through the atom row. The two refutations are different facts: a cell is a set of TYPES over all
histories through a state, so two ladder paths can realize the same closure type without agreeing
on a single atom row, and the construction's unavailability says nothing about the obligation.
No construction that preserves the realized type without preserving the valuation pointwise is
stated anywhere in the tree. No pin here mentions
`ladderSound`, `ladderLift`, `ladderRealized` or the filed `cellAt_const_of_kappa_eq`; half (i) and
the atom-valuation agreement are untouched and both still hold at their own hypotheses; no
certificate object is named; no finite-fibre or finite-width hypothesis appears; and no pin is a
bound. The wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` carries the
non-vacuity on both sides. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_of_pend_eq' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_of_pend_eq

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.PendFactorsLab' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.PendFactorsLab

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pendFactorsLab_of_atom' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pendFactorsLab_of_atom

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_of_lab_eq_of_pendFactorsLab' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cntAt_eq_of_lab_eq_of_pendFactorsLab

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.AtomPreservingCountMove' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.AtomPreservingCountMove

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.atomPreservingCountMove_refuted' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.atomPreservingCountMove_refuted

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_eq_of_shift' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.kappa_eq_of_shift

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.CellLEZeroConstOfKappaEq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.CellLEZeroConstOfKappaEq

/-! ## Requirement (W): the type-preserving pump layer (`RaySummary/LadderPump.lean`)

The pins below are the deletion admissibility layer, the mirror of the splice layer pinned
above: the deletion index map `delIdx` (a definition; no axioms), the payoff
`delCnt_sub_of_mem_region` (at every position whose region reaches the deleted block the forced
countdown is the original's minus the block's length, exactly), and the admissibility half
`exists_deleted_ladderPath_of_pend_past` (in the pending-forever regime the deleted walk lifts to
a ladder path with no pin side condition, through `exists_ladderPath_of_walk` with the pins above
the block displaced by `-l`).

**What these pins certify, and what they do not.** The standard profile on each declaration,
and nothing else. They certify that the surgery is a ladder path; nothing here says the realized
TYPE is preserved — that is the type half of the layer, pinned separately. No certificate object
is named, no finite-fibre or finite-width hypothesis appears, no pin is a bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.delIdx' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.delIdx

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.delCnt_sub_of_mem_region' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.delCnt_sub_of_mem_region

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_deleted_ladderPath_of_pend_past' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_deleted_ladderPath_of_pend_past

end BimodalTest.Metalogic
