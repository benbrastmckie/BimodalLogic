# Implementation Plan: Task #335 — Outer-Gate Assembly Engine (`kvE2_body` / `bracketEndChar_kvE2`) — ⇒ Soundness Half over the LANDED `kvE2_outer_fold` (v4, post-333)

- **Task**: 335 - Build the outer-gate assembly engine `kvE2_body` / `bracketEndChar_kvE2`, the two-level quant-layer connector that `KampPrior.lean:351` (the depth-k≥2 Cor 5.4 converter) consumes
- **Status**: [IMPLEMENTING]
- **Effort**: 4-6 hours (⇒ half + assembly; Phases 1-2 already landed; the genuine risk is Phase 4b `hbdry`/`hexcl` discharge)
- **Dependencies**:
  - 334 (COMPLETED — faithful carrier redefinition `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`)
  - 337 (COMPLETED — `kvE2_sepBody_holds_of_honest` completeness engine, consumed by the landed Phase 2)
  - 342 (COMPLETED — interior-restricted owner index `kvE2_sepPosI`, tie-admitting weak orders, `hLR` deletion)
  - **333 (COMPLETED — `ff54d45c5`)** — landed `kvE2_outer_fold` (`SharedWitness.lean:9897`, green, axiom-clean) plus the extraction/kit lemmas (`kvE2_sepBody_extract`, `kvE2_sepBundleL/R_parts`, `kvE2_sepBody_kit_sound`). The prior "EXTERNAL prerequisite: wait for 333" gate is **retired** — the wait is over. 335 CONSUMES these lemmas; H7 territory still holds (333 owns `SharedWitness.lean`, 335 owns `OuterGate.lean`).
- **Research Inputs**:
  - specs/335_outer_gate_assembly_engine_kvE2_body/reports/03_plan-currency-check-post-333.md (**AUTHORITATIVE post-333 currency check** — establishes that `kvE2_outer_fold` is landed but takes FOUR provider-conditional families `hgateL`/`hgateR`/`hbdry`/`hexcl` that 335 must construct/discharge, NOT a thin wrapper; the `hbdry`/`hexcl` discharge at `P.existF 0` is the residue of the 309 F3/F4 obstruction and is the make-or-break)
  - specs/333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/reports/03_pdf-fidelity-r3-dissolved-regrounding.md (CONFIRMED, H4-verified — the forward-zone `hgate` conjunct is antecedent-only; the O4 crux record is inert; citation rule: Rabinovich by PDF page only)
  - specs/335_outer_gate_assembly_engine_kvE2_body/reports/01_outer-gate-assembly-engine.md (original research; carrier/interface grounding — line numbers superseded post-334/342/333)
  - specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/13_rxw-faithfulness-audit.md (CONFIRMED — pivot/faithfulness constraints on `.rXW`)
  - specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/14_tie-class-semantics-audit.md (CONFIRMED — primed order `kvE2_sepHonestOrder'` is the only correct order)
- **Artifacts**: plans/04_outer-gate-post-333-v4.md (this file); supersedes plans/03_soundness-half-consume-333-lemmas.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; lean4.md; literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is **plan v4**, a revision of plan v3 forced by task 333 landing (`ff54d45c5`) after v3 was
written. v3's core premises are **confirmed current** (report 03): the deleted symbols really are
gone, the live carrier is the faithful `kvE2_sepArr'`/`kvE2_sepBody`, the ⇐ completeness half is
landed at `OuterGate.lean:139`, and Phase 3 comment hygiene is still valid and independent. **All of
that grounding is PRESERVED here.**

**What v3 got wrong: Phase 4 was materially UNDER-SCOPED as a "thin wrapper".** The actual landed
`kvE2_outer_fold` (`SharedWitness.lean:9897`) does NOT yield `intro h; rw [two_eq]; apply
kvE2_outer_fold`. Its real signature (verified against HEAD) takes **four provider-conditional
hypothesis families** that task 333 deliberately punted to the 335 provider instantiation and did NOT
discharge:

- `hgateL` / `hgateR` (SW:9911 / 9929) — the interior LEFT/RIGHT per-σ gate families for the
  `kvE2_sep_zXW3` / `kvE2_sep_zWT3` interior zones. Internally the fold feeds these to
  `kvE2_sepBody_kit_sound` (SW:9787, called at SW:9959-9960).
- `hbdry` (SW:9946) — non-interior positive realization: `∀ w, x<w → w<t → …ptW… → ∀ σ ∈ kvE2_sepPos qnf,
  ¬(zXW3 ∨ zWT3) → ∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ`.
- `hexcl` (SW:9952) — negative-sub exclusion: `∀ w, x<w → w<t → …ptW… → ∀ σ, qnf.2 σ = false →
  ∀ x1, ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ`.

`BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) does NOT carry `hbdry`/`hexcl` as
hypotheses — it supplies only the six order bits + `h_UZ`/`h_SZ` + `x t`. So at the instantiation
`charK := fun χ => P.existF 0 χ` task 335 must **PROVE all four families**, not thread them. This is
the substantive gap v3 missed. Phase 4 is therefore re-scoped into 4a/4b/4c with an explicit
escalation branch on 4b, per report 03's recommendation.

**Deliverables** (the k=2 N2-C gate, `PriorInterface.lean:60`):
- `bracketEndChar_kvE2_sound_two_prior : (bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t
  → ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` (UNCONDITIONAL — no `hL`/`hLR`).
- `bracketEndChar_kvE2_correct_two_prior : BracketCarrierCorrectVPrior atomMap
  (bracketEndChar_kvE2 atomMap h_surj P)` — mirroring the landed k≤1 lift
  `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:100`). This is the exact
  `BracketCarrierCorrectVPrior` GO gate that task 309 is blocked waiting for.

The work is confined to `OuterGate.lean` (aggregator import present, `NfMultiAnchorBridge.lean:39`).
The 334/342 carrier and 333's soundness lemmas are **verified INPUTS** — only applied, never edited.

### Verified interface facts (checked against HEAD, do not re-derive)

| Symbol | Location | Role in this plan |
|---|---|---|
| `kvE2_outer_fold` | `SharedWitness.lean:9897` | LANDED. Consumed by Phase 4c. Takes six order bits (`qnf.1 (.order …)`), `M`, `x t`, `h`, `hgateL`, `hgateR`, `hbdry`, `hexcl` → `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`. |
| `kvE2_sepBody_kit_sound` | `SharedWitness.lean:9787` | Called internally by the fold; defines the exact `hgateL`/`hgateR` shapes Phase 4a must build. |
| `kvE2_sepBody_extract` | `SharedWitness.lean:8410` | Produces the interior `kvE2_sepBundleL/R` bundles for Phase 4a. |
| `kvE2_sepBundleL_parts` / `kvE2_sepBundleR_parts` | `SharedWitness.lean:5379` / `5396` | Per-σ kit feeding `kvE_subBracket2V_sound_of_parts` in Phase 4a. |
| `kvE_subBracket2V_sound_of_parts` | `SubBracket2V.lean:1290` | Per-σ interior realization sound-of-parts (Phase 4a). |
| `kvE_subBracket2V_sound_of_outer` | `SubBracket2V.lean:1481` | Composition pattern the fold docstring cites for the non-interior/exclusion families (relevant to Phase 4b). |
| `ExistProviders` (`existF`, `correct`) | `PriorInterface.lean:38` | `correct : temporal_truth M atomMap t (existF n sub) ↔ ∃ env : Fin n → M.carrier, nf_eval_nf M k (n+1) (insertEnv env t) sub`. The tool for Phase 4b. |
| `BracketCarrierCorrectVPrior` | `PriorInterface.lean:60` | k=2 target; at successor depth the `qnf.atom_assgn (.order …)` order bits are **defeq** to the fold's `qnf.1 (.order …)` bits. |
| `bracketEndChar_kv_correct_one_prior` | `PriorInterface.lean:100` | The k=1 lift Phase 5's `_correct_two_prior` mirrors. |
| `bracketEndChar_kv_factors` | `CarrierKv.lean:422` | The machine-checked (outer zone, projected 1-type) information-loss record — the A1-sense conditionality boundary relevant to Phase 4b's escalation decision. |
| `bracketEndChar_kvE2` / `_two_eq` | `OuterGate.lean:62` / `73` | Live def + `rfl` bridge (Phase 1, landed). Delegates to `kvE2_sepBody (nf_depth0_char_formula …) (fun χ => P.existF 0 χ)`. |
| `bracketEndChar_kvE2_complete_two_prior` (+ `_hcb`/`_hck`) | `OuterGate.lean:139` (+ `94`/`115`) | ⇐ half (Phase 2, landed). Signature shape Phase 4c/5 mirror. |

### Research Integration (newly integrated in plan v4)

- **335 report 03 (`03_plan-currency-check-post-333.md`, AUTHORITATIVE)**: the load-bearing new
  finding — `kvE2_outer_fold` is landed but relocated `hbdry`/`hexcl` out of 333's scope and into
  335's provider instantiation rather than discharging them. So "can the faithful carrier discharge
  exclusion at `P.existF 0`?" is **still open** and now lives in 335 Phase 4b. This report drives the
  4a/4b/4c re-scope and the mandatory escalation branch. It also confirms Phase 3 (comment hygiene) is
  safe to land immediately, and that 335 is on the critical path for both 309 (unblock) and 341
  (refactor, which must NOT start until 335's `OuterGate.lean` work completes).
- **Preserved from v3**: 333 report 03 (O4 crux DISSOLVED / antecedent-only conjunct — retires the
  in-source BLOCKED framing), 337 reports 13/14 (`.rXW` faithfulness, primed order guardrail). All
  remain binding.

### Citation rule (binding — carried into every phase)

Cite the Rabinovich source **by PDF page** (`p.N`), never `md:NN`. The markdown paraphrase drops every
displayed equation and inverts `k≠m`→`k=m`; every `md:NN` anchor dangles. For **Lemma 3.2** use the
mandated form: *"the construction forced by Def 3.1 (p.4), corroborated by the k=m split (p.7) and Def
7.5 (p.13); Lemma 3.2(1) (p.4) states the closure without printed proof."* The dangling `md:297` cite
in a prior 335 artifact is purged/re-grounded in Phase 3.

## Goals & Non-Goals

**Goals**:
- Preserve the landed ⇐ completeness (`bracketEndChar_kvE2_complete_two_prior`, Phase 2) and Phase 1
  live def + `rfl` bridge — do not re-plan or re-touch them.
- Correct the stale in-source BLOCKED framing (`OuterGate.lean:172-201`) and re-ground the dangling
  `md:297` cite (Phase 3) — 335's own file, within territory, independent of the ⇒ half.
- Construct the four provider-conditional families the LANDED `kvE2_outer_fold` requires and prove
  **⇒ soundness** `bracketEndChar_kvE2_sound_two_prior`, split into:
  - Phase 4a — `hgateL`/`hgateR` (interior gates) from `kvE2_sepBody_extract` + the per-σ kit.
  - Phase 4b — `hbdry`/`hexcl` at `charK := P.existF 0` from `ExistProviders.correct` + `h_UZ`/`h_SZ`,
    **with a mandatory escalation branch** if they do not close from provider correctness alone.
  - Phase 4c — wrap into `bracketEndChar_kvE2_sound_two_prior` via `rw [bracketEndChar_kvE2_two_eq]` +
    `kvE2_outer_fold` fed the four families.
- Assemble both directions into the **UNCONDITIONAL** `k = 2` gate-correctness theorem
  `bracketEndChar_kvE2_correct_two_prior`, mirroring `bracketEndChar_kv_correct_one_prior`; finalize
  the `OuterGate.lean` scope docstring (Phase 5).
- Preserve F1-F7 and the LITMUS (`NavigatedSpine.lean:437`): no `x1 < e_i` relative-position literal
  on any live path; witness bounds come from the bracket range, never a chain.

**Non-Goals**:
- **Do NOT edit `SharedWitness.lean`, `SubBracket2V.lean`, or any 333/334/342 carrier input** (H7:
  333's territory; verified INPUTS). 335 owns `OuterGate.lean` only. If any phase concludes a
  `SharedWitness.lean` decl must change shape, STOP and coordinate with 333 — re-shape in
  `SharedWitness.lean` (333's file), never in `OuterGate.lean` by weakening the statement, and never
  by assuming a family or closing vacuously.
- **Do NOT re-prove or weaken** `kvE2_outer_fold`, `kvE2_sepBody_kit_sound`, `kvE2_sepBody_extract`,
  `kvE2_sepBody_holds_of_honest`, or any 333/334/342 lemma. Consume unchanged.
- **Do NOT reintroduce any interiority hypothesis** (`hL`, `hLR`, or a left/right-interior guard on
  realized types). Refuted by `kvE2_sepHonest_hLR_absurd` (SW:5714).
- **Do NOT add `hbdry`/`hexcl` (or any provider-conditional family) as a hypothesis on
  `bracketEndChar_kvE2_sound_two_prior` or `bracketEndChar_kvE2_correct_two_prior`.** That would make
  the k=2 gate CONDITIONAL and fail the UNCONDITIONAL `BracketCarrierCorrectVPrior` that task 309
  needs. If the families cannot be discharged from the available context, that is a blocker to
  escalate (Phase 4b), not a hypothesis to add.
- **Do NOT wire the gate into `KampPrior.lean:351`** — R-B, a distinct downstream task, out of scope.
- **The F4 semantic `ℤ` LHS-FALSE discriminator + GO verdict is a SEPARATE, not-yet-spawned successor
  task** (per `SubBracket.lean:231`), spawned once the ⇒ half lands. Out of scope here.
- No bare `sorry`/`admit`; no vacuous close (`False.elim`, `(kvE2_sepHonest_hLR_absurd …).elim`,
  `def X := True`, `:= trivial`); no gate-modulo-assumed family; no interiority hypothesis (zero-debt).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **`hexcl`/`hbdry` do NOT close from `ExistProviders.correct` + `h_UZ`/`h_SZ` at `P.existF 0`** (the residue of the 309 F3/F4 obstruction — a single `t`-anchored provider literal may not force the joint positions / may collapse the exclusion guard to ⊤ on-fiber) | H | **M-H** | Phase 4b is the make-or-break and carries a **mandatory escalation branch**: if the discharge does not close from provider correctness alone, STOP — do NOT assume the family, do NOT close vacuously, do NOT add a hypothesis. Record the exact captured goal, classify the fix as either (a) a `SharedWitness.lean` re-shape (333 territory → coordinate/spawn) or (b) a genuinely unmet A1-conditionality (would force a conditional gate that fails 309) → escalate to the user. `bracketEndChar_kv_factors` (`CarrierKv.lean:422`) bounds what the depth-2 carrier pins (outer zone, projected 1-type) and is the reference for this classification. |
| Phase 4a interior gate families do not line up with the exact `hgateL`/`hgateR` shape `kvE2_outer_fold` expects (6-conjunct left excluding `kvE_sub2_zXU`, 4-conjunct right excluding `kvE2_sep_zWX1` — the two geometries differ, SW:9924/9941) | M | M | Build 4a directly against the verbatim fold-signature shapes (SW:9911-9945). Use `kvE2_sepBody_extract` → `kvE2_sepBundleL/R_parts` → `kvE_subBracket2V_sound_of_parts`. Confirm each `have` with `lean_goal` against the fold's expected argument type before wiring. If the kit cannot produce the exact shape, that is a 333-territory seam (coordinate, do not weaken). |
| Order-bit mismatch: `kvE2_outer_fold` wants `qnf.1 (.order …)` but `BracketCarrierCorrectVPrior` supplies `qnf.atom_assgn (.order …)` | L | M | These are **defeq** at successor depth (confirmed by the `bracketEndChar_kv_correct_one_prior` comment, PriorInterface.lean). Supply directly; if `exact` balks, insert a `show`/`change` bridging `atom_assgn` to `qnf.1`. No re-proof needed. |
| Wiring the soundness wrapper to the wrong weak order (`kvE2_sepModelOrder` SW:1476 or unprimed `kvE2_sepHonestOrder` SW:3891 — singleton classes, grouped obligations FALSE under ties) | H | L | Guardrail (337 report 14): any ordering-touching step uses the PRIMED `kvE2_sepHonestOrder'` (SW:5974) only. `kvE2_outer_fold` uses it internally; 335's wrapper consumes the fold structurally. Checklist item in Phase 4c. |
| Accidentally editing `SharedWitness.lean`/`SubBracket2V.lean` (333's territory) | H | L | All 335 code lives in `OuterGate.lean`. A `git status` gate in Phase 5 confirms the 333/334/342 files byte-unchanged. |
| Vacuous close typechecks green but proves nothing | H | L | Explicit testing item: grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`, `:= True`, `:= trivial`. Green + vacuous is a FAILURE. |
| Re-introducing a `md:NN` cite or citing the corrupted `.md` | M | L | Binding citation rule: page cites only. Phase 3 purges `md:297`; Testing greps `OuterGate.lean` for `md:` = 0. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2 | -- (landed) |
| 1 | 3 | -- (independent; land immediately) |
| 2 | 4a, 4b | 3 (same-file sequencing); 4a and 4b are independent of each other |
| 3 | 4c | 4a, 4b |
| 4 | 5 | 2, 4c |

Phases within the same wave can execute in parallel (4a and 4b touch disjoint obligations — interior
gates vs. non-interior/exclusion — and can be developed independently, then both consumed by 4c). All
phases edit only `OuterGate.lean`; 335 and 333 do not run concurrently (H7). The former "EXTERNAL
prerequisite: wait for 333" gate is GONE — `kvE2_outer_fold` is on disk, green.

### Phase 1: Live wrapper def + `rfl` bridge [COMPLETED]

**Goal**: Introduce the first live `bracketEndChar_kvE2` definition delegating to the faithful
carrier, plus the `rfl` bridge, in the isolated `OuterGate.lean` sibling wired into the aggregator.

**Delivered** (verified against source, on disk, green):
- `bracketEndChar_kvE2` (`OuterGate.lean:62`): `noncomputable def` producing `BracketEndCharCarrierV
  sig 2`, delegating to `kvE2_sepBody (nf_depth0_char_formula …) (fun χ => P.existF 0 χ)`.
- `bracketEndChar_kvE2_two_eq` (`OuterGate.lean:73`): the `rfl` bridge exposing `kvE2_sepBody`.
- Aggregator import (`NfMultiAnchorBridge.lean:39`).

**Depends on**: none. **Files**: `OuterGate.lean` (present). Preserved as-is; do not re-do.

---

### Phase 2: ⇐ completeness half — consume `kvE2_sepBody_holds_of_honest` [COMPLETED]

**Result**: `bracketEndChar_kvE2_complete_two_prior` landed (`OuterGate.lean:139`, sorry-free,
axiom-clean `{propext, Classical.choice, Quot.sound}`), plus helper bridges
`bracketEndChar_kvE2_hcb` / `bracketEndChar_kvE2_hck`. The gate `hg` is discharged by the landed
`kvE2_sepGate_holds_of_honest`; `hxw`/`hwt` recovered from `qnf`'s atom layer via `h_xy`/`h_yt`
(LITMUS-clean, bracket range). UNCONDITIONAL — no `hL`/`hLR`.

**Depends on**: 1. **Files**: `OuterGate.lean` (present, `OuterGate.lean:133-170`). Preserved as-is.

---

### Phase 3: Retire the stale in-source BLOCKED framing + citation hygiene [COMPLETED]

**Goal**: Correct 335's own in-source prose that records the ⇒ half as BLOCKED for two now-false
reasons, and re-ground the one dangling `md:NN` cite. Comment-only edit within 335's territory;
lands no proof but removes the doubly-stale mental model. Independent of the ⇒ half — land immediately.

**Tasks**:
- [x] Replace the `OuterGate.lean:172-201` "Phases 3-5 — BLOCKED" note with an accurate status: the
      ⇒ half is now-attemptable work consuming task 333's LANDED `kvE2_outer_fold`
      (`SharedWitness.lean:9897`, green, axiom-clean). Record that the fold takes four
      provider-conditional families (`hgateL`/`hgateR`/`hbdry`/`hexcl`) that 335 constructs at
      `charK := P.existF 0` — `hgateL`/`hgateR` from the interior kit (4a), `hbdry`/`hexcl` from
      provider correctness (4b, the genuine risk). *(completed)*
- [x] State the evidence inline with `file:line`: `kvE2_outer_fold` SW:9897 landed; the four families
      at SW:9911/9929/9946/9952; `kvE2_sepBody_extract` SW:8410 produces bundles; the named symbols
      `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` no longer exist (334 → `kvE2_sepArr'` +
      `kvE2_sepDisjValidOwner`); the O4 crux is DISSOLVED (333 report 03), forward-zone conjunct is
      antecedent-only; authorization held (333 Territory Contract). *(completed)*
- [x] Purge/re-ground the dangling `md:297` cite (and any other `md:NN`) in 335's artifacts to a PDF
      page cite, using the mandated Lemma 3.2 form. *(completed — `grep -c "md:" OuterGate.lean` = 0;
      the new note cites Rabinovich by PDF page only: Def 3.1 p.4, §5 pp.7-9, Lemma 3.2(1) p.4.)*
- [x] Do NOT touch the delivered decls or the docstring items 4/5 (Phase 5 finalizes those once
      soundness lands); do NOT touch any `SharedWitness.lean` content. *(completed — only the
      172-201 note block changed; header items 4/5 and all decls untouched; SW byte-unchanged.)*

**Timing**: 0.5 hours. **Depends on**: none (1, 2 landed).

**Files to modify**: `OuterGate.lean` (comment block only).

**Verification**:
- `lake build …OuterGate` still exit 0 (comment-only edit, no proof change).
- `grep -n "md:" OuterGate.lean` = 0; no `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` asserted as a
  live obstruction in the note.
- `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged (`git status`).

---

### Phase 4a: Construct the interior gate families `hgateL`/`hgateR` [NOT STARTED]

**Goal**: Build the two interior LEFT/RIGHT per-σ gate families in the exact shape
`kvE2_outer_fold` expects (SW:9911-9945), as local `have`s over the
`BracketCarrierCorrectVPrior` context (six order bits + `h_UZ`/`h_SZ` + `x t`) at
`charK := fun χ => P.existF 0 χ`. These are consumed by Phase 4c, not by a standalone theorem.

**Tasks**:
- [ ] Establish the `hgateL` obligation: `∀ w, x<w → w<t → (kvE2_sepPtW …).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 → …` the 6-conjunct interior LEFT
      geometry excluding `kvE_sub2_zXU` (verbatim SW:9911-9928). Discharge via `kvE2_sepBody_extract`
      (SW:8410) → `kvE2_sepBundleL_parts` (SW:5379) → `kvE_subBracket2V_sound_of_parts`
      (SubBracket2V:1290).
- [ ] Establish the `hgateR` obligation: the 4-conjunct interior RIGHT geometry excluding
      `kvE2_sep_zWX1` (verbatim SW:9929-9945). Discharge via `kvE2_sepBundleR_parts` (SW:5396) →
      `kvE_subBracket2V_sound_of_parts`.
- [ ] Confirm each `have`'s type against the fold's expected argument with `lean_goal` /
      `lean_hover_info` BEFORE wiring into 4c. The left and right geometries genuinely differ — do not
      copy one to the other.
- [ ] Any ordering-touching step uses the PRIMED `kvE2_sepHonestOrder'` (SW:5974) only (337 report 14).
- [ ] **Seam guard**: if `kvE2_sepBundleL/R_parts` + `kvE_subBracket2V_sound_of_parts` cannot produce
      the exact fold shape, STOP and coordinate with 333 (re-shape on the SharedWitness side) — do NOT
      weaken the statement, assume the gate, or add an interiority hypothesis.

**Timing**: 1.5 hours. **Depends on**: 3 (same-file sequencing).

**Files to modify**: `OuterGate.lean` (interior gate `have`s; may be factored into private helper
lemmas `bracketEndChar_kvE2_hgateL` / `_hgateR` for readability — 335's own file).

**Verification**:
- The two families typecheck against the `kvE2_outer_fold` argument positions (`lean_goal`).
- No interiority hypothesis; primed order only; sorry-free.
- `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged.

---

### Phase 4b: Discharge `hbdry` and `hexcl` at `charK := P.existF 0` — THE GENUINE RISK [NOT STARTED]

**Goal**: Construct the non-interior positive realization family `hbdry` (SW:9946) and the negative-sub
exclusion family `hexcl` (SW:9952) from `ExistProviders.correct` (`PriorInterface.lean:38`) +
`h_UZ`/`h_SZ`, at the provider instantiation `charK := fun χ => P.existF 0 χ`. This is the residue of
the 309 F3/F4 obstruction and is the make-or-break for 335's soundness half. **This phase carries a
mandatory escalation branch and MUST NOT be closed vacuously or by adding a hypothesis.**

**Tasks**:
- [ ] `hbdry`: for `w` with `x<w<t`, `(kvE2_sepPtW …).eval_at M atomMap w`, `σ ∈ kvE2_sepPos qnf`,
      `¬(nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3)`, produce
      `∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ`. Route the σ-level `charK` E[Σ] literals of
      `kvE2_sepEpL` (SW:1054) / `kvE2_sepPtW` (SW:1100) / `kvE2_sepEpR` (SW:1076) through
      `ExistProviders.correct`'s `↔ ∃ env, nf_eval_nf M k (n+1) (insertEnv env t) sub` at
      `existF 0` to type into the arity-4 depth-1 evaluation. Compose per the
      `kvE_subBracket2V_sound_of_outer` (SubBracket2V:1481) pattern the fold docstring cites.
- [ ] `hexcl`: for `σ` with `qnf.2 σ = false`, produce `∀ x1, ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ`. This
      is the "negative subs unrealized" clause, provider-conditional in the A1 sense
      (`PriorInterface.lean:47-59`). Derive from `ExistProviders.correct` + the carrier's own
      exclusion channel — NOT by assuming it.
- [ ] Confirm every intermediate `have` with `lean_goal`; witness bound `x < x1`-region reads from the
      bracket range, NOT a chain — no `x1 < e_i` literal (LITMUS `NavigatedSpine.lean:437`).
- [ ] **ESCALATION BRANCH (mandatory)**: if `hbdry` or `hexcl` does NOT close from
      `ExistProviders.correct` + `h_UZ`/`h_SZ` alone:
      - Do NOT assume the family, do NOT `False.elim`/vacuous-close, do NOT add it as a hypothesis on
        the k=2 theorems.
      - Capture the exact residual goal (`lean_goal` transcript) and the failing channel.
      - Classify the fix using `bracketEndChar_kv_factors` (`CarrierKv.lean:422`, the machine-checked
        (outer zone, projected 1-type) information-loss record):
        (a) **`SharedWitness.lean` re-shape needed** (the carrier must pin more than the factored
            content) → 333 territory: STOP, mark this phase `[BLOCKED]`, coordinate with 333 or spawn a
            333-scoped task. This further delays 341 (record the coordination point).
        (b) **Genuinely unmet A1-conditionality** (the provider literal cannot force the joint
            positions / exclusion collapses to ⊤ on-fiber, mirroring 309 F4) → escalate to the user:
            discharging this would require either a stronger provider contract or a conditional gate,
            and a conditional gate fails the UNCONDITIONAL `BracketCarrierCorrectVPrior` that 309 needs.
      - Record the decision explicitly (do NOT discover it mid-Phase-4c).

**Timing**: 1.5-3 hours (bounded if provider correctness suffices; open-ended escalation if not).
**Depends on**: 3 (same-file sequencing). Independent of 4a.

**Files to modify**: `OuterGate.lean` (`hbdry`/`hexcl` `have`s or private helper lemmas
`bracketEndChar_kvE2_hbdry` / `_hexcl`).

**Verification**:
- If green: both families typecheck against the `kvE2_outer_fold` argument positions; sorry-free; no
  assumed family; no vacuous close; primed order only; LITMUS-clean.
- If escalated: the phase is `[BLOCKED]` with a captured goal, a channel diagnosis, and an explicit
  (a)/(b) classification — no `sorry`/vacuous placeholder committed, `OuterGate.lean` left at its
  Phase-4a-green state.
- `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged either way.

---

### Phase 4c: Wrap into `bracketEndChar_kvE2_sound_two_prior` via `kvE2_outer_fold` [NOT STARTED]

**Goal**: Assemble the ⇒ (mp) direction as a standalone lemma over the `BracketCarrierCorrectVPrior`
context, feeding `kvE2_outer_fold` the four families from 4a/4b.

```
bracketEndChar_kvE2_sound_two_prior :
  (bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t
    → ∃ w : M.carrier, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```
UNCONDITIONAL (no `hL`/`hLR`, no assumed family).

**Tasks**:
- [ ] State `bracketEndChar_kvE2_sound_two_prior` with the same signature-context shape as
      `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:139-152`), arrow reversed.
- [ ] `intro h_holds`; `rw [bracketEndChar_kvE2_two_eq] at h_holds` to expose
      `(kvE2_sepBody (nf_depth0_char_formula …) (fun χ => P.existF 0 χ) qnf).holds`.
- [ ] `apply kvE2_outer_fold` (or `exact kvE2_outer_fold …`) at `charK := fun χ => P.existF 0 χ`,
      supplying: the six order bits (from `h_xy`/…/`h_tx`; bridge `qnf.atom_assgn (.order …)` →
      `qnf.1 (.order …)` via `show`/`change` if `exact` balks — they are **defeq**), `M`, `x`, `t`,
      `h_holds`, and the four families `hgateL`/`hgateR` (Phase 4a) + `hbdry`/`hexcl` (Phase 4b).
- [ ] Confirm the resulting goal `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` with `lean_goal`; no residual
      side-goals.
- [ ] Any ordering-touching step uses the PRIMED `kvE2_sepHonestOrder'` only (the fold uses it
      internally; the wrapper is order-agnostic).

**Timing**: 1 hour. **Depends on**: 4a AND 4b (both families must be green). If 4b escalated to
`[BLOCKED]`, this phase is HALTED (not a permanent block — resumes once 4b resolves).

**Files to modify**: `OuterGate.lean` (add ⇒ soundness lemma).

**Verification**:
- `bracketEndChar_kvE2_sound_two_prior` compiles sorry-free; no interiority hypothesis and no
  provider-conditional family in its signature; consumes 333's `kvE2_outer_fold` unmodified.
- `#print axioms bracketEndChar_kvE2_sound_two_prior` (via `lake env lean`, NOT `lean_verify` — it is
  UNRELIABLE on `SharedWitness.lean`, returning stale `sorryAx` after an external `lake build`) →
  `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- No `x1 < e_i` literal; primed order only; `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged.

---

### Phase 5: Assemble unconditional `k = 2` gate-correctness + axiom/faithfulness audit + docstring [NOT STARTED]

**Goal**: Combine both directions into `bracketEndChar_kvE2_correct_two_prior :
BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 atomMap h_surj P)`, confirm
axiom-cleanliness and F1-F7/LITMUS preservation, and finalize the `OuterGate.lean` scope docstring.

**Tasks**:
- [ ] State `bracketEndChar_kvE2_correct_two_prior` (UNCONDITIONAL): unfold
      `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`), `intro` the six order hypotheses +
      `h_UZ`/`h_SZ` + `x t`, then `constructor` combining Phase 4c (⇒, mp) and Phase 2 (⇐, mpr),
      mirroring `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:100`).
- [ ] Finalize the `OuterGate.lean` header docstring: rewrite delivered items 4/5
      (`OuterGate.lean:24-29`) to record `bracketEndChar_kvE2_sound_two_prior` and
      `bracketEndChar_kvE2_correct_two_prior` as DELIVERED (drop the "NOT delivered, BLOCKED" text);
      note R-A unconditional, R-B out of scope, and the F4 `ℤ` discriminator as a not-yet-spawned
      successor task (`SubBracket.lean:231`). Page-cite only.
- [ ] Run `#print axioms bracketEndChar_kvE2_correct_two_prior` via `lake env lean`; confirm
      `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- [ ] F1-F7 + LITMUS preservation checklist (see Testing & Validation).
- [ ] `git status` confirms only `OuterGate.lean` changed; `SharedWitness.lean`/`SubBracket2V.lean`
      byte-for-byte unmodified.
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate`, then full
      `lake build`.

**Timing**: 1 hour. **Depends on**: 2, 4c.

**Files to modify**: `OuterGate.lean` (assembled theorem + docstring finalize).

**Verification**:
- `#print axioms bracketEndChar_kvE2_correct_two_prior` axiom-clean, no `sorryAx`.
- Full `lake build` green.
- No interiority hypothesis anywhere; no vacuous close; no provider-conditional family in the
  signature; docstring records delivered decls, page-cited.

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate` succeeds after
      each phase; full `lake build` green at the end.
- [ ] **Axiom check via `#print axioms` (NOT `lean_verify`)**: run each delivered declaration through
      `lake env lean` with `#print axioms <name>`; every one returns `{propext, Classical.choice,
      Quot.sound}` with no `sorryAx`. `lean_verify` is UNRELIABLE on `SharedWitness.lean` (stale LSP
      `sorryAx` after external `lake build`) — do not trust it.
- [ ] **No vacuous close**: grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`,
      `:= True`, `:= trivial`. Green + vacuous is a FAILURE, not a pass.
- [ ] **No assumed provider-conditional family**: `hbdry`/`hexcl` (and `hgateL`/`hgateR`) appear ONLY
      as proved local `have`s / private helper lemmas, never as hypotheses on
      `bracketEndChar_kvE2_sound_two_prior` or `bracketEndChar_kvE2_correct_two_prior`.
- [ ] **No interiority hypothesis**: no `hL`/`hLR`/left-or-right-interior guard on realized types in
      any delivered signature (refuted by `kvE2_sepHonest_hLR_absurd`, SW:5714).
- [ ] **Primed order only**: no live path consumes `kvE2_sepModelOrder` (SW:1476) or the unprimed
      `kvE2_sepHonestOrder` (SW:3891); ordering rides `kvE2_sepHonestOrder'` (SW:5974).
- [ ] **LITMUS (`NavigatedSpine.lean:437`)**: no `x1 < e_i` relative-position literal on any live path;
      witness bounds come from the bracket range, never a chain.
- [ ] **F1-F7**: non-vacuous realization (F2/F3 via the landed completeness engine + 333's soundness
      fold); no open/closed zone-key conflation (F5); no model literal buried (F4).
- [ ] **Citation hygiene**: `grep -n "md:" OuterGate.lean` = 0; all Rabinovich references page-cited;
      Lemma 3.2 uses the mandated form (Def 3.1 p.4 / k=m split p.7 / Def 7.5 p.13).
- [ ] **Territory (H7)**: `SharedWitness.lean`, `SubBracket2V.lean`, and all other 334/337/342 files
      byte-for-byte unmodified (`git status`); only `OuterGate.lean` changed. If any landed decl must
      change (Phase 4b branch a), STOP and coordinate with 333 — do NOT edit `SharedWitness.lean`.
- [ ] **SW sorry count unchanged**: `SharedWitness.lean` sorry string occurrences all inside prose
      comments (zero real sorries); count MUST NOT rise (335 does not edit `SharedWitness.lean`).
- [ ] `bracketEndChar_kvE2_two_eq` remains a genuine `rfl` bridge (unchanged from Phase 1).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — extended:
  corrected BLOCKED-note comment (Phase 3); interior gate families `hgateL`/`hgateR` (Phase 4a);
  non-interior/exclusion families `hbdry`/`hexcl` (Phase 4b); ⇒ soundness lemma
  `bracketEndChar_kvE2_sound_two_prior` (Phase 4c); assembled unconditional gate-correctness theorem
  `bracketEndChar_kvE2_correct_two_prior` + finalized scope docstring (Phase 5). (Phase 1 def + `rfl`
  bridge and Phase 2 completeness lemma already present.)
- `specs/335_outer_gate_assembly_engine_kvE2_body/plans/04_outer-gate-post-333-v4.md` (this file);
  supersedes `plans/03_soundness-half-consume-333-lemmas.md`.
- `specs/335_outer_gate_assembly_engine_kvE2_body/summaries/04_outer-gate-post-333-summary.md` (on
  completion).
- **Successor task (F4, NOT this task)**: a separate lean4 task for the F4 semantic `ℤ` LHS-FALSE
  discriminator + GO verdict (per `SubBracket.lean:231`), spawned once the ⇒ half lands.
- **Follow-on task (R-B, NOT this task)**: wire `bracketEndChar_kvE2` +
  `bracketEndChar_kvE2_correct_two_prior` into `KampPrior.lean:351`.
- **Unblocks (downstream)**: task 309 (needs the unconditional `bracketEndChar_kvE2_correct_two_prior`
  GO gate) and task 341 (`SharedWitness.lean` refactor, which must NOT start until 335's
  `OuterGate.lean` work completes).

## Rollback/Contingency

- All 335 work is additive and isolated to `OuterGate.lean`. To revert new phases: `git checkout
  OuterGate.lean` to its Phase-2 state; the tree returns to the current landed state (⇐ half + def +
  bridge) with all carrier/soundness INPUTS untouched.
- **If Phase 4b `hbdry`/`hexcl` do not close from provider correctness**: follow the mandatory
  escalation branch — capture the goal, classify (a) 333-territory re-shape vs. (b) unmet
  A1-conditionality, mark Phase 4b `[BLOCKED]`, and STOP. Do NOT assume the family, close vacuously,
  or add a hypothesis. Phases 3 and 4a (both independent of 4b) remain landed.
- **If the SharedWitness↔OuterGate seam mismatches** (Phase 4a or 4c): coordinate the exact
  `kvE2_outer_fold` / kit statement with 333; re-shape on the 333/SharedWitness side (333's territory),
  never by weakening 335's statement or editing `SharedWitness.lean` from 335.
- **If any phase concludes a landed 333/334/337/342 declaration must change**: STOP — this is 333's
  territory. Coordinate with 333 or spawn a 333-scoped task; do not edit `SharedWitness.lean` from 335
  and do not assume permission. Never commit a bare `sorry`, an assumed family, a vacuous close, or an
  interiority hypothesis.
