# Implementation Plan: Task #335 — Outer-Gate Assembly Engine (`kvE2_body` / `bracketEndChar_kvE2`) — FRAGMENT GATE (v5, post-blocker-adjudication)

- **Task**: 335 - Build the outer-gate assembly engine `kvE2_body` / `bracketEndChar_kvE2`, the two-level quant-layer connector that `KampPrior.lean:351` (the depth-k≥2 Cor 5.4 converter) consumes — now delivered as the **single-positive-sub fragment gate** sanctioned by task 321 verdict N2
- **Status**: [BLOCKED] (Phase A COMPLETED; Phase B BLOCKED — interior-gate FORWARD conjunct has no public producer under `hfrag`; C/D not reached)
- **Effort**: 4-6 hours (Phases 1-3 landed; the genuine risk is Phase C `hexcl`-under-`hfrag` GO/NO-GO probe)
- **Dependencies**:
  - 334 (COMPLETED — faithful carrier redefinition `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`)
  - 337 (COMPLETED — `kvE2_sepBody_holds_of_honest` completeness engine, consumed by the landed Phase 2)
  - 342 (COMPLETED — interior-restricted owner index `kvE2_sepPosI`, tie-admitting weak orders, `hLR` deletion)
  - **333 (COMPLETED — `ff54d45c5`)** — landed `kvE2_outer_fold` (`SharedWitness.lean:9897`, green, axiom-clean) plus the extraction/kit lemmas (`kvE2_sepBody_extract`, `kvE2_sepBundleL/R_parts`, `kvE2_sepBody_kit_sound`). 335 CONSUMES these unchanged; H7 territory holds (333 owns `SharedWitness.lean`, 335 owns `OuterGate.lean`).
  - **321 verdict N2 (SANCTION — scope amendment, 2026-07-07)**: the GO/NO-GO deliverable for 309 Phase 13.4 + `KampPrior.lean:351` is re-scoped to the single-positive-sub fragment; the multi-positive case is deferred to the named successor task (bit-compatibility filtering carrier re-definition). This is the authoritative authorization for the `hfrag` restriction on `qnf`.
- **Research Inputs**:
  - specs/335_outer_gate_assembly_engine_kvE2_body/reports/04_gate-blocker-adjudication.md (**AUTHORITATIVE — the adjudication that forced this v5**. Verdict `b-weaken-fragment`. Branch (a) SharedWitness reshape REFUTED (rich-model refutability `OuterGate.lean:235`; O4 CRUX RECORD `SharedWitness.lean:6698-6791` certifies channel exhaustion; `bracketEndChar_kv_factors` `CarrierKv.lean:422` machine-checks the information ceiling). Branch (b-strengthen) REFUTED-BY-AUDIT (330 audit category error; protected prior interface `PriorInterface.lean:3-6`). Sanctioned path: single-positive-sub fragment gate.)
  - specs/335_outer_gate_assembly_engine_kvE2_body/.blocker-research.json (verdict JSON, `plan_v5_shape`, `spawn_needed: false`)
  - specs/335_outer_gate_assembly_engine_kvE2_body/handoffs/01_continuation.md (where implementation stopped: Phases 1-3 landed green; 4a/4b/4c blocked on the four provider-conditional families the fold takes as hypotheses)
  - specs/335_outer_gate_assembly_engine_kvE2_body/reports/03_plan-currency-check-post-333.md (post-333 currency check — established that `kvE2_outer_fold` takes FOUR families 335 must discharge, not thread; superseded on the discharge strategy by report 04)
  - specs/333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/reports/03_pdf-fidelity-r3-dissolved-regrounding.md (CONFIRMED — citation rule: Rabinovich by PDF page only)
  - specs/337_.../reports/13_rxw-faithfulness-audit.md + 14_tie-class-semantics-audit.md (CONFIRMED — `.rXW` faithfulness; primed order `kvE2_sepHonestOrder'` is the only correct order)
- **Artifacts**: plans/05_fragment-gate-v5.md (this file); supersedes plans/04_outer-gate-post-333-v4.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; lean4.md; literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is **plan v5**, forced by the Phase-4 blocker adjudication (report 04). Plan v4 correctly
identified that the landed `kvE2_outer_fold` (`SharedWitness.lean:9897`) takes four
provider-conditional families (`hgateL`/`hgateR`/`hbdry`/`hexcl`) as hypotheses that 335 must
discharge at `charK := P.existF 0`. Plan v4's Phase 4 then attempted to discharge them
**unconditionally over an arbitrary `qnf`** — and that is REFUTED, not merely hard:

- **Branch (a)** (reshape `SharedWitness.lean` so the gate is derived from `.holds`) is REFUTED
  semantically. The FORWARD clause `(∃ v, zoneHolds … zs v ∧ nf_eval χ) → σ.2 (nf0_assemble …) =
  true` is FALSE in a rich model for arbitrary `qnf` (`OuterGate.lean:235-236`): `σ.2` need not
  mark every realizable `(zs, χ)`. The O4 CRUX RECORD (`SharedWitness.lean:6698-6791`) certifies
  channel exhaustion ("no derivation exists, not merely none found", SW:6742-6752), and
  `bracketEndChar_kv_factors` (`CarrierKv.lean:422`) machine-checks the (outer zone, projected
  1-type) information ceiling. No file-ownership change fixes a false statement.
- **Branch (b-strengthen)** (a higher-arity `charK` provider pinning σ's full arity-4 content) is
  REFUTED-BY-AUDIT (the 330 category-error finding: joint multi-anchor content rides NAVIGATED
  evaluation position, never richer static atoms; E[Σ] point types are quantifier-free monadic).
  It was already machine-refuted at F4 and would break the PROTECTED prior interface
  (`ExistProviders`/`BracketCarrierCorrectVPrior`, `PriorInterface.lean:3-6`) consumed by
  KampPrior's recursion.

**The sanctioned path (this plan): the single-positive-sub FRAGMENT gate.** Task 321 verdict N2
(authoritative scope amendment) re-scoped the 309 Phase 13.4 + `KampPrior.lean:351` deliverable to
this fragment. The O4 CRUX RECORD states the obstruction residue **VANISHES** there
(SW:6785-6791): "with ONE interior positive there are no cross-σ slots … the residue vanishes;
this is exactly the configuration the landed `kvE_subBracket2V_sound_of_outer`
(`SubBracket2V.lean:1216`) + `kvE_sub2V_bounded_anchor_of_outer` (`:1182`) already serve." Five of
six `hgate` conjuncts are already derivable from the landed O4 core (SW:6700-6706).

**Crucially, the fragment route needs NO `SharedWitness.lean` edit.** The fold takes the four
families as hypotheses; 335 discharges them *under a fragment hypothesis `hfrag` on `qnf`* entirely
inside its own territory (`OuterGate.lean`). `spawn_needed: false` for the current unblock. The
multi-positive case remains the deferred successor task 321-N2 already named (bit-compatibility
filtering — a carrier re-definition with O1b/O2/O3 knock-on rework).

**Deliverables** (the k=2 N2-C fragment gate):
- `bracketEndChar_kvE2_sound_two_prior_frag : (hfrag : kvE2_sepFragment qnf) →
  (bracketEndChar_kvE2 …).holds M atomMap x t → ∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` — the ⇒
  soundness half, provider-shape UNCONDITIONAL (six order bits + UZ/SZ + x t only, per 309's
  requirement), with the fragment hypothesis entering **only** as a qnf-domain restriction (the
  narrowing 321-N2 sanctions — NOT a provider-conditional family hypothesis).
- `bracketEndChar_kvE2_correct_two_prior_frag : (hfrag : kvE2_sepFragment qnf) →
  BracketCarrierCorrectVPrior …` (fragment-restricted) — the exact fragment-scoped GO gate task
  309 v8 consumes at Phase 13.4/14 and `KampPrior.lean:351`.

The work is confined to `OuterGate.lean`. 341's Phase-3 gate ("335 COMPLETED + `SharedWitness.lean`
frozen from HEAD `ff54d45c5` lineage") stays intact and becomes EASIER to certify — the fragment
route touches OuterGate.lean only.

### Verified interface facts (checked against HEAD, do not re-derive)

| Symbol | Location | Role in this plan |
|---|---|---|
| `kvE2_outer_fold` | `SharedWitness.lean:9897` | LANDED. Consumed by Phase D. Takes six order bits, `M`, `x t`, `h`, `hgateL`, `hgateR`, `hbdry`, `hexcl` → `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`. Fed the four families discharged under `hfrag`. |
| O4 CRUX RECORD | `SharedWitness.lean:6698-6791` | The channel-exhaustion certificate. SW:6700-6706 = five `hgate` conjuncts already derivable; SW:6785-6791 = residue-vanish under one interior positive. Read-only reference. |
| `kvE_subBracket2V_sound_of_outer` | `SubBracket2V.lean:1216` | LANDED. The composition the fragment `hgateL`/`hgateR` consume (Phase B). |
| `kvE_sub2V_bounded_anchor_of_outer` | `SubBracket2V.lean:1182` | LANDED. Bounded-anchor companion consumed by Phase B. |
| `kvE2_sepBody_extract` | `SharedWitness.lean:8410` | Produces the interior `kvE2_sepBundleL/R` bundles (Phase B). |
| `kvE2_sepBody_kit_sound` | `SharedWitness.lean:9787` | Called internally by the fold; defines the exact `hgateL`/`hgateR` shapes Phase B must build. |
| `kvE2_sepPos` / `nf0_zoneSpec` | (carrier) | Positive-sub owner index + zone spec — the fragment predicate quantifies over these (Phase A). |
| `kvE2_sepSegForm_excludes` + `neg_2var_vec_ea` | (carrier) / `EANegationClosure.lean:722` | Segment-exclusion form + landed Prop 4.2 negation closure — the evidence base for the `hexcl`-under-`hfrag` probe (Phase C). |
| `ExistProviders` (`existF`, `correct`) | `PriorInterface.lean:38` | `correct : temporal_truth … ↔ ∃ env, nf_eval_nf …`. Provider tool; instantiated at `charK := fun χ => P.existF 0 χ`. |
| `BracketCarrierCorrectVPrior` | `PriorInterface.lean:60` | k=2 target (fragment-restricted). At successor depth `qnf.atom_assgn (.order …)` ≡ `qnf.1 (.order …)` (defeq). PROTECTED interface — provider shape must NOT change. |
| `bracketEndChar_kv_factors` | `CarrierKv.lean:422` | The (outer zone, projected 1-type) information-ceiling record — the reference for the Phase C NO-GO classification. |
| `bracketEndChar_kvE2` / `_two_eq` | `OuterGate.lean:62` / `73` | Live def + `rfl` bridge (Phase 1, landed). Delegates to `kvE2_sepBody … (fun χ => P.existF 0 χ)`. |
| `bracketEndChar_kvE2_complete_two_prior` | `OuterGate.lean:139` | ⇐ half (Phase 2, landed). Phase D mirrors its signature shape (arrow reversed, `hfrag` added). |
| `KampPrior.lean:351` | — | Downstream consumer of the fragment gate (R-B, out of scope here; the 309-v8 handoff note records what it receives). |

### Research Integration (newly integrated in plan v5)

- **335 report 04 (`04_gate-blocker-adjudication.md`, AUTHORITATIVE)** — the load-bearing new
  finding driving this entire v5: the plan-v4 unconditional Phase-4 discharge is REFUTED (branch a
  semantically, branch b-strengthen by audit), and the ONLY viable path is the 321-N2-sanctioned
  single-positive-sub fragment gate, dischargeable entirely inside OuterGate.lean under a `qnf`
  restriction with no SharedWitness edit. Supplies the O4 residue-vanish citation (SW:6785-6791),
  the landed `SubBracket2V.lean:1216`/`:1182` consumption pattern, and the mandatory `hexcl`
  GO/NO-GO framing.
- **335 `.blocker-research.json`** — the verdict JSON (`b-weaken-fragment`, `spawn_needed: false`,
  `plan_v5_shape`) confirming no spawn and no 341 impact.
- **Superseded by report 04 on strategy**: plan v4's Phase 4 (unconditional four-family discharge)
  — retained only as the historical record of the refuted attempt; its Phase 1-3 grounding is
  PRESERVED (carried as this plan's Phases 1-3).
- **Preserved**: 333 report 03, 337 reports 13/14 (`.rXW` faithfulness, primed-order guardrail),
  the page-cite-only citation rule. All remain binding.

### Citation rule (binding — carried into every phase)

Cite the Rabinovich source **by PDF page** (`p.N`), never `md:NN`. The markdown paraphrase drops
every displayed equation and inverts `k≠m`→`k=m`. For **Lemma 3.2** use the mandated form: *"the
construction forced by Def 3.1 (p.4), corroborated by the k=m split (p.7) and Def 7.5 (p.13);
Lemma 3.2(1) (p.4) states the closure without printed proof."* The O4 residue-vanish claim cites
the CRUX RECORD by SW line only (SW:6785-6791), an internal proof-tree reference, not a paper cite.

## Goals & Non-Goals

**Goals**:
- Preserve the landed Phase 1 (live def + `rfl` bridge), Phase 2 (⇐ completeness
  `bracketEndChar_kvE2_complete_two_prior`), and Phase 3 (retired BLOCKED note + citation hygiene).
  Do not re-plan or re-touch them.
- Introduce a **single-positive-sub fragment predicate** `kvE2_sepFragment qnf` and perform the
  `_frag` **statement surgery** — new `_frag` theorem shells in `OuterGate.lean` that carry `hfrag`
  as a `qnf`-domain restriction (Phase A).
- Discharge `hgateL`/`hgateR` **under `hfrag`** — with one interior positive the cross-σ residue
  vanishes (O4 record SW:6785-6791), consuming `kvE_subBracket2V_sound_of_outer`
  (`SubBracket2V.lean:1216`) + `:1182` + the O4 derivable core (Phase B).
- Run the `hbdry`/`hexcl`-under-`hfrag` **GO/NO-GO probe** as ONE bounded dispatch; on NO-GO, STOP
  and report (escalate, do not thrash) (Phase C).
- Assemble `bracketEndChar_kvE2_correct_two_prior_frag` (fragment-restricted, provider-shape
  unconditional) and write the **309-v8 handoff note** recording what the fragment gate provides
  for 309 Phases 13.4/14 and `KampPrior.lean:351` (Phase D).
- Keep the deliverables axiom-clean `{propext, Classical.choice, Quot.sound}`; no sorries on live
  paths; primed order only; LITMUS-clean (`NavigatedSpine.lean:437`).

**Non-Goals**:
- **Do NOT edit `SharedWitness.lean` anywhere in this plan.** 341's frozen-file gate must stay
  intact (SharedWitness.lean byte-unchanged from HEAD `ff54d45c5` lineage). H7 territory:
  `OuterGate.lean` only. This is stricter than v4: v4 permitted "coordinate with 333 to reshape";
  v5 forbids any SharedWitness reshape because branch (a) is REFUTED — there is nothing to reshape
  that would help.
- **Do NOT edit `SubBracket2V.lean` or any 333/334/342 carrier input** — consume unchanged.
- **Do NOT add `hbdry`/`hexcl` (or any provider-conditional family) as a hypothesis of the final
  fragment gate.** The ONLY sanctioned hypothesis beyond the provider shape is `hfrag`
  (`kvE2_sepFragment qnf`) — the qnf-domain restriction 321-N2 authorizes. A provider-conditional
  family hypothesis would fail 309's provider-unconditional `BracketCarrierCorrectVPrior`
  requirement.
- **Do NOT attempt the multi-positive case.** It is the deferred successor task (bit-compatibility
  filtering carrier re-definition, O4 record SW:6763-6770). Create as a NEW task when 335 lands; do
  NOT fold into 335 or 341.
- **Do NOT re-attempt branch (a) or branch (b-strengthen).** Both are adjudicated REFUTED (report
  04). No SharedWitness reshape, no higher-arity `charK` provider.
- **Do NOT reintroduce any interiority hypothesis** (`hL`, `hLR`) — refuted by
  `kvE2_sepHonest_hLR_absurd` (SW:5714). The fragment predicate is a positivity/zone restriction on
  `qnf`, NOT an interiority guard on realized types.
- **Do NOT wire the gate into `KampPrior.lean:351`** — R-B, a distinct downstream task, out of
  scope (the 309-v8 handoff note describes the interface, does not implement it).
- No bare `sorry`/`admit`; no vacuous close (`False.elim`, `hLR_absurd.elim`, `:= True`,
  `:= trivial`); no gate-modulo-assumed-family; zero-debt on live paths.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **`hexcl`-under-`hfrag` does NOT close** (negative-sub exclusion in the fragment: the O4 record adjudicates the interior-gate residue only; exclusion content rides `kvE2_sepSegForm_excludes` + Prop 4.2 closure `neg_2var_vec_ea` and is *plausible but NOT pre-certified*) | H | **M** | Phase C is an EXPLICITLY one-dispatch bounded GO/NO-GO probe. On NO-GO: STOP, capture the exact residual goal (`lean_goal` transcript) + failed-closer list (F4/O4 evidence style), classify via `bracketEndChar_kv_factors` (`CarrierKv.lean:422`), mark Phase C `[BLOCKED]`, and escalate to the user — the only remaining path would be the successor carrier re-definition. Do NOT assume the family, close vacuously, or thrash across more dispatches. |
| Fragment predicate `kvE2_sepFragment` chosen too weak (admits non-interior positives → `hbdry` needs its own probe) or too strong (unusable by 309) | M | M | Phase A default = **"exactly one positive sub, interior-zoned"** (strongest residue-vanish guarantee per O4; `hbdry` non-interior class then empty/trivial). Record the exact form as a Phase-A decision; confirm it is the weakest restriction making all four families derivable. Flag any residual `hbdry` probe need to Phase C. |
| `hgateL`/`hgateR` fragment shapes do not line up with the fold's expected argument types (SW:9911-9945 geometries differ L vs R) | M | L | Build Phase B directly against the verbatim fold-signature shapes; consume `kvE_subBracket2V_sound_of_outer` (:1216) + `:1182` + the O4 derivable core (SW:6700-6706). Confirm each `have` with `lean_goal` before wiring. |
| Order-bit mismatch: fold wants `qnf.1 (.order …)`, `BracketCarrierCorrectVPrior` supplies `qnf.atom_assgn (.order …)` | L | M | **Defeq** at successor depth. Supply directly; insert `show`/`change` if `exact` balks. No re-proof. |
| Accidental `SharedWitness.lean` / `SubBracket2V.lean` edit (breaks 341's frozen-file gate) | H | L | All 335 code lives in `OuterGate.lean`. `git status` gate in Phase D confirms both files byte-unchanged. |
| Vacuous close typechecks green but proves nothing | H | L | Grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`, `:= True`, `:= trivial`. Green + vacuous is a FAILURE. |
| `hfrag` smuggled in as a provider-conditional family rather than a pure `qnf` restriction | H | L | Checklist item: `hfrag : kvE2_sepFragment qnf` must depend ONLY on `qnf` (its shape/positivity/zones), never on `M`, `atomMap`, `P`, or a realized type. Inspect the predicate signature in Phase A. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2, 3 | -- (landed; completed carryover) |
| 1 | A | 3 (same-file sequencing) |
| 2 | B, C | A (both consume the `_frag` shells + `hfrag`; B and C are independent obligations — interior gates vs. boundary/exclusion) |
| 3 | D | B, C |

All phases edit only `OuterGate.lean`. 335 and 341 do not run concurrently (H7); SharedWitness.lean
stays frozen. Phases sized to one agent dispatch each.

### Phase 1: Live wrapper def + `rfl` bridge [COMPLETED]

**Delivered** (verified against source, on disk, green):
- `bracketEndChar_kvE2` (`OuterGate.lean:62`): `noncomputable def` producing `BracketEndCharCarrierV
  sig 2`, delegating to `kvE2_sepBody (nf_depth0_char_formula …) (fun χ => P.existF 0 χ)`.
- `bracketEndChar_kvE2_two_eq` (`OuterGate.lean:73`): the `rfl` bridge exposing `kvE2_sepBody`.
- Aggregator import (`NfMultiAnchorBridge.lean:39`).

Completed carryover from v4 — preserved as-is; do NOT re-do.

---

### Phase 2: ⇐ completeness half — consume `kvE2_sepBody_holds_of_honest` [COMPLETED]

**Delivered**: `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:139`, sorry-free,
axiom-clean `{propext, Classical.choice, Quot.sound}`), plus helper bridges
`bracketEndChar_kvE2_hcb` / `bracketEndChar_kvE2_hck`. UNCONDITIONAL (no `hL`/`hLR`). Phase D's
`_frag` correctness theorem reuses this ⇐ direction unchanged (the fragment restriction gates only
the ⇒ half).

Completed carryover from v4 — preserved as-is; do NOT re-do.

---

### Phase 3: Retire the stale in-source BLOCKED framing + citation hygiene [COMPLETED]

**Delivered** (committed `5689db302`): replaced the `OuterGate.lean:172-201` BLOCKED note with an
accurate status; stated the fold's four-family requirement inline with `file:line`; purged the
dangling `md:297` cite (`grep -c "md:" OuterGate.lean` = 0; new note page-cites Rabinovich only).
SharedWitness.lean byte-unchanged.

Completed carryover from v4 — preserved as-is; do NOT re-do. (Phase D re-touches only the
delivered-items 4/5 docstring to record the `_frag` deliverables.)

---

### Phase A: Single-positive-sub fragment predicate + `_frag` statement surgery [COMPLETED]

**Delivered** (committed, green, no sorry): `kvE2_sepFragment` (`OuterGate.lean`) —
`∃ σ0, kvE2_sepPos qnf = [σ0] ∧ (nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3)`. Depends only
on `qnf` (family-smuggling guard satisfied). The `_frag` sound shell was stated and its fold
reduction verified to typecheck (six order bits unify defeq `qnf.atom_assgn = qnf.1`); it is NOT
committed because its body cannot be discharged (see Phase B blocker).

**Goal**: Define the fragment predicate `kvE2_sepFragment qnf` and introduce the `_frag` theorem
statements in `OuterGate.lean` ONLY. The fragment hypothesis enters as a **qnf restriction**
(sanctioned by task 321 verdict N2). No `SharedWitness.lean` edits. `sorry`-free by stating only
(the shells carry the obligations Phases B/C/D discharge).

**Tasks**:
- [ ] Define `kvE2_sepFragment (qnf : NormalForm sig 2 3) : Prop`. **Default form (decision to
      record): "exactly one positive sub, interior-zoned"** — the strongest residue-vanish guarantee
      per O4 (SW:6785-6791):
      ```
      def kvE2_sepFragment (qnf : NormalForm sig 2 3) : Prop :=
        ∃! σ, σ ∈ kvE2_sepPos qnf   -- exactly one positive sub
        -- + zone side-condition: nf0_zoneSpec σ.1 is interior (kvE2_sep_zXW3 / kvE2_sep_zWT3)
      ```
      The predicate depends ONLY on `qnf` (its positivity + zone structure) — never on `M`,
      `atomMap`, `P`, or a realized type. Confirm this by inspection (a family-smuggling guard).
- [ ] State the `_frag` shells with `hfrag : kvE2_sepFragment qnf` as an ordinary hypothesis, the
      six order bits + `h_UZ`/`h_SZ` + `x t` as the provider shape (unchanged from the k≤1 lift),
      and NO provider-conditional family in the signature:
      ```
      theorem bracketEndChar_kvE2_sound_two_prior_frag …
        (hfrag : kvE2_sepFragment qnf) :
        (bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t
          → ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
      theorem bracketEndChar_kvE2_correct_two_prior_frag …
        (hfrag : kvE2_sepFragment qnf) :
        BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 atomMap h_surj P) qnf  -- fragment-restricted
      ```
      Body may be `sorry` at Phase A (shells only) — but the shells must TYPECHECK (signatures
      well-formed). Record which downstream obligations each shell leaves.
- [ ] Confirm the shells compile with the placeholder body via `lean_diagnostic_messages` (only the
      `sorry` warning, no type errors). Do NOT commit a `sorry` as a green milestone — Phase A's
      green commit is the fragment predicate `def` + the well-typed shells; if a temporary `sorry`
      body is used to typecheck, it is replaced (not committed on a live path) in Phases B-D.

**Decision to record explicitly** (Phase A output): the exact `kvE2_sepFragment` form chosen
(default: exactly-one-interior-positive) and, if a weaker form is chosen, why (and what extra
`hbdry` probe Phase C then owns).

**Timing**: 1-1.5 hours. **Depends on**: 3 (same-file sequencing).

**Files to modify**: `OuterGate.lean` (fragment predicate `def` + `_frag` theorem shells).

**Verification**:
- `kvE2_sepFragment` depends only on `qnf` (no `M`/`atomMap`/`P` in its signature).
- The two `_frag` shells typecheck; no provider-conditional family in either signature; `hfrag` is
  the sole added hypothesis beyond the provider shape.
- `SharedWitness.lean` / `SubBracket2V.lean` byte-unchanged (`git status`).

---

### Phase B: Discharge `hgateL` / `hgateR` under `hfrag` [COMPLETED]

**RESOLVED post-345** (2026-07-10, session sess_1783723095_edd5a7_335): the pre-345 blocker below is
superseded. Task 345 landed the symmetric gate (Rabinovich Cor 5.4, clause (v)), dissolving `hInnerR`
and delivering the pin-anchored fold `kvE2_outer_fold_frag` (`SharedWitness.lean:12529`) whose only
obligations beyond the provider shape are `hfrag` + `hcorrK` + `hexcl`. The interior gates
`hgateL`/`hgateR` and the non-interior `hbdry` are now internal to the fold (discharged inside
`kvE2_sepBody_kit_sound_frag` SW:12487 under `hfrag`). 335 Phase B landed
`bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean`, green, axiom-clean
`{propext, Classical.choice, Quot.sound}`): it discharges `hcorrK` inline via
`bracketEndChar_kvE2_hck.mp` and threads `hexcl` as a hypothesis (Phase C proves it, Phase D removes
it). `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged. The FORWARD-conjunct wall that blocked
the pre-345 attempt no longer exists on this path — the symmetric gate makes it a gate consequence.

<details><summary>Pre-345 blocker (historical — superseded by the symmetric gate)</summary>

**BLOCKER** (Phase B — recorded after a genuine machine attempt; territory-guard STOP):
- **What failed**: The interior-LEFT gate family `hgateL` cannot be produced under `hfrag`. After the
  fold reduction (typechecks) and reducing to the sole `σ = σ0`, the six-conjunct split leaves three
  underivable residuals (captured verbatim via `lean_goal`, transcripts in `handoffs/02_continuation.md`):
  (1) `a < w` for an arbitrary fresh-atom anchor `a`; (2) `nf_eval_nf M 0 4 [a,w,x,t] σ.1` (full base
  from only the fresh projection `hanchor`); (4) FORWARD `∀ zs χ, (∃ v, zoneHolds … ∧ nf_eval χ) →
  σ.2 (nf0_assemble zs χ σ.1) = true`.
- **What was tried**: Set up `refine kvE2_outer_fold … ?hgateL ?hgateR ?hbdry ?hexcl`; `hbdry`
  DISCHARGED (vacuous — every positive equals interior `σ0`, contradicting non-interior antecedent);
  `hgateL` reduced and split; exhaustive public-API search for a FORWARD-clause producer (none —
  `σ.2 (nf0_assemble …) = true` appears only as a HYPOTHESIS across the fold/kit/`SubBracket2V`
  signatures, never a conclusion); confirmed `kvE_subBracket2V_sound_of_outer`/`_of_parts`/
  `kvE2_sepBundleL_sound` all CONSUME the full `hgate` (with FORWARD), never produce it; confirmed
  `kvE2_sepBody_extract` discards the segment content.
- **Why it's stuck**: The only exclusion channel `kvE2_sepSegForm_excludes` (SW:6683) fires only where
  the segment form HOLDS at the witness `v`; that segment content lives inside the frozen
  `kvE2_sepDisjunct'` and is not exposed by any public extractor. Reaching it to close conjuncts
  1/2/4 requires NEW lemmas in `SharedWitness.lean` — branch (a), adjudicated REFUTED (report 04),
  and prohibited by 341's frozen-file gate. The O4 residue-vanish (SW:6785-6791) is a Phase-10
  ROUTING verdict certifying the CROSS-σ residue vanishes for one positive; it is NOT a landed
  derivation, and formalizing "every witness is σ0's own bit-true slot or a segment-covered point"
  still needs the frozen segment structure. `bracketEndChar_kv_factors` (`CarrierKv.lean:422`)
  machine-certifies the (outer zone, projected 1-type) information ceiling.
- **What is needed**: Either (i) a public segment-coverage / FORWARD-clause producer landed in
  `SharedWitness.lean` under a single-positive hypothesis (a 333/SharedWitness-territory task — the
  frozen-file gate must be renegotiated), or (ii) the SUCCESSOR carrier re-definition
  (bit-compatibility filtering, O4 SW:6763-6770). Both are outside 335's OuterGate-only territory.
- **Prohibited workarounds**: NOT applied — no `SharedWitness.lean` edit, no `sorry`, no vacuous
  close, no assumed/provider-conditional family hypothesis.

</details>

**Goal** (historical): Build the two interior LEFT/RIGHT per-σ gate families in the exact shape
`kvE2_outer_fold` expects (SW:9911-9945), **under `hfrag`**. With one interior positive the cross-σ
residue VANISHES (O4 record SW:6785-6791) — the FORWARD clause that was refutable over arbitrary
`qnf` becomes derivable because there are no cross-σ slot points.

**Tasks**:
- [ ] From `hfrag` extract the sole interior positive σ0 and the emptiness of the cross-σ slot-point
      class. This is the structural fact O4 SW:6785-6791 records; use it to collapse the FORWARD
      clause of `hgateL`/`hgateR` (the plan-v4 wall) to the residue-vanish case.
- [ ] Discharge `hgateL` (6-conjunct interior LEFT geometry excluding `kvE_sub2_zXU`, verbatim
      SW:9911-9928) via `kvE_subBracket2V_sound_of_outer` (`SubBracket2V.lean:1216`) +
      `kvE_sub2V_bounded_anchor_of_outer` (`:1182`) + the O4 derivable core (five conjuncts already
      derivable, SW:6700-6706: `kvE2_sep_zone4_consistent`, `kvE2_sepHgate_offFiber`,
      `kvE2_sepHgate_innerNine`, `kvE2_sepSegForm_excludes`, biconditional endpoint/witness literals).
- [ ] Discharge `hgateR` (4-conjunct interior RIGHT geometry excluding `kvE2_sep_zWX1`, verbatim
      SW:9929-9945) via the same landed composition. The L/R geometries genuinely differ — do NOT
      copy one to the other; confirm each `have` type with `lean_goal` before wiring.
- [ ] Any ordering-touching step uses the PRIMED `kvE2_sepHonestOrder'` (SW:5974) only (337 report
      14). Witness bounds read from the bracket range, not a chain (LITMUS `NavigatedSpine.lean:437`).
- [ ] **Territory guard**: if the landed `SubBracket2V.lean:1216`/`:1182` + O4 core cannot produce
      the exact fold shape under `hfrag`, STOP — do NOT edit SharedWitness.lean (branch (a) is
      REFUTED; there is no reshape that helps). Capture the goal and fold this into the Phase C
      GO/NO-GO report (the fragment route is then at risk).

**Timing**: 2-4 hours (the main derivation work). **Depends on**: A. Independent of C.

**Files to modify**: `OuterGate.lean` (`hgateL`/`hgateR` `have`s, or private helpers
`bracketEndChar_kvE2_hgateL_frag` / `_hgateR_frag`).

**Verification**:
- `hgateL`/`hgateR` typecheck against the `kvE2_outer_fold` argument positions (`lean_goal`);
  sorry-free; primed order only; no interiority hypothesis (the restriction rides `hfrag` on `qnf`,
  not a guard on realized types).
- `SharedWitness.lean` / `SubBracket2V.lean` byte-unchanged.
- Commit as an incremental green milestone once both families close.

---

### Phase C: `hbdry` / `hexcl` GO/NO-GO probe under `hfrag` — ONE DISPATCH, BOUNDED [BLOCKED]

**NOT REACHED** — gated on Phase B, which is BLOCKED (the fold's four families are a single
obligation set; `hgateL`'s FORWARD conjunct fails with no public producer). `hbdry` was in fact
DISCHARGED during the Phase-B attempt (vacuous under `hfrag`), but `hexcl` (the designated genuine
risk) is downstream of the SAME frozen-segment-content gap: excluding every negative sub also rides
`kvE2_sepSegForm_excludes` + the disjunct's segment coverage, unreachable via the public API. The
fragment route is therefore NO-GO for the interior-gate obligation, ahead of the `hexcl` probe.

**Goal**: Discharge the non-interior positive realization family `hbdry` (SW:9946) and the
negative-sub exclusion family `hexcl` (SW:9952) **under `hfrag`**. In the exactly-one-interior-positive
fragment, `hbdry`'s non-interior positive class is empty (or trivially bounded) — verify. `hexcl`
under the fragment is **plausible but UNPROBED**: exclusion content rides `kvE2_sepSegForm_excludes`
+ the landed Prop 4.2 negation closure (`neg_2var_vec_ea`, `EANegationClosure.lean:722`), but the O4
record adjudicates the *interior gate* residue only — it does NOT pre-certify exclusion. **This
phase is EXPLICITLY one-dispatch bounded: on NO-GO it STOPS and reports — escalate, do not thrash.**

**Tasks**:
- [ ] `hbdry` under `hfrag`: in the exactly-one-interior-positive fragment the non-interior positive
      class is empty (from `hfrag`'s `∃!` + interior zone side-condition) → the family is
      vacuously/trivially satisfied. Discharge and confirm with `lean_goal`. If the chosen fragment
      admits non-interior positives (a weaker Phase-A form), this needs the O4/`SubBracket2V` route
      instead — fold into the same probe.
- [ ] `hexcl` under `hfrag`: for σ with `qnf.2 σ = false`, produce `∀ x1, ¬ nf_eval_nf M 1 4
      [x1,w,x,t] σ`. Attempt via `kvE2_sepSegForm_excludes` + Prop 4.2 closure `neg_2var_vec_ea`
      (`EANegationClosure.lean:722`) restricted by `hfrag`. Confirm each `have` with `lean_goal`;
      LITMUS-clean; primed order only.
- [ ] **GO** (both close): commit as an incremental green milestone; proceed to Phase D.
- [ ] **NO-GO** (`hexcl` or `hbdry` does not close from the fragment evidence): STOP immediately —
      do NOT assume the family, do NOT `False.elim`/vacuous-close, do NOT add a provider-conditional
      hypothesis, do NOT open a second probe dispatch (no thrashing). Capture the exact residual goal
      (`lean_goal` transcript) + the failed-closer list (F4/O4 evidence style). Classify via
      `bracketEndChar_kv_factors` (`CarrierKv.lean:422`): a NO-GO here means the fragment route is
      exhausted and the only remaining path is the SUCCESSOR carrier re-definition
      (bit-compatibility filtering — O4 record SW:6763-6770). Mark Phase C `[BLOCKED]`, write the
      NO-GO report into the task's handoff, and escalate to the user. `OuterGate.lean` is left at its
      Phase-B-green state.

**Timing**: 1-2 hours (bounded to one dispatch by construction). **Depends on**: A. Independent of B.

**Files to modify**: `OuterGate.lean` (`hbdry`/`hexcl` `have`s or private helpers
`bracketEndChar_kvE2_hbdry_frag` / `_hexcl_frag`).

**Verification**:
- **GO**: both families typecheck against the fold argument positions; sorry-free; no assumed
  family; no vacuous close; primed order; LITMUS-clean; `SharedWitness.lean`/`SubBracket2V.lean`
  byte-unchanged.
- **NO-GO**: Phase C is `[BLOCKED]` with a captured goal + channel diagnosis + explicit
  fragment-exhaustion classification; no `sorry`/vacuous placeholder committed; `OuterGate.lean`
  left at Phase-B-green; user escalation issued. This is a legitimate terminus for the dispatch —
  not a failure to retry.

---

### Phase D: Assemble `bracketEndChar_kvE2_correct_two_prior_frag` + 309-v8 handoff note [BLOCKED]

**NOT REACHED** — gated on Phases B AND C (both BLOCKED). No `_frag` correctness theorem is
assembled; `bracketEndChar_kvE2` remains at Phase-A-green (live def + `rfl` bridge + Phase-2 ⇐
completeness + fragment predicate). The 309-v8 impact is: the k=2 fragment GO gate is NOT delivered
— 309 Phases 13.4/14 and `KampPrior.lean:351` cannot yet consume a `bracketEndChar_kvE2_correct_two_prior_frag`.

**Goal**: With Phases B and C green, discharge the `_frag` shells: feed `kvE2_outer_fold` the four
families (from B and C, all under `hfrag`) to close `bracketEndChar_kvE2_sound_two_prior_frag`, then
assemble both directions into `bracketEndChar_kvE2_correct_two_prior_frag`. Finalize the docstring
and write the 309-v8 handoff note.

**Tasks**:
- [ ] Close `bracketEndChar_kvE2_sound_two_prior_frag`: `intro h_holds`;
      `rw [bracketEndChar_kvE2_two_eq] at h_holds`; `refine kvE2_outer_fold … h_holds hgateL hgateR
      hbdry hexcl` with the four families from B/C. Bridge `qnf.atom_assgn (.order …)` →
      `qnf.1 (.order …)` via `show`/`change` if `exact` balks (defeq). No residual side-goals; no
      `sorry`.
- [ ] Close `bracketEndChar_kvE2_correct_two_prior_frag`: unfold the (fragment-restricted)
      `BracketCarrierCorrectVPrior`, `intro` the six order hypotheses + `h_UZ`/`h_SZ` + `x t`, then
      `constructor` combining the ⇒ (Phase-D sound, under `hfrag`) and ⇐ (Phase 2 complete, unchanged
      — the fragment gates only ⇒) directions. Mirror `bracketEndChar_kv_correct_one_prior`
      (`PriorInterface.lean:100`), with `hfrag` threaded to the ⇒ half only.
- [ ] `#print axioms bracketEndChar_kvE2_correct_two_prior_frag` via `lake env lean` (NOT
      `lean_verify` — unreliable on SharedWitness.lean, stale `sorryAx`) → `{propext,
      Classical.choice, Quot.sound}`, no `sorryAx`.
- [ ] Finalize the `OuterGate.lean` header docstring (delivered items 4/5): record
      `bracketEndChar_kvE2_sound_two_prior_frag` and `bracketEndChar_kvE2_correct_two_prior_frag` as
      DELIVERED (fragment-scoped); note the multi-positive case deferred to the named successor task.
      Page-cite only.
- [ ] **Write the 309-v8 handoff note** (`specs/335_.../handoffs/02_frag-gate-for-309-v8.md`)
      recording precisely: (1) the fragment gate `bracketEndChar_kvE2_correct_two_prior_frag`
      provides the k=2 GO gate for **309 Phases 13.4/14** and **`KampPrior.lean:351`** *under
      `kvE2_sepFragment qnf`*; (2) the fragment hypothesis is a qnf-domain restriction 321-N2
      sanctions (provider shape unchanged, so 309's provider-unconditional requirement is met in the
      provider sense); (3) 309 v8 re-points Phase 13.4/14 to the `_frag` theorem and fragment-scopes
      the `KampPrior.lean:351` discharge; (4) the multi-positive case stays DEFERRED to the named
      successor task (bit-compatibility filtering carrier re-definition, O4 SW:6763-6770); (5) flag
      for 309's reviser: whether the ∀k lift (`KampPrior` `Nat.rec`) composes with a fragment-scoped
      k=2 rung without further statement surgery.
- [ ] `git status` confirms only `OuterGate.lean` (+ the handoff note) changed; `SharedWitness.lean`
      / `SubBracket2V.lean` byte-for-byte unmodified. `lake build …OuterGate`, then full `lake build`.

**Timing**: 1-1.5 hours. **Depends on**: B AND C (both green). Halted if C is NO-GO.

**Files to modify**: `OuterGate.lean` (assemble `_frag` theorems + docstring); new handoff note
`specs/335_.../handoffs/02_frag-gate-for-309-v8.md`.

**Verification**:
- `bracketEndChar_kvE2_sound_two_prior_frag` and `_correct_two_prior_frag` compile sorry-free;
  `hfrag` is the sole restriction beyond the provider shape; no provider-conditional family in
  either signature; consume `kvE2_outer_fold` unmodified.
- `#print axioms …_correct_two_prior_frag` axiom-clean, no `sorryAx`.
- Full `lake build` green; 309-v8 handoff note written.
- `SharedWitness.lean` / `SubBracket2V.lean` byte-unchanged (341's frozen-file gate intact).

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate` succeeds after
      each phase; full `lake build` green at the end.
- [ ] **Axiom check via `#print axioms` (NOT `lean_verify`)**: every delivered `_frag` declaration
      through `lake env lean` returns `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
      `lean_verify` is UNRELIABLE on `SharedWitness.lean` (stale LSP `sorryAx`).
- [ ] **Fragment hypothesis is a pure `qnf` restriction**: `kvE2_sepFragment` depends only on `qnf`;
      `hfrag` never smuggles `M`/`atomMap`/`P`/a realized type.
- [ ] **No assumed provider-conditional family**: `hbdry`/`hexcl`/`hgateL`/`hgateR` appear ONLY as
      proved local `have`s / private helpers, never as hypotheses on the `_frag` theorems. `hfrag`
      is the ONLY sanctioned added hypothesis.
- [ ] **No vacuous close**: grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`,
      `:= True`, `:= trivial`. Green + vacuous is a FAILURE.
- [ ] **No interiority hypothesis**: no `hL`/`hLR`/realized-type interior guard in any delivered
      signature (refuted by `kvE2_sepHonest_hLR_absurd`, SW:5714).
- [ ] **Primed order only**: no live path consumes `kvE2_sepModelOrder` (SW:1476) or unprimed
      `kvE2_sepHonestOrder` (SW:3891); ordering rides `kvE2_sepHonestOrder'` (SW:5974).
- [ ] **LITMUS (`NavigatedSpine.lean:437`)**: no `x1 < e_i` relative-position literal on any live
      path; witness bounds come from the bracket range.
- [ ] **Citation hygiene**: `grep -n "md:" OuterGate.lean` = 0; Rabinovich page-cited; O4
      residue-vanish cites SW:6785-6791 by line.
- [ ] **Territory (H7) / 341 frozen-file gate**: `SharedWitness.lean`, `SubBracket2V.lean`, and all
      334/337/342 files byte-for-byte unmodified (`git status`); only `OuterGate.lean` (+ the handoff
      note) changed. NO SharedWitness reshape anywhere in this plan.
- [ ] `bracketEndChar_kvE2_two_eq` remains a genuine `rfl` bridge (unchanged from Phase 1).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — extended:
  fragment predicate `kvE2_sepFragment` + `_frag` theorem shells (Phase A); `hgateL`/`hgateR` under
  `hfrag` (Phase B); `hbdry`/`hexcl` GO/NO-GO under `hfrag` (Phase C); assembled
  `bracketEndChar_kvE2_sound_two_prior_frag` + `bracketEndChar_kvE2_correct_two_prior_frag` +
  finalized docstring (Phase D). (Phase 1 def + `rfl` bridge, Phase 2 completeness lemma, Phase 3
  corrected note already present.)
- `specs/335_outer_gate_assembly_engine_kvE2_body/plans/05_fragment-gate-v5.md` (this file);
  supersedes `plans/04_outer-gate-post-333-v4.md`.
- `specs/335_outer_gate_assembly_engine_kvE2_body/handoffs/02_frag-gate-for-309-v8.md` (Phase D — the
  309-v8 handoff note).
- `specs/335_outer_gate_assembly_engine_kvE2_body/summaries/05_fragment-gate-summary.md` (on
  completion).
- **Deferred successor task (NOT this task)**: multi-positive case — bit-compatibility filtering
  carrier re-definition with O1b/O2/O3 rework (O4 record SW:6763-6770). Create as a NEW task when 335
  lands; do NOT fold into 335 or 341.
- **Follow-on task (R-B, NOT this task)**: wire `bracketEndChar_kvE2` +
  `bracketEndChar_kvE2_correct_two_prior_frag` into `KampPrior.lean:351`.
- **Unblocks (downstream)**: task 309 (consumes the fragment gate at Phase 13.4/14; requires a v8
  revision to re-point off the retired `kvE'`) and task 341 (`SharedWitness.lean` refactor — the
  fragment route keeps SharedWitness.lean frozen, so 341's Phase-3 gate becomes EASIER to certify).

## Rollback/Contingency

- All 335 work is additive and isolated to `OuterGate.lean`. To revert new phases: `git checkout`
  `OuterGate.lean` to its Phase-3 state; the tree returns to the current landed state (⇐ half + def
  + bridge + corrected note) with all carrier/soundness INPUTS untouched.
- **If Phase C is NO-GO** (`hexcl`/`hbdry` do not close under `hfrag`): follow the mandatory bounded
  branch — capture the goal, classify via `bracketEndChar_kv_factors` (fragment exhausted → only the
  successor carrier re-definition remains), mark Phase C `[BLOCKED]`, write the NO-GO handoff, STOP,
  and escalate to the user. Do NOT thrash across more dispatches, assume the family, close vacuously,
  or edit `SharedWitness.lean`. Phases A and B (both independent of C) remain landed green.
- **If the fragment predicate (Phase A) proves unusable by 309**: this is a scope-alignment issue,
  not an implementation retry — coordinate the exact `kvE2_sepFragment` form with 309's v8 reviser
  before proceeding to B/C. The default (exactly-one-interior-positive) matches 321-N2's declared
  scope; deviate only with recorded justification.
- **Do NOT re-attempt branch (a) (SharedWitness reshape) or branch (b-strengthen) (higher-arity
  `charK`)** — both adjudicated REFUTED (report 04). Never edit `SharedWitness.lean`, never commit a
  bare `sorry`, an assumed family, a vacuous close, or an interiority hypothesis.
