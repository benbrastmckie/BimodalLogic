/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfZoneFlattenNavigable
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfEFold
import FormalSystem.Metalogic.WeakCanonical.PriorDefs
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationClosure
import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop42Vacuity
import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop42Contentful
import FormalSystem.Metalogic.WeakCanonical.Kamp.Lemma53
import FormalSystem.Metalogic.WeakCanonical.Kamp.Section5Correspondence
import FormalSystem.Metalogic.WeakCanonical.Kamp.DedekindINF
import FormalSystem.Metalogic.WeakCanonical.Kamp.Lemma53Faithful
import FormalSystem.Metalogic.WeakCanonical.Kamp.Lemma53FaithfulPast
import Mathlib.Data.List.Permutation
-- NOTE: `import ...Kamp.Lemma53FaithfulPast` lands the import edge for the SINCE/`HasDedekindSUP`
-- MIRROR of the faithful eq (5.2) primitives (Rabinovich 2014, PDF p.8, mirrored). `Lemma53Faithful`
-- above is entirely future-directed; `kminus` (`PriorINF.lean:98`) was declared with no
-- object-language spelling and no correctness lemma anywhere in the tree, so `HasDedekindSUP`
-- (`DedekindINF.lean:153`) could be stated but none of its content could be used. This module
-- supplies `kminusFormula`/`kminus_formula_correct`, `kminusPred`/`kminusPred_eval`,
-- `HasDedekindSUP.last_occ_tp`, the right-end chain primitives
-- (`orderedPointsExist_combine_right`, `orderedPointsExist_combine_kminus`,
-- `orderedPointsExist_widen_right`) and the SUP-side exclusion route
-- (`HasAttainedSUP.toHasDefinableSUP`, `hasDefinableSUP_excludes_kminus`,
-- `prior_makes_kminus_disjunct_unreachable`). NO hypothesis absent from p.8 is introduced: Since
-- is interpreted natively by `Formula.snce` (`Table.lean:198`), so `K⁻` is TL-definable exactly as
-- `K⁺` is. Like the INF direction, the past mirror is NOT observable by any current consumer —
-- `prior_makes_kminus_disjunct_unreachable` proves the `K⁻` boundary disjunct is dead on every
-- Prior structure. The edge exists for the same reason as the `Lemma53Faithful` edge: parking it
-- in `Kamp/Boneyard/` would put it under no glob and in no CI build, so both the mirror and its
-- exclusion theorem would rot invisibly. The module contains **no sorries** and every declaration
-- is axiom-clean. Cycle-free: Lemma53FaithfulPast imports only `...Kamp.DedekindINF`, already in
-- this file's transitive closure.
-- NOTE: `import ...Kamp.Lemma53Faithful` lands the import edge for the FAITHFUL THREE-DISJUNCT
-- LEMMA 5.3 (Rabinovich 2014, PDF p.8): `negChainOnFaithful` / `negChainOnFaithful_iff` and
-- `lemma53Faithful`, which restore the paper's printed disjunct (2) `K⁺(P₁)(z₀) ∧ Oₙ(rest)` that
-- the landed `negChainOn` (`EANegationFix/OnBuilder.lean:179`) truncates away, over the faithful
-- `HasDedekindINF` carrier rather than `HasAttainedINF`. The edge exists for the same reason as
-- the `DedekindINF` edge below: parking it in `Kamp/Boneyard/` would put it under no glob and in
-- no CI build, so the faithful transcription — and, worse, the two NON-VACUITY declarations that
-- make it auditable (`lemma53Faithful_perPoint_is_VACUOUS`, the failed-vacuity control, and
-- `prior_makes_disjunct2_unreachable`, the exclusion stated as a theorem) — would rot invisibly.
-- The module contains **no sorries** and every declaration is axiom-clean. Cycle-free:
-- Lemma53Faithful imports `...Kamp.DedekindINF`, `...Kamp.VecEAConjFull` and
-- `...Kamp.VecEAClosure`, all already in this file's transitive closure.
-- NOTE: `import ...Kamp.DedekindINF` lands the import edge for the FAITHFUL DEDEKIND CARRIER
-- (Rabinovich 2014, eq (5.2), PDF p.8): `HasDedekindINF`/`HasDedekindSUP`, the four compatibility
-- shims from the landed carriers, `prior_hasDedekindINF`/`prior_hasDedekindSUP` (the live-path
-- boundary), and the machine-checked strictness delta against `HasDefinableINF`. Of the re-base
-- onto that carrier, **Lemma 5.3 is DONE** — see the `Lemma53Faithful` edge above — while
-- **Lemma 5.1 / Prop 4.2 remain DEFERRED, not done**. Both the landed part and the deferred part
-- are still unobservable to every current consumer, because the live chain is Prior structures
-- where attainment holds outright (`prior_makes_disjunct2_unreachable` proves exactly that).
-- This edge exists for the same reason as the Section5Correspondence
-- and Prop42Vacuity edges below, and one more: the DEFERRED note itself must be reachable.
-- Parking the carrier in `Kamp/Boneyard/` would put it under no glob and in no CI build, so both
-- the carrier and the record of what remains undone would rot invisibly — the exact failure mode
-- those two guards were created to prevent. The module contains **no sorries**; the deferred
-- targets are recorded as prose and in the follow-up task, never as `sorry`-bodied theorems.
-- Cycle-free: DedekindINF imports `...Kamp.PriorINF` and `...Kamp.Lemma53`, both already in this
-- file's transitive closure.
-- NOTE: `import ...Kamp.Section5Correspondence` lands the import edge for the SECTION 5
-- CORRESPONDENCE GUARD: the page-cited table mapping Rabinovich's Section 5 (PDF pp.7-11) onto
-- the `EANegationFix/` names that already transcribe it, plus `prop42_contentful_of_attained`
-- (the contentful Prop 4.2, discharged at the attained carrier from `VVecEA2.negFix_iff`).
-- This edge is the whole point of that file, for the same reason as the Prop42Vacuity edge
-- below: the Section 5 transcription was discoverable by grep for thirteen months and was
-- nonetheless re-planned from scratch by successive agents, one of which marked six present,
-- sorry-free rows ABSENT. An unreachable table rots silently; a reachable one breaks the build.
-- Cycle-free: Section5Correspondence imports `...Kamp.Prop42Contentful` and
-- `...Kamp.EANegationFix.VecEANegFix`, both already in this file's transitive closure, and
-- Prop42Contentful is not in VecEANegFix's closure.
-- NOTE: `import ...Kamp.Lemma53` lands the import edge for the Lemma 5.3 transcription
-- (Rabinovich 2014, PDF p.8): the printed Basis, the `K⁺` canonical-expansion atom, and
-- `hasDefinableINF_excludes_kplus` — the machine-checked finding that `HasDefinableINF`
-- (`PriorINF.lean:108`) is too strong a carrier for eq (5.2) because it deletes the paper's
-- disjunct (2). That finding is the reason this edge matters: an unreachable refutation
-- protects nothing, which is the lesson `Prop42Vacuity` exists to encode. Cycle-free: Lemma53
-- imports only `...Kamp.VecEAFormula` and `...Kamp.PriorINF`, both already in this file's
-- transitive closure.
-- NOTE: `import ...Kamp.Prop42Contentful` lands the import edge for the CONTENTFUL Prop 4.2
-- target — the statement `Prop42Vacuity` says the tree lacks — plus the two endpoint cases
-- (Rabinovich 2014, Lemma 5.1 Case 1, PDF p.9) and the Section 5 dependency map. Same
-- reasoning as the Prop42Vacuity edge below: an unreachable target protects and records
-- nothing. Cycle-free: Prop42Contentful imports only `...Kamp.VecEAFormula`.
-- NOTE: `import ...Kamp.Prop42Vacuity` lands the import edge that makes the Prop 4.2 vacuity
-- guard REACHABLE from `FormalSystem.lean`, so CI compiles it. This edge is the whole
-- point of that file: a guard sitting in an unreachable directory protects nothing (that is
-- precisely how the same finding, recorded at `Boneyard/NegationIndep.lean:357-364`, went
-- unread). Prop42Vacuity proves that `neg_2var_vec_ea`'s conclusion — re-exported by this
-- file's neighborhood via `NavigatedSpine.reflatten_neg_step` — follows from NO hypotheses,
-- and so carries no content about negation. Cycle-free: Prop42Vacuity imports only
-- `...Kamp.VecEAFormula`, already in this file's transitive closure via EANegationClosure;
-- nothing in VecEAFormula's closure imports this file. It is a leaf: no declaration here or
-- downstream consumes `prop42_conclusion_is_vacuous`, so the edge is inert to the build
-- beyond forcing the guard to compile.
-- NOTE: `import ...Kamp.EANegationClosure` lands the import edge
-- authorized by plan v6 (report 05 §d, verified on paper; compile-verified this dispatch).
-- Cycle-free: only KampPrior imports this file, and EANegationClosure's transitive closure
-- (EANegation, VecEAClosure, VecEAFormula, PriorINF, ExistsForallNF, PriorDefs, MonadicFO,
-- Table) reaches neither KampPrior nor this file. It transitively supplies PriorINF
-- (`HasAttainedINF`/`prior_hasAttainedINF`, PriorINF:202/:224) and the Lemma 5.1/Cor 5.4/
-- Prop 4.2 negation-stack assets consumed by Phases 13.2-13.4.
-- NOTE: `import ...WeakCanonical.PriorDefs` supplies
-- `SemanticPriorUZ`/`SemanticPriorSZ` (PriorDefs:22/:33) for the F2 decision-probe verdict
-- record at the bottom of this file. Cycle-free: PriorDefs imports only `...WeakCanonical.Table`
-- (already in this file's transitive closure); nothing in PriorDefs' closure imports this file.
-- NOTE: `import Mathlib.Data.List.Permutation` supplies
-- `List.mem_permutations` (arrangement-disjunct membership ↔ `List.Perm`), consumed by the
-- soundness direction of the V-carrier. Mathlib-only; no project-file import added.
-- NOTE: `import ...Kamp.NfEFold` is cycle-free — NfEFold imports only
-- `...WeakCanonical.NormalForm` and `...Kamp.NfDepth0Generalized` (NfEFold.lean:1-2), neither of
-- which imports this file. It supplies the E[Σ]-fold assets (`efoldOfNf1`,
-- `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, the depth-0 split kit) consumed by the
-- k=1 fold carrier `bracketEndCharK1` below.
-- NOTE: `import ...KampPrior` was REMOVED to break the import cycle that blocked
-- wiring this bridge into `KampPrior.lean:391`. The two symbols this file used from KampPrior
-- (`nfQuantClauseTl`/`_correct`, `atomKind_arity1_is_pred`) were relocated to
-- `NfDepth0Generalized` and reach here transitively via `NfZoneFlattenNavigable`.
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2V
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.NavigatedSpine
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorZoneTriage
-- NOTE: `import ...NfMultiAnchorBridge.ExteriorBracket` lands the
-- adjacent exterior brackets + enriched composed gate `bracketEndCharKvE2Ext` on the live
-- import path. Cycle-free: ExteriorBracket is a leaf importing only OuterGate (above) and
-- Kamp.ExteriorNegationPast → Kamp.ExteriorNegation → SharedWitness/ExteriorZoneTriage
-- (all already in this file's transitive closure); nothing in that closure imports this
-- file. This edge also brings the Phase-3..6 clause-family files into the root build.
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracket
-- NOTE: thread the general-`k` gate + the obligation-carrying EndInterval
-- consumer reshape into the root build. `ExteriorGateAssembleK` transitively pulls the
-- general-`k` interior/exterior modules (`InteriorGateGeneralK`, `ExteriorBracketAssembleK`,
-- `ExteriorConverter{,Past}K`); `EndIntervalConsumerK` hosts the reshaped
-- `endIntervalPrior`/`EndIntervalCorrectPrior`/`endInterval_step_correct`. Both are acyclic leaves
-- below `ExteriorGateAssembleK`; nothing in that closure imports this aggregator. This makes the
-- general-`k` discharge lemma + consumer reachable from `KampPrior` (which imports this file).
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.EndIntervalConsumerK
-- NOTE: thread the aggregate quantEnd/seg construction + the six
-- k=0/k=1 arm-correctness hook-discharge lemmas into the root build. Cycle-free:
-- `AggregateHookDischarge` is an acyclic leaf importing `EndIntervalConsumerK` (above) and
-- `Kamp.NfToVecEA` (whose closure — VecEATranslation, NormalForm, KampTranslation,
-- PriorDefs — is already reachable and imports nothing under `NfMultiAnchorBridge`);
-- only `KampPrior` imports this aggregator (the single-consumer policy for this bridge).
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregateHookDischarge
-- NOTE: thread the (0,1) point-channel merge variant of the gated
-- anchor-collapse (Lemma 3.2(2) coincident-witness collapse at `w = x`: gate + clause iff
-- + dite carrier + n=2 fold characterization, plus the R9 genericity probe) into the root
-- build for the Phase-16 `w = x` dispatcher channel. Cycle-free: `AggregatePointMergeK1`
-- is an acyclic leaf importing only `AggregateHookDischarge` (above); nothing in that
-- closure imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregatePointMergeK1
-- NOTE: thread the E1 exterior fiber kit (the 7-zone fiber partition
-- of the depth-1 fold at n=3, env [w,x,t]: `extZoneFiber_k1`, the routing lemma
-- `extZone_consistent_lt` + inconsistent-fiber falsity `extZone_inconsistent_false`, and
-- the R3 single-fiber adjudication probe `extProbe_clause_iff`) into the root build for
-- the Phase 14a-14c exterior navigated carriers. Cycle-free: `ExteriorFiberKitK1` is an
-- acyclic leaf importing only `AggregateHookDischarge` (above); nothing in that closure
-- imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberKitK1
-- NOTE: thread the E2 Since-navigated w-package (`navPackLeft` +
-- the fold iff `navPackLeft_correct`, the Lemma 7.10 / Prop 3.5 one-free-variable fold of
-- the w-dependent fibers into a single TemporalPred at the pin x) into the root build for
-- the Phase 14b/14c distribution and `∃w` pin glue. Cycle-free: `ExteriorNavPastK1` is an
-- acyclic leaf importing only `ExteriorFiberKitK1` (above) and the upstream
-- `Kamp.Translation`; nothing in that closure imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNavPastK1
-- NOTE: thread the E5 future-exterior mirror (the t<w channel: the
-- future zone kit `extZoneFiberFut_k1`, the Until-navigated w-package `navPackRight` +
-- fold iff, the distribution `navDistribRight`, and the carrier `CExtFut` +
-- `CExtFut_correct` + 3-bot falsity trio; E6 `extDuality` NOT landed — duplication
-- fallback recorded in the module docstring) into the root build for the Phase-16a
-- dispatcher's t<w channel. Cycle-free: `ExteriorNavFutK1` is an acyclic leaf importing
-- only `ExteriorNavPastK1` (above); nothing in that closure imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNavFutK1
-- NOTE: thread the off-diagonal k=1 zone classifier + per-qnf
-- dispatcher (the 6-way row classification `aggOdClassify` + mirror `aggOdClassifyF`,
-- the routing totality `aggOdZone3_route_of_eval`, the two-pin reading
-- `agg2Past_holds_pin_iff`, the point/interior channel carriers `CAggPtX`/`CAggPtT`/
-- `CAggInt`, and the dispatcher `CAggOd` + master clause iff `CAggOd_clause_iff`) into
-- the root build for the Phase-16b `aggPop1` fold. Cycle-free: `AggregateOffDiagK1` is
-- an acyclic leaf importing only `VecEAConjFull`, `EANegationFix`,
-- `AggregatePointMergeK1`, `ExteriorNavPastK1`, `ExteriorNavFutK1`, and
-- `AggregateHookDischarge` (all above or outside this aggregator's closure); nothing
-- in that closure imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregateOffDiagK1
-- NOTE: thread the full-iff conjunction closure kit
-- (`BracketFormula.snoc_holds_iff`, `BracketFormula.conjFull_iff`, `VVecEA2.conjFull_iff`,
-- `VVecEA2.trivialTrue`) into the root build for the Phase 8-11 fixed-formula negation
-- stack and the Phase-16 `aggPop1` conjunction fold. Cycle-free: `VecEAConjFull` is an
-- acyclic leaf importing only `Kamp.VecEAClosure` (→ VecEAFormula → ExistsForallNF), all
-- already in this file's transitive closure via `EANegationClosure`; nothing in that
-- closure imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAConjFull
-- NOTE: thread the fixed-formula Lemma 5.3 On-builder
-- (`negChainOn`, `negChainOn_iff`, `orderedPointsExist_combine`, `chainAllTrue`) and the
-- PriorINF `HasAttainedSUP`/`prior_hasAttainedSUP` mirror into the root build for the
-- Phase 9-11 negation stack. Cycle-free: `EANegationFix` imports only `Kamp.VecEAConjFull`
-- and `Kamp.EANegation`, both already in this file's transitive closure; nothing in that
-- closure imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix
-- NOTE: `import ...Kamp.VecEACombinators` lands the import edge for the two `VVecEA2`
-- combinators the `VBracketFormula` layer already had and the `VVecEA2` layer did not:
-- `VVecEA2.conjEverywhere`/`_holds_iff` (PDF p.6, Prop 4.2/4.3 conjunction closure) and
-- `VVecEA2.concatPin`/`_holds_iff` (PDF p.9, the Case 3 pinned split of Lemma 5.1). The
-- `concatPin` here differs from `VBracketFormula.concatPin` in the one way that matters:
-- it carries `veaL.endpointRight` and `veaR.endpointLeft` THROUGH the pin point rather
-- than discarding them, which is what makes its `_holds_iff` a biconditional. The module
-- is carrier-neutral — it names no `HasDedekind*`/`HasAttained*` hypothesis. Cycle-free:
-- `VecEACombinators` imports only `Kamp.VecEAConjFull` and `Kamp.EANegationFix.ConcatPin`,
-- both already in this file's transitive closure above; nothing in that closure imports
-- this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEACombinators
-- NOTE: `import ...Kamp.EANegationFixFaithful.BoundedFixFaithful` lands the import edge for
-- Rabinovich's Cor 5.4(1)/(2) as printed on PDF p.9 — `¬F₀(z₀) ∨ Oₙ(F₁,…,Fₙ,z₀,z₁)` and its
-- mirror — at `VVecEA2` over the faithful `HasDedekindINF` carrier. The head disjunct is the
-- paper's endpoint condition carried in `VecEA2.endpointLeft`/`endpointRight`, NOT the
-- attained-first/last-`¬β` interval encoding (`rightPinBracket`/`leftPinBracket`) that the
-- endpoint-free `VBracketFormula` result type of `EANegationFix/BoundedFix.lean` forces. That is
-- what drops `HasAttainedINF` to `HasDedekindINF` in Cor 5.4(1) and drops `HasAttainedSUP`
-- entirely from Cor 5.4(2). Nothing in `EANegationFix/` is edited: `negBoundedRightFix(_iff)` and
-- `negBoundedLeftFix(_iff)` stay live and consumed, and the attained hypotheses still reach these
-- statements through `HasAttainedINF.toHasDedekindINF`. Cycle-free: the module imports only
-- `Kamp.EANegationFix.BoundedFix` and `Kamp.Lemma53Faithful`, both already in this file's
-- transitive closure above; nothing in that closure imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.BoundedFixFaithful
-- NOTE: `import ...Kamp.EANegationFixFaithful.BoundedFixAnchoredFaithful` lands the import edge
-- for the ANCHORED mirrors of the same pair (PDF pp.9-10): Cor 5.4(1)/(2) at an arbitrary anchor
-- `α` sitting at the moving endpoint, which is Rabinovich's own `Fₙ := αₙ` (PDF p.9) read at the
-- peeled outermost point type, and the shape Figure 1 (PDF p.10) puts to work at its split point.
-- Same head redesign as the unanchored module — the printed endpoint condition in
-- `VecEA2.endpointLeft`/`endpointRight` instead of the `rightPinBracket`/`leftPinBracket` attained
-- encoding — which drops `HasAttainedINF` to `HasDedekindINF` in anchored Cor 5.4(1) and drops
-- `HasAttainedSUP` entirely from anchored Cor 5.4(2). Nothing in `EANegationFix/` is edited:
-- `negBoundedRightFixAnchored(_iff)` and `negBoundedLeftFixAnchored(_iff)` stay live and consumed,
-- and the attained hypotheses still reach these statements through `HasAttainedINF.toHasDedekindINF`.
-- Cycle-free: the module imports only `Kamp.EANegationFix.BoundedFixAnchored` and
-- `Kamp.EANegationFixFaithful.BoundedFixFaithful`, both already in this file's transitive closure
-- above; nothing in that closure imports this aggregator.
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.BoundedFixAnchoredFaithful
-- NOTE: `import ...Kamp.EANegationFixFaithful.NegFixOneFaithful` lands the import edge for LEMMA
-- 5.1 AT ONE WITNESS over the faithful carrier (Rabinovich 2014, PDF pp.9-10): `negFixOneFaithful`
-- with its cover and `_iff`, plus `HasDedekindINF.first_occ_tp` and the eq (5.3) pieces
-- (`infPinPoint`, `allSeg`, `somePointBlock`). Unlike the two anchored/unanchored Cor 5.4 modules
-- above, this one is NOT the landed attained formulation with the carrier swapped: `negFixOne`
-- (`EANegationFix/NegFixOne.lean:90`) is a six-disjunct list `{A,B1,B2,B3,B4,B4′}` of the tree's
-- own devising whose cover pins FOUR attained points, none of which occurs in the paper, whereas
-- Rabinovich's Lemma 5.1 proof is a three-case split pinning exactly one point — the eq (5.3)
-- infimum of `¬β₁`, which is eq (5.2) of p.8 read at `P := ¬β₁`. The module therefore transcribes
-- the paper's cases and drops BOTH attained hypotheses: `HasDedekindINF` alone, where
-- `negFixOne_iff` (`EANegationFix/NegFixOne.lean:353`) needs `HasAttainedINF` AND `HasAttainedSUP`.
-- The edge also protects `NegFixOneFaithfulGateProbe`, the `ℝ` counterexample proving the
-- six-disjunct list is not a cover once attainment is dropped (the structure discharges the
-- faithful eq (5.2) obligation at the pinned predicate and refutes the attained one) — an
-- exclusion theorem of the same class as `prior_makes_disjunct2_unreachable`, which would rot
-- invisibly under `Kamp/Boneyard/`. Nothing in `EANegationFix/` is edited: `negFixOne`,
-- `negFixOne_cover`, `negFixOne_iff` and the `ℤ` probe `NegFixGateProbe` stay live and consumed
-- (`NfMultiAnchorBridge/Base.lean:1416` cites them). The module contains no sorries and every
-- declaration is axiom-clean. Cycle-free: it imports `Kamp.EANegationFix.NegFixOne`,
-- `Kamp.EANegationFixFaithful.BoundedFixAnchoredFaithful` and `Kamp.VecEACombinators`, all already
-- in this file's transitive closure above, plus `Mathlib.Data.Real.Basic` /
-- `Mathlib.Tactic.Linarith` for the probe's carrier.
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.NegFixOneFaithful
-- NOTE: `import ...Kamp.EANegationFixFaithful.NegFixListFaithful` lands the import edge for
-- LEMMA 5.1's RECURSION over the faithful carrier (Rabinovich 2014, PDF pp.10-11):
-- `negFixListFaithful` with `negFixListFaithful_nil_iff` and `negFixListFaithful_iff`, plus the
-- `VVecEA2` pinned-DNF machinery (`VecPinnedItem`, `vecPinnedConj`, `vecPinnedConjAll`,
-- `vecPinnedListToV`) that the `VBracketFormula` version at `EANegationFix/NegFix.lean:298`-`:426`
-- has no lift for. This is the inductive step of the very argument `NegFixOneFaithful` settles at
-- one witness, and unlike that module it IS the landed attained formulation with the carrier
-- swapped: `negFixList`'s Case 2 / Case 3 disjuncts and the whole carrier-free `Aᵢ`/`Bᵢ` split
-- (`splitsAt` / `bracketOf_splitsAt_iff`, PDF pp.10-11) are reused unchanged. What the faithful
-- carrier ADDS is a third, top-level disjunct — Case 1, `K⁺(¬β₁)(z₀)` (PDF p.9) — because
-- `HasDedekindINF.first_occ` preserves Rabinovich's printed disjunction where the attained
-- `firstNegPin_or_all` (`EANegationFix/NegFix.lean:137`) collapses it to a two-way dichotomy. The
-- edge also protects `negFixListFaithful_case1_is_indispensable`, which machine-checks that under
-- `K⁺(¬β₁)(z₀)` the other two disjuncts are both UNSATISFIABLE, so the added gate is load-bearing
-- rather than dead syntax admitted for type-checking — an exclusion artifact of the same class as
-- `prior_makes_disjunct2_unreachable`. Carrier result: `HasDedekindINF` ALONE, where
-- `negFixList_iff` (`EANegationFix/NegFix.lean:520`) needs `HasAttainedINF` AND `HasAttainedSUP`.
-- Nothing in `EANegationFix/` is edited; `negFixList` and `negFixList_iff` stay live and consumed.
-- The module contains no sorries and every declaration is axiom-clean. Cycle-free: it imports only
-- `Kamp.EANegationFix.NegFix` and `Kamp.EANegationFixFaithful.NegFixOneFaithful`, both already in
-- this file's transitive closure above.
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.NegFixListFaithful
-- NOTE: `import ...Kamp.EANegationFixFaithful.VecEANegFixFaithful` lands the import edge for the
-- PROP 4.2 / 4.3 LIFT CHAIN over the faithful carrier (Rabinovich 2014, PDF p.6 for the two lift
-- steps, pp.10-11 for the bracket leg it consumes): `BracketFormula.negFixFaithful` →
-- `VecEA2.negFixFaithful` → `VVecEA2.negFixFaithful`, each with its `_iff`. It mirrors the landed
-- attained chain (`EANegationFix/NegFix.lean:479`, `EANegationFix/VecEANegFix.lean:67`/`:154`)
-- declaration for declaration, with one structural difference that is the migration's whole point:
-- the attained `VecEA2.negFix` MAPS its bracket leg under `⊤` endpoints, because a
-- `VBracketFormula` disjunct has no endpoint slots; the faithful bracket leg is already a list of
-- `VecEA2` disjuncts, so it is spliced VERBATIM and no endpoint predicate is erased. The edge also
-- protects the three declarations that machine-check what the `_iff` statements are silent about —
-- `VecEA2.mem_negFixFaithful_disjuncts` and `VecEA2.negFixFaithful_of_bracket` (no disjunct is
-- dropped or `⊤`-erased at the lift) and `VecEA2.negFixFaithful_carries_limit_gate` (the added
-- Case 1 `K⁺(¬β₁)(z₀)` disjunct, PDF p.9, still forces the top of the chain). A lift that silently
-- collapsed the faithful recursion's three disjuncts to two would prove the same biconditionals,
-- so those three are the non-vacuity content here. Carrier result: `HasDedekindINF` ALONE, where
-- `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:183`) needs `HasAttainedINF` AND
-- `HasAttainedSUP`; the only shim used runs attained → faithful
-- (`VVecEA2.negFixFaithful_iff_of_attained`), never the reverse. Nothing in `EANegationFix/` is
-- edited; `VecEA2.negFix` and `VVecEA2.negFix_iff` stay live and consumed. The module contains no
-- sorries and every declaration is axiom-clean. Cycle-free: it imports only
-- `Kamp.EANegationFixFaithful.NegFixListFaithful`, already in this file's transitive closure
-- directly above.
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.VecEANegFixFaithful
-- NOTE: `import ...Kamp.Prop42Faithful` lands the import edge for the TERMINUS OF THE FAITHFUL
-- RE-BASE (Rabinovich 2014, Proposition 4.2, PDF p.6): `prop42_contentful_of_dedekind`, which
-- discharges the SAME contentful target `Prop42Contentful` (`Prop42Contentful.lean:151`) that
-- `prop42_contentful_of_attained` (`Section5Correspondence.lean:128`) discharges, but from
-- `HasDedekindINF` ALONE where that one needs `HasAttainedINF` AND `HasAttainedSUP`. p.6 states
-- Prop 4.2 "over Dedekind complete chains" in the statement itself, which is the fidelity point
-- the whole re-base turns on. `prop42_contentful_of_attained_inf_only` records the consequence:
-- the landed attained theorem is now a corollary whose `HasAttainedSUP` argument is unused.
-- The edge also protects the three declarations that make the result AUDITABLE, which is why it
-- cannot be parked in `Kamp/Boneyard/` (no glob, no CI, silent rot):
-- `prop42Faithful_perPoint_is_VACUOUS` (the failed-vacuity control re-run against the FINAL
-- statement — the per-point `∃ v'` ordering is provable from NO carrier hypothesis at all, which
-- is what makes the hoisted ordering the actual content), `prop42_witness_exposes_negFixFaithful`
-- and `prop42_witness_carries_limit_gate` (the `∃ v'` hides the witness, so a construction that
-- had dropped the paper's Case 1 `K⁺(¬β₁)(z₀)` gate would prove the headline theorem verbatim;
-- these two name the witness and prove the gate still fires in it). Finally
-- `prop42_faithful_unobservable_on_prior` is the re-base's CUMULATIVE EXCLUSION statement: on
-- every Prior structure the restored disjunct (2) and its `K⁻` dual are BOTH provably dead, so no
-- current consumer can observe the difference — observability needs a genuinely non-attained
-- Dedekind-complete frame class, which this tree does NOT build. That honest limit must stay
-- reachable, not rot. Nothing in `EANegationFix/` is edited; the attained stack stays live and
-- consumed. The module contains **no sorries** and every declaration is axiom-clean. Cycle-free:
-- it imports `Kamp.Prop42Contentful`, `Kamp.EANegationFixFaithful.VecEANegFixFaithful` and
-- `Kamp.Lemma53FaithfulPast`, all already in this file's transitive closure.
import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop42Faithful

/-!
# Multi-Anchor Characteristic Formula Bridge

A new **leaf** file (nothing imports it; it imports nothing beyond
`NfZoneFlattenNavigable` — which transitively pulls `VecEATranslation`,
`NfZoneDepthK`, `NfDepth0Generalized` — and `KampPrior`). It hosts the
sorry-free depth-graded two-anchor characteristic-formula bridge deliverables.

## Deliverables (built across the multi-anchor bridge phases)
1. `nfChar2Formula : NormalForm sig (k+1) 2 → Formula` (Phase 3).
2. `NfZoneFlattenNavigable` at arbitrary depth `k` (Phase 5).

## This file — Phase 1 (bottom-of-recursion bases)
- `nf_char2_atom_layer`: the **diagonal depth-0 atom-layer** iff — the depth-0
  characteristic formula of an arity-1 NF characterizes the arity-2 evaluation of
  its diagonal value-duplication `diagDup` on the constant env `[t,t]`. Built from
  `nfDepth0CharFormula` + `diagDup_eval_zero` (i.e. `renameNF_eval_diag0`).
- `nf_zone_flatten_navigable_zero`: the `k = 0` base of deliverable 2 — the arity-3
  tail-diagonal existential of a duplicated NF `diagDup3` on `[w,t,t]` equals the
  arity-2 existential on `[w,t]`. Endpoints are atom/anchor types via
  `renameNF_eval_diag0`; **no `bracketBuild*` navigation yet**.

## Postmortem forbidden-route list (BINDING — read before writing any construction)

Every future dispatch on this file MUST check each candidate construction against
these three refuted routes (the Phase-11b projection lineage + the import-cycle blocker audit):

- **(a) Do NOT** re-attempt a projection-based VecEA2 bridge for the `x=t` diagonal
  case. `liftIdx(totalUnskip)` is non-injective; the coupled quant layer does not
  factor through per-variable projections. Split the coupled `∃w` **directly** on the
  full env `[w,x,t]` (`exists_nested_split3` / `exists_trichotomy_split`) and discharge
  through `nf_char3_eq_succ_iff`'s joint decomposition — never per-variable projection.
- **(b) Do NOT** re-attempt a flat single-interval atomic bracket absorption. A depth-0
  atomic `BracketFormula` is confined to `[x,t]` and cannot capture exterior-`w`
  realizability. Endpoint types MUST be **navigated** recursive `bracketBuild*`
  `TemporalPred`s, not depth-0 atomic brackets.
- **(c) Do NOT** re-attempt an arity-1-collapse repair for the diagonal arm
  (`char_k1 (diagCollapse sub_nf)`). At depth `k+1` this is the documented **non-theorem**
  (`NfDepth0Generalized.lean:1691-1719`; `liftIdx r` non-injective, `←` fails).

**Settled**: the diagonal collapse (`renameNF_eval_diag0`) is used **only at the depth-0
atom layer**, where it is a proven iff. The depth-`(k+1)` quant layer goes through the
honest arity-3 navigated existential — **never** collapsed to arity 1.

## References
- Rabinovich 2014, "A Proof of Kamp's Theorem", Cor 5.4 (`F_i` chain).
- The multi-anchor characteristic-formula bridge design and its blocker research: the deliverable
  list, the phase split, and the three refuted routes above are transcribed from them verbatim.
-/
