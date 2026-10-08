# Implementation Plan: Task #711

- **Task**: 711 - Universal-summary substrate for the `⊡` fibre check on the seam-gluing route
- **Status**: [IMPLEMENTING] (revised v2; Phase 1 carried closed, Phases 2-9 re-scoped onto the Büchi-chain route)
- **Effort**: 16 hours (1.5 spent in Phase 1; 14.5 remaining)
- **Dependencies**: 732 (satisfied — E3 reported). 736 (no dependency edge; its report is integrated here as the revision's primary input)
- **Research Inputs**:
  - specs/711_universal_summary_substrate_stab_fibre/reports/01_universal-summary-substrate.md
  - specs/736_cslib_omega_automata_survey_and_e3_reopen_check/reports/01_cslib-omega-automata-survey.md
  - specs/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md
- **Reports Integrated**: 01_universal-summary-substrate.md (v1); 01_cslib-omega-automata-survey.md, 01_cslib-omega-automata-survey-summary.md (v2)
- **Artifacts**: plans/02_buechi-chain-ktype-substrate.md (this file); supersedes plans/01_universal-summary-substrate.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build the universal-summary substrate as a **step-for-step instantiation of Büchi's
complementation chain in this tree's monadic k-type idiom**, replacing v1's from-scratch
`FwdPresentation`/`Profile`/splice construction. Task 736 established, machine-checked, that
Büchi complementation *is* the time-axis Ramsey-coloured interval-summary device — candidate (d)
— and that **this tree already instantiates that device on the MSO side**, over ⟨ℤ,<⟩, with the
monadic k-type of a segment in place of a congruence class. The substrate's job is therefore not
to invent a device but to take the four chain steps this tree already owns, make them public and
named, and close the one step it does not: **saturation**.

The route skips the `LTS`/`ωSequence`/`ωLanguage` automata stack entirely — which is exactly
where 736 measured the 7,526-line port cost — and reuses: `KType`/`kTypeOf`/`KEquiv`
(`WeakCanonical/NEquivalence.lean`) as the finite-index right-congruence analogue; `segZ` and
`zFiber` as the segment and block carriers; `exists_zFactorization` (today private inside
`GroupModel/RamseyFactorization.lean`) as the Ramsey cover, already proved via
`infinite_ramsey_pairs`; `kEquiv_zFiber_segSum` (also private there) as "a block is the ordered
sum of its segments"; and `kEquiv_orderedSum_of_kEquiv_colour` (`MixedSum.lean`) as the mixing
lemma that turns a statement about segment types into a statement about whole blocks.

Definition of done: a public cluster `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`
carrying steps 2-5 of the chain sorry-free on standard axioms; a consumer-facing seam interface
under `FormalSystem/Metalogic/Decidability/RaySummary/` that states the `⊡` bridge **against an
abstract realization hypothesis and never discharges it**; headline axiom profiles pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`; two evidence probes wired and the whole
collection green; `bash scripts/check-module-invariants.sh` green.

### Research Integration (v2 — what task 736 changed)

- **The device identity is settled and the confidence bound is raised.** 736 read the *proof
  body*, not a docstring: `Cslib.ωLanguage.IsRegular.compl` runs through `buchiFamily_cover`
  (`Congruences/BuchiCongruence.lean:118`), which colours a pair of time points by the congruence
  class of the segment between them and applies `infinite_graph_ramsey` at line 125. The
  (c)/(d) shared-Ramsey-core claim is **RAISED from LOW-confidence framing to High, proof-level**.
  Consequence adopted: v1's Phase 9 "executability discrimination between (c) and (d)" probe is
  **retired as obsolete** — 736 settled the question it was filed to probe, and recorded the
  settlement at E3's own site (`device-selection-probe.lean`'s RE-AUDIT block). Phase 8 below
  replaces it with a probe that exercises the substrate itself.

- **The gap this task should close is now named.** `RamseyFactorization.lean:358,360` already
  applies `infinite_ramsey_pairs` to `fun a b => kTypeOf sig k (segZ sig c (a : ℤ) (b : ℤ))` —
  pairs of times coloured by the monadic k-type of the segment between them, over ⟨ℤ,<⟩ — but
  uses the result for Ehrenfeucht-Fraïssé order-inflation (`inflate_left`/`inflate_right`), not
  for a summary device. The ingredients are proved and **private**. The task is to publish them
  as a chain and add the missing link.

- **The confidence bound the plan respects.** 736 rates as **High** that complementation *is* the
  Ramsey-over-time device, but only **Medium** that route (c) MSO-over-⟨ℤ,<⟩ *reduces* to it,
  because MSO↔ω-regular is unformalized in **any** proof assistant (cslib has zero MSO: a grep
  over all of `Cslib/` for `MSO`/`MonadicSecondOrder`/`monadic second`/`second-order`/
  `SecondOrder` returns nothing). **No phase leans on that reduction.** It appears exactly once,
  in Phase 7, as a named field of an abstract hypothesis bundle that this task does not discharge.

- **Port nothing; no Lake `require` on cslib.** 736 measured the McNaughton closure at 7,526
  lines across 47 modules against a Mathlib rev **76 commits divergent** from this tree's, with an
  observed break (`invalidField: domRestrict`) on the first ported line and every `grind` call in
  a 147-line ported fragment needing replacement. cslib is cited for shape only, in docstrings,
  never depended on. No phase below adds a dependency, an import, or a transcription.

- **Candidates (a) and (b) stay rejected, on corrected grounds.** (b) Safraless: cslib's
  `BuchiCompl.lean` `complement_language_sub`/`sup`/`eq` (lines 293, 321, 328) are all
  `proof_wanted`, emitting **no declaration** — a `sorry`-grep of 0 on that file is a **false
  negative**, so the construction's correctness is unproved. (a) Safra/Piterman: McNaughton *is*
  proved in Lean (fork-only, `OmegaRegularLanguage.lean:440`; upstream line 259 is
  `proof_wanted`), but what it delivers is an acceptor **over states** — the wrong axis, refuted
  by `Probe732Device.not_lasso_sufficient_on_chain` and
  `PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`.

- **Carried from v1's own report, still live**: the one-sided-live hazard in HWZ Def 12 / Lemma 17
  (a quasistate that is a bare set of types admits a splice creating a realised type the model
  lacked — lethal to a `⊡`-label) is paid in Phase 7's hypothesis bundle, as it was in v1's
  Phase 8, not in the substrate; the atomization licence
  (`Metalogic.Conservativity.plusTruthAt_iff_atomize`) is what lets a consumer take `φ` `⊡`-free
  with a finite alphabet; E2 has no written specification beyond the ranking's falsifier sentence,
  and Phase 9 defines it from that sentence.

### Where this plan's decomposition diverges from the dispatch's table, and why

The revision brief's step map asks for "the `[u]·[v]^ω` family analogue over `segZ`" as step 3
(TO BUILD) and names step 5 saturation as "THE REAL OPEN WORK; the plan's principal deliverable".
Reading the sources leads to a different split, stated here rather than followed silently:

1. **Step 3 is nearer to HAVE than to TO BUILD.** `ZFactorization` (`RamseyFactorization.lean:343`)
   already *is* the ℤ-time-axis analogue of `[u]·[v]^ω`: a monotone cutting sequence `W : ℤ → ℤ`
   covering ℤ, with one k-type `τneg` on every segment below the middle and one k-type `τpos` on
   every segment above it — i.e. `(τneg)^(ω*) · τzero · (τpos)^ω`, the bi-infinite form the time
   axis needs. It is a `private structure` and its existence theorem is `private`. The work is
   **publication plus one added field** (`τzero`, the middle segment's type, currently implicit),
   not construction. Phases 3-4 do that.

2. **Step 5 splits into one tractable half and one that is not this task's to close.** Saturation
   "each family member inside or disjoint from the target set" decomposes as:
   - **(5a) The k-type of a block is a function of its family.** Two blocks whose factorizations
     carry the same triple `(τneg, τzero, τpos)` have *literally the same* colour index order —
     both are ℤ coloured `τneg` below 0, `τzero` at 0, `τpos` above — so the mixing lemma
     `kEquiv_orderedSum_of_kEquiv_colour` applies directly, with `kEquiv_zFiber_segSum` on each
     side. This is real work (≈200-300 lines of glue plus the instance plumbing) but it is
     **assembly of proved parts, not open mathematics**; notably it does **not** need
     `kEquiv_colourStructure_anchored`, because the two colourings coincide pointwise rather than
     merely being anchored-equivalent. Phase 5.
   - **(5b) Saturation proper, for monadic targets.** Given (5a), for any target set cut out by a
     monadic sentence of quantifier depth ≤ k over ⟨ℤ,<⟩ with the block's colouring, each family
     is wholly inside or wholly disjoint from it, and — since there are finitely many triples —
     that target set is a finite union of families. Phase 6. This is Büchi's step 5 and the
     *licensed* part of his step 6.
   - **(5c) Saturation for the `⊡` target is NOT reachable here**, because getting from
     `PlusTruthAt M τ t (.stab φ)` to a depth-≤k monadic sentence over the time axis *is* the
     Medium-confidence MSO reduction 736 bounded. Phase 7 states it as a hypothesis field and
     stops. **The principal deliverable is therefore (5a)+(5b), and the honest residue is named
     rather than attempted.**

3. **Step 6 is out of scope** exactly as the brief says; nothing below mentions
   `Decidable (PlusValidZTime φ)` except to disclaim it.

### Prior Plan Reference

Supersedes `plans/01_universal-summary-substrate.md`. Phase 1 of that plan is
`[COMPLETED WITH EXCLUSIONS]` and is carried into this plan **verbatim and unchanged** as Phase 1.
Its Phases 2-10 were all `[NOT STARTED]` and are retired; see Decisions D-10 to D-13 for what was
kept, what was dropped, and why.

### Roadmap Alignment

`specs/ROADMAP.md` is read, not modified (no `roadmap_flag` on this dispatch). For orientation:
Phase 1 names the critical path **711 → 735** and records that the evidence collection has
several writers (733, 734, 736 and this task), so probes are dispatched singly. 736's own summary
flags two now-stale statements in the ROADMAP's E3 section as an operator hand-off; correcting
them is **not** this task's work.

## Goals & Non-Goals

**Goals**:

- Publish the Büchi chain's steps 2-4 in the monadic k-type idiom as a public cluster under
  `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`, with the finite-index fact
  `kType_finite` and the Ramsey cover `exists_matching_factorization` as named, sorry-free
  theorems on standard axioms.
- Close the chain's step 5 for monadic targets: `kEquiv_zFiber_of_matching_segments` (the mixing
  argument on matched segment types) and `kTypeOf_zFiber_eq_of_sameTriple` (the k-type of a block
  is a function of its family triple), both sorry-free on standard axioms.
- State the `⊡` bridge in `FormalSystem/Metalogic/Decidability/RaySummary/Seam.lean` against an
  abstract realization hypothesis, carrying the Medium-confidence bound in its docstring, and
  discharge nothing.
- Pin every headline axiom profile in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`.
- Write and wire two evidence probes — the substrate exercised on a concrete coloured ℤ-block,
  and E2, the depth-2 stratification probe — and run the whole collection (the collection is the
  gate).
- Correct the falsified `Nat.nth` note in
  `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`.
- Keep every durable anchor resolving: the fully-qualified names `…WeakCanonical.segZ`,
  `…WeakCanonical.infinite_ramsey_pairs`, `…WeakCanonical.inflate_left`/`inflate_right`,
  `Nat.exists_strictMono_const_pair_colour`, `FormalSystem.PlusLanguage.plusStab_iff_omega`,
  `…PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`.

The four backticked declaration identifiers above — `kType_finite`,
`exists_matching_factorization`, `kEquiv_zFiber_of_matching_segments`,
`kTypeOf_zFiber_eq_of_sameTriple` — are exactly the set pinned under
`## Lean Challenge Statements`. See Decision D-14 for why the remaining deliverables are
specified in their phases rather than pinned.

**Non-Goals**:

- Any port from cslib, any transcription of cslib proof text, any Lake `require` on cslib.
- Formalizing MSO syntax or semantics, Büchi's theorem, the MSO↔ω-regular correspondence, or any
  ω-automaton. The `⊡`-to-monadic reduction is a hypothesis field in Phase 7 and is never
  discharged.
- Assembling `Decidable (PlusValidZTime φ)` or any decision procedure for L⁺; discharging the
  Phase 7 hypothesis for the sliced certificate or any concrete frame other than the probe
  fixtures. That is the consumer's (735's) work.
- Any complexity claim, upper or lower. Task 713's ARGUED CTL⋆ 2EXPTIME result is a sanity
  ceiling only and is never a source of an upper bound.
- Any claim that the probed `⊡(Fp)`/`⊡(Pp)` shapes discriminate between devices
  (`Probe732Device`, machine-checked, settled they do not).
- Proving a real-formula `⊡(Pp)` bridge on the Bool fixture (E3's first honest limit stays).
- Editing `.claude/context/**` (deploy artifact) or `specs/ROADMAP.md`; both carry operator
  hand-off items from 736's summary and neither belongs to this task.
- Adding rows to `docs/theorem-index.md`; the headlines are pinned in the test module instead.
  The path stays in `file_scope` unused.
- Relocating the k-type kernel to a task-type-neutral home (e.g. `Metalogic/Expressiveness/`).
  Recorded as a follow-up in the cluster README, not done here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Relocating `segZ`/`ZFactorization`/`kEquiv_zFiber_segSum` out of `RamseyFactorization.lean` breaks `inflate_left`/`inflate_right` or the companion chain | H | M | The new modules keep **namespace `FormalSystem.Metalogic.WeakCanonical` unchanged**, so every fully-qualified name is byte-identical after the move and no alias is needed; `segZ` has exactly one consumer file (grep, Phase 3 re-runs it). `RamseyFactorization.lean` imports the new module. Fallback: leave the declarations in place and merely drop `private`, which delivers the same public surface at the cost of the import-graph hygiene — record the switch and continue; no later phase changes |
| The new cluster's import closure drags `MonoDiscrete`/`GoodGroupable` back in | M | M | The cluster imports `GroupModel/BlockDecomposition.lean` (`zFiber`; imports only `OrderedSum` + Mathlib), `MixedSum.lean` (the mixing lemma; imports `ColourOrders` → `BackAndForth`), `IntegerModel/GoodStructures.lean` (`k_equiv_of_iso`) and `ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`. None of these reaches `MonoDiscrete` or `GoodGroupable`. Phase 3 verifies by `lake build` of the cluster root alone and records the actual closure |
| Phase 5's instance plumbing (`[Finite sig.preds]` vs `[Fintype sig.preds] [DecidableEq sig.preds]`) fights the mixing lemma | M | M | `exists_zFactorization` today carries `[Fintype sig.preds] [DecidableEq sig.preds]` while `kEquiv_zFiber_segSum` carries `[Finite sig.preds]` and opens with `haveI := Classical.decEq …; haveI := Fintype.ofFinite …`. Phase 5 states every new theorem with `[Finite sig.preds]` and reproduces that two-line preamble; if a statement genuinely needs `Fintype`, state it that way and say so in the docstring |
| (5a) turns out to need `kEquiv_colourStructure_anchored` after all, pulling in `MonoDiscrete` | M | L | The two colourings are pointwise equal, so `funext` + `congrArg` should discharge the mixing lemma's hypothesis outright. If not, the anchored lemma applies with `I = J = ℤ`, `aI = aJ = 0`, `(α, β, γ) = (τneg, τzero, τpos)` — a one-line fallback whose only cost is the import; take it, record it, and do not redesign |
| The `⊡` bridge's hypothesis bundle is the wrong shape for 735 | M | M | It is a hypothesis bundle, not a procedure; its fields are the two directions of HWZ Thm 14 for this semantics plus the named one-sided-live obligation. 735 may generalize it; nothing here is lost. Phase 7 keeps the bundle under 60 lines of statement |
| Evidence-collection contention: `scripts/check-evidence-probes.sh` has live writers (733, 734, 736) | M | H | Dispatch singly. Phases 8 and 9 each **re-read the script immediately before editing and APPEND, never rewrite** — 736 recorded the exact procedure and its blob hash check; reuse it |
| A phase runs past its context budget | M | M | Each phase is one agent run (~100-500 lines of output); on pressure checkpoint with `bash .claude/scripts/git-snapshot.sh --no-revert 711` and write the continuation handoff per `context/contracts/wrap-up.md` |
| A reader takes Phase 6's "finite union of families" as a decidability result | H | M | Phase 6's docstring states, in its first paragraph, that the result is about monadic targets over coloured ℤ-blocks and that no reduction from `⊡` to such a target exists in Lean anywhere; the test module's section docstring repeats it; Phase 8's probe header repeats it under "what this does NOT establish" |

## Decisions

- **D-10 The route is Büchi's chain transposed to k-types, not a from-scratch construction.**
  v1's `FwdPresentation`/`Profile`/`DeviceCondition`/splice design (v1 Decisions D-6, D-7) is
  **retired unbuilt**. Reason: 736 showed the chain's distinctive step is already in this tree,
  proved and axiom-clean, in the k-type idiom, and that re-deriving an equivalent device over a
  bespoke `Profile` alphabet would duplicate `kTypeOf`'s role while forgoing the mixing lemma
  (`kEquiv_orderedSum_of_kEquiv_colour`), which is the single piece that makes saturation
  tractable. Nothing from v1 Phases 2-10 was implemented, so nothing is discarded.
- **D-11 The deficit-set bookkeeping (v1 D-6) is dropped with its construction.** It solved a
  problem — securing fulfilment at interior positions of a period witness — that the k-type route
  does not have: a k-type already summarises *everything* a depth-≤k monadic sentence can see
  about a segment, interior positions included. If a later phase finds a fulfilment obligation the
  k-type cannot see, that is a finding about `k`, to be recorded, not a reason to reintroduce a
  parallel alphabet.
- **D-12 v1's Phase 9 discrimination probe is retired as obsolete; Phase 8 replaces it.** Its
  subject — whether (c) and (d) are the same device — was answered by 736 at High confidence from
  the proof body, and the answer is recorded at E3's own site. A probe re-establishing a settled
  fact is not evidence. Phase 8 instead exercises the substrate end to end on a concrete coloured
  ℤ-block.
- **D-13 v1's Phase 10 (E2, the depth-2 stratification probe) is carried forward unchanged** as
  Phase 9. It is independent of the device question and its specification gap (E2 has no written
  spec beyond the ranking's falsifier sentence) is unaffected by 736.
- **D-14 Challenge statements pin the four self-contained theorems only.** The seam interface's
  statements depend on a hypothesis structure this plan specifies but whose fields the
  implementation phase fixes in detail; pinning them would turn every field adjustment into a
  `[BLOCKED]` round trip on the critical path. Their intended signatures are given in Phase 7 as
  the plan's contract under `.claude/rules/plan-compliance.md` (decomposition fidelity).
- **D-15 The cluster lives under `WeakCanonical/`, with the seam interface under
  `Decidability/RaySummary/`.** `KType`, `segZ`, `zFiber` and the mixing lemma all live under
  `WeakCanonical/`, so the substrate sits beside its ingredients and adds no cross-front import;
  the `⊡` bridge must reach `FormalSystem/PlusLanguage/PlusRayFibre.lean`, so it sits on the
  decidability side and imports both. A task-type-neutral home for the k-type kernel is recorded
  as a follow-up in the cluster README, not attempted here.
- **D-16 Axiom pins live in `BimodalTest`, not in the C14 inline list.** Carried unchanged from
  v1 D-8: the sanctioned pattern is `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean`
  (`#guard_msgs` + `#print axioms`).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel; this plan is fully sequential. Each phase is
one agent run. Phases 8 and 9 are serialized specifically to keep a single writer on
`scripts/check-evidence-probes.sh`, which has live writers in other tasks.

### Phase 1: Relocate infinite Ramsey for pairs to ForMathlib, alias kept [COMPLETED WITH EXCLUSIONS]

**Exclusions** (Phase 1): `bash scripts/check-module-invariants.sh` exits 1 on the single
pre-existing check C9 (a task-number citation at `scripts/check-phantom-citations.sh:145`,
committed by task 728 in `729dc345f`, a file outside this phase's territory and untouched here);
every other check is green (full run: C1 build, C24, C33, C5, C12/C13, C28, INV all PASS). The
phase's own gates — both `lean_verify`s, the no-`FormalSystem` import rule, the probe collection
(16/16 PASS) — are met in full.

**Goal**: Move `section Ramsey` (lines 65–170 of
`FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean`: the private helpers
`ramsey_step_exists` … `ramseySeq_pair_col` and the theorem `infinite_ramsey_pairs`) into a new
Mathlib-namespace module, keep the old name as a one-line alias, and register the module at every
site the `ForMathlib/` convention requires, so that the decidability side can import the Ramsey
ingredient without importing `WeakCanonical.GroupModel`.

**Tasks**:

- [x] Re-verify the baseline before moving anything:
      `lean_verify FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` (expected axioms
      `[propext, Classical.choice, Quot.sound]`, no sorry), and grep every citation of the name
      outside `specs/`: `FormalSystem/Metalogic/WeakCanonical.lean`,
      `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md`,
      `scripts/check-evidence-probes.sh`, `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`.
      None of these needs editing if the alias keeps the name; confirm after the move.
- [x] Create `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` with the copyright
      header, imports `Mathlib.Data.Set.Finite.Lattice`, `Mathlib.Logic.Denumerable`,
      `Mathlib.Data.Fintype.Pigeonhole` (exactly the three the section uses today; drop any the
      build shows unused), **no** `FormalSystem.*` import, `namespace Nat`, the moved section
      verbatim (private helpers unchanged), and the public theorem renamed
      `Nat.exists_strictMono_const_pair_colour` with the same statement
      `∀ {C : Type} [Finite C] (c : ℕ → ℕ → C), ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, ∀ i j, i < j → c (g i) (g j) = τ`.
      Module docstring: what it is (infinite Ramsey for pairs, absent from Mathlib at pin
      `v4.33.0-rc1`: `Combinatorics/Hindman.lean` and `HalesJewett.lean` mention it only), the
      Doets 1987 ch. 7 (pp. 89–93) provenance carried from the old header, and the Mathlib-shaped
      name rationale.
- [x] In `RamseyFactorization.lean`: delete the section, add
      `import FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs`, keep the docstring'd
      `theorem infinite_ramsey_pairs (c : ℕ → ℕ → C) : … := Nat.exists_strictMono_const_pair_colour c`
      at the same name in the same namespace (`FormalSystem.Metalogic.WeakCanonical`), and update
      the module docstring's "proved from scratch here" sentence to point at the new module. Keep
      the `variable {C : Type} [Finite C]` the alias needs.
- [x] Register the module: add the import and a Contents bullet to `FormalSystem/ForMathlib.lean`;
      add `` `FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs `` to `exceptions` in
      `scripts/CheckInitImportsMain.lean` (C24); update the exception sentence in
      `FormalSystem/Init.lean`'s docstring (it currently enumerates two `ForMathlib` modules);
      create `FormalSystem/ForMathlib/Combinatorics/README.md` on the `Order/README.md` pattern;
      add the `Combinatorics/` bullet to `FormalSystem/ForMathlib/README.md`'s Related
      Documentation and regenerate its inventory table with
      `bash scripts/check-module-invariants.sh --emit-inventory` (hand-write the trailing
      description cell); update the `RamseyFactorization.lean` row and the
      `infinite_ramsey_pairs` bullet in `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md`
      and the mention in `FormalSystem/Metalogic/WeakCanonical.lean` to say "alias of". *(deviation: altered — `--emit-inventory` also rewrote the rollup blocks of `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and `README.md`; staged with the phase)*
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem` (C33 requires
      `FormalSystem.lean` byte-current).
- [x] Build the two touched roots, detached and guarded:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.ForMathlib FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization`;
      then `lean_verify` both names (same axiom set as the baseline).
- [x] Run `bash scripts/check-module-invariants.sh` (full, with build) and
      `bash scripts/check-evidence-probes.sh` (E3's probe cites the alias). Both green. *(deviation: altered — probes green (16/16); the harness is green on every check except the pre-existing C9 named in the Exclusions above, which is out of this phase's territory)*
- [x] Commit via `git-commit-scoped.sh` (`task 711 phase 1: relocate infinite Ramsey for pairs to ForMathlib`),
      staging only the files listed below.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: Eleven files are touched and ~110 lines move with **zero** proof edits
beyond the namespace change and the alias. Confirm by `lean_verify` on both names after the
build; if any proof in the moved section needs editing, record it with `issue-record.sh`
(`--class "tooling bug or gap"` or the concrete class) because the section's only dependencies
were the three Mathlib imports.

**Files to modify**:

- `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` - new; the moved section under `Nat.exists_strictMono_const_pair_colour`
- `FormalSystem/ForMathlib/Combinatorics/README.md` - new; subdirectory README on the `Order/README.md` pattern
- `FormalSystem/ForMathlib.lean` - import + Contents bullet
- `FormalSystem/ForMathlib/README.md` - inventory row (regenerated) + Related Documentation bullet
- `FormalSystem/Init.lean` - docstring's recorded-exception sentence
- `scripts/CheckInitImportsMain.lean` - C24 exception entry
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` - section removed, import added, alias theorem, header sentence
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md` - row and bullet wording
- `FormalSystem/Metalogic/WeakCanonical.lean` - mention wording
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify Nat.exists_strictMono_const_pair_colour` and
  `lean_verify FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` both report
  `[propext, Classical.choice, Quot.sound]`, no sorry.
- `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` returns nothing.
- `bash scripts/check-module-invariants.sh` exits 0 (C24, C33, C5, C12/C13 among them);
  `bash scripts/check-evidence-probes.sh` exits 0.

---

### Phase 2: Step 2 — the finite-index fact, the cluster scaffold, and the falsified `Nat.nth` note [COMPLETED WITH EXCLUSIONS]

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `bash scripts/check-module-invariants.sh` exits 0 | The single failing check is the pre-existing C9 citation at `scripts/check-phantom-citations.sh:145` (committed in `729dc345f`), a file outside this task's `file_scope` and untouched by this phase — the identical exclusion Phase 1 recorded | Full harness run this dispatch: every other check PASS (C1 build + `BimodalTest`, C2, C3, C4, C5, C14, C15, C16, C20, C23, C24, C28 with 0 warnings, C29, C30, C31, C32, C33); INV PASS after `--emit-inventory`; `--no-build` confirmation pass recorded in the phase commit |

**Goal**: Establish Büchi chain step 2 (a finite alphabet of segment summaries) as a named,
public theorem, stand up the cluster's aggregator, README and axiom-pin test module so later
phases only append, and correct the one stale claim 736 falsified in a file this task owns.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Basic.lean`: copyright header;
      imports `FormalSystem.Metalogic.WeakCanonical.NEquivalence` and
      `FormalSystem.Metalogic.WeakCanonical.MixedSum`; `namespace FormalSystem.Metalogic.WeakCanonical`.
      Module docstring: the cluster is Büchi's complementation chain transposed to monadic
      k-types over the ℤ time axis; name the six steps and say which module owns each; cite
      Thomas 1997 "Languages, Automata, and Logic" §5.1 p. 30 for the chain and cslib's
      `Cslib.Automata.NA.Buchi.buchiFamily_cover` **as a read-only structural reference, never a
      dependency**; state in one sentence that the time axis is forced
      (`…PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` refutes finite width;
      `Probe732Device.not_lasso_sufficient_on_chain` refutes pigeonhole over states) and that no
      complexity bound is claimed. Cite declaration names and sources, never task numbers.
- [x] State and prove step 2:
      `theorem kType_finite (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) : Finite (KType sig k)`.
      The proof already exists inline at `RamseyFactorization.lean`'s `exists_zFactorization`
      (`haveI : Finite (KType sig k) := by unfold KType; infer_instance`); lift it verbatim and
      add the instance attribute only if instance search does not already find it (check with
      `lean_hover_info`/`lean_multi_attempt` before adding, to avoid a diamond). *(completed — instance search already finds it; no attribute added. Deviation: altered — the pinned `[Fintype] [DecidableEq]` binders trip Mathlib's `unusedFintypeInType`/`unusedDecidableInType` linters, which have no `warning-budget.txt` disposition row; both suppressed declaration-scoped with a C29 reason comment rather than changing the Challenge signature)*
- [x] Create the aggregator `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` importing
      `KTypeSummary.Basic` (later phases append one import each), and add
      `import FormalSystem.Metalogic.WeakCanonical.KTypeSummary` to
      `FormalSystem/Metalogic/WeakCanonical.lean` with a short entry in its docstring's cluster
      list (the `GroupModel/RamseyFactorization.lean` entry is the model).
- [x] Create `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` on the
      `FormalSystem/ForMathlib/Combinatorics/README.md` / `GroupModel/README.md` pattern: why the
      cluster exists, the six-step chain table with each step's owning module and status (only
      step 2 landed at this phase; the rest listed as planned and updated as they land), the
      consumer relation (built here, consumed by the assembly record, never absorbed into it),
      the two carried limits, and the recorded follow-up that a task-type-neutral home for the
      k-type kernel was considered and deferred. Add the two rows (`KTypeSummary.lean`,
      `KTypeSummary/`) to `FormalSystem/Metalogic/WeakCanonical/README.md`'s module table.
- [x] Create `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` on the
      `PeriodicExtensionAxiomTest.lean` pattern (permanent evidence, not a test), pinning with
      `#guard_msgs` + `#print axioms`: `Nat.exists_strictMono_const_pair_colour`,
      `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`, and
      `FormalSystem.Metalogic.WeakCanonical.kType_finite`. Section docstring states what the
      module pins and that `[propext, Classical.choice, Quot.sound]` is the standard profile.
      Register it in `Tests/BimodalTest.lean` next to `PeriodicExtensionAxiomTest`.
- [x] Correct the falsified note in
      `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` (the "## The proof"
      paragraph, around line 36): the parenthetical "`Mathlib.Data.Nat.Nth` is not in this
      project's built cache, so `Nat.nth` is deliberately not used" is **false** — the olean is
      present and a probe in this tree compiles using `Nat.nth`
      (`specs/evidence/seam-gluing-ray-product/cslib-ramsey-port-feasibility.lean`). Before
      editing, re-confirm by compiling a one-line `import Mathlib.Data.Nat.Nth` scratch file with
      `lake env lean`. Replace the parenthetical with the accurate statement: the proof enumerates
      with `Nat.Subtype.ofNat`, which needs no extra import, and `Nat.nth` is an available
      alternative that was not required. Do **not** rewrite the proof — this is a prose-only fix.
- [x] `lake exe mk_all --lib FormalSystem`; build detached and guarded:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.WeakCanonical.KTypeSummary BimodalTest.Metalogic.KTypeSummaryAxiomTest FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs`;
      `lean_verify FormalSystem.Metalogic.WeakCanonical.kType_finite`.
- [x] Run `bash scripts/check-module-invariants.sh` and `bash scripts/check-evidence-probes.sh`;
      commit (`task 711 phase 2: k-type finite index, cluster scaffold, Nat.nth note fix`). *(deviation: altered — harness green on every check except the pre-existing C9 named in the Exclusions below; `--emit-inventory` rewrote the rollup blocks of `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and `README.md`, staged with the phase as in Phase 1; probes 17/17 PASS)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: eight files, ~120 new lines, with **zero** proof work beyond lifting a
two-line `haveI`. Confirm by `lean_verify` on `kType_finite` and by the prose-only character of
the `InfiniteRamseyPairs.lean` diff (`git diff --stat` on that file should show no change inside
any `theorem`/`def` body). If `Finite (KType sig k)` turns out to need more than `unfold`+
`infer_instance` outside `exists_zFactorization`'s local context, record why with
`issue-record.sh` — the existing site is the evidence that it does not.

**Files to modify**:

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Basic.lean` - new; step 2 and the chain docstring
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` - new; cluster aggregator
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - new; cluster README with the six-step table
- `FormalSystem/Metalogic/WeakCanonical.lean` - import + docstring entry
- `FormalSystem/Metalogic/WeakCanonical/README.md` - two module-table rows
- `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` - prose-only: the falsified `Nat.nth` note
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - new; axiom pins
- `Tests/BimodalTest.lean` - import registration
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify FormalSystem.Metalogic.WeakCanonical.kType_finite` reports no sorry and axioms
  within `[propext, Classical.choice, Quot.sound]`.
- Guarded build of the three named roots exits 0 with no `#guard_msgs` mismatch.
- `bash scripts/check-module-invariants.sh` exits 0; `bash scripts/check-evidence-probes.sh`
  exits 0 (the collection is unchanged by this phase but the Ramsey module it cites was touched).

---

### Phase 3: Step 3 carrier — publish `segZ` and the block-as-segment-sum lemma [COMPLETED WITH EXCLUSIONS]

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `bash scripts/check-module-invariants.sh` exits 0 | The single failing check is the pre-existing C9 citation at `scripts/check-phantom-citations.sh:145` (committed in `729dc345f`), outside this task's `file_scope` and untouched by this phase — the identical exclusion Phases 1 and 2 recorded | Full harness run this dispatch after the move: C1 (build + `BimodalTest`), C2, C3, C28 (0 warnings), C33 and every other check PASS; INV PASS after `--emit-inventory`; `lean_verify` on `kEquiv_zFiber_segSum`, `inflate_right`, `inflate_left` all `[propext, Classical.choice, Quot.sound]`; probes 17/17 |

**Goal**: Make the segment carrier and the "a coloured ℤ-block is the ordered sum of its
segments" lemma public, in a module the substrate can import without reaching the group-model
front, with every fully-qualified name unchanged.

**Tasks**:

- [x] Re-verify the baseline before moving anything: `grep -rn 'segZ' --include=*.lean .` (expect
      hits only in `GroupModel/RamseyFactorization.lean` and in one probe *comment*), and
      `lake env lean` a scratch file importing
      `FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization` that `#check`s
      `FormalSystem.Metalogic.WeakCanonical.segZ`. Record both results. *(completed — `segZ`: 13 hits in `RamseyFactorization.lean`, 2 in `Basic.lean`'s docstring, 2 in one probe comment; `#check` through the old import resolves)*
- [x] Create `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Segment.lean`: header; imports
      `KTypeSummary.Basic`, `FormalSystem.Metalogic.WeakCanonical.GroupModel.BlockDecomposition`
      (for `zFiber`) and `FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures` (for
      `k_equiv_of_iso`); `namespace FormalSystem.Metalogic.WeakCanonical` — **the namespace is
      unchanged, so no alias is needed and every fully-qualified name survives the move**.
- [x] Move `def segZ` (currently `RamseyFactorization.lean:320`) verbatim, with its docstring
      extended by one sentence naming its chain role: the half-open coloured segment `[a, b)` is
      the time-axis analogue of a finite word between two positions, and `kTypeOf sig k (segZ …)`
      is the finite summary alphabet step 2 bounds.
- [x] Move `kEquiv_zFiber_segSum` (currently `private`, `RamseyFactorization.lean:442`) verbatim
      and **drop `private`**. Extend its docstring: this is the chain's "a block *is* its
      factorization" step, the hinge the mixing lemma is applied through. Keep the proof byte-
      identical; if an import is missing, add the import rather than editing the proof.
- [x] In `RamseyFactorization.lean`: delete the two moved declarations, add
      `import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Segment`, and update the module
      docstring's "Main results" list and the `segZ` mention to point at the new module. Leave
      `qzFiber` where it is — it is group-model-specific (`ℚ ×ₗ ℤ` tails) and has a consumer in
      `GroupableCompanion.lean`; say so in a one-line comment so a later reader does not "finish"
      the move.
- [x] Append `import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Segment` to
      `KTypeSummary.lean`; update the cluster README's step-3 row; update the
      `RamseyFactorization.lean` row in `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md`
      to say the segment carrier now lives in the summary cluster.
- [x] Record the import closure: run
      `lake env lean --print-imports` (or `lake build` with the module graph) on
      `FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Segment` and confirm by grep that
      neither `MonoDiscrete` nor `GoodGroupable` is in it. Write the measured closure into the
      cluster README. If either *is* present, record the fact and continue — hygiene is a
      preference here, not a gate.
- [x] `lake exe mk_all --lib FormalSystem`; guarded build of
      `FormalSystem.Metalogic.WeakCanonical.KTypeSummary` and
      `FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization`;
      `lean_verify FormalSystem.Metalogic.WeakCanonical.kEquiv_zFiber_segSum`,
      `lean_verify FormalSystem.Metalogic.WeakCanonical.inflate_right` and
      `lean_verify FormalSystem.Metalogic.WeakCanonical.inflate_left` (the two downstream
      consumers must keep their axiom profiles).
- [x] Pin `kEquiv_zFiber_segSum` in the test module; run
      `bash scripts/check-module-invariants.sh`; commit
      (`task 711 phase 3: publish the segment carrier and the block-as-segment-sum lemma`). *(deviation: altered — harness green except the pre-existing C9 named in the Exclusions below; `--emit-inventory` rollups and `typst/generated/status.typ` (pre-commit gate) staged with the phase; probes 17/17 PASS)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: ~70 lines move with **zero** proof edits; seven files touched;
`inflate_left`/`inflate_right` keep identical axiom profiles. Confirm by the three `lean_verify`
calls above and by `git diff` showing the moved proof bodies unchanged. If any moved proof needs
editing, that is evidence the declaration had an undeclared dependency on the group-model front —
record it with `issue-record.sh` and take the Risks-table fallback (drop `private` in place
instead of moving).

**Files to modify**:

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Segment.lean` - new; `segZ` and `kEquiv_zFiber_segSum`, public
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` - two declarations removed, import added, docstring updated
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md` - row wording
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` - import appended
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - step-3 row, measured import closure
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - pin for `kEquiv_zFiber_segSum`
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify` on `…WeakCanonical.kEquiv_zFiber_segSum`, `…inflate_right`, `…inflate_left`: no
  sorry, axioms unchanged from the pre-move baseline.
- `grep -rn 'MonoDiscrete\|GoodGroupable' FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`
  returns nothing.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 4: Steps 3 and 4 — the family and the Ramsey cover, made public [NOT STARTED]

**Goal**: Publish the `(τneg)^(ω*) · τzero · (τpos)^ω` family over the ℤ time axis and the Ramsey
cover theorem that every coloured block lies in one — Büchi's steps 3 and 4, already proved in
this tree, currently private.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Family.lean` (imports
      `KTypeSummary.Segment` and `FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs`;
      same namespace). Module docstring: this is Büchi's `[u]·[v]^ω` family, bi-infinite because
      the time axis is ℤ and the seam-gluing presentation glues a backward ray to a forward ray;
      name the cslib shape it mirrors (`Cslib.Automata.NA.Buchi.buchiFamily`) as a reference only;
      state that the cover is proved from `infinite_ramsey_pairs`, applied **twice**, once per
      orientation, exactly as `RamseyFactorization.lean` already does.
- [ ] Move `structure ZFactorization` (currently `private`,
      `RamseyFactorization.lean:343`) here, drop `private`, rename to `SegmentFactorization` if a
      clearer name is wanted (record either choice), and **add one field**
      `zero_type : kTypeOf sig k (segZ sig c (W 0) (W 1)) = τzero` with the accompanying
      `τzero : KType sig k`. Rationale: the middle segment's type is what makes the family triple
      complete and is what Phase 5 needs; today it is implicit.
- [ ] Move `exists_zFactorization` here, drop `private`, and extend it to produce the new field
      (the witness is `kTypeOf sig k (segZ sig c (W 0) (W 1))` itself, so the added obligation is
      `rfl`). Keep the existing proof byte-identical apart from the extra `refine` slot.
- [ ] Define the family and its membership as plain predicates over the data, so no quotient or
      `Set` machinery is introduced:
      `def InFamily (sig) [..] (k) (τneg τzero τpos : KType sig k) (c : sig.preds → ℤ → Prop) : Prop`
      — "there is a `SegmentFactorization sig k c` whose three types are `τneg`, `τzero`, `τpos`";
      and the cover `theorem family_cover (sig) [..] (k) (c) : ∃ τneg τzero τpos, InFamily sig k τneg τzero τpos c`,
      a one-line corollary of the moved existence theorem.
- [ ] State the self-contained form the plan pins,
      `theorem exists_matching_factorization` (signature under `## Lean Challenge Statements`),
      as the unbundled restatement of `family_cover` — it exists so a consumer can use the cover
      without importing the structure. Prove it by `obtain` from `family_cover`.
- [ ] In `RamseyFactorization.lean`: delete the two moved declarations, add the import, update
      the docstring, and repair `inflate_right`/`inflate_left`'s `obtain ⟨W, hmono, hcover, τpos, τneg, hpos, hneg, hstrict, _⟩`
      destructuring for the added field (the only mechanical edit this phase makes to a proof —
      an extra `_` in each pattern; if the field order differs, follow the structure's order).
- [ ] Pin `family_cover` and `exists_matching_factorization` in the test module; append the import
      to `KTypeSummary.lean`; update the cluster README's steps 3-4 rows; `mk_all`; guarded
      scoped build; `lean_verify` the two new names **and** `inflate_left`/`inflate_right` again;
      `bash scripts/check-module-invariants.sh`; commit
      (`task 711 phase 4: publish the k-type family and the Ramsey cover`).

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: ~140 lines move, ~40 lines are added (the predicate, the corollary, the
unbundled restatement), and exactly two proof sites outside the moved code change — the two
`obtain` patterns in `inflate_right`/`inflate_left`. Confirm by `git diff` on
`RamseyFactorization.lean` showing changes confined to the import block, the docstring, the
deletions, and those two patterns. If more sites change, stop and record the divergence: the
structure had more consumers than grep found.

**Files to modify**:

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Family.lean` - new; steps 3 and 4
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` - declarations removed, import added, two `obtain` patterns widened
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` - import appended
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - steps 3-4 rows
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - pins for `family_cover`, `exists_matching_factorization`
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify …WeakCanonical.family_cover` and
  `lean_verify …WeakCanonical.exists_matching_factorization`: no sorry, axioms within
  `[propext, Classical.choice, Quot.sound]`.
- `lean_verify …inflate_left` and `…inflate_right`: axiom profiles unchanged from Phase 3's
  recorded baseline.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 5: Step 5a — the saturation core: a block's k-type is a function of its family [NOT STARTED]

**Goal**: Close the chain's only genuinely missing link. Prove that two coloured ℤ-blocks whose
factorizations carry matching segment types are k-equivalent, and hence that the block k-type is
constant on a family — the hinge on which saturation turns.

**Tasks**:

- [ ] Settled-design preamble (restate in the dispatch): the strategy is **assembly of three
      proved parts, not a new induction**. Part 1: `kEquiv_zFiber_segSum` (Phase 3) rewrites each
      block as the ordered sum of its segments. Part 2: the two colour index orders
      `kTypeColouring sig k (fun z => segZ sig c (W z) (W (z+1)))` and its primed twin are
      **pointwise equal functions `ℤ → KType sig k`** under the matching hypothesis, so
      `KEquiv (colourSig _) k` between them is `congrArg`/`funext`, not a back-and-forth
      argument. Part 3: `kEquiv_orderedSum_of_kEquiv_colour` (`MixedSum.lean:547`) turns Part 2
      into a `KEquiv` between the ordered sums. Compose with `KEquiv`'s symmetry and transitivity
      — `KEquiv` unfolds to an equation between `kTypeOf` values, so these are `Eq.symm`/
      `Eq.trans`. Inherited sorries: none.
- [ ] Create `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean` (imports
      `KTypeSummary.Family`; same namespace). Module docstring: this is Büchi's step 5 for
      monadic targets; name what it does **not** give — nothing here says the `⊡` fibre condition
      is such a target, and no formalization of the MSO↔ω-regular correspondence exists in any
      proof assistant, so that reduction is never used; cite
      `Cslib.Automata.NA.Buchi.buchiFamily_saturation` as the structural reference it mirrors.
- [ ] Prove the pointwise-colouring lemma first, as its own named step:
      `theorem kTypeColouring_eq_of_matching_segments` — under
      `∀ z, kTypeOf sig k (segZ sig c (W z) (W (z+1))) = kTypeOf sig k (segZ sig c' (W' z) (W' (z+1)))`,
      the two `kTypeColouring` structures over ℤ are equal (by `funext` on the colour function and
      `congrArg` on `colourStructure`), hence `KEquiv (colourSig (KType sig k)) k` between them
      holds by `rfl` after `rw`. Keep this separate so a failure localizes.
- [ ] Prove the headline
      `theorem kEquiv_zFiber_of_matching_segments` (signature under
      `## Lean Challenge Statements`) by: `kEquiv_zFiber_segSum` on each side,
      `kEquiv_orderedSum_of_kEquiv_colour` with the previous lemma, and transitivity. Reproduce
      `kEquiv_zFiber_segSum`'s own instance preamble
      (`haveI := Classical.decEq sig.preds; haveI := Fintype.ofFinite sig.preds`) if the
      elaborator asks for it.
- [ ] Derive the family-level corollary
      `theorem kTypeOf_zFiber_eq_of_sameTriple` (signature under
      `## Lean Challenge Statements`): two blocks whose factorizations carry the same
      `(τneg, τzero, τpos)` have equal block k-types. Proof: the matching hypothesis of the
      headline follows from the six type equations by a three-way case split on `z` (`z < 0`,
      `z = 0`, `0 < z`) via `rcases lt_trichotomy z 0`. Add the bundled restatement over
      `InFamily` as a second corollary, `kTypeOf_zFiber_eq_of_inFamily`, so consumers can use
      either form.
- [ ] `#print axioms` on all four new names during development; pin
      `kEquiv_zFiber_of_matching_segments` and `kTypeOf_zFiber_eq_of_sameTriple` in the test
      module; append the import to `KTypeSummary.lean`; update the cluster README's step-5a row;
      `mk_all`; guarded scoped build; `bash scripts/check-module-invariants.sh`; commit
      (`task 711 phase 5: saturation core, the block k-type is a function of the family`).

**Timing**: 2.5 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 200-300 lines, of which the trichotomy bookkeeping in
`kTypeOf_zFiber_eq_of_sameTriple` and the instance plumbing are the two parts that can run long.
Confirm by line count at commit. If `kTypeColouring_eq_of_matching_segments` cannot be closed by
`funext`+`congrArg` — i.e. if `colourStructure` is not injective enough in its colour argument for
the rewrite — fall back to `kEquiv_colourStructure_anchored` with `I = J = ℤ`, `aI = aJ = 0`,
`(α, β, γ) = (τneg, τzero, τpos)`, accept the resulting `MonoDiscrete` import, record the switch
in the cluster README's measured-closure paragraph, and continue. Do **not** redesign the phase
around the fallback.

**Files to modify**:

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean` - new; step 5a
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` - import appended
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - step-5a row
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - pins for the two headline names
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify …WeakCanonical.kEquiv_zFiber_of_matching_segments` and
  `lean_verify …WeakCanonical.kTypeOf_zFiber_eq_of_sameTriple`: no sorry, axioms within
  `[propext, Classical.choice, Quot.sound]`.
- `grep -rn 'sorry' FormalSystem/Metalogic/WeakCanonical/KTypeSummary/` returns nothing.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 6: Step 5b — saturation proper, and the finite-cover consequence for monadic targets [NOT STARTED]

**Goal**: State and prove saturation in Büchi's own shape — each family is wholly inside or
wholly disjoint from the target — for targets cut out by a monadic sentence of quantifier depth
≤ k, and record the licensed consequence: such a target is a finite union of families. Stop
precisely there.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Universal.lean` (imports
      `KTypeSummary.Saturation`; same namespace). Module docstring, **first paragraph**: this
      result is about targets definable by a depth-≤k monadic sentence over the coloured ℤ-block;
      it is **not** a decidability result and **not** a statement about `⊡`; getting from a `⊡`
      fibre condition to such a target is the MSO reduction that is unformalized in every proof
      assistant, and this module does not attempt it. Second paragraph: the chain correspondence
      (`buchiFamily_saturation` and `IsRegular.fin_cover_saturates_compl` are the cslib shapes;
      reference only).
- [ ] Define the target predicate without introducing new logic machinery: a target is
      `T : (sig.preds → ℤ → Prop) → Prop` together with a hypothesis
      `hT : ∀ c c', kTypeOf sig k (zFiber sig c) = kTypeOf sig k (zFiber sig c') → (T c ↔ T c')`
      — "T is determined by the block's k-type". Name it
      `def DeterminedByKType (sig) [..] (k) (T) : Prop`, and prove the one fact that justifies the
      name: any `T` of the form `fun c => NfEvalNf (zFiber sig c) k 0 Fin.elim0 nf` for a normal
      form `nf` at depth `k` is `DeterminedByKType` (unfold `kTypeOf`; `decide_eq_decide`). Keep
      this second lemma short; it is what makes the abstraction non-vacuous.
- [ ] `theorem family_saturation (hT : DeterminedByKType sig k T) (τneg τzero τpos) : (∀ c, InFamily sig k τneg τzero τpos c → T c) ∨ (∀ c, InFamily sig k τneg τzero τpos c → ¬ T c)`
      — the literal "inside or disjoint" form. Proof: by `Classical.em` on whether some member
      satisfies `T`, then `kTypeOf_zFiber_eq_of_inFamily` plus `hT` to propagate.
- [ ] `theorem target_eq_union_of_families (hT) : ∀ c, T c ↔ ∃ τneg τzero τpos, InFamily sig k τneg τzero τpos c ∧ (∀ c', InFamily sig k τneg τzero τpos c' → T c')`
      — the finite-union statement, with finiteness supplied by `kType_finite` (Phase 2) on the
      triple type. State the finiteness as its own named lemma
      `finite_family_triples : Finite (KType sig k × KType sig k × KType sig k)` so the count is
      visible rather than buried. **No cardinality bound and no complexity claim** anywhere in
      this module.
- [ ] `#print axioms` on the three new theorems; pin `family_saturation` and
      `target_eq_union_of_families` in the test module, with a section docstring repeating the
      scope disclaimer; append the import; update the cluster README's step-5b row and its
      "what this cluster does not give you" paragraph; `mk_all`; guarded scoped build;
      `bash scripts/check-module-invariants.sh`; commit
      (`task 711 phase 6: saturation for monadic targets and the finite-family cover`).

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 180-260 lines. The non-vacuity lemma (that a depth-k normal form gives a
`DeterminedByKType` target) is the one piece that reaches into `NormalForm.lean`'s API and can
run long; hypothesized at ~40 lines. Confirm by line count. If it exceeds ~80 lines, land
`family_saturation` and `target_eq_union_of_families` against the abstract hypothesis, move the
non-vacuity lemma to Phase 8's probe as a concrete instance instead, and record the move — an
abstract saturation theorem with no exhibited instance is exactly the shape the probe exists to
close, so the obligation is relocated rather than dropped.

**Files to modify**:

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Universal.lean` - new; step 5b
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` - import appended
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - step-5b row, scope disclaimer
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - pins for the two headline names
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify …WeakCanonical.family_saturation` and
  `lean_verify …WeakCanonical.target_eq_union_of_families`: no sorry, axioms within
  `[propext, Classical.choice, Quot.sound]`.
- `grep -rn 'Decidable\|complexity\|EXPTIME' FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Universal.lean`
  returns nothing outside the disclaimer prose.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 7: The seam interface — the `⊡` bridge against an abstract realization hypothesis [NOT STARTED]

**Goal**: Give the consumer a single named interface connecting the keystone
`FormalSystem.PlusLanguage.plusStab_iff_omega` to the substrate, stated against a hypothesis
bundle this task does not discharge, with the Medium-confidence bound written into the statement's
own docstring.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/Decidability/RaySummary/Seam.lean` (imports
      `FormalSystem.Metalogic.WeakCanonical.KTypeSummary` and
      `FormalSystem.PlusLanguage.PlusRayFibre`; `namespace FormalSystem.Metalogic.Decidability.RaySummary`).
      Module docstring, in order: (a) the keystone restates `⊡φ` at a seam as a universal
      quantification over `SeqPair F (τ.state t)` — a backward ray glued to a forward ray; (b) the
      substrate summarises a coloured ℤ-block by a family triple and makes any k-type-determined
      target constant on a family; (c) **the missing link, stated as such**: nothing in Lean
      anywhere reduces a `⊡` fibre condition to a k-type-determined target over the time axis,
      because MSO↔ω-regular is unformalized in every proof assistant (cslib has zero MSO), so
      that link is a *hypothesis field* here and the confidence on it is Medium, not High;
      (d) HWZ Def 12's quasistate is a bare set of types and its Lemma 17 splice can create a
      realised type the model lacked — lethal to a `⊡`-label — which is why the bundle demands
      joint realization through the seam rather than one-sided liveness; the tree's finite-width
      analogues are `PlusSlicedCertificate.live_iff` and `PlusSlicedCertificate.stab_factors`;
      (e) the atomization licence `FormalSystem.Metalogic.Conservativity.plusTruthAt_iff_atomize`
      is what lets a consumer take `φ` `⊡`-free with a finite alphabet; (f) discharging the
      bundle is the consumer's work, and this module builds no decision procedure.
- [ ] `structure SeamSummary (sig : MonadicSignature) (k : ℕ)` — the consumer-facing datum: the
      family triple `(τneg, τzero, τpos)` reached through the seam, plus a `holds : Bool` verdict
      the summary assigns to it. Keep it a plain structure over `Fintype` components; no
      quotient, no `Set`.
- [ ] `structure Presents {F : FrameOver intOrder} [F.IsRegular] (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula) (sig) (k) (S : SeamSummary sig k) : Prop`
      with exactly three fields, each named for the obligation it carries:
      - `colours : ∀ bf : SeqPair F (τ.state t), ∃ c : sig.preds → ℤ → Prop, PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c` for the module's abstract target `T`
        — **this is the unformalized MSO reduction**; its docstring says so in one sentence.
      - `determined : DeterminedByKType sig k T` — the substrate's own hypothesis, discharged by
        Phase 6's non-vacuity lemma for a monadic `T`.
      - `realized : ∀ c, InFamily sig k S.τneg S.τzero S.τpos c → ∃ bf : SeqPair F (τ.state t), …`
        — the joint-realization obligation; its docstring names the HWZ Lemma 17 splice hazard
        above as the reason it is joint and not one-sided.
- [ ] `theorem plusStab_iff_seamSummary (h : Presents M τ t φ sig k S) : PlusTruthAt M τ t (.stab φ) ↔ S.holds = true`
      from `plusStab_iff_omega`, `family_cover`, `family_saturation` and the three fields. Keep
      the proof short — if it needs a fourth field, add it and record why: the bundle is this
      plan's to shape, the discharge is not.
- [ ] Create `FormalSystem/Metalogic/Decidability/RaySummary.lean` importing `RaySummary.Seam`,
      and add `import FormalSystem.Metalogic.Decidability.RaySummary` to
      `FormalSystem/Metalogic/Decidability.lean` with a one-paragraph entry in its docstring's
      cluster list (the sliced certificate's paragraph is the model). Create
      `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: why the cluster exists beside
      `PlusSlicedCertificate/` (finite width refuted → summaries over the time axis), what it
      holds (the seam interface only; the substrate proper is the `WeakCanonical/KTypeSummary/`
      cluster and the README links to it), the consumer relation, and the two carried limits.
      Add the two rows to `FormalSystem/Metalogic/Decidability/README.md`'s module table.
- [ ] Pin `plusStab_iff_seamSummary` in the test module, with a section note that its profile
      inherits `Classical.choice` through `plusStab_iff_omega`'s
      `FrameOver.worldHistoryOfStepPath` (the `PeriodicExtensionAxiomTest.lean` precedent for a
      choice-carrying row). `mk_all`; guarded scoped build; `bash scripts/check-module-invariants.sh`;
      commit (`task 711 phase 7: seam interface and the stab bridge against an abstract hypothesis`).

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 200-300 lines, most of it docstring; the bridge theorem itself is under 40
lines by design. Confirm by line count and by `grep -c` on the module for the word "hypothesis"
(the three fields must each carry one). If `plusStab_iff_seamSummary` cannot be closed with three
fields, add a fourth rather than weakening the statement, and record the addition.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/Seam.lean` - new; the seam interface and the bridge
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - new; cluster aggregator
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - new; cluster README
- `FormalSystem/Metalogic/Decidability.lean` - import + docstring entry
- `FormalSystem/Metalogic/Decidability/README.md` - two module-table rows
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - pin for `plusStab_iff_seamSummary`
- `FormalSystem.lean` - regenerated root (C33)

**Verification**:

- `lean_verify …Decidability.RaySummary.plusStab_iff_seamSummary`: no sorry, axioms within
  `[propext, Classical.choice, Quot.sound]`.
- `grep -rn 'sorry' FormalSystem/Metalogic/Decidability/RaySummary/` returns nothing.
- Guarded scoped build exits 0; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 8: Evidence probe (i) — the substrate exercised end to end on a concrete coloured block [NOT STARTED]

**Goal**: Exhibit the whole chain on one finitely presented infinite fibre: a concrete colouring
of ℤ, its factorization, its family triple, a k-type-determined target, and the saturation
verdict — with a header that states plainly what the probe does not establish. This replaces v1's
retired (c)/(d) discrimination probe (Decision D-12).

**Tasks**:

- [ ] Create `specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean`
      (`import FormalSystem` only — the collection's standing rule;
      `namespace Probe711Substrate`). Re-grep every name before citing it:
      `FormalSystem.Metalogic.WeakCanonical.family_cover`, `…family_saturation`,
      `…kTypeOf_zFiber_eq_of_sameTriple`, `…Decidability.RaySummary.plusStab_iff_seamSummary`,
      `Probe732Device.not_lasso_sufficient_on_chain`,
      `…PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`.
- [ ] Fixture: a one-predicate signature and the colouring `c p t := (t % 2 = 0)` on ℤ (or a
      time-asymmetric colouring if the parity one makes the family degenerate — confirm, do not
      assume). Exhibit a factorization explicitly (`W z := 2 * z` for the parity colouring) rather
      than invoking `family_cover`, so the probe shows the *content* of the cover and not just its
      existence; then also invoke `family_cover` and check the two agree in their triple.
- [ ] Exhibit a second colouring in the **same** family with a different cutting sequence (e.g.
      shifted, `W' z := 2 * z + 2` on the same colouring, or a different colouring with the same
      segment types) and apply `kTypeOf_zFiber_eq_of_sameTriple` to conclude the two blocks have
      equal k-type — the probe's central fact, and the one that makes saturation non-vacuous.
- [ ] Exhibit a k-type-determined target and apply `family_saturation` to it, recording the
      verdict branch taken. If Phase 6's Scope Hypothesis relocated the non-vacuity lemma here,
      this is where it lands.
- [ ] Exhibit a non-trivial inhabitant of the Phase 7 hypothesis bundle on this fixture if it can
      be done inside budget; if it cannot, say so explicitly in the header under "what this does
      NOT establish" rather than overrunning — an unexhibited bundle is an honest limit, a faked
      one is not.
- [ ] Header in the collection's style. **What is established**: the chain runs end to end on a
      concrete infinite fibre; two distinct blocks in one family are machine-checked k-equal; the
      saturation theorem has an exhibited instance. **What is NOT established**: no decidability
      of anything; no complexity bound; no claim that any `⊡` condition is a k-type-determined
      target (the MSO reduction is unformalized everywhere, cslib included); no claim that
      `⊡(Fp)`/`⊡(Pp)` discriminate between devices (`Probe732Device` settled they do not); no
      claim about adequacy beyond this fixture. Axiom record and the compile line
      `lake env lean specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean`.
      `#print axioms` foot for every headline theorem the probe states.
- [ ] Wire: **re-read `scripts/check-evidence-probes.sh` immediately before editing** (record its
      blob hash, as task 736 did) and **append only** — one `WIRED` array entry plus its doc
      block, no existing entry or comment altered. Run the **whole** collection
      (`bash scripts/check-evidence-probes.sh`), expected all wired probes PASS, exit 0. Commit
      (`task 711 phase 8: substrate probe on a concrete coloured block`), staging the probe and
      the script only.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 250-400 lines; the explicit factorization (discharging `Monotone`, the
cover, and the three type equations for `W z = 2 * z`) is the long part, hypothesized at ~120
lines. Confirm by line count. If computing `kTypeOf` on a concrete segment proves infeasible —
it is `noncomputable`, defined through `Classical.dec`, so it will not reduce by `decide` — state
the type equations as *equalities between `kTypeOf` applications* proved by an order isomorphism
of the two segments (`k_equiv_of_iso`) rather than by evaluation, and record that no probe claim
rests on kernel evaluation.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean` - new; probe (i)
- `scripts/check-evidence-probes.sh` - `WIRED` entry + doc block (append only; re-read first)

**Verification**:

- `lake env lean specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean`
  exits 0 with no error and no warning; `grep -c sorry` on the probe is 0; `#print axioms` within
  `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-evidence-probes.sh` exits 0 for the whole collection, with the pre-edit and
  post-edit wired counts differing by exactly one.

---

### Phase 9: Evidence probe (ii) — E2, the depth-2 stratification probe, and close-out [NOT STARTED]

**Goal**: Define and run E2 from the ranking's falsifier sentence ("a `⊡`-depth-2 formula whose
`⊡`-value at a class is not a function of the class's summary state") on a fixture whose depth-1
`⊡`-value is state-dependent, then close the task out. Carried unchanged from v1 (Decision D-13).

**Tasks**:

- [ ] Create `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean`
      (`import FormalSystem`; `namespace Probe711DepthTwo`). Fixture: two states `a, b` with
      `Rf _ a a`, `Rf _ a b`, `Rf _ b b` (bi-serial: `a` has predecessor `a`; `b` has predecessors
      `a, b`), built by `FrameOver.ofSlicedStep` with its `IsRegular` instance, `p` true at `b`
      only. Re-grep `FormalSystem.Metalogic.Conservativity.plusTruthAt_iff_atomize` and the probe
      twin `Probe718Stratification.plusTruthAt_iff_stratum_atomize` before citing.
- [ ] Depth 1: prove `stab_will_at_a : ¬ PlusTruthAt M τ t (.stab (F p))` for `τ.state t = a`
      (the history that stays at `a` forever) and `stab_will_at_b : PlusTruthAt … (.stab (F p))`
      for `τ.state t = b` (every successor of `b` is `b`, where `p` holds) — the state-dependent
      depth-1 value the shared Bool fixture cannot supply.
- [ ] Depth 2, two formulas: `⊡F(⊡Fp)` and `⊡(Fp → ⊡Fp)`. For each, (a) compute the value at `a`
      and at `b` directly from the semantics (`a`: both `False`; `b`: both `True` — confirm, do
      not assume), and (b) compute it through the stratification: atomize with a fresh atom `q`
      for `⊡Fp`, read `q` through the depth-1 stratum (`q(a) = false`, `q(b) = true`), and
      evaluate the resulting L-formula at depth 1 (`⊡F q`, `⊡(Fp → q)`) over the atomized model.
      Prove `(a) ↔ (b)` by `plusTruthAt_iff_atomize` applied twice, as theorems
      `depth2_via_strata_1`, `depth2_via_strata_2`.
- [ ] The falsifier check: state and prove that on this fixture each depth-2 `⊡`-value at a state
      **is** a function of `(state, depth-1 stratum)` — `value_is_function_of_stratum` — and
      record in the header that this is a POSITIVE result on one fixture, not a proof that the
      falsifier cannot exist: what would kill stratification is a fixture where two states with
      equal depth-1 strata differ at depth 2, and this probe exhibits none.
- [ ] Header in the collection's style (what is established / what is NOT established / axiom
      record / compile line); `#print axioms` foot. Wire into `scripts/check-evidence-probes.sh`
      (**re-read immediately before editing; append only**); run the whole collection; commit
      (`task 711 phase 9: depth-2 stratification probe E2`), staging the probe and the script.
- [ ] Close-out for the task: update both cluster READMEs' evidence paragraphs to cite the two
      probes by file name and mark every chain step's status final; run the unscoped final build
      (`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached), the
      test-library build (`… -- build BimodalTest`), `bash scripts/check-module-invariants.sh` and
      `bash scripts/check-evidence-probes.sh`; all green before the task is marked complete.
      Write the implementation summary.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 250-350 lines. Two `decide_will`-style layer lemmas took E3 ~100 lines for
one layer on one formula; if the second formula's depth-2 computation runs long, keep `⊡F(⊡Fp)`
as the probe's subject, record `⊡(Fp → ⊡Pp)`-shaped formulas as a follow-up in the header, and do
not overrun.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` - new; probe (ii), E2
- `scripts/check-evidence-probes.sh` - `WIRED` entry + doc block (append only; re-read first)
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - evidence paragraph, final step statuses
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - evidence paragraph
- `specs/711_universal_summary_substrate_stab_fibre/summaries/02_buechi-chain-ktype-substrate-summary.md` - new; implementation summary

**Verification**:

- `lake env lean specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` exits 0 with no
  warning, no sorry, axioms within `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-evidence-probes.sh` exits 0 for the whole collection.
- Final gates: unscoped guarded `lake build` exit 0; `lake build BimodalTest` exit 0;
  `bash scripts/check-module-invariants.sh` exit 0;
  `grep -rn sorry FormalSystem/Metalogic/WeakCanonical/KTypeSummary FormalSystem/Metalogic/Decidability/RaySummary`
  empty.

## Lean Challenge Statements

The four self-contained theorems this plan commits to, with bodies `sorry` by this section's
rule. Each is stated against names that are **already public in the tree today** (`KType`,
`kTypeOf`, `KEquiv`, `segZ`, `zFiber`), so the block type-checks standalone before any phase
runs; Phases 3 and 4 relocate `segZ` within the same namespace, leaving these signatures
unchanged. See Decision D-14 for why the seam interface's statements are specified in Phase 7
rather than pinned here.

```lean
import FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization

namespace FormalSystem.Metalogic.WeakCanonical

theorem kType_finite (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) : Finite (KType sig k) := sorry

theorem exists_matching_factorization (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (c : sig.preds → ℤ → Prop) :
    ∃ (W : ℤ → ℤ) (τneg τzero τpos : KType sig k),
      Monotone W ∧
      (∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1)) ∧
      W 1 < W 2 ∧ W (-2) < W (-1) ∧
      (∀ z : ℤ, 0 < z → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τpos) ∧
      (∀ z : ℤ, z < 0 → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τneg) ∧
      kTypeOf sig k (segZ sig c (W 0) (W 1)) = τzero := sorry

theorem kEquiv_zFiber_of_matching_segments (sig : MonadicSignature) [Finite sig.preds]
    (k : ℕ) (c c' : sig.preds → ℤ → Prop) (W W' : ℤ → ℤ)
    (hW : Monotone W) (hW' : Monotone W')
    (hcov : ∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1))
    (hcov' : ∀ t : ℤ, ∃ z, W' z ≤ t ∧ t < W' (z + 1))
    (hmatch : ∀ z : ℤ,
      kTypeOf sig k (segZ sig c (W z) (W (z + 1)))
        = kTypeOf sig k (segZ sig c' (W' z) (W' (z + 1)))) :
    KEquiv sig k (zFiber sig c) (zFiber sig c') := sorry

theorem kTypeOf_zFiber_eq_of_sameTriple (sig : MonadicSignature) [Finite sig.preds]
    (k : ℕ) (c c' : sig.preds → ℤ → Prop) (W W' : ℤ → ℤ)
    (τneg τzero τpos : KType sig k)
    (hW : Monotone W) (hW' : Monotone W')
    (hcov : ∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1))
    (hcov' : ∀ t : ℤ, ∃ z, W' z ≤ t ∧ t < W' (z + 1))
    (hpos : ∀ z : ℤ, 0 < z → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τpos)
    (hneg : ∀ z : ℤ, z < 0 → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τneg)
    (hzero : kTypeOf sig k (segZ sig c (W 0) (W 1)) = τzero)
    (hpos' : ∀ z : ℤ, 0 < z → kTypeOf sig k (segZ sig c' (W' z) (W' (z + 1))) = τpos)
    (hneg' : ∀ z : ℤ, z < 0 → kTypeOf sig k (segZ sig c' (W' z) (W' (z + 1))) = τneg)
    (hzero' : kTypeOf sig k (segZ sig c' (W' 0) (W' 1)) = τzero) :
    kTypeOf sig k (zFiber sig c) = kTypeOf sig k (zFiber sig c') := sorry

end FormalSystem.Metalogic.WeakCanonical
```

## Literature Proof Structure (H3 Tier 1 mapping, rebuilt on task 736's step map)

Reference-grounding tier: **Tier 1**. Primary source: **`thomas_1997_languages_automata`**
("Languages, Automata, and Logic", `verified_conversion`, source PDF present) — task 736's named
template and E3's own named resolving check. **Match corpus ids WHOLE**: `thomas_1997` is a
*different* document (the composition method and EF games; `no_source_pdf`, hazard-carrying) and
must never be cited by the author-year stem. The alternative lineage note matters here: that
second document is the lineage of this tree's `MonadicFO`/`NEquivalence`/`RamseyFactorization`
cluster, which performs step 4's analogue with monadic k-types and needs no automata at all —
which is exactly the route this plan takes.

Supporting Tier 1: HWZ 2000 (APAL 106), GKWZ 2003, Doets 1987 ch. 7 (via the Ramsey module).
Tier 3 inputs: the keystone, the sliced certificate's liveness and no-finite-width modules, the
evidence collection. Status vocabulary: `transcribed` (proved in tree), `pending` (this plan's
target, with the owning phase), `blocked` (no Lean route under zero-debt; frame only), `reference`
(read-only structural comparison, never a dependency). No row is `sorry`.

**Büchi's chain, transposed to monadic k-types over the ℤ time axis.** The cslib column is a
read-only structural reference establishing that the chain is real and that step 4 is its
distinctive step; **nothing in that column is imported, ported, or depended on.**

| # | Büchi's step (Thomas 1997 §5.1 p. 30) | cslib's identifier (reference only) | This tree's identifier | Status |
|---|---|---|---|---|
| 1 | Finite-index right congruence on finite words | `Cslib.Automata.NA.Buchi.BuchiCongruence` | `KType`, `kTypeOf`, `KEquiv` (`WeakCanonical/NEquivalence.lean:73`) | transcribed (k-type in place of congruence class) |
| 2 | Finite index over a finite signature | `buchiCongruence_fin_index` | `kType_finite` | pending (Phase 2; the proof exists inline at `exists_zFactorization`) |
| 3 | The family `[u]·[v]^ω`, here bi-infinite: `(τneg)^(ω*) · τzero · (τpos)^ω` | `buchiFamily`, `mem_buchiFamily` | `SegmentFactorization`, `InFamily` (from the private `ZFactorization`) | pending (Phase 4; structure exists, private, one field added) |
| 3′ | A word *is* the concatenation of its factors | — (implicit in cslib's `ωSequence` API) | `kEquiv_zFiber_segSum` | pending (Phase 3; proved in tree, private) |
| 4 | **Ramsey step**: colour a pair of positions by the summary of the segment between them, apply infinite Ramsey for pairs, take the monochromatic monotone sequence | `buchiFamily_cover` via `Cslib.infinite_graph_ramsey` (`Congruences/BuchiCongruence.lean:118`, Ramsey call at `:125`) | `exists_matching_factorization` / `family_cover`, via `infinite_ramsey_pairs` = `Nat.exists_strictMono_const_pair_colour` | pending (Phase 4; **proved in tree**, private, applied twice for the two orientations at `RamseyFactorization.lean:358,360`) |
| 5 | **Saturation**: each family member is inside or disjoint from the target | `buchiFamily_saturation` | `kEquiv_zFiber_of_matching_segments`, `kTypeOf_zFiber_eq_of_sameTriple`, `family_saturation` | pending (Phases 5-6; **the principal deliverable**) |
| 5′ | A finite saturating cover makes the target a finite union of pieces | `IsRegular.fin_cover_saturates_compl` | `target_eq_union_of_families` | pending (Phase 6; monadic targets only) |
| 6 | Conclude decidability | `IsRegular.compl` (upstream, proved) | — | **out of scope** (the assembly record's work) |

**Supporting rows.**

| Source | Proposition / location | Lean identifier | Status |
|---|---|---|---|
| Doets 1987 ch. 7, pp. 89-93 | infinite Ramsey for pairs | `Nat.exists_strictMono_const_pair_colour` (alias `…WeakCanonical.infinite_ramsey_pairs`) | transcribed (relocated in Phase 1) |
| Shelah/Thomas composition method; `thomas_1997` (the *other* document — cite whole, with its recorded hazard) | the k-type of an ordered sum is determined by the index order coloured by summand types | `kEquiv_orderedSum_of_kEquiv_colour` (`MixedSum.lean:547`) | transcribed (**the engine of Phase 5**) |
| same | coloured index orders, constant on each side of a pinned anchor, are `≡ₖ` | `kEquiv_colourStructure_anchored` | transcribed (Phase 5's recorded fallback only) |
| HWZ 2000 Def 12, Remark 13, Thm 14, p. 11 | realization hypothesis; the Lemma 17 splice hazard | `…RaySummary.Presents` (hypothesis bundle) | pending (Phase 7; **discharge is the consumer's**) |
| This tree, `PlusLanguage/PlusRayFibre.lean:290` | the keystone | `FormalSystem.PlusLanguage.plusStab_iff_omega` | transcribed |
| HWZ Thm 14 + keystone | the `⊡` bridge | `…RaySummary.plusStab_iff_seamSummary` | pending (Phase 7) |
| This tree, `Atomization.lean` | alphabet licence | `…Conservativity.plusTruthAt_iff_atomize` | transcribed (used by Phase 9) |
| This tree, `NoFiniteWidth.lean:1280` | design constraint: the time axis is forced | `…PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` | transcribed (cited) |
| E3, `device-selection-probe.lean` | pigeonhole over states is refuted | `Probe732Device.not_lasso_sufficient_on_chain` | transcribed (cited) |
| Büchi 1962 / Thomas 1997 Thm 5.9 p. 37 | Büchi's theorem (MSO ↔ ω-regular) | — | **blocked** (frame only; unformalized in **every** proof assistant — cslib has zero MSO) |
| Kupferman-Vardi 2001 §5.2 | rank-based NBA complementation, correctness | `Cslib…complement_language_sub`/`sup`/`eq` (lines 293, 321, 328) | **blocked** (`proof_wanted`, emits no declaration; a `sorry`-grep of 0 is a false negative) |
| McNaughton 1966 / Choueka 1974 | ω-regular ↔ deterministic Muller | `Cslib.ωLanguage.IsRegular.iff_da_muller` (fork-only, `OmegaRegularLanguage.lean:440`) | reference (**wrong axis** — an acceptor over states; rejected) |

**Divergence from the sources, with justification** (lean4 override, "Transcription Discipline"):

1. **Congruence class → monadic k-type.** Büchi colours a segment by its Büchi-congruence class;
   this tree colours it by `kTypeOf sig k`. The step-4 docstring cslib itself carries — the
   argument "does not depend on any details of `BuchiCongruence` other than that it is of finite
   index" — is the licence for the substitution, and `kType_finite` (step 2) supplies the one
   property it names.
2. **Bi-infinite family instead of `[u]·[v]^ω`.** The time axis is ℤ, not ℕ, because the
   seam-gluing presentation glues a backward ray to a forward ray at a seam, so the family is
   `(τneg)^(ω*) · τzero · (τpos)^ω` and the cover applies Ramsey twice, once per orientation —
   which is exactly what `exists_zFactorization` already does.
3. **Saturation is proved for k-type-determined targets, not for `⊡`.** Büchi's step 5 saturates
   against the automaton's accepted language. The analogue here saturates against any target the
   block's k-type determines. Bridging `⊡` to such a target is the MSO reduction, unformalized
   everywhere; it is a hypothesis field in Phase 7 and is never discharged. **This is the plan's
   single largest divergence and the Medium-confidence bound 736 set.**
4. **HWZ's quasistate is a bare set of types; the Phase 7 bundle demands joint realization
   through the seam**, because `⊡` quantifies over histories through a *state*, which HWZ's
   language does not have, and the Lemma 17 splice can otherwise create a realised type the model
   lacked. Carried unchanged from v1.

## Testing & Validation

- [ ] Every new module under `KTypeSummary/` and `RaySummary/`: `lean_verify` on each headline
      name reports no sorry and axioms within `[propext, Classical.choice, Quot.sound]`.
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` builds with every `#guard_msgs`
      block matching (guarded `lake build BimodalTest`).
- [ ] The two pre-existing downstream consumers of the relocated declarations,
      `…WeakCanonical.inflate_left` and `…inflate_right`, keep the axiom profiles recorded as
      Phase 3's baseline, after Phases 3, 4 and 5.
- [ ] `bash scripts/check-module-invariants.sh` green after every module-adding phase (C33 for
      the regenerated root, C5/C12/C13 for README paths; no C24 entry is needed because no new
      `ForMathlib` module is added by this plan).
- [ ] `bash scripts/check-evidence-probes.sh` green for the whole collection after Phases 2, 8
      and 9, with the wired count rising by exactly one in each of Phases 8 and 9.
- [ ] No cslib dependency was introduced: `grep -rn 'Cslib' lakefile.toml lake-manifest.json` is
      empty and `grep -rn '^import Cslib' --include=*.lean .` is empty. Mentions of cslib
      identifiers inside docstrings and probe headers are references and are expected.
- [ ] No complexity claim: `grep -rni 'EXPTIME\|polynomial time\|exponential time\|upper bound\|lower bound'`
      over the new modules and probes returns only disclaimer prose.
- [ ] Final: unscoped guarded `lake build` exit 0;
      `grep -rn sorry FormalSystem/Metalogic/WeakCanonical/KTypeSummary FormalSystem/Metalogic/Decidability/RaySummary`
      empty.
- [ ] No file outside `specs/` cites a task number: docstrings cite declaration names, file
      paths and sources (`bash scripts/check-task-references.sh` — the repo-wide lint FAILs on a
      pre-existing baseline, so the gate here is **non-regression**: zero flagged occurrences in
      any file this task touches).

## Artifacts & Outputs

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` and
  `KTypeSummary/{Basic,Segment,Family,Saturation,Universal}.lean`, `KTypeSummary/README.md`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `RaySummary/Seam.lean`,
  `RaySummary/README.md`
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
- `specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean`,
  `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean`, both wired in
  `scripts/check-evidence-probes.sh`
- Edits to existing modules: `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean`
  (declarations relocated, imports and docstring updated, two `obtain` patterns widened),
  `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` (prose-only note fix)
- Registration edits: `FormalSystem.lean` (regenerated), `FormalSystem/Metalogic/WeakCanonical.lean`,
  `FormalSystem/Metalogic/WeakCanonical/README.md`,
  `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md`,
  `FormalSystem/Metalogic/Decidability.lean`, `FormalSystem/Metalogic/Decidability/README.md`,
  `Tests/BimodalTest.lean`
- `specs/711_universal_summary_substrate_stab_fibre/summaries/02_buechi-chain-ktype-substrate-summary.md`
  (written by Phase 9's close-out)

Artifacts named in v1 and **not** produced by this plan:
`Decidability/RaySummary/{Colour,Profile,Forward,Backward,Periodic,Stab}.lean`,
`Tests/BimodalTest/Metalogic/RaySummaryAxiomTest.lean`,
`specs/evidence/seam-gluing-ray-product/ray-summary-discrimination-probe.lean`. They remain in
the task's declared `file_scope` from v1 and are simply unused; see Decisions D-10 and D-12.

## Rollback/Contingency

- Every phase commits only green work through `.claude/scripts/git-commit-scoped.sh`, staging the
  phase's listed files; reverting a phase is `git revert` of its commits, which leaves earlier
  phases intact because the dependency order is strictly linear.
- **Phases 3 and 4 are the relocation phases and carry the only risk to existing green work.**
  If either cannot be made green within its budget, take the recorded fallback: leave the
  declarations where they are and merely drop `private`, then have the new cluster import
  `GroupModel/RamseyFactorization` directly. That delivers the identical public surface at the
  cost of import-graph hygiene; record the switch in the cluster README's measured-closure
  paragraph. No later phase changes.
- If Phase 5's saturation core cannot be closed: `KTypeSummary/` keeps Phases 2-4 (committed
  green), the phase is marked `[BLOCKED]` with the exact goal state per
  `.claude/rules/plan-compliance.md`, and no dependent phase (6, 7, 8) starts. A strategic sorry
  for the mixing-lemma application is admissible only under the five-condition test in
  `context/contracts/anti-analysis.md`, must be tracked in `sorry_inventory` with a follow-up
  task, and is not the default.
- If Phase 7's bridge cannot be stated without assuming the MSO reduction as a *theorem* rather
  than a hypothesis field, **do not state it**. Mark the phase `[BLOCKED]`, record that the
  Medium-confidence bound bit, and close the task on Phases 2-6 plus the probes. Smuggling the
  reduction in as an `axiom`, a `sorry`, or an unflagged `Prop` is a zero-debt violation.
- If a genuine working-tree rollback is ever needed (a phase left the tree red and
  unrecoverable), follow `context/contracts/recovery.md`'s rollback rung:
  `bash .claude/scripts/git-snapshot.sh 711` first (with `--allow-out-of-scope` only if the
  refusal fires and a whole-tree revert is genuinely intended), then the destructive command.
  Never use the default snapshot form as a routine checkpoint; the defensive checkpoint before
  risky work is `bash .claude/scripts/git-snapshot.sh --no-revert 711`.
- `scripts/check-evidence-probes.sh` is never rewritten, only appended to, and is re-read
  immediately before every edit (tasks 733, 734 and 736 are live writers). The evidence
  collection is never weakened to make a probe pass: a probe that stops compiling is repaired by
  tracking the API, and a probe whose claim turns out false is rewritten to record the
  falsification, not deleted.
