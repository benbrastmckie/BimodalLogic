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
-- The baseline is raised one chunk at a time, as the ledger grows; the `longFile` linter requires
-- the value to be at least the file's length and refuses a value more than one chunk above it.
set_option linter.style.longFile 3900

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

/-! ## The anchor-free lift

`exists_ladderPath_of_walk`'s anchor slot `hn₀` is REDUNDANT: a walk whose pin family is pairwise
compatible already determines a `Drift` register through those pins, and that register's value at
`0` witnesses the anchor. `drift_lipschitz_two_sided` is the `Drift`-level Lipschitz fact the
discharge reads (the counterpart of `nxtAt_lipschitz_two_sided`, which is the same fact on a
ladder path's own deadline register), and `exists_ladderPath_of_walk_of_pins` is the lift with the
slot dropped. The anchored form is NOT superseded in the tree: every landed consumer still reads
it, and both pins below stand beside its own rather than replacing it. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.drift_lipschitz_two_sided' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.drift_lipschitz_two_sided

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_of_walk_of_pins' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_of_walk_of_pins

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
that depth steps by. `stabDepth` itself is declared in `RaySummary/CounterQuotient.lean`, not in
the transport module: `(K2)`'s margin conjunct and `Tcof` both read
`(plusSubformulaClosure φ).sup stabDepth`, and the transport module imports the parameter layer
rather than the other way round. The measure is purely syntactic, so the home makes no difference
to what it says, and its namespace is unchanged. The three facts (`stabDepth_stab`,
`stabDepth_arg_le_of_le_succ`, `stabDepth_le_sup` — the
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
schema is a definition, it is proved nowhere and claimed by nothing — and no regime-restricted
variant of it is claimed either, because the schema concludes cell EQUALITY and only the UPWARD
inclusion is landed (`cellAt_subset_of_shift_of_pend_past`). The pin layer's two halves pinned
below bear on it without closing it: the DICHOTOMY splits every pending position into the pin-free
side the upward inclusion already consumes and the backward window's side, and the PIGEONHOLE over
region starts produces, from a pin COUNT in a window, the type-respecting block SPANNING a pin that
the downward inclusion would need — whose length `(K1)` provably does not constrain, since both
cycle-length conjuncts carry `pending throughout` on the walk they quantify. The `(K2)` pin beside
them is the EXPONENTIAL reading of that conjunct (`two_pow_card_prodState_le_Tc`), which is the
quantity such a pigeonhole consumes. Its REFUTATION at the parameter conditions the obligation was
filed against (the probe's frozen `ParamsOkPre`, whose `(K4)` reads the backward exactness
depth alone) is carried by the wired probe
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

/-! ## Requirement (W): the type half of the pump layer (`RaySummary/LadderPump.lean`)

The pins below are the TYPE lemmas of the pump layer: duplicating or deleting a block whose two
ends carry the same object state and the same realized stab-free type preserves the realized
type at EVERY position, read through the block's index map (`spliceIdx` for the duplication,
`delIdx` for the deletion). Each is the `L := fun _ => False` instance of a pinned-letter
transport proved at the truth level by one induction per clause, with the temporal clauses
routed through the endpoint equality of the block's ends. HWZ 2000 Lemma 17 is the deletion
form; the duplication form is its mirror.

**What these pins certify, and what they do not.** The standard profile on each declaration,
and nothing else. They certify the type half of each surgery under no pending-region hypothesis,
no `ParamsOk` and no pin condition. No certificate object is named, no finite-fibre or
finite-width hypothesis appears, no pin is a bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_spliceIdx_of_tpOf_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_spliceIdx_of_tpOf_eq

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_delIdx_of_tpOf_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_delIdx_of_tpOf_eq

/-! ## Requirement (W): the forward window and the type pigeonhole (`RaySummary/LadderPump.lean`)

`nxtAt_le_cntAt_add_of_next_region` is the FORWARD window of the next-deadline register — the
register at a position is at most the countdown there plus the next idle run plus the next
region's start countdown — the mirror of the landed backward window
`cntAt_le_nxtAt_succ_of_idle_past` and the quantity `(K4)`'s forward conjunct dominates.
`exists_typeBlock_of_budget_le_cnt` is the `(objAt, tpOf)` pigeonhole: a region of countdown at
least `|Q| · 2^|cl φ|` carries a type-respecting block of length at most that budget. The
standard profile on each, and nothing else; no certificate object is named, no pin is a
complexity bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_le_cntAt_add_of_next_region' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_le_cntAt_add_of_next_region

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_typeBlock_of_budget_le_cnt' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_typeBlock_of_budget_le_cnt

/-! ## Requirement (W): the realized-chain bridge (`RaySummary/LadderChain.lean`)

`realized_typeBlock_mem_prodCycleLens`: a type-respecting block of a pending region, of length
at most the budget, read as a periodic walk on `(objAt, tpOf)` pairs, is a `cohIdle`-cycle of
the certificate graph through saturated pending classes, so its length is in `prodCycleLens`;
`typeBlock_length_dvd_of_paramsOk`: hence it divides `P + 1` under `(K1)`. These pins read the
LOCAL half of the certificate layer only — no certificate-SET object — which is the mechanical
form of the module's distance from the recorded circularity. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.realized_typeBlock_mem_prodCycleLens' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.realized_typeBlock_mem_prodCycleLens

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.typeBlock_length_dvd_of_paramsOk' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.typeBlock_length_dvd_of_paramsOk

/-! ## Requirement (W): `(K2)` as an exponential lower bound (`RaySummary/LadderChain.lean`)

`two_pow_card_prodState_le_Tc`: `(K2)` bounds `Tc` below by `2 ^ Fintype.card (ProdState Q φ)`,
an EXPONENTIAL in the product carrier's cardinality and not the cardinality itself, because
`cascadeBound` carries that power as a factor. This is the quantity a pigeonhole over the REGION
STARTS of a doubling chain consumes, where the weaker `budget_le_Tc` beside it is the
linear-in-the-carrier reading of the same conjunct. The standard profile. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.two_pow_card_prodState_le_Tc' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.two_pow_card_prodState_le_Tc

/-! ## Requirement (W): the regime-A assembly (`RaySummary/LadderChain.lean`)

`exists_ladderPath_through_shifted_of_pend_past`: through a pending-forever path's state at
countdown at least `Tc`, a ladder path with the countdown raised by exactly `m · (P + 1)`, the
register and the object state held, and the same realized stab-free type.
`cellAt_subset_of_shift_of_pend_past`: hence the UPWARD inclusion of cells along the
common-shift chain in the pending-forever regime. ONE direction only; the downward inclusion is
not claimed, and the depth-`0` cell obligation under `ParamsOk` is neither proved nor refuted by
these pins. `hasForwardSlack_zero`: the forward-slack regime's BASELINE is free — amount `0` holds
on every ladder path from the register's Lipschitz bound alone — and the two transports around it
are exact (`hasForwardSlack_raise` adds exactly the raise, `hasForwardSlack_del` spends exactly
the deletion), so the regime is not itself a source of slack. The standard profile on the two
assembly pins, and `propext` with `Quot.sound` alone — below the standard profile — on the
baseline, which consumes no choice. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_through_shifted_of_pend_past' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_ladderPath_through_shifted_of_pend_past

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_shift_of_pend_past' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_shift_of_pend_past

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.hasForwardSlack_zero' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.hasForwardSlack_zero

/-! ## Requirement (W): the cell level (`RaySummary/LadderCell.lean`)

`cellAt_subset_of_common_shift_of_pend_past`: the UPWARD cell inclusion along the COMMON-SHIFT
chain — the sub-regime `cellAt_subset_of_shift_of_pend_past`'s docstring names and does not
state, with the register carried up by the same multiple of `P + 1` as the countdown. ONE
direction only, exactly as for the register-held sub-regime: no downward inclusion is claimed by
either, and the depth-`0` cell obligation under `ParamsOk` is neither proved nor refuted by these
pins. `kappa_collision_regimes`: the collision case split, over arithmetic facts rather than over
cells, with THREE branches — equal register, common shift, and a SATURATED gap coordinate that
neither inclusion addresses. `kappa_collision_two_regimes_refuted`: the compiled refutation of
the two-branch form as a consequence of the collision destructors together with `(K4)`'s
`2 ≤ B`, which is why the third branch is carried; it refutes that derivation alone and asserts
nothing about the two-branch form under full `ParamsOk`. The standard profile on the two
positive results, and `propext` with `Quot.sound` alone — below the standard profile — on the
refutation, which consumes no choice. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_common_shift_of_pend_past' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellAt_subset_of_common_shift_of_pend_past

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_regimes' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_regimes

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_two_regimes_refuted' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_two_regimes_refuted

/-! ## Requirement (W): the FORWARD-SLACK-RESTRICTED depth-`0` cell obligation
(`RaySummary/LadderCell.lean`)

THE UNRESTRICTED OBLIGATION IS STILL OPEN. `CellLEZeroConstOfKappaEq` — pinned above as a schema
proved nowhere — is, under `ParamsOk`, neither proved nor refuted, and the reserved name
`cellLE_zero_const_of_kappa_eq` is still claimed by nothing. The pins below do not change that:
they pin a STRICTLY STRONGER statement, which bears on the unrestricted schema's truth value in
neither direction.

THE RESTRICTED FORM IS PROVED. `CellLEZeroConstOfKappaEqForwardSlack` is the obligation with four
hypotheses added, and `cellLE_zero_const_of_kappa_eq_of_forwardSlack` is a THEOREM of it at every
parameter tuple `ParamsOk` admits. The four: the EQUAL-REGISTER restriction `n = n'`; the
pending-forever gap at both pairs; the threshold bounds `Tc ≤ c` and `Tc ≤ c'` at both pairs; and
the FORWARD-SLACK WITNESSING of whichever pair carries the higher countdown, at exactly the
displacement separating the two. It concludes cell EQUALITY, the relation its name advertises —
the upward half is the landed `cellAt_subset_of_shift_of_pend_past`, the downward half is
`cellAt_subset_of_shift_of_pend_past_rev`, and `Set.Subset.antisymm` closes it.

WHAT THE RESTRICTION COSTS, COMPILED. `cellAt_subset_of_shift_of_pend_past_rev` lifts the landed
path-level `mem_cellAt_of_shift_of_hasForwardSlack_exact` to the state level through
`ForwardSlackWitnessed` — every type the higher cell realizes is realized there by SOME path with
forward slack — which is existential over paths and so untouched by the climbing-register
refutation `ClimbWitness.hasForwardSlack_refuted_unconditional`; no state-level form of the regime
exists. `kappa_collision_two_regimes_refuted_of_pend_gap` is why the EQUAL-REGISTER hypothesis is
carried rather than dispatched away: at `Tc = Tn = P = 0`, `B = 2` the pairs `(2, 0)` and `(4, 1)`
collide inside the pending-forever regime with both countdowns above the threshold, the registers
differ, and no single multiple of `P + 1` displaces both coordinates — so the saturated-gap branch
of `kappa_collision_regimes` survives the regime restriction, and no landed inclusion addresses it
in either direction. That refutation, like its sibling above, is scoped to the derivation from the
collision destructors and `2 ≤ B`, and asserts nothing under full `ParamsOk`.

WHY THE WITNESSING HYPOTHESIS IS CARRIED RATHER THAN DISCHARGED, COMPILED — AND WHERE THE
REFUTATION ACTUALLY BITES. A normalization lemma — every type realized at the upper state is
realized there by SOME path with forward slack — would discharge `ForwardSlackWitnessed` outright
and so drop the fourth hypothesis. The one candidate route to it was to LENGTHEN the idle run
between the compared position's region and the first region start above it, which supplies exactly
the amount the deletion's anchor clause is short by. That route splits THREE ways, and the split
is the substance rather than a refinement of wording: the MECHANISM is a theorem, and what is
refuted is the universal availability of its premise and the freedom of its increment.

The UNRESTRICTED schema is REFUTED, not merely unproved, and the obstruction is one level below
the pin condition, in `step` itself: a ladder path's object walk satisfies
`step (objAt g v) (objAt g (v + 1)) = true` at every position, so an idle run of length two
requires an idle-to-idle edge in the object's own step graph, and an object admitted by `ParamsOk`
need not have one — the two-state object with exactly that edge missing is serial in both
directions and carries a path satisfying every hypothesis of the lengthening while admitting no
lengthened path at all. (The refuting object is the standalone prototype
`idle-gap-lengthening.lean` in the task record that landed this layer — `idleGapLengthening_refuted`
in namespace `Probe838C` — not a wired probe, so it is not pinned here.) The refutation closes
from `step` alone and never reaches the type clause, so it says nothing about whether a lengthened
path, where one exists, holds the realized stab-free type.

The FREED-INCREMENT form is refuted too, and separately — the restriction to the multiples of the
repeat length is a necessity, not a convenience. `idleGapLengtheningAllIncrements_refuted`
(`LadderIdle.lean`) exhibits a three-state object whose idle states carry a `2`-cycle and no
self-loop, so every idle run has EVEN length and the run of length `4` that MEETS the run-repeat
premise at `k = 2` — both ends of the block at the same idle state, with the same realized type —
admits no lengthening to `5`.

The SHARPENED form is a THEOREM, and that is the correction this section carries.
`idleGapLengtheningOfIdleRunRepeat_holds` (`LadderIdle.lean`) lengthens the run under a RUN-LOCAL
premise — a block of the idle run whose two ends carry the same object state and the same realized
type — with the increment restricted to the multiples of the repeat length. Its pin clause does
not merely loosen but DISCHARGES OUTRIGHT, through `idleSplice_pins` (`LadderPump.lean`), which
carries no regime hypothesis and no side condition. So the idle run's length is a datum of the
object rather than a parameter the construction may raise — but WHERE the object supplies a
repeat, the construction may raise it by any multiple of the repeat length, and that is enough to
discharge the witnessing hypothesis conditionally (see the disposition in the next section).

None of the three refutes the depth-`0` obligation or any `ParamsOk` conjunct, and what IS pinned
here is the restricted form of the cell obligation that the still-carried hypothesis forces.

WHAT A CONSUMER MUST SUPPLY to use the restricted form: at each state it inducts through, the
register equality across the collision and a forward-slack witness at the higher state. Neither is
a consequence of `ParamsOk`.

THE TWO ROUTES LEFT OPEN, named rather than claimed: a `(K1)` amendment constraining the length of
a type-respecting block that spans a region start — which `(K1)` does not do, compiled, see the pin
layer's section below — and a REGISTER-LOWERING deletion, the common-shift mirror of
`mem_cellAt_of_shift_of_hasForwardSlack_exact` carrying the register DOWN by the same multiple of
`P + 1` as the countdown. The latter would buy the common-shift sub-regime's downward direction and
so drop the equal-register hypothesis on the first branch of the case split; it would NOT reach the
saturated residue.

The standard profile on the three positive declarations, and `propext` with `Quot.sound` alone —
below the standard profile — on the refutation, which consumes no choice. No certificate object is
named, no finite-fibre or finite-width hypothesis appears, and no pin is a bound. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_shift_of_pend_past_rev' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_shift_of_pend_past_rev

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.CellLEZeroConstOfKappaEqForwardSlack' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.CellLEZeroConstOfKappaEqForwardSlack

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellLE_zero_const_of_kappa_eq_of_forwardSlack' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellLE_zero_const_of_kappa_eq_of_forwardSlack

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_two_regimes_refuted_of_pend_gap' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms kappa_collision_two_regimes_refuted_of_pend_gap

/-! ## Requirement (W): the forward-slack witnessing hypothesis is NOT DISCHARGEABLE by the
pin-layer route (`RaySummary/LadderChain.lean`, `RaySummary/LadderCell.lean`,
`RaySummary/CounterQuotient.lean`)

THE VERDICT, stated and not left tacit. `ForwardSlackWitnessed` is STILL A HYPOTHESIS on all five
depth-`0` cell-equality schemas. The route recorded in this section — the deletion above the
compared position's region — is REFUTED at the pin layer rather than merely unproved;
`ForwardSlackWitnessed` itself is an existential over paths and is therefore neither discharged
nor refuted. The reserved name
`cellLE_zero_const_of_kappa_eq` remains claimed by nothing, confirmed by an exact-name sweep over
`FormalSystem/` and not by inference from the pins below.

THE DISPOSITION OF THE FRONTIER, recorded here rather than left to be re-derived. Four things are
true together and none of them may be read as any of the others.

* `ForwardSlackWitnessed` is UNCHANGED as a carried hypothesis: it still sits on all five
  depth-`0` cell-equality schemas of `LadderCell.lean`, every consumer must still supply it, and
  no schema's signature moved.
* The pin-layer route is UNCHANGED as refuted. Everything below this paragraph stands.
* A SECOND ROUTE EXISTS, is cascade-free, and is CONDITIONAL.
  `forwardSlackWitnessed_of_cell_idleRunPumpable` (`RaySummary/LadderIdle.lean`, pinned below)
  concludes `ForwardSlackWitnessed` at EVERY amount `l` from an amount-free run-local premise
  `IdleRunPumpable`, through `hasForwardSlack_of_idleRunRepeat` (also pinned below). It deletes
  nothing, so neither `hanch` nor `hstraddle` arises and none of `(K2)`'s `cascadeBound` is spent;
  the one surgery is the duplication of an idle block inside the idle run SEPARATING the compared
  position's region from the next one, whose pin clause `idleSplice_pins` discharges
  unconditionally. The regime asks `K ≤ n + cntAt g z + I - l` and the free two-sided Lipschitz
  bound already gives `K ≤ n + cntAt g z + I`; the pump leaves `K` put and raises `I`, so the
  deficit is paid out of the pumped run. `IdleRunPumpable` is NOT `ParamsOk`-derivable — `(K1)`
  quantifies `prodCycleLens`, `objCycleLens` and `satPeriod` and never `idleCycleLens`, and
  `idle_run_lt_tIdle_of_no_idleCycle` is the bound the other way — so the theorem RESTRICTS the
  obligation rather than removing it.
* THE FRONTIER IS NOW ONE NAMED SUB-REGIME: the paths whose intervening idle run has length `1`,
  where no repeat block exists to pump. That side is open and is claimed in neither direction;
  the route-space closure behind the narrowing is the wired probe
  `specs/evidence/forward-slack-pin-cascade/route-space-closure.lean`.

THE ROUTE, AND WHY IT FAILS. The route was: delete a type-respecting block inside the FIRST
REGION ABOVE the compared position's own region while holding the register at that position, then
iterate to drive that region's countdown below `tShort Q φ`, at which point the regime holds for
free. The route is the mirror of the already-refuted idle-run LENGTHENING recorded in the section
above, and it fails one level HIGHER: not in `step`, but in the pin layer's own compatibility
condition.

Its deletion primitive `exists_deleted_ladderPath_of_next_region_nxt` LANDED, pinned below. It
takes exactly two clauses as hypotheses — `hanch` for the pins at or above the block, `hstraddle`
for the pairs that straddle it — and discharges everything else internally through the two pull
lemmas `del_pin_pull_of_lt`/`del_pin_pull_of_ge`, also pinned. Both remaining clauses are
NON-DISCHARGEABLE from the pending-forever regime at countdown at least `Tc` together with
`ParamsOk`: `hanch` short by exactly `l`, `hstraddle` short by exactly `2 * l`, where `l` is the
deleted block's length. The obstruction is not an elaboration failure. On a path whose straddling
pin pair SATURATES pin compatibility the primitive's own CONCLUSION is false, because any deleted
path would itself be a ladder path and `pinCompat_of_ladderPath` would bind its pins at exactly
the broken positions. The deletion leaves the undisplaced pins' VALUES put while shortening every
later pin's distance by `l`, and additionally lowers by `l` the value of the pin whose region
swallows the block; a configuration already at the bound breaks by exactly what the deletion
removes.

`(K2)`'s BUDGET CANNOT PAY FOR IT, and that is the substantive finding rather than a side remark.
`cascadeBound`'s own recurrence `a (k + 1) ≤ 2 * a k + J + 1` is the bound the saturated
configuration ATTAINS WITH EQUALITY, so the budget DESCRIBES the obstruction rather than
dominating it. Two structural facts close the remaining escapes: `Adm pend q` places no upper
bound on a pending state's countdown, so a saturated register is admissible at every scale; and
every `ParamsOk` conjunct the thresholds enter is a LOWER bound on a parameter, never an upper
bound on a path quantity.

THE COMPILED RECORDS, wired rather than asserted.
`specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean` is in
`scripts/check-evidence-probes.sh`'s `WIRED` list: it carries the obstruction as a theorem
(`no_deleted_ladderPath_of_straddle_break`), realizes the saturated configuration as a concrete
two-state ladder path in the regime (`obs`), and refutes the deletion at EVERY block that path's
next region admits (`obs_no_admissible_block`). The scale-invariance of the deficit — that
`Tc ≤ cntAt g z` and `(K3)`'s `2 * tShort + tIdle + 2 ≤ Tc` are among the available facts and
still do not close it — is the arithmetic half, recorded in the task artifact
`phase-5-gate-measurement.lean` rather than as a wired probe, so it is not pinned here.

THE NAMED CONSEQUENCE FOR `Real`, AND IT IS PROVISIONAL RATHER THAN PERMANENT. Because the
hypothesis is not derivable by this route and stays carried, `certStabK` — the one `Real`
condition that consumes the agreement of class-equivalent cells, and the only one of the six not
claimed — must be RESTATED rather than proved, for as long as that remains the case. The word
PROVISIONAL is load-bearing and is not a hedge: the restatement obligation is blocked on a
condition that IS dischargeable on the pumpable side by
`forwardSlackWitnessed_of_cell_idleRunPumpable`, not on one refuted outright, so it is expected to
lift if and when the `I = 1` side closes — and it is NOT recorded here as permanent. Nothing below
claims `certStabK`, and nothing below consumes the agreement or the schema
`CellLEZeroConstOfKappaEq`.

WHAT DID LAND, and what each piece buys. Three things of unconditional value, independent of the
verdict:

* **The regime is now a CHECKABLE condition on one region, not an opaque condition on a register.**
  `next_region_cnt_le_of_hasForwardSlack` and its converse-bearing
  `hasForwardSlack_iff_next_region_cnt_le` turn `HasForwardSlack` into a bound on the countdown of
  the first region start above the compared position's region; `hasForwardSlack_amount_le` reads
  off the amount bound the regime forces. `forwardSlackWitnessed_iff_next_region_cnt_le` lifts the
  restatement to the CELL level. None of the four is a discharge: each converts the hypothesis's
  shape, and all four leave it a hypothesis.
* **Three scoping records.** `pend_succ_of_fwd` with `objCycleLens_nonempty_of_pend`, and
  `paramsOk_inflate` — which inflates `P` to `j * (P + 1) - 1` for any `0 < j`, so a displacement
  argument may take any multiple of `P + 1` without re-deriving `ParamsOk`, PROVIDED the inflated
  modulus still fits under `(K2)`'s margin conjunct. That proviso is the lemma's explicit `hroom`
  hypothesis and not a consequence of the parameter conditions: the margin is linear in `P`, so
  inflating by `j` multiplies the requirement by `j`. `paramsOk_inflate_raise`, pinned in the
  margin section at the end of this file, is the unconditional sibling that pays for the inflation
  by raising `Tc` and `Tn` with `P`.
* **The deletion primitive itself**, usable wherever `hanch` and `hstraddle` are supplied from
  OUTSIDE the pending-forever regime. Its signature carries `hnz : nxtAt g z ≤ cntAt g z` as an
  admitted hypothesis, measured necessary by compiling the proof with and without it; `hnz` is
  free at a consumer carrying the pending-forever gap `n + 2 ≤ c`, so it costs such a consumer
  nothing.

WHAT A CONSUMER MUST STILL SUPPLY is unchanged by all of this: at each state it inducts through,
the register equality across the collision and a forward-slack witness at the higher state.
Neither is a consequence of `ParamsOk`.

THE PROFILES SPLIT, and the split is recorded rather than smoothed over. FIVE of the ten pins
below sit BELOW the standard profile at `[propext, Quot.sound]`, consuming no choice:
`next_region_cnt_le_of_hasForwardSlack`, `hasForwardSlack_iff_next_region_cnt_le`,
`hasForwardSlack_amount_le`, `pend_succ_of_fwd` and `del_pin_pull_of_ge`. The restatement of the
regime as a bound on one region, the amount bound it forces, the pending-successor step and the
pull above the block are all constructions that never choose. The other five carry the standard
`[propext, Classical.choice, Quot.sound]`, from two distinct sources rather than one.
`del_pin_pull_of_lt` and `exists_deleted_ladderPath_of_next_region_nxt` consume choice in their
own PROOFS, through the `by_cases` on whether the lower pin's region reaches the block and the
`by_contra` placing every idle position above the compared position; and
`objCycleLens_nonempty_of_pend` through its `classical` block and the `.choose` it takes on
`pend_succ_of_fwd`'s existential before the pigeonhole over object states. `paramsOk_inflate` and
`forwardSlackWitnessed_iff_next_region_cnt_le` inherit it instead from the DEFINITIONAL closure of
what they quantify — `ParamsOk` and `ForwardSlackWitnessed` respectively — rather than from
anything either proof does: `paramsOk_inflate` only destructures and rebuilds the conjunction —
now carrying its margin hypothesis through to the rebuilt third `(K2)` conjunct, which changes the
signature and not the proof's axiom sources — and the `iff` only re-packages the existential's
witness. No certificate object is named, no finite-fibre or finite-width hypothesis appears, and
no pin is a bound. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.next_region_cnt_le_of_hasForwardSlack' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms next_region_cnt_le_of_hasForwardSlack

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.hasForwardSlack_iff_next_region_cnt_le' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms hasForwardSlack_iff_next_region_cnt_le

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.hasForwardSlack_amount_le' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms hasForwardSlack_amount_le

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pend_succ_of_fwd' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms pend_succ_of_fwd

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.objCycleLens_nonempty_of_pend' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms objCycleLens_nonempty_of_pend

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.paramsOk_inflate' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms paramsOk_inflate

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.forwardSlackWitnessed_iff_next_region_cnt_le' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms forwardSlackWitnessed_iff_next_region_cnt_le

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.del_pin_pull_of_lt' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms del_pin_pull_of_lt

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.del_pin_pull_of_ge' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms del_pin_pull_of_ge

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_deleted_ladderPath_of_next_region_nxt' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_deleted_ladderPath_of_next_region_nxt

/-! ## Requirement (W): the run-local discharge route, CONDITIONAL
(`RaySummary/LadderIdle.lean`)

WHAT THE TWO PINS BELOW CERTIFY. `hasForwardSlack_of_idleRunRepeat` is the PATH level: the pumped
path sits at the same ladder state at the compared position, realizes the same stab-free type
there, and carries `HasForwardSlack` at the amount `l`.
`forwardSlackWitnessed_of_cell_idleRunPumpable` is the CELL level — `ForwardSlackWitnessed` at
EVERY amount `l`, from the amount-free run-local premise `IdleRunPumpable`. The amount is
universally quantified in the conclusion and appears NOWHERE in the premise, because `d := l + 1`
pumps as much idle run as the amount demands; that asymmetry is what makes this route work where
the deletion route of the section above could not, the deletion having had to buy `l` units of a
quantity the saturated register had already spent.

WHAT THEY DO NOT CERTIFY, because it is not true. This is a CONDITIONAL discharge and must not be
read as an unconditional one. No schema loses a hypothesis: `LadderCell.lean` is untouched, all
five depth-`0` cell-equality schemas still carry `ForwardSlackWitnessed`, the unrestricted
`CellLEZeroConstOfKappaEq` is still neither proved nor refuted, and the reserved name
`cellLE_zero_const_of_kappa_eq` is still claimed by nothing. `IdleRunPumpable` is a datum of the
object and its run rather than a consequence of `ParamsOk` — `(K1)` quantifies `prodCycleLens`,
`objCycleLens` and `satPeriod` and never `idleCycleLens`, and `idle_run_lt_tIdle_of_no_idleCycle`
bounds every idle run BELOW `tIdle pend` absent an idle cycle — so a consumer must still supply
it, exactly as it must still supply the witnessing hypothesis itself. What remains open after
these two is the complementary side: the paths whose intervening idle run has length `1`.

The standard profile on both, MEASURED rather than expected. No certificate object is named, no
finite-fibre or finite-width hypothesis appears, and neither pin is a bound. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.hasForwardSlack_of_idleRunRepeat' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms hasForwardSlack_of_idleRunRepeat

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.forwardSlackWitnessed_of_cell_idleRunPumpable' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms forwardSlackWitnessed_of_cell_idleRunPumpable

/-! ## Requirement (W): the pin layer (`RaySummary/LadderPin.lean`)

`pend_past_or_idle_of_no_pin_below` is the PIN-FREE DICHOTOMY: below a position carrying no pin
at all — no idle position immediately followed by a pending one — pending is downward closed, so
the past is either uniformly idle or uniformly pending from some position down.
`pendPast_or_cntAt_le_nxtAt_succ` is its counter-level form at a pending position of a ladder
path: either the past is uniformly pending (the pin-free side, which is the hypothesis the landed
upward cell inclusion already consumes) or the countdown is at most the register plus one (the
backward window). The standard profile on each, and nothing else; no certificate object is named,
and neither pin asserts that pins are dense on a general path. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pend_past_or_idle_of_no_pin_below' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pend_past_or_idle_of_no_pin_below

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pendPast_or_cntAt_le_nxtAt_succ' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pendPast_or_cntAt_le_nxtAt_succ

/-! ## Requirement (W): the pigeonhole over region starts (`RaySummary/LadderPin.lean`)

`exists_pinTypeBlock_of_budget_lt_pins` runs the `(objAt, tpOf)` pigeonhole over the PINS rather
than over the positions inside one region, so the block it produces SPANS a pin: with more than
twice the type-pigeonhole budget of pins enumerated in a window, two of them at least two apart
carry the same object state and the same realized type at their successor positions, and a third
pin lies strictly inside the block they bound. `exists_spanningBlock_of_pins_below` reads that
tuple off in the shape the refuted spanning-block condition's statement took. The hypothesis is
the PIN COUNT in the window: neither pin claims that count is derivable from the parameter
conditions, and neither revives the refuted device, which asserted a spanning block
unconditionally. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_pinTypeBlock_of_budget_lt_pins' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_pinTypeBlock_of_budget_lt_pins

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_spanningBlock_of_pins_below' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_spanningBlock_of_pins_below

/-! ## The pin cascade's front half (`RaySummary/LadderAgree.lean`)

`pinnedRegions` is the set of region starts whose span meets a window, and
`pinnedRegions_subset_Ico` is the fact the cascade's well-foundedness rests on: an IDLE anchor
admits no region start below it whose span reaches it, so the pinned regions a window meets lie
inside the window. `pinnedRegions_finite` and `pinnedRegions_ncard_le` are its corollaries, the
second stating the cascade's iteration count as a COUNT. `pin_deficit_le_of_lengthen` is the
per-step increment over `pinCompat_of_ladderPath`, `cascadeDemand` the recurrence it sums,
`cascadeDemand_add_succ` that recurrence's closed form, and `cascadeDemand_le_cascadeBound` the
sizing against `(K2)`'s own `cascadeBound`. `regime_exhaustive_of_clipIdx_eq` records the regime
exhaustiveness as a lemma: a gap-coordinate collision at a fixed next deadline never straddles
the two regimes. None of these constructs a path, and no pin hypothesis of
`exists_spliced_ladderPath` is relaxed by any of them. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pend_of_mem_region' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pend_of_mem_region

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pinnedRegions_subset_Ico' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pinnedRegions_subset_Ico

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pinnedRegions_finite' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pinnedRegions_finite

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pinnedRegions_ncard_le' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pinnedRegions_ncard_le

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pin_deficit_le_of_lengthen' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.pin_deficit_le_of_lengthen

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cascadeDemand_add_succ' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cascadeDemand_add_succ

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cascadeDemand_le_cascadeBound' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cascadeDemand_le_cascadeBound

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.regime_exhaustive_of_clipIdx_eq' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.regime_exhaustive_of_clipIdx_eq

/-! ## `Real` and its agreement-free conditions (`RaySummary/LadderRealize.lean`)

`stab_bit_agree_of_certStabK` is why the acceptance clause is the hard condition: a certified set
assigns the same `⊡` bit to any two members sharing an object state and a counter class, and by
`stab_mem_tpOf_iff_cell` those bits are cell-level data of the members' own world states.
`Real` is the actually realizable subset, `realItem`/`mem_real_realItem` say every point of every
admissible ladder history projects into it, `mem_clType_iff_truth` is the bridge from membership
in a member's closure type to truth at the witnessing point, and `real_certLocK`/`real_certBoxK`
are conditions (1) and (6) of `Real`. Neither condition quantifies a relation between two
members, which is why both are available without the counter-lift lemma; conditions (2), (3) and
(4) do quantify `relK` and are NOT claimed here. No pin below consumes the agreement or the
schema `CellLEZeroConstOfKappaEq`. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_bit_agree_of_certStabK' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stab_bit_agree_of_certStabK

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.mem_real_iff' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.mem_real_iff

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.mem_real_realItem' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.mem_real_realItem

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.mem_clType_iff_truth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.mem_clType_iff_truth

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certLocK' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.real_certLocK

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certBoxK' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.real_certBoxK

/-! ### The interface the lift reads at the comparison position, pending-forever regime

`exists_ladderPath_at_region_of_pend_past` is the EXISTENTIAL form of what `spliced_at_region`
exposes: some ladder path carries the original's object state at the comparison position with the
countdown raised by exactly the cycle length. It is pinned because it is the regime half that
needs no self-loop premise. In the idle-past regime the `spliceObj`-shaped conclusion is still
REFUTED — `spliceCnt` raises the pin at the region start by exactly `l`
against `pinCompat_of_ladderPath`'s necessity, and the tight doubling chain of
`specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean` makes every pin
pair exactly tight with an idle past — so `exists_spliced_ladderPath_of_idle_past` is claimed by
nothing, deliberately, and that refutation is unaffected by anything below.

The NARROWER existential the consumer actually reads is a different statement, and it is landed
in both regimes: `exists_ladderPath_at_region_of_idle_past_of_self_loop` closes the idle-past
half on the INSERTED walk rather than the spliced one, and
`exists_ladderPath_at_region_of_self_loop` joins the two by `by_cases` on the pending-past
predicate. Both are pinned at the end of this file, and both carry
`hself` — the path-local self-loop at the path's own idle positions at or below `a` — which this
name does not. The standard profile. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_at_region_of_pend_past' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms
  FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_at_region_of_pend_past

/-! ### The idle-insertion walk and its four LOCAL ladder conditions

The cascade's first missing component, landed as a DEFINITION with its elementary local facts:
`insIdx` (identity above the insertion site, constantly `u` on the collapsed block `[u - d, u]`,
`· + d` below it), `insObj`/`insCnt` (the spliced walk read through it), the index map's three
retraction facts plus the two readings `insIdx_of_ge` and `insIdx_succ_of_lt_block` the local
conditions rewrite with, the two pointwise facts `insObj_of_gt`/`insCnt_of_gt` that carry the
comparison position BY CONSTRUCTION, the four local hypotheses `exists_ladderPath_of_walk`
consumes (`insObj_step`, `insCnt_idle`, `insCnt_pend_pend`, `insCnt_pend_idle`), and
`le_region_start_of_idle` — the one place the idle-past regime hypothesis enters, saying the
regime's idle witness is a legal insertion site.

**WHAT IS PINNED HERE IS NOT AN EXISTENTIAL AND NOT A PIN CONDITION.** `hpins` and `hn₀` for the
inserted walk are not among the names in this subsection; the pin condition arrives separately as
`insPins_of_region_start`, pinned further below, and `hn₀` is eliminated rather than produced
(`exists_ladderPath_of_walk_of_pins` reads the pin family's own pairwise compatibility). Of the
three `exists_ladderPath_at_region*`-family names, the two that are landed —
`exists_ladderPath_at_region_of_idle_past_of_self_loop` and
`exists_ladderPath_at_region_of_self_loop` — each took exactly one binder beyond the
pending-forever half, `hself`, the path-local self-loop decided here;
`exists_spliced_ladderPath_of_idle_past` took none and stays unclaimed and refuted.

**THE SELF-LOOP PRIMITIVE IS AN EXPLICIT HYPOTHESIS, AND `insObj_step` IS THE ONLY SITE.**
`insObj_step` carries `hself : step (objAt g u) (objAt g u) = true`, consumed at exactly one
place — the collapsed block, where the index map sends two consecutive positions to the inserted
idle object. `IsLadderPath` supplies no self-loop, and the pigeonhole alternative needs MANY idle
runs below the region start where the regime hypothesis gives ONE; the module's own section
docstring records that decision and its reason. The consequence is recorded rather than buried: on
a general object relation the self-loop is a genuine additional premise, so the idle-past
interface is unconditional in the REGIME sense only and carries `hself` all the way out.

Profiles: the three definitions depend on no axioms at all; the plumbing facts carry `[propext]`
or `[propext, Quot.sound]`; the four local conditions and the two `if`-dichotomy readings carry
the standard profile or a subset of it. No `sorryAx`, no custom axiom anywhere. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insIdx' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insIdx

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insObj' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insObj

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insCnt' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insCnt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insIdx_of_gt' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insIdx_of_gt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insIdx_of_mem_block' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insIdx_of_mem_block

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insIdx_of_lt_block' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insIdx_of_lt_block

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insIdx_of_ge' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insIdx_of_ge

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insIdx_succ_of_lt_block' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insIdx_succ_of_lt_block

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insObj_of_gt' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insObj_of_gt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insCnt_of_gt' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insCnt_of_gt

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insObj_step' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insObj_step

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insCnt_idle' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insCnt_idle

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insCnt_pend_pend' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insCnt_pend_pend

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insCnt_pend_idle' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insCnt_pend_idle

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.le_region_start_of_idle' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.le_region_start_of_idle

/-! ### The region start of the splice point's own region

`le_region_start_of_idle` above reads a GIVEN region start against an idle witness.
`exists_region_start_of_idle_past` is the complementary CONSTRUCTIVE direction: from an idle
position anywhere at or below a pending `a` it produces the greatest idle position `s ≤ a`, which
is the start of `a`'s own region — with the window inequality `a ≤ s + 1 + cntAt g (s + 1)` and the
MAXIMALITY clause saying every position strictly between `s` and `a` is pending.  That maximality
is what makes a single insertion at `s` sufficient, and it is the hypothesis the cascade's
region-start trichotomy consumes.  `Nat.find` over backward idle distances is decidable on `Bool`
equality without choice, so the profile stays at `[propext, Quot.sound]`.

This pin is itself NOT an existential over ladder paths: `hpins` for the inserted walk
(`insPins_of_region_start`) and the two landed `exists_ladderPath_at_region*` names are pinned
separately, below. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_region_start_of_idle_past' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_region_start_of_idle_past

/-! ### The inserted walk's region starts, trichotomised

`insRegionStart_trichotomy` is the whole content of the insertion's PIN half. Inserting the
repeated segment's copy at `u`, the region start of `a`'s own region, with depth `d := l`, every
region start of the inserted walk is the raised pin at `u` (countdown `cntAt g (u + 1) + l`), an
original region start strictly below `u` displaced DOWN by `l` with its countdown unchanged, or an
original region start at or above the seam displaced UP by `l` with its countdown unchanged.

Three things the pin records, none of them derivable from the name:

* The earlier region starts move down TOGETHER, so their mutual distances are preserved and only
  their distance to the raised pin grows — by exactly `l`. That is what fixes `d := l` and why ONE
  insertion suffices where this section's `cascadeDemand` / `pin_deficit_le_of_lengthen`
  bookkeeping anticipated an iteration with a doubling recurrence. That bookkeeping stays landed
  as the sizing record and is NOT consumed by this proof.
* The middle band `u < x < a + l` is EMPTY, and it takes the maximality clause of
  `exists_region_start_of_idle_past` plus the pending span of `a` under `l ≤ cntAt g a` to make it
  so. The collapsed block is excluded separately and for a different reason: its whole image is
  the idle `u`, so a position there has an idle successor.
* The profile carries `Classical.choice`, unlike `exists_region_start_of_idle_past` above: the
  splice's own countdown lemmas are in the dependency closure here and the region-start
  extraction's `Nat.find` route is not the only thing being measured.

This pin is itself NOT an existential over ladder paths. `hpins` for the inserted walk
(`insPins_of_region_start`) and the two landed `exists_ladderPath_at_region*` names are pinned
separately, below, and `exists_spliced_ladderPath_of_idle_past` remains REFUTED rather than merely
unclaimed. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insRegionStart_trichotomy' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insRegionStart_trichotomy

/-! ### `hpins` for the inserted walk, and the tightness of `d := l`

`insPins_of_region_start` is the pin obligation the `spliceObj`-shaped refutation left open,
discharged: the inserted walk's region-start countdowns are pairwise compatible, which is exactly
the hypothesis `exists_ladderPath_of_walk_of_pins` consumes. Nine pairs of trichotomy cases, each
closing on `pinCompat_of_ladderPath` applied to the two ORIGINAL region starts.

Three things this pin records that the name does not carry:

* **`d := l` is TIGHT, and one pair fixes it.** The pair `(u, y)` — the raised pin at `u` against
  an original start displaced down to `y - l` — demands `(u - y) + l` where compatibility on the
  original supplies only `u - y`. The deficit is exactly the raise, so no smaller depth closes
  this pair and no larger one is needed. Every other pair has slack.
* **The three mirror pairs are reached by `natAbs`'s symmetry in its two arguments**, by applying
  `pinCompat_of_ladderPath` in the swapped order rather than by re-proving the arithmetic. Nine
  cases, six distinct arguments.
* **The cascade bookkeeping is NOT in this proof's dependency closure as a proof term.**
  `cascadeDemand`, `cascadeDemand_add_succ`, `cascadeDemand_le_cascadeBound`, `pinnedRegions*` and
  `pin_deficit_le_of_lengthen` are all unconsumed: the single insertion at the region start of
  `a`'s own region replaces the iteration they size, and they stay landed as the record of what
  that iteration would have cost. `two_pow_card_prodState_le_Tc` is not reachable from here at
  all — it lives in `LadderChain.lean`, which imports this module.

The profile matches `insRegionStart_trichotomy`'s, which is the only nontrivial thing in its
dependency closure beyond `pinCompat_of_ladderPath`. This pin is itself not an existential over
ladder paths: the two landed `exists_ladderPath_at_region*` names are the existentials it feeds,
pinned separately below, and `exists_spliced_ladderPath_of_idle_past` remains REFUTED rather than
merely unclaimed. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.insPins_of_region_start' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.insPins_of_region_start

/-! ### The two existentials of the idle-past regime

`exists_ladderPath_at_region_of_idle_past_of_self_loop` and
`exists_ladderPath_at_region_of_self_loop` are the interface
the counter lift reads at the comparison position, in the regime where the splice point has an
idle position in its past and in both regimes joined. Four things these pins record that the
names do not carry:

* **The cascade collapsed to a SINGLE insertion.** The insertion site is the region start of `a`'s
  own region and the depth is `d := l`; that choice moves every earlier region start down by `l`
  together, so only the distance to the raised pin grows and the growth is exactly the raise.
  There is no iteration in either dependency closure, and so no doubling recurrence:
  `cascadeDemand`, `cascadeDemand_add_succ`, `cascadeDemand_le_cascadeBound`, `pinnedRegions*` and
  `pin_deficit_le_of_lengthen` are all unconsumed by these two proofs.
* **`hself` is a real binder, carried path-locally.** Both names take
  `∀ p ≤ a, pend (objAt g p) = false → step (objAt g p) (objAt g p) = true`. The self-loop at an
  idle object does not follow from `IsLadderPath`, which constrains `step` only along the original
  walk, and the collapsed block of the inserted walk needs it at exactly one position. It is stated
  at the path's own idle positions at or below `a` rather than globally over `Q`.
* **The join is unconditional in the REGIME sense only.**
  `exists_ladderPath_at_region_of_self_loop` carries
  neither a pending-past nor an idle-past hypothesis — it `by_cases`es the dichotomy internally —
  while still carrying `hself`, because its idle-past branch does.
* **`pend (objAt g a) = true` is derived, not assumed.** Neither name takes it as a binder; both
  obtain it from `0 < l ≤ cntAt g a` through `cntAt_eq_zero_of_idle`, matching
  `exists_ladderPath_at_region_of_pend_past` above.

The profile on each matches `insPins_of_region_start`'s, which together with
`exists_ladderPath_of_walk_of_pins` is the only nontrivial thing in either closure.
`exists_spliced_ladderPath_of_idle_past` is still claimed by nothing, and remains REFUTED rather
than merely unclaimed: the conclusion these two names carry is NOT the `spliceObj`-shaped one.

**THE `_of_self_loop` SUFFIX IS THE RECORD, AND THE BARE NAMES ARE UNCLAIMED.** Both pinned names
carry the suffix because both carry `hself`; `exists_ladderPath_at_region_of_idle_past` and
`exists_ladderPath_at_region` are UNCLAIMED, pending a discharge of that premise, on the same
convention `exists_spliced_ladderPath_of_idle_past` already follows in the same module. The
premise is INDEPENDENT rather than merely undischarged: the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-self-loop-derivability-decision.lean` compiles
`hself_not_derivable` — the implication from the other binders to `hself` refuted with
`Fintype Q` ASSUMED — together with `hself_satisfiable_at_an_instance`. So there is nothing for a
pin here to measure under either bare name, and no pin claims one.
`exists_ladderPath_at_region_of_pend_past`, pinned above, reads no `hself` and keeps its own
name. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_at_region_of_idle_past_of_self_loop' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
-- linter.style.longLine: the fully qualified name plus the `_of_self_loop` suffix makes this
-- `#print axioms` line over 100 characters, and the line cannot be broken (the command takes one
-- identifier). Deleting the suppression makes the linter's warning part of the captured message,
-- so `#guard_msgs` fails on a correct profile.
set_option linter.style.longLine false in
#print axioms
  FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_at_region_of_idle_past_of_self_loop

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_at_region_of_self_loop' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
-- linter.style.longLine: the fully qualified name plus the `_of_self_loop` suffix makes this
-- `#print axioms` line over 100 characters, and the line cannot be broken (the command takes one
-- identifier). Deleting the suppression makes the linter's warning part of the captured message,
-- so `#guard_msgs` fails on a correct profile.
set_option linter.style.longLine false in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_at_region_of_self_loop

/-! ### `Real`'s three RELATIONAL conditions

Conditions (2), (3) and (4) of `Real` — the three that quantify `relK` between two members, and
whose one shared missing link was a theorem deriving an `RK` edge from an actual `Count`/`Drift`
step. That link is `rk_of_count_drift`, pinned below; each of the three cites it. The discharge
path conditions (3) and (4) owe is a contiguous stretch of the member's OWN witnessing history,
supplied by `relK_realItem_succ` together with `untl_mem_tpOf_iff`/`snce_mem_tpOf_iff`. Five of
`Real`'s six conditions are landed with these; only `certStabK`, the one that consumes the
agreement of class-equivalent cells, is not claimed. No pin here consumes the agreement or the
schema `CellLEZeroConstOfKappaEq`, and none claims `certAdmK` of `Dmax` or any inclusion between
`Real` and `Dmax`. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certBiInfK' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.real_certBiInfK

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certFwdK' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.real_certFwdK

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certBwdK' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.real_certBwdK

/-! ### The bounded-representative lemma of `R_K`

`rk_of_count_drift` is the one fact `RK`'s bounded-representative definition does not give for
free: every actual `Count`/`Drift` step at arbitrary counters is an `RK` edge at the two classes.
It carries NO parameter, size or regime hypothesis, and it is proved by construction rather than
by `decide` — a `decide` over `RK` is `M^4`-shaped in the representative bound `M`, so no general
proof by enumeration exists and a concrete one would prove nothing general. The pin matters
because this lemma is the shared missing link of `Real`'s three relational conditions, and
because the representative bound it is stated over was WIDENED to make it provable: the narrower
`Tc + Tn + P + B + 2` is refuted by three `decide`-checked witnesses at the frozen bound
(`specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean`). The standard
profile. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.rk_of_count_drift' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.rk_of_count_drift

/-! ## Requirement (W): the ordinary window regime's arithmetic (`RaySummary/LadderWindow.lean`)

The complement regime. All five hypothesis-strengthened schemas of `LadderCell.lean` carry the
PENDING-FOREVER gap `n + 2 ≤ c`; this layer carries its exact complement `c ≤ n + 1`, and
`kappa_collision_window_or_pendPast_exhaustive` (pinned last in this file) is the compiled
statement that the two are the only cases at a fixed register. `kappa_collision_window_room` is
the regime's one real arithmetic gain: a fixed-register collision read inside the window either
pins the two countdowns equal or exhibits a positive multiple of `P + 1` separating them TOGETHER
WITH the strict room `c' ≤ n` for the larger — the room is `clipIdx_regime_of_eq`'s own
disjunction with the gap branch killed by the regime hypothesis, not an added assumption.
`window_anchor_compat_of_room` says that room IS the `z`-anchored lift's anchor clause at the
region start after a raise, and the two `window_pin_compat_*` names are the pin pair clause in
each direction. In all three pin statements `jP` is an OPAQUE natural number: the arithmetic
never reads it as `j · (P + 1)`, so none of them depends on the modulus, on `(K1)`, or on any
parameter tuple. Nothing here is a path construction and nothing is a cell inclusion. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_window_room' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_window_room

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_anchor_compat_of_room' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_anchor_compat_of_room

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_pin_compat_raise_of_gap' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_pin_compat_raise_of_gap

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_pin_compat_lower_of_spacing' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_pin_compat_lower_of_spacing

/-! ## Requirement (W): the window regime's decision gate and its clause lemmas

`HasIdleRunBelow` is THE NAMED IDLE-RUN CONDITION, and it is the whole reason this regime is
reachable: the compensator here is the idle run BELOW the comparison position, never slack above
it, so `HasForwardSlack` and `ForwardSlackWitnessed` appear nowhere in this module and the
refuted deletion-above route is not re-entered. The gate these pins record measured whether the
composite lift's two clauses close on the five admissible hypotheses — `ParamsOk`, the two window
hypotheses, `Tc ≤ c`, the collision's room, and this one named condition — and they did:
`window_anchor_clause_of_pin_classification` is the anchor clause reduced to a pin classification
and `window_pin_pair_raise_of_slack` the pin pair clause reduced to banked slack, with
`nxtAt_le_cntAt_region_start` supplying the start's own arithmetic from the ORIGINAL path and
`regionStart_spacing`, `no_pin_in_idle_run`, `region_run_of_region_start` and
`exists_idleBlock_of_hasIdleRunBelow` supplying the geometry. No sixth hypothesis was needed, so
this was a PASS rather than a widening — which is also why the conditional obstruction probe the
plan reserved for the FAIL branch was never written: there is no window-regime obstruction in
existence to compile. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.HasIdleRunBelow' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.HasIdleRunBelow

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.regionStart_spacing' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.regionStart_spacing

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_pin_dist_grows_below' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_pin_dist_grows_below

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_pin_dist_grows_above' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_pin_dist_grows_above

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_anchor_compat_at_region_start' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_anchor_compat_at_region_start

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_le_cntAt_region_start' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.nxtAt_le_cntAt_region_start

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_anchor_clause_of_pin_classification' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms
  FormalSystem.Metalogic.Decidability.RaySummary.window_anchor_clause_of_pin_classification

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.no_pin_in_idle_run' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.no_pin_in_idle_run

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_pin_pair_raise_of_slack' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_pin_pair_raise_of_slack

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.region_run_of_region_start' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.region_run_of_region_start

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_idleBlock_of_hasIdleRunBelow' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_idleBlock_of_hasIdleRunBelow

/-! ## Requirement (W): the composite splice's admissibility half, register held

`window_composite_pin_trichotomy` sorts every region start of the composite walk into three
classes named against the ORIGINAL path, and those three classes are exactly the three disjuncts
the gate's anchor clause consumes. `window_composite_pins` discharges the pin pair clause from
it: nine pin-class pairs, eight closing on `pinCompat_of_ladderPath` and a rigid displacement,
and the ninth — the raised region start against a pin below the lengthened run — spending the
compensator through `l ≤ E`. That ninth pair is the clause an uncompensated splice FAILS in this
regime. `exists_window_composite_ladderPath` lifts the walk TWICE, the second time through the
`z`-anchored `exists_ladderPath_of_walk_nxt_at` at the PRESCRIBED register value, because a cell
inclusion reads `nxtAt` at the comparison position and the anchor-free lift chooses whatever the
drift extension returns. Two scope facts the names do not carry: the raise here is ONE block
length `l`, not a multiple of `P + 1` (the bridge putting `l` among the divisors is `(K1)`'s and
the iteration to an exact multiple is a later step), and none of the three carries the realized
TYPE. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_composite_pin_trichotomy' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_composite_pin_trichotomy

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_composite_pins' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_composite_pins

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_window_composite_ladderPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_window_composite_ladderPath

/-! ## Requirement (W): the iterate to an exact multiple of `P + 1`

The window-regime analogue of `exists_iterSpliced_ladderPath_idx_of_pend_past`, which cannot be
reused here because the landed one carries the pending-forever hypothesis in two places.
`window_iter_pin_trichotomy` is the trichotomy stated so that every hypothesis and every
conclusion names only the path being spliced — which is what makes it applicable to the result of
its own conclusion, and so iterable — and `window_iter_pins` is its pin pair clause. The five
arithmetic names are the per-step reproduction of the three loop invariants, each as pure
arithmetic: `window_iter_anchor_raise` and `window_iter_anchor_shift` for the anchor clause,
`window_iter_slack_raise` for the pin-pair budget, `window_iter_budget_raise` for the anchor
budget (reproducing with NO slack lost — the countdown rises by `l` exactly as the unspent budget
falls by `l`), and `window_iter_no_low_shift` for the vacuity of the trichotomy's third disjunct
below the region start. `window_natAbs_sub_comm` exists because the two budget invariants are
written with the distance in opposite orders and the ambient library names this in neither.
`exists_window_iterSpliced_ladderPath` is the iterate itself, with the register prescribed. The
standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_iter_pin_trichotomy' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_iter_pin_trichotomy

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_iter_pins' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_iter_pins

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_natAbs_sub_comm' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_natAbs_sub_comm

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_iter_anchor_raise' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_iter_anchor_raise

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_iter_anchor_shift' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_iter_anchor_shift

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_iter_slack_raise' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_iter_slack_raise

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_iter_budget_raise' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_iter_budget_raise

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_iter_no_low_shift' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_iter_no_low_shift

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_window_iterSpliced_ladderPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_window_iterSpliced_ladderPath

/-! ## Requirement (W): the idle lengthening and where each resource is spent

`window_idle_pin_dichotomy` is the pin classification of the path the idle pump returns — two
classes rather than three, since no pin sits inside an idle run — with the pump's own output
clauses as hypotheses verbatim and nothing new assumed. The next three pins are worth reading
together because each says where ONE resource goes. `window_idle_anchor_clause`: the insertion's
length `E` is NOT spent on the anchor clause, which would hold for any `E`.
`window_idle_slack`: the insertion IS spent here, the displaced region start leaving the
original's own pin bound slack by exactly `E`. `window_idle_budget`: the COLLISION'S ROOM is
spent here, and this is the only place the window hypothesis enters the construction at all —
once, not once per step. `exists_iterIdleSpliced_ladderPath_idx` is the iterated lengthening read
through the index map, which is what carries the realized TYPE as well as the walk and the
countdown. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_idle_pin_dichotomy' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_idle_pin_dichotomy

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_idle_anchor_clause' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_idle_anchor_clause

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_idle_slack' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_idle_slack

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_idle_budget' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_idle_budget

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_iterIdleSpliced_ladderPath_idx' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_iterIdleSpliced_ladderPath_idx

/-! ## Requirement (W): the window regime's RAISING primitive

`exists_window_raise_displaced` assembles the two stages at the displaced position and
`exists_window_raise_ladderPath` re-anchors the result at `z` itself, with the realized type
held: a ladder path through `(objAt g z, cntAt g z + m · (P + 1), nxtAt g z)`. This is the
regime's path-level deliverable and the thing Phase 4's cell inclusion lifts. What it is NOT:
there is no matching LOWERING primitive, and the next section's three pins measure why. The
standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_window_raise_displaced' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_window_raise_displaced

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_window_raise_ladderPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.exists_window_raise_ladderPath

/-! ## Requirement (W): why the LOWERING direction has no primitive — a measured deficit

These three are the record that the result is one-directional by measurement rather than by
choice, and they are the Evidence column of three separate landed `Reasoned Exclusions` records.
`window_lower_anchor_not_implied`: the lowering branch's room `c ≤ n`, the deletion's own bound
`jP ≤ c`, and the path's arithmetic `n ≤ c + 2 · d + 1` do not jointly give the clause's binding
half. `window_lower_anchor_fails_at_tight_bound`: the deficit is not an artefact of a loose
witness — with the path's bound TIGHT (which `nxtAt_lipschitz` permits) the clause fails for
EVERY positive displacement, so no sharpening of the path's arithmetic recovers it.
`window_lower_anchor_of_required`: what would be needed, stated so it need not be rediscovered —
one named condition `n + jP ≤ c + 2 · d + 1`, a bound on the register from ABOVE relative to the
in-region depth, which is a SIXTH hypothesis and therefore excluded by the decision gate's own
criterion. The consequence is carried honestly in the next section's conclusion: cell INCLUSION,
not equality, because `Set.Subset.antisymm` needs two inclusions and this regime has one. The
companion wired probe is `lowering-anchor-deficit.lean`, named in
`scripts/check-evidence-probes.sh`'s probe list. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_lower_anchor_not_implied' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_lower_anchor_not_implied

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_lower_anchor_fails_at_tight_bound' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms
  FormalSystem.Metalogic.Decidability.RaySummary.window_lower_anchor_fails_at_tight_bound

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.window_lower_anchor_of_required' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.window_lower_anchor_of_required

/-! ## Requirement (W): the window regime's upward cell inclusion

`WindowIdleRunWitnessed` lifts the raising primitive's path data from one path to a whole cell:
every type the cell realizes at `z` is realized there by SOME ladder path with a region start
below `z` carrying the named idle-run condition. `cellAt_subset_of_window_raise` is the
inclusion it buys — at countdown at least `Tc`, in the ordinary window regime, the cell at
`(q, c, n)` is contained in the cell at `(q, c + m · (P + 1), n)`. Note the direction: UPWARD
only. The downward inclusion is not landed here, and is not merely unproved but excluded on the
measurement in the section above — it would be the lift of a primitive that does not exist. The
standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.WindowIdleRunWitnessed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.WindowIdleRunWitnessed

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_window_raise' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_window_raise

/-! ## Requirement (W): the window schema, its theorem, and the compiled dichotomy

The regime's terminus. `CellSubsetOfKappaEqWindowRaise` is the schema and
`cellSubset_of_kappa_eq_window_raise` the theorem proving it at every parameter tuple `ParamsOk`
admits. Five things separate this schema from the reserved `CellLEZeroConstOfKappaEq`, and all
five are visible in its own statement: the two window hypotheses (where the landed schemas carry
`n + 2 ≤ c`), the threshold bounds, the named idle-run condition demanded at the lower-countdown
pair, and a WEAKER CONCLUSION — direction-indexed cell INCLUSION rather than equality. Being
strictly stronger in hypotheses and weaker in conclusion, it bears on the reserved statement's
truth value in NEITHER direction, and the reserved name is STILL claimed by nothing: an
exact-name declaration sweep over `FormalSystem/` returns zero sites for
`cellLE_zero_const_of_kappa_eq`, and the five pending-forever schemas of `LadderCell.lean` are
unchanged by this layer. The reverse-ordering half of each displacement branch is discharged as
VACUOUS (`0 < j * (P + 1)` contradicts the opposite ordering), not proved, and the theorem's
docstring says so. `kappa_collision_window_or_pendPast_exhaustive` is what makes this a half of a
partition rather than an unquantified special case: a fixed-register collision at `2 ≤ B` puts
BOTH countdowns on the same side of the window boundary, with no third case. It is derived from
`clipIdx_regime_of_eq` and `pend_past_of_nxtAt_lt` rather than asserted. Nothing in this layer is
a realization theorem, nothing claims `HitPresented` or `PlusValidZTime`, and no index of a
ladder cell is claimed at any parameters. The standard profile on each. -/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.CellSubsetOfKappaEqWindowRaise' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.CellSubsetOfKappaEqWindowRaise

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellSubset_of_kappa_eq_window_raise' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cellSubset_of_kappa_eq_window_raise

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_window_or_pendPast_exhaustive' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms
  FormalSystem.Metalogic.Decidability.RaySummary.kappa_collision_window_or_pendPast_exhaustive

/-! ## The depth-stratified parameter margin (`RaySummary/CounterQuotient.lean`)

Three pins for `(K2)`'s margin conjunct and the two forms its consumers read it at. The conjunct
asks `b · (P + 1) · (D + 1) ≤ T_c` for `b` the type-pigeonhole budget, `P + 1` the modulus and
`D := (plusSubformulaClosure φ).sup stabDepth` the `⊡`-nesting depth of the closure. It is a
STRENGTHENING of the parameter conditions, and the two things that have to be said about a
strengthening are both said here.

FIRST, IT IS DISCHARGEABLE. `paramsOk_params` is re-proved at the new `T_cof`, whose definition
gains one `max` arm reading `Pof` — and `Pof` is the modulus minus one, computed from the
certificate graph's cycle lengths and the periodicity fixpoint's period, so it does not read
`T_c` and there is no circularity. Its pin above is unchanged at the standard profile, and its
signature gained no binder: a parameter hypothesis nobody can discharge is indistinguishable from
an unproved statement for every consumer downstream, which is the one failure mode this layer
exists to prevent. The generic satisfiability statement is the round-15 probe's
`exists_paramsOk_with_margin`.

SECOND, IT COSTS THE UNCONDITIONAL INFLATION LEMMA. `paramsOk_inflate` now carries the inflated
room as an explicit hypothesis, because the margin is LINEAR in `P` and
`paramsOk_modulus_unbounded_at_fixed_Tc` (round-15 probe) says no bound on the inflation factor
at a fixed `T_c` follows from (K1)-(K4). `paramsOk_inflate_raise` is the sibling that keeps the
capability unconditional by raising `T_c` and `T_n` with `P`; its statement is existential in the
raised pair, which is why it reports `Classical.choice` on the same footing as its sibling rather
than below it.

NEITHER ROOM LEMMA IS A BOUND. `budget_mul_spacing_le_Tc` is the shape
`exists_typeBlock_of_spacing`'s single room hypothesis consumes at spacing `s := P + 1`, the
spacing at which a pumped block's length is a multiple of the modulus;
`margin_room_at_depth` is the same quantity with one block of room reserved per `⊡`-depth level,
at the base `Tc_0 = 0` the conjunct forces. Both are lower bounds on `T_c` read in the available
direction, and neither bounds `P`, the cell, the fibre or the width. The standard profile on each,
inherited from `ParamsOk`'s own definitional closure and not from any choice either proof makes.-/

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.paramsOk_inflate_raise' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.paramsOk_inflate_raise

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.budget_mul_spacing_le_Tc' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.budget_mul_spacing_le_Tc

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.margin_room_at_depth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.margin_room_at_depth

/-! ## The iterated splice's interior clauses (`RaySummary/LadderCell.lean`)

One clause landed and one refuted, both as siblings leaving the pump spine byte-identical.

LANDED. `exists_iterSpliced_ladderPath_idx_interior_of_pend_past` carries the four clauses of
`exists_iterSpliced_ladderPath_idx_of_pend_past` plus the countdown at position `j` of copy `i`,
which is the original's at the retracted position plus the `(d - i) * l` positions of the copies
still above it. The parent is untouched; the clause is proved by re-running the parent's induction
with it carried, since the parent's existential exposes no interior countdown to derive it from.
This says nothing about any stability bit, cell or counter class, and claims no index of a ladder
cell at any parameters.

REFUTED. The companion register clause is NOT a clause of this construction.
`iterSpliced_register_interior_forces_block_drift` derives from it, on any ladder path, that the
original's register at the block's last position is within one of its value at the block's first;
`iterSpliced_register_interior_refuted` exhibits a path on which that fails while every hypothesis
of the parent holds, so no path at all satisfies the clause there. The register coordinate of the
pump is uncontrolled at the window's interior. Nothing in this layer is a realization theorem and
nothing claims `HitPresented` or `PlusValidZTime`. The standard profile on the first and the
third; the second needs no choice. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_iterSpliced_ladderPath_idx_interior_of_pend_past' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_iterSpliced_ladderPath_idx_interior_of_pend_past

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.iterSpliced_register_interior_forces_block_drift' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms iterSpliced_register_interior_forces_block_drift

/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.iterSpliced_register_interior_refuted' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.iterSpliced_register_interior_refuted

/-! ## The register discriminator (`RaySummary/LadderCell.lean`)

The two-sided measurement the register weakening needed, and the decision it forces. SIDE (A),
the producer: `register_displacement_bound_of_anchor` is the whole of the register coordinate's
transport between two ladder paths agreeing at one anchor — the sum of the two positions'
distances to it — and `register_interior_displacement_bound_at_block` reads that at the pump's own
copy pairs, at the bound `i * l + 2 * j`, which grows with the copy index.
`iterSpliced_register_clipped_interior_forces_block_drift` then weakens the refuted register
clause from equality to `kappa`'s own clipped reading `min . Tn` and derives the SAME block
`Drift`, because below the threshold the clipped reading IS equality; and
`iterSpliced_register_clipped_interior_refuted` exhibits that on the climbing-register fixture
already carried, at every `Tn >= 3` and every `P`, with the residue conjunct carried alongside, so
the clipped/residue CONJUNCTION is refuted and not merely its clipped half.

SIDE (B), the consumer: `stab_alphaR_iff` computes the `stab` bit of one probe formula at an idle
ladder state exactly — the bit IS `register = 0`, because from an idle position the next region's
countdown is the register. `stab_bit_ne_of_register_ne` reads the negative half off it: at every
amount `m > 0` two states sharing object and countdown but differing in the register carry
differing bits, which refutes dropping the register conjunct outright, refutes a `Drift`-distance
bound at `m = 1`, and refutes the residue reading alone at `m = P + 1`.
`stab_alphaR_eq_of_clipped_eq` reads the positive half: the clipped reading alone delivers the
bit's agreement at every threshold `Tn >= 1`.

The two sides disagree, so no relation is defined here and no membership of any pump pair in one
is claimed. Nothing in this layer is a realization theorem and nothing claims `HitPresented` or
`PlusValidZTime`. The standard profile throughout; the three arithmetic statements need no
choice. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.register_displacement_bound_of_anchor' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms register_displacement_bound_of_anchor

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.register_interior_displacement_bound_at_block' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms register_interior_displacement_bound_at_block

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.iterSpliced_register_clipped_interior_forces_block_drift' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms iterSpliced_register_clipped_interior_forces_block_drift

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.iterSpliced_register_clipped_interior_refuted' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms iterSpliced_register_clipped_interior_refuted

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_alphaR_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms stab_alphaR_iff

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_bit_ne_of_register_ne' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms stab_bit_ne_of_register_ne

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_alphaR_eq_of_clipped_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms stab_alphaR_eq_of_clipped_eq

/-! ### The pending-state measurement

The consumer measurement above is taken at an idle state; the positions of a pump block are all
pending. `stab_gapR_iff` computes the `stab` bit of the probe formula `gapR` at a PENDING ladder
state exactly, as the threshold `c + 1 < n` on the signed gap, with `gapPath` the falling-register
path through the state and `pendPath` the constant-register one. Off it:
`stab_gapR_eq_of_gap_eq` consumes equality of the gap at every pending state;
`stab_gapR_ne_of_clipped_eq` refutes the clipped/residue conjunction at every countdown
`c >= Tn - 1`; `stab_gapR_eq_of_clipped_eq_of_low` consumes the clipped register on the slice of
equal countdowns `c + 2 <= Tn`, and `stab_gapR_iff_of_cnt_zero` reads the bit at countdown `0`.
PRODUCER side: `iterSpliced_gap_interior_forces_block_gap_le` derives from the gap-shaped conjunct
at copies `0` and `1` that the original's gap does not rise across the block. No relation is
defined and no cell agreement is claimed. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_gapR_iff' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms stab_gapR_iff

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_gapR_iff_of_cnt_zero' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms stab_gapR_iff_of_cnt_zero

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_gapR_eq_of_gap_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms stab_gapR_eq_of_gap_eq

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_gapR_ne_of_clipped_eq' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms stab_gapR_ne_of_clipped_eq

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.stab_gapR_eq_of_clipped_eq_of_low' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms stab_gapR_eq_of_clipped_eq_of_low

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.gapPath_isLadderPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms gapPath_isLadderPath

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.pendPath_isLadderPath' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms pendPath_isLadderPath

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.iterSpliced_gap_interior_forces_block_gap_le' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms iterSpliced_gap_interior_forces_block_gap_le

/-! ### The certificate-side bridge, route (P-2) (`RaySummary/LadderRealize.lean`)

The design round's two legs. LEG A: `real_certStabK_mpr` is the direction of `certStabK`'s clause
that needs NO cell transfer and is landed unconditionally, `real_certStabK_mp_of_cell_stab_transfer`
is the direction that carries it, and `real_certStabK_of_cell_stab_transfer` joins them into the
reduction of condition (5) of `Real` to the cell-side obligation. The scope reading is
`kappa_eq_register_displaced` with `register_displaced_collision_in_domain`, which exhibit the
register-displaced collisions inside that obligation's domain, together with
`register_displaced_ne_common_shift`, which shows the landed common-shift tool does not reach
them. LEG B: `ClassRepTransport` is the
transport, OPEN here — neither proved nor refuted — with `cell_stab_transfer_of_classRepTransport`
and `real_certStabK_of_classRepTransport` the implications out of it. Every pin is a reduction or a
scope reading; none claims the transport, the agreement, or any inclusion between `Real` and
`Dmax`. The standard profile on each. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certStabK_mpr' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms real_certStabK_mpr

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certStabK_mp_of_cell_stab_transfer' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms real_certStabK_mp_of_cell_stab_transfer

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certStabK_of_cell_stab_transfer' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms real_certStabK_of_cell_stab_transfer

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_eq_register_displaced' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms kappa_eq_register_displaced

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.register_displaced_collision_in_domain' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms register_displaced_collision_in_domain

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.register_displaced_ne_common_shift' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms register_displaced_ne_common_shift

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cell_stab_transfer_of_classRepTransport' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cell_stab_transfer_of_classRepTransport

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certStabK_of_classRepTransport' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms real_certStabK_of_classRepTransport

/-! ### Phase 11.26: the register-raise transport, and the two coordinates that refuse it

Branch OPEN of the certificate-side bridge. `kappa_eq_register_raise_down` is the
DOWNWARD-saturated family of register-displaced `kappa`-collisions;
`raise_room_excludes_upward_displacement` is the compiled inequality by which the raise tool's
room ceiling excludes the UPWARD-saturated family Phase 11.25 exhibited inside the obligation's
own domain; `certStabK_of_stabFree` records that at a stab-free closure — the only closure at
which the register-moving deletions are available — condition (5) is vacuous;
`exists_ladderPath_register_raised_at_held_countdown` is the `m = 0` instance of the raised
exact-shift deletion, the one instance that holds a countdown fixed; and
`cellAt_subset_of_register_raise` is the transport it yields, with the `kappa`-collision as the
first conjunct of its conclusion. None of these claims `ClassRepTransport`, which stays OPEN,
and none claims the agreement or any inclusion between `Real` and `Dmax`. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.kappa_eq_register_raise_down' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms kappa_eq_register_raise_down

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.raise_room_excludes_upward_displacement' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms raise_room_excludes_upward_displacement

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.certStabK_of_stabFree' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms certStabK_of_stabFree

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_register_raised_at_held_countdown' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_ladderPath_register_raised_at_held_countdown

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_register_raise' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellAt_subset_of_register_raise


/-! ### Phase 11.27: the composition over the covered collisions, and what it buys

The certificate-side bridge composed on the collisions Phase 11.26's transport covers.
`exists_ladderPath_register_lowered_at_held_countdown` is the `m = 0` instance of the LOWERED
exact-shift deletion, the reverse direction of the register raise at a held countdown;
`cellAt_subset_of_register_lower` is the cell inclusion it yields;
`cellAt_eq_of_register_displacement` is the two inclusions together — the cell-level
AGREEMENT over the COVERED set, which is NOT the filed `cellAt_const_of_kappa_eq` and is
landed under its own name precisely so the difference is visible;
`cell_stab_transfer_of_register_displacement` is that agreement in the shape the reduction's
`hcell` binder consumes, in both orientations; and `real_certStabK_of_stabFree` is the
composition's `certStabK` product over the covered regime — which is VACUOUS there, its proof
consuming nothing from the transport or the agreement. None of these claims `ClassRepTransport`,
the filed agreement, or any inclusion between `Real` and `Dmax`. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_register_lowered_at_held_countdown' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_ladderPath_register_lowered_at_held_countdown

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_register_lower' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellAt_subset_of_register_lower

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_eq_of_register_displacement' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellAt_eq_of_register_displacement

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cell_stab_transfer_of_register_displacement' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cell_stab_transfer_of_register_displacement

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.real_certStabK_of_stabFree' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms real_certStabK_of_stabFree


/-! ### Phase 11.7: the filed agreement left OPEN, and the instantiation over the covered set

`register_dichotomy_of_kappa_eq_held_countdown` is the gap coordinate's own split at a held
countdown — trivial, downward-saturated (the covered family), or upward-saturated (outside every
landed tool's reach) — and `cellAt_const_of_kappa_eq_of_covered` is the agreement at the FILED
statement's own shape, with the `kappa`-collision as a hypothesis, restricted to the covered
family by explicit named binders. Neither is the filed `cellAt_const_of_kappa_eq`, which is
attempted at its recorded signature and left OPEN on the uncovered collisions specifically and
which is landed in this tree under no name; neither consumes `ladderSound`, `ladderLift` or any
(S)/(C') statement. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.register_dichotomy_of_kappa_eq_held_countdown' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms register_dichotomy_of_kappa_eq_held_countdown

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_const_of_kappa_eq_of_covered' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellAt_const_of_kappa_eq_of_covered


/-! ### Route (E-2): the diagonal gap — offset-invariance of `tpOf`, and the covered agreement at
a general time component

The world state's own `ℤ` component is one of the five coordinates on which the filed
`cellAt_const_of_kappa_eq` is open, and it is the one coordinate tractable independently of the
register question: `Rlad` ignores its time argument, so one ladder walk is a world history at
every offset (`exists_hist_of_isLadderPath_at_offset`), the offset is invisible to every clause of
`PlusTruthAt` (`truthAt_iff_of_worldTime_offset`, the `⊡` letters INCLUDED and no stab-free
premise anywhere), hence invisible to the realized type (`tpOf_eq_of_worldTime_offset`) and to the
cell (`cellAt_ladder_eq_of_worldTime`). `cellAt_const_of_kappa_eq_of_covered_at_time` is the
covered agreement with its diagonal world state replaced by a general `t`, every other binder
unchanged.

What is NOT pinned here because it is not claimed: the filed `cellAt_const_of_kappa_eq` stays
OPEN on the other four coordinates (the upward-saturated register family, moved countdowns,
closures carrying a `⊡` letter, paths outside the regime), nothing below consumes
`ladderSound`, `ladderLift`, `ladderCons_localRun` or any (S)/(C') statement, and no parameter
ruling is taken. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_hist_of_isLadderPath_at_offset' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_hist_of_isLadderPath_at_offset

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.truthAt_iff_of_worldTime_offset' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms truthAt_iff_of_worldTime_offset

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_of_worldTime_offset' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms tpOf_eq_of_worldTime_offset

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_ladder_eq_of_worldTime' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellAt_ladder_eq_of_worldTime

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_const_of_kappa_eq_of_covered_at_time' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellAt_const_of_kappa_eq_of_covered_at_time

/-! ### The step system on the step fragment (`RaySummary/LadderStepFrag.lean`)

`Zrel a b` is the derived relation on ladder states at a budget of `a` backward and `b` forward
steps; `Zrel.succ` and `Zrel.pred` are its one-step back-and-forth; `exists_linked_path` is the
path forth the `⊡` clause reads; `truth_iff_of_lnk` is the truth lemma on `StepFrag` (every
connective, `⊡` and `□` included, `untl`/`snce` only at the guard `⊥`); `cellAt_eq_of_Zrel` is the
cell agreement, a corollary carrying no `ParamsOk` hypothesis.

What is NOT pinned here because it is not claimed: an agreement over `kappa`-classes, a fibre
equation, or anything about a formula with an `untl` or `snce` jump at a guard other than `⊥`. The
thresholds `2 * (dBack + dFwd) ≤ Tc, Tn` an instantiation at a formula needs are hypotheses of
that instantiation and are discharged nowhere. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Zrel' does not depend on any axioms -/
#guard_msgs in
#print axioms Zrel

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Zrel.succ' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms Zrel.succ

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Zrel.pred' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms Zrel.pred

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_linked_path' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_linked_path

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.truth_iff_of_lnk' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms truth_iff_of_lnk

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.cellAt_eq_of_Zrel' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms cellAt_eq_of_Zrel


/-! ### The row link (`RaySummary/LadderStepFrag.lean`)

`LnkRow a b g g' t t'` is the relation the two jump clauses of `PlusTruthAt` read; `LnkRow.symm`,
`LnkRow.mono` and `LnkRow.toLnk` are its symmetry, its monotonicity in the budgets and its
restriction to the window link; `exists_rowLinked_path_zero` is the `⊡` clause against it at the
budget `(0, 0)`.

`LnkRow.refl` is its reflexivity; `truth_iff_of_lnkRow` is the truth lemma over it at the `⊡`-free
level (`RowFrag`), `untl` and `snce` at every guard; `LnkRow.first_zero` and
`LnkRow.region_end_obj` are a necessary condition on a row link (the two current pending regions
end at one object state).

What is NOT pinned here because it is not declared: the path forth with a whole-row
correspondence at a positive budget. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LnkRow' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms LnkRow

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LnkRow.symm' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms LnkRow.symm

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LnkRow.mono' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms LnkRow.mono

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LnkRow.toLnk' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms LnkRow.toLnk

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_rowLinked_path_zero' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_rowLinked_path_zero

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LnkRow.refl' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms LnkRow.refl

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LnkRow.first_zero' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms LnkRow.first_zero

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LnkRow.region_end_obj' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms LnkRow.region_end_obj

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.truth_iff_of_lnkRow' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms truth_iff_of_lnkRow

/-! ### The residue-carrying state relation (`RaySummary/LadderStepFrag.lean`)

`Srel P a b` is `Zrel a b` with the two countdowns congruent modulo `P + 1`; `Srel.toZrel` is its
projection to the step system's relation, and `Srel.refl`, `Srel.symm`, `Srel.mono` its three
structural lemmas.

What is NOT pinned here because it is not declared: a path forth from `Srel`.  The wired probe
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` refutes it
(`no_rowLinked_path_of_Srel`). -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Srel' does not depend on any axioms -/
#guard_msgs in
#print axioms Srel

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Srel.toZrel' does not depend on any axioms -/
#guard_msgs in
#print axioms Srel.toZrel

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Srel.refl' does not depend on any axioms -/
#guard_msgs in
#print axioms Srel.refl

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Srel.symm' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms Srel.symm

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Srel.mono' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms Srel.mono

/-! ### The agreement on `kappa`-classes refuted at (K4)'s clip (`RaySummary/LadderRealize.lean`)

One pin: the existential refutation of the agreement's schema at the clip
`max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)`. Its two-state witness is `private` to the
module and is pinned through this theorem. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_kappa_collision_cellAt_ne_at_K4_clip' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_kappa_collision_cellAt_ne_at_K4_clip

/-! ### `Real` is NOT certified at (K4)'s clip (`RaySummary/LadderRealize.lean`)

One pin: the existential refutation of `certStabK` — condition (5) — and hence of `certAdmK` ON
`Real` itself, at the same clip and the same two-state witness. It is the certificate-side reading
of the entry above, and it closes the route to `Real ⊆ Dmax` through `dmax_maximal`. It does NOT
state `Real ⊄ Dmax`. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_paramsOk_real_not_certAdmK' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms exists_paramsOk_real_not_certAdmK

open FormalSystem.Metalogic.Decidability.RaySummary in
open FormalSystem.Syntax FormalSystem.PlusLanguage in
/-- **THE RESTRICTION CHECK.** The refutation is read at the `(K4)` clip `Bof` itself outputs, with
`ParamsOk` discharged at the same tuple — not at a clip chosen to defeat it. A version stated at an
unconstrained `B`, or without the `ParamsOk` conjunct, would not typecheck here. -/
example : ∃ (Q : Type) (_ : Fintype Q) (_ : Nonempty Q)
      (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
      (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
      (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
      (phi : PlusFormula) (Tc Tn P : ℕ),
      ParamsOk step pend lab phi Tc Tn P
          (max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)) ∧
      ¬ certAdmK step pend lab phi Tc Tn P
          (max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2))
          (Real step pend lab phi Tc Tn P
            (max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)) fwd bwd) := by
  obtain ⟨Q, hQ, hne, step, pend, lab, fwd, bwd, phi, Tc, Tn, P, hp, -, hadm⟩ :=
    exists_paramsOk_real_not_certAdmK
  exact ⟨Q, hQ, hne, step, pend, lab, fwd, bwd, phi, Tc, Tn, P, hp, hadm⟩


/-! ### The threshold-carrying state relation

`Mrel P a b` is `Srel P a b` with the countdown clause raised: the two countdowns are equal, or
both at least `(P + 1) * (a + b)`.  Its margin per unit of budget is the object-dependent `P + 1`
where `Zrel`'s own is the object-independent `2`.  `Mrel.toSrel` and `Mrel.toZrel` are its two
projections, so every consumer of the step system's results reads it unchanged.

What is NOT pinned here because it is not declared: a path forth from `Mrel`, and a refutation of
one.  Neither exists.  The wired probe
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` records what the
round that stated this relation attacked and what each attack compiled instead
(`not_Mrel_xR_yR`, `region_end_agrees_R4`, `region_end_matchable_B5`). -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Mrel' does not depend on any axioms -/
#guard_msgs in
#print axioms Mrel

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Mrel.toSrel' does not depend on any axioms -/
#guard_msgs in
#print axioms Mrel.toSrel

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Mrel.toZrel' does not depend on any axioms -/
#guard_msgs in
#print axioms Mrel.toZrel

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Mrel.refl' does not depend on any axioms -/
#guard_msgs in
#print axioms Mrel.refl

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Mrel.symm' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms Mrel.symm

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Mrel.mono' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms Mrel.mono


/-! ### The recursive-induction scaffold for the row link (`RaySummary/LadderStepFrag.lean`)

`LnkRow.of_closed` is the first derivation of a row link at a POSITIVE budget anywhere in the
tree: a budget-indexed relation between POSITIONS which is sound for `Zrel` and closed under both
jump conditions entails `LnkRow` at every budget. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.LnkRow.of_closed' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms LnkRow.of_closed

/-! **THE RESTRICTION CHECK.**  The scaffold is instantiated at the POSITIVE budget `(3, 5)`, so a
version silently restricted to the budget `(0, 0)` — the one `exists_rowLinked_path_zero` already
covers — fails to typecheck here rather than passing review. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
example {Q : Type} {pend : Q → Bool} {g g' : ℤ → LadderState Q pend}
    (S : ℕ → ℕ → ℤ → ℤ → Prop)
    (hzr : ∀ a b t t', S a b t t' → Zrel a b (g t) (g' t'))
    (hfw : ∀ a b t t', S a (b + 1) t t' →
      FwdJump (fun s s' => S a b s s') t t' ∧ FwdJump (fun s' s => S a b s s') t' t)
    (hbw : ∀ a b t t', S (a + 1) b t t' →
      BwdJump (fun s s' => S a b s s') t t' ∧ BwdJump (fun s' s => S a b s s') t' t)
    (t t' : ℤ) (h : S 3 5 t t') : LnkRow 3 5 g g' t t' :=
  LnkRow.of_closed S hzr hfw hbw 3 5 t t' h

/-! ### The `(K2)` margin at `Mrel`'s raised countdown threshold
(`RaySummary/LadderStepFrag.lean`) -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/--
info: 'FormalSystem.Metalogic.Decidability.RaySummary.Mrel.threshold_le_Tc' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms Mrel.threshold_le_Tc


/-! ### Route (R-2): the object half of `(K1)`, count move 1, and the budget's essentiality
(`RaySummary/LadderStepFrag.lean`)

Phase 11.49 added the object half of `(K1)` — `∀ l ∈ objCycleLens step pend, l ∣ (P + 1)` — as a
hypothesis, under the user's decision 21, and landed its bridge from `ParamsOk`, the first of the
three count moves, and the mechanical reason the scaffold's relation must stay budget-indexed.
`exists_rowLinked_path` itself did NOT close; it is not pinned here, and no declaration of that
name exists.

**The added-hypothesis check is mechanical and it lives here.** The bridge's own statement is the
added hypothesis, and the restriction check below instantiates count move 1 at a positive splice
with the register offset read off its conclusion — a version that silently dropped the register
clause would fail to typecheck rather than passing review. -/

open FormalSystem.Metalogic.Decidability.RaySummary in
/--
info: 'FormalSystem.Metalogic.Decidability.RaySummary.objHalfK1_of_paramsOk' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms objHalfK1_of_paramsOk

open FormalSystem.Metalogic.Decidability.RaySummary in
/--
info: 'FormalSystem.Metalogic.Decidability.RaySummary.exists_lengthened_region' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exists_lengthened_region

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- info: 'FormalSystem.Metalogic.Decidability.RaySummary.Zrel.forall_iff_eq' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms Zrel.forall_iff_eq

open FormalSystem.Metalogic.Decidability.RaySummary in
open FormalSystem.Syntax FormalSystem.PlusLanguage in
/-- **THE BRIDGE CHECK, mechanical.** A `ParamsOk` in hand discharges the added hypothesis in the
bundled form the path forth's binder list would carry. If the bridge were dropped or restated at
a different shape this would fail to elaborate. -/
example {Q : Type} [Fintype Q] {step : Q → Q → Bool} {pend : Q → Bool}
    {lab : Q → Atom → Bool} {φ : PlusFormula} {Tc Tn P B : ℕ}
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    ∀ l ∈ objCycleLens step pend, l ∣ (P + 1) :=
  objHalfK1_of_paramsOk hp

open FormalSystem.Metalogic.Decidability.RaySummary in
/-- **THE RESTRICTION CHECK on count move 1.** The move is instantiated with its register offset
and its countdown offset BOTH read off the conclusion and BOTH equal to the same positive `l`, so
the gap `n - c` is carried unchanged. A version that moved the countdown while leaving the
register alone — the shape every earlier round's register obstruction took — would not typecheck
here. -/
example {Q : Type} [Fintype Q] {step : Q → Q → Bool} {pend : Q → Bool}
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (t : ℤ)
    (hpast : ∀ p : ℤ, p ≤ t → pend (objAt g p) = true)
    (hroom : Fintype.card Q ≤ cntAt g t)
    {P : ℕ} (hK1 : ∀ l ∈ objCycleLens step pend, l ∣ (P + 1)) :
    ∃ (l : ℕ) (g' : ℤ → LadderState Q pend), 0 < l ∧ l ∣ (P + 1) ∧
      IsLadderPath step pend g' ∧ objAt g' t = objAt g t ∧
      ((nxtAt g' t : ℤ) - cntAt g' t = (nxtAt g t : ℤ) - cntAt g t) := by
  obtain ⟨l, g', hl, hdvd, hg', ho, hc, hn⟩ := exists_lengthened_region hg t hpast hroom hK1
  exact ⟨l, g', hl, hdvd, hg', ho, by rw [hc, hn]; push_cast; ring⟩

end BimodalTest.Metalogic
