# Implementation Plan: Interior-Restricted Owner Index and Tie-Admitting Weak Orders for kvE2_sep

- **Task**: 342 - rework kvE2_sep arrangement carrier with interior-restricted owner index and tie-admitting weak orders
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours (9 phases, ~1.5-2.5h each; one phase per orchestrator cycle, 11 cycles available)
- **Dependencies**: None (parent task 337 stays [BLOCKED] until this lands)
- **Research Inputs**:
  - `specs/342_rework_kve2_sep_arrangement_carrier_with_interiorrestricted_owner_index_and_tieadmitting_weak_orders/reports/01_rabinovich-fidelity-audit.md` (page-cited ground truth; SUPERSEDES the task description on citation phrasing)
  - `specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/07_hlr-inconsistency-coincidence-merge.md` §§4-5 (target completeness shape + blast radius)
- **Artifacts**: plans/01_interior-index-and-tie-admitting-orders.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4

## Overview

The kvE2_sep completeness layer in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(5,406 lines) carries two machine-certified defects that must be fixed together because they
rewrite the same declarations: (1) the hypothesis `hLR` on four completeness theorems is
certified UNSATISFIABLE by `kvE2_sepHonest_hLR_absurd` (SW:4618) — it is a Lean-layer artifact
with no Rabinovich counterpart, and the fix is Rabinovich §5's (p.7) interior-restricted owner
index (`kvE2_sepPosI`); (2) the `Nodup` conjunct (iii) of `kvE2_sepDisjValid` (SW:1350-1354)
makes equality-case order types unrepresentable, so honest tie models realize no disjunct — the
fix is tie-admitting weak orders with meet-folded strict disjuncts, forced by Def 3.1 (p.4).
Definition of done: `lake build` green; the rebuilt completeness chain ending in
`kvE2_sepBody_complete_holds'` (report 07 §4 shape) axiom-clean
(`{propext, Classical.choice, Quot.sound}`); `kvE2_sepHonest_hLR_absurd` compiles verbatim;
no `sorry` in landed declarations.

**The audit verdict is FAITHFUL — the design is settled. Implementers do not re-litigate it.**

### Research Integration

- Audit report 01 (task 342): Part I FULLY GROUNDED in §5 (p.7); Part II FAITHFUL with citation
  correction D1; D2/D7 scoping; in-file precedents `kvE2_sepPosIn` (SW:199) and per-cut
  meet-folded segments (SW:983-994) confirmed.
- Report 07 (task 337) §4: corrected target `kvE2_sepBody_complete_holds'`; §5: full blast-radius
  table used to size Phases 2-7 below.

### Citation Discipline (D1 — MANDATORY, binding on every artifact this plan produces)

Rabinovich's Lemma 3.2 is prefaced "It is clear that" and has **no printed proof anywhere in the
16 pages**. NEVER write "per the proof of Lemma 3.2(1)". The only sanctioned phrasing for the
tie-collapse mechanism, verbatim or near-verbatim:

> "forced by Def 3.1 (p.4) — strict chain + conjunction semantics; corroborated by Def 3.1's
> non-distinct pinning indices (p.4), the k=m equality-case order-type disjunction (p.7), and
> Def 7.5's `z0 = z1` alternative (p.13); Lemma 3.2(1) (p.4) states the closure without printed
> proof."

D2: the k=m split concerns coincident FREE-VARIABLE pinnings (`z0 = z1`) at the §5 negation
stage, NOT bound-witness merging — cite as corroboration only. In kvE2_sep the outer points are
strictly ordered by `hxw`, `hwt`, so k=m never arises; admissible ties are witness-level
(base-base, base-foreign-anchor). Def 7.13 (p.15) licenses ONLY the outer `x < w < t`
segmentation — never cite it for coincidence merging.

### Strict-Quotient Guard (state in every Part II docstring)

Tie classes are *index-level data only*. Every emitted disjunct is a strict Def-3.1 bracket over
the quotient: one slot per tie class, point type
`formula_conjList (class.map (kvE2_sepSlotType charBase charK))`. `IntervalPattern.holds` strict
monotonicity (`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean:106-132` — note:
under `Kamp/`, NOT `NfMultiAnchorBridge/`) is an exact Def 3.1 transcription and is **never
weakened**. Any drift toward `≤` bracket semantics is an infidelity and a hard defect.

### D7 Note (state in the conjunct-(iii') docstring)

Anchor-anchor tie exclusion has **no paper counterpart**. It is a Lean-side, machine-checked
pruning justified by `nf_eval_unique` (used at SW:2522-2529, 2569): order types that are honestly
unrealizable may be dropped without losing completeness. Document it exactly as such — never as
Rabinovich content.

### Source-to-Implementation Mapping (Tier 1, literature-backed)

| Source (Rabinovich 2014, PDF pages) | Lean identifier | Status in this plan |
|---|---|---|
| Def 3.1, p.4 — strict chain `xn > … > x0`, pinned `z_k = x_{i_k}` | `IntervalPattern.holds` (Kamp/ExistsForallNF.lean:106-132) | UNTOUCHED (source-mandated) |
| §5 ψ0/ψ1/φ split, p.7 — interiority as construction invariant | `kvE2_sepPosI` (new, Phase 1); re-anchored index (Phases 2-4); `hLR` deletion (Phase 5) | Phases 1-5 |
| §5 + Prop 3.5, pp.5,7 — non-interior → atomic E[Σ] endpoint content | existing `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR` (SW:886-946) + honesty lemmas (new) | Phase 8 (b) |
| Def 3.1 forcing (tie collapse; Lemma 3.2(1) states closure without printed proof; corroborated k=m p.7, Def 7.5 p.13) | conjunct-(iii) replacement, `kvE2_sepTieGroupedL/R`, `kvE2_sepDisjunct'` | Phases 6-7 |
| Def 7.13 + Lemma 7.14, p.15 — outer segmentation between DISTINCT variables only | outer `x < w < t` split of `kvE2_sepBody` | UNTOUCHED |
| (no paper counterpart) machine guard | `kvE2_sepHonest_hLR_absurd` (SW:4618) | RETAINED VERBATIM |
| (no paper counterpart, D7) anchor-anchor pruning | `nf_eval_unique`-backed anchor-distinct conjunct | Phase 6, documented as Lean-side |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the task-337 blocker record, the
task-342 fidelity audit, and explicit user decisions.

**Do NOT**:
- Write "per the proof of Lemma 3.2(1)" or attribute the tie-collapse mechanism to a proof text —
  there is none (D1). Use the sanctioned phrasing above.
- Define `kvE2_sepPosI` as `kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3`.
  The append breaks global enumeration order and destroys the `Nodup`/`zipIdx`/membership
  transfer. It MUST be the single two-zone order-preserving filter (Phase 1).
- Weaken `IntervalPattern.holds` monotonicity or introduce any `≤`-chain bracket variant.
- Introduce any `x1 < e_i` relative-position literal (LITMUS, NavigatedSpine.lean:437). Witness
  bounds come from `IntervalPattern.holds`'s own range, never a chain.
- Let any OPEN zone key enter any coincident/tie read (F5). Base-anchor tie discharges read the
  anchor owner's CLOSED self-zone bit at the FOREIGN base type; base-base classes read no
  self-zone key. Strict placements keep their OPEN keys.
- Resurrect the REJECTED alternative: keeping `wo` over all of `kvE2_sepPos` with a non-interior
  `true` branch in `kvE2_sepDisjValidOwner`. Rejected by explicit user decision — unfaithful to
  the interleaving index (which ranges over bracket witnesses only, §5 p.7).
- Modify, rename, or delete `kvE2_sepHonest_hLR_absurd` (SW:4618). It must keep compiling
  **verbatim** as a permanent design guard. It quantifies over `kvE2_sepPos`, which this task
  does not touch — only the arrangement index moves to `kvE2_sepPosI`, so retention is
  compatible by construction.
- Re-litigate the design. The audit verdict is FAITHFUL. Analysis-only dispatches are a defect.
- Add any new hypothesis that restricts which owner types may be realized (no `hLR` successors).
  Interiority is recovered definitionally via `List.mem_filter`, never hypothesized.
- Cite the Literature `.md` paraphrase of Rabinovich for any load-bearing claim (audit D6). Cite
  PDF page numbers only.

**MUST preserve** (banked green, axiom-clean — see Preserved Assets):
- All rows of the Preserved Assets table below, plus the F1-F7 faithfulness invariants.
- `kvE2_sepCoincidentOrder_mem_arr'` is restated without `hLR` (Phase 5) but must stay
  proof-shape-identical (same conjunct dispatch; the `rcases hLR` step becomes a
  `List.mem_filter` extraction).

**Design decisions are SETTLED** (do not re-open without a machine-checked counterexample):
- Part I filter shape: single two-zone filter following `kvE2_sepPosIn` (SW:199).
- `hLR` is deleted with NO replacement hypothesis.
- Part I lands before Part II; each phase ends green.
- Per-owner slot lists `kvE2_sepSlotsLFor/RFor` (SW:292-311) are UNCHANGED — merging is a
  property of the order type, not the slot inventory.
- `kvE2_sepBracketN` (SW:1009) and banked `kvE2_sepBracketN_construct` (SW:4521) are generic over
  point-type lists and survive unchanged.
- Boundary classes zAtX3/zAtW3/zAtT3 (and zPastX3/zFutT3) ride the EXISTING endpoint/pivot
  literals (SW:886-946) via the biconditional `kvE2_sepLit` (SW:173) — no new literal machinery.
- Anchor-anchor ties excluded as Lean-side `nf_eval_unique` pruning (D7 phrasing).

### Preserved Assets

The following work is complete, banked green and axiom-clean, and must not regress:

| Component | Location | Status | Disposition under this plan |
|-----------|----------|--------|------------------------------|
| `kvE2_sepHonest_engineInputs` | SW:3952 | [COMPLETED] task 337 | untouched; re-verify compiles each phase |
| `kvE2_sepHonest_witnesses` | SW:4141 | [COMPLETED] task 337 | untouched |
| `kvE2_sepBracketN_construct` | SW:4521 | [COMPLETED] task 337 P3.1 | untouched (generic over point-type lists) |
| `kvE2_sepHonestBaseRealizerL/R` | SW:3503/3522 | [COMPLETED] task 337 | untouched |
| `kvE2_sepHonest_hLR_absurd` | SW:4618 | [COMPLETED] task 337 c11 | RETAINED VERBATIM (design guard) |
| `kvE2_sepCoincidentOrder_mem_arr'` | SW:2489 | [COMPLETED] task 337 P1 | restated without `hLR` (Phase 5), proof-shape-identical |
| `IntervalPattern.holds` | Kamp/ExistsForallNF.lean:106-132 | landed | untouched (source-mandated) |
| 5A keystone `nf_eval_unique` usage | SW:2522-2569 | [COMPLETED] task 340 | reused for anchor-distinct conjunct |
| LITMUS | NavigatedSpine.lean:437 | landed | invariant, checked at gate |

## Goals & Non-Goals

**Goals**:
1. Part I: interior-restricted owner index `kvE2_sepPosI`; re-anchor `kvE2_sepAllSlots`,
   `kvE2_sepOrderTypes`, `kvE2_sepModelOrder`, owner-projection + membership lemmas,
   `kvE2_sepCoincidentOrder`, `kvE2_sepHonestOrder`; delete `hLR` from the four theorems;
   restate `kvE2_sepDisjunct_extract` over `kvE2_sepPosI`; endpoint/pivot honesty lemmas.
2. Part II: conjunct-(iii) replacement (anchor-distinct + ordered nonempty tie classes +
   tie-class validity), `kvE2_sepTieGroupedL/R`, meet-folded grouped disjunct builder
   `kvE2_sepDisjunct'`, `kvE2_sepBody`/`kvE2_sepBody_holds_iff` rewire, tie-reporting
   `kvE2_sepHonestOrder'`, target `kvE2_sepBody_complete_holds'` per report 07 §4.
3. Doc-only edit: `OuterGate.lean:28` region prose referencing `kvE2_sepBody_complete`'s
   interiority hypothesis.
4. Every phase ends at a green, committable milestone (`lake build` passes).

**Non-Goals**:
- Re-planning task 337 Phases 3-4 (happens after this task lands, via `/revise 337` or
  `/plan 337` against the corrected interface).
- A grouped-disjunct successor of `kvE2_sepDisjunct_extract` with full per-class witness
  extraction (soundness-side). The landed `kvE2_sepDisjunct_extract` is parametric in flat
  `lL lR` and keeps compiling; this plan restates only its `hmemL`/`hmemR` over `kvE2_sepPosI`
  (Phase 5). Full grouped extraction belongs to the 337 re-plan (it is the engine's territory);
  Phase 7 provides only the small `formula_conjList` per-class evaluation helper.
- Any change to `kvE2_sepPos` itself, `kvE2_sepSlotsLFor/RFor`, `kvE2_sepBracketN`, or
  `IntervalPattern.holds`.
- Wiring into `KampPrior.lean` (recorded follow-on in OuterGate scope notes, out of scope).

## Risks & Mitigations

- **Defeq breakage from re-anchoring `kvE2_sepAllSlots`** (value provably equal, not defeq):
  Phase 1 lands the value-transfer lemma
  `(kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock = (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock`
  BEFORE any re-anchoring, so every broken `rfl`/unfold repairs by one rewrite.
- **Large interconnected file (5,406 lines) → flag-day RED risk**: phases are ordered
  carrier-first, consumers incrementally, with `hLR` kept as a (syntactically unused) hypothesis
  through Phase 4 so the file is green at every phase boundary; Phase 5 is then a pure
  statement-level deletion.
- **Phase 9 (tie-reporting honest order) is the research-grade core** — bounded by a fixed
  declaration list and an explicit split escape (9.1/9.2) using the 2 slack orchestrator cycles;
  if a specific conjunct proof is genuinely blocked after the split, the sanctioned move is a
  documented strategic-sorry skeleton (per wrap-up contract) with a follow-up task — never
  discarding landed structure, never silently weakening a statement.
- **`formula_conjList [f]` vs `f` syntactic mismatch** in the singleton-class compatibility
  path (Phase 7): prove `.holds`/eval-level equivalence, not syntactic equality.
- **Rank-payload semantics flip** (Phase 9): the existing lex rank (`(value, slotIndex)`) is
  injective BY DESIGN (task 340 5A-5C) and must be kept for `kvE2_sepHonestOrder`; the
  tie-reporting order is a NEW `kvE2_sepHonestOrder'` with value-only rank — never mutate the
  banked lex machinery in place.

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
| 8 | 8 | 6 |
| 9 | 9 | 7, 8 |

All phases edit the same file (`SharedWitness.lean`), so execution is sequential (single-file
territory, H7); the wave table records that Phase 8 logically depends only on Phases 5-6 (not 7),
so Phases 7 and 8 may run in either order if a re-dispatch reorders them.

### Phase 1: Add kvE2_sepPosI and its transfer-lemma foundation [COMPLETED]

**Goal**: Land the interior-restricted owner index as a purely additive change with every
transfer lemma later phases need, so re-anchoring phases repair proofs by rewriting.

**Tasks**:
- [x] Define, immediately after `kvE2_sepPosIn` (SW:199), following its in-file precedent:
  ```lean
  noncomputable def kvE2_sepPosI {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
      List (NormalForm sig 1 4) :=
    (kvE2_sepPos qnf).filter
      (fun σ => decide (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3))
  ```
  Docstring cites: Rabinovich §5 (p.7) ψ0/ψ1/φ split — interiority is a construction invariant
  of φ, never a hypothesis on realized types. Do NOT use the `++` form (postmortem rule).
- [x] `kvE2_sepPosI_mem` : `σ ∈ kvE2_sepPosI qnf ↔ σ ∈ kvE2_sepPos qnf ∧ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3)` (via `List.mem_filter`, `decide_eq_true_eq`).
- [x] `kvE2_sepPosI_subset` (mem → mem of `kvE2_sepPos`) and `kvE2_sepPosI_zone` (mem → the
  interiority disjunction) as direct corollaries.
- [x] `kvE2_sepPosI_nodup` : filter preserves the existing `kvE2_sepPos` Nodup fact
  (`lean_local_search` for the existing Nodup lemma; `List.Nodup.filter`) *(deviation: altered —
  a PRIVATE `kvE2_sepPos_nodup` already exists later in the file at SW:2014, unreferencable from
  the Phase 1 block above it; `kvE2_sepPosI_nodup` proves the double-filter chain directly
  `((Finset.nodup_toList _).filter _).filter _` with a docstring pointer)*.
- [x] Block-vanishing helpers: `kvE2_sepSlotsLFor_eq_nil` / `RFor_eq_nil` /
  `kvE2_sepSlotBlock_eq_nil` for non-interior σ (direct from the `else []` branches,
  SW:292-311), and the converse `kvE2_sepMem_posI_of_slot` :
  `σ ∈ kvE2_sepPos qnf → s ∈ kvE2_sepSlotBlock σ → σ ∈ kvE2_sepPosI qnf`
  (a nonempty block forces an interior zone; also state `SlotsLFor`/`SlotsRFor` variants —
  landed as `kvE2_sepMem_posI_of_slotL`/`_slotR`).
- [x] The key value-transfer lemmas (flatMap over a filter equals flatMap over the whole list
  when the function vanishes off the predicate — prove one generic private helper, instantiate):
  - `kvE2_sepPosI_flatMap_slotBlock` : `(kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock = (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock`
  - same for `kvE2_sepSlotsLFor` and `kvE2_sepSlotsRFor` (generic helper:
    `kvE2_sep_flatMap_filter_of_vanish`, private).
- [x] `lake build` green (full project, 1720 jobs; axioms on `kvE2_sepPosI_flatMap_slotBlock`
  = `{propext, Classical.choice, Quot.sound}`).

**Estimated output**: ~150-250 lines, additive only.
**Done when**: build green; `grep -c "kvE2_sepPosI" SharedWitness.lean` > 0; diff contains no
edits to existing declarations; `#print axioms kvE2_sepPosI_flatMap_slotBlock` clean.
**Timing**: 1.5h
**Depends on**: none

### Phase 2: Re-anchor the slot-family layer kvE2_sepAllSlots to kvE2_sepPosI [COMPLETED]

**Goal**: `kvE2_sepAllSlots` (SW:346-348) flatMaps over `kvE2_sepPosI`; all its dependent
Nodup/index/membership lemmas repaired via the Phase 1 transfer lemma.

**Tasks**:
- [x] Edit `kvE2_sepAllSlots` to `(kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock`. Value is
  unchanged (Phase 1 transfer lemma) but NOT defeq — expect broken unfold/rfl proofs.
- [x] Add `kvE2_sepAllSlots_eq_pos` : `kvE2_sepAllSlots qnf = (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock` (one `rw` from Phase 1) as the universal repair tool.
- [x] Repair `kvE2_sepAllSlots_nodup` (SW:472), `kvE2_sepMem_allSlots` (SW:~352; KEEP its
  hypothesis `hσ : σ ∈ kvE2_sepPos` — repair the proof via `kvE2_sepMem_posI_of_slot`, so all
  existing call sites compile unchanged), `kvE2_sepSlotIndexOf` bound/injectivity lemmas,
  `kvE2_sepConsistentBlock_slotIndexOf` (SW:725), and `kvE2_sepZipPayload_flatMap` (SW:~2280 —
  repair its proof with the transfer lemma; its statement over `kvE2_sepPos.zipIdx` is restated
  in Phase 4 when its consumers move). *(deviation: altered — `kvE2_sepMem_allSlots` RELOCATED
  from above the Phase 1 transfer section to just below `kvE2_sepAllSlots_eq_pos`, because its
  repaired proof needs `kvE2_sepMem_posI_of_slot`, declared later in the file; statement
  verbatim-unchanged. `kvE2_sepSlotIndexOf_lt`/`_injOn` needed NO repair — they are
  list-generic over `kvE2_sepAllSlots` and never unfold it.)*
- [x] `kvE2_sepSlotsL/R` (SW:318-325) and `kvE2_sepSegLAt/RAt` (SW:983-994) stay mapping over
  `kvE2_sepPos` (semantically equivalent — non-interior contributions are `[]`/`⊤`; report 07
  sanctions either; the conservative diff is smaller). Record this choice in a comment.
- [x] Full `lake build`.

**Estimated output**: ~100-250 lines of diff (1 def edit + proof repairs).
**Done when**: build green; `#print axioms kvE2_sepAllSlots_nodup` clean; no statement other
than `kvE2_sepAllSlots`'s body changed in this phase.
**Timing**: 1.5-2h
**Depends on**: 1

### Phase 3: Re-anchor the arrangement enumeration and membership lemmas [COMPLETED]

**Goal**: `kvE2_sepOrderTypes`, `kvE2_sepModelOrder`, the owner-projection lemma, and the
order/slot membership lemmas all range over `kvE2_sepPosI`.

**Tasks**:
- [x] `kvE2_sepOrderTypes` (SW:1277): `foldr` over `kvE2_sepPosI qnf` (the `n` bound stays
  `(kvE2_sepAllSlots qnf).length`, already re-anchored). Docstring: the interleaving index
  ranges over bracket witnesses only (§5 p.7); Lemma 3.2(1) states the closure without printed
  proof.
- [x] `kvE2_sepModelOrder` (SW:1296): `zipIdx` over `kvE2_sepPosI qnf`.
- [x] `kvE2_sepOrderTypes_owners` (SW:1563): conclusion becomes
  `wo.map Prod.fst = kvE2_sepPosI qnf` (aux lemma untouched — it is list-generic).
- [x] `kvE2_sepMem_orderOwners` (SW:1571): hypothesis `hσ : σ ∈ kvE2_sepPosI qnf`.
- [x] `kvE2_sepSlotsLOf_mem`/`ROf_mem` (SW:1585/1595): restate `hσ` over `kvE2_sepPosI`. For any
  call site that holds only `σ ∈ kvE2_sepPos`, recover via `kvE2_sepMem_posI_of_slot` (the slot
  hypothesis `hs` forces interiority) — patch call sites rather than keeping duplicate wrappers,
  unless >3 call sites need it, in which case add the derived Pos-facing corollary.
  *(1 call site: `kvE2_sepBody_extract`, patched via `kvE2_sepMem_posI_of_slotL/R`)*
- [x] Repair all consumers of `kvE2_sepOrderTypes_owners` (grep; includes the SW:2239 region and
  the mem_orderTypes instances) using `kvE2_sepPosI_subset` where `σ ∈ kvE2_sepPos` is needed.
  *(deviation: altered — the coincident/honest `mem_orderTypes` instances become FALSE-in-general
  once the enumeration folds over `kvE2_sepPosI` while their `zipIdx` carriers stay over
  `kvE2_sepPos` (the enumeration pins the owner projection). Repaired with an interim
  `hpos : kvE2_sepPosI qnf = kvE2_sepPos qnf` hypothesis on both, discharged at every consumer
  from `hLR` via the NEW lemma `kvE2_sepPosI_eq_pos` (SW:~242). Phase 4 deletes `hpos` when the
  two carriers move to `kvE2_sepPosI`. Additionally: `kvE2_sepOrderOwners_mem_pos` and
  `kvE2_sepSlotsL/ROf_mem_block` were generalized over a generic owner list `L` via
  `howners : wo.map Prod.fst = L` (statement-level), so the hLR-free task-337 value-sorted trio
  keeps its unchanged statements by reading the honest order's owner projection directly off its
  `zipIdx` carrier (`List.zipIdx_map_fst`); `kvE2_sepOrderOwners_nodup` now closes with
  `kvE2_sepPosI_nodup`.)*
- [x] Full `lake build`. *(green, 1720 jobs; axioms on all rebuilt declarations exactly
  `{propext, Classical.choice, Quot.sound}`; `kvE2_sepHonest_hLR_absurd` verbatim-untouched)*

**Estimated output**: ~150-300 lines of diff.
**Done when**: build green; `grep -n "map Prod.fst = kvE2_sepPos qnf" SharedWitness.lean`
returns nothing (only `kvE2_sepPosI` projections remain); axioms clean on the restated lemmas.
**Timing**: 2h
**Depends on**: 2

### Phase 4: Re-anchor kvE2_sepCoincidentOrder and kvE2_sepHonestOrder (rank machinery repair) [COMPLETED]

**Goal**: Both canonical witness orders enumerate over `kvE2_sepPosI`; the task-340 5A-5C rank
machinery and all conjunct proofs repaired so that `hLR` becomes syntactically unused in every
proof body (setting up Phase 5 as a pure statement deletion).

**Tasks**:
- [x] `kvE2_sepCoincidentOrder` (SW:2292) and `kvE2_sepHonestOrder` (SW:3063): `zipIdx` over
  `kvE2_sepPosI qnf`.
- [x] Restate/repair `kvE2_sepZipPayload_flatMap` (SW:~2280) over `kvE2_sepPosI.zipIdx` so the
  conjunct-(iii) Nodup routes still collapse to `kvE2_sepAllSlots.map f` (now definitionally
  aligned, both over `kvE2_sepPosI`).
- [x] Repair `kvE2_sepCoincidentOrder_mem_orderTypes`, `kvE2_sepHonestOrder_mem_orderTypes`
  (aux instances now over `kvE2_sepPosI`; tuple bounds unchanged via `kvE2_ordRank_lt` /
  `kvE2_sepSlotIndexOf_lt`). *(deviation: altered — the interim `hpos` binders Phase 3
  installed were deleted; both lemmas are now UNCONDITIONAL, and `kvE2_sepPosI_eq_pos`
  itself was deleted with zero remaining references)*
- [x] Re-check the 5A-5C rank machinery (SW:2531ff): `kvE2_sepSlotHonestGIdx` and its
  injectivity are over `kvE2_sepAllSlots` — repair defeq-sensitive steps with
  `kvE2_sepAllSlots_eq_pos` where needed. Do NOT change the lex (value, slotIndex) payload —
  it stays the injective strict-order payload (Phase 9 adds the separate tie-reporting order).
  *(deviation: altered — 5A-5C compiled unchanged (statement-level over `kvE2_sepAllSlots`);
  the carrier-sensitive repairs instead landed in the 337 halign layer:
  `kvE2_sepSlotGIdx_honestOrder`'s `find?` resolution now runs over `kvE2_sepPosI.zipIdx`
  (membership via `kvE2_sepMem_posI_of_slot`), and the `valueSorted` pair's inline `hwo`
  owner projection is now `= kvE2_sepPosI` with `kvE2_sepPosI_subset` feeding the mono calls)*
- [x] In the four `hLR` theorems' proof bodies (SW:2445, 2489, 3095, 4249): membership now gives
  `hσmem : σ ∈ kvE2_sepPosI qnf`; replace every `rcases hLR σ hσmem with hzone | hzone` by
  `rcases (kvE2_sepPosI_mem …).mp hσmem |>.2 with hzone | hzone` (or via `kvE2_sepPosI_zone`),
  leaving `hLR` present in the statement but unused in the proof. Where a lemma needs
  `σ ∈ kvE2_sepPos`, use `kvE2_sepPosI_subset`. *(note: `kvE2_sepBody_complete_holds` has no
  `rcases hLR`; it still forwards `hLR` to `kvE2_sepHonestOrder_mem_arr'`, whose binder
  Phase 5 deletes — the only remaining destructuring use of `hLR` in the file is inside
  `kvE2_sepHonest_hLR_absurd`, by design)*
- [x] Full `lake build`; confirm `kvE2_sepHonest_hLR_absurd` (SW:4618) untouched by this diff.

**Estimated output**: ~150-300 lines of diff.
**Done when**: build green; the four theorems compile with `hLR` unused in proof bodies (verify:
temporarily renaming the binder to `_hLR` in a scratch check, or by inspection that no proof step
references it); axioms clean on both `mem_arr'` theorems.
**Timing**: 2-2.5h
**Depends on**: 3

### Phase 5: Delete hLR (statement rewrites), restate kvE2_sepDisjunct_extract, OuterGate doc edit [NOT STARTED]

**Goal**: Part I lands completely — no `hLR` anywhere except the retained design-guard
certificate; extraction hypotheses over `kvE2_sepPosI`; prose corrected.

**Tasks**:
- [ ] Delete the `hLR` hypothesis from `kvE2_sepBody_complete` (SW:2445),
  `kvE2_sepCoincidentOrder_mem_arr'` (SW:2489), `kvE2_sepHonestOrder_mem_arr'` (SW:3095),
  `kvE2_sepBody_complete_holds` (SW:4249); fix the internal call chain
  (`complete_holds` → `HonestOrder_mem_arr'`, `complete` → `CoincidentOrder` route).
  Proof shapes are otherwise identical (Phase 4 already made `hLR` unused).
- [ ] `kvE2_sepDisjunct_extract` (SW:4667): restate `hmemL`/`hmemR` as
  `∀ σ ∈ kvE2_sepPosI qnf, ∀ s ∈ kvE2_sepSlotsLFor σ, s ∈ lL` (resp. `RFor`/`lR`); conclusion is
  already zone-guarded and unchanged. Repair its proof (interior σ membership now definitional)
  and any call sites (supply via the Phase 3 restated `SlotsLOf_mem`/`ROf_mem`).
- [ ] Rewrite the now-stale docstrings (SW:2428-2444 banner, 2484, 3090, 4245): interiority is
  recovered definitionally via `List.mem_filter` on `kvE2_sepPosI`; boundary/self-zone classes
  ride the endpoint/pivot literals (§5 + Prop 3.5, pp.5,7). Use the D1-sanctioned citation
  phrasing throughout.
- [ ] Doc-only edit in `OuterGate.lean` (~line 28, the "Scope decisions" R-A bullet): replace the
  `hL`-hypothesis description with the interior-restricted carrier description (task 342: owner
  index `kvE2_sepPosI`; no interiority hypothesis; `kvE2_sepHonest_hLR_absurd` documents why).
- [ ] Verify `kvE2_sepHonest_hLR_absurd` compiles VERBATIM: `git diff` must show zero changes in
  SW:4595-4665 (its banner may reference the corrected statements — if its banner prose must
  change, change ONLY prose above the theorem, never the theorem or its docstring's certified
  claims; prefer zero changes).
- [ ] Full `lake build`; `#print axioms` (via `lean_verify`) on all four rebuilt theorems.

**Estimated output**: ~100-200 lines of diff (mostly deletions + prose).
**Done when**: build green; `grep -n "hLR" SharedWitness.lean` shows hits ONLY in the
`kvE2_sepHonest_hLR_absurd` region and historical comments; axioms on the four =
`{propext, Classical.choice, Quot.sound}`; OuterGate.lean builds.
**Timing**: 1.5-2h
**Depends on**: 4

### Phase 6: Tie-admitting validity — conjunct (iii) replacement and tie-class grouping [NOT STARTED]

**Goal**: Replace the global-`Nodup` conjunct with anchor-distinct + tie-class wellformedness +
tie-class validity reads; add the grouping functions. Existing (all-distinct payload) witness
orders re-verify under the new predicate.

**Tasks**:
- [ ] `kvE2_sepClosedLeafAt (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool` — the
  foreign-type generalization of `kvE2_sepClosedLeafStub` (SW:1316-1321): left-interior owners
  read `kvE2_sepBits σ kvE2_sep_zAtX1L χ`, all others `kvE2_sepBits σ kvE2_sep_zAtX1R χ`.
  Lemma: `kvE2_sepClosedLeafStub σ = kvE2_sepClosedLeafAt σ (nf0_projFresh σ.1)`. Docstring:
  F5 — this is a CLOSED self-zone key read at the foreign base type; no OPEN key enters any
  coincident read.
- [ ] Anchor-payload projection: a helper extracting each owner's ANCHOR-slot payload index from
  `(σ, tag, t)` (the anchor slot is `.lX1 σ` resp. `.rX1 σ` at the structurally known position
  `(kvE2_sepS σ kvE_sub2_zXU).length` resp. `(kvE2_sepS σ kvE2_sep_zWX1).length` in
  `kvE2_sepSlotBlock σ` — reuse/`lean_local_search` any existing block-position lemma from 340).
- [ ] Replace `kvE2_sepDisjValid` conjunct (iii) `decide (wo.flatMap (fun p => p.2.2)).Nodup`
  (SW:1350-1354) with:
  - (iii') **anchor-distinct**: the cross-owner ANCHOR payload indices are `Nodup` — docstring
    carries the D7 note (Lean-side `nf_eval_unique`-certified pruning, no paper counterpart);
  - (iv) **tie-class validity**: for every duplicated payload value (tie class, computed from
    the full payload multiset), the class contains at most one anchor slot (free given (iii')),
    and if it contains anchor slot of owner `σa` together with base slots of types
    `χ₁, …, χₖ` (foreign or own), then `kvE2_sepClosedLeafAt σa χᵢ = true` for each `i`;
    base-base classes impose no read (F5-clean by construction).
  Keep conjuncts (i)/(ii) verbatim. Keep everything `Bool`/`decide`-able.
- [ ] `kvE2_sepTieGroupedL/R (wo) : List (List (KvE2SepSlot sig))` — group
  `kvE2_sepSlotsLOf/ROf wo` into maximal runs of equal wo-payload index (the merge key). Use
  `List.splitBy` (or the file's house pattern) on the sorted list. Lemmas:
  `(kvE2_sepTieGroupedL wo).flatten = kvE2_sepSlotsLOf wo`; every class `≠ []`; if the full
  payload is `Nodup` then every class is a singleton (`kvE2_sepTieGroupedL wo = (kvE2_sepSlotsLOf wo).map ([·])`).
- [ ] Repair the conjunct-(iii) branches of `kvE2_sepBody_complete`,
  `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepHonestOrder_mem_arr'`: current payloads are
  globally `Nodup` (banked facts), which implies (iii') (sublist of Nodup) and makes (iv)
  vacuous (all classes singletons). Package this implication once as
  `kvE2_sepDisjValid_tie_of_nodup`-style lemma and reuse in all three.
- [ ] Full `lake build`.

**Estimated output**: ~250-400 lines.
**Done when**: build green; the three completeness theorems re-verify axiom-clean; grouping
round-trip lemma (`flatten` = sorted list) proved; no OPEN-key read added anywhere
(grep the new code for `kvE_sub2_` keys — none may appear in the tie-class read path).
**Timing**: 2-2.5h
**Depends on**: 5

### Phase 7: Meet-folded grouped disjunct builder and kvE2_sepBody rewire [NOT STARTED]

**Goal**: One bracket slot per tie class; `kvE2_sepBody` emits grouped disjuncts;
`kvE2_sepBody_holds_iff` and `kvE2_sepBody_complete_holds` restated over the grouped builder.

**Tasks**:
- [ ] Grouped segment dispatcher: cut `i` of a grouped list `gL` reuses the EXISTING per-cut
  refined conjunctions (SW:983-997) evaluated at the flat prefix — i.e. segment at grouped cut
  `i` = `kvE2_sepSegLAt charBase qnf gL.flatten ((gL.take i).flatten).length` (segments between
  two members of one tie class disappear with the slot; segments already meet-fold across all
  owners per cut, so tie folding is point-type grouping + cut reindexing ONLY — no new β
  machinery). Mirror for the right region; wrap as `kvE2_sepSegsG`.
- [ ] `kvE2_sepDisjunct'` (TOP-LEVEL def, crux failed-closer-3 lesson: no let-buried builders),
  consuming `gL gR : List (List (KvE2SepSlot sig))`:
  point types `gL.map (fun c => ⟨formula_conjList (c.map (kvE2_sepSlotType charBase charK))⟩)`,
  shared `ptW`, right mirror, `kvE2_sepBracketN` reused as-is, segments `kvE2_sepSegsG`.
  Docstring: strict-quotient guard (one slot per tie class; emitted disjunct is a strict Def-3.1
  bracket; forced by Def 3.1 (p.4), corroborated k=m (p.7) + Def 7.5 (p.13); Lemma 3.2(1) states
  the closure without printed proof).
- [ ] Singleton-compatibility lemma at `.holds` level (NOT syntactic): if every class of
  `gL`/`gR` is a singleton with `gL.flatten = lL`, `gR.flatten = lR`, then
  `(kvE2_sepDisjunct' … gL gR).2.holds M atomMap x t ↔ (kvE2_sepDisjunct … lL lR).2.holds M atomMap x t`
  (pointwise: `formula_conjList [f]` eval-equals `f`; segments align by cut arithmetic).
- [ ] Small per-class evaluation helper (the only extraction-side deliverable this task owes):
  a realized class point of type `formula_conjList (c.map …)` realizes each member's type
  (`formula_conjList` eval ⟹ each conjunct) — consumed by the 337 re-plan.
- [ ] Rewire `kvE2_sepBody` (SW:1645): `(kvE2_sepArr' qnf).map fun wo => kvE2_sepDisjunct' charBase charK qnf (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)`.
- [ ] Restate `kvE2_sepBody_holds_iff` (SW:1682) over the grouped builder (same
  `dif_pos`/`holds_flatMap_map` route).
- [ ] Restate `kvE2_sepBody_complete_holds`: `hdisj` becomes the grouped disjunct of the (strict,
  Phase 4) `kvE2_sepHonestOrder` — its payload is Nodup, so `kvE2_sepTieGroupedL/R` are
  singletons and the proof wires through `holds_iff'` + `HonestOrder_mem_arr'` exactly as before.
- [ ] `kvE2_sepDisjunct_extract` and `kvE2_sepBracketN_construct` are parametric in flat lists —
  confirm untouched and still green.
- [ ] Full `lake build`.

**Estimated output**: ~250-400 lines.
**Done when**: build green; `kvE2_sepBody_complete_holds` axiom-clean over the grouped builder;
singleton-compat lemma proved; `IntervalPattern.holds` untouched (git diff on
Kamp/ExistsForallNF.lean is empty); LITMUS grep (`grep -n "x1 <" ` on new code) clean.
**Timing**: 2-2.5h
**Depends on**: 6

### Phase 8: Honest non-interior evaluation pack — foreign-base tie discharges and endpoint/pivot honesty lemmas [NOT STARTED]

**Goal**: The two additive lemma packs that discharge honest-model obligations previously hidden
behind vacuity: (a) F5 foreign-base CLOSED-key discharges for base-anchor tie classes;
(b) endpoint/pivot honesty lemmas for the boundary-class literals.

**Tasks**:
- [ ] (a) Generalize the landed coincidence discharges `kvE2_sepCoincidentAnchor_discharge`
  (SW:2188) and `_R` (SW:2361) from the owner's own fresh type to an arbitrary FOREIGN base type:
  under honest `h`, if base type `χ` is honestly realized AT owner σa's anchor point (the
  tie-class situation: equal honest values), then `kvE2_sepBits σa kvE2_sep_zAtX1L χ = true`
  (left-interior σa; `zAtX1R` mirror). Hence `kvE2_sepClosedLeafAt σa χ = true`. **F5 obligation:
  the discharge reads the anchor owner's CLOSED key at the foreign type — no OPEN key enters any
  coincident read.** Follow the existing discharges' proof route (same key family).
- [ ] (b) Endpoint/pivot honesty lemmas: under honest `h` (and the same char-semantics
  hypotheses the file's existing eval lemmas use — `lean_local_search` for the house `hchar`
  convention, e.g. in `kvE2_sepHonestBasePairsL_eval` / the coincidence discharges — reuse it
  verbatim, do not invent a new hypothesis shape):
  - `kvE2_sepEpL_eval_of_honest` : `(kvE2_sepEpL charBase charK qnf).eval_at M atomMap x`
  - `kvE2_sepPtW_eval_of_honest` : pivot literal at `w`
  - `kvE2_sepEpR_eval_of_honest` : at `t`
  Route: each literal is a `kvE2_sepLit (kvE2_sepHasPos …) (…)` biconditional conjunction
  (SW:886-946, 173); positive bits are honest `kvE2_sepHasPos` values, so the positive side is
  discharged by exhibiting the honest realization at the endpoint/pivot (the always-realized
  characteristics land here — this is exactly the σ_w route of `kvE2_sepHonest_hLR_absurd`, now
  as an obligation instead of a contradiction); negative bits discharge by the absence of a
  positive owner with that projection. Cite: §5 + Prop 3.5 (pp.5,7) atomic-E[Σ] routing.
- [ ] Full `lake build`.

**Estimated output**: ~250-450 lines.
**Done when**: build green; all five named lemmas exist sorry-free and axiom-clean.
**Contingency (bounded-unit escape)**: (a) and (b) are independent units. If (b)'s literal
evaluation needs infrastructure exceeding this run, land (a) green + commit, then split (b) to a
Phase 8.1 dispatch (slack cycle). Only if (b) is blocked after its own dedicated run may it
become a documented strategic-sorry skeleton with a follow-up task — statements landed, sorries
inventoried per wrap-up contract, never silently dropped.
**Timing**: 2-2.5h
**Depends on**: 6 (uses `kvE2_sepClosedLeafAt`; independent of Phase 7)

### Phase 9: Tie-reporting honest order and kvE2_sepBody_complete_holds' [NOT STARTED]

**Goal**: The completeness keystone: an honest order whose payload reports EQUAL indices exactly
where honest values coincide, its carrier membership under the tie-admitting validity, and the
report 07 §4 target theorem.

**Tasks**:
- [ ] `kvE2_sepSlotHonestVIdx` — value-only rank: `kvE2_ordRank` over the honest slot-VALUE
  family (drop the slot-index lex tiebreak of `kvE2_sepSlotHonestGIdx`; `kvE2_ordRank` at
  SW:1219 needs no injectivity). Payload lemmas: equal honest values ⟹ equal rank (definitional
  for a rank counting strictly-smaller values); strictly smaller value ⟹ strictly smaller rank
  (`kvE2_ordRank_strictMono`); rank bound (`kvE2_ordRank_lt`). Do NOT modify the banked lex
  machinery — this is a new parallel definition.
- [ ] `kvE2_sepHonestOrder'` : `zipIdx` over `kvE2_sepPosI`, all-`.coincident` tags, payload
  `block.map kvE2_sepSlotHonestVIdx`. Membership in `kvE2_sepOrderTypes` via the aux instance
  (entries `< n` from the rank bound).
- [ ] `kvE2_sepHonestOrder'_mem_arr'` — the four validity conjuncts:
  - (i) all-`.coincident` owner validity: reuse `kvE2_sepCoincidentOwner_valid_left/right`
    verbatim (tuple-agnostic).
  - (ii) per-owner consistency: the owner's own slot values are STRICTLY increasing (own base
    witnesses lie strictly inside their region, strictly separated from the own anchor — reuse
    the banked region-strictness facts feeding `kvE2_sepHonest_engineInputs`, e.g. the
    `kvE2_sepHonestBasePairsL/R_eval` bounds), so value-only ranks are strictly increasing
    (`kvE2_ordRank_strictMono`). Own-slot ties cannot occur — record why in the docstring.
  - (iii') anchor-distinct: cross-owner anchor VALUES are injective by the 5A keystone route
    (`nf_eval_unique`, SW:2555-2569 pattern), hence distinct ranks (`kvE2_ordRank` injective on
    distinct values via strictMono both ways).
  - (iv) tie-class validity: members of a tie class share an honest value; a base-anchor class
    realizes the base type AT the anchor's honest point, so the Phase 8 (a) foreign-base
    discharge gives `kvE2_sepClosedLeafAt σa χ = true`; base-base classes impose no read.
- [ ] `kvE2_sepBody_complete_holds'` (report 07 §4 shape, verbatim target):
  no `hLR`; owners from `kvE2_sepPosI`; `hdisj` over
  `kvE2_sepDisjunct' … (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' …)) (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' …))`;
  wires `HonestOrder'_mem_arr'` into `kvE2_sepBody_holds_iff`'s `.mpr`. Keep the Phase 7
  `kvE2_sepBody_complete_holds` (strict-order instance) alongside as a corollary/variant.
- [ ] **Exit verification gate** (all four, recorded in the summary):
  1. `lake build` green.
  2. `lean_verify` / `#print axioms` on `kvE2_sepBody_complete`,
     `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepHonestOrder_mem_arr'`,
     `kvE2_sepHonestOrder'_mem_arr'`, `kvE2_sepBody_complete_holds`,
     `kvE2_sepBody_complete_holds'` — exactly `{propext, Classical.choice, Quot.sound}`.
  3. `kvE2_sepHonest_hLR_absurd` compiles unchanged (git diff over its region empty since
     Phase 5).
  4. `grep -n "sorry" SharedWitness.lean OuterGate.lean` — none in landed declarations.

**Estimated output**: ~300-500 lines.
**Done when**: all four gate checks pass.
**Split escape (bounded-unit)**: if conjuncts (ii)/(iv) exceed one run, split into
Phase 9.1 (defs + payload lemmas + orderTypes membership, green + committed) and
Phase 9.2 (`mem_arr'` + `complete_holds'` + gate) using the remaining slack cycle. If a single
conjunct is still genuinely blocked after 9.2's dedicated run, the sanctioned move is a
documented strategic-sorry skeleton (statement landed, sorry inventoried with assumption +
follow-up task per the wrap-up contract) — never discarding the landed structure, never
reintroducing a restriction hypothesis.
**Timing**: 2.5h
**Depends on**: 7, 8

## Testing & Validation

- Per-phase: `lake build` (or `lean_diagnostic_messages` on `SharedWitness.lean` +
  `OuterGate.lean`) must be green before the phase commit — every phase is a committable
  milestone.
- Axiom hygiene: `lean_verify` on every restated/new theorem at its landing phase; final gate in
  Phase 9 re-checks the full completeness chain =
  `{propext, Classical.choice, Quot.sound}` only.
- Design-guard regression: `kvE2_sepHonest_hLR_absurd` (SW:4618) verbatim at Phases 4, 5, 9
  (git diff over its region).
- LITMUS regression: no `x1 < e_i`-style relative-position literal in any new code; witness
  bounds only from `IntervalPattern.holds`'s own range; `git diff` on
  `Kamp/ExistsForallNF.lean` and `NavigatedSpine.lean` empty at every phase.
- F5 regression: tie-class read path uses only `kvE2_sep_zAtX1L`/`zAtX1R` CLOSED keys; strict
  placements keep OPEN keys (`kvE2_sepDisjValidOwner` conjunct (i) unchanged).
- `hLR` sweep after Phase 5: `grep -n "hLR" SharedWitness.lean` hits only the certificate region
  and historical comments.
- No `sorry` in landed declarations at any phase commit (strategic-sorry skeleton only via the
  documented escapes in Phases 8/9, with inventory + follow-up task).

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (all nine phases)
- Modified (doc-only): `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean`
  (Phase 5)
- New declarations (expected inventory): `kvE2_sepPosI` (+ ~8 transfer lemmas),
  `kvE2_sepAllSlots_eq_pos`, `kvE2_sepClosedLeafAt` (+ stub-compat lemma),
  `kvE2_sepTieGroupedL/R` (+ round-trip/singleton lemmas), corrected `kvE2_sepDisjValid`
  conjuncts (iii')/(iv), `kvE2_sepDisjunct'`, `kvE2_sepSegsG`, singleton `.holds`-compat lemma,
  per-class `formula_conjList` evaluation helper, foreign-base discharges (L/R),
  `kvE2_sepEpL/PtW/EpR_eval_of_honest`, `kvE2_sepSlotHonestVIdx` (+ payload lemmas),
  `kvE2_sepHonestOrder'` (+ membership), `kvE2_sepHonestOrder'_mem_arr'`,
  `kvE2_sepBody_complete_holds'`
- Summary: `specs/342_.../summaries/01_interior-index-and-tie-admitting-orders-summary.md`
  (at completion, per implementer contract)
- After completion: task 337 stays [BLOCKED] until this lands; then re-plan 337 Phases 3-4
  (`/revise 337` or `/plan 337`) against the corrected interface — the engine's single delegated
  `.holds` obligation becomes the tie-grouped `hdisj`, with boundary-class content discharged
  from `h` at the endpoint/pivot conjuncts (Phase 8 (b) lemmas).

## Rollback/Contingency

- Every phase ends green and is committed (`task 342 phase P: {name}`), so rollback is always
  "reset to the previous phase commit" — never a partial-file recovery. Use
  `bash .claude/scripts/git-snapshot.sh` before any intentional rollback.
- If Phase 2-4 re-anchoring blast proves much larger than estimated: do NOT fall back to the
  rejected non-interior-true-branch alternative (user decision). Instead split the failing phase
  into `.1`/`.2` sub-phases at a green boundary (the transfer-lemma design makes any prefix of
  repaired lemmas a committable state) and consume a slack cycle.
- If total work threatens to exceed the 11 available cycles: Phases 1-7 are the non-negotiable
  core (both defects fixed, completeness chain green over the strict honest order); Phase 8 (b)
  and the Phase 9 tie-reporting order are the sanctioned follow-up-task candidates, split per
  their documented escapes — propose the follow-up in the handoff rather than rushing a RED
  landing.
