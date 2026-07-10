# Research Report: Post-334 Ground Truth and the Remaining Soundness-Extraction Frontier (task 333)

- **Task**: 333 - carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair
- **Report**: reports/02_post334-soundness-extraction-frontier.md
- **Type**: lean4
- **Date**: 2026-07-10
- **Session**: sess_1783656333_b01222
- **Status**: researched
- **HEAD**: `235d181ef` (import-path source files git-clean; `lake build …OuterGate` exit 0, 1014 jobs, warnings only)
- **Supersedes**: reports/01_bit-compatibility-carrier-redefinition.md (written against pre-334 HEAD `443684ae6`; now stale)
- **Standards**: .claude/rules/artifact-formats.md, .claude/context/formats/report-format.md

## Executive Summary

Task 333's own artifacts (plan `01_*`, report `01_*`, the `handoffs/*`) are **stale**. Dependency
task 334 (completed) plus the sibling cluster 337/340/342 (all completed) have already executed the
bulk of 333's five deliverables, and the carrier redefinition that 333 was chartered to perform
(`kvE2_sepArrL/R` → bit-compatibility filtering) **is already done** — it is task 334's
`kvE2_sepArr'` with per-order-type validity `kvE2_sepDisjValidOwner`. The remaining open work is
**not** a carrier redefinition; it is a **soundness-extraction threading** problem, and the
deliverable-4 gate now physically lives in `OuterGate.lean` (task 335, PARTIAL), not in
`SharedWitness.lean`.

Concretely, the surviving open obligation is the **⇒ (soundness) half** of the k=2 gate
`BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 …)`: `.holds ⟹ ∃ w, nf_eval_nf M 2 3
[w,x,t] qnf`. The channel the pre-334 O4 CRUX RECORD declared *missing* (a cross-σ bit channel)
now **exists** as `kvE2_sepArr'_sound` (`SharedWitness.lean:6946`), but the extraction chain
(`kvE2_sepDisjunct_extract` / `kvE2_sepBody_extract`) does not yet thread those per-owner validity
bits into the `hgate` forward-zone conjunct.

**Recommendation headline**: the 333 plan (`plans/01`) must be **revised (`/revise`)**, not resumed
— its Phases 1-5 are already landed/deleted by 334/342 and its Phases 6-8 have moved file and
changed shape. There is also a live **ownership overlap with task 335** that needs an orchestrator
decision before dispatch.

---

## A. Ground-Truth Inventory

### A.1 Live sorry count on the import path

- **`SharedWitness.lean` (9276 lines): 0 live sorries.** All 3 `sorry` token hits (lines 2841,
  2910, 5092, 6651, 6834, 6915 by grep) are inside docstrings / `/-! -/` records / prose. Verified
  by word-boundary grep excluding comment lines.
- **Entire `NfMultiAnchorBridge/` import path: 0 live sorries.** Every `sorry` occurrence in
  `Base.lean`, `CarrierK1V.lean`, `NavigatedSpine.lean`, `OuterGate.lean`, `SubBracket.lean`, etc.
  is prose ("no `sorry` on any live path", "strategic sorry DISCHARGED", baseline notes).
- **The only live sorries in the wider Kamp tree are `KampPrior.lean:351/354`** (the documented
  "live Kamp sorry baseline (2)", `CarrierK1V.lean:2092`, `Base.lean:735`). These are **explicitly
  out of task 333 scope** (plan `01` Non-Goals, line 152).
- Build confirmation: `lake build Bimodal.…NfMultiAnchorBridge.OuterGate` → **exit 0, 1014 jobs**,
  warnings only (unused-variable linter on `OuterGate.lean:148/149`). OuterGate imports
  SharedWitness, so the whole redefined carrier path is green at HEAD.

### A.2 Current public API of the carrier (post-334, verified at cited lines)

| Symbol | Loc | Role | Status |
|--------|-----|------|--------|
| `kvE2_sepArr'` | SW:1776 | THE faithful carrier — valid weak orders of merged anchor set (Lemma 3.2(1)) | live |
| `kvE2_sepDisjValid` / `kvE2_sepDisjValidOwner` | SW:1767 / :1733 | per-order-type validity (the bit-compatibility filter — reads OPEN `zXU/zUW` for strict, CLOSED `zAtX1L/R` for coincidence) | live |
| `kvE2_sepBody` | SW:2328 | carrier body; `.disjuncts = (kvE2_sepArr' qnf).map (kvE2_sepDisjunct' … tieGroupedL/R)` on gate-true branch | live |
| `kvE2_sepCoincidentOrder` | SW:2984 | honest coincidence (tie) arrangement — the honestly-valid disjunct | live |
| `kvE2_sepBody_complete` | SW:3236 | ⇐ **UNCONDITIONAL** `kvE2_sepArr' qnf ≠ []` (both LEFT+RIGHT interior via `kvE2_sepPosI_zone`) | **landed, axiom-clean** |
| `kvE2_sepBody_complete_holds` | SW:5705 | ⇐ at `.holds` level from a realized honest disjunct | landed |
| `kvE2_sepBody_holds_of_honest` | SW:9262 | ⇐ **engine**: honest eval ⟹ `kvE2_sepBody.holds` (consumed by OuterGate) | landed |
| `kvE2_sepArr'_sound` | SW:6946 | ⇒ **per-owner** bit extraction: held disjunct ⟹ `∀ p ∈ wo, kvE2_sepDisjValidOwner p.1 p.2.1 = true` ∧ anchorDistinct ∧ tieRead | **landed, the missing O4 channel** |
| `kvE2_sepDisjunct_extract` | SW:6195 | ⇒ bracket `.holds` ⟹ endpoint/pivot literals + per-zone bundles (takes slot-membership + pairwise as hyps) | landed |
| `kvE2_sepBody_extract` | SW:6356 | ⇒ carrier `.holds` ⟹ same, wrapping the disjunct extractor (takes `hpairL/hpairR/hnd` as hyps) | landed |
| `kvE2_sepHonest_hLR_absurd` | SW:5738 | task-337 finding: interiority hypothesis `hLR` is inconsistent with every honest eval | landed |
| non-interior evaluation pack | SW:6956+ | task-342: routes non-interior positives to E[Σ] endpoint/pivot literals | landed |
| `kvE2_sepBody_nonvacuous` | SW:2915 | ⇐ non-vacuity **conditioned on `hvalid` about the STRICT `kvE2_sepModelOrder`** | **DEAD (see §B)** |
| `kvE2_sepModelOrder` | SW:1476 | the STRICT model order | dead-ish (15 refs, all inside SW; superseded) |

**Deleted by 334 (grep-0, confirmed):** `kvE2_sepArrL`, `kvE2_sepArrR`, `kvE2_sepValid`,
`kvE2_sepSlotsL_valid`/`_valid`, and the entire `kvE2_sepSingleton*` / `kvE2_sepBody_singleton*`
retreat block **including the two strategic sorries** that 333's plan Phases 4-5 targeted
(`kvE2_sepSingleton_coverage_left`, `kvE2_sepBody_singleton_complete_left`). The plan's sorry line
numbers (`:1820`, `:1952`) no longer exist.

### A.3 Which of 333's five deliverables remain open

| # | Deliverable | Post-334 status |
|---|-------------|-----------------|
| 1 | Redefine `kvE2_sepArrL/R` with bit-compat filtering + restore non-vacuity | **DONE by 334** (`kvE2_sepArr'` + `kvE2_sepDisjValidOwner`; non-vacuity = unconditional `kvE2_sepBody_complete`) |
| 2 | Discharge the two strategic sorries | **VOID by 334** (the whole singleton retreat block deleted; sorries removed, not discharged) |
| 3 | Lift to full multi-positive-sub correctness pair | **⇐ (completeness) LANDED; ⇒ (soundness) OPEN** — see §C |
| 4 | Phase 12 N2-C (`BracketCarrierCorrectVPrior`) + Phase 13 (F4 ℤ discriminator) | **⇐ half LANDED in OuterGate (335); ⇒ half BLOCKED; F4 construction-level LANDED, semantic ℤ spawned** — see §D |
| 5 | Full `lake build` green + axiom-clean surviving public API | **Green now** (0 live sorries on path); "surviving public API" is smaller than 333 planned because the singleton API was deleted |

**Net: only deliverable 3 (⇒ soundness) and deliverable 4 (the k=2 ⇒ gate + F4 semantic ℤ) remain
genuinely open, and both now sit at the SharedWitness↔OuterGate seam, not inside the carrier
structure.**

---

## B. The `hvalid` Residue — soundness-relevant, resolved

`kvE2_sepBody_nonvacuous` (SW:2915) concludes `(kvE2_sepBody …).disjuncts ≠ []` **but carries the
hypothesis** `hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) = true` about the **STRICT**
model order.

**Finding (grounded, SW:2937-2948 + SW:6663-6668):** task 334 established — with a `lean_goal`-level
argument, now recorded in the file — that at self-coincidence σ's OPEN `zXU/zUW` bits (which
`kvE2_sepDisjValidOwner .strictBefore/.strictAfter` read at σ's own fresh type) are **FALSE**, while
the CLOSED `zAtX1L` bit is TRUE. Hence `hvalid` **is not honestly attainable** for the honest
realization: the strict order `kvE2_sepModelOrder` is not the honestly-valid disjunct — the
COINCIDENCE order `kvE2_sepCoincidentOrder` is. So `kvE2_sepBody_nonvacuous` is a **conditional whose
antecedent the honest model cannot supply** — it is not literally `False`, but it is inert as a
non-vacuity witness.

**It is fully superseded.** `kvE2_sepBody_complete` (SW:3236) proves `kvE2_sepArr' qnf ≠ []`
**unconditionally** via `kvE2_sepCoincidentOrder`, and since
`kvE2_sepBody.disjuncts = (kvE2_sepArr' qnf).map …` (SW:2351), `kvE2_sepArr' ≠ [] ⟹ .disjuncts ≠ []`
by `List.map_ne_nil`. So an unconditional `.disjuncts ≠ []` follows directly from
`kvE2_sepBody_complete` with no `hvalid`.

**Reference check:** `kvE2_sepBody_nonvacuous` has **zero live code consumers** — all three
non-definition mentions (SW:910, :6668, :6703) are inside docstrings / the O4 crux record.
`kvE2_sepModelOrder` is referenced 15× but **only inside `SharedWitness.lean`** and is not consumed
by any downstream file (OuterGate/NavigatedSpine/Prior all grep-0).

**Recommendation (B):** option **(ii) — delete `kvE2_sepBody_nonvacuous`** in favor of
`kvE2_sepBody_complete`, as a small cleanup phase. If a `.disjuncts ≠ []` corollary is wanted for
API symmetry, restate it unconditionally as a one-line consequence of `kvE2_sepBody_complete` +
`List.map_ne_nil` (this is option (i) collapsed to a trivial derivation). The strict-order support
cluster (`kvE2_sepModelOrder` and its `_mem_orderTypes` lemma at SW:1871) can then be swept for
deletion too, but that is **LOW-risk cleanup, not make-or-break** — gate it behind a reference sweep
so no live proof (e.g. `kvE2_sepArr'_mem_modelOrder` at SW:1888) regresses.

---

## C. Deliverable 3 — the multi-positive correctness pair

### C.1 What "the correctness pair" means at the carrier level

The pair is the two directions of the carrier `.holds` biconditional against a depth-2 realization:

- **⇐ completeness**: `(∃ w, nf_eval_nf M 2 3 [w,x,t] qnf) ⟹ (kvE2_sepBody …).holds M atomMap x t`.
  **LANDED.** Chain: `kvE2_sepBody_complete` (SW:3236, carrier non-empty) →
  `kvE2_sepBody_complete_holds` (SW:5705) / the honest-order membership
  `kvE2_sepHonestOrder'_mem_arr'` (SW:6120) → the engine `kvE2_sepBody_holds_of_honest` (SW:9262).
  This is exactly what `OuterGate.bracketEndChar_kvE2_complete_two_prior` (OuterGate:139) consumes,
  and it is green + axiom-clean (334 Phase-8 + 335 Phase-2 summaries; corroborated by the exit-0
  build).

- **⇒ soundness**: `(kvE2_sepBody …).holds M atomMap x t ⟹ ∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`.
  **OPEN.** This is the genuine remaining proof obligation.

### C.2 What the post-334 extraction chain supplies (and its residue)

`kvE2_sepBody_extract` (SW:6356) already reduces the carrier `.holds` to: `kvE2_sepEpL/EpR` endpoint
literals, a pivot `w` with `x<w<t` and `kvE2_sepPtW`, and per-zone bundles
`kvE2_sepBundleL/R` for the interior positives — **but takes three hypotheses**:

```
hpairL/hpairR : ∀ wo ∈ kvE2_sepArr' qnf, (kvE2_sepSlotsL/ROf wo).Pairwise (kvE2_sepSlotLe · · = true)
hnd           : ∀ wo ∈ kvE2_sepArr' qnf, ((kvE2_sepSlotsL/ROf wo).map (kvE2_sepSlotGIdx wo)).Nodup
```

`kvE2_sepArr'_sound` (SW:6946) supplies the **new cross-σ bit channel** the pre-334 O4 crux said did
not exist: from `wo ∈ kvE2_sepArr' qnf` it yields `∀ p ∈ wo, kvE2_sepDisjValidOwner p.1 p.2.1 =
true` plus `anchorDistinct` and `tieRead`.

**The residue (concrete, `OuterGate.lean:172-201` + O4 record SW:6566-6659):**
1. `kvE2_sepBody_extract`'s `hpairL/hpairR/hnd` side-conditions are **un-discharged for the soundness
   path** — the note states "the landed `Pairwise`/`Nodup` lemmas are stated for the wrong
   relation/order or are completeness-only". A soundness-oriented `Pairwise`/`Nodup` lemma over
   `kvE2_sepSlotsL/ROf wo` for arbitrary `wo ∈ kvE2_sepArr' qnf` (not just the honest order) is
   needed. **This is the first concrete sub-obligation.**
2. After extraction, the six-conjunct per-σ `hgate` (`SubBracket2V.lean:1868-1882`, do-not-edit) must
   be assembled at each extracted anchor. The pre-334 O4 crux (SW:6588) showed the **forward-zone
   conjunct** `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` at a cross-σ slot point was
   underdetermined. **The fix is now available**: `kvE2_sepArr'_sound` proves the disjunct's
   `kvE2_sepDisjValidOwner` bits hold, and the arrangement that realized the `.holds` is a *specific*
   `wo ∈ kvE2_sepArr'`, so its per-owner bits are the cross-σ compatibility facts the conjunct needs.
   **This is the second (make-or-break) sub-obligation**: prove `kvE2_sepDisjValidOwner σ tag ⟹` the
   `SubBracket2V` forward-zone conjunct at the arrangement-selected placement.
3. There is **no depth-2 quant-layer fold** landed (`OuterGate.lean:177`): the only fold engine
   `nf_quant_layer_fold_iff` (`NfEFold.lean:391`) folds depth-0 inner subs; the k=2 quant layer
   ranges over depth-1 subs `σ : NormalForm sig 1 4`. So reassembling `∃ w, nf_eval_nf M 2 3` from
   the per-σ bundles + `ExistProviders.correct` is the **third** sub-obligation (the "outer fold"
   `NavigatedSpine.lean:445` sketches as `kvE2_outer_fold`).

### C.3 Concrete lemma names / Mathlib needs

- Consumed (do-not-edit): `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1025`),
  `kvE_subBracket2V_sound_of_outer` (`:1216`), `kvE_sub2V_bounded_anchor_of_outer` (`:1182`), the
  per-σ kit `kvE_subBracket2V_correctness_pair` (`:1868-1882`).
- New (to prove, all in `SharedWitness.lean`, task-333 owned): the soundness `Pairwise`/`Nodup`
  side-condition lemmas for arbitrary `wo ∈ kvE2_sepArr'`; the
  `kvE2_sepDisjValidOwner ⟹ forward-zone conjunct` bridge; the outer depth-2 fold.
- Mathlib: nothing exotic — `List.Pairwise`/`List.Nodup`/`List.map_ne_nil` families,
  `List.mem_filter`, `List.mem_map` (all already used in-file). No new Mathlib search needed; this is
  a bespoke-transcription task, not a Mathlib-gap task (leansearch/loogle not required).

---

## D. Deliverable 4 — Phase 12 / N2-C and Phase 13

### D.1 `BracketCarrierCorrectVPrior` — what it is and where the k=2 discharge lives

`BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) is a **`Prop` predicate, not a `sorry`**. It
is already proved for `k=0` (`:80`) and `k=1` (`:95`). Its shape: for a carrier and every `qnf` with
the six atom-layer order conditions and a Prior (UZ/SZ) structure,

```
(carrier qnf).holds M atomMap x t  ↔  ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

The **k=2 discharge target** is `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 …)`, where
`bracketEndChar_kvE2` (`OuterGate.lean:62`, task 335) is the **first live** k=2 carrier, delegating
by `rfl` to `kvE2_sepBody` at the standard instantiation (`bracketEndChar_kvE2_two_eq`, `:73`).

- **⇐ direction: LANDED** — `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:139`),
  unconditional, consumes `kvE2_sepBody_holds_of_honest`. Green, axiom-clean.
- **⇒ direction: BLOCKED** — `bracketEndChar_kvE2_sound_two_prior` and the assembled
  `bracketEndChar_kvE2_correct_two_prior` are **NOT delivered** (`OuterGate.lean:24-29, 172-201`).
  This is exactly the §C.2 soundness obligation.

**Ownership note (make-or-break for planning):** the deliverable-4 gate physically lives in
`OuterGate.lean`, which is **task 335's file** (status PARTIAL). Task 335 declared its ⇒ half BLOCKED
citing "carrier REDEFINITION outside this task's additive scope … requires explicit orchestrator
re-authorization … No such authorization is held" (`OuterGate.lean:194-201`). **But that block reason
is partly stale**: it cites the pre-334 O4 crux as if the redefinition were still pending, whereas
334 already performed it (`kvE2_sepArr'` + `kvE2_sepDisjValidOwner` IS the "bit-compatibility
filtering" the crux prescribed, SW:6631-6634). The true remaining work is the **soundness-extraction
threading of §C.2**, which does not edit the carrier structure at all — it adds soundness lemmas in
`SharedWitness.lean` (333-owned) and consumes them in `OuterGate.lean` (335-owned).

### D.2 Phase 13 — F4 ℤ adversarial discriminator: current state and house style

- **Construction-level F4 discrimination: LANDED** in `SubBracket.lean` (task 321 Stage B). The
  discriminator is `kvE_subBracket_ne_of_witnessCount_ne` (`SubBracket.lean:188`), built on
  `kvE_subBracket_witnessCount` (`:171`); the adversary is `σ'' = char[14,16,11,20]` positive via the
  `zUW` channel (`SubBracket.lean:62`). Verdict record: **PARTIAL-GO** (`SubBracket.lean:197`, "Stages
  A-B landed; semantic gate Stages C-D spawned").
- **Full semantic `M = ℤ` LHS-FALSE proof: NOT landed, explicitly spawned.** `SubBracket.lean:231`:
  "The FULL semantic `M = ℤ` LHS-FALSE proof requires the corrected carrier's evaluation … to be
  spawned as its own task". So plan-01 Phase 8's "F4 ℤ LHS-FALSE at (10,20)" is **downstream of the
  soundness gate** (it needs `bracketEndChar_kvE2`'s evaluation direction) and may already have a
  dedicated task — this must be checked before 333 claims it.
- **House style to mirror**: the F1-F4 verdict record + discrimination-corollary pattern in
  `SubBracket.lean:44-264` (fold-bit destructor lemma → witnessCount → `_ne_of_witnessCount_ne`
  corollary → inert verdict `/-! -/` record with axiom footprint stated). Mirror that structure for
  the F4 semantic instantiation; the DISCRIMINATION requirement (LHS must be FALSE, never weakened to
  pass) is the binding constraint (plan-01 Postmortem, lines 70-72).

---

## E. Recommendation — phase-sized plan for the remaining work

### E.0 First: this is a `/revise`, not a resume

`plans/01_bit-compat-carrier-redefinition.md` is **stale in every phase**: Phases 1-2 (redefine
arrL/R, non-vacuity) are done/deleted by 334; Phases 3-5 (plumbing + two singleton sorries) target
deleted declarations; Phases 6-8 have moved file (`OuterGate.lean`) and changed shape. **Do not
resume `plans/01`.** Run `/revise 333` to author a plan-02 against the frontier below. Resuming
plan-01 would send an implementation agent to edit line numbers and symbols that no longer exist.

### E.1 Ownership decision required BEFORE dispatch (orchestrator gate)

The remaining deliverable-4 gate is in `OuterGate.lean` (task 335, PARTIAL). Task 333 and task 335
now overlap on the same ⇒ soundness obligation. **Escalate one of:**
- **(Preferred) Re-scope 333** to own the `SharedWitness.lean` soundness-extraction lemmas (§C.2
  sub-obligations 1-3), and grant 335 the authorization to consume them in `OuterGate.lean` to close
  its ⇒ half. This respects the H7 territory contract (333 owns SharedWitness, 335 owns OuterGate).
- **(Alternative) Fold 333 into 335** and mark 333 `[EXPANDED]`/absorbed, since 334 already delivered
  333's original deliverables 1-2 and the residue is 335's blocked ⇒ half.

Flag to the user: **the OuterGate BLOCKED note's "requires orchestrator re-authorization" is the
gate.** Provide it, scoped to "add soundness lemmas in SharedWitness + consume in OuterGate; the
carrier structure `kvE2_sepArr'`/`kvE2_sepDisjValidOwner`/`kvE2_sepBody` stays byte-identical".

### E.2 Phase-sized frontier (each ≤ ~100-500 lines output)

| Phase | Scope | Owns | Risk |
|-------|-------|------|------|
| R1 | **Cleanup**: delete dead `kvE2_sepBody_nonvacuous` (+ optional strict `kvE2_sepModelOrder` cluster after a reference sweep); if wanted, add a 1-line unconditional `.disjuncts ≠ []` corollary from `kvE2_sepBody_complete`. | SW | LOW |
| R2 | **Soundness side-conditions**: prove the `Pairwise`/`Nodup` lemmas over `kvE2_sepSlotsL/ROf wo` for arbitrary `wo ∈ kvE2_sepArr' qnf` (§C.2 obligation 1), discharging `kvE2_sepBody_extract`'s `hpairL/hpairR/hnd` on the soundness path. | SW | MEDIUM |
| R3 | **HIGH / make-or-break**: the `kvE2_sepDisjValidOwner ⟹ forward-zone `hgate` conjunct` bridge (§C.2 obligation 2) — prove the cross-σ conjunct `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` from the arrangement-selected `kvE2_sepArr'_sound` bit at the realized placement. This is where the pre-334 O4 crux failed; the new `kvE2_sepDisjValidOwner` channel is the intended resolution — **verify it actually closes, do NOT weaken any filter or assume `hgate`.** | SW | **HIGH** |
| R4 | **Outer depth-2 fold** `kvE2_outer_fold` (§C.2 obligation 3): reassemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ bundles + `ExistProviders.correct` + navigated sub-chain (`NavigatedSpine.lean:445` sketch). | SW (engine) | HIGH |
| R5 | **Close the k=2 ⇒ gate**: `bracketEndChar_kvE2_sound_two_prior` + assembled `bracketEndChar_kvE2_correct_two_prior` = `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 …)` (consumes R2-R4). | OuterGate (335 territory — needs E.1 auth) | MEDIUM |
| R6 | **F4 semantic ℤ discriminator** (plan-01 Phase 13): LHS-FALSE at `(10,20)` + GO verdict record, mirroring `SubBracket.lean` F1-F4 house style — **only after R5** (needs the evaluation direction), and **only if not already a separate spawned task** (check first, `SubBracket.lean:231-253`). | SubBracket / new file | MEDIUM |

**Make-or-break flag:** **R3 is the single highest-risk step** and is the crux the entire 321→333
lineage has orbited. If R3 does not close with the `kvE2_sepArr'_sound` channel, STOP and escalate —
do NOT weaken any filter to vacuity and do NOT introduce `sorry`/`hgate`-assumption (zero-debt;
plan-01 Postmortem, lines 58-89). The strong prior is that it **does** close now, because
`kvE2_sepDisjValidOwner` is precisely the cross-σ bit channel the O4 crux (SW:6610-6638) proved was
the missing piece and prescribed as the faithful repair.

---

## Faithfulness constraints carried forward (from 321/333/334)

- Rabinovich 2014 Lemma 5.1: QF point types only (`charBase χ` / `charK (nfk_projFresh σ)`); no
  `fChainPred`, no nesting. **LITMUS grep must stay 0 on any new soundness lemma.**
- Lemma 3.2(1): the disjunction ranges over CONSISTENT refinements — **never weaken
  `kvE2_sepDisjValid` toward vacuity** to force a proof.
- Lemma 3.2(2): anchor cap 2; wrapper stated over `(x,t)`.
- Macro-side confinement: L list only `(x,w)` slots, R only `(w,t)`.
- F4 must genuinely DISCRIMINATE (LHS-FALSE); never weaken to pass.
- Do-not-edit assets (`SubBracket2V.lean`, `NavigatedSpine.lean` engine bricks, etc.) byte-identical;
  the carrier structure `kvE2_sepArr'`/`kvE2_sepBody` stays byte-identical (new work is additive
  soundness lemmas + the OuterGate consumer).

## Verification method note

All claims are line-cited against HEAD `235d181ef` source (not the stale summaries). Build state
confirmed by `lake build …OuterGate` exit 0 (1014 jobs). Sorry inventory by word-boundary grep
excluding comment lines. Axiom-cleanliness of the ⇐ chain is corroborated by the 334/335 summaries
and the green build; a `lean_verify` pass on `kvE2_sepBody_complete` / `kvE2_sepArr'_sound` /
`kvE2_sepBody_holds_of_honest` is recommended as the first action of the implementer to
re-confirm `[propext, Classical.choice, Quot.sound]` before building on them (not re-run here to
avoid a full-file rebuild during research). **UNVERIFIED-by-lean_verify (grounded by build + prose):
the exact axiom triple of the three ⇐ decls** — treat as high-confidence but re-check on dispatch.
