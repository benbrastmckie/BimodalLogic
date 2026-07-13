# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` (Rabinovich Cor 5.4(1) ⇐)

- **Task**: 358 - Land the `nf_nvar_exist_all_depths` n>=1 arms (KampPrior.lean:361, :364), produce the genuine realizer `hσ`, discharge the eleven task-356/357 obligations, retire the completeness sorry
- **Status**: [NOT STARTED]
- **Effort**: 10-16 hours (hard open-mathematics transcription; 5 phases)
- **Dependencies**: 357 (completed), 356 (completed) — both green; 341 (planned, serialized AFTER 358)
- **Research Inputs**:
  - reports/02_literature-proof-method-survey.md (THE proof method — Rabinovich Cor 5.4(1) ⇐, §2.4 recipe; authoritative)
  - reports/01_realization-recursion-realizer.md (Lean statement pinning, obligation→converter map, landed-interface table)
- **Artifacts**: plans/02_realizer-recursion-implementation.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md (Literature Fidelity; Vacuous Definitions PROHIBITED)
- **Type**: lean4

## Overview

Retire the two open arms of `nf_nvar_exist_all_depths` in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (the n=1 critical arm at :361 and
the n+2 footprint arm at :364). The mathematical method is **IDENTIFIED and settled** by report 02:
the within-bracket realizer is **Rabinovich 2014, Corollary 5.4(1), the ⇐ direction** — a
**constructive induction on F-chain length driven by the `Until` modality plus a two-way
`min`/case-split** (`if y2 ≤ x_{n+1} then y2 else x_{n+1}`), NOT an `inf`/`sup` global choice. The
k>=2 case is the already-landed k=1 template (`fChainFrom`/`fChainPred`, EANegation.lean:552)
extended by exactly one Until-driven chain-link. Producing the realizer `hσ` at the anchor the
already-landed chain destructor reconstructs discharges the eleven carried obligations mechanically
through the two landed pure-reader converters and the green obligation-carrying consumer. Result:
`nf_nvar_exist_all_depths` sorry-free at :361 AND :364, full-tree `lake build` green, and
`#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]` (plus acceptable
`ofReduceBool`/`trustCompiler` from `native_decide` in the Syntax layer).

**Definition of done** (binding, from task brief): :361 and :364 both sorry-free; provider
instantiation discharges `hreal`/`hexcl`/`hbr*` at the KampPrior recursion site; full-tree build
GREEN; `#print axioms completeness_discrete` clean. :364 CANNOT be silently deferred — a carried
sorry there keeps `sorryAx` in the completeness footprint.

### Preserved Assets

The following work is complete/green and MUST NOT regress. Task 358 CONSUMES these by name (do not
re-derive, do not re-implement, do not overwrite). Task 341 is serialized AFTER 358, so these
interfaces are stable at their current locations during this task; if 341 has moved any, re-locate
by name (the interface, not the file path, is the contract).

| Component | Interface (by name) | File:line | Status | Verified |
|-----------|---------------------|-----------|--------|----------|
| Cor 5.4 future chain destructor (anchor) | `kvE_futChainDestructG` | ExteriorNegationK.lean:293 | [COMPLETED] sorry-free | pin in Phase 1 |
| Future exterior converter (pure reader) | `kvE_futBundle_of_realizer` | ExteriorConverterK.lean:208 | [COMPLETED] sorry-free | pin in Phase 1 |
| Past exterior converter (pure reader) | `kvE_pastBundle_of_realizer` | ExteriorConverterPastK.lean:177 | [COMPLETED] sorry-free | pin in Phase 1 |
| Future chain destruct (G-guarded) | `kvE_futChainDestructG` (+ past dual `kvE_pastChainDestruct*`) | ExteriorNegationK.lean:293 | [COMPLETED] | pin in Phase 1 |
| Interior+exterior composed gate | `bracketEndChar_kvExt_correct_prior` | ExteriorGateAssembleK.lean:106 | [COMPLETED] (`hexclExt` internal) | pin in Phase 1 |
| Obligation-carrying consumer | `endInterval_step_correct` / `EndIntervalCorrectPrior` | EndIntervalConsumerK.lean:171 / :95 | [COMPLETED] (task 357) | pin in Phase 1 |
| General-k supply-site seam | `kampPrior_site_rungK_gate_match` | KampPrior.lean:816 | [COMPLETED] | pin in Phase 1 |
| Provider shim (fed by IH family) | `kampPrior_existProviders_of_ih` | KampPrior.lean:972 | [COMPLETED] | pin in Phase 1 |
| k=1 realizer template (Fi chain) | `fChainFrom` / `fChainPred` / `fChainFrom_base` | EANegation.lean:552 / :567 / :580 | [COMPLETED] | reference model |
| n=0 / k=0 arms of the target def | `nf_nvar_exist_all_depths` `\| 0 =>`, `\| k+1,0 =>` | KampPrior.lean:224, :335 | [COMPLETED] sorry-free | do not touch |

### Source-to-Implementation Mapping (H3, Tier 1 — Literature-Backed)

Authoritative source: **Rabinovich, *A Proof of Kamp's Theorem* (2014)**, read directly at
`~/Projects/Literature/sources/rabinovich_2014/` chunks 0013–0016. Second corroborating source for
the interior/exterior seam: report 355/01 Q1/Q3 (independent confirmation the Cor 5.4 interior vs.
Lemma 7.6 adjacency split is Rabinovich's actual seam).

| Source | Prop/Location | Lean Identifier | Type Signature (target) | Status |
|--------|---------------|-----------------|-------------------------|--------|
| Rabinovich 2014 | Cor 5.4(1) ⇐, §5 (chunk 0015) | `nf_nvar_exist_all_depths` `\| 1 =>` arm (:361) | produces `hσ : nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _=>t)))) σ` | sorry → Phases 2-3 |
| Rabinovich 2014 | Cor 5.4(1) ⇐ general step (chunk 0015) | `nf_nvar_exist_all_depths` `\| n+2 =>` arm (:364) | arity-(n+1) existential at depth k+1 | sorry → Phase 4 |
| Rabinovich 2014 | Cor 5.4(1) `Fi` chain, eq 5.3 `INF` first-point (chunk 0016) | `fChainFrom` / `fChainPred` (k=1 landed) | `BracketFormula.fChainFrom …` | transcribed (k=1); extend one link in Phase 2 |
| Rabinovich 2014 | Cor 5.4 chain destructor / `O_n` (chunk 0015) | `kvE_futChainDestructG` (+ past dual) | anchor `x1` + D-uniform gap + per-item occurrence | transcribed (landed) |
| Rabinovich 2014 | Until-witness of `(β_{n+1} Until α_{n+1})` (chunk 0015 lines 9–41) | project `Until` truth-lemma (name pinned in Phase 1) | from `y1 ⊨ (β Until α)`: `∃ y2 > y1, α(y2) ∧ (∀ z ∈ (y1,y2), β z)` | **pending — Phase 1 verify constructivity** |
| Rabinovich 2014 | Cor 5.4(1) converters | `kvE_futBundle_of_realizer` / `kvE_pastBundle_of_realizer` | `hσ → (∀ s, σ.2 s → ∃ v, …) ∧ (∀ s, drop=σ.1 → (∃ v →) → σ.2 s)` | transcribed (landed) |

**Transcription discipline (SETTLED)**: follow Cor 5.4(1) ⇐ verbatim (§2.4 recipe). The witness
selection is the decidable `min`/case-split, NOT an `inf`/`sup`. Do NOT switch to GHR separation,
Hodkinson games, or Kamp 1968 — report 02 §3 shows every alternative is strictly harder to
formalize. Do NOT `simp`/`omega`/`aesop` past the Until-witness or the case-split step (Literature
Fidelity policy; mirror `fChainFrom` explicitly).

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from report 02 §4–5, report 01 §4, the
task brief's zero-debt mandate, and lean4.md.

**Do NOT**:
- Do NOT frame the realizer as an `inf`/`sup` global choice. Report 02 §2.3 corrects the
  task-309/355 shorthand: the ONLY Dedekind-completeness appeal is the first-order-definable `INF`
  first-point (eq 5.3), already formalized at k=1. The realizer recursion itself is the constructive
  Until-driven `min`/case-split — no unbounded/global selection at the realizer step.
- Do NOT introduce `Classical.choice` at the realizer step. The `min`/case-split is decidable over
  the discrete/integer domain; keep it constructive so the axiom audit stays clean.
- Do NOT `simp`/`omega`/`aesop` past the Until-witness extraction or the `y2 ≤ x_{n+1}` case-split.
  These are the faithful Rabinovich content and must be transcribed explicitly (lean4.md Literature
  Fidelity; report 02 §6).
- Do NOT re-derive, re-implement, or overwrite any Preserved Asset. The two converters are PURE
  READERS — do not rebuild them; supply their argument `hσ` only.
- Do NOT edit any file other than `KampPrior.lean`. FILE SCOPE is a single file (task brief + report
  01 §5). If a genuinely new lemma is required in another file (e.g., a missing constructive Until
  truth-lemma in the Semantics layer), that is an out-of-file-scope escalation → [BLOCKED] + spawn,
  NOT an inline cross-file edit.
- Do NOT silently defer :364. A carried sorry at :364 keeps `sorryAx` in the completeness footprint,
  so the axiom audit (Phase 5) will fail. :364 is mandatory, not optional.
- Do NOT land a strategic `sorry` or a vacuous `def X := True`/`Unit`/`trivial` anywhere. This task
  is zero-debt: the terminus is a clean `#print axioms`. If a piece cannot close green, escalate.

**MUST preserve**:
- The n=0 arm (:335) and k=0 base (:224) of `nf_nvar_exist_all_depths` — already sorry-free; do not
  touch their proofs.
- All nine landed interfaces in the Preserved Assets table (356/357/309 deliverables).
- Existing full-tree green status of every module OTHER than KampPrior.lean.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- Method = Rabinovich Cor 5.4(1) ⇐ constructive Until + `min`/case-split induction. Rejected
  alternatives (GHR separation, Hodkinson/Kamp games) are strictly harder to formalize (report 02 §3).
- Anchor reconstruction = the already-landed `kvE_{fut,past}ChainDestructG` (Cor 5.4 negation side).
  Do NOT rebuild the anchor destructor.
- Obligation discharge = feed `hσ` through the two landed converters + the green consumer. The
  eleven obligations (7 interior via `kampPrior_site_rungK_gate_match` → `bracketEndChar_kvExt_correct_prior`;
  4 exterior via the bundles) fall out mechanically GIVEN `hσ`.
- The escalation atom, if blocked, is the **fiber-level `HasAttainedINF` existence converse**
  (arity-5, general-depth mirror of EANegation.lean:571) — spawn THAT as the isolated sub-task, and
  keep :364 as a separate follow-up only if route (a) fails.

## Goals & Non-Goals

- **Goals**:
  - `nf_nvar_exist_all_depths` sorry-free at :361 (n=1 critical arm) and :364 (n+2 footprint arm).
  - Produce the genuine realizer `hσ` via Cor 5.4(1) ⇐ (base + one Until-link), consuming the landed
    chain destructor for the anchor.
  - Discharge `hreal`/`hexcl` (interior, 7) + `hbrPastReal`/`hbrPastSat`/`hbrFutReal`/`hbrFutSat`
    (exterior, 4) at the `k+1` recursion body via the landed converters + consumer + provider shim.
  - Full-tree `lake build` GREEN.
  - `#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]`
    (+ acceptable `ofReduceBool`/`trustCompiler`).
- **Non-Goals**:
  - Refactoring `NfMultiAnchorBridge/` (that is task 341, serialized AFTER 358).
  - Re-deriving the chain destructor, the converters, the consumer, or the k=1 `fChainFrom` template.
  - Editing any file other than `KampPrior.lean`.
  - Landing arity-≥5 fiber machinery in other files (escalate if required).

## Risks & Mitigations

- **Risk (PRIMARY, report 02 caveat 1 / report 01 §4.1)**: the project's `Until` truth-lemma may
  expose the witness only classically, not constructively, on the target discrete/integer (Reynolds)
  model. **Mitigation**: Phase 1 verifies this FIRST as the escalation gate; on the integer model it
  should be constructive. If it is not, that is the escalation boundary → [BLOCKED] + spawn an
  isolated constructive-Until-witness sub-task (out of file scope). Do not proceed to Phase 2 until
  Phase 1 is green.
- **Risk (report 02 caveat 2)**: if the 356/357 reshapes were not green, 358 would re-block at
  WIRING, not mathematics. **Mitigation**: 356 and 357 are both `completed`; Phase 1 pins all nine
  interfaces by name (guards against a 341 move) before any construction.
- **Risk (report 01 §4.2)**: the `\| n+2 =>` arity lift (route a, arity-generic reduction) may not
  work cheaply; route (b) is the full multi-anchor Lemma 5.1 argument (strictly harder).
  **Mitigation**: Phase 2 builds the realizer arity-generically where feasible so Phase 4 is a thin
  instantiation; if route (a) is blocked, attempt route (b), else [BLOCKED] + spawn an isolated
  arity-lift sub-task (:364 kept separate; parent stays [BLOCKED], never [COMPLETED] with a sorry).
- **Risk (report 01 §3 subtlety)**: the gate obligations quantify `x1` universally, but `hσ` exists
  only at the selected anchor. **Mitigation**: Phase 3 applies the converter at the specific `x1`
  from `kvE_futChainDestructG`; the non-selected `x1` antecedent is discharged by the exclusion
  reading (`nf_eval_nfk_iff_efold` off-fiber branch). Pin this alignment early in Phase 3.
- **Risk**: build-time regression to another module from a shared edit. **Mitigation**: file scope
  is a single file; scoped `lake build` per phase, full-tree only in Phase 5.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Plan is fully sequential: all phases edit the single-file `KampPrior.lean` (shared recursion
constant + file-scope constraint), so no two phases can run in parallel. Phase 1 is the escalation
gate — do not begin Phase 2 until it is green.

### Phase 1: Interface pin + constructive Until-witness verification (escalation gate) [NOT STARTED]
- **Goal:** Confirm the caveats are satisfied BEFORE any construction: (a) all nine Preserved-Asset
  interfaces resolve by name at their current locations; (b) the project's `Until` truth-lemma
  exposes the Until-witness CONSTRUCTIVELY on the target discrete/integer (Reynolds) model. This is
  the single real dependency and the escalation boundary (report 02 caveat 1).
- **Tasks:**
  - [ ] `lean_local_search` / `lean_hover_info` each of the nine interfaces in the Preserved Assets
        table; record the current file:line and full type signature of each. If 341 has moved any,
        re-locate by name and note the new location (do not edit them).
  - [ ] Locate the project's `Until` truth-lemma (the semantics lemma unfolding `Until`/`Since`
        satisfaction on `OrderedMonadicStructure`). Record its exact name and signature.
  - [ ] Determine whether it yields, from `y1 ⊨ (β Until α)`, a CONSTRUCTIVE witness
        `y2 > y1` with `α(y2)` and `β` on `(y1, y2)` (decidable, no `Classical.choice`) on the
        discrete/integer model. Use `lean_hover_info` on the lemma; if it produces an existential
        that is eliminable without `Classical.choice`, it is constructive-viable.
  - [ ] GO/NO-GO: if constructive-viable AND all nine interfaces resolve → proceed to Phase 2. If the
        Until-witness is only classical, OR requires a NEW lemma in another file (out of file scope)
        → STOP: mark task [BLOCKED], spawn an isolated constructive-Until-witness sub-task, do NOT
        proceed.
- **Timing:** 1-2 hours (verification only; no proof edits unless an inline adapter is trivially
  in-scope in KampPrior.lean).
- **Depends on:** none
- **Done when:** every interface pinned with a recorded signature AND a named constructive Until
  truth-lemma identified (GO), OR task marked [BLOCKED] with a spawned sub-task (NO-GO). No sorry
  introduced.

### Phase 2: Produce the realizer `hσ` — Cor 5.4(1) ⇐ base + one Until-link (n=1, arity 4) [NOT STARTED]
- **Goal:** Construct the genuine within-bracket realizer
  `hσ : nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _=>t)))) σ` at the anchor `x1`
  that `kvE_{fut,past}ChainDestructG` reconstructs, following the §2.4 recipe: k=1 is the landed
  `fChainFrom` base; k>=2 is that base extended by one Until-driven chain-link with the two-way
  `min`/case-split (`if y2 ≤ x_{n+1} then y2 else x_{n+1}`, both provably in `(z0,z1)`). Build this
  arity-generically where feasible (Fin.cons identity, report 01 §1.3 route a) so Phase 4 is thin.
- **Tasks:**
  - [ ] Run `kvE_futChainDestructG` (and past dual) to obtain the exterior anchor `x1` (past `x1<x`;
        future `t<x1`), the D-uniform gap, and per-item occurrences (landed; do not rebuild).
  - [ ] Apply the Phase-1 Until truth-lemma at the folded top anchor
        `(αn ∧ β_{n+1} Until α_{n+1})` to extract `y2 > y1` with `α_{n+1}(y2)` and `β_{n+1}` on
        `(y1, y2)`.
  - [ ] Transcribe the decidable `min`/case-split: `if y2 ≤ x_{n+1} then z := y2 else z := x_{n+1}`;
        prove `z ∈ (z0, z1)` in BOTH branches (report 02 §2.2). Mirror `fChainFrom`/`fChainPred`
        explicitly — no `simp`/`omega` bypass of the case-split.
  - [ ] Assemble the atom layer `nf_eval_nf M 0 4 [x1,w,x,t] σ.1` and fold the per-fiber
        biconditionals via `nf_eval_nfk_iff_efold` into `hσ` (mirror the converter body shape,
        ExteriorConverterK.lean:158–188).
  - [ ] Scoped build: `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`.
        Commit this green sub-step (`task 358 phase 2: constructive Cor 5.4(1) realizer hσ`).
- **Timing:** 4-6 hours (the hard core; report 01 §4 estimates hundreds of lines, de-risked by the
  landed destructor + k=1 template).
- **Depends on:** 1
- **Done when:** `hσ` is produced sorry-free as a standalone `have`/local lemma at the anchor, with
  the scoped module compiling. No `Classical.choice` at the realizer step (verify with a local
  `lean_verify` on any extracted helper).

### Phase 3: Discharge the eleven obligations + wire the `\| 1 =>` arm (:361) [NOT STARTED]
- **Goal:** Feed `hσ` through the landed converters + consumer + provider shim to discharge the
  eleven carried obligations and return the `\| 1 =>` arm, retiring the :361 sorry.
- **Tasks:**
  - [ ] Discharge the four exterior obligations via the bundles at the SELECTED `x1`:
        `hbrPastReal`/`hbrPastSat` ← `kvE_pastBundle_of_realizer hσ .1/.2`;
        `hbrFutReal`/`hbrFutSat` ← `kvE_futBundle_of_realizer hσ .1/.2` (report 01 §3 map).
  - [ ] Pin the ∀x1 / selected-x1 reconciliation (report 01 §3 subtlety): apply the converter at the
        destructor's `x1`; discharge the non-selected antecedent via the exclusion/off-fiber reading
        (`nf_eval_nfk_iff_efold` off-fiber branch).
  - [ ] Route the seven interior obligations (`hreal`/`hexcl` + internalized `hexclExt`) through
        `kampPrior_site_rungK_gate_match` → `bracketEndChar_kvExt_correct_prior` (`hexclExt` internal).
  - [ ] Instantiate `endInterval_step_correct` / `EndIntervalCorrectPrior` with the provider family
        from `kampPrior_existProviders_of_ih` (fed the recursion's own IH family) and the produced
        `hσ`; return `⟨endIntervalPrior atomMap h_surj charF Pfam k, proof⟩` for the `\| 1 =>` arm.
  - [ ] Replace the :361 `sorry`. Scoped build green. Commit
        (`task 358 phase 3: retire :361 n=1 arm, discharge eleven obligations`).
- **Timing:** 3-4 hours (mechanical given `hσ`, per report 01 §3 "fall out mechanically").
- **Depends on:** 2
- **Done when:** :361 sorry-free; `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`
  green; no new sorry introduced elsewhere.

### Phase 4: Retire the `\| n+2 =>` footprint arm (:364) — arity lift [NOT STARTED]
- **Goal:** Retire the :364 sorry so the completeness footprint carries no `sorryAx`. Preferred
  route (a): fold `\| 1 =>` and `\| n+2 =>` into one arity-generic construction via the Fin.cons
  identity `Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t` (KampPrior:203–211), reducing
  the arity-(n+1) existential at depth k+1 to an (n+1)-var existential at depth k available from the IH.
- **Tasks:**
  - [ ] Attempt route (a): reuse the Phase-2 arity-generic realizer + the Phase-3 discharge, keyed off
        the same `endIntervalPrior`/provider machinery, instantiated at arity n+2. The task-357 carrier
        threads arity via the `NormalForm sig … 5`/`… 4` fiber shapes (report 01 §1.3, encouraging).
  - [ ] If route (a) closes: replace the :364 `sorry`; scoped build green.
  - [ ] If route (a) is BLOCKED: attempt route (b) — the genuine multi-anchor (`x1 < … < xn`)
        increasing-sequence realizer (full Rabinovich Lemma 5.1). If route (b) also cannot close
        green: STOP — mark task [BLOCKED], spawn an isolated arity-lift sub-task (:364 kept separate),
        and do NOT land a sorry. Parent stays [BLOCKED], never [COMPLETED] with a carried sorry.
  - [ ] Commit the green step (`task 358 phase 4: retire :364 n+2 footprint arm`).
- **Timing:** 2-4 hours (route a) — open-ended if route (b) triggers; escalate rather than expand.
- **Depends on:** 3
- **Done when:** :364 sorry-free and scoped module green, OR task [BLOCKED] with a spawned isolated
  arity-lift sub-task. :364 is NOT silently deferrable.

### Phase 5: Full-tree green + axiom audit [NOT STARTED]
- **Goal:** Verify the terminus: full-project build and the clean completeness axiom footprint.
- **Tasks:**
  - [ ] `lake build` (full project) — GREEN, no sorries, no errors.
  - [ ] `lean_verify` on the fully-qualified `completeness_discrete`; confirm
        `#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]`
        (+ acceptable `ofReduceBool`/`trustCompiler` from `native_decide` in the Syntax layer).
        Any OTHER axiom (esp. `sorryAx`) is a FAIL → return to the offending phase.
  - [ ] Grep KampPrior.lean to confirm zero remaining `sorry` in `nf_nvar_exist_all_depths`.
  - [ ] Final commit (`task 358: complete implementation`) + summary artifact.
- **Timing:** 1-2 hours (build + verification).
- **Depends on:** 4
- **Done when:** full-tree build GREEN AND `#print axioms completeness_discrete` clean (no `sorryAx`,
  no stray axioms).

## Testing & Validation
- [ ] Scoped `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` green after each of
      Phases 2, 3, 4.
- [ ] Full `lake build` green in Phase 5.
- [ ] `lean_verify completeness_discrete` axiom footprint = `[propext, Classical.choice, Quot.sound]`
      (+ acceptable `ofReduceBool`/`trustCompiler`); NO `sorryAx`.
- [ ] No `sorry`/`admit`/vacuous `def X := True`/`Unit`/`trivial` introduced anywhere.
- [ ] No file other than `KampPrior.lean` modified.
- [ ] No `Classical.choice` at the realizer step (local `lean_verify` on extracted helpers).

## Artifacts & Outputs
- plans/02_realizer-recursion-implementation.md (this file)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean (edited: :361 and :364 arms)
- summaries/02_realizer-recursion-summary.md (on completion)

## Rollback/Contingency
- Each phase commits its own green sub-step; a failed phase leaves prior phases committed and green.
- If Phase 1 NO-GO (Until-witness not constructive / out-of-file-scope lemma needed): task [BLOCKED],
  spawn isolated constructive-Until-witness sub-task; no code changes landed.
- If Phase 4 route (a)+(b) both blocked: task [BLOCKED], spawn isolated arity-lift sub-task; :361
  stays landed and committed, :364 stays sorry (parent [BLOCKED], NOT [COMPLETED]).
- Zero-debt invariant: at no point land a strategic `sorry` or vacuous `def`. Escalate via [BLOCKED]
  + spawn instead (task brief mandate; recovery ladder in .claude/context/contracts/recovery.md).
