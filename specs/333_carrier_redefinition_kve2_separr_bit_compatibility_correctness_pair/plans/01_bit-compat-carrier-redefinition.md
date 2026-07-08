# Implementation Plan: Bit-Compatibility Carrier Redefinition of `kvE2_sepArrL`/`kvE2_sepArrR` (task 333)

- **Task**: 333 - carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair
- **Status**: [NOT STARTED]
- **Effort**: ~18-24 hours (8 phases, one agent run each)
- **Dependencies**: task 321 (closed PARTIAL — N2 verdict; predecessor lineage)
- **Research Inputs**: reports/01_bit-compatibility-carrier-redefinition.md
- **Artifacts**: plans/01_bit-compat-carrier-redefinition.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

Task 321's additive-only v7 plan landed the k=2 correctness gate on the single-positive-sub
fragment (N2 verdict) but left **two tracked strategic sorries** (`SharedWitness.lean:1820`,
`:1952`) plus the deferred multi-positive fragment. All three route to ONE fix that the additive
path structurally could not perform: **redefine the interleaving-enumeration filter
`kvE2_sepValid` (hence `kvE2_sepArrL`/`kvE2_sepArrR`) with cross-σ bit-compatibility FILTERING**,
so the disjunct enumeration admits only arrangements whose per-interval segment content is
compatible with every positive sub's fold-bit content. The redefinition is warranted by
**Rabinovich 2014 Lemma 3.2(1)** (the conjunction↔disjunction equivalence ranges over
*consistent interval-decomposition refinements* — see Source-to-Implementation Mapping). Scope of
edit is confined to `SharedWitness.lean` (task 321's sole-owner additive file). Definition of
done: full `lake build` green, **zero sorry on any live path**, axiom-clean surviving public API
(`[propext, Classical.choice, Quot.sound]`), `BracketCarrierCorrectVPrior` discharged, and the F4
`ℤ` adversarial test proven to DISCRIMINATE (LHS-FALSE + GO verdict record).

### Research Integration

- **reports/01_bit-compatibility-carrier-redefinition.md** (integrated in plan v1, 2026-07-08):
  supplies the 8-phase decomposition (§7), the arrangement-blind defect analysis (§2), the
  non-vacuity break/re-establishment strategy (§3), the two strategic-sorry anatomies (§4), the
  Phase 12/13 requirements (§5), the faithfulness constraints (§6), the risk register (§8), and
  the ground-truth reference index (§9, all locations verified against HEAD `443684ae6` this
  research session). Verified build state at plan time: `lake build …SharedWitness` exit 0, exactly
  2 live sorries (lines 1820, 1952), file_scope git-clean.

### Source-to-Implementation Mapping (H3 — Tier 1: literature)

Ground truth: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.

| Source claim | Location | Implementation site | Phase |
|--------------|----------|---------------------|-------|
| Lemma 3.2(1): conjunction of ∃∀-formulas ≡ disjunction over **consistent interval-decomposition refinements** | rabinovich md:77 (form md:65-74) | new cross-σ bit-compatibility clause in `kvE2_sepSlotLe` / `kvE2_sepValid` (`SharedWitness.lean:327-333`); cite md:77 at the redefined filter | 1 |
| Lemma 5.1: quantifier-free point types = `charBase χ` (depth-0) / `charK (nfk_projFresh σ)` (E[Σ]-atom) ONLY — no `fChainPred`, no bracket-in-bracket | rabinovich md:72, :134-135; `NavigatedSpine.lean:43-48` | no-nesting audit on every point-type position; filter reads bits/indices, never introduces nested types | 1-8 (audit) |
| Lemma 3.2(2): anchor cap 2 — everything over free variables `(x, t)` | rabinovich md:78 | depth-2 gate + wrapper stated over `(x, t)` only | 7 |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the task 321 exhaustion verdict
(research §1.2-1.3), the O4 CRUX RECORD (`SharedWitness.lean:1562-1655`), and the Rabinovich
faithfulness constraints (research §6).

**Do NOT**:
- **Do NOT add an additive gate clause** to repair the cross-σ obstruction. Task 321's v7 plan
  exhausted the additive route across 13 dispatches; the O4 CRUX RECORD (`:1618-1626`) proves no
  additive gate clause closes it: a **conjunctive** cross-σ clause is sound-sufficient but breaks
  honest-derivability / non-vacuity (FM-vac, prohibited); a **disjunctive** clause is
  arrangement-blind while the placement is arrangement-chosen. The ONLY faithful repair is
  bit-compatibility FILTERING of the enumeration (`:1627-1634`).
- **Do NOT weaken the redefined `kvE2_sepValid` to a vacuous / always-true filter** to make
  non-vacuity (Phase 2) pass. A vacuous filter re-admits the arrangement-blind defect and
  reintroduces the underdetermined `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1)` bit. If the honest
  witness-order arrangement cannot be shown to pass the filter, the filter is too STRONG —
  re-examine the compatibility predicate, do not relax it toward vacuity (risk register, HIGH).
- **Do NOT weaken the F4 `ℤ` adversarial test** (Phase 8). It MUST discriminate: if the LHS still
  holds at `(10,20)`, completeness lost the `σ.2` dependence → reopen Phase 5; NEVER weaken the
  test to make it pass (v7 plan `:847`).
- **Do NOT introduce a `x1 < e_i` relative-position literal** on any live path (LITMUS). The
  filter reads arrangement slot **indices** and **fold bits** (`kvE2_sepBits`), never a model-order
  literal between the fresh witness and a slot (crux record `:1644-1645`).
- **Do NOT introduce nested point-type structure** (no-nesting). Every point-type position stays
  `charBase χ` or `charK (nfk_projFresh σ)` (`NavigatedSpine.lean:43-48`). The filter constrains
  only which permutations are enumerated, never the point types themselves.
- **Do NOT de-privatize `k1v_reconstruct_nf3`** (`CarrierK1V.lean:918`). The Phase 7 atom-layer
  reconstruction at `[w,x,t]` is re-derived additively per D2; `nf_eval_depth1_fold_iff`
  (`CarrierKv.lean:466`) is the available fold reference.
- **Do NOT make the compatibility clause non-`Bool` / non-`decide`-based.** It must stay
  `Bool`-valued so `List.filter` and `Decidable` survive (`kvE2_sepBits` is already `Bool`; risk
  register, MEDIUM).
- **Do NOT edit any do-not-edit asset.** `SubBracket2V.lean`, `NavigatedSpine.lean`, `Base.lean`,
  `CarrierK1V.lean`, `CarrierKv.lean`, `PriorInterface.lean`, `RefutationF2.lean`, `SubBracket2.lean`,
  `SubBracket.lean` in `NfMultiAnchorBridge/` and all sibling-Kamp files must stay byte-identical.
- **Do NOT introduce a new sorry, `sorry` deferral, or new axiom** (zero-debt). Final state must be
  sorry-free on every live path and axiom-clean.

**MUST preserve** (see Preserved Assets table below for the itemized accounting):
- The carrier structure `kvE2_sepBody` (`:551`), the depth-2 gate `kvE2_sepGate` (`:532`, NOT
  redefined — only the enumeration filter is), and `kvE2_sepGate_holds_of_honest` (`:849`).
- The ∀-anchor dissolver `kvE2_sepSingleton_sound_of_parts_at` (`:1838`, sorry-free, axiom-clean)
  and the singleton wrapper `kvE2_sepBody_singleton_sound_left` (`:1891`).
- The three landed soundness closers in the do-not-edit `SubBracket2V.lean`
  (`kvE_subBracket2V_sound`, `_sound_of_parts` `:1025`, `_sound_of_outer` `:1216`) and the O6
  source `kvE_subBracket2V_complete` (`:1465`).
- Existing test coverage: the F4 discriminator semantics (Phase 8) must remain a genuine
  LHS-FALSE discriminator.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **Route = bit-compatibility FILTERING**, not additive gate repair (task 321 exhaustion verdict,
  research §1.3; option B of the 321 handoff). Grounded in Rabinovich Lemma 3.2(1) "consistent
  refinement" (md:77) — faithful, not ad-hoc.
- **The ∀-anchor obstruction is dissolved per-σ** via the `_sound_of_parts_at` pattern (`:1838`),
  consuming the six gate conjuncts only at the single extracted anchor `x1` — NOT via a global
  ∀-anchor statement (which is FALSE at singleton size, crux record `:1636-1642`).
- **Scope is confined to `SharedWitness.lean`** (+ its existing umbrella import if needed). This is
  a redefinition inside task 321's sole-owner file, so it is NOT strictly append-only, but it does
  NOT spread to any other file.

### Preserved Assets

Task 321 landed the following work (verified green at HEAD `443684ae6`). The redefinition
deliberately BREAKS three items (marked ⚠ — non-vacuity witness and the two `_valid` lemmas); all
others must not regress.

| Component | File / Location | Status | Notes |
|-----------|-----------------|--------|-------|
| O1/O1b carrier `kvE2_sepBody` | SharedWitness.lean:551 | [COMPLETED] | structure survives; disjunct enumeration re-filtered |
| Depth-2 gate `kvE2_sepGate` | SharedWitness.lean:532 | [COMPLETED] | NOT redefined |
| `kvE2_sepGate_holds_of_honest` | SharedWitness.lean:849 | [COMPLETED] | survives filter change |
| O2 membership collapse `kvE2_sepBody_holds_iff` | SharedWitness.lean:579 | [COMPLETED] | plumbing re-checked in Phase 3 |
| ⚠ Non-vacuity `kvE2_sepBody_nonvacuous` | SharedWitness.lean:918 | [BREAKS] | must re-witness honest arrangement (Phase 2) |
| ⚠ `kvE2_sepSlotsL_valid` / `_valid` (canonical identity) | SharedWitness.lean:722 / :734 | [BREAKS] | identity arrangement no longer admitted; replaced by honest-order lemma (Phase 2) |
| O3 extraction `kvE2_sepDisjunct_extract` | SharedWitness.lean:1232 | [COMPLETED] | signature change in Phase 3 (surface segments, not discard @ :1259) |
| O3 `kvE2_sepBody_extract` / `_halves` | SharedWitness.lean:1369 / :1328 | [COMPLETED] | consumed by Phases 4-5 |
| O4 derivable core (zone4/offFiber/innerNine/segForm) | SharedWitness.lean (O4 block) | [COMPLETED] | survive |
| N2 ∀-anchor dissolver `kvE2_sepSingleton_sound_of_parts_at` | SharedWitness.lean:1838 | [COMPLETED] | sorry-free, axiom-clean; do not re-open |
| N2 singleton wrapper `kvE2_sepBody_singleton_sound_left` | SharedWitness.lean:1891 | [COMPLETED] | forward direction, wired |
| Soundness closers (do-not-edit) | SubBracket2V.lean:1025 / :1216 / sound | [COMPLETED] | byte-identical; consumed only |
| O6 completeness source (do-not-edit) | SubBracket2V.lean:1465 | [COMPLETED] | byte-identical; consumed in Phase 5 |
| Per-σ kit (do-not-edit) | SubBracket2V.lean:1855 | [COMPLETED] | byte-identical; consumed in Phase 6 |

## Goals & Non-Goals

- **Goals**:
  - Redefine `kvE2_sepSlotLe` / `kvE2_sepValid` (hence `kvE2_sepArrL`/`R`) with a cross-σ
    bit-compatibility clause (Phase 1).
  - Re-establish non-vacuity by witnessing the honest witness-order arrangement (Phase 2 —
    make-or-break).
  - Repair O2/O3 plumbing so segment realizations are surfaced (Phase 3).
  - Discharge both strategic sorries (`:1820`, `:1952`) via the now-consistent per-interval
    segments (Phases 4-5).
  - Lift to the full multi-positive-sub correctness pair (Phase 6).
  - Discharge `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) — Phase 12/N2-C (Phase 7).
  - Run the F4 `ℤ` adversarial discriminator + GO verdict record + full integrity sweep — Phase
    13 (Phase 8).
- **Non-Goals**:
  - No edits outside `SharedWitness.lean` (+ umbrella import).
  - No downstream rewire of task 309 Phase 13.4 or the `KampPrior.lean:351` strategic-sorry hook
    (both unblocked by the GO verdict but out of scope here).
  - No de-privatization of `k1v_reconstruct_nf3`; no new axioms; no `sorry` deferral.

## Risks & Mitigations

- **Risk (HIGH — the new make-or-break): Phase 2 non-vacuity re-establishment fails** — the honest
  arrangement is not expressible as a single admitted permutation. *Mitigation*: the honest model
  DOES induce a real total order on all witnesses; the induced permutation is bit-compatible by
  construction (each slot realized at a real model point carrying its 1-type). If it cannot be
  shown to pass the filter, the filter is too strong — re-examine the compatibility predicate; do
  NOT weaken to a vacuous filter (Postmortem Constraints).
- **Risk (MEDIUM): coverage collapse (Phase 4) does not actually follow from the redefinition.**
  *Mitigation*: validate the collapse claim early — Phase 1 includes a 2-positive sanity check
  before committing downstream. ADDENDUM-2 (`:763-765`) asserts the collapse but task 321 never
  executed it.
- **Risk (MEDIUM): redefined filter breaks `Decidable`/computability of the `filter`.**
  *Mitigation*: keep the compatibility clause `Bool`-valued and `decide`-based (as the current
  `kvE2_sepSlotLe`); `kvE2_sepBits` is already `Bool`.
- **Risk (MEDIUM): O2/O3 plumbing rework larger than expected** — `extract` must now surface
  segments. *Mitigation*: the segment realizations already exist in the raw `IntervalPattern.holds`
  (dropped at `:1259`); surfacing them is a signature change, not new mathematics (research §8).
- **Risk (LOW-MEDIUM): multi-positive lift (Phase 6) hits a NEW cross-σ obstruction.**
  *Mitigation*: the redefinition was designed precisely against the cross-σ crux; the ∀-anchor
  obstruction must still be dissolved per-σ via the `_sound_of_parts_at` pattern generalized to
  multiple anchors. Contingency: if a genuinely new obstruction surfaces, STOP, do NOT weaken any
  filter, and escalate (see Rollback/Contingency).
- **Risk (LOW): F4 test (Phase 8) fails to discriminate.** *Mitigation*: LHS-TRUE means
  completeness lost `σ.2` dependence → reopen Phase 5; never weaken the test.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 3, 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |

**No phases run in parallel.** Every phase edits the single file `SharedWitness.lean` (H7
territory contract: exclusive ownership, no overlap possible), and each phase's build-green
depends on the prior phase's redefinition/plumbing being in place. The wave map is therefore
strictly sequential — one phase per wave.

### Phase 1: Redefine `kvE2_sepSlotLe` / `kvE2_sepValid` with the cross-σ bit-compatibility clause [PARTIAL]

> **Status note (session sess_1783522894_0a5276)**: The compat predicate
> (`kvE2_sepSlotChi`/`kvE2_sepFreshZoneBefore`/`kvE2_sepFreshZoneAfter`/`kvE2_sepCompat`) is
> STAGED and committed green (`e86d9dcf4`). The in-place filter switch + all mechanical
> downstream repairs are verified-compiling (except the two Phase 2 `_valid` lemmas) and captured
> in `handoffs/phase1-switch-and-repairs.patch`. Not wired live because the switch is inseparable
> from Phase 2 non-vacuity (identity arrangement no longer valid). Resume via
> `handoffs/01_phase2-nonvacuity-make-or-break.md`. The 2-positive `#eval` sanity check is NOT yet
> run — do it after applying the patch, before the Phase 2 proof.
- **Goal:** Replace the arrangement-blind first disjunct of `kvE2_sepSlotLe` (`:327-329`,
  `!(sub a = sub b)` ⇒ any cross-σ order valid) with a cross-σ bit-compatibility constraint, so an
  arrangement is admitted only when every cross-σ slot placement matches a TRUE σ-bit for that
  (zone, χ). Cite Rabinovich Lemma 3.2(1) (md:77) at the redefined filter.
- **Tasks:**
  - [ ] Define the compatibility predicate: a slot owned by τ realizing χ, when placed in a region
        relative to another positive σ, must satisfy `kvE2_sepBits σ (σ-relative-zone) χ = true`
        (`kvE2_sepBits` at `:152-154`). Key the σ-relative zone on σ's outer zone class
        `nf0_zoneSpec σ.1` for the placement-generic reading (research §2.2: `kvE_sub2_zXU` means
        "`x<v<x1`" for left-interior σ but "`x<v<w`" for right-interior σ).
  - [ ] Keep the clause `Bool`-valued / `decide`-based; leave σ-own slots unconstrained by the new
        clause (they are bit-compatible by construction via `kvE2_sepS`, `:178-180`).
  - [ ] Rebuild `kvE2_sepValid` (`:332-333`) over the new `kvE2_sepSlotLe`; confirm
        `kvE2_sepArrL`/`kvE2_sepArrR` (`:338-345`) still compute (filter over `.permutations`).
  - [ ] **2-positive sanity check** (de-risks Phase 4 collapse): on a 2-interior-positive instance,
        confirm by `#eval` / `decide` that the arrangement-blind bad interleaving (τ's `zXU`-χ slot
        below σ's fresh slot with σ-bit false) is now REJECTED, and a bit-true interleaving is
        ADMITTED. Record the result inline as a comment for Phase 4.
  - [ ] LITMUS grep (`grep -nE "fChainPred|x1[[:space:]]*<[[:space:]]*e"`) = 0 live hits; no-nesting
        audit on the new clause.
- **Timing:** ~2-3 hours.
- **Depends on:** none
- **Estimated output:** ~120-200 lines (definition rewrite + sanity-check scaffold).
- **Sorry-count target:** 2 (unchanged — the two pre-existing strategic sorries at `:1820`, `:1952`
  remain; NO new sorry introduced by the redefinition).
- **Done when:** `lake build …SharedWitness` exit 0; `kvE2_sepArrL`/`ArrR` type-check and compute;
  the 2-positive sanity check shows reject-bad / admit-good; LITMUS 0 hits; `lean_verify` clean on
  new/changed symbols; `git diff --stat` touches only `SharedWitness.lean`.

### Phase 2: Re-establish non-vacuity via the honest witness-order arrangement (make-or-break) [NOT STARTED]

> **Status note (session sess_1783522894_0a5276, HEAD `ec9e63b7c`)**: Confirmed make-or-break.
> (1) Audit item 1 (fresh-less-sub cross-σ gap) RESOLVED as **1a** — the whole-macro-side exclusion
> of a fresh-less sub is owned by `kvE2_sepSegLForSub`/`kvE2_sepSegRForSub` (uniform `kvE_sub2_zXU` /
> `kvE_sub2_zWT` segment forms), so the compat filter is correctly silent; NO third clause added.
> (2) Audit item 2 (mixed-class discrimination) landed as a **proof-form** universal theorem
> `kvE2_sepCompat_lX1_eq` (a foreign χ-slot before σ's fresh slot is admitted iff σ's `zXU` bit for χ
> is true) — stronger than an `#eval` datapoint, axiom-clean. (3) Proven structurally that NO
> bit-independent arrangement passes for multi-positive qnf, so non-vacuity genuinely needs the
> honest model-sorted arrangement — a NOVEL **joint slot-level sorted realization** (not a lift of
> `k1v_sorted_realization`/`_3`, whose Nodup-type requirement fails because χ-types recur across
> owners). Full blueprint + first-next-step in `handoffs/02_phase2-joint-sort-blueprint.md`. The
> filter switch (`handoffs/phase1-switch-and-repairs.patch`) applies onto BASELINE `443684ae6`
> (not HEAD). Build left GREEN with the switch reverted (staged-not-wired), 2 tracked sorries.
- **Goal:** Prove that the honest witness-order arrangement passes the redefined `kvE2_sepValid`,
  replacing the now-false canonical-identity lemmas `kvE2_sepSlotsL_valid`/`_valid` (`:722`/`:734`),
  and rebuild `kvE2_sepBody_nonvacuous` (`:918-938`) on that witness. This is the FM-vac guard — the
  highest-risk phase.
- **Tasks:**
  - [ ] Introduce the honest-order lemma: from an honest realization `nf_eval_nf M 2 3 [w,x,t] qnf`,
        each positive σ's fresh witness `x1_σ` and its bit-true 1-types are realized at genuine
        model points ordered by `<`; that real order induces a permutation of `kvE2_sepSlotsL qnf`
        that (a) respects each σ's internal rank and (b) is bit-compatible (each cross-σ slot sits
        in a region where its owner's bit is TRUE, because realized at a real point carrying that
        1-type). Prove it passes the redefined `kvE2_sepValid`.
  - [ ] Reuse the surviving `flatMap`-pairwise machinery (`kvE2_sep_pairwise_flatMap` `:611`,
        `kvE2_sepSlotLe_of_rank` `:631`); REPLACE the cross-σ totality lemma
        `kvE2_sepSlotLe_of_sub_ne` (`:637`, used at `:730`/`:742`) — no longer unconditionally true
        — with the bit-compatibility-conditioned version.
  - [ ] Rewire `kvE2_sepBody_nonvacuous` (`:926-938`) membership witness to the honest arrangement;
        confirm `kvE2_sepGate_holds_of_honest` (`:849`) still discharges the gate branch unchanged.
  - [ ] Guard against vacuity: assert (comment + proof structure) that the disjunct list is
        NON-empty and the witness is the honest one — do NOT relax the filter to admit it.
- **Timing:** ~4-5 hours (make-or-break).
- **Depends on:** 1
- **Estimated output:** ~200-300 lines (honest-order lemma + machinery replacement + non-vacuity
  rewire). If the honest-order lemma alone exceeds ~300 lines, split into 2.1 (honest-order
  permutation construction) and 2.2 (passes-filter + non-vacuity rewire).
- **Sorry-count target:** 2 (still the two `:1820`/`:1952` strategic sorries; non-vacuity itself
  MUST be sorry-free — a non-vacuity sorry is a vacuity device and is prohibited).
- **Done when:** `lake build` exit 0; `kvE2_sepBody_nonvacuous` sorry-free and axiom-clean via
  `lean_verify`; honest-order lemma proven; no vacuous filter; LITMUS 0 hits; diff only
  `SharedWitness.lean`.

### Phase 3: Repair O2/O3 plumbing — surface segment realizations in `kvE2_sepDisjunct_extract` [NOT STARTED]
- **Goal:** Update the extraction plumbing so the segment realizations (currently DISCARDED at
  `:1259` via `obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩` — the three `IntervalPattern.holds`
  components dropped) are SURFACED, so Phases 4-5 can consume them. Re-check O2 membership collapse
  under the redefined filter.
- **Tasks:**
  - [ ] Change the signature/return of `kvE2_sepDisjunct_extract` (`:1232`) to preserve the segment
        `IntervalPattern.holds` components instead of discarding them at `:1259` (signature change,
        not new mathematics — research §8 MEDIUM).
  - [ ] Propagate through `kvE2_sepBody_extract` (`:1369`) and the membership lemmas
        (`:1187`/`:1196`/`:1205`/`:1214`); re-verify `kvE2_sepBody_holds_iff` (`:579`) under the
        redefined enumeration.
  - [ ] Confirm `kvE2_sepDisjunct_halves` (`:1328`) still surfaces the bracket halves consistently.
- **Timing:** ~2-3 hours.
- **Depends on:** 2
- **Estimated output:** ~150-250 lines (signature change + propagation).
- **Sorry-count target:** 2 (unchanged; plumbing must stay sorry-free).
- **Done when:** `lake build` exit 0; extract now returns segment realizations; downstream callers
  compile; `lean_verify` clean; diff only `SharedWitness.lean`.

### Phase 4: Discharge `kvE2_sepSingleton_coverage_left` (sorry @ :1820) [NOT STARTED]
- **Goal:** Discharge the single-anchor coverage residue (`:1796-1820`) — produce `h_atom`,
  `h_fwd`, `h_bwd` AT the single extracted anchor `x1` — using the now-consistent per-interval
  segments surfaced in Phase 3. Validates the central efficiency claim (research §4.1): the
  six-piece coverage collapses because the bit-compatibility-filtered enumeration aligns
  per-interval segment content with per-zone σ exclusion.
- **Tasks:**
  - [ ] Consume the segment realizations surfaced by Phase 3 to build `h_fwd`/`h_bwd` uniformly
        (pieces 2-5 of ADDENDUM-2 collapse: point→interval map, bracket-segment→σ-`segForm`
        refinement `:427`, depth-0 mutual-exclusivity, exterior/boundary decoder via `kvE2_sepEpL`
        `:354` / `kvE2_sepEpR` `:376`).
  - [ ] Read slot INDICES for the point→interval location map — NEVER an `x1 < e_i` literal (LITMUS).
  - [ ] Confirm `kvE2_sepSingleton_sound_of_parts_at` (`:1838`) still consumes the three conjuncts
        unchanged; re-verify `kvE2_sepBody_singleton_sound_left` (`:1891`, wired `:1920-1924`).
- **Timing:** ~3-4 hours.
- **Depends on:** 3
- **Estimated output:** ~150-250 lines.
- **Sorry-count target:** **1** (the `:1820` sorry is discharged; only `:1952` remains).
- **Done when:** `lake build` exit 0; `kvE2_sepSingleton_coverage_left` sorry-free + axiom-clean via
  `lean_verify`; sorry count = 1; LITMUS 0 hits; diff only `SharedWitness.lean`.

### Phase 5: Discharge `kvE2_sepBody_singleton_complete_left` (sorry @ :1952) [NOT STARTED]
- **Goal:** Discharge the O6 completeness lift (`:1939-1952`) — from σ's depth-1 realization at a
  shared `w` (via the do-not-edit `kvE_subBracket2V_complete` `SubBracket2V.lean:1465`), rebuild the
  joint carrier's `.holds` at singleton size by constructing the single realized disjunct of the
  (degenerate) interleaving product. Under the redefinition the admitted arrangement for the honest
  model is uniquely determined by the witness ordering (dovetails with Phase 2), so "which disjunct
  is realized" has a canonical answer.
- **Tasks:**
  - [ ] Construct the O2 arrangement realization at singleton size using the honest-order
        arrangement from Phase 2 as the uniquely-admitted disjunct.
  - [ ] Assemble the `.holds` from σ's depth-1 realization; no `x1 < e_i` literal (LITMUS);
        no nested point types (no-nesting).
- **Timing:** ~3-4 hours.
- **Depends on:** 3, 4
- **Estimated output:** ~150-250 lines.
- **Sorry-count target:** **0** (the `:1952` sorry is discharged; `SharedWitness.lean` is now
  sorry-free on all live paths).
- **Done when:** `lake build` exit 0; `kvE2_sepBody_singleton_complete_left` sorry-free +
  axiom-clean; **sorry count = 0**; LITMUS 0 hits; diff only `SharedWitness.lean`.

### Phase 6: Lift to the full multi-positive-sub correctness pair [NOT STARTED]
- **Goal:** Generalize the singleton soundness+completeness pair to ≥2 interior positives, using the
  per-σ kit `kvE_subBracket2V_correctness_pair` (`SubBracket2V.lean:1855`, do-not-edit) and the
  `_sound_of_parts_at` dissolver pattern (`:1838`) generalized to multiple anchors.
- **Tasks:**
  - [ ] Both directions over ≥2 interior positives: soundness (each σ's six gate conjuncts consumed
        at its own extracted anchor) and completeness (joint carrier `.holds` rebuilt from the
        multi-σ realization).
  - [ ] Dissolve the ∀-anchor obstruction per-σ (generalize `_sound_of_parts_at` to multiple
        anchors) — do NOT restate a global ∀-anchor claim (FALSE at singleton, SETTLED).
  - [ ] If a genuinely NEW cross-σ obstruction surfaces (not the one the redefinition targets),
        STOP and escalate (Rollback/Contingency) — do NOT weaken any filter.
- **Timing:** ~3-4 hours.
- **Depends on:** 5
- **Estimated output:** ~150-300 lines. If both directions each exceed ~250 lines, split into 6.1
  (multi-positive soundness) and 6.2 (multi-positive completeness).
- **Sorry-count target:** 0 (no new sorry).
- **Done when:** `lake build` exit 0; multi-positive pair proven sorry-free + axiom-clean; sorry
  count = 0; LITMUS 0 hits; diff only `SharedWitness.lean`.

### Phase 7: Phase 12 (N2-C → FULL) gate wrapper — discharge `BracketCarrierCorrectVPrior` [NOT STARTED]
- **Goal:** Discharge `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) for the carrier —
  the full multi-positive statement now that Phase 6 delivers it (else minimally the singleton
  fragment `kvE2_sepBody_correct_singleton`). The two directions are Phase 6's soundness +
  completeness once assembled into the predicate shape. Anchor cap 2 (Rabinovich md:78): stated
  over `(x, t)` only.
- **Tasks:**
  - [ ] Bridge `VVecEA2` (what `kvE2_sepBody` produces) into the `BracketEndCharCarrierV sig k`
        framing the predicate expects, or state the biconditional in the same shape (research §5.1).
  - [ ] Depth-2 unfold via `nf_eval_nf` (`NormalForm.lean:198-207`); atom-layer reconstruction at
        `[w,x,t]` re-derived additively per D2 (do NOT de-privatize `k1v_reconstruct_nf3`;
        `nf_eval_depth1_fold_iff` `CarrierKv.lean:466` is the available fold reference).
  - [ ] FM-vac discipline: honest antecedent, not a vacuity device.
- **Timing:** ~2-3 hours.
- **Depends on:** 6
- **Estimated output:** ~120-250 lines.
- **Sorry-count target:** 0.
- **Done when:** `lake build` exit 0; `BracketCarrierCorrectVPrior` discharged for the carrier,
  sorry-free + axiom-clean; diff only `SharedWitness.lean`.

### Phase 8: Phase 13 — F4 `ℤ` adversarial discriminator + GO verdict record + integrity sweep [NOT STARTED]
- **Goal:** Instantiate the F4 `ℤ` counterexample against `kvE2_sepBody` and PROVE the LHS is FALSE
  at `(10,20)` (the test MUST discriminate), then land the GO/NO-GO verdict record (F1-F4 house
  style) and the full integrity sweep. The GO verdict unblocks task 309 Phase 13.4 and the
  `KampPrior.lean:351` hook rewire (both downstream, out of scope).
- **Tasks:**
  - [ ] Instantiate F4: `M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
        `σ''=char[14,16,11,20]` vs honest `char[14,15,10,20]` marked false; prove
        `¬ (kvE2_sepBody …).holds … 10 20`.
  - [ ] DISCRIMINATION check: if the LHS holds, completeness lost `σ.2` dependence → reopen Phase 5;
        NEVER weaken the test (Postmortem Constraints).
  - [ ] Land the GO verdict record (F1-F4 house style).
  - [ ] Integrity sweep: `lake build` full-project green; additive-only diff review; do-not-edit
        assets byte-identical (`git status --short` over file_scope clean except `SharedWitness.lean`);
        NO sorry on any live path (`grep -n "sorry"` shows only comment/string hits, 0 live);
        axiom-clean via `lean_verify` on the surviving public API
        (`[propext, Classical.choice, Quot.sound]`); LITMUS grep 0 live hits; no-nesting audit.
- **Timing:** ~3-4 hours.
- **Depends on:** 7
- **Estimated output:** ~150-300 lines (F4 instantiation + verdict record + sweep). If F4
  instantiation alone exceeds ~250 lines, split into 8.1 (F4 discriminator) and 8.2 (verdict +
  sweep).
- **Sorry-count target:** 0 (final state; verified by the sweep).
- **Done when:** full `lake build` exit 0; F4 LHS-FALSE proven (discriminates); GO verdict recorded;
  integrity sweep all-green; sorry count = 0 on every live path; axiom-clean; do-not-edit assets
  byte-identical.

## Testing & Validation

Per-phase invariants (run at every phase's Done-when):
- [ ] `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
      exit 0 (full-project build at Phase 8).
- [ ] Sorry inventory: `grep -n "sorry" …/SharedWitness.lean` — live-sorry count matches the phase's
      Sorry-count target (2 → 2 → 2 → 2 → 1 → 0 → 0 → 0 → 0 across Phases 1-8).
- [ ] `lean_verify` axiom-clean (`[propext, Classical.choice, Quot.sound]`) on new/changed symbols.
- [ ] LITMUS grep `grep -nE "fChainPred|x1[[:space:]]*<[[:space:]]*e"` = 0 live hits.
- [ ] No-nesting audit: every point-type position is `charBase χ` or `charK (nfk_projFresh σ)`.
- [ ] `git diff --stat` touches only `SharedWitness.lean` (+ umbrella import if needed); do-not-edit
      assets byte-identical.
- [ ] Phase 8 only: F4 `ℤ` LHS-FALSE proven (discriminates); GO verdict recorded.

## Artifacts & Outputs

- plans/01_bit-compat-carrier-redefinition.md (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (redefined filter, re-established non-vacuity, repaired plumbing, both sorries discharged,
  multi-positive pair, gate wrapper, F4 discriminator + verdict record)
- summaries/01_bit-compat-carrier-redefinition-summary.md (on completion)

## Rollback/Contingency

- **Per-phase git discipline**: commit each phase at its green Done-when (`task 333 phase P: …`).
  Any phase that fails its build-green stays uncommitted; fix forward (never discard uncommitted
  work — snapshot via `.claude/scripts/git-snapshot.sh` before any intentional rollback).
- **Phase 2 (make-or-break) fails**: if the honest witness-order arrangement cannot be shown to
  pass the filter, the filter is too STRONG — re-examine the Phase 1 compatibility predicate; do
  NOT weaken it to vacuity. If irreducible, STOP and report — the redefinition needs revision, not
  a vacuous filter.
- **Phase 6 hits a genuinely new cross-σ obstruction**: STOP, do NOT weaken any filter; capture the
  `lean_goal` and escalate (candidate `/spawn` for a scoped multi-positive follow-up, or fall back
  to the landed N2 single-positive fragment for the Phase 7 wrapper — the F4 discriminator in Phase
  8 runs meaningfully regardless of FULL vs N2 scope).
- **Phase 8 F4 fails to discriminate (LHS-TRUE)**: completeness lost `σ.2` dependence → reopen Phase
  5; NEVER weaken the test.
- **Full revert**: because all edits are confined to `SharedWitness.lean`, a full rollback is
  `git checkout 443684ae6 -- …/SharedWitness.lean` (only after a snapshot per the dirty-tree rule).
