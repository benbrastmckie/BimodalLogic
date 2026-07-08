# Implementation Plan v2: Task #337 — Model-Order Merge Bracket-`holds` Engine for `kvE2_sepDisjunct`

- **Task**: 337 - Build the joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct` (Option A: model-order merge)
- **Status**: [NOT STARTED]
- **Effort**: 6-7 hours
- **Dependencies**: 336 (COMPLETED — `kvE2_sepBody_complete` generalized `hL` → `hLR`)
- **Research Inputs**: specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/01_rabinovich-witness-ordering-faithfulness.md; specs/335_outer_gate_assembly_engine_kvE2_body/reports/02_spawn-analysis.md
- **Artifacts**: plans/02_model-order-merge-bracket-holds.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md (literature-fidelity-policy.md)
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is the **v2 (Option A) redesign** of task 337. The v1 plan
(`plans/01_joint-disjunct-bracket-holds.md`) was BLOCKED at Phase 1 because it targeted `.holds`
for the **FIXED flatMap slot arrangement** `kvE2_sepSlotsL/R qnf` (SharedWitness.lean:315-322 —
`(kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor/RFor`), which is provably **not**
strictly-monotone-realizable when positive interior owners' anchors interleave. The codebase had
already deleted `kvE2_sepSlotsL_valid`/`_valid` as FALSE for exactly this reason
(SharedWitness.lean:1038-1044).

The Rabinovich (2014) faithfulness report (`reports/01_rabinovich-witness-ordering-faithfulness.md`)
establishes **Option A (model-order merge) as the faithful transcription of the witness**:
- **Definition 3.1** (md:63-74): the witness is a **single** strictly-monotone chain
  `x_0 < x_1 < … < x_n` in **actual model/temporal order** — a global monotone merge of all owners'
  anchor points. It is **not** a permutation quantifier at the witness level.
- **Lemma 3.2(1)** (md:77): the disjunction over order-consistent interleavings lives at the
  **formula level** and is **already landed** faithfully as `kvE2_sepArr'` (SharedWitness.lean:763,
  the filtered `kvE2_sepOrderTypes` enumeration). It must **not** be duplicated at the `.holds`
  level via `List.mem_permutations` (that is a Lean-encoding artifact per the research, §2).

Accordingly, the fix is a **retarget + one engine generalization**:
1. **Retarget** the deliverable's conclusion off the flatMap list and onto the **model-order
   arrangement** `kvE2_sepModelOrder` (SharedWitness.lean:719), whose membership in the faithful
   carrier is already proven (`kvE2_sepModelOrder_mem_orderTypes` :791; `kvE2_sepArr'_mem_modelOrder`
   :800).
2. **Generalize** the single-owner region engine `k1v_sorted_realizationK`
   (SubBracket2V.lean:633) from ONE owner to the **merged anchor set** across all positive owners,
   producing the single globally-monotone witness `interleaveK ps` (`Pairwise (· < ·)`).

Definition of done: a new sorry-free builder `kvE2_sepDisjunct_holds_of_honest` (naming mirrors the
existing `kvE2_sepGate_holds_of_honest` convention) in `SharedWitness.lean` producing
`(kvE2_sepDisjunct charBase charK qnf sortedL sortedR).2.holds M atomMap x t` for the **model-order
slot arrangement** `sortedL/sortedR`, plus the single authorized carrier rewire that makes it
consumable by `kvE2_sepBody_holds_iff`; `lean_verify` axiom-clean
(`{propext, Classical.choice, Quot.sound}` only, no `sorryAx`); all seven faithfulness invariants
F1-F7 preserved; full `lake build` green; every task-334/336 lemma preserved as a verified
parametric INPUT.

### SCOPE CHECK — Additive vs. carrier edit (REQUIRED determination)

**Determination**: the model-order **builder** is ADDITIVE; **wiring it into the carrier** for
consumption requires ONE targeted, non-weakening rewire of `kvE2_sepBody`'s disjunct map.

**Additive at the lemma level (cite exact lines)**:
- `kvE2_sepDisjunct` is **parametric** in `lL lR : List (KvE2SepSlot sig)`
  (SharedWitness.lean:613-615) — building `.holds` for a model-sorted `sortedL/sortedR` touches no
  existing declaration.
- `kvE2_sepDisjunct_extract` is likewise **parametric** in `{lL lR}` and requires only
  `hmemL/hpairL/hmemR/hpairR` — i.e. that the list *contains* every per-owner slot
  (`∀ σ ∈ kvE2_sepPos qnf, ∀ s ∈ kvE2_sepSlotsLFor σ, s ∈ lL`) and is `kvE2_sepSlotLe`-pairwise
  sorted (SharedWitness.lean:1865-1873). A **model-sorted** list satisfying those two conditions is
  a first-class target for both the extractor and a mirror builder — no extractor edit needed.
- The model-order machinery is already landed and axiom-clean: `kvE2_sepModelOrder` (:719),
  `kvE2_sepModelOrder_mem_orderTypes` (:791), `kvE2_sepArr'_mem_modelOrder` (:800, described
  axiom-clean at :1043).
- The engine `k1v_sorted_realizationK` (SubBracket2V.lean:633) is landed; it already returns
  `interleaveK ps` with `Pairwise (· < ·)` (:646) over a region list — the exact monotone-merge
  primitive Option A needs.

**Requires a carrier edit for CONSUMPTION (cite exact lines)**:
- `kvE2_sepBody`'s disjunct map **discards the weak order** (`fun _wo => …`) and hardcodes the
  FIXED flatMap `kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)`
  (SharedWitness.lean:835-836). Consequently `kvE2_sepBody_holds_iff` (:862-865) demands `.holds`
  for the **flatMap** list — the very object that is not model-sorted-realizable. To let the
  additive builder feed the carrier, `kvE2_sepBody` :835-836 must be rewired so each `_wo`-disjunct
  is built over a **`wo`-keyed model-sorted slot list** instead of the constant flatMap list.
- This rewire **strengthens rather than weakens**: it makes `kvE2_sepBody.holds` PROVABLE, whereas
  the flatMap arrangement was already known-unusable (the deleted FALSE scaffolds at
  SharedWitness.lean:1038-1044 and the "joint model-sorted arrangement … make-or-break" note at
  :334-337 document this exact unbuilt piece). All task-334/336 LEMMAS
  (`kvE2_sepDisjunct_extract`, `kvE2_sepArr'_sound` :2594, `kvE2_sepBody_complete` :1592,
  `kvE2_sepHonestBundleL/R`, `kvE2_sepModelOrder*`, `kvE2_sepBody_extract` :2013) are preserved as
  verified INPUTS: each is parametric in `lL/lR` or in `wo`, so rewiring the slot-list *argument*
  leaves their statements and proofs untouched.

**Available scaffolding**: a staged, verified-compiling switch for exactly this "joint model-sorted
arrangement" already exists at `specs/333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/handoffs/phase1-switch-and-repairs.patch`
(referenced from SharedWitness.lean:337-339). Phase 5 reuses it as the starting point rather than
re-deriving the switch.

**Conclusion**: Phases 1-4 (the builder) are strictly additive. Phase 5 (carrier consumption
wiring) is the single authorized carrier edit; it is required to actually unblock task 335 and is
the direct realization of the Option-A directive. v1's Non-Goal "Do NOT edit `kvE2_sepBody`" is
**superseded** for the `kvE2_sepBody` :835-836 disjunct-map slot-list argument ONLY, on the
authority of the Rabinovich faithfulness report; every other carrier body/signature remains
untouched.

### Research Integration

Newly integrated report: `reports/01_rabinovich-witness-ordering-faithfulness.md` (Option A =
faithful witness; Option B = Lean artifact at the witness level; enumeration belongs at the formula
level where `kvE2_sepArr'` already lands it; concrete next step = generalize
`k1v_sorted_realizationK` to the merged anchor set targeting the `kvE2_sepModelOrder` disjunct). The
v1-integrated spawn analysis (`specs/335_.../reports/02_spawn-analysis.md`) is retained for the
verified-INPUT boundary and the `bracketEndChar_k1v_complete` size precedent, but its flatMap-target
framing is **superseded** by the model-order retarget.

### Prior Plan Reference

v1 plan `plans/01_joint-disjunct-bracket-holds.md` is superseded. Its Phase 1 BLOCKER note (fixed
flatMap not model-sorted-realizable) is the precise motivation for this retarget; its Phases 2-5
proof skeleton (region assembly → engine → `IntervalPattern.holds_eq_succ.mpr` point-type/segment
match → endpoint discharge → verification gate) is carried forward but re-based onto the model-sorted
slot list, and extended with the Phase 5 carrier-consumption wiring that v1 (correctly, under its
Non-Goals) could not perform.

### Roadmap Alignment

No ROADMAP.md consulted (roadmap flag not set). Advances the `kamp_theorem_formalization` topic by
landing the faithful (Option A) completeness-side joint bracket engine, unblocking task 335
Phases 2-4.

## Goals & Non-Goals

**Goals**:
- Generalize `k1v_sorted_realizationK` (one owner) to a **joint engine over the merged anchor set**
  of all positive owners, producing one globally-monotone witness (`interleaveK ps`,
  `Pairwise (· < ·)`).
- Deliver a sorry-free `kvE2_sepDisjunct_holds_of_honest` producing
  `(kvE2_sepDisjunct charBase charK qnf sortedL sortedR).2.holds M atomMap x t` for the
  **model-order slot arrangement** `sortedL/sortedR` (keyed to `kvE2_sepModelOrder qnf`), from the
  honest depth-2 evaluation + `x < w < t` + `hLR`.
- Perform the single authorized carrier rewire of `kvE2_sepBody` :835-836 so the model-order
  disjunct is built over `sortedL/sortedR`, and re-prove `kvE2_sepBody_holds_iff` (and any
  non-vacuity/consumer it feeds) so the builder is consumable by task 335.
- `lean_verify` axiom-clean (`{propext, Classical.choice, Quot.sound}`, no `sorryAx`); full
  `lake build` green.
- Preserve F1-F7 (esp. F5 no open/closed zone-key conflation; LITMUS NavigatedSpine:437 — no
  `x1 < e_i` relative-position literal, witness/segment bounds from the bracket range `x`/`w`/`t`
  and the engine's interior guarantees, never an owner-to-owner chain).

**Non-Goals**:
- **Do NOT** re-enumerate permutations at the `.holds` level (`List.mem_permutations` /
  Option B). The formula-level enumeration `kvE2_sepArr'` already lands the faithful disjunction
  (Lemma 3.2(1), md:77); duplicating it at the witness level is forbidden by the research.
- **Do NOT** weaken, re-derive, or change the *statements/proofs* of any task-334/336 lemma
  (`kvE2_sepDisjunct_extract`, `kvE2_sepArr'_sound`, `kvE2_sepBody_complete`,
  `kvE2_sepHonestBundleL/R`, `kvE2_sepBody_extract`, `kvE2_sepModelOrder*`). Apply them as
  parametric INPUTS. The ONLY authorized carrier edit is the `kvE2_sepBody` :835-836 disjunct-map
  slot-list argument (Phase 5), which strengthens (makes `.holds` provable) and leaves every INPUT
  lemma untouched.
- **Do NOT** touch `OuterGate.lean` or `KampPrior.lean` — task 335's consumption is a separate
  re-dispatch.
- **Do NOT** generalize beyond the left-OR-right interior owner class (`hLR`).
- No bare `sorry`/`admit`, no vacuous placeholder (`def X := True`), no gate-modulo-assumed
  hypothesis.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Merged-anchor region list for `k1v_sorted_realizationK` mis-orders across owners (the interleave the whole redesign targets) | H | M | Build the region list in **model order** directly: one region per consecutive `(anchor_i, anchor_{i+1})` gap of the merged, sorted anchor set `{x, all owners' x1_σ, w, t}`; `hlink` chains via shared boundaries `x<…<w<…<t`; the engine's `interleaveK ps` then IS the monotone merge (SubBracket2V:646). Never place all of one owner's witnesses before another's by construction. |
| Defining the `wo`-keyed model-sorted slot list `sortedL/sortedR` satisfying the extractor shape (`hmemL/hpairL/hmemR/hpairR`, :1870-1873) | H | M | Reuse the staged switch `specs/333_.../handoffs/phase1-switch-and-repairs.patch` and the staged cross-σ compat defs (SharedWitness:324-340) as the sorted-list source; prove `hmem*` (contains every `kvE2_sepSlotsLFor/RFor σ` slot) from "sorted list = permutation of the flatMap union" and `hpair*` from `kvE2_sepSlotLe`-sortedness of the model merge. |
| Phase 3 (point-type + segment matching) overflows one agent run | H | M | Largest phase; build point-type realizations and the three `beta` segment families as separate green `have`s; if overflow looms, checkpoint the point-type helper as its own committed sorry-free lemma and split the segment matcher into a follow-on green sub-step (never a `sorry`). |
| Phase 5 carrier rewire cascades into re-proving many consumers of `kvE2_sepBody_holds_iff` | H | M | Scope the rewire to the `:835-836` disjunct-map argument only; the iff's structure (`∃ _wo ∈ kvE2_sepArr', …`) is preserved — only the per-`wo` disjunct object changes. Consume the staged patch's mechanical downstream repairs; re-prove `kvE2_sepBody_holds_iff` and `kvE2_sepBody_nonvacuous` (:1397) which route through `kvE2_sepArr'_mem_modelOrder` (already model-order-based). |
| Faithfulness regression: `x1 < e_i` relative-position literal (LITMUS NS:437) or F5 open/closed key conflation | H | L | All witness/segment bounds from the region endpoints `x`/`w`/`t` and the engine's interior guarantees (`hrange`), never an owner-to-owner chain; reuse honest bundles verbatim (they satisfy F1-F7); the staged sorted-list defs read slot INDICES only (SharedWitness:339-340), never a model-order `x1 < e_i` literal; Phase 6 re-audits. |
| Engine generalization to merged anchors is larger than the single-owner `k1v_sorted_realizationK` | M | M | `k1v_sorted_realizationK` is ALREADY the k-region lift (SubBracket2V:623-646, "Multi-anchor region-partition lift"); the merged-anchor region list is exactly its intended input. No new engine theorem is required — only the region-list *construction* (Phase 1) and its invocation (Phase 2). |
| `hLR` case split (left vs right interior) doubles region-mapping work | M | M | Handle the two interior zones symmetrically as in task 336's `rcases hLR … with hzone | hzone`; left → `kvE2_sepHonestBundleL` → its `(x,x1)`/`(x1,w)` regions, right → `kvE2_sepHonestBundleR` → its `(w,x1)`/`(x1,t)` regions; the merged region list consumes both uniformly in model order. |

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

Fully sequential: each phase consumes the sorry-free auxiliary lemma of the previous. Each phase is
sized to one agent run.

### Phase 1: Model-order slot arrangement + merged-anchor engine-region assembly [BLOCKED]

**BLOCKER** (Phase 1) — structural, plan-level (surfaced by implementation dispatch, `lean_goal`/source-grounded):

- **What failed**: The plan's foundational object — a `wo`-keyed, model-INDEPENDENT slot list
  `sortedL/sortedR` that is strictly-monotone-realizable and re-indexable to the engine's globally
  monotone witness output (`interleaveK ps`) — cannot be defined for the general multi-owner case
  within the authorized scope. Phase 1 cannot produce `sortedL/sortedR` + `hpairL/hpairR`, and
  Phase 2's re-indexing of `interleaveK ps` into the `sortedL ++ ptW :: sortedR` order with strict
  monotonicity is consequently ill-posed.
- **What was tried / verified** (read-only investigation; NO code edited, NO sorry introduced):
  1. Confirmed baseline `lake build` of `SharedWitness` is green.
  2. Read the target machinery: `kvE2_sepDisjunct`/`kvE2_sepBracketN` (:602-624), the extractor
     `kvE2_sepDisjunct_extract` (:1865), `IntervalPattern.holds_eq_succ` (ExistsForallNF.lean:188),
     the engine `k1v_sorted_realizationK` (SubBracket2V:633), the honest bundles
     `kvE2_sepHonestBundleL/R` (:1222/:1274), `kvE2_sepBody`/`_holds_iff`/`_nonvacuous`.
  3. Confirmed the forward-`.holds` template `bracketEndChar_k1v_complete` (CarrierK1V:1629) exists
     but targets the SINGLE-owner `bracketEndChar_k1v`, not the joint `kvE2_sepBracketN`.
- **Why it's stuck** (root cause — carrier encoding):
  - `kvE2_sepBracketN.holds` via `IntervalPattern.holds_eq_succ` requires witnesses
    `ws : Fin (N+1) → M.carrier` **strictly monotone in the FIXED slot-position order** of
    `sortedL ++ ptW :: sortedR`, with `ws i` realizing slot `i`'s point type in a
    **model-determined** interval (owner σ's `(x, x1_σ)` / `(x1_σ, w)` etc.), AND the `beta`
    segment obligations `∀ y ∈ (ws i, ws_{i+1})` keyed to `(sortedL.take i).contains (.lX1 σ)`
    (`kvE2_sepSegLForSub` :552-560).
  - `sortedL/sortedR` MUST be **model-independent**: they are arguments to `kvE2_sepDisjunct`
    inside `kvE2_sepBody` (:821-837), a `noncomputable def … (qnf) : VVecEA2` with **no model in
    scope**. The disjunct list the carrier maps over must be a syntactic function of `qnf`/`wo`.
  - The landed weak-order carrier `KvE2SepWeakOrder := List (σ × KvE2SepSpikeOrderType)` (:694-695)
    records only a **per-owner** tag (`strictBefore`/`strictAfter`/`coincident`) — each owner's
    class **relative to the shared witness `w`** (`kvE2_sepModelTag` :713-716 reads
    `nf0_zoneSpec σ.1`). It carries **NO cross-owner interleaving** of the multiple interior
    owners' fresh anchors `x1_σ` among themselves.
  - Therefore, for two distinct left-interior owners whose anchors interleave **differently across
    honest models** (`x1_σ1 < x1_σ2` in one model, `x1_σ2 < x1_σ1` in another), no fixed
    model-independent `sortedL` order is strictly-monotone-realizable for all such models, and `wo`
    cannot select the correct interleaving because it does not encode cross-owner order. Concretely,
    with the owner-blocked (flatMap) order, σ1's `lUW` realizer ∈ `(x1_σ1, w)` and σ2's `lXU`
    realizer ∈ `(x, x1_σ2)` violate monotonicity exactly when `x1_σ2 < x1_σ1` — the plan's own
    stated motivation — but the model-sorted interleaving that fixes it is model-dependent and
    unrepresentable in `wo`.
  - The codebase confirms this is the unbuilt general case: SharedWitness.lean:2007-2012 states
    `hpairL/hpairR` hold "whenever the canonical union is a single region-sorted block (e.g. the
    singleton configuration; **the general multi-owner pairwise discharge is the completeness-side
    Phase-8 obligation**)."
  - The plan's claimed "sorted-list source" scaffolding
    (`specs/333_.../handoffs/phase1-switch-and-repairs.patch`) **does not contain any
    `sortedL/sortedR` definition**: that patch only redefines `kvE2_sepSlotLe` (arrangement-blind →
    `kvE2_sepCompat`), a switch already landed live in the current file (:459-463). It provides no
    model-sorted list.
- **Secondary independent tension** (Phase 5 routing): the task-334 empirical finding
  (SharedWitness.lean:1421-1429) establishes that the **strict** `kvE2_sepModelOrder` validity is
  NOT honestly provable — at each owner's own fresh anchor the CLOSED `zAtX1L` bit is forced but the
  OPEN `zXU`/`zUW` bits are not — so the honestly-valid member of `kvE2_sepArr'` is
  `kvE2_sepCoincidentOrder`, not `kvE2_sepModelOrder`. Phase 5 task 2's stated route of the ⇐
  direction "through `kvE2_sepArr'_mem_modelOrder` (:800)" cannot be discharged, because
  `kvE2_sepArr'_mem_modelOrder` requires `hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) =
  true`, which the honest model does not force.
- **What is needed** (re-plan / v3 — outside current authorized scope): the two faithful
  resolutions both lie beyond the single authorized `kvE2_sepBody` :835-836 rewire:
  1. **Enrich the carrier's weak-order encoding** so a disjunct carries the cross-owner anchor order
     (a total/weak order on the merged anchor multiset, not just per-owner tags), enabling a
     `wo`-keyed model-sorted slot list. This modifies `KvE2SepWeakOrder` / `kvE2_sepOrderTypes` /
     `kvE2_sepArr'` / `kvE2_sepModelOrder` — the preserved task-334 INPUTs (plan Non-Goal), a
     carrier redefinition (properly a successor to task 333).
  2. **Slot-level interleaving enumeration at the `.holds` level** (`List.permutations` of the
     flat slot union) — this is the explicitly FORBIDDEN Option B (plan Non-Goal; research §2).
  Additionally the Phase-5 route must target the **coincidence** order/disjunct, not the strict
  model order. A v3 plan (or a spawned carrier-enrichment task) should choose resolution (1),
  re-scope the "single authorized carrier edit" to include the weak-order encoding, and re-target
  Phase 4/5 onto `kvE2_sepCoincidentOrder`.
- **Prohibited workarounds** (NOT taken): no `sorry`, no `admit`, no `def X := True`/vacuous
  placeholder, no `.holds`-modulo-assumed-segment. No code was modified; the file remains at its
  green post-task-336 state.


**Goal**: Define the `wo`-keyed **model-sorted** joint slot lists `sortedL/sortedR` (keyed to
`kvE2_sepModelOrder qnf`, satisfying the extractor shape `hmemL/hpairL/hmemR/hpairR`), then build
the **merged-anchor** `k1v_sorted_realizationK` region list from the honest bundles and discharge
the four engine preconditions (`hpos`, `hlink`, `hnd`, `hreal`). Deliver as a sorry-free private
helper (suggested `kvE2_sepModelOrder_regions_of_honest`).

**Tasks**:
- [ ] Verify on start: `kvE2_sepBody_complete` carries `hLR` (:1592-1599); `kvE2_sepArr'_sound`
      (:2594); `kvE2_sepModelOrder` (:719), `kvE2_sepModelOrder_mem_orderTypes` (:791),
      `kvE2_sepArr'_mem_modelOrder` (:800); honest bundles `kvE2_sepHonestBundleL` :1222 /
      `kvE2_sepHonestBundleR` :1274 (grep + one `lean_hover_info` each).
- [ ] Define `sortedL/sortedR` = the model-order permutation of `kvE2_sepSlotsL/R qnf` (source: the
      staged switch `specs/333_.../handoffs/phase1-switch-and-repairs.patch` + cross-σ compat defs
      SharedWitness:324-340). Prove `hmemL/hmemR` (contains every `kvE2_sepSlotsLFor/RFor σ` slot,
      :1870/:1872 shape) and `hpairL/hpairR` (`kvE2_sepSlotLe`-pairwise, :1871/:1873 shape).
- [ ] Build the merged-anchor region list `regions : List (M.carrier × M.carrier × List (NormalForm sig 0 1))`:
      one region per consecutive gap of the sorted merged anchor set `{x} ∪ {x1_σ : σ positive} ∪ {w} ∪ {t}`;
      per `σ`, `rcases hLR σ hσmem with hzone | hzone`, LEFT → `kvE2_sepHonestBundleL` interior
      realizers on `(x,x1_σ)`/`(x1_σ,w)`, RIGHT → `kvE2_sepHonestBundleR` on `(w,x1_σ)`/`(x1_σ,t)`.
- [ ] Discharge `hpos` (`r.1 < r.2.1`) from `hxw`/`hwt` + anchor ordering; `hlink`
      (`List.Chain' (·.2.1 = ·.1)`) from shared boundaries; `hnd` from the sorted list's rank nodup
      (`kvE2_sepSlotsLFor_pairwise` :996 / `_RFor_pairwise` :1027); `hreal` from the honest-bundle
      interior realizers.
- [ ] Verify each `have` with `mcp__lean-lsp__lean_goal`; keep sorry-free.

**Timing**: 1.25 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `sortedL/sortedR` definition(s) + `kvE2_sepModelOrder_regions_of_honest` (private helper), near
  end before `end`.

**Verification**:
- Helper + sorted-list defs compile sorry-free; `lean_verify` shows no `sorryAx`.
- Region boundaries are exactly `x`/interior anchors/`w`/`t` (no `x1 < e_i` literal introduced).
- `hmem*`/`hpair*` match the `kvE2_sepDisjunct_extract` hypothesis shapes byte-for-byte.

---

### Phase 2: Joint engine invocation + global monotone witness [NOT STARTED]

**Goal**: Apply `k1v_sorted_realizationK` to the Phase-1 merged-anchor regions, obtain `ps` +
`(interleaveK ps).Pairwise (· < ·)`, define the bracket witness function
`ws : Fin (N+1) → M.carrier` re-indexed to the model-sorted slot order
(`sortedL ++ ptW :: sortedR`), and prove strict monotonicity plus range `x < ws i < t`. Deliver as a
sorry-free private helper (suggested `kvE2_sepModelOrder_witnesses_of_honest`).

**Tasks**:
- [ ] `obtain ⟨ps, hf, hsorted⟩ := k1v_sorted_realizationK M regions hpos hlink hnd hreal`
      (consuming the Phase-1 helper).
- [ ] Define `ws` by re-indexing `interleaveK ps` into the `kvE2_sepBracketN` slot order
      `sortedL ++ ptW :: sortedR`, pivot `ptW` at index `(sortedL.map …).length` (mirror the
      extractor's `kvE2_sep_getElem_left/mid/right` index arithmetic :1897-onward, in reverse).
- [ ] Prove strict monotonicity `∀ i j, i < j → ws i < ws j` from `hsorted` (`interleaveK`
      pairwise, SubBracket2V:646).
- [ ] Prove range `∀ i, x < ws i ∧ ws i < t` from region positivity/link (leftmost block lower
      bound `x`, rightmost block upper bound `t`).
- [ ] Verify each step with `lean_goal`; keep sorry-free.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepModelOrder_witnesses_of_honest` (private helper).

**Verification**:
- Helper compiles sorry-free; `lean_verify` no `sorryAx`.
- `ws` indexing agrees with `kvE2_sepBracketN`'s `sortedL ++ ptW :: sortedR` layout (pivot at
  `|sortedL|`).

---

### Phase 3: Point-type + segment matching → model-order `bracket.holds` [NOT STARTED]

**Goal**: From the Phase-2 witness sequence, prove every point-type realization and the three
`kvE2_sepSegs` segment families, then close
`(kvE2_sepDisjunct charBase charK qnf sortedL sortedR).2.holds` via
`IntervalPattern.holds_eq_succ.mpr` (ExistsForallNF.lean:188). Deliver as a sorry-free private
helper (suggested `kvE2_sepModelOrder_bracket_holds_of_honest`). Largest phase.

**Tasks**:
- [ ] `rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t (by omega)]` and
      `refine ⟨ws, ?_, ?_, ?_, ?_, ?_, ?_⟩` to expose the six mpr obligations (mono, range, point
      types, `beta[0]`, `beta[i+1]`, `beta[k+1]`).
- [ ] Mono + range: discharge from the Phase-2 helper directly.
- [ ] Point types: for each slot `i`, evaluate `(sortedL.map … ++ ptW :: sortedR.map …)[i]` at
      `ws i` — left slots from `kvE2_sepHonestBundleL` fresh-point realizers, pivot `kvE2_sepPtW`
      from the shared `w`, right slots from `kvE2_sepHonestBundleR`; positions read via the
      model-sorted slot order, not the flatMap order.
- [ ] Segments: for each inter-witness gap + the two boundary gaps, realize the refined-conjunction
      segment type from the region-interior realizers threaded through the engine's `ps` per-region
      guarantees (`hreal` content).
- [ ] Verify each `have` with `lean_goal`; keep sorry-free. If nearing an agent-run boundary,
      commit the point-type portion as a standalone green lemma and continue segments as a
      follow-on green sub-step.

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepModelOrder_bracket_holds_of_honest` (private helper).

**Verification**:
- Helper compiles sorry-free; `lean_verify` no `sorryAx`.
- Segment bounds come from region endpoints/engine guarantees, not owner-to-owner chains
  (LITMUS NS:437); F5 closed/open keys unconflated.

---

### Phase 4: Endpoint discharge + assemble builder `kvE2_sepDisjunct_holds_of_honest` [NOT STARTED]

**Goal**: Discharge the endpoint conjuncts `kvE2_sepEpL`@x and `kvE2_sepEpR`@t from the honest
evaluation `h`, then assemble the three-part `VecEA2.holds` and state + prove the builder
`kvE2_sepDisjunct_holds_of_honest` targeting the **model-order arrangement** `sortedL/sortedR`,
sorry-free.

**Tasks**:
- [ ] Prove `(kvE2_sepEpL charBase charK qnf).eval_at M atomMap x` and
      `(kvE2_sepEpR charBase charK qnf).eval_at M atomMap t` from the atom-layer of `h` over
      `[w,x,t]` (same data the extractor destructures as `hepL`/`hepR` :1877-1878; add a small
      private `have` if no direct helper exists).
- [ ] State `kvE2_sepDisjunct_holds_of_honest` (signature mirroring `kvE2_sepGate_holds_of_honest`
      :1149 — `qnf`, `charBase`, `charK`, `M`, `atomMap`, `w x t`, `hxw`, `hwt`, `hLR`, `h`)
      concluding `(kvE2_sepDisjunct charBase charK qnf sortedL sortedR).2.holds M atomMap x t`.
- [ ] `refine ⟨hepL, hepR, ?_⟩`; close the bracket via the Phase-3 helper (instantiated at the
      model-sorted `sortedL/sortedR`).
- [ ] Verify each `have` with `lean_goal`; keep sorry-free.

**Timing**: 0.75 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add the
  builder `kvE2_sepDisjunct_holds_of_honest`.

**Verification**:
- Builder compiles sorry-free; `lean_verify` no `sorryAx` (full audit in Phase 6).
- Conclusion is `.holds` for the model-order arrangement (NOT the flatMap `kvE2_sepSlotsL/R qnf`).

---

### Phase 5: Carrier consumption wiring — rewire `kvE2_sepBody` :835-836 + re-prove `kvE2_sepBody_holds_iff` [NOT STARTED]

**Goal** (the single AUTHORIZED carrier edit; see SCOPE CHECK): rewire the `kvE2_sepBody` disjunct
map so each `_wo`-disjunct is built over the `wo`-keyed model-sorted slot list `sortedL/sortedR`
instead of the constant flatMap `kvE2_sepSlotsL/R qnf`, then re-prove `kvE2_sepBody_holds_iff` and
`kvE2_sepBody_nonvacuous` so the Phase-4 builder is consumable by task 335. Every INPUT lemma
statement/proof stays untouched.

**Tasks**:
- [ ] Apply/adapt the staged switch
      `specs/333_.../handoffs/phase1-switch-and-repairs.patch` for the `kvE2_sepBody` :835-836
      disjunct-map argument only (constant flatMap → `wo`-keyed model-sorted list).
- [ ] Re-prove `kvE2_sepBody_holds_iff` (:855-865): the `∃ _wo ∈ kvE2_sepArr', …` structure is
      preserved; only the per-`wo` disjunct object changes to the model-sorted arrangement. Route
      the ⇐ direction through the Phase-4 builder for the `kvE2_sepModelOrder` disjunct
      (`kvE2_sepArr'_mem_modelOrder` :800).
- [ ] Re-confirm `kvE2_sepBody_nonvacuous` (:1397) — it already routes through
      `kvE2_sepArr'_mem_modelOrder` / the coincidence order (:1600-1611); confirm it survives the
      rewire unchanged or with a minimal parametric adjustment.
- [ ] `git diff` gate on this phase: confirm NO change to any INPUT lemma statement/proof
      (`kvE2_sepDisjunct_extract`, `kvE2_sepArr'_sound`, `kvE2_sepBody_complete`,
      `kvE2_sepHonestBundleL/R`, `kvE2_sepBody_extract`, `kvE2_sepModelOrder*`); only the
      `kvE2_sepBody` :835-836 slot-list argument and `kvE2_sepBody_holds_iff`'s per-`wo` object
      changed.
- [ ] Verify each step with `lean_goal`; keep sorry-free.

**Timing**: 1.25 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` —
  `kvE2_sepBody` :835-836 (slot-list argument), `kvE2_sepBody_holds_iff`, and any minimal
  parametric adjustment to `kvE2_sepBody_nonvacuous`.

**Verification**:
- `kvE2_sepBody_holds_iff` and `kvE2_sepBody_nonvacuous` compile sorry-free; `lean_verify` no
  `sorryAx`.
- `git diff` confirms every INPUT lemma statement/proof byte-for-byte unmodified.
- The builder `kvE2_sepDisjunct_holds_of_honest` now discharges the ⇐ direction of
  `kvE2_sepBody_holds_iff`.

---

### Phase 6: Axiom-cleanliness gate + F1-F7 faithfulness audit + full build [NOT STARTED]

**Goal**: Run the explicit axiom-cleanliness gate, audit F1-F7 preservation, confirm INPUT lemmas
untouched, and pass a full project build.

**Tasks**:
- [ ] `lean_verify` on `kvE2_sepDisjunct_holds_of_honest`, `kvE2_sepBody_holds_iff`, and each
      Phase-1..3 helper; confirm each returns `{propext, Classical.choice, Quot.sound}` with **no
      `sorryAx`**.
- [ ] Grep the diff for `sorry`/`admit`/new `axiom`/vacuous `:= True` — must be NONE.
- [ ] F1-F7 checklist: F1 (region types stay QF); F2 (non-vacuous — realizers from honest bundles,
      not placeholders); F3/F4 (witnesses region-interior, no new anchors, no `x1 < e_i` literal);
      F5 (no open/closed zone-key conflation — closed `zAtX1L`/`zAtX1R` bits read as in task 336);
      LITMUS NavigatedSpine:437 (all witness/segment bounds from the bracket range `x`/`w`/`t` and
      engine interior guarantees, never a chain).
- [ ] `git diff` gate: confirm the change is the Phase-1..4 additive helpers + the single Phase-5
      `kvE2_sepBody`/`kvE2_sepBody_holds_iff` rewire; every other declaration (esp. the INPUT
      lemmas) unmodified.
- [ ] Full `lake build` green.

**Timing**: 0.75 hours

**Depends on**: 5

**Files to modify**:
- None (verification-only; fixups surfaced by the audit excepted).

**Verification**:
- `lean_verify` on all delivered/rewired declarations axiom-clean, no `sorryAx`.
- Full `lake build` succeeds.
- F1-F7 checklist passes; INPUT lemmas untouched.

---

## Testing & Validation

- [ ] `lake build` of the `NfMultiAnchorBridge/` target (and full project in Phase 6) succeeds.
- [ ] `lean_verify` on `kvE2_sepDisjunct_holds_of_honest`, `kvE2_sepBody_holds_iff`, and every
      auxiliary helper returns `{propext, Classical.choice, Quot.sound}` with no `sorryAx`.
- [ ] No bare `sorry`/`admit`, no new `axiom`, no vacuous definition anywhere in the diff.
- [ ] Every task-334/336 INPUT lemma statement/proof is byte-for-byte unmodified (only
      `kvE2_sepBody` :835-836 slot-list arg + `kvE2_sepBody_holds_iff` per-`wo` object changed).
- [ ] The builder's conclusion targets the model-order arrangement `sortedL/sortedR`, and the
      rewired `kvE2_sepBody_holds_iff` (:862-865) consumes it.
- [ ] No `List.mem_permutations` at the `.holds` level (Option B forbidden).
- [ ] F1-F7 faithfulness checklist passes (F5 closed/open discrimination; LITMUS NS:437 no
      `x1 < e_i` literal; witness/segment bounds from the bracket range and engine guarantees).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` —
  additive: `sortedL/sortedR` model-order slot lists, `kvE2_sepModelOrder_regions_of_honest`,
  `kvE2_sepModelOrder_witnesses_of_honest`, `kvE2_sepModelOrder_bracket_holds_of_honest` (private
  helpers), the builder `kvE2_sepDisjunct_holds_of_honest`; and the single authorized carrier
  rewire of `kvE2_sepBody` :835-836 + re-proof of `kvE2_sepBody_holds_iff`.
- `specs/337_.../plans/02_model-order-merge-bracket-holds.md` (this file).
- `specs/337_.../summaries/02_model-order-merge-bracket-holds-summary.md` (on completion).
- **Downstream**: task 335 re-dispatches Phases 2-4 to consume `kvE2_sepDisjunct_holds_of_honest`
  via the rewired `kvE2_sepBody_holds_iff`.

## Rollback/Contingency

- Phases 1-4 are additive to `SharedWitness.lean`. To revert those: delete the new declarations;
  the file returns to its post-task-336 state with every INPUT untouched.
- Phase 5 is a single scoped rewire of `kvE2_sepBody` :835-836 + `kvE2_sepBody_holds_iff`. To
  revert: restore the constant flatMap argument (returns to the byte-for-byte post-336 state). If
  Phase 5 cascades beyond the iff + non-vacuity into many consumers, **checkpoint Phases 1-4 as a
  committed green additive builder** and surface the carrier-consumption breadth as a scope question
  (spawn a dedicated carrier-rewire task) rather than forcing an over-broad edit.
- If Phase 3 cannot close within one agent run: commit the point-type helper as a standalone
  sorry-free lemma (green checkpoint), then continue the segment matcher as a follow-on green
  sub-step. Never commit a bare `sorry`, a vacuous placeholder, or a `.holds` modulo an assumed
  segment obligation (honest RESCOPE discipline).
- If any fix appears to require weakening a task-334/336 INPUT lemma statement/proof (as opposed to
  the sanctioned `kvE2_sepBody` slot-list argument), stop and surface it as a scope question rather
  than weakening a verified INPUT.
