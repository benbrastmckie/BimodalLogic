# Implementation Plan: Task #305 (v39 — direct nf_eval_nf construction for KampPrior:391)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [IN PROGRESS] (Phase 10 COMPLETED — depth-0 asset landed; x=t remainder folded into Phase 11; Phases 11-15 remaining)
- **Effort**: ~12 hours (5-7 dispatches; only Phase 10 scheduled this session)
- **Dependencies**: None (resumes from build-GREEN HEAD; baseline 2 live sorries `KampPrior.lean:391`/`:394`, single `sorryAx` in `completeness_discrete`, axioms `Lean.ofReduceBool`/`Lean.trustCompiler` + `propext`/`Classical.choice`/`Quot.sound`)
- **Research Inputs**: reports/39_depth-k1-bridge-design.md (primary, Tier-1 literature-backed, H4-verified against `lean_term_goal` at `KampPrior.lean:391`); supersedes report 38's mis-scoped design
- **Artifacts**: plans/39_direct-nf-construction.md (this file)
- **Standards**: .claude/rules/artifact-formats.md, .claude/rules/state-management.md, .claude/context/formats/plan-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md, literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan supersedes the **BLOCKED Phase 8** of plan v38. Report 39 (Tier-1, H4-verified against
Rabinovich 2014 §3-5 and the verified `lean_term_goal` at `KampPrior.lean:391`) root-causes the
Phase 8 blocker: plan v38 designed a `VecEA_m` `existClosure`/`disj` wiring against the **depth-k**
conclusion of `ih_exist_1`, but the **actual** `:391` goal is at **depth k+1** —
`∃ env, nf_eval_nf M (k+1) (1+1) (insertEnv env t) sub_nf` with `sub_nf : NormalForm sig (k+1) (1+1)`.
Every `existClosure`/`existClosureLeft`/`disj` combinator is stated over `VecEA_m.holds`, a different
object; no `NF(k+1) ↔ VecEA_m` iff exists, so the plan-38 wiring is inapplicable at depth k+1.

**Corrected route (report 39, SETTLED):** build a **direct `nf_eval_nf` construction** — a uniform
`NormalForm sig (k+1) 2 → Formula` mirroring the proven `nf_succ_char_formula` (char_k1) pattern —
with negation pushed to the **formula level** (`¬` on the depth-k IH temporal formula, avoiding the
hard uniform Prop 4.2 negation) and a **compile-time 3-way case split on the decidable order atoms of
`sub_nf.1`** (not report 38's runtime `VecEA_m.disj`). The genuine new content is a **depth-k
generalization of the two-anchor arity-3 zone converter** (`nf_3var_zone_*` exist only at depth 0),
which is Rabinovich's Cor 5.4 `F_i`-chain lifted from depth-0 atom types to depth-k characteristic
types, fed through the sorry-free `bracketBuildLeft`/`bracketBuildRight`.

**Definition of done (whole plan):** `lake build` GREEN (~1700 jobs), `:391` cleared, `:394`
cleared-or-documented-off-path, live-path sorry count 2 → 0/1, axiom set unchanged, zero new
top-level `axiom`, no NF-depth/arity-tower reintroduction on the live path.

**BUDGET / PAUSE (decided by user):** this plan is **budget-constrained**. Report 39 sizes the full
discharge at 5-7 dispatches / ~1400-2300 lines, exceeding the remaining ~4-dispatch budget. **Only
Phase 10 (`mergeNF_succ_quant`) is scheduled for the current orchestration session** — it is
self-contained, off the live path, MEDIUM confidence, and broadly reusable. **The orchestration
session PAUSES after Phase 10.** Phases 11-15 resume via `/orchestrate 305 --hard` with a fresh cycle
budget. Note: Phase 10 alone does **not** drop the `:391` sorry (all three arms plus assembly are
required before `:391` can be rewired at Phase 14).

### Research Integration

- **Report 39 (primary, Tier-1, H4-verified)** — `reports/39_depth-k1-bridge-design.md`. Decisive
  findings integrated below:
  - **Root cause of Phase 8 BLOCKER (H4-confirmed):** `:391` is depth **k+1**, not depth k; the
    plan-38 `VecEA_m` wiring targeted `ih_exist_1`'s depth-k conclusion — the wrong object. No
    `NF(k+1) ↔ VecEA_m` iff exists (report 39 Executive Summary #1, adversarial table rows 1-3).
  - **Cheapest correct route (SETTLED):** direct `nf_eval_nf` construction mirroring
    `nf_succ_char_formula` (KampPrior.lean:107-177), formula-level `¬`, decidable order-atom 3-way
    case split. NOT a generic NF→VecEA_m bridge; NOT the uniform Prop 4.3/4.2 negation route
    (report 39 Q1, #2).
  - **Per-model existential bridge is VACUOUS** (`∃ vea, nf_eval ↔ vea.holds` closed by
    `⟨tt, tt_holds⟩`); any bridge must be a uniform function with a model-independent iff
    (report 39 #3, Q2).
  - **The one genuinely hard piece:** a depth-k generalization of the two-anchor arity-3 zone
    decomposition (`nf_3var_zone_*` exist only at depth 0; depth-0 NFs have no quant layer, so the
    sorry-free depth-0 base case does NOT de-risk the quant-layer coupling) — report 39 #4, Q4.
    This is the genuine inductive step of Kamp's theorem.
  - **`:391` is load-bearing at ARBITRARY depth** (`kamp_prior_expressive_completeness` →
    `nf_characterizable_temporal_prior` succ → `nf_nvar_exist_all_depths_fn … k 1`) — report 39 #5.
  - **x=t arm needs `mergeNF_succ`'s quant-layer collapse**, provable via a **diagonal-specialized**
    eval lemma (the duplicating env satisfies `E = e ∘ r` on ALL positions), NOT the general
    `renameNF_eval_iff` bijection lemma (which a non-injective merge violates) — report 39 Q3,
    NfDepth0Generalized.lean:580-582.
  - **Corrected stale claim:** `bracketBuildLeft` EXISTS sorry-free (report 38 wrongly listed it as
    missing) — VecEATranslation.lean.

### Preserved Assets

The following work is complete and must not regress. Phase 7 of plan v38 landed sorry-free
(off the live path); Phases 1-4b remain as landed. All merge/bracket/zone assets below are the
directly-reused bricks for phases 10-14.

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Phase 1: Boneyard triage + REBUILD gate | handoffs/phase-1-gate-rebuild-20260624.md | [COMPLETED] | 2026-06-24 |
| Phase 2: Lemma 3.2(2) arity firewall (`VecEA_m.arity_firewall`) | `Kamp/VecEAArityFirewall.lean` | [COMPLETED] | 2026-06-24 |
| Phase 3: Prop 4.2 model-dependent negation (`neg_2var_vec_ea`) | `EANegationClosure.lean` | [COMPLETED] | 2026-06-24 |
| Phase 4a: arbitrary-arity negation closure (`neg_vec_ea_m`) | `Kamp/EAVecNegationClosure.lean` | [COMPLETED] | 2026-06-24 (off-path) |
| Phase 4b: uniform atom/lt/tt/ff blocks (`atomAt`/`ltAt`/`tt`/`ff` + `_holds`) | `Kamp/Prop43.lean` | [COMPLETED] | 2026-06-24 (off-path) |
| Phase 7 (plan v38): leftward closure (`bracketBuildLeft`+`_correct`, `existClosureLeft`+`_correct`/`_correct_rev`) | `VecEATranslation.lean`, `VecEA_m.lean` | [COMPLETED] | 2026-07 (sorry-free, off-path) |
| char_k1 template (`nf_succ_char_formula` + `_correct`, formula-level `¬` via `nf_quant_clause_tl`) | `KampPrior.lean:107-177` | [PRESENT] | sorry-free depth-(k+1) arity-1 |
| `mergeNF_succ` (def) + `mergeNF_succ_atom` (atom layer) | `NfDepth0Generalized.lean:593,599` | [PRESENT] | depth-(k+1) quant layer OPEN (x=t arm folded into Phase 11) |
| Phase 10: `renameNF_eval_diag0` (depth-0 diagonal value-duplication congruence) | `NfDepth0Generalized.lean` | [COMPLETED] | 2026-07 (sorry-free, off-path; reusable atom-layer/depth-0 base case for Phase 11) |
| `bracketBuildRight`/`bracketBuildLeft` (+`_correct`), accept arbitrary `TemporalPred` | `VecEATranslation.lean:50` | [PRESENT] | Until/Since nesting, sorry-free |
| `nf_3var_zone_{ytx,txy,yxt,xty}` (+`_correct`) — DEPTH-0 ONLY | `VecEADecomp.lean:518-731` | [PRESENT] | Phase 11 generalizes to depth-k |
| `nf_vecEA2_past/future` (+`_correct`) — DEPTH-0 ONLY | `NfToVecEA.lean:217,259` | [PRESENT] | reference for Phase 11 |

**Do NOT re-derive, revert, or overwrite any row above.** Phases 10-14 CONSUME these; they generalize
`mergeNF_succ`, `nf_3var_zone_*`, and the bracket builders to depth k rather than rebuilding them.

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014 §3-5)

Paper (ground truth): `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.
Full lemma inventory in report 39 §"H3 Lemma-level mapping table". Live-path-relevant rows:

| Source (Rabinovich 2014) | Lean identifier (to build) | Type signature (from report 39, verified) | Phase |
|---|---|---|---|
| diagonal (x=t) arity collapse at depth k+1 (restricted to realizable forms) | x=t arm via char[t,t]=char[t] on realizable sub-forms (or Phase-14 diagonal-consistency guard) | depth-(k+1) diagonal collapse restricted to realizable forms; general `mergeNF_succ_quant` iff refuted as a NON-theorem (Phase 10) | 11 (folded in from 10) |
| depth-0 diagonal value-duplication congruence (landed) | `renameNF_eval_diag0` | `nf_eval_nf M 0 a E (renameNF r f nf) ↔ nf_eval_nf M 0 b e nf` (drops `hsec`, keeps `hsec2`+`hcomp2`) | 10 [COMPLETED] |
| §5 three-zone split, lifted depth-0 → depth-k | `nf_zone_depthk_*` (generalize `nf_3var_zone_*`) | depth-k two-anchor arity-3 `∃ y` zone converter; point/segment types = depth-k IH formulas | 11 |
| Prop 3.5 / Cor 5.4 — Since chain (past arm) | past-arm converter via `bracketBuildLeft` | `NormalForm sig (k+1) 2 → Formula` for the `x<t` case; iff | 12 |
| Prop 3.5 / Cor 5.4 — Until chain (future arm) | future-arm converter via `bracketBuildRight` | mirror of Phase 12 for the `t<x` case; iff | 13 |
| §5 inductive step — arity-2 ∃ engine (the `:391` GOAL) | `exist_tl_fn_{k+1}` uniform `NormalForm sig (k+1) 2 → Formula` | decidable order-atom 3-way split (x=t/x<t/t<x) + `⊥` arm; wired into `KampPrior.lean:391` | 14 |

## Goals & Non-Goals

**Goals**:
- Build a uniform `NormalForm sig (k+1) 2 → Formula` (the depth-(k+1) arity-2 existential engine, the
  sibling of `exist_tl_fn_k`) DIRECTLY over `nf_eval_nf`, with formula-level negation and a decidable
  `sub_nf.1` order-atom 3-way case split, and wire it into `KampPrior.lean:391` (`| 1 =>` arm).
- Reuse (never rebuild) `nf_succ_char_formula`, `mergeNF_succ`/`mergeNF_succ_atom`,
  `bracketBuildLeft`/`bracketBuildRight`, and the depth-0 `nf_3var_zone_*` as the depth-k template.
- Drop live-path sorry count 2 → 1 at Phase 14; verify `:394` cleared/off-path at Phase 15.

**Non-Goals** (see Postmortem Constraints for the binding "Do NOT" list):
- No `VecEA_m` `existClosure`/`existClosureLeft`/`disj` wiring for `:391` (report 39: inapplicable —
  the correctness lemmas are over `VecEA_m.holds`, not `nf_eval_nf`; no NF(k+1)↔VecEA_m iff).
- No per-model existential bridge (`∃ vea, nf_eval ↔ vea.holds` — vacuous, closed by `⟨tt,…⟩`).
- No uniform Prop 4.2/4.3 dependency; negation stays at the formula level.
- No De Morgan / positive-NF restructure of Prop 4.3.
- No NF-depth parameter beyond the existing `k`, no arity tower, no `k+2` NF-disjunction, no `mutual`
  char/exist def.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the Phase 8 BLOCKER, report 39's
adversarial verification, and this task's 38+ prior-plan churn history.

**Do NOT**:
- Wire `VecEA_m.existClosure`/`existClosureLeft`/`disj` (or any `VecEA_m.holds`-typed combinator)
  into `:391`. Report 39 root-caused this as the Phase 8 failure: those lemmas relate `VecEA_m.holds`,
  but the `:391` goal is `nf_eval_nf M (k+1) 2 …`; no NF(k+1)↔VecEA_m iff exists. This is the exact
  mis-scope that produced the BLOCKER — do not repeat it.
- Ship a **per-model** existential bridge (`∃ vea : VecEA_m 2, nf_eval ↔ vea.holds env`) — VACUOUS,
  closed by `⟨tt, tt_holds⟩`/`⟨ff,…⟩` for any input (report 38/39 confirmed). Every converter built
  here must be a **uniform total function** `NormalForm sig (k+1) 2 → Formula` with a
  model-independent iff, exactly like `nf_succ_char_formula`.
- Depend on a **uniform Prop 4.2/4.3** (complete conjunction, faithful bidirectional negation) —
  report 39: the direct construction pushes negation to the formula level (`¬` on the depth-k IH
  temporal formula), which is model-independent and trivial. Do NOT reach for uniform VecEA negation.
- De Morgan / positive-NF restructure of Prop 4.3 (relocates the obstruction from `not` to `all`).
- Reintroduce any NF-depth / arity-tower parameter beyond `k`, arity-4+ existential converter, `k+2`
  NF-disjunction, or `mutual` char/exist def. This is the durable failure mode across plans 11-38
  (sorry moved `FOToVEA:118` → `KampPrior:154` → `:391`); do not re-create it.
- Use `renameNF_eval_iff` (NfDepth0Generalized:440) for the x=t collapse — it requires a **bijection**
  (`f ∘ r = id` on the larger arity), which the **non-injective** merge violates. Phase 10 uses the
  **diagonal-specialized** eval lemma instead (NfDepth0Generalized:580-582): the duplicating env
  satisfies `E = e ∘ r` on ALL positions.
- Add any `sorry` to the live import path. Off-path scaffolding (phases 10-13) may carry its own
  sorries only while quarantined; nothing new lands on the `completeness_discrete` path except a
  sorry-free discharge at Phase 14.
- Revert or overwrite any Preserved Asset (Phases 1-4b, Phase-7 leftward closure, char_k1,
  `mergeNF_succ`/`_atom`, bracket builders, depth-0 zone lemmas).

**MUST preserve**:
- Build GREEN (~1700 jobs) at every phase boundary.
- Axiom set exactly `Lean.ofReduceBool`/`Lean.trustCompiler` + `propext`/`Classical.choice`/
  `Quot.sound`; zero new top-level `axiom`.
- The `nf_succ_char_formula` (char_k1) pattern as the template; the sorry-free `bracketBuildLeft`/
  `bracketBuildRight` (arbitrary `TemporalPred`) and `mergeNF_succ`/`mergeNF_succ_atom` as reused
  bricks.
- `:391` and `:394` stay as the two baseline sorries until Phase 14 (`:391`) and Phase 15 (`:394`).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The `:391` goal is depth **k+1** arity-2 `∃ env, nf_eval_nf M (k+1) (1+1) (insertEnv env t) sub_nf`
  (H4-verified via `lean_term_goal` at KampPrior.lean:391:7; for `env : Fin 1`,
  `insertEnv env t = Fin.cons (env 0) (fun _ => t)`, so it is `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`).
- The route is the DIRECT `nf_eval_nf` construction (mirror `nf_succ_char_formula`), NOT a generic
  NF→VecEA_m bridge and NOT uniform Prop 4.3. (Report 39 Executive Summary #2; adversarial table.)
- The witness-position (past/present/future) is a **compile-time decidable case split on `sub_nf.1`**
  order atoms (`AtomKind.order 0 1` = `x<t`, `order 1 0` = `t<x`), not a runtime `VecEA_m.disj`.
  Both-true ⇒ unsatisfiable atom layer ⇒ `A := ⊥`. (Report 39 D1.)
- The x=t arm requires `mergeNF_succ`'s quant-layer collapse; `char_k1` alone cannot (it takes an
  arity-1 NF, the x=t env is arity-2 diagonal). (Report 39 Q3.)
- The two-anchor quant layer (Q4) cannot be closed by the single-anchor depth-k IH directly; it needs
  the depth-k zone converter (Phase 11). This is the irreducible crux. (Report 39 Q4.)
- Uniform Prop 4.3 remains OFF the completeness path and is a separate `/spawn` candidate.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 11 (crux) exceeds one dispatch. | M | H | Report 39 flags it as ~400-700 lines / likely 2 dispatches. Split into 11a (`y<x`/`y=x` zones + `bracketBuildLeft` plumbing) and 11b (`x<y<t`/`y=t`/`y>t` zones + `bracketBuildRight` plumbing) at dispatch time; each sub-phase ends GREEN off-path. Do NOT churn a single dispatch past its budget. |
| Phase 10 `mergeNF_succ_quant` diagonal env compatibility (`E = e ∘ r` on all positions) is more intricate than the 580-582 sketch. | M | M | Mirror the existing `mergeNF_succ_atom` proof structure; the atom layer already lands. If the quant iff resists after a bounded budget, land `mergeNF_succ_quant`'s forward direction first (still off-path GREEN) and split the reverse into 10.2. |
| The depth-k IH formulas (`exist_tl_fn_k`) do not compose cleanly as bracket point/segment types. | H | M | `bracketBuildLeft`/`bracketBuildRight` accept arbitrary `TemporalPred` (verified); Phase 11 feeds `exist_tl_fn_k sub_nf'` (and its `¬`) as the `TemporalPred`. Prove the zone iff against `nf_eval_nf` directly, mirroring the depth-0 `nf_3var_zone_*_correct` proofs declaration-by-declaration. |
| Phase 14 assembly surfaces a `Fin.cons`/`insertEnv` index-ordering mismatch. | H | M | Phase 14 first proves the assembled `exist_tl_fn_{k+1}` iff against `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` as a standalone off-path lemma; `insertEnv env t = Fin.cons (env 0) (fun _=>t)` is proved inline at KampPrior:482. Build GREEN before touching `:391`. |
| `:394` (n≥2) turns out reachable on the live path, needing general-m closure this plan does not build. | M | L | Phase 15 runs `lean_verify completeness_discrete` to check reachability. If off-path, document as non-blocking (final count 1). If reachable requiring general-m closure, STOP and record a divergence note recommending the `/spawn` uniform-Prop-4.3 task; do NOT reintroduce an arity tower. |
| Regressing the GREEN baseline or the axiom set. | H | L | `lake build` GREEN + `#print axioms completeness_discrete` + `grep '^axiom ' Theories/` at every phase boundary; off-path scaffolding stays quarantined until Phase 14 consumes it sorry-free. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 10 [COMPLETED] | -- |
| 2 | 11 (incl. x=t arm; may split 11a, 11b) | -- |
| 3 | 12, 13 | 11 |
| 4 | 14 | 11, 12, 13 |
| 5 | 15 | 14 |

Phase 10 [COMPLETED] landed the depth-0 diagonal congruence `renameNF_eval_diag0`; its depth-(k+1)
x=t remainder is folded into Phase 11 (shared realizability crux). Phase 11 now builds both the
depth-k zone converter (feeding the past/future arms) and the x=t arm. Phases 12 and 13 (past/future
arms) both consume Phase 11's zone converter and can run in parallel. Phase 14 assembles 11 (x=t) +
12 + 13 and rewires `:391`. Phase 15 verifies. **Resume dispatches Phase 11** (see Overview).

### Historical Phase Ledger (plans 37/38 — closed, do not re-execute)

The executable phases below are numbered **10-15 with plain integers** (orchestrator heading-scan
requires `### Phase N: <name> [NOT STARTED]`), continuing from plan v38's Phase 9. Correspondence to
report 39's `8a-8e` decomposition is recorded per-phase.

| Phase | Name | Terminal Status | Disposition |
|---|---|---|---|
| 1-6 (plan 37) | Boneyard triage … verification | terminal | Context only; see plan 37/38 ledgers. |
| 7 (plan 38) | Leftward existential closure (`existClosureLeft`) | [COMPLETED] | Sorry-free, off-path; preserved asset. NOTE: its `VecEA_m` combinators are NOT used for `:391` (report 39: inapplicable at depth k+1). Retained as a library asset. |
| 8 (plan 38) | n=1 witness-position split + `:391` rewire | [CLOSED-BLOCKED — SUPERSEDED BY PHASES 10-14] | Mis-scoped: targeted depth-k `VecEA_m` wiring; `:391` is depth k+1 over `nf_eval_nf`. Replaced by the direct construction in phases 10-14 (report 39). |
| 9 (plan 38) | Verification | [DEFERRED — FOLDED INTO PHASE 15] | Carried forward verbatim as Phase 15. |

---

### Phase 10: mergeNF_succ_quant — diagonal quant-layer collapse (x=t arm) [COMPLETED]

*(= report 39 Phase 8a. Depth-0 asset landed sorry-free; depth-(k+1) x=t remainder re-scoped into
Phase 11 on resume — see the "Re-scoped on resume" note below.)*

**Re-scoped on resume** (user-approved fold, session sess_1783315428_d370a2): Phase 10's landed
deliverable is `renameNF_eval_diag0` (the **depth-0** value-duplication diagonal congruence,
sorry-free, in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean`) — a
preserved, reusable asset for the atom-layer transfer and the `k=0` base case. The remaining
**depth-(k+1) x=t arm** is a **genuine NON-theorem in its Phase-10 form** (per the Phase-10 PARTIAL
handoff diagnosis: the diagonal congruence's quant `←` direction fails because
`liftIdx (totalUnskip)` is non-injective and cannot recover non-diagonal-realizable sub-forms).
This is the SAME depth-`k` realizability crux Phase 11's zone / characteristic-NF machinery
addresses, so the x=t remainder is **folded into Phase 11** (below) rather than pursued
standalone. Phase 10 is therefore COMPLETE as scoped (depth-0 asset landed GREEN, off-path); the
detailed PARTIAL diagnosis and divergence notes are preserved verbatim below for the record.

**PARTIAL** (Phase 10, session sess_1783306400_33dd64):
- **Landed sorry-free**: `renameNF_eval_diag0` (NfDepth0Generalized.lean, ~48 lines) — the
  **depth-0** diagonal (value-duplication) congruence
  `nf_eval_nf M 0 a E (renameNF r f nf) ↔ nf_eval_nf M 0 b e nf`, using value-compat
  `hcomp` (`e = E∘f`) + `hcomp2` (`E = e∘r`) + retraction `hsec2` (`r∘f=id`) + `M.lt`
  irreflexivity, dropping the failing `hsec` (`f∘r=id`). Axioms `[propext, Classical.choice,
  Quot.sound]`, no `sorryAx`. This is the reusable atom-layer transfer + the `k=0` base case.
- **Blocked (NON-theorem, not merely hard)**: the depth-`k+1` lift `mergeNF_succ_quant` / the
  full x=t arm iff. After the atom layer transfers via `renameNF_eval_diag0`, the residual
  quant-layer obligation (captured via `lean_goal`, NfDepth0Generalized.lean succ case) is:
  ```
  (∀ sub_nf : NormalForm sig K (a+1),
      (∃ x, nf_eval_nf M K (a+1) (Fin.cons x E) sub_nf) ↔ nq (renameNF (liftIdx f) (liftIdx r) sub_nf))
    ↔
  (∀ sub_nf : NormalForm sig K (b+1),
      (∃ x, nf_eval_nf M K (b+1) (Fin.cons x e) sub_nf) ↔ nq sub_nf)
  ```
  - **What was tried**: (1) plain top-level iff `nf_eval (k+1) 2 [t,t] sub_nf ↔ nf_eval (k+1) 1 [t]
    (mergeNF_succ sub_nf 0 0)` — refuted: the arity-2 atom layer constrains BOTH positions
    against `M(t)`, the merged arity-1 layer only position 1, so `.mpr` fails whenever
    sub_nf's pred rows at positions 0,1 disagree. (2) The `renameNF_eval_diag` congruence
    (evaluate the duplicated form on the bigger diagonal env) — the `→` half of its quant
    layer IS provable (round-trip `renameNF (liftIdx f)(liftIdx r)(renameNF (liftIdx r)(liftIdx f) g)=g`
    via `skipFin`/`liftIdx f` injectivity + IH), but the `←` half is a genuine non-theorem.
  - **Why stuck (root cause)**: the quant layer of the *duplicated* form `renameNF r f nf`
    ranges over ALL `sub_nf : NF K (a+1)`. The collapse-then-expand
    `renameNF (liftIdx r)(liftIdx f)(renameNF (liftIdx f)(liftIdx r) sub_nf)` does NOT recover
    `sub_nf` because `liftIdx r` (= `liftIdx (totalUnskip …)`) is **non-injective**. A
    `sub_nf` that is not diagonal-invariant is unrealizable on the diagonal env `Fin.cons x E`
    (its `∃ x …` is false), yet `nq` of its collapse can be `true` — so the duplicated form is
    generally NOT satisfied by `E` even when the original is satisfied by `e`. This is exactly
    the **realizability structure** the Phase-11 depth-`k` zone converter / characteristic-NF
    machinery supplies. Report-39's Phase-8a scoping ("x=t collapse self-contained, before
    Phase 11") holds only at depth 0; at depth `k ≥ 1` the x=t arm is **NOT separable** from
    the Phase-11 crux.
  - **What is needed**: build Phase 11's depth-`k` realizability machinery FIRST (or a
    characteristic-NF collapse lemma `mergeNF_succ char[t,t] = char[t]` restricted to
    diagonal-invariant/realizable sub-forms), then the x=t arm follows. Recommend RE-SCOPING:
    fold Phase 10's remaining content into Phase 11 (they share the same inductive crux), or
    add a compile-time diagonal-consistency guard on `sub_nf` in the Phase-14 assembly.
  - **Prohibited fallbacks honored**: no `sorry` added to any path (baseline 2 unchanged); no
    vacuous placeholder; no `VecEA_m` wiring / per-model bridge / uniform Prop 4.2-4.3 /
    arity-tower; `renameNF_eval_iff` bijection route correctly avoided.

**Goal**: Prove `mergeNF_succ_quant` — the **quant-layer** correctness of `mergeNF_succ` on the
**duplicating (diagonal) environment** — giving the reduction
`nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf ↔ nf_eval_nf M (k+1) 1 (fun _=>t) (mergeNF_succ sub_nf 0 0)`,
so the **x=t arm** discharges as `char_k1 ∘ mergeNF_succ`. Self-contained, off the live import path;
also unblocks the `:394`/arity-collapse territory. MEDIUM confidence.

**Reference grounding (H3, Tier 1)**: report 39 Q3; NfDepth0Generalized.lean:580-582 (the diagonal
env satisfies `E = e ∘ r` on ALL positions, so the one-directional congruence dropping `hsec`
applies where the general bijection lemma does not). `mergeNF_succ` def + `mergeNF_succ_atom` are the
reused bricks (NfDepth0Generalized:593,599).

**Tasks**:
- [ ] Read NfDepth0Generalized.lean:560-620 (`mergeNF_succ`, `mergeNF_succ_atom`, the 580-582
  diagonal comment, and `renameNF_eval_iff` at :440 to confirm why the bijection route is wrong).
- [ ] State `mergeNF_succ_quant`: the quant-layer eval iff for `mergeNF_succ sub_nf 0 0` on the
  duplicating env `Fin.cons t (fun _=>t)` (or the arity-general `full_val` diagonal), mirroring
  `mergeNF_succ_atom`'s statement shape but on the `.2` (quant) component.
- [ ] Prove it via the **diagonal-specialized** congruence (drop `hsec`, keep `hsec2` + the env
  compatibility `hcomp2 : E = e ∘ r` that the duplicating env satisfies). Do NOT invoke
  `renameNF_eval_iff` (non-injective merge violates its bijection hypothesis).
- [ ] Assemble the **x=t arm** as `char_k1 (mergeNF_succ sub_nf 0 0)` and prove its iff:
  `temporal_truth M atomMap t (char_k1 (mergeNF_succ sub_nf 0 0)) ↔ nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf`
  (using `char_k1_correct` + `mergeNF_succ_atom` + `mergeNF_succ_quant`). Keep as a named off-path
  lemma; do NOT touch `:391` this phase.
- [ ] `lean_verify` each new declaration: sorry-free, axioms `[propext, Classical.choice, Quot.sound]`,
  no `sorryAx`, zero new top-level axioms.

**File targets**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` (append
`mergeNF_succ_quant` + the x=t arm lemma). Append-only; off the live import path.

**Estimated output**: ~250-400 lines. **Done when**: `mergeNF_succ_quant` + the x=t arm iff are
sorry-free and `lean_verify`-clean; `lake build` GREEN (~1700 jobs); live-path sorry count UNCHANGED
at 2 (new decls off-path).

**Confidence**: MEDIUM (report 39). **Timing**: ~3 hours. **Depends on**: none.

**Verification**:
- `lake build` GREEN (~1700 jobs).
- `lean_verify …mergeNF_succ_quant` and the x=t arm lemma → axioms `[propext, Classical.choice,
  Quot.sound]`, no `sorryAx`, no new axioms.
- `grep '^axiom ' Theories/` → zero new top-level axioms.
- Live-path sorry count UNCHANGED at 2 (`:391`, `:394`).
- No `renameNF_eval_iff` appeal in `mergeNF_succ_quant`; no NF-depth/arity-tower growth.

**Split fallback**: if the quant iff resists after a bounded budget, land the forward direction as
Phase 10.1 (off-path GREEN) and the reverse as Phase 10.2; each sub-phase ends GREEN.

**>>> PAUSE HERE. The orchestration session ends after Phase 10 commits GREEN. Phases 11-15 resume
via `/orchestrate 305 --hard` with a fresh cycle budget. <<<**

---

### Phase 11: Depth-k two-anchor arity-3 zone converter (incl. x=t arm) [PARTIAL]

**PARTIAL** (Phase 11a, session sess_1783315428_d370a2): depth-k atom/order extraction
groundwork landed sorry-free, off-path, in new file
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneDepthK.lean`
(`nf_eval_atom_layer`, `nf3_order_iff`, and the six `nf3_order_{yx,yt,xy,xt,ty,tx}` facts —
the exact `h_o_*` hypotheses `reconstruct_nf_3var` consumes, generalized to depth k). Full
`lake build` GREEN (1700 jobs); live-path sorry baseline UNCHANGED at 2; axioms
`[propext, Classical.choice, Quot.sound]` on every new decl; zero new top-level axioms.
**11b crux REMAINS**: the faithful depth-k zone converter (and the x=t arm downstream of it) is
NOT landed — the naive projection-based `VecEA2` generalization is a NON-theorem at depth k
(the quant layer `qnf.2 : NormalForm sig (k-1) 4 → Bool` couples y,x,t through a shared 4th
quantified variable and does not factor through per-variable projections; same structural
failure as the Phase-10 x=t non-theorem). No strategic sorry was stated for it because any
non-vacuous statement presupposes the joint-characteristic-type construction (an
`∃ formula, …` is vacuous / Postmortem-forbidden). See the DIVERGENCE NOTE in
`NfZoneDepthK.lean` for the full obstruction analysis. Resume Phase 11b next dispatch: build the
`∃ y`-through-coupled-quant-layer converter via `bracketBuildLeft`/`bracketBuildRight` fed with
depth-k joint characteristic types (Rabinovich §5 / Cor 5.4), then the folded-in x=t arm.

*(= report 39 Phase 8b. THE CRUX. MEDIUM-LOW confidence. Likely 2 dispatches — split into 11a/11b at
dispatch time if a single dispatch cannot land it GREEN. **Absorbs the depth-(k+1) x=t arm folded in
from Phase 10** — the two share the same depth-`k` realizability crux; see the Phase 10 "Re-scoped on
resume" note.)*

**Goal**: Generalize the depth-0 `nf_3var_zone_{ytx,txy,yxt,xty}` (`VecEADecomp.lean:518-731`) from
depth 0 to **depth k**: a converter that expresses the two-anchor arity-3 existential
`∃ y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _=>t))) qnf` (anchored at TWO points `x`, `t`) as
a **nested Since/Until bracket** splitting `y` by zone (`y<x`, `y=x`, `x<y<t`, `y=t`, `y>t`), with the
**depth-k IH formulas** (`exist_tl_fn_k` and its `¬`) as the bracket point/segment `TemporalPred`
types. This is Rabinovich's Cor 5.4 `F_i`-chain lifted from depth-0 atom types to depth-k
characteristic types (report 39 Q4).

**x=t arm (folded in from Phase 10):** after building the depth-`k` two-anchor arity-3 zone
converter / realizability machinery above, prove the **x=t arm** — the depth-(k+1) diagonal
quant-layer collapse `mergeNF_succ char[t,t] = char[t]` **restricted to realizable (diagonal-
invariant) forms** — using the same characteristic-NF realizability structure the zone converter
supplies. `renameNF_eval_diag0` (Phase 10's sorry-free depth-0 diagonal congruence,
NfDepth0Generalized.lean) is an **available reusable asset** for the atom-layer transfer and the
depth-0 base case. If the restricted collapse resists within budget, the x=t arm may instead be
discharged as a **compile-time diagonal-consistency guard on `sub_nf`** deferred to the Phase 14
assembly (per the Phase-10 handoff `next_action_hint`); either route keeps the arm off the live
path until Phase 14 consumes it. The general (unrestricted) `mergeNF_succ_quant` iff is a
NON-theorem and is NOT attempted (Phase 10 diagnosis).

**Reference grounding (H3, Tier 1)**: Rabinovich 2014 §5 (md:119-173) interval split, Cor 5.4
(md:157) `F_i` chain; `nf_3var_zone_*` (depth-0 template, VecEADecomp:518-731); `bracketBuildLeft`/
`bracketBuildRight` (arbitrary `TemporalPred`, VecEATranslation:50); `exist_tl_fn_k` (depth-k IH,
in scope at `:391`).

**Tasks**:
- [x] Read `VecEADecomp.lean:518-731` (`nf_3var_zone_*` + `_correct`) and `NfToVecEA.lean:217,259`
  (`nf_vecEA2_past/future`) as the depth-0 templates; read `bracketBuildLeft/Right` signatures.
  *(11a done: templates + `NormalForm`/`nf_eval_nf` structure read.)*
- [x] Landed sorry-free depth-k **atom/order extraction** groundwork in `NfZoneDepthK.lean`:
  `nf_eval_atom_layer` (uniform depth-k atom-layer iff), `nf3_order_iff` (general depth-k order
  extraction on `[y,x,t]`), and the six `nf3_order_{yx,yt,xy,xt,ty,tx}` facts. *(deviation from
  original task list: extraction layer added as explicit reusable lemmas — this is the part of
  the depth-k converter that genuinely generalizes; consumed by every zone forward direction +
  Phase-14 split.)*
- [ ] Define the depth-k zone converter(s) `nf_zone_depthk_*` over `NormalForm sig k 3`, parameterized
  by the depth-k IH formula function (point/segment `TemporalPred` = `exist_tl_fn_k _` / its `¬`).
  *(deferred to 11b — the CRUX: naive projection-based `VecEA2` is a NON-theorem at depth k, see
  DIVERGENCE NOTE in `NfZoneDepthK.lean`; needs joint-characteristic-type construction.)*
- [ ] Prove the zone iff against `nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _=>t))) qnf` directly,
  mirroring the depth-0 `nf_3var_zone_*_correct` proofs, feeding the depth-k IH formulas through
  `bracketBuildLeft`/`bracketBuildRight`. *(deferred to 11b.)*
- [x] `lean_verify` each landed declaration sorry-free; off the live path. *(11a decls verified:
  axioms `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.)*

**File targets**: new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneDepthK.lean`
(imports the depth-0 zone lemmas + bracket builders as templates). Off the live import path.

**Estimated output**: ~400-700 lines. **Done when**: the depth-k zone converter + its iff are
sorry-free and `lean_verify`-clean; `lake build` GREEN; live-path sorry count UNCHANGED at 2. If split:
11a ends GREEN with the `y<x`/`y=x` (past-facing) zones; 11b ends GREEN with the `x<y<t`/`y=t`/`y>t`
zones + full converter.

**Confidence**: MEDIUM-LOW (report 39 — the genuine inductive step of Kamp's theorem; untested at
depth 0 because depth-0 NFs have no quant layer). **Timing**: ~4-6 hours (likely 2 dispatches).
**Depends on**: none (Phase 10 is [COMPLETED]; Phase 11 reuses its landed `renameNF_eval_diag0`
asset for the x=t arm's depth-0 base case, plus the preserved depth-0 templates + IH).

**Verification**: `lake build` GREEN; `lean_verify` on each new decl → baseline axioms, no `sorryAx`;
`grep '^axiom '` zero new; live-path sorry count unchanged at 2; no arity-4+ / NF-depth-tower growth.

---

### Phase 12: x<t (past) arm converter via bracketBuildLeft [NOT STARTED]

*(= report 39 Phase 8c. MEDIUM confidence.)*

**Goal**: Assemble the **x<t (past)** case into a uniform `NormalForm sig (k+1) 2 → Formula`: for each
quant clause `qnf : NormalForm sig k 3` of `sub_nf`, apply the Phase-11 zone converter and
`bracketBuildLeft` (Since-nesting), with formula-level `¬` for the not-realized (`= false`) clauses;
prove the iff against `∃ x, x<t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` restricted to
the `A(0<1)=true` atom-layer branch.

**Reference grounding (H3, Tier 1)**: Prop 3.5 / Cor 5.4 Since-chain (report 39 Q1/Q4); Phase-11 zone
converter; `bracketBuildLeft` (VecEATranslation:50); `nf_succ_char_formula` (formula-level `¬`
template, KampPrior:107-177).

**Tasks**:
- [ ] Build the past-arm function: atom layer (incl. `x<t` order) as a depth-0 arity-2 predicate
  conjunction; quant layer as per-`qnf` clauses `(∃y … zone …) ↔ Q qnf` via Phase-11 + `bracketBuildLeft`,
  negated at the formula level for `Q qnf = false`.
- [ ] Prove the past-arm iff against `nf_eval_nf` (the `A(0<1)=true` branch), mirroring
  `nf_succ_char_formula_correct` structure.
- [ ] `lean_verify` sorry-free; off the live path.

**File targets**: `Kamp/NfZoneDepthK.lean` or a new small module, then imported. Off the live path.

**Estimated output**: ~300-450 lines. **Done when**: past-arm converter + iff sorry-free,
`lean_verify`-clean; `lake build` GREEN; live-path sorry count unchanged at 2.

**Confidence**: MEDIUM. **Timing**: ~3-4 hours. **Depends on**: 11.

**Verification**: `lake build` GREEN; `lean_verify` baseline axioms, no `sorryAx`; zero new axioms;
live-path sorry count unchanged; no arity-tower/uniform-Prop-4.2 appeal.

---

### Phase 13: t<x (future) arm converter via bracketBuildRight [NOT STARTED]

*(= report 39 Phase 8d. MEDIUM confidence — mirror of Phase 12.)*

**Goal**: Mirror of Phase 12 for the **t<x (future)** case, using `bracketBuildRight` (Until-nesting)
instead of `bracketBuildLeft`; iff against the `A(1<0)=true` atom-layer branch.

**Reference grounding (H3, Tier 1)**: Prop 3.5 / Cor 5.4 Until-chain; `bracketBuildRight`
(VecEATranslation:50); Phase-11 zone converter; Phase-12 as the structural mirror template.

**Tasks**:
- [ ] Build the future-arm function (mirror of Phase 12 via `bracketBuildRight`); prove its iff
  against `nf_eval_nf` (the `A(1<0)=true` branch).
- [ ] `lean_verify` sorry-free; off the live path.

**File targets**: same module as Phase 12. Off the live path.

**Estimated output**: ~250-400 lines. **Done when**: future-arm converter + iff sorry-free,
`lean_verify`-clean; `lake build` GREEN; live-path sorry count unchanged at 2.

**Confidence**: MEDIUM (mirror). **Timing**: ~3 hours. **Depends on**: 11.

**Verification**: as Phase 12.

---

### Phase 14: Assembly — order-atom 3-way split + rewire KampPrior:391 [NOT STARTED]

*(= report 39 Phase 8e. MEDIUM-HIGH confidence, contingent on 11/12/13.)*

**Goal**: Assemble the uniform `exist_tl_fn_{k+1} : NormalForm sig (k+1) 2 → Formula` via a
**decidable compile-time 3-way case split on `sub_nf.1`** order atoms — `A(0<1)=false ∧ A(1<0)=false`
→ x=t arm (Phase 11, folded in from Phase 10); `A(0<1)=true` → x<t arm (Phase 12); `A(1<0)=true`
→ t<x arm (Phase 13); both true → `A := ⊥` (unsatisfiable atom layer) — prove the combined iff against
`∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`, and **rewire `KampPrior.lean:391`**
(`| 1 =>` arm) to consume it, dropping live-path sorry count 2 → 1.

**Reference grounding (H3, Tier 1)**: report 39 D1 (decidable order-atom split, `⊥` arm), the verified
`:391` goal (`insertEnv env t = Fin.cons (env 0) (fun _=>t)`, KampPrior:482); phases 11/12/13 arms
(x=t from Phase 11, folded in from Phase 10).

**Tasks**:
- [ ] Build `exist_tl_fn_{k+1}` with the decidable `sub_nf.1` order-atom 3-way case split (+ `⊥` arm);
  prove the standalone iff against `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` as a
  named off-path lemma; `lake build` GREEN before touching `:391`.
- [ ] Add the imports required by the assembly (phases 10-13 decls) to `KampPrior.lean`; `lake build`
  to confirm no cycle and GREEN **before** editing the arm.
- [ ] Replace the `sorry` at `KampPrior.lean:391` (`| 1 =>` arm) with the assembled construction
  (rewrite `insertEnv env t` to `Fin.cons (env 0) (fun _=>t)` via the KampPrior:482 identity);
  `lake build` GREEN.
- [ ] `lean_verify completeness_discrete`: confirm the `:391` arm discharged, its `sorryAx` source
  gone; live-path sorry count now 1 (only `:394`).

**File targets**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (imports + the `:391`
arm); assembly lemma in `Kamp/NfZoneDepthK.lean` or a new small module.

**Estimated output**: ~200-350 lines. **Done when**: `:391` sorry removed, `lake build` GREEN,
`lean_verify completeness_discrete` shows the `:391`-sourced `sorryAx` gone, live-path sorry count
2 → 1, baseline axioms unchanged.

**Confidence**: MEDIUM-HIGH (contingent on 11/12/13). **Timing**: ~3 hours. **Depends on**: 11, 12, 13.

**Verification**:
- `lake build` GREEN (~1700 jobs); `grep -n sorry KampPrior.lean` shows only the `:394` arm on the live path.
- `lean_verify completeness_discrete` → `:391`-sourced `sorryAx` gone; live-path sorry count 2 → 1.
- `#print axioms completeness_discrete` = baseline; `grep '^axiom ' Theories/` = zero new axioms.
- No `VecEA_m.holds`-wiring, per-model bridge, uniform Prop 4.2/4.3, NF-depth/arity-tower appeal on the live path.

---

### Phase 15: Verification — clear/off-path :394, axiom + sorryAx audit [NOT STARTED]

*(Carried forward from plan v38 Phase 9.)*

**Goal**: Confirm `:394` (n≥2) cleared or provably off the live path with documentation, confirm full
GREEN and the baseline axiom set, and record the final live-path sorry inventory (0, or 1 with `:394`
documented off-path). Emit closure outputs.

**Tasks**:
- [ ] `lean_verify completeness_discrete` to determine whether `:394` (`| n+2 =>` arm) is reachable on
  the live path. If off-path, document it as a non-blocking off-path sorry (final live count = 1). If
  reachable and dischargeable via the phases-10-14 machinery at `m ≤ existing arity`, discharge it; if
  it would require general-m arbitrary-position closure, STOP and record a divergence note
  recommending the `/spawn` uniform-Prop-4.3 task (do NOT reintroduce an arity tower).
- [ ] `#print axioms completeness_discrete`: confirm exactly the baseline; note whether `sorryAx` is
  now absent (final live count 0) or still present via `:394` only (documented off-path).
- [ ] `grep '^axiom ' Theories/` → zero new top-level axioms.
- [ ] Confirm `lake build` GREEN (~1700 jobs); record the final live-path sorry inventory.
- [ ] Emit the task-303 closure note and feed the task-95 `#print axioms` audit.

**File targets**: `KampPrior.lean` (`:394` arm if live) + closure-note output.

**Estimated output**: ~50-150 lines. **Done when**: `:394` removed (final count 0, `sorryAx` gone) OR
documented off-path (final count 1, `sorryAx` retained via `:394` only); baseline axioms confirmed;
closure note written.

**Confidence**: MEDIUM-HIGH. **Timing**: ~2 hours. **Depends on**: 14.

**Verification**:
- `lake build` GREEN (~1700 jobs).
- `:394` removed (final count 0) OR documented off-path (final count 1) with a written reachability note.
- `#print axioms completeness_discrete` = baseline; `grep '^axiom ' Theories/` = zero new axioms.
- Closure note written; task-95 audit fed.

## Deferred / Follow-up Task Recommendation (candidate `/spawn`)

Report 39 (consistent with report 38) rates the **uniform standalone Prop 4.3** LOW-MEDIUM and OFF the
completeness path. Recorded here as a candidate `/spawn` (a separate standalone task), NOT part of this
plan: "Faithful uniform Prop 4.3 — complete conjunction (Lemma 3.2(1) `conjComplete`, iff) +
bidirectional Prop 4.2 (§5 exhaustive partition) + general-m `existClosureAll` (Lemma 3.4 full)." It is
wanted only if the uniform Prop 4.3 is desired as a standalone library asset; it does not gate
`completeness_discrete`.

## Testing & Validation

- [ ] `lake build` GREEN (~1700 jobs) at every phase boundary (10, 11, 12, 13, 14, 15).
- [ ] `lean_verify` on each new off-path declaration → baseline axioms, no `sorryAx`, no new axioms.
- [ ] `lean_verify completeness_discrete` sorry-inventory recorded at each boundary; live-path count
  trends 2 → 1 (after Phase 14) → 0 or 1 (after Phase 15).
- [ ] `#print axioms completeness_discrete` shows the baseline axiom set unchanged
  (`Lean.ofReduceBool`/`Lean.trustCompiler` + `propext`/`Classical.choice`/`Quot.sound`).
- [ ] `grep '^axiom ' Theories/` confirms zero new top-level axioms at every boundary.
- [ ] No `VecEA_m.holds`-wiring for `:391`, no per-model existential bridge, no uniform Prop 4.2/4.3
  dependency, no De Morgan / positive-NF restructure, no NF-depth/arity-tower reintroduction on the
  live path.
- [ ] Preserved assets (Phases 1-4b, Phase-7 closure, char_k1, `mergeNF_succ`/`_atom`, bracket
  builders, depth-0 zone lemmas) unchanged.

## Artifacts & Outputs

- plans/39_direct-nf-construction.md (this file)
- Phase 10 [COMPLETED]: `renameNF_eval_diag0` (depth-0 diagonal congruence) in `NfDepth0Generalized.lean` — sorry-free, off-path; depth-(k+1) x=t remainder folded into Phase 11
- Phase 11: depth-k zone converter `nf_zone_depthk_*` (+ folded-in x=t arm) in `Kamp/NfZoneDepthK.lean` — sorry-free, off-path
- Phase 12: x<t past-arm converter (via `bracketBuildLeft`) — sorry-free, off-path
- Phase 13: t<x future-arm converter (via `bracketBuildRight`) — sorry-free, off-path
- Phase 14: `exist_tl_fn_{k+1}` assembly; `KampPrior.lean:391` discharged; live-path sorry count 2 → 1
- Phase 15: `:394` cleared or documented off-path; `#print axioms` audit; task-303 closure note; task-95 audit fed
- summaries/39_direct-nf-construction-summary.md (on completion)

## Rollback/Contingency

- Each phase is additive/append-only and build-GREEN at its boundary; revert is `git checkout` of the
  phase's commit. Phases 10-13 land off the live import path, so a failed Phase 14 rewire reverts
  without disturbing the proven arms.
- If Phase 11 (crux) resists after a bounded budget: split into 11a/11b (each GREEN off-path); do not
  churn a single dispatch. If it remains MEDIUM-LOW-blocked, STOP, record a divergence note, and keep
  `:391` as the baseline sorry — do NOT force it via a vacuous bridge or arity tower.
- If Phase 14's `insertEnv` index-ordering resists after a bounded budget: STOP, record a divergence
  note, keep the assembled iff off-path (GREEN), and re-scope the arm rewrite as the sole remaining
  sub-item; do not reopen any refuted route.
- If Phase 15 finds `:394` reachable and needing general-m closure: STOP, document it, recommend the
  `/spawn` uniform-Prop-4.3 task; do NOT reintroduce an arity tower.
- **Forbidden fallbacks** (do NOT take under any failure): `VecEA_m.holds`-wiring for `:391`, per-model
  existential bridge, uniform Prop 4.2/4.3 dependency, De Morgan / positive-NF restructure, NF-depth /
  arity-tower reintroduction, `nf_succ_char_formula2`, Route A′ in-situ zone-split, Route B re-anchor.
  All refuted (reports 18/37/38/39, plans 37/38) and closed.
- Baseline (build GREEN ~1700 jobs, 2 live sorries `:391`/`:394`, single `sorryAx` in
  `completeness_discrete`, axioms `Lean.ofReduceBool`/`Lean.trustCompiler` unchanged) is the safe
  restore point; never commit a state that regresses it.
