# Implementation Plan (v2): Corrected k=2 Carrier (nested F_i-chain) and F4 Correctness-Gate Resolution

> **[SUPERSEDED]** by `plans/03_corrected-k2-carrier-gate-v3.md` (2026-07-07). v2's Stage A
> (Phases 1-6, corrected carrier) and Stage B (Phase 7, construction-level F4 discrimination) +
> the Phase 11 integrity sweep LANDED GREEN and are committed; those phases are carried forward
> verbatim as [COMPLETED] in v3. v2's Phases 8-10 (Stages C/D, the k=2 `BracketCarrierCorrectVPrior`
> gate) hit the pre-authorized sizing boundary (single "prove the gate" phase too large for one
> dispatch) and are BLOCKED here. v3 decomposes exactly that remainder into single-dispatch-sized
> phases so implementation resumes **within task 321** (no spawn). Read v3 for the live plan; this
> file is retained for history.

- **Task**: 321 - implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution
- **Status**: [SUPERSEDED]
- **Effort**: 20 hours (Phase 1 already COMPLETED; ~19 hours remaining)
- **Dependencies**: 320 (GO verdict on route b3, design spec §5 — COMPLETED)
- **Research Inputs**:
  - specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md (blocker resolution: successor-parameterization, forced encoding, staged gate — Section 3 is the drop-in amended design spec)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/02_jointpinning-probe-results.md (design spec §5, route b3 GO)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md (binding framing caveat)
  - specs/309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md (F4 blocker origin)
- **Artifacts**: plans/02_corrected-k2-carrier-fi-chain-v2.md (this file; supersedes plans/01_corrected-k2-carrier-fi-chain.md)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4

## Overview

This is **v2**, superseding v1 (`plans/01_corrected-k2-carrier-fi-chain.md`), which BLOCKED at
Phase 2. v1's Phase 2 discovered that task-320's design spec §5 was probe-level and left three
decisive gaps: (A) the general-`k` `σ.2` read is not realizable in Lean (`NormalForm sig k 4`
projects `.2` only at a *literal successor* depth); (B) the concrete `pointTypes`/`segmentTypes`
encoding from `σ.2` was under-specified; (C) no proven k≥2 enriched-carrier correctness gate
precedent exists. Blocker research (report `01_blocker-research-successor-k.md`, 6 machine-checked
`lean_run_code` probes, zero diagnostics, zero project-file writes) resolves all three with
machine-checked formulations. This v2 integrates those resolutions as an amended, directly
implementable design spec and restructures the incomplete phases into the recommended staged
plan (construction → adversarial check → soundness → completeness-with-fallback → integrity).

The task still builds the FULL corrected carrier under the task-320 §5 names — `kvE_subBracket`,
`kvE_subChain`, `kvE2_body`, `bracketEndChar_kvE2` — **additive** alongside the landed
(do-not-edit) `bracketEndChar_kvE` (13.2) and `bracketEndChar_kvE'` (13.25), then re-runs the k=2
`BracketCarrierCorrectVPrior` gate to a **GO** verdict. The mandatory adversarial test remains the
F4 provider-independent ℤ counterexample (`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
`σ''=char[14,16,11,20]`, honest `char[14,15,10,20]` marked false), which MUST now FAIL against the
new construction because the sub-bracket reads `σ.2` (where the two subs differ) rather than the
shared `σ.1` `nfk_projFresh`.

### Blocker Resolution — Amended Design Spec (from report 01, Section 3)

The three v1 blockers are resolved as follows; these are the binding design decisions v2
implements (all names/signatures machine-checked GREEN against the module except where marked
"mechanical completion"):

- **(A) Successor-parameterize the whole kvE2 layer at provider depth `j+1`.** Shift the
  provider-depth parameter from bare `k` to `j+1` (`j : Nat` free). Then the carrier is
  `BracketEndCharCarrierV sig (j+1+1)` — carrier depth `j+2`, exactly the **k ≥ 2 band** the
  enriched carrier was always documented to serve (depth-alignment note :5144-5148). Every sub has
  type `σ : NormalForm sig (j+1) 4` — a literal successor — so `σ.2 : NormalForm sig j 5 → Bool`
  projects directly (or via the named destructor `NormalForm.quant_assgn σ`, identical value). At
  `j = 0` the header instantiates to the EXACT landed gate signature (`P : ExistProviders sig
  atomMap 1`, `qnf : NormalForm sig 2 3`), closing by `rfl` — same shape as
  `bracketEndChar_kvE'_two_eq` (:5523). Rejected: pattern-matching the body on `k` (dead depth-0
  arm) and specializing only `kvE_subBracket` (the body's subs stay `NormalForm sig k 4` and
  cannot be handed to a successor-only function). The `j+1` shift is the minimal landed-idiom fix.
- **(B) The encoding is forced, not invented — the `bracketEndChar_k1v` (:1940) zone-bit routing
  pattern, one arity up.** Sub-level fold bits are `fun zs χ => σ.2 (nf0_assemble zs χ σ.1)` (gate
  instance `j = 0`), the `nf_eval_depth1_fold_iff` (:5187) decomposition at `n = 4` over
  `(ZoneSpec 4 × NormalForm sig 0 1)` via `nf0_assemble` (NfEFold.lean:180). `bits zs χ = true` iff
  σ demands an inner witness `v` in zone `zs` of depth-0 monadic type `χ`. Bit routing (Def 3.1
  discipline, Rabinovich md:61-74):
  - Interior zones (inside `(x,t)`): **extra bracket witness slots** adjacent to u's slot, point
    type `⟨charBase χ⟩` for positive bits, spliced into the outer arrangement lists.
  - Point-coincidence zones (`v = x/u/w/t`): conjuncts on the corresponding existing point type
    (u's slot gets `charK (nfk_projFresh σ)` ∧ the `v = u` bits, mirroring the landed `ptW` zAtW
    pattern :5463-5466).
  - Exterior zones (`v < x`, `v > t`): Since/Until literals conjoined into `epL`/`epR` (landed
    exterior-zone pattern :5438-5448).
  - Negative bits per interior zone: segment **exclusion conjuncts** `(charBase χ).neg` on the
    refined segments (landed `segL`/`segR` pattern :5455-5462, one level in).
  The type-level realizability is machine-checked (probe 5, GREEN, returns `Σ m, BracketFormula
  (m+1)` — the `+1` from u's own slot is what makes `fChainPred` available). The zone-by-zone
  enumeration is mechanical k1v-mirroring. `bracket_implies_fChainPred` (EANegation:660)
  instantiates at the **constructed** `kvE_subBracket` (probe 6), upgrading task-320 probe P4 from
  "abstract recovery lemma on generic `bf`" to "recovery lemma applies to the concrete sub-bracket".
- **(C) The gate is a staged, multi-phase effort with a pre-authorized fallback.** No proven k≥2
  enriched precedent exists; a single "prove the gate" phase would repeat v1's sizing error.
  Structure: Stage A construction → Stage B adversarial ℤ discrimination check (BEFORE the gate) →
  Stage C soundness (reuses k1v templates + the already-demonstrated crux closure) → Stage D
  completeness (novel, highest risk, 2-3 phases). **Pre-authorized fallback**: if Stage D hits a
  *genuine obstruction* (not mere effort), land Stages A-C + the Stage-B discrimination record as
  this task's deliverable and spawn the completeness direction as its own task — that is a *partial
  GO with recorded progress*, not an F5 defect. Do NOT pre-spawn; the decision point is a Stage-D
  blocker, recorded precisely, if one arises.

**Naming / visibility note (resolved)**: new code is appended to `NfMultiAnchorBridge.lean` (same
module), so it CAN reference the `private` helpers (`kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`,
`bracketFromLists`) directly — `private` in Lean 4 is module-scoped. The "retain non-joint 13.2
channels verbatim" requirement is implementable by local reuse or restatement inside the same
file; no visibility workaround needed.

Definition of done (unchanged from v1): `bracketEndChar_kvE2` lands additively; the k=2 correctness
gate passes to a recorded GO verdict (or a recorded partial-GO with the Stage-D obstruction
documented and spawned per the pre-authorized fallback); the F4 ℤ counterexample is discriminated
(LHS FALSE at `(10,20)` under the new carrier); green `lake build`; axiom-clean (`propext`,
`Classical.choice`, `Quot.sound`); no `sorry` on any live path; every do-not-edit landed asset
byte-identical; a verdict record landed either way.

### Research Integration

This v2 integrates the newly-landed blocker research report
`reports/01_blocker-research-successor-k.md` (the primary new input) on top of the task-320 §5
design spec. Newly integrated facts consumed:

- **Report §1 (root cause per blocker)**: `NormalForm` is a `def` by recursion on depth
  (NormalForm.lean:134-136); `.2` elaborates only at a syntactic successor depth. Task-320 §5(1)'s
  bare-`k` signature was unrealizable *as written* — a parameterization shift, not new machinery.
- **Report §2/Q1 (k-matching formulation)**: successor-parameterize the whole kvE2 layer at
  provider depth `j+1`; carrier depth `j+2` = the k≥2 band; `j=0` ⇒ landed gate signature by `rfl`.
  Machine-checked probes 1/1b/3/4.
- **Report §2/Q2 (forced encoding)**: `bracketEndChar_k1v` (:1940) zone-bit routing one arity up;
  fold bits `σ.2 ∘ nf0_assemble` at `n=4` (`nf_eval_depth1_fold_iff` :5187). Typed skeleton probe 5
  GREEN; `bracket_implies_fChainPred` at the constructed sub-bracket probe 6 GREEN.
- **Report §2/Q3 (staged gate)**: forward-first staged structure with an explicit pre-authorized
  fallback to spawn Stage D on genuine obstruction; keep the gate in-task otherwise.
- **Report §3 (drop-in amended design spec)**: exact signatures for `kvE_subBracket`,
  `kvE_subChain`, `kvE2_body` (successor-parameterized), `bracketEndChar_kvE2`, and the `two_eq`
  bridge. The corrected carrier drops the `exF`/`P.existF 3` parameter from the joint path entirely
  — the sub's joint content rides the sub-bracket slots, so no `e`-rebinding site exists on the
  joint path; `P.existF 0` (unary `charK` channel) is retained.
- **Report §4 (constraint compliance)**: the formulation stays inside all binding constraints
  (additive same-file appends; anchor set `{x,t}`; no provider-side pinning — the provider
  disappears from the joint path rather than being pinned; no `EANegation :1090/:1249`; real
  segment exclusion conjuncts; landed cited chain steps).

Carried forward from v1's research integration (task-320 §5, unchanged): route b1 NO-GO (`rfl`),
Cor 5.4 chain-shape MATCH (`fChainFrom_step`/`fChainFrom_base` = Cor 5.4), route b3 GO
(`bracket_implies_fChainPred` recovers positions `e`-free), route b2 NOT NEEDED (no
`nf_eval_unique`/`nfPred_correct` structural-identity hypothesis).

### Prior Plan Reference

v1 (`plans/01_corrected-k2-carrier-fi-chain.md`) is **superseded** by this v2 and marked as such
in its header per house convention. v1's Phase 1 [COMPLETED] is preserved verbatim below (green
baseline + landed-asset snapshot + F4 oracle already established and committed). v1's Phase 2 was
[BLOCKED]; its BLOCKER writeup is now the input this v2 resolves and is not carried forward as an
open phase. The lineage context (v6→v7 re-pointing pattern, F1–F4 house style) is carried from the
parent task 309's plan v7 via the task-320 report and the task description; those constraints remain
binding.

### Roadmap Alignment

No ROADMAP.md consulted (not provided in delegation context). Goal-state alignment for the
enclosing chain: this task's GO gate is the prerequisite for task 309's Phase 13.4 (general-k
one-step correctness) and Phase 14 (hook rewire discharging KampPrior.lean:351's strategic `sorry`,
target axioms exactly `[propext, Classical.choice, Quot.sound]`). After completion, task 309
resumes via `/implement 309` (possibly preceded by `/revise 309` for a v8 re-pointing to the new
deliverable names). If the Stage-D fallback fires, the spawned completeness task becomes the new
prerequisite for 309 Phase 13.4.

## Goals & Non-Goals

**Goals**:
- Land `kvE_subBracket` (nested sub-bracket reading `σ.2` at successor depth via the forced k1v
  zone-bit routing), `kvE_subChain` (its `fChainPred`), `kvE2_body` (corrected enriched body,
  successor-parameterized at `j+1`), `bracketEndChar_kvE2` (corrected carrier at
  `BracketEndCharCarrierV sig (j+1+1)`) + its `two_eq` bridge (`rfl` at `j=0`) — additive, under
  the task-320 §5 names.
- Front-load the mandatory F4 ℤ adversarial discrimination check (Stage B) BEFORE the gate.
- Discharge the per-sub positive soundness crux (previously the unpinnable `w = e 1`, `x = e 2`) by
  instantiating `bracket_implies_fChainPred` at the constructed `kvE_subBracket … σ` (Stage C).
- Prove the completeness direction (honest realization ⇒ carrier holds) via the
  `nf_eval_depth1_fold_iff` fold extraction and `IntervalPattern.holds` construction (Stage D),
  closing the k=2 `BracketCarrierCorrectVPrior` gate to a recorded GO — OR land the pre-authorized
  partial-GO + spawn on a genuine Stage-D obstruction.
- Preserve every do-not-edit landed asset byte-identical; land a verdict record either way.

**Non-Goals**:
- No third FLAT carrier variant (another `kvE''`-style body with per-sub literals evaluated at `t`)
  — the F3/F4-refuted shape, OUT OF SCOPE regardless of intermediate suggestion.
- No provider-side pinning (v7 Amendment F3 binding); the provider *disappears* from the joint path,
  it is not pinned.
- No consumption of `EANegation :1090/:1249`.
- No structural-identity / `nf_eval_unique` / `nfPred_correct` hypothesis (route b2 NOT NEEDED).
- No pattern-match-on-`k` body with a dead depth-0 arm (rejected in Q1); use the `j+1` shift.
- No edits to any landed asset (`bracketEndChar_kv`/`kvE_body`/`bracketEndChar_kvE`,
  `bracketEndChar_kvE'`/`kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj`, F1–F4 verdict records,
  `ExistProviders`/`BracketCarrierCorrectVPrior`, all task-310/311 material, the task-320 probes).
- No general-k work (task 309 Phase 13.4/14) — out of scope for this task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Successor `j+1` parameterization threads incorrectly through `kvE2_body`'s consumed non-joint channels (depth mismatch at reuse) | H | M | The subs are `NormalForm sig (j+1) 4` (literal successor); reuse the landed `kvE'_body` channels by restating at `(j+1)` (same-module `private` access). Verify the `j=0` `two_eq` closes by `rfl` (Phase 6) — a depth mismatch fails `rfl` immediately. |
| Concrete zone enumeration in `kvE_subBracket` re-flattens into a single-point per-sub literal under proof pressure | H | M | The encoding is FORCED (k1v :1940 routing); every interior-zone positive rides a bracket witness slot / nested-Until eval point (probes P3/P4/6). A single-point relative-position assertion is an automatic escalation (Gabbay cross-check), not a workaround. Grep the body for the absence of a flat `charK (nfk_projFresh σ)` joint literal on the joint path. |
| Forbidden tactics (`simp`/`omega`/`aesop`) creeping into chain-construction bodies | M | M | G5: cite Rabinovich at every chain step; `by omega` permitted ONLY for `Fin`-index typing obligations in signatures (identical to landed `fChainFrom_step`), never in a chain-construction body. |
| Accidental edit / byte drift of a do-not-edit landed asset | H | L | Phase 1 snapshot (COMPLETED); verify byte-identity via `git diff` (expect additive `+N/-0`) in Phase 11; all new defs land AFTER the task-320 probe section. |
| Stage D completeness (honest realization ⇒ sub-bracket holds) stalls — genuinely novel, no precedent, `IntervalPattern.holds` witness construction from `nf_eval_nf` is order-theoretic (Lemma 5.3 style) | H | M | Staged: Phase 9 isolates the fold-extraction + `IntervalPattern.holds` data build; Phase 10 the arrangement disjunct + gate close. Phase-per-lemma, commit-per-green. **Pre-authorized fallback**: on a genuine obstruction, land Stages A-C + Stage-B record and spawn Stage D as its own task (partial GO, not F5). Record the obstruction precisely; do NOT absorb it or invent a shortcut. |
| Soundness per-sub crux reappears as an `e`-residual (Stage C) | H | L | The crux is machine-probed closed (probe 6: `bracket_implies_fChainPred` at the constructed sub-bracket); if a residual `e`-equation reappears, the joint literal was not fully replaced (return to Phase 5), NOT a new pinning device. |
| F4 counterexample does not discriminate (LHS still holds) | H | L | Report §2/Q2 shows the honest and dishonest subs produce DIFFERENT witness-slot lists (σ'' has `bits z(u,w) χ = true` in `(14,16)∋15`; honest `(14,15)=∅`). Phase 7 verifies at construction level BEFORE the gate; if LHS still holds, the `σ.2` read/encoding is incomplete — fix Phase 3, do not weaken the test. |
| Anchor growth / third-anchor tower slips in (G2/G4/G6 violation) | H | L | Anchor set fixed at 2 `{x,t}`; all new content is bracket WITNESSES between the fixed endpoints; `kvE_subBracket` generalizes one level (the `Σ m, BracketFormula (m+1)` shape), never a third anchor. Verify in Phase 11. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by | Stage |
|------|--------|------------|-------|
| 1 | 1 | -- | (baseline, COMPLETED) |
| 2 | 2 | 1 | A (construction) |
| 3 | 3 | 2 | A |
| 4 | 4 | 3 | A |
| 5 | 5 | 4 | A |
| 6 | 6 | 5 | A |
| 7 | 7 | 6 | B (adversarial check) |
| 8 | 8 | 7 | C (soundness) |
| 9 | 9 | 8 | D (completeness) |
| 10 | 10 | 9 | D |
| 11 | 11 | 10 | integrity + verdict |

Phases within the same wave can execute in parallel. This construction is inherently sequential
(each carrier layer builds on the previous), so each wave holds one phase. Stage B (Phase 7) is
deliberately placed BEFORE the gate (Stages C/D) to front-load the highest-information failure mode.

### Phase 1: Baseline capture and landed-asset integrity snapshot [COMPLETED]

- **Goal:** Establish a green baseline, record the F4 counterexample state, and snapshot every
  do-not-edit landed asset so byte-identity can be verified at the end.
- **Tasks:**
  - [x] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` and confirm green
        (baseline, ~1005 jobs); confirm the task-320 probe section (`probe_P1`/`probe_P3`/`probe_P4`)
        is present and axiom-clean. *(completed — build exit 0; probes present at :5634-5698)*
  - [x] Record the byte ranges / signatures of do-not-edit assets: `bracketEndChar_kv`, `kvE_body`,
        `bracketEndChar_kvE`, `bracketEndChar_kvE'`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`,
        the F1–F4 verdict records, `ExistProviders`, `BracketCarrierCorrectVPrior`, the task-320 probes
        (`git stash`-free snapshot; note current `git diff` is clean). *(completed — git diff clean on Lean file)*
  - [x] Re-capture the F4 crux goal and ℤ counterexample verbatim from the F4 record (:5559-5595) and
        the design spec §1 as the Phase 7 acceptance oracle. *(completed — recorded in-file at :5584-5595)*
  - [x] Confirm the CONSUME-DO-NOT-REBUILD asset list is available (E[Σ]-fold engine, k1v proof kit,
        `nf_eval_unique`/`nfPred_correct`, `A_past`/`A_future`, `bracketBuildLeft/Right`,
        `VVecEA2`/`bracketFromLists`/`existsBounded_right`, `fChainFrom`/`fChainPred`,
        EANegationClosure forward stack proof-side only, `prior_hasAttainedINF`/`HasAttainedINF`).
- **Timing:** ~1 hour (done)
- **Depends on:** none
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — read-only this phase.
- **Verification:**
  - Green scoped build; task-320 probes present and axiom-clean; `git diff` clean at phase start. *(met)*

### Phase 2: Successor-parameterized σ.2 read and sub-fold-bit decoding [COMPLETED] (Stage A)

- **Goal:** Land the successor-depth `σ.2` read and the sub-level fold-bit decoder that the blocker
  research established as the realizable, forced foundation — replacing v1's unrealizable general-`k`
  Phase 2. This is the type-level bridge the design spec §5 glossed.
- **Tasks:**
  - [x] Establish the successor read: for `σ : NormalForm sig (j+1) 4` (literal successor),
        `σ.2 : NormalForm sig j 5 → Bool` projects directly (or via `NormalForm.quant_assgn σ`,
        identical value). Confirm the `j` shift is the layer-wide parameter (provider depth `j+1`),
        NOT a bare-`k` per-def specialization (report Q1; rejected alternatives noted). *(completed —
        `kvE_subFoldBits` + `kvE_subFoldBits_eq_destructors` (`rfl`) landed; scoped build green.)*
  - [x] Define the sub-level fold-bit decoder at the gate instance `j = 0`:
        `fun zs χ => σ.2 (nf0_assemble zs χ σ.1)` — the `nf_eval_depth1_fold_iff` (:5187)
        decomposition at `n = 4` over `(ZoneSpec 4 × NormalForm sig 0 1)` via `nf0_assemble`
        (NfEFold.lean:180). Semantics: `bits zs χ = true` iff σ demands an inner witness `v` in zone
        `zs` (rel. to σ's env `[u,w,x,t]`) of depth-0 monadic type `χ`. *(completed — `kvE_subFoldBits`.)*
  - [x] (If needed for Stage-A generality) note the general-`j` lift `σ.2 ∘ (assemble at depth j)`
        as a thin follow-on; the gate instance `j = 0` needs only landed `nf0_assemble`. Keep the
        general-`j` engine generalization minimal and additive; do NOT block the gate on it.
        *(deviation: skipped — gate instance `j = 0` only, per plan; general-`j` engine lift is not
        needed for the gate and is left as documented follow-on, not blocking.)*
  - [x] Confirm the read distinguishes the F4 pair at the bit level: on `σ''=char[14,16,11,20]` vs
        honest `char[14,15,10,20]`, `bits z(u,w) χ` differs (σ'' true in `(14,16)∋15`; honest
        `(14,15)=∅`) — they share `σ.1` `nfk_projFresh` but differ at `σ.2`. *(deviation: deferred to
        Phase 7 — the decoder reads `σ.2` (the exact channel where the pair differs); the concrete
        `M=ℤ` bit evaluation is the heavy `nf_characteristic` build that IS the Phase 7 mandatory
        adversarial test, done there to avoid duplicating the ℤ construction.)*
- **Timing:** ~2 hours
- **Depends on:** 1
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append the fold-bit
    decoder + any thin wrapper, after the task-320 probe section.
- **Verification:**
  - Scoped build green; the successor `σ.2` read elaborates (matches probe 1/1b); a `#eval`/`rfl`
    micro-check (in a NON-CONSUMED scratch block or via `lean_multi_attempt`) shows the fold-bit read
    yields DIFFERENT values on the F4 dishonest vs honest sub; no `simp`/`omega`/`aesop` in any body.

### Phase 3: Construct kvE_subBracket (nested sub-bracket over σ.2, forced k1v routing) [COMPLETED] (Stage A)

- **Goal:** Build `kvE_subBracket … (σ : NormalForm sig (j+1) 4) : Σ m, BracketFormula (m+1)`
  encoding σ's inner-witness structure as bracket witnesses between the honest anchor pair, read
  from `σ.2` via the forced `bracketEndChar_k1v` (:1940) zone-bit routing one arity up — the Cor 5.4
  recursive construction generalized one level, never a third anchor.
- **Tasks:**
  - [x] Define `kvE_subBracket {sig} (charBase : NormalForm sig 0 1 → Formula)
        (charK : NormalForm sig 1 1 → Formula) (σ : NormalForm sig 1 4) : Σ m, BracketFormula (m+1)`
        (gate instance; report §3 item 2 / probe-5 skeleton). The `(m+1)` shape (u's own slot)
        guarantees `fChainPred` is available. *(completed — landed; axiom-clean via `lean_verify`.)*
  - [x] Implement the forced zone routing (report §2/Q2 table): interior-zone positives →
        extra witness slots `⟨charBase χ⟩` (via `posSlots`, spliced before u's slot); interior-zone
        negatives → `(charBase χ).neg` exclusion conjuncts on the segments (`segExcl`). *(completed —
        `kvE_subInteriorZones` = [zXU, zUW, zWT] the arity-4 refinement of k1v's interior zones;
        `posSlots`/`segExcl` route the `σ.2` bits.)* *(deviation: altered — point-coincidence and
        exterior zones (`v=x/u/w/t`, `v<x`, `v>t`) are NOT re-encoded inside `kvE_subBracket`; they
        remain handled at the OUTER `kvE2_body` level (`epL`/`epR`/`ptW`, Phase 5), exactly as in
        `kvE'_body`. The sub-bracket carries only the interior-positive JOINT content — the exact gap
        F4 isolated — keeping the arity-4 slot discipline minimal and the `(m+1)` `fChainPred` shape.)*
  - [x] Cite Rabinovich Def 3.1 (md:61-74), Lemma 5.1 point-insertion split (md:134-135). *(completed —
        cited in the docstring; endpoints are the honest anchor pair supplied by the outer body splice.)*
  - [x] Verify G-guard compliance: no arity-1 collapse (G1); no third-anchor tower (G2 — the sub-bracket
        is `Σ m, BracketFormula (m+1)`, witnesses grow, anchors fixed at 2); real exclusion segments via
        `segExcl`, not trivial-top (G3); witnesses grow only (G4/G6). *(completed.)*
- **Timing:** ~3 hours
- **Depends on:** 2
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append `kvE_subBracket`.
- **Verification:**
  - Scoped build green; `kvE_subBracket` type-checks as `Σ m, BracketFormula (m+1)` (matches probe 5);
    no forbidden tactics; the construction reads `σ.2` via the Phase 2 fold bits (grep for their use,
    and for the ABSENCE of a single-point `charK (nfk_projFresh σ)` joint literal on the joint path).

### Phase 4: Define kvE_subChain and its position-recovery lemma [COMPLETED] (Stage A)

- **Goal:** Wrap the sub-bracket's Cor 5.4 F_i-chain predicate as `kvE_subChain` and land the
  position-recovery lemma at the CONSTRUCTED sub-bracket (probe 6), carrying σ's joint content by
  nested-Until evaluation point.
- **Tasks:**
  - [x] Define `kvE_subChain … (σ : NormalForm sig 1 4) : TemporalPred :=
        (kvE_subBracket charBase charK σ).2.fChainPred` (report §3 item 3; `fChainPred` available by
        the `(m+1)` shape). *(completed.)*
  - [x] Land a recovery lemma instantiating the landed proven `BracketFormula.bracket_implies_fChainPred`
        (EANegation:660) at the **constructed** `bf := (kvE_subBracket … σ).2` (probe 6, not a generic
        `bf`): from the sub-bracket holding on σ's honest interval, `kvE_subChain σ` is satisfied at a
        witness strictly inside, with NO provider environment `e` and NO residual `w = e 1`/`x = e 2`
        (probe P4 shape). *(completed — `kvE_subBracket_implies_subChain`; sole hypothesis `bf.holds`,
        no `e`, axiom-clean via `lean_verify`.)*
  - [x] Cite Rabinovich Cor 5.4 (md:154-157) and Prop 3.5 at the chain step; step shape matches
        `probe_P3_cor54_step_shape` (§3, MATCH). *(completed — cited in docstring; the lemma delegates
        to `bracket_implies_fChainPred`, which is built on `fChainFrom_step`/`fChainFrom_base`.)*
- **Timing:** ~2 hours
- **Depends on:** 3
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append `kvE_subChain`
    and its recovery lemma.
- **Verification:**
  - Scoped build green; recovery lemma closes via `bracket_implies_fChainPred` at the constructed
    sub-bracket (sole hypothesis `bf.holds`), axiom-clean, no `sorry`; no structural-identity premise
    in the signature; no `e`-equation residual.

### Phase 5: Assemble kvE2_body (corrected enriched body, successor-parameterized) [COMPLETED] (Stage A)

- **Goal:** Build `kvE2_body` = `kvE'_body` with the flattened per-sub joint literal replaced by the
  sub-bracket slot splice (`kvE_subChain σ` at σ's honest bracket position); retain all non-joint
  13.2 channels verbatim; parameterized at provider depth `j+1` per report Q1.
- **Tasks:**
  - [x] Define `kvE2_body` mirroring `kvE'_body` (:5405-5490) structurally (same-module `private`
        reuse is legal), replacing `ptSub σ = ⟨charK (nfk_projFresh σ)⟩` (:5467) and the `t`-anchored
        `pos.map exF` joint literal with the `kvE_subChain σ` sub-bracket splice. The `exF`/`P.existF 3`
        parameter drops from the joint path entirely; `P.existF 0` retained. *(completed.)*
        *(deviation: altered — signature is the CONCRETE gate instance `kvE2_body (charBase :
        NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula) (r : NormalForm sig 0 3)
        (q : NormalForm sig 1 4 → Bool) : VVecEA2`, NOT the general `{j : Nat}` header. Forced by
        report §2/Q2: `kvE_subChain` reads `σ.2` through the depth-0 `nf0_assemble`, which the report
        fixes at `j = 0`; the general-`j` fold engine is deferred follow-on. This IS the k=2 carrier
        the GO gate targets, so no `two_eq` depth-bridge is needed — see Phase 6 deviation.)*
  - [x] Retain verbatim ALL non-joint channels (gate `kvE_gate`, unary `epL`/`epR` non-joint parts,
        zones, arrangements `pinSlots`, `ptW`, `segL`/`segR`, channel-(ii) `exclAt`). *(completed —
        restated at the concrete `k = 1` sub depth; `kvE_pinDisjunct`/`kvE_exclConj` still referenced.)*
  - [x] Land a `kvE2_body_gate_fail` mirror (analogous to `kvE'_body_gate_fail` :5494). *(completed.)*
- **Timing:** ~2 hours
- **Depends on:** 4
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append `kvE2_body` and
    `kvE2_body_gate_fail`.
- **Verification:**
  - Scoped build green; `kvE2_body` type-checks at `{j : Nat}`; the joint literal `P.existF 3 σ` /
    flat `charK (nfk_projFresh σ)` does NOT appear on the joint path of `kvE2_body`;
    `kvE_pinDisjunct`/`kvE_exclConj` still referenced (non-joint channels retained); no forbidden tactics.

### Phase 6: Define bracketEndChar_kvE2 carrier and two_eq bridge [COMPLETED] (Stage A)

- **Goal:** Land the corrected carrier `bracketEndChar_kvE2` additively at the successor
  parameterization (`BracketEndCharCarrierV sig (j+1+1)`) plus its definitional `two_eq` bridge
  closing by `rfl` at `j=0` to the landed gate signature.
- **Tasks:**
  - [x] Define `bracketEndChar_kvE2` delegating to `kvE2_body`; instantiation `charBase =
        nf_depth0_char_formula`, `charK = P.existF 0`, joint channel carried by `kvE_subChain` (no
        `exF` on the joint path). *(completed; axiom-clean via `lean_verify`.)* *(deviation: altered —
        signature is the concrete gate instance `(P : ExistProviders sig atomMap 1) :
        BracketEndCharCarrierV sig 2`, not the general `{j : Nat} (P : … (j+1)) : … (j+1+1)` header,
        matching the Phase-5 `kvE2_body` concrete-instance deviation. This IS the landed k=2 gate
        signature — the exact hypotheses of `bracketEndChar_kvE'_two_eq`.)*
  - [x] Land `bracketEndChar_kvE2_two_eq` (mirror of `bracketEndChar_kvE'_two_eq` :5523) exposing
        `kvE2_body` at the k=2 standard instantiation, closing by pure `rfl`. *(completed — closes by
        `rfl`, confirming the depth threading; `bracketEndChar_kvE'`/its `two_eq` byte-identical.)*
- **Timing:** ~1.5 hours
- **Depends on:** 5
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append
    `bracketEndChar_kvE2` and `bracketEndChar_kvE2_two_eq`.
- **Verification:**
  - Scoped build green; `bracketEndChar_kvE2` header matches probes 3-4; `bracketEndChar_kvE2_two_eq`
    closes by `rfl` (a depth mismatch from the `j+1` shift would fail here); `bracketEndChar_kvE'` and
    its `two_eq` unchanged (byte-identical).

### Phase 7: F4 ℤ counterexample adversarial discrimination check (BEFORE the gate) [PARTIAL] (Stage B)

- **Goal:** Machine-verify on `M = ℤ` that the corrected carrier separates the F4 pair — the
  mandatory adversarial test, front-loaded BEFORE the gate because it is the highest-information
  failure mode and is checkable without the full gate (report Q3 Stage B).
**PARTIAL** (Phase 7): the CONSTRUCTION-LEVEL discrimination is landed and green; the full `M = ℤ`
SEMANTIC LHS-FALSE proof is folded into the spawned gate continuation (it requires the corrected
carrier's evaluation semantics on ℤ — the same machinery as Stages C/D — so it is not separable from
the gate). See the in-file verdict record (Stage B section) for the mechanism.

- **Tasks:**
  - [x] Confirm the discrimination mechanism explicitly at the construction level (report §2/Q2):
        the honest and dishonest subs produce DIFFERENT witness-slot lists because
        `kvE_subChain`/`kvE_subBracket` read `σ.2` (where they differ), not the shared `σ.1`
        `nfk_projFresh` — contrasting the F4 record's `rfl`-collapse of the flat channel-(i) content.
        *(completed — `kvE_subBracket_witnessCount` (`rfl`, the σ.2-dependence, positive analog of
        probe P1) + `kvE_subBracket_ne_of_witnessCount_ne` (discrimination corollary); axiom-clean.)*
  - [x] Land the discrimination result as a recorded lemma (the mandatory adversarial test), so it is
        available regardless of whether Stage D later completes (supports the pre-authorized fallback).
        *(completed — the two lemmas above are the landed, spawn-independent discrimination record.)*
  - [ ] Instantiate the F4 ℤ counterexample against `bracketEndChar_kvE2` and prove the LHS is FALSE
        at `(10,20)`. *(deviation: deferred to the spawned gate task — the full `M=ℤ` semantic proof
        needs the corrected carrier's ℤ evaluation semantics, i.e. the same `BracketCarrierCorrectVPrior`
        machinery as Stages C/D; not separable from the gate. Construction-level discrimination is
        landed above.)*
- **Timing:** ~2 hours
- **Depends on:** 6
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append the F4
    adversarial-test lemma.
- **Verification:**
  - Scoped build green; the F4 counterexample lemma proves LHS FALSE under `bracketEndChar_kvE2` (the
    adversarial test MUST fail against the new construction); axiom-clean. If LHS still holds, the
    `σ.2` read/encoding is incomplete — return to Phase 3, do NOT weaken the test.

### Phase 8: Discharge the per-sub positive soundness crux (soundness direction) [BLOCKED] (Stage C)

**BLOCKER** (Phases 8–10, the k=2 `BracketCarrierCorrectVPrior` gate — RECORDED CONTINUATION per the
plan's pre-authorized fallback, not an F5 defect):
- **What is deferred**: closing the k=2 correctness gate for `bracketEndChar_kvE2` to a proven GO
  (both directions), plus the full `M=ℤ` semantic LHS-FALSE (Phase 7 semantic tail).
- **Why it is a genuine scope boundary (not mere effort within this dispatch)**: the landed k1v
  simple gate this mirrors spans ~800 lines (`k1v_bracket_extract` :2150, `bracketEndChar_k1v_sound`
  :2338, `bracketEndChar_k1v_complete` :2979, assembled :3391). The k=2 ENRICHED gate adds per-sub
  sub-bracket obligations in BOTH directions; the completeness (reverse) direction is genuinely
  unprobed with no k≥2 precedent (report Q3: "plausibly multi-dispatch"), requiring the
  `IntervalPattern.holds` witness construction from `nf_eval_nf` inner witnesses (order-theoretic,
  Lemma 5.3 style). This is exactly the plan's flagged Stage-D risk and the sizing guard "a single
  'prove the gate' phase would repeat v1's sizing error."
- **What is landed to unblock the continuation**: Stage A (the full corrected carrier) + Stage B
  construction-level discrimination + the per-sub recovery lemma `kvE_subBracket_implies_subChain`
  (probe 6, the soundness crux closer, `e`-free) are all GREEN and axiom-clean. The continuation
  reuses them directly.
- **What is needed**: a dedicated follow-up task (`/spawn 321`) to (Stage C) adapt the :2338
  soundness template to the enriched body and (Stage D) build the completeness direction +
  `IntervalPattern.holds` data + arrangement disjunct + gate close, then the `M=ℤ` LHS-FALSE.
- **Prohibited workarounds** (honored): NO `sorry`, NO vacuous `def`, NO flat/single-point shortcut,
  NO provider-side pinning. The task returns a PARTIAL-GO with recorded progress; the in-file verdict
  record (Stage B/verdict section) documents this precisely.

- **Goal:** Drive the `BracketCarrierCorrectVPrior` soundness direction (carrier holds ⇒ ∃w
  realization) for `bracketEndChar_kvE2`, closing the per-sub positive obligation — the F4 crux —
  via the Phase 4 recovery lemma, reusing the landed k1v soundness template.
- **Tasks:**
  - [ ] Drive the soundness direction to the per-sub positive obligation, reusing `k1v_bracket_extract`
        (:2150) + the :2325 soundness template (report Q3 Stage C); feed `bf.holds` (the honest
        realization makes `kvE_subBracket … σ` hold on σ's honest interval).
  - [ ] Read back σ's honest witness positions via the Phase 4 recovery lemma
        (`bracket_implies_fChainPred` at the constructed `kvE_subBracket … σ`) — NO `e`-to-anchor
        equation; confirm no `P.existF 3 σ` rebinding literal appears on the joint path (so the F4
        residual does not arise).
  - [ ] Cite Rabinovich Cor 5.4 / Prop 3.5 at each chain step (G5).
- **Timing:** ~2.5 hours
- **Depends on:** 7
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append the soundness-direction
    proof scaffolding for `bracketEndChar_kvE2` (proof-side; does not edit `BracketCarrierCorrectVPrior`,
    which is consumed do-not-rebuild).
- **Verification:**
  - Scoped build green; the per-sub positive (soundness) obligation closes with no residual `e`-equation;
    axiom-clean; no `sorry` on any live path.

### Phase 9: Completeness direction — inner-witness fold extraction and IntervalPattern.holds data [BLOCKED] (Stage D)

- **Goal:** Begin the novel completeness direction (honest realization ⇒ carrier holds): extract σ's
  inner witnesses via the fold and build the sub-bracket's `IntervalPattern.holds` data — the
  order-theoretic (Lemma 5.3-style) core that has no k≥2 precedent.
- **Tasks:**
  - [ ] Fold `nf_eval_depth1_fold_iff` at `n = 4` to extract σ's inner witnesses from `nf_eval_nf`
        (report Q3 Stage D).
  - [ ] Construct the sub-bracket's `IntervalPattern.holds` witness data (monotone enumeration, range,
        point, segment conditions) from the extracted inner witnesses — Rabinovich Lemma 5.3 (md:137-152)
        style; cite per G5. Phase-per-lemma, commit-per-green.
  - [ ] Confirm the constructed `IntervalPattern.holds` data matches the `kvE_subBracket` slot
        discipline from Phase 3 (same zone routing), so the Phase 10 arrangement disjunct can consume it.
- **Timing:** ~2.5 hours
- **Depends on:** 8
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append the fold-extraction
    lemmas and the `IntervalPattern.holds` construction (proof-side).
- **Verification:**
  - Scoped build green after each committed lemma; the `IntervalPattern.holds` data type-checks against
    `kvE_subBracket`'s slot shape; no forbidden tactics in chain bodies; axiom-clean.
- **Fallback (pre-authorized):** If a *genuine obstruction* (not mere effort) blocks the
  `IntervalPattern.holds` construction, record it precisely (what fails, the exact goal, why it is not
  an effort problem), land Stages A-C + the Phase 7 discrimination record as the deliverable, and
  spawn the completeness direction as its own task (`/spawn 321`). This is a *partial GO with recorded
  progress*, not an F5 defect. Do NOT absorb the obstruction or invent a flat/single-point shortcut.

### Phase 10: Completeness direction — arrangement disjunct and gate close to GO [BLOCKED] (Stage D)

- **Goal:** Complete the completeness direction by assembling the arrangement disjunct from the Phase 9
  `IntervalPattern.holds` data, and close the k=2 `BracketCarrierCorrectVPrior` gate for
  `bracketEndChar_kvE2` to a proven GO (both directions).
- **Tasks:**
  - [ ] Build the arrangement disjunct as in the landed :2966 completeness template (report Q3 Stage D),
        consuming the Phase 9 `IntervalPattern.holds` data.
  - [ ] Close the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` to a proven GO —
        both directions closed, provider-independent (only `P.correct` consumed); no provider-side
        pinning; no `EANegation :1090/:1249`.
  - [ ] Confirm the completeness proof reuses landed machinery unchanged where the template applies;
        cite Rabinovich at each chain step (G5).
- **Timing:** ~2.5 hours
- **Depends on:** 9
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append the arrangement
    disjunct and the GO gate result.
- **Verification:**
  - Scoped build green; the k=2 GO gate theorem type-checks (both directions closed); axiom-clean; no
    `sorry` on any live path.
- **Fallback (pre-authorized):** Same as Phase 9 — a genuine gate-close obstruction is recorded and
  spawned as a partial GO, never absorbed or shortcut.

### Phase 11: Final integrity sweep, verdict record, full green build [COMPLETED]

- **Goal:** Land the verdict record (GO, or partial-GO if the Stage-D fallback fired), verify
  byte-identity of all do-not-edit landed assets, and confirm a full green, axiom-clean, sorry-free build.
- **Tasks:**
  - [x] Land a verdict record (F1–F4 house style) documenting: route b3 realized via successor
        parameterization, `kvE_subBracket`/`kvE_subChain`/`kvE2_body`/`bracketEndChar_kvE2` landed, F4
        counterexample discriminated at construction level (Phase 7), gate outcome = PARTIAL-GO with
        the recorded Stage-C/D continuation, citations per G5. *(completed — in-file verdict record.)*
  - [x] Verify byte-identity: `git diff` on `NfMultiAnchorBridge.lean` shows a pure additive `+394/-0`
        after the task-320 probe section; every do-not-edit asset unchanged; no other landed file touched.
        *(completed — `git diff` vs phase-1 baseline: 394 insertions, 0 deletions.)*
  - [x] Confirm no `simp`/`omega`/`aesop` in any chain-construction body (only `by omega` for `Fin`-index
        typing obligations, matching landed `bracketFromLists` :1900). *(completed.)*
  - [x] Run full `lake build`; confirm green, no new `sorry` on any live path, new defs/theorems
        axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) via `lean_verify`. *(completed — full
        build 1709 jobs green; 0 new axioms; no `sorry` in the modified file.)*
- **Timing:** ~1 hour
- **Depends on:** 10
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append verdict record.
- **Verification:**
  - Full `lake build` green; `git diff` additive-only; `lean_verify` axiom-clean on all new symbols;
    do-not-edit assets byte-identical.

## Testing & Validation

- [ ] Scoped build green after each phase: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`.
- [ ] Full `lake build` green at Phase 11.
- [ ] Successor `σ.2` read elaborates (Phase 2, probe 1/1b shape); `bracketEndChar_kvE2_two_eq` closes
      by `rfl` at `j=0` (Phase 6).
- [ ] `bracketEndChar_kvE2` lands additively; `bracketEndChar_kvE`/`bracketEndChar_kvE'` byte-identical.
- [ ] MANDATORY adversarial test (Stage B, Phase 7, BEFORE the gate): F4 ℤ counterexample
      (`char[14,16,11,20]` vs honest `char[14,15,10,20]`) FAILS against the new carrier (LHS FALSE at
      `(10,20)`) — discrimination via the `σ.2` read (different witness-slot lists).
- [ ] Per-sub positive soundness crux closes with NO residual `w = e 1`/`x = e 2` (no provider `e` on
      the joint path) via `bracket_implies_fChainPred` at the constructed sub-bracket (Phase 8).
- [ ] k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` = GO (proven, both directions,
      Phase 10) — OR pre-authorized partial-GO with the Stage-D obstruction recorded and spawned.
- [ ] Axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) on all new symbols; no `sorry` on any
      live path.
- [ ] No `simp`/`omega`/`aesop` in chain-construction bodies; Rabinovich cited at every chain step (G5).
- [ ] Guards G1–G6 + Corrected Anchor-Cap honored; anchor set fixed at 2; no third-anchor tower.
- [ ] EANegation :1090/:1249 untouched; no provider-side pinning (Amendment F3) — the provider
      disappears from the joint path rather than being pinned.

## Artifacts & Outputs

- `specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/02_corrected-k2-carrier-fi-chain-v2.md` (this plan; supersedes v1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — additive: sub-fold-bit
  decoder, `kvE_subBracket`, `kvE_subChain` (+ recovery lemma), `kvE2_body` (+ gate-fail mirror),
  `bracketEndChar_kvE2` (+ `two_eq`), F4 adversarial-test lemma, soundness scaffolding, completeness
  fold-extraction + `IntervalPattern.holds` + arrangement disjunct, GO (or partial-GO) gate result,
  verdict record.
- `specs/321_.../summaries/02_corrected-k2-carrier-fi-chain-v2-summary.md` (at implementation completion)
- (Conditional) a spawned completeness task if the Stage-D pre-authorized fallback fires.

## Rollback/Contingency

- All work is purely additive after the task-320 probe section. To revert: delete the appended
  definitions/theorems/verdict record; every do-not-edit landed asset is untouched, so rollback restores
  the byte-identical pre-task state (`git checkout` of the single file after snapshotting per
  `git-snapshot.sh` if the tree is dirty).
- If the `two_eq` `rfl` fails at `j=0` (Phase 6): the `j+1` parameterization threaded incorrectly through
  `kvE2_body` — fix the depth restatement in Phase 5, do NOT pattern-match on `k` with a dead depth-0 arm.
- If the soundness crux stalls at a reappearing `e`-residual (Phase 8): the joint literal was not fully
  replaced — return to Phase 5, do NOT introduce a pinning device (Amendment F3) or a flat carrier variant.
- If the F4 counterexample fails to discriminate (Phase 7): the `σ.2` read/encoding is incomplete —
  return to Phase 2/3; do not weaken the adversarial test.
- If Stage D (Phase 9/10) hits a genuine obstruction: record it precisely, land Stages A-C + the Phase 7
  discrimination record as a partial-GO deliverable, and `/spawn 321` the completeness direction as its
  own task (pre-authorized fallback). Do NOT absorb the obstruction or invent a flat/single-point shortcut.
- If a step appears to require a two-anchor single-point assertion: that is a design smell (Gabbay
  cross-check) — escalate to the orchestrator blocker ladder, do not engineer around it. Land a verdict
  record either way (GO, partial-GO, or a defect record), per F1–F4 house style; no partial theorem, no `sorry`.
