# Implementation Plan: Task #305 (v38 — Lemma 3.4 m=1 rewire)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (resumes from build-GREEN HEAD; baseline 2 live sorries `KampPrior.lean:391`/`:394`, `sorryAx` in `completeness_discrete`, axioms `Lean.ofReduceBool`/`Lean.trustCompiler` + `propext`/`Classical.choice`/`Quot.sound` unchanged)
- **Research Inputs**: reports/38_prop43-unblock-design.md (primary, Tier-1 literature-backed, H4-verified — its `next_action_hint`: REVISE plan 37)
- **Artifacts**: plans/38_lemma34-m1-rewire.md (this file)
- **Standards**: .claude/rules/artifact-formats.md, .claude/rules/state-management.md, status-markers.md, artifact-management.md, tasks.md, lean4.md, literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan supersedes the blocked Phase 4–6 tail of plan 37. Report 38 (Tier-1, H4-verified against
Rabinovich 2014 §3–4) establishes that **the live completeness path does not need a uniform
Prop 4.3 at all**: the single live sorry that matters — `KampPrior.lean:391`
(`nf_nvar_exist_all_depths … k 1`, the `| 1 =>` arm) — reduces to **Lemma 3.4 at m = 1**: absorb
one order-unconstrained existential witness into a 1-point environment. It needs **no complete
conjunction (Lemma 3.2(1)) and no negation (Prop 4.2)**. This plan builds exactly that surgical
unblock in two executable phases plus a verification phase:

- **Phase 7** — leftward existential closure (`bracketBuildLeft` + `existClosureLeft` + its
  holds-iff), the Since-mirror of the already-proven rightward `existClosure`. HIGH confidence.
- **Phase 8** — the n=1 witness-position split (a 3-arm disjunction: witness before / at / after the
  single point `t`) combining `existClosureLeft` (Phase 7) with the existing rightward `existClosure`
  and an `x = t` substitution, wired directly into the `| 1 =>` arm at `KampPrior.lean:391`. This is
  the DIRECT existential-closure rewire — it does not route through any uniform Prop 4.3. MEDIUM-HIGH.
- **Phase 9** — verification: `:394` (n≥2) cleared or proven off the live path with documentation,
  full `lake build` GREEN (~1700 jobs), axiom audit (`Lean.ofReduceBool`/`Lean.trustCompiler`
  unchanged), `sorryAx` scan, live-path sorry count 2 → 0 (or 1 if `:394` is proven off-path).

**Constraints**: every phase ends on a GREEN `lake build`; no phase may add a sorry to the live
path; the axiom set stays exactly the baseline with zero new top-level `axiom`; faithfulness to
Rabinovich is overriding, so no step reintroduces an NF-depth/arity-tower parameter. **Definition of
done**: `lake build` GREEN, `:391` cleared, `:394` cleared-or-documented-off-path, live-path sorry
count 2 → 0/1, axiom set unchanged.

### Research Integration

- **Report 38 (primary, Tier-1, H4-verified)** — `reports/38_prop43-unblock-design.md`. Decisive
  findings integrated below:
  - **Blocker 4 (LIVE-PATH CRITICAL)**: `existClosure` (`VecEA_m.lean:208`) absorbs only the
    **rightmost** var via `bracketBuildRight` (Until-nesting) and is a genuine iff
    (`existClosure_correct` :245 + `existClosure_correct_rev` :314). The De Bruijn `.ex` prepends
    `x` at index 0 with no order constraint. Bridging = split on where `x` lands among the existing
    points. For m = 1 this is a 3-arm split (before/at/after `t`). This is the whole live task.
  - **4a design (HIGH)**: `bracketBuildLeft` is the Since-mirror of `bracketBuildRight` — all
    primitives exist (`Formula.snce`, `weak_since` at `Formula.lean:474`, `all_past`); it is a
    structural mirror of proven sorry-free code. `existClosureLeft` absorbs the leftmost var.
    Type signatures given verbatim in Phase 7 below.
  - **4b design (MEDIUM-HIGH)**: the `| 1 =>` arm target is
    `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf` (verified at
    `KampPrior.lean:387–391`; confirmed at HEAD). The 3-arm disjunction closes it: `x < t` →
    `existClosureLeft` (Phase 7); `x = t` → substitution (arity-preserving, drops to a 1-point
    formula handled by existing atom/lt/NF machinery); `x > t` → existing `existClosure`. Combine
    via `VVecEA_m.disj` (a genuine iff, `VecEA_m.lean:135`).
  - **De Morgan / positive-NF restructure REJECTED** (report 38 Executive Summary #1 + adversarial
    table): NNF eliminates general `not` but keeps `all`; `∀`-closure ≡ `¬∃¬` needs Prop 4.2. It
    merely relocates the obstruction. **This plan does not restructure Prop 4.3.**
  - **Uniform Prop 4.3 is OFF the live path** and is LOW–MEDIUM confidence (needs complete
    conjunction `conjComplete` + faithful bidirectional Prop 4.2). Recorded below as a `/spawn`
    candidate only — it does not gate completeness.

### Preserved Assets

The following work is complete and must not regress. Phases 1–4b landed sorry-free and (for 4a/4b)
off the live import path; all remain as landed.

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Phase 1: Boneyard triage + REBUILD gate | handoffs/phase-1-gate-rebuild-20260624.md | [COMPLETED] | 2026-06-24 |
| Phase 2: Lemma 3.2(2) arity firewall (`VecEA_m.arity_firewall`) | `Kamp/VecEAArityFirewall.lean` | [COMPLETED] | 2026-06-24 (`lean_verify` clean) |
| Phase 3: Prop 4.2 model-dependent negation (`neg_2var_vec_ea`) | `EANegationClosure.lean` | [COMPLETED] | 2026-06-24 (sorry-free, baseline axioms) |
| Phase 4a: arbitrary-arity negation closure (`neg_vec_ea_m`, `EAVecNegationClosure`) | `Kamp/EAVecNegationClosure.lean` | [COMPLETED] | 2026-06-24 (off-path, sorry-free) |
| Phase 4b: uniform atom/lt/tt/ff blocks (`atomAt`/`ltAt`/`tt`/`ff` + `_holds`) | `Kamp/Prop43.lean` | [COMPLETED] | 2026-06-24 (off-path, sorry-free) |
| Rightward existential closure (`existClosure` + `_correct` :245 + `_correct_rev` :314) | `VecEA_m.lean` | [PRESENT] | genuine rightmost iff |
| Disjunction closure (`VVecEA_m.disj` + `disj_holds`) | `VecEA_m.lean:131–148` | [PRESENT] | genuine iff |
| Rightward temporal build (`bracketBuildRight` + `_correct` :234) | `VecEATranslation.lean:50` | [PRESENT] | Until-nesting |

**Do NOT re-derive any row above.** Phase 7 mirrors the `existClosure`/`bracketBuildRight` rows;
Phase 8 consumes the `existClosure`, `disj`, and Phase-4b atom/lt rows plus Phase 7's output.

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014 §3–4)

Only the live-path lemmas are mapped here (full lemma inventory in report 38 §"H3 Lemma-level
mapping table"). Paper at
`specs/literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.

| Source (Rabinovich 2014) | Lean identifier (to build) | Type signature (from report 38, verbatim) | Phase |
|---|---|---|---|
| Prop 3.5 (V-EA→TL, Since-mirror) | `bracketBuildLeft` (+ `_correct`) | `noncomputable def bracketBuildLeft : {n : Nat} → BracketFormula n → TemporalPred → Formula` | 7 |
| Lemma 3.4, left absorption | `VecEA_m.existClosureLeft` (+ `_correct`, `_correct_rev`) | `def existClosureLeft {m} (vea : VecEA_m (m+1)) : VecEA_m m`; `_correct (hm : m ≥ 1) : vea.existClosureLeft.holds M atomMap env → ∃ z, z < env ⟨0,_⟩ ∧ vea.holds M atomMap (prependEnv z env)`; `_correct_rev (hm : m ≥ 1) : z < env ⟨0,_⟩ → vea.holds M atomMap (prependEnv z env) → vea.existClosureLeft.holds M atomMap env` | 7 |
| Lemma 3.4, m=1 (arbitrary-position, 3-arm) | n=1 position split assembled from `existClosureLeft` + `existClosure` + `x=t` subst, combined by `VVecEA_m.disj` | closes `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf` (`KampPrior.lean:391`) | 8 |

## Goals & Non-Goals

**Goals**:
- Phase 7: build `bracketBuildLeft` + `existClosureLeft` and the leftward absorption iff
  (`_correct` / `_correct_rev`) as a structural mirror of the proven rightward `existClosure`,
  sorry-free, off the live import path.
- Phase 8: assemble the n=1 3-arm witness-position disjunction and wire it into `KampPrior.lean:391`
  (`| 1 =>` arm), a DIRECT existential-closure rewire; drop live-path sorry count 2 → 1.
- Phase 9: clear `:394` (n≥2) or prove it off the live path with documentation; confirm full GREEN,
  baseline axiom set, `sorryAx` status, and final live-path sorry count (0, or 1 with `:394`
  documented off-path).
- Reuse (never re-implement) `existClosure`, `disj`/`disj_holds`, `bracketBuildRight`, and the
  Phase-4b atom/lt blocks.

**Non-Goals** (see Postmortem Constraints for the binding "Do NOT" list):
- No uniform Prop 4.3 (complete conjunction Lemma 3.2(1) / faithful bidirectional Prop 4.2 /
  general-m `existClosureAll`). Off the completeness path; deferred to a `/spawn` recommendation.
- No De Morgan / positive-NF restructure of Prop 4.3 (report 38 REJECTED — relocates the
  obstruction from `not` to `all`).
- No NF-depth parameter, no arity-3+ existential converter, no arity-tower reintroduction.
- No Route A′ (in-situ zone-split) or Route B (re-anchor via `US_expressively_complete_over_Z`) —
  both refuted (plan 37, report 37) and closed.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from plan 37's Phase 4 blocker, report 38's
adversarial verification, and this task's 35+ prior-plan churn history.

**Do NOT**:
- De Morgan / positive-NF restructure of Prop 4.3 — REJECTED by report 38 (relocates the negation
  obstruction to the universal-closure case; NNF keeps `all`, and `∀`-closure ≡ `¬∃¬` still needs
  the UNFIXABLE model-independent Prop 4.2 backward).
- Reintroduce any NF-depth / arity-tower parameter, arity-3+ existential converter, `k+2`
  NF-disjunction, or `mutual` char/exist def. This is the exact artifact this plan removes; it is
  the durable failure mode across plans 11–35 (sorry moved `FOToVEA:118` → `KampPrior:154` → `:391`).
- Ship a vacuous per-model existential (`∃ v, v.holds env ↔ eval φ`) as if it were Lemma 3.4 or
  Prop 4.3 — it is closed by `⟨tt,…⟩`/`⟨ff,…⟩` for any φ (plan 37 Phase 4 blocker). Every closure
  built here must be a genuine model-independent iff (or feed one).
- Add any `sorry` to the live import path. Off-path scaffolding may carry its own sorries only while
  quarantined; nothing new lands on the `completeness_discrete` path except a sorry-free discharge.
- Revert or overwrite Phases 1–4b assets (`Kamp/Prop43.lean` atom/lt/tt/ff blocks,
  `Kamp/EAVecNegationClosure.lean`, `Kamp/VecEAArityFirewall.lean` arity firewall). They stay as
  landed, off-path.
- Rebuild `existClosure`, `disj`/`disj_holds`, or `bracketBuildRight` — they are present and proven;
  Phase 7 mirrors them, Phase 8 consumes them.

**MUST preserve**:
- Build GREEN (~1700 jobs) at every phase boundary.
- Axiom set exactly `Lean.ofReduceBool`/`Lean.trustCompiler` + `propext`/`Classical.choice`/
  `Quot.sound`; zero new top-level `axiom`.
- The rightward `existClosure` genuine iff and `disj_holds` genuine iff (load-bearing for Phase 8).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The live sorry `:391` reduces to Lemma 3.4 at m=1 ONLY — no conjunction, no negation. (Report 38
  Executive Summary #2, adversarial table row "Live sorry `:391` needs only Lemma 3.4 (m=1)":
  CONFIRMED.)
- Phase 8 is a DIRECT existential-closure rewire of `:391`. The old Phase 5 "re-anchor through a
  uniform Prop 4.3 + Prop 3.5" is dropped — the direct rewire subsumes it.
- Uniform Prop 4.3 (and its conjunction/negation prerequisites) is OFF the completeness path and is
  a separate `/spawn` candidate, not part of this plan's executable phases.
- `existClosure` (rightmost) is a genuine iff and is reused as-is; the leftward mirror is the only
  new absorption direction needed.
- Model-dependent negation (`neg_2var_vec_ea`, Phase 3) stays; model-independent negation is
  off-path and out of scope here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The Since-mirror `bracketBuildLeft_correct` re-derivation is more intricate than the rightward original (Since vs Until asymmetry in `weak_since`). | M | M | Phase 7 mirrors `bracketBuildRight_correct` (`VecEATranslation.lean:234`) declaration-by-declaration; primitives (`Formula.snce`, `weak_since` `Formula.lean:474`, `all_past`) are confirmed present. If a sub-lemma resists after a bounded budget, split Phase 7 into 7.1 (`bracketBuildLeft` + `_correct`) and 7.2 (`existClosureLeft` + `_correct`/`_correct_rev`) rather than churning. |
| The `x = t` middle arm of the n=1 split needs an arity-preserving substitution not yet isolated. | M | M | Report 38 4b: `x = t` drops to a 1-point formula handled by existing atom/lt/NF machinery; use the Phase-4b `atomAt`/`ltAt` blocks. If substitution is missing, build it as a small local lemma within Phase 8's budget (still m ≤ 1, no arity growth). |
| Rewiring `:391` surfaces a `StrictMono`/`insertEnv` index-ordering mismatch between `Fin.cons`/`prependEnv` and the arm's `insertEnv env t`. | H | M | Phase 8 first proves the 3-arm disjunction as a standalone iff against `insertEnv env t` (the actual arm term, confirmed at `KampPrior.lean:388`), then substitutes into the arm. The three arms are exhaustive on the trichotomy `x < t / x = t / x > t`, so `disj_holds` gives the iff. Build GREEN before the arm edit is committed. |
| Import rewire onto the live `KampPrior` path introduces a cycle or latent breakage. | H | L | Phase 8 adds only the imports needed for `existClosureLeft` + the split; runs `lake build` to confirm acyclicity and GREEN **before** touching `:391`. Phase-4b assets are already off-path and import-clean. |
| `:394` (n≥2) turns out to be reachable on the live path, requiring general-m closure this plan does not build. | M | L | Phase 9 first runs `lean_verify completeness_discrete` to check reachability. If off-path, document as a non-blocking off-path sorry (final count 1). If reachable, the general-m `existClosureAll` is OUT OF SCOPE here → STOP and record a divergence note recommending the `/spawn` uniform-Prop-4.3 task; do NOT reintroduce an arity tower to force it. |
| Regressing the GREEN baseline or the axiom set. | H | L | `lake build` GREEN + `#print axioms completeness_discrete` + `grep '^axiom ' Theories/` at every phase boundary; off-path scaffolding stays quarantined until its consumer is sorry-free. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 7 | -- |
| 2 | 8 | 7 |
| 3 | 9 | 8 |

Fully sequential: Phase 8 consumes Phase 7's `existClosureLeft` iff; Phase 9 verifies the state
Phase 8 produces. Each wave is one phase (one implementation dispatch).

### Historical Phase Ledger (plan 37 — closed, do not re-execute)

The executable phases below are numbered 7/8/9, continuing plan 37's numbering. Plan 37's Phases
1–6 are terminal; none is `[NOT STARTED]`. They appear here as context only.

| Phase (plan 37) | Name | Terminal Status | Disposition |
|---|---|---|---|
| 1 | Boneyard triage + REBUILD gate | [COMPLETED] | Gate verdict REBUILD; preserved asset. |
| 2 | Lemma 3.2(2) arity firewall | [COMPLETED] | `VecEA_m.arity_firewall` sorry-free; preserved. |
| 3 | Prop 4.2 model-independent backward | [COMPLETED] | Resolved via model-dependent interim `neg_2var_vec_ea`; preserved. |
| 4 | Revive/rebuild Prop 4.3 (uniform) | [BLOCKED — SUPERSEDED BY PHASE 7–8] | Uniform Prop 4.3 blocked & off-path; live path re-scoped to Lemma 3.4 m=1. 4a/4b assets preserved off-path. |
| 5 | Re-anchor KampPrior through uniform Prop 4.3 + Prop 3.5 | [SUPERSEDED BY PHASE 8] | Replaced by the DIRECT existential-closure rewire in Phase 8 (no uniform Prop 4.3 dependency). |
| 6 | Verification | [SUPERSEDED BY PHASE 9] | Folded into Phase 9. |

---

### Phase 7: Leftward existential closure — bracketBuildLeft + existClosureLeft + iff [COMPLETED]

**Deviation (bracketBuildLeft already existed)**: Report 38 stated `bracketBuildLeft` (+`_correct`)
was MISSING; in fact a complete, sorry-free copy existed in `NfToVecEA.lean` (downstream of
`VecEATranslation.lean`), carrying an outdated "sorries at n > 0" docstring. Because `VecEA_m`
(where `existClosureLeft` lives) is upstream of `NfToVecEA`, that copy was unreachable. Resolution:
the canonical `bracketBuildLeft`/`_correct` (with `chainHoldsLeft`, `bracket_append_witness`,
`bracket_extract_last_witness`) now lives in `VecEATranslation.lean`; the duplicate block was
removed from `NfToVecEA.lean` and its two `bracketBuildLeft_correct_zero` usages repointed to the
general `bracketBuildLeft_correct`. Net effect: single source of truth, still sorry-free, and the
leftward translation is now available to `VecEA_m`.

**Goal**: Build the Since-mirror of the proven rightward absorption: `bracketBuildLeft`
(+ `_correct`) and `VecEA_m.existClosureLeft` (+ `_correct` / `_correct_rev`), absorbing the
**leftmost** variable of a `VecEA_m (m+1)` into a `VecEA_m m` via a Since-based temporal condition.
Sorry-free, off the live import path. This is a structural mirror of sorry-free code (report 38 4a,
HIGH confidence).

**Tasks**:
- [x] Read `VecEATranslation.lean:50,234` (`bracketBuildRight` + `bracketBuildRight_correct`) and
  `VecEA_m.lean:208–332` (`existClosure` + `_correct` :245 + `_correct_rev` :314) as the mirror
  templates; confirm `Formula.snce` / `buildLeft` (`Translation.lean:199`) signatures.
- [x] Build `noncomputable def bracketBuildLeft : {n : Nat} → BracketFormula n → TemporalPred → Formula`
  (Since analog of `bracketBuildRight`; holds at `z1` iff `∃ z0 < z1` with the endpoint + bracket on
  `(z0, z1)`), in `VecEATranslation.lean`. *(deviation: consolidated from a pre-existing
  `NfToVecEA.lean` copy — see Phase 7 heading note.)*
- [x] Prove `bracketBuildLeft_correct` as the Since-mirror of `bracketBuildRight_correct`
  (via `chainHoldsLeft` + `bracket_append_witness` / `bracket_extract_last_witness`).
- [x] Build `def VecEA_m.existClosureLeft {m} (vea : VecEA_m (m+1)) : VecEA_m m` (absorb leftmost
  var `z0`: fold interval `(z0,z1)` + endpoint `(z0)` into endpoint `(z1)`) in `VecEA_m.lean`
  (append-only). *(deviation: used `prependEnv` = index-0 prepend, not `leftPart`.)*
- [x] Prove `existClosureLeft_correct` and `existClosureLeft_correct_rev` (the two directions of the
  leftward absorption iff), signatures per the Source-to-Implementation Mapping table.
- [x] `lean_verify` each new declaration: sorry-free, axioms = `[propext, Classical.choice, Quot.sound]`,
  no `sorryAx`.

**File targets**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` (append
`bracketBuildLeft` + `_correct`), `.../Kamp/VecEA_m.lean` (append `existClosureLeft` + `_correct` /
`_correct_rev`). Append-only; off the live import path.

**Line estimate**: ~250–400 lines (bulk is the Since analog of `bracketBuildRight_correct` + the
witness-prepend lemma mirroring `VecEATranslation.lean:66`).

**Timing**: ~3 hours

**Depends on**: none (builds on preserved `existClosure` / `bracketBuildRight` templates)

**Verification**:
- `lake build` GREEN (~1700 jobs).
- `lean_verify VecEA_m.existClosureLeft_correct` and `lean_verify VecEA_m.existClosureLeft_correct_rev`
  → axioms `[propext, Classical.choice, Quot.sound]`, no `sorryAx`, no new axioms.
- `grep '^axiom ' Theories/` → zero new top-level axioms.
- Live-path sorry count UNCHANGED at 2 (new decls are off-path).
- No NF-depth / arity-3+ appeal in the new declarations.

**Split fallback**: if `bracketBuildLeft_correct` resists after a bounded budget, split into
7.1 (`bracketBuildLeft` + `_correct`) and 7.2 (`existClosureLeft` + `_correct`/`_correct_rev`); each
sub-phase ends GREEN.

---

### Phase 8: n=1 witness-position split + live rewire of KampPrior:391 [NOT STARTED]

**Goal**: Assemble the n=1 3-arm witness-position disjunction (witness `x` before / at / after the
single point `t`) and wire it into the `| 1 =>` arm at `KampPrior.lean:391`, discharging the live
sorry. This is the DIRECT existential-closure rewire — it does not route through any uniform Prop 4.3.
Drops the live-path sorry count from 2 to 1 (report 38 4b, MEDIUM-HIGH confidence).

**Tasks**:
- [ ] Read `KampPrior.lean:305–331` (`ih_exist_1`) and `:385–395` (the `| 1 =>` / `| n+2 =>` arms);
  confirm the arm target is `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`.
- [ ] Build the three arms against `insertEnv env t`:
  - `x < t` → `VecEA_m.existClosureLeft` (Phase 7);
  - `x = t` → arity-preserving substitution `x := t` (drops to a 1-point formula; use the Phase-4b
    `Kamp/Prop43.lean` `atomAt`/`ltAt` blocks; build a small local subst lemma only if not already
    isolated);
  - `x > t` → existing `VecEA_m.existClosure`.
- [ ] Combine the three arms with `VVecEA_m.disj` (genuine iff, `VecEA_m.lean:135`) and prove the
  standalone iff `(split).holds … ↔ ∃ x, … (insertEnv …) …` on the trichotomy `x<t / x=t / x>t`
  (exhaustive). Keep this as a named off-path lemma first; `lake build` GREEN before touching `:391`.
- [ ] Add the imports required by the split (Phase 7 decls + Phase-4b `Kamp/Prop43.lean`) to
  `KampPrior.lean`; `lake build` to confirm no cycle and GREEN **before** editing the arm.
- [ ] Replace the `sorry` at `KampPrior.lean:391` (`| 1 =>` arm) with the split lemma; `lake build`
  GREEN.
- [ ] `lean_verify completeness_discrete`: confirm the `:391` arm is discharged and its `sorryAx`
  source is gone; confirm live-path sorry count is now 1 (only `:394`).

**File targets**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (imports + the
`:391` arm and, if needed, a local subst lemma). New split lemma may live in `Kamp/Prop43.lean` or a
new small module, then imported.

**Line estimate**: ~200–350 lines.

**Timing**: ~3 hours

**Depends on**: 7

**Verification**:
- `lake build` GREEN (~1700 jobs).
- `KampPrior.lean:391` sorry removed; `grep -n sorry KampPrior.lean` shows only the `:394` arm remains
  on the live path.
- `lean_verify completeness_discrete` → the `:391`-sourced `sorryAx` gone; live-path sorry count 2 → 1.
- `#print axioms completeness_discrete` → baseline axiom set unchanged; `grep '^axiom ' Theories/` →
  zero new top-level axioms.
- No NF-depth / arity-3+ appeal introduced in the arm or the split lemma.

---

### Phase 9: Verification — clear/off-path :394, axiom + sorryAx audit [NOT STARTED]

**Goal**: Confirm `:394` (n≥2) is cleared or provably off the live path with documentation, confirm
full GREEN and the baseline axiom set, and record the final live-path sorry inventory (0, or 1 with
`:394` documented off-path). Emit closure outputs.

**Tasks**:
- [ ] `lean_verify completeness_discrete` to determine whether `:394` (`| n+2 =>` arm) is reachable on
  the live path. If off-path, document it as a non-blocking off-path sorry (final live count = 1). If
  reachable, discharge it via the same Lemma-3.4 machinery **only if it stays m ≤ existing arity**;
  if it would require general-m arbitrary-position closure (`existClosureAll`), STOP and record a
  divergence note recommending the `/spawn` uniform-Prop-4.3 task (do NOT reintroduce an arity tower).
- [ ] `#print axioms completeness_discrete`: confirm exactly the baseline
  (`Lean.ofReduceBool`/`Lean.trustCompiler` + `propext`/`Classical.choice`/`Quot.sound`); note whether
  `sorryAx` is now absent (it should be if final live count = 0) or still present via `:394` (if
  documented off-path).
- [ ] `grep '^axiom ' Theories/` → zero new top-level axioms.
- [ ] Confirm `lake build` GREEN (~1700 jobs); record the final live-path sorry inventory.
- [ ] Emit the task-303 closure note and feed the task-95 `#print axioms` audit.

**File targets**: `KampPrior.lean` (`:394` arm if live) + closure-note output.

**Line estimate**: ~50–150 lines (verification + any small off-path discharge/documentation).

**Timing**: ~2 hours

**Depends on**: 8

**Verification**:
- `lake build` GREEN (~1700 jobs).
- `:394` removed (final count 0, `sorryAx` gone) OR documented off-path with a written reachability
  note (final count 1, `sorryAx` retained via `:394` only).
- `#print axioms completeness_discrete` = baseline; `grep '^axiom ' Theories/` = zero new axioms.
- Closure note written; task-95 audit fed.

## Deferred / Follow-up Task Recommendation (candidate `/spawn`)

Report 38 rates the **uniform standalone Prop 4.3** LOW–MEDIUM and OFF the completeness path. It is
recorded here as a candidate `/spawn` (a separate standalone task), NOT part of this plan:

- **Scope**: "Faithful uniform Prop 4.3 — complete conjunction (Lemma 3.2(1) `conjComplete`, iff) +
  bidirectional Prop 4.2 (§5 exhaustive `Cond_i` partition) + general-m `existClosureAll`
  (Lemma 3.4 full)."
- **Why separate**: this is the genuine hard half of Kamp's theorem; it is large
  (conjunction ~400–600 lines, faithful bidirectional Prop 4.2 ~800–1500+ lines, LOW confidence) and
  must not gate `completeness_discrete`. It is wanted only if the uniform Prop 4.3 is desired as a
  standalone library asset.
- **Action**: recommend `/spawn 305 "faithful uniform Prop 4.3 (conjComplete + bidirectional Prop 4.2 +
  existClosureAll)"` after this plan completes, if the library asset is wanted. No dependency of this
  plan on that task.

## Testing & Validation

- [ ] `lake build` GREEN (~1700 jobs) at every phase boundary (7, 8, 9).
- [ ] `lean_verify completeness_discrete` sorry-inventory recorded at each boundary; live-path count
  trends 2 → 1 (after Phase 8) → 0 or 1 (after Phase 9).
- [ ] `#print axioms completeness_discrete` shows the baseline axiom set unchanged
  (`Lean.ofReduceBool`/`Lean.trustCompiler` + `propext`/`Classical.choice`/`Quot.sound`); `sorryAx`
  absent iff final live count = 0.
- [ ] `grep '^axiom ' Theories/` confirms zero new top-level axioms at every boundary.
- [ ] No NF-depth parameter, no arity-3+ existential converter, no De Morgan / positive-NF Prop 4.3
  restructure, no uniform Prop 4.3 dependency introduced on the live path.
- [ ] Every new helper's recursion is structural on the FO formula / bracket, or fixed-arity; no
  depth-index recursion.
- [ ] Preserved assets (Phases 1–4b) unchanged: `Kamp/VecEAArityFirewall.lean`,
  `Kamp/EAVecNegationClosure.lean`, `Kamp/Prop43.lean` atom/lt/tt/ff blocks not regressed.

## Artifacts & Outputs

- plans/38_lemma34-m1-rewire.md (this file)
- Phase 7: `bracketBuildLeft` (+ `_correct`) in `VecEATranslation.lean`; `VecEA_m.existClosureLeft`
  (+ `_correct` / `_correct_rev`) in `VecEA_m.lean` — sorry-free, off-path
- Phase 8: n=1 3-arm split lemma; `KampPrior.lean:391` (`| 1 =>` arm) discharged; imports rewired;
  live-path sorry count 2 → 1
- Phase 9: `:394` cleared or documented off-path; `#print axioms` audit; task-303 closure note;
  task-95 audit fed
- summaries/38_lemma34-m1-rewire-summary.md (on completion)

## Rollback/Contingency

- Each phase is additive/append-only and build-GREEN at its boundary; revert is `git checkout` of the
  phase's commit. Phase 7 lands off the live import path, so a failed Phase 8 rewire reverts without
  disturbing the proven `existClosureLeft`.
- If Phase 7's Since-mirror resists: split into 7.1/7.2 (see Phase 7 split fallback); do not churn.
- If Phase 8's `x = t` middle arm or the `insertEnv` index-ordering resists after a bounded budget:
  STOP, record a divergence note, and re-scope the middle arm as the sole remaining sub-item rather
  than reopening the uniform Prop 4.3 or any refuted route.
- If Phase 9 finds `:394` reachable and needing general-m closure: STOP, document it, recommend the
  `/spawn` uniform-Prop-4.3 task; do NOT reintroduce an arity tower to force it.
- **Forbidden fallbacks** (do NOT take under any failure): De Morgan / positive-NF Prop 4.3
  restructure, uniform per-connective negation, NF-depth / arity-tower reintroduction, Route A′
  in-situ zone-split, Route B re-anchor, `nf_succ_char_formula2`, vacuous per-model existential. All
  refuted (reports 18/37/38, plan 37) and closed.
- Baseline (build GREEN ~1700 jobs, 2 live sorries `:391`/`:394`, single `sorryAx` in
  `completeness_discrete`, axioms `Lean.ofReduceBool`/`Lean.trustCompiler` unchanged) is the safe
  restore point; never commit a state that regresses it.
