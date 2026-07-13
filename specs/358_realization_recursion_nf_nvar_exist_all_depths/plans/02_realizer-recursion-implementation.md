# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` (Rabinovich Cor 5.4(1) ⇐)

- **Task**: 358 - Land the `nf_nvar_exist_all_depths` n>=1 arms (KampPrior.lean:361, :364), produce the genuine realizer `hσ`, discharge the eleven task-356/357 obligations, retire the completeness sorry
- **Status**: [IMPLEMENTING]
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

### Phase 1: Interface pin + constructive Until-witness verification (escalation gate) [COMPLETED]
- **Goal:** Confirm the caveats are satisfied BEFORE any construction: (a) all nine Preserved-Asset
  interfaces resolve by name at their current locations; (b) the project's `Until` truth-lemma
  exposes the Until-witness CONSTRUCTIVELY on the target discrete/integer (Reynolds) model. This is
  the single real dependency and the escalation boundary (report 02 caveat 1).
- **Tasks:**
  - [x] `lean_local_search` / `lean_hover_info` each of the nine interfaces in the Preserved Assets
        table; record the current file:line and full type signature of each. If 341 has moved any,
        re-locate by name and note the new location (do not edit them).
        *(done 2026-07-12: all nine resolve; see Phase 1 Findings below. One relocation:
        `kampPrior_existProviders_of_ih` is a 3-lemma family now at KampPrior.lean:989/:1013/:1043,
        plan said :972 — located by name, not edited)*
  - [x] Locate the project's `Until` truth-lemma (the semantics lemma unfolding `Until`/`Since`
        satisfaction on `OrderedMonadicStructure`). Record its exact name and signature.
        *(done: it is DEFINITIONAL — `Bimodal.Metalogic.WeakCanonical.temporal_truth`,
        Table.lean:182; `.untl` case at :190-191 unfolds to
        `∃ s, t < s ∧ temporal_truth M atomMap s φ ∧ ∀ r, t < r → r < s → temporal_truth M atomMap r ψ`
        — exactly the Rabinovich witness shape; `.snce` dual at :192-193. No separate named lemma
        exists or is needed: the landed k=1 template consumes it via
        `simp only [temporal_truth]` + `obtain ⟨s, hs_lt, hs_F, hs_seg⟩` at EANegation.lean:594-611,
        :637-647)*
  - [x] Determine whether it yields, from `y1 ⊨ (β Until α)`, a CONSTRUCTIVE witness
        `y2 > y1` with `α(y2)` and `β` on `(y1, y2)` (decidable, no `Classical.choice`) on the
        discrete/integer model. Use `lean_hover_info` on the lemma; if it produces an existential
        that is eliminable without `Classical.choice`, it is constructive-viable.
        *(done: CONSTRUCTIVE-VIABLE, verified by machine probe `until_witness_probe` (lean_run_code)
        transcribing the exact Cor 5.4(1) ⇐ inductive step — extraction + two-way case-split —
        compiling green with axiom closure `[propext, Classical.choice, Quot.sound]`, IDENTICAL to
        the ambient baseline: a bare `Exists.intro` lemma over these types shows the SAME closure
        (Mathlib `LinearOrder` floor), as do all nine preserved assets. The realizer step adds NO
        new axiom and no choice-based selection: extraction is Prop-level `Exists.elim`; the
        case-split uses `le_total`/`le_or_gt` from the bundled `LinearOrder`
        (`OrderedMonadicStructure.carrier_order`, MonadicFO.lean:103-109). Grounded against
        Rabinovich chunk 0015 lines 25-35: "If y2 ≤ xn+1 then z = y2 … otherwise xn+1 ∈ (y1,y2) …
        z = xn+1")*
  - [x] GO/NO-GO: if constructive-viable AND all nine interfaces resolve → proceed to Phase 2. If the
        Until-witness is only classical, OR requires a NEW lemma in another file (out of file scope)
        → STOP: mark task [BLOCKED], spawn an isolated constructive-Until-witness sub-task, do NOT
        proceed.
        *(verdict: **GO** — all nine interfaces resolve by name; Until-witness constructive-viable;
        no new lemma needed outside KampPrior.lean; no sorry introduced)*

**Phase 1 Findings (pinned interfaces, 2026-07-12)**:

| # | Interface | Pinned location | Signature (essence) |
|---|-----------|-----------------|---------------------|
| 1 | `kvE_futChainDestructG` | ExteriorNegationK.lean:293 | from item-uniformity + `kvE_futChainG` at `s`: `∃ x1, s < x1 ∧ endF(x1) ∧ (∀ r ∈ (s,x1), D r) ∧ ∀ a ∈ l, ∃ r ∈ (s,x1), itemF a r` |
| 1b | `kvE_pastChainDestructG` (dual) | ExteriorNegationPastK.lean:353 | mirror: `∃ x1 < s, endF(x1) ∧ D on (x1,s) ∧ per-item occurrence` |
| 2 | `kvE_futBundle_of_realizer` | ExteriorConverterK.lean:208 | `hσ : nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x fun _=>t))) σ → (∀ s, σ.2 s = true → ∃ v, nf_eval_nf M k 5 … s) ∧ (∀ s, nfk_dropFresh s = σ.1 → (∃ v, …) → σ.2 s = true)` |
| 3 | `kvE_pastBundle_of_realizer` | ExteriorConverterPastK.lean:177 | same shape as #2 (past) |
| 4 | `bracketEndChar_kvExt_correct_prior` | ExteriorGateAssembleK.lean:106 | 6 order-bit hyps + 6 gate hyps → `VVecEA2.holds M atomMap (bracketEndChar_kvExt …) x t ↔ ∃ w, nf_eval_nf M (k+2) 3 … qnf` |
| 5 | `endInterval_step_correct` / `EndIntervalCorrectPrior` | EndIntervalConsumerK.lean:171 / :95 | `∀ …, EndIntervalCorrectPrior atomMap h_surj charF Pfam k` (consumer green) |
| 6 | `kampPrior_site_rungK_gate_match` | KampPrior.lean:816 | same 6+6 hypothesis seam as #4, gate-match at supply site |
| 7 | `kampPrior_existProviders_of_ih_{correct,exist1,existF0_char}` | KampPrior.lean:989/:1043/:1013 | provider shim fed by IH family `ih : ∀ n sub, ∃ A, ∀ M …, truth A ↔ ∃ env, nf_eval_nf M j (n+1) (insertEnv env t) sub` *(moved from :972; family of 3)* |
| 8 | `BracketFormula.fChainFrom`/`fChainPred`/`fChainFrom_base` | EANegation.lean:552/:567/:580 | k=1 realizer template; `fChainFrom_base`: eval ↔ pointType ∧ ∃ s > x, segment on (x,s) |
| 9 | `nf_nvar_exist_all_depths` `\| 0 =>` / `\| k+1,0 =>` arms | KampPrior.lean:212 (def), n=0 arm :335-346 sorry-free, k=0 base :224 | sorries ONLY at :361 (`\| 1 =>`) and :364 (`\| n+2 =>`) — exactly the two targets |

**Phase 2 implementation notes from probe**: (a) `le_or_lt` is deprecated in this toolchain —
use `le_or_gt`; (b) do not project `M.carrier_order.decidableLE` directly (no such projection in
current Mathlib) — use `le_total`/`le_or_gt`/`inferInstance`; (c) axiom-floor for ALL green
assets is `[propext, Classical.choice, Quot.sound]` — the Phase-2 `lean_verify` bar is "no axiom
beyond this floor, no `sorryAx`", not literal absence of `Classical.choice` (which is baked into
the Mathlib `LinearOrder` types themselves, as the bare-`Exists.intro` baseline probe proved).
- **Timing:** 1-2 hours (verification only; no proof edits unless an inline adapter is trivially
  in-scope in KampPrior.lean).
- **Depends on:** none
- **Done when:** every interface pinned with a recorded signature AND a named constructive Until
  truth-lemma identified (GO), OR task marked [BLOCKED] with a spawned sub-task (NO-GO). No sorry
  introduced.

### Phase 2: Produce the realizer `hσ` — Cor 5.4(1) ⇐ base + one Until-link (n=1, arity 4) [COMPLETED]
- **Goal:** Construct the genuine within-bracket realizer
  `hσ : nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _=>t)))) σ` at the anchor `x1`
  that `kvE_{fut,past}ChainDestructG` reconstructs, following the §2.4 recipe: k=1 is the landed
  `fChainFrom` base; k>=2 is that base extended by one Until-driven chain-link with the two-way
  `min`/case-split (`if y2 ≤ x_{n+1} then y2 else x_{n+1}`, both provably in `(z0,z1)`). Build this
  arity-generically where feasible (Fin.cons identity, report 01 §1.3 route a) so Phase 4 is thin.
- **Tasks:**
  - [x] Run `kvE_futChainDestructG` (and past dual) to obtain the exterior anchor `x1` (past `x1<x`;
        future `t<x1`), the D-uniform gap, and per-item occurrences (landed; do not rebuild).
        *(done 2026-07-12: consumed inside the drivers `kampPrior_futRealizer_of_pos` /
        `kampPrior_pastRealizer_of_pos` (KampPrior.lean end section) — the positive-existence
        reading of the `kvE_extNeg{Fut,Past}_complete` bodies, emitting the SELECTED anchor,
        the endpoint description `kvE_{fut,past}End`, and `hσ`)*
  - [x] Apply the Phase-1 Until truth-lemma at the folded top anchor
        `(αn ∧ β_{n+1} Until α_{n+1})` to extract `y2 > y1` with `α_{n+1}(y2)` and `β_{n+1}` on
        `(y1, y2)`. *(done: `kampPrior_fChain_realize_from` extracts the Until-witness `y` of
        each link through the landed `fChainFrom_step` characterization — the definitional
        `temporal_truth` `.untl` reading, consumed via the k=1 template as the plan's
        "extension of the landed base"; deviation: altered — extraction goes through
        `fChainFrom_step`/`fChainFrom_base` rather than a raw `simp only [temporal_truth]`
        at the anchor, which is the SAME definitional content in the template's packaged form)*
  - [x] Transcribe the decidable `min`/case-split: `if y2 ≤ x_{n+1} then z := y2 else z := x_{n+1}`;
        prove `z ∈ (z0, z1)` in BOTH branches (report 02 §2.2). Mirror `fChainFrom`/`fChainPred`
        explicitly — no `simp`/`omega` bypass of the case-split.
        *(done: TWO explicit two-way case-splits landed — the per-link `le_or_gt y (x (i+1))`
        in `kampPrior_fChain_realize_from` (branch 1: witness `y` itself; branch 2: bound point
        `x (i+1) ∈ (v, y)` with segment restriction), invariant `w a ≤ x (i+a)` keeping both
        branches in-bracket; and the endpoint `le_or_gt s z1` in
        `kampPrior_fChain_realize_bracket` (z := s vs z := z1 by final-segment restriction).
        This is the bounded resolution of the EANegation.lean:1249 Until-unboundedness
        obstruction; both case-splits are explicit `rcases le_or_gt`)*
  - [x] Assemble the atom layer `nf_eval_nf M 0 4 [x1,w,x,t] σ.1` and fold the per-fiber
        biconditionals via `nf_eval_nfk_iff_efold` into `hσ` (mirror the converter body shape,
        ExteriorConverterK.lean:158–188).
        *(done: `kampPrior_futRealizer_assemble` / `kampPrior_pastRealizer_assemble` — atom layer
        via `kvE_{fut,past}Atom_of_bundle` on a designated bit-true self-zone fiber, off-fiber
        falsity via `kvE_{fut,past}Admissible_offFiber`, fold via `nf_eval_nfk_iff_efold`;
        exact inverses of `kvE_{fut,past}Bundle_of_realizer`. The at-anchor fiber transfer
        enters through the `hreal`/`hsat` hypothesis shapes — the same shapes
        `kvE_futBundle_of_realizer` proves sound — which Phase 3 discharges at the selected
        anchor per the plan's reconciliation task)*
  - [x] Scoped build: `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`.
        Commit this green sub-step (`task 358 phase 2: constructive Cor 5.4(1) realizer hσ`).
        *(done: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` — Build completed
        successfully (1032 jobs); `lean_verify` on `kampPrior_fChain_realize_bracket`,
        `kampPrior_futRealizer_of_pos`, `kampPrior_pastRealizer_of_pos`: axiom closure exactly
        `[propext, Classical.choice, Quot.sound]` (== ambient floor, no `sorryAx`, no new
        axiom); no new sorry — file sorries remain exactly the inherited :361/:364)*

**Phase 2 Findings (2026-07-12)**: seven new sorry-free theorems at the end of KampPrior.lean:
`kampPrior_fChain_realize_cons` (Fin.cons prepend transfer), `kampPrior_fChain_realize_from`
(the Cor 5.4(1) ⇐ inductive engine, suffix form), `kampPrior_fChain_realize` (arity-generic
chain realizer, i=0 instance), `kampPrior_fChain_realize_bracket` (partial-bracket form,
`∃ z ∈ (z0,z1]` with `bf.holds z0 z`), `kampPrior_futRealizer_assemble` /
`kampPrior_pastRealizer_assemble` (σ-level `hσ` fold at the anchor), and
`kampPrior_futRealizer_of_pos` / `kampPrior_pastRealizer_of_pos` (destructor-selected anchor +
`hσ` from `kvE_{fut,past}Pos`). The chain realizer is stated for every `BracketFormula (n+1)`
(arity-generic, report 01 §1.3 route a) so Phase 4 reuses it verbatim.
- **Timing:** 4-6 hours (the hard core; report 01 §4 estimates hundreds of lines, de-risked by the
  landed destructor + k=1 template).
- **Depends on:** 1
- **Done when:** `hσ` is produced sorry-free as a standalone `have`/local lemma at the anchor, with
  the scoped module compiling. No `Classical.choice` at the realizer step (verify with a local
  `lean_verify` on any extracted helper).

### Phase 3: Discharge the eleven obligations + wire the `\| 1 =>` arm (:361) [BLOCKED]

**BLOCKER** (Phase 3, 2026-07-12, machine-grounded — see handoffs/phase-3-blocker-20260712.md for
the full record):
- **What failed**: The plan's step-(a) obligation→converter map ("`hbrFutReal` ←
  `kvE_futBundle_of_realizer hσ .1`", report 01 §3) is unexecutable: the four exterior `hbr*`
  obligations bind σ with `qnf.2 σ = false` (UNMARKED σ), for which no realizer `hσ` exists to feed
  the converter. Machine probe (compiled green via `lean_run_code` against the site binder shapes,
  EndIntervalConsumerK.lean:142-146): with the strongest ⇐-direction ambient
  `h : nf_eval_nf M (m+2) 3 [w0,x,t] qnf` in scope, `hno : ¬ ∃ x1', nf_eval_nf M (m+1) 4
  [x1',w0,x,t] σ` is derivable from `(h.2 σ).mp` + `qnf.2 σ = false`, while the remaining goal
  `∃ v, nf_eval_nf M m 5 [v,x1,w,x,t] s` (pinned fiber realization at an ARBITRARY exterior
  `x1 > t`, no truth antecedent) has no realizer-typed fact in context. Semantically FALSE on
  Prior models with sparse predicates (e.g. the landed probe model `P2M = (ℤ,<), P={0,10,20}`,
  ExteriorFiberProbeK.lean: pick σ admissible with `σ.1` prescribing the predicate at the fresh
  slot, `x1` a non-predicate point above `t` — no `v` can realize any on-fiber bit-true `s`).
  Task 356's own summary concedes exactly this (summaries/01:52-55: "This is **not derivable from
  `h`**: an unmarked σ … is realized at NO `x1` … so no realizer exists to feed
  `kvE_futBundle_of_realizer`") — the interface was threaded outward on a discharge promise that
  fails at the outermost (KampPrior recursion) site, where no further "outward" exists.
- **What was tried**: (i) full source trace of the consumption chain — the obligations are consumed
  only inside `kvE_extNeg{Fut,Past}_complete` (ExteriorConverterK.lean:126-137 /
  ExteriorConverterPastK.lean) at DESTRUCTOR-SELECTED anchors under a local `hpos` (chain-firing)
  ambient that the outward-threaded binder shape does NOT carry; (ii) discharge from the endpoint
  truth channel — `kvE_futEnd` (ExteriorNegationK.lean:395) contains only free-env positive fiber
  content (`P.existF 4` re-anchored), which cannot pin the outer coordinates `(w,x,t)`; (iii)
  vacuity routes — the gate ⇐ half is vacuous for bit-false qnf but is genuinely needed for every
  REALIZED (bit-true) qnf in the `∀qnf` agreement, where the same false instances arise; (iv) the
  plan's step-(b) off-fiber reconciliation — inapplicable: both `hbrFutReal`'s `s` (bit-true) and
  `hbrFutSat`'s `s` (`nfk_dropFresh s = σ.1`) are ON-fiber.
- **Why stuck**: two independent gaps. (1) THE PINNING GAP (= the plan's own pre-named escalation
  atom, Postmortem Constraints: "the fiber-level `HasAttainedINF` existence converse"): all landed
  truth channels (`kvE_futEnd`/`kvE_futGapD`/chain content) deliver fiber realization with FREE
  outer env (`∃ env : Fin 4 → M.carrier`, `P.existF 4`-shaped), but the obligations demand
  realization PINNED to the site's `(w,x,t)`; deriving pinned from free is the un-landed arity-5
  general-depth converse (Rabinovich Cor 5.4(2) re-anchoring in the existence direction). The
  Phase-2 realizer engine (chain realizer over `BracketFormula`) pins witnesses between bracket
  ENDPOINTS but has no bridge from the `kvE_*` fiber-zone truth channel to `BracketFormula` content
  at the fiber level. (2) THE ARM-ASSEMBLY GAP: even with all eleven obligations discharged,
  retiring :361 requires folding the per-qnf `VVecEA2` carrier biconditionals into the arm formula
  (`∀qnf` agreement → `quantEnd`/`seg` hooks → `nf_char2_{past,future}_formula_correct`/
  `A_diag_correct` → `kampPrior_case1_trichotomy_assemble`). No such fold is landed: the task-349
  `endCharRec`/`endChar` pipeline exists only as docstring-frozen signatures (Base.lean:1521-1563,
  1954-1977 — inside `/-! -/` blocks, no declarations) with its base shape machine-refuted
  (`endCharN0_correct_infeasible`, Base.lean:1779), and the task-309 Phase-18/19 hooks are
  explicitly undischarged (KampPrior.lean:1123: "No hook is discharged here"). The plan's "return
  `⟨endIntervalPrior …, proof⟩`" does not typecheck (`BracketEndCharCarrierV` is not a `Formula`).
- **What is needed**: a literature-grounded research pass (Rabinovich 2014 Cor 5.4, §5, chunks
  0013-0016) that settles (a) the faithful statement of the fiber-level pinned-realization converse
  (arity-5, general depth — the Cor 5.4(1) ⇐ argument applied ONE fiber level down, with the
  outer coordinates carried as bracket endpoints), and (b) whether the `hbr*` binders in the
  interface chain (ExteriorConverterK.lean:126-134 → ExteriorBracketAssembleK.lean:181-191 →
  ExteriorGateAssembleK.lean:142-167 → KampPrior.lean:845-870 → EndIntervalConsumerK.lean:129-154)
  must be restated to carry the chain-firing truth antecedent (`kvE_futPos`/`kvE_futEnd` truth)
  under which they are actually consumed — an out-of-file-scope interface revision — and (c) the
  carrier→formula arm assembly route (hooks or a corrected endChar-style fold). Items (a)+(b) are
  out of KampPrior.lean file scope → orchestrator escalation per task mandate.
- **Prohibited**: Do NOT use sorry, `def X := True`, or any vacuous placeholder; do NOT edit the
  interface chain from this dispatch (out of file scope).

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
