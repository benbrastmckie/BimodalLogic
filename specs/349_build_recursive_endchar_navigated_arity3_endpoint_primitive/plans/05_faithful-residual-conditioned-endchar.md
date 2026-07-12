# Implementation Plan: Task #349 (v5 — faithful residual-conditioned `endChar`)

- **Task**: 349 - Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: Task 351 (LANDED — `nfEval_le2_reduction` family, green, sorry-free, 0-new-axiom)
- **Research Inputs**:
  - reports/05_rabinovich-faithful-endchar-architecture.md (AUTHORITATIVE — Tier-1 literature-grounded
    faithful architecture; §3 corrected Lean architecture, §4 5-column faithfulness table, §5 adversarial
    self-verification, §6 the 4-phase v5 breakdown this plan realizes)
  - reports/04_arity4-bridge-feasibility-audit.md (the arity-4 enclosing-pair bridge NON-THEOREM
    refutation — the trap v5 must avoid; the reason v4 Phases 3–5 are superseded)
  - reports/02_rabinovich-faithfulness-audit.md (three-level free-variable discipline; navigate-not-collapse)
  - specs/REVIEW_codebase-restructure/03_routeA-feasibility-audit.md (confirms 349 is the shared
    bottleneck; sole open obligation = residual threading at the k+1 step)
- **Artifacts**: plans/05_faithful-residual-conditioned-endchar.md (this file); supersedes plans/04_reduction-navigated-endchar.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md; literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: true
- **reports_integrated**: [05_rabinovich-faithful-endchar-architecture.md]

## Overview

Build the recursive navigated arity-3 endpoint primitive `endChar : (k : Nat) → EndCharCarrier sig k`
(FROZEN carrier `EndCharCarrier sig k = NormalForm sig k 3 → TemporalPred`, Base.lean:1007) plus its
correctness theorem `endChar_correct`, by recursion on modal depth `k` at fixed anchor arity 3. This is
plan **v5**; it supersedes v4 (plans/04), whose Phase-3 architecture — a closed `Formula`-valued
`navPieceForm` used as the `innerConv` of `nf_char3_endpoint_tl`, read at one point before the anchors
`(x,t)` are quantified — was proven a machine-checked **NON-THEOREM** (report 04 §2.1;
`endCharN0_correct_infeasible`, Base.lean:1779). That defect is **parameter-independence**: a `Formula`
fixed before `(x,t)` is a constant function of `(x,t)`, but its target `∃w, nf_eval_nf M k 4 [w,y,x,t] sub`
is non-constant in `(x,t)`; constant ≢ non-constant.

The faithful replacement (report 05 §3) mirrors Rabinovich's three-level free-variable discipline exactly:
reduce the arity-4 inner existential to a ≤2-free-anchor conjunction **FIRST** (Lemma 3.2(2)), characterize
each conjunct with the **Prop-valued, x,t-EXPLICIT** `nf_zone_flatten_navigable_correct` (immune to the
refutation because x,t appear on both sides), state `endChar_correct` at **every** `k` with the
**anchor-residual hypothesis `h_res`** (generalizing the already-green `endChar0_correct`), and collapse to
a closed `Formula`/`TemporalPred` **only at the base** `endChar0` (≤1 free anchor, the Proposition 3.5
analog). The new step builder `endCharStep` replaces the deleted `nf_char3_endpoint_tl` inner-Formula
converter.

**Definition of done**: `endChar`/`endChar_correct` sorry-free; `lean_verify endChar_correct` = exactly
`[propext, Classical.choice, Quot.sound]`; scoped `lake build` (Base module + NavigatedEndChar) GREEN and
final full-tree `lake build` GREEN; `git status --short` touches only `Base.lean` (additive) and
`NavigatedEndChar.lean` (+ this plan/summary); the correctness statement is the residual-conditioned
x,t-explicit form (NEVER the refuted unconditional world-local form); task 309 Phase 18/19 can cite
`endChar_correct` by name.

### Feasibility posture (from report 05 §0, §5)

The corrected correctness statement **survives** every constant-vs-non-constant / world-locality test that
killed the prior three architectures (report 05 §5.1, claims 1–5, 7 all High confidence). The **one**
remaining open obligation is **residual threading** (§5.1 claim 6, Medium confidence): whether the `k+1`
step can supply `h_res` for its ≤2-anchor sub-pieces from its own `h_res` plus the bracket-exterior
navigation. This is **not** a non-theorem (the base case proves the mechanism; `nf_zone_flatten_navigable_correct`
proves the x,t-explicit carrier) — it is a *proof-engineering* obligation on a well-typed, non-refuted
statement, categorically different from the three prior non-theorem dead-ends. Verdict:
**FEASIBLE-PENDING-RESIDUAL-THREADING**. Phase 3 is the feasibility gate; if threading fails it escalates
to `[BLOCKED]` with the exact `lean_goal` recorded — it does **not** stub with `sorry` or a vacuous def.

### Preserved Assets

The following work is complete, green, sorry-free, and **must not regress or be rebuilt**. Phase-1/2 v4
assets and the Base green machinery are consumed by name.

| Component | File:line | Status | Role in v5 |
|-----------|-----------|--------|------------|
| `nfEval3_reduction` (+ `_zero_shape` / `_succ_shape`) | NavigatedEndChar.lean:75 | [COMPLETED] v4 Phase 1 | arity-3 reduction specialization (Step A) — **preserve verbatim** |
| `endCharNav0_correct` (+ `_pairwise`) | NavigatedEndChar.lean:118 | [COMPLETED] v4 Phase 2 | reduced-RHS base (composes with `nfEval3_reduction`) — **preserve verbatim** |
| `navPieceForm` / `navPiece_reduce` | NavigatedEndChar.lean:196/215 | [COMPLETED] v4 Phase 3a | `navPiece_reduce` RETAINED as Step A specialization; `navPieceForm` def retained (its `_correct` is FORBIDDEN, never stated) |
| `endChar0` / `endChar0_correct` / `endChar0_wlocus_correct` | Base.lean:995/1056/1015 | [COMPLETED] prior | Prop 3.5 collapse (base); base case of `endChar_correct` (the `h_res` shape) |
| `nf_zone_flatten_navigable` / `_correct` / `_brick` | Base.lean:667/687/813 | [COMPLETED] prior | Step B — Prop-valued, x,t EXPLICIT on both sides |
| `seg` / `seg_holds_correct` / `seg_holds_coupled` | Base.lean:1127/1136/1150 | [COMPLETED] prior | Step C — β-segment interior (G3, never `⊤`) |
| `nf3_locus0` / `nf_depth0_char_formula` / `_correct` | Base.lean:982/999 | [COMPLETED] prior | Step D — position-0 atom locus |
| `nfEval_le2_reduction` | Lemma32Reduction.lean:535 | [COMPLETED] task 351 | Step A — Rabinovich Lem 3.2(2) arity-4→≤3 |
| `EndCharCarrier` (abbrev) | Base.lean:1007 | [COMPLETED] frozen | REUSE unchanged (FROZEN carrier, not widened) |
| `endCharN0_correct_infeasible` (+ `sigCex`/`Mcex`/`atomMapCex`) | Base.lean:1779 | [COMPLETED] refutation | negative guardrail — the no-`h_res` refutation; document WHY the unconditional form is FORBIDDEN |

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014, residual-conditioned realization)

Load-bearing decisions cite `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(md:NNN) via report 05 §4. Reproduced here so every phase's target is grounded.

| Rabinovich construct (paper §/lemma) | Role | Lean target (name) | Green asset consumed | Guard (G1–G5) |
|---|---|---|---|---|
| Def 3.1 `∃∀`-formula, md:109 | normal form, n+1 bound witnesses | `NormalForm sig k 3` (read-pt + 2 anchors) | `nf_eval_nf` (NormalForm.lean:198) | G1: arity fixed 3, no arity-1 collapse |
| Lemma 3.2(2) ≤2 free vars, md:119 | reduce arity-n → ≤2-free conjunction FIRST | `endCharStep` Step A | `nfEval_le2_reduction` (Lemma32Reduction:535), `navPiece_reduce` (NavEndChar:215) | G2/G4: witness `v` stays bound; anchors ⊆ {x,t}, ≤2 |
| Prop 4.2 + §5 negation/navigation at 2 free, md:165/195 | two-endpoint characterization, x,t explicit | `endCharStep` Step B | `nf_zone_flatten_navigable_correct` (Base:687) | G2/G4: x,t explicit on both sides, ≤2 free |
| §5 Notation 5.2 `[…](z0,z1)`, md:219 | enclosing-pair interval formula | `nf_zone_flatten_navigable M atomMap x t …` | Base:687 (x,t = z0,z1) | G4: x,t are the enclosing pair, not a 3rd anchor |
| Lemma 5.3 `r0=inf`, re-anchor, md:233–247 | navigate + re-anchor endpoint (`w` bound, never free) | `bracketBuildLeft/Right` exterior hooks (`pastEnd`/`futureEnd`) | `nf_zone_flatten_navigable_correct` h_past/h_fut | G2/G4: `w` bracket witness, never a 3rd free anchor |
| Cor 5.4 chain `F_{i-1}:=α_{i-1}∧(β_i Until F_i)`, md:261 | endpoint characteristic chain | `endChar k` recursion hook (IH) | `endChar_correct k` (residual form) | G5: manual `or_congr`/`exists_congr`, no simp shortcut |
| Cor 5.4 `β_i` interval predicate, md:263 | interior "holds-along" segment | `seg` interior = `endChar qnf` | `seg_holds_coupled` (Base:1150) | G3: `seg` interior, never `⊤` |
| Prop 3.5 collapse at **1** free, md:137 | TL formula at one point (base only) | `endChar0` | `endChar0_correct` (Base:1056), `endCharNav0_correct` (NavEndChar:118) | G1: collapse only at base, ≤1 free locus |
| single-world char CANNOT certify arbitrary multi-anchor `env` | (Lean impossibility) | forbidden target | `endCharN0_correct_infeasible` (Base:1779) | forbids the unconditional world-local form |

## Goals & Non-Goals

**Goals**:
- Define `endChar : (k) → EndCharCarrier sig k` (FROZEN arity-3 carrier UNCHANGED) by `Nat.rec` on depth
  `k`: `endChar 0 = endChar0`; `endChar (k+1) = endCharStep (endChar k)`.
- Prove `endChar_correct` at **every** `k` in the **residual-conditioned, x,t-explicit** form
  (report 05 §3.2): base = `exact endChar0_correct …` (green); step discharged via reduce-first (Step A)
  + Prop-valued x,t-explicit flatten (Step B) + `seg` interior (Step C) + position-0 collapse (Step D).
- Keep everything sorry-free; `lean_verify` axioms exactly `[propext, Classical.choice, Quot.sound]`;
  additive-only to `Base.lean` and `NavigatedEndChar.lean`.

**Non-Goals**:
- Building any `Formula`-valued inner converter fixed before the anchors (the defect site
  `nf_char3_endpoint_tl` + `innerConv`, Base.lean:869/885 — DELETED from the critical path).
- Stating `navPieceForm_correct` (the non-theorem biconditional — FORBIDDEN; the `navPieceForm` *def* and
  `navPiece_reduce` *reduction* are retained as different objects).
- Any `nf_char3_deeper_split` / arity-4 collapse / arity-4-enclosing-pair single-point read (report 04
  NON-THEOREM).
- The unconditional, x,t-implicit world-local `endChar_correct` shape (`endCharN0_correct_infeasible`,
  UNPROVABLE).
- Re-deriving task 351's `nfEval_le2_reduction` family (imported, not rebuilt).
- Editing the seven frozen provider files, `KampPrior.lean`, `Lemma32Reduction.lean`, or
  `nf_nvar_exist_all_depths`'s signature.
- Widening the frozen `EndCharCarrier sig k` abbreviation (Base.lean:1007).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Residual threading fails at the k+1 step** (the ONE known risk, report 05 §5.1 claim 6): `endCharStep`'s invocation of `endChar_correct k` on sub-pieces cannot obtain their `h_res` from its own `h_res` + bracket-exterior structure | H | M | Phase 3 is the dedicated feasibility gate. Attack: derive each sub-piece's `h_res` from the enclosing `h_res` (positions 1,2 pinned) plus the fresh witness's atom facts supplied by the `nf_zone_flatten_navigable_correct` endpoint hooks. **Fallback**: if it cannot close, mark `[BLOCKED]`, record the exact `lean_goal` showing the missing residual, and escalate (`/spawn 349` for a residual-threading lemma) — do NOT stub with `sorry`, a vacuous def, or a forbidden collapse (report 05 §5.2, Phase 3 contingency) |
| Phase 3 exceeds one agent run (>500 lines / open-ended proof) | M | H | Pre-declared split at the def/proof seam: **3a** = assemble `endCharStep` def + STATE the k+1 case of `endChar_correct`; **3b** = discharge Steps B–D + residual threading. Each 3a/3b is its own committable green unit. Bounded-unit stop condition: 3a is green once the def elaborates and the statement typechecks; 3b's stop condition is the k+1 goal closed OR `[BLOCKED]` with recorded goal |
| Temptation to re-state the refuted `Formula`-valued `navPieceForm_correct` / unconditional world-local form because it "looks cleaner" | H | M | PROHIBITED — machine-checked NON-THEOREM (report 04; `endCharN0_correct_infeasible`). The discriminator is `h_res` + x,t-explicitness (report 05 §5.2). Phase 1 pins the residual-conditioned target and records the counterexample pointer |
| Temptation to fake green with `sorry` / `def X := True` / a forbidden collapse when Step B/D resists | H | M | PROHIBITED (postmortem constraints). A stuck main target is `[BLOCKED]` + `lean_goal` record, never a fake green |
| Accidental edit to a frozen file (`Lemma32Reduction.lean`, the 7 providers, `KampPrior.lean`, `nf_nvar_exist_all_depths` sig) | H | L | Never open them for edit; verify `git status --short` shows only `Base.lean` (additive) + `NavigatedEndChar.lean` (+ plan/summary) before each commit |
| Manual Rabinovich chain-step bridge tempts a `simp`/`omega`/`aesop` shortcut | M | M | G5 binding: manual `constructor`/`intro`/`or_congr`/`exists_congr`/`and_congr_right` bridges only, mirroring `nf_zone_flatten_navigable_correct` (Base.lean:700-706) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |

Phases are **sequential** (report 05 §6 wave/territory note): each depends on the prior's
`endChar_correct` shape. No parallel wave — this is a single-territory recursion. Territory: **additive**
edits to `Base.lean` (new `endCharStep`, `endChar`, `endChar_correct`) and `NavigatedEndChar.lean`;
**no edits** to the seven frozen providers, `KampPrior.lean`, `Lemma32Reduction.lean`, or
`nf_nvar_exist_all_depths`'s signature.

**Per-phase hard bar (applies to every `[NOT STARTED]` phase)**:
- sorry-free; `lean_verify` on the phase's new correctness lemma = exactly
  `[propext, Classical.choice, Quot.sound]`; scoped `lake build` of the Base module +
  `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.NavigatedEndChar` GREEN.
- Explicit "reuse vs rebuild" note satisfied; preserved assets consumed by name, never rebuilt.
- **Guards (binding)**: G1 no arity-1 collapse (arity fixed at 3, closed-Formula collapse only at base);
  G2/G4 anchors ⊆ {x,t}, ≤2, `w`/`v` bracket witnesses never a third free anchor; G3 non-trivial `seg`
  interior (never `TemporalPred.top`); G5 manual bridges only (no `simp`/`omega`/`aesop` on a Rabinovich
  chain step). FORBIDDEN (grep-confirmed absent in new code): `nf_char3_deeper_split`, arity-4 collapse /
  arity-4-enclosing-pair single-point read, the unconditional x,t-implicit world-local form,
  `navPieceForm_correct`. `EndCharCarrier` FROZEN (not widened); frozen-file edits (git-scope confirmed).

### Phase 1: Spec freeze — residual-conditioned `endChar_correct` statement + `endChar` skeleton + base case [COMPLETED]

- **Goal:** State `endChar_correct` (report 05 §3.2) as the residual-conditioned biconditional at general
  `k`, and the `endChar : (k) → EndCharCarrier sig k` skeleton with `endChar 0 = endChar0`. Prove the
  **base case** by `exact endChar0_correct …` (already green). Leave the step (`endChar (k+1)`) as a named
  hole to be filled in Phases 2–3. This replaces v4's Phase-3 interface, which was built on the defective
  `nf_char3_endpoint_tl`.
- **Exact statement to freeze** (report 05 §3.2 — do NOT re-freeze the unconditional form):
  ```lean
  theorem endChar_correct {sig} (M) (atomMap)
      (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p) :
      ∀ (k : Nat) (qnf : NormalForm sig k 3) (w x t : M.carrier)
        (h_res : ∀ atom : AtomKind sig 3, (∀ p, atom ≠ AtomKind.pred p 0) →
          (atom_eval M (zoneEnv3 w x t) atom ↔ (qnf atom = true))),
      (endChar atomMap h_surj k qnf).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (zoneEnv3 w x t) qnf
  ```
- **Skeleton to freeze** (report 05 §3.3):
  ```
  endChar 0     qnf = endChar0 atomMap h_surj qnf         -- Prop 3.5 collapse, ≤1 free
  endChar (k+1) qnf = endCharStep (endChar k) qnf          -- new builder, Phase 2–3 hole
  ```
- **Reuse vs rebuild:** REUSE `endChar0`/`endChar0_correct` (Base.lean:995/1056), `zoneEnv3`, `atom_eval`,
  `AtomKind`, `EndCharCarrier` (frozen, Base.lean:1007). BUILD only the statement + skeleton + base-case
  proof. The `h_res` hypothesis shape is `endChar0_correct`'s residual generalized to arbitrary `k`.
- **Tasks:**
  - [x] State `endChar_correct` verbatim in the residual-conditioned x,t-explicit form above. *(frozen as
        a pinned spec in the NavigatedEndChar.lean "Phase 1 (v5)" docstring; the compiled base building
        block `endChar_correct_zero` realizes the `k=0` instance — deviation: the full `∀k` `endChar_correct`
        theorem name is produced in Phase 4 by induction, since a `∀k` theorem cannot leave the k+1 step a
        sorry-free hole in Phase 1.)*
  - [x] Define the `endChar` skeleton by `Nat.rec`; `endChar 0 = endChar0`; the step names `endCharStep`
        (declared, body deferred to Phase 3 — a scaffolded hole, not a `sorry`'d theorem). *(`endCharStep`
        carries a genuine `TemporalPred`-valued SCAFFOLD body `endChar0 … qnf.1` — the position-0 atom
        layer — replaced fix-forward in Phase 3; not vacuous, not proof-carrying.)*
  - [x] Prove the `k=0` case: `exact endChar0_correct …` (green, carries `h_res`). *(`endChar_correct_zero`,
        closed by `exact endChar0_correct M atomMap h_surj qnf w x t h_res` via the `Nat`-rec zero-branch
        defeq.)*
  - [x] Record (docstring at the `endChar_correct` site) the FORBIDDEN unconditional form pointer
        (`endCharN0_correct_infeasible`, Base.lean:1779) and WHY `h_res` + x,t-explicitness is the
        discriminator (report 05 §5.2).
  - [x] Route audit: grep-confirm no `nf_char3_endpoint_tl` `innerConv` dependency, no `navPieceForm_correct`,
        no unconditional world-local claim; `EndCharCarrier` unchanged; git-scope clean. *(grep clean in new
        code: the only `navPieceForm_correct`/`sorry` tokens are prose in FORBIDDEN/`sorry-free` docstrings;
        `EndCharCarrier` untouched; git scope = NavigatedEndChar.lean + plan only.)*
- **Estimated output:** ~100–150 lines.
- **Done when:** the statement + `endChar` skeleton + `k=0` base compile; no `sorry` in the base;
  `lean_verify` on the base-discharging lemma = `[propext, Classical.choice, Quot.sound]`; scoped build GREEN.
- **Depends on:** none.
- **Files to modify:** `.../NfMultiAnchorBridge/NavigatedEndChar.lean` (and/or `Base.lean` additively, per the
  §6 territory note — additive only).

### Phase 2: `endCharStep` Step A — arity-4 → nfEvalRHS reduction (reduce FIRST) [COMPLETED]

- **Goal:** Build the arity-4 → nfEvalRHS reduction wiring inside the step: for each `sub : NormalForm sig
  k 4`, apply `navPiece_reduce` / `nfEval_le2_reduction` to expose the ≤2-free-anchor (≤ arity-3)
  conjunction BEFORE any Formula conversion. This is where v4 went wrong by converting to `Formula` first;
  here reduction is first (report 05 §3.4 Step A, §5.3).
- **Exact reduction to establish** (report 05 §3.4 Step A):
  ```
  (∃v, nf_eval_nf M k 4 [v,w,x,t] sub) ↔ (∃v, nfEvalRHS M k 4 [v,w,x,t] sub)
  ```
  where `nfEvalRHS` is a finite conjunction of `nf_eval_nf` facts each of anchor arity ≤ 3 (Lemma 3.2(2)
  ≤2-free cap, md:119). Witness `v` stays existential, OUTSIDE the reduced inner form (SETTLED merge).
- **Reuse vs rebuild:** REUSE (consume) `nfEval_le2_reduction` (Lemma32Reduction.lean:535) and the already-green
  `navPiece_reduce` (NavigatedEndChar.lean:215 — its witness-outside reduction is retained verbatim);
  `nfEval3_reduction` (+ `_zero`/`_succ`_shape, NavigatedEndChar.lean:75). BUILD only the thin step-level
  reduction lemma that the Phase-3 assembly consumes. Do NOT rebuild any of the reduction family.
- **Tasks:**
  - [x] Prove the step-level reduction lemma exposing the ≤2-free-anchor conjunction for each arity-4 `sub`,
        via `exists_congr` + `nfEval_le2_reduction` / `navPiece_reduce` (witness `v` OUTSIDE).
        *(`endCharStep_reduceA` (per-`sub`, consumes `navPiece_reduce`) + `endCharStep_quant_reduceA`
        (whole quant layer via `forall_congr'`/`iff_congr`, witness `v` OUTSIDE, `qnf.2` verbatim).)*
  - [x] Confirm via `nfEval3_reduction_succ_shape` / `nfEvalRHS_succ` that every emitted `nf_eval_nf`
        conjunct is arity ≤ 3 (no arity climb past 3 among emitted facts).
        *(`nfEval4_reduction` (+`_zero_shape`/`_succ_shape`): emitted atom facts are `nf_eval_nf M 0 2 …`,
        anchor arity 2; the "4"/"5" are recursion env domains, never emitted anchor arities.)*
  - [x] Route audit: **no `Formula`-valued converter yet**; witness `v` stays existential (G2/G4);
        no per-pair `∀ij ∃w` distribution; no arity-collapsing `nfRestrict`; grep clean.
        *(`navPieceForm_correct`/`nf_char3_deeper_split` tokens appear only in prose docstrings;
        `nfRestrict0` used only on the atom layer; `lean_verify` on all 5 = `[propext, Classical.choice,
        Quot.sound]`; git scope = NavigatedEndChar.lean + plan only; Base.lean untouched.)*
- **Estimated output:** ~150–250 lines.
- **Done when:** the step-level reduction lemma is green and sorry-free; `lean_verify` =
  `[propext, Classical.choice, Quot.sound]`; scoped build GREEN; emitted conjuncts confirmed arity ≤ 3.
- **Depends on:** 1.
- **Files to modify:** `.../NavigatedEndChar.lean` (and/or `Base.lean` additively).

### Phase 3: `endCharStep` Steps B–D + step correctness (FEASIBILITY GATE — the ONE known risk) [NOT STARTED]

- **Goal:** Assemble `endCharStep (endChar k) qnf : TemporalPred` from `nf_zone_flatten_navigable`
  (x,t EXPLICIT) + `seg` interior + position-0 locus, and prove the `k+1` case of `endChar_correct`,
  discharging the endpoint/interior hooks from the IH `endChar_correct k` **with the threaded residual**.
  This phase is the residual-threading feasibility gate (report 05 §5.1 claim 6, §6 Phase 3). It replaces
  v4 Phases 3b/4/5.
- **The four discharge steps** (report 05 §3.4):
  - **Step B — characterize each ≤2-anchor conjunct with x,t EXPLICIT (Prop-valued).** Use
    `nf_zone_flatten_navigable_correct M atomMap x t pastEnd futureEnd q` (Base.lean:687), LHS
    `(∃w, nf_eval_nf M k 3 [w,x,t] q)` and RHS both carrying x,t explicitly → immune to the refutation.
    Endpoint hooks `pastEnd := endChar k`, `futureEnd := endChar k`; their correctness `h_past`/`h_fut`
    **is the depth-`k` IH `endChar_correct k`** (residual form) at the navigated witness.
  - **Step C — interior segment.** The bounded interior rides `seg` via `seg_holds_coupled` (Base.lean:1150),
    whose `h_endChar` hook is again `endChar_correct k`. Interior predicate = the genuine `endChar k qnf`
    (G3: non-trivial, never `TemporalPred.top`).
  - **Step D — collapse only at the base.** The position-0 atom layer is `endChar0`'s locus (`nf3_locus0`);
    anchors pinned by `h_res`. The single-free-variable Prop 3.5 collapse — the ONLY closed-`Formula` read.
  - **Residual threading (the gate):** each Step-B/C invocation of `endChar_correct k` on a sub-piece must
    obtain that sub-piece's `h_res` from `endCharStep`'s own `h_res` (positions 1,2 pinned) plus the fresh
    bracket witness's atom facts. This is the unproven obligation.
- **Reuse vs rebuild:** REUSE `nf_zone_flatten_navigable`/`_correct`/`_brick` (Base.lean:667/687/813),
  `seg`/`seg_holds_coupled` (Base.lean:1127/1150), `nf3_locus0`/`nf_depth0_char_formula` (Base.lean:982/999),
  the Phase-2 step-reduction, and the IH `endChar_correct k`. BUILD `endCharStep` (the new step builder) and
  the k+1 correctness proof. This REPLACES the deleted `nf_char3_endpoint_tl` inner-Formula converter — do
  NOT resurrect it or state `navPieceForm_correct`.
- **Tasks:**
  - [ ] **(3a)** Define `endCharStep (rec : EndCharCarrier sig k) qnf : TemporalPred` assembled from
        `bracketBuildLeft/Right` (navigation) + `seg` interior + position-0 locus, with x,t flowing as
        explicit parameters of the Prop-valued flatten. STATE the k+1 case of `endChar_correct`.
  - [ ] **(3b)** Discharge Step B (`h_past`/`h_fut` from IH), Step C (`h_endChar` from IH, `seg` interior),
        Step D (position-0 via `nf3_locus0`, anchors pinned by `h_res`), and thread the residual from
        level `k+1` to each ≤2-anchor sub-piece at level `k`. Manual bridges (G5).
  - [ ] Route audit: G2/G4 (every `w`/`v` a bracket witness; free anchors ≤2, arity capped at 3), G3
        (`seg` interior non-trivial, never `⊤`), G5; no `nf_char3_deeper_split`; no arity-4 collapse; no
        `navPieceForm_correct`; no per-pair `∀ij ∃w` distribution; no `nfRestrict`. Grep clean.
- **Pre-declared split (bounded-unit / >500-line guard):** if the step overruns one agent run, split at the
  def/proof seam: **3a** = `endCharStep` def + k+1 statement (stop condition: def elaborates, statement
  typechecks); **3b** = the Steps-B–D + residual-threading proof (stop condition: k+1 goal closed OR
  `[BLOCKED]` with recorded `lean_goal`). Each is its own committable green unit.
- **Feasibility-gate contingency (report 05 §5.2, §6 Phase 3):** if the residual cannot be threaded through
  the bracket exteriors, mark `[BLOCKED]`, document the exact `lean_goal` state showing the missing
  residual, and escalate (`/spawn 349` for a residual-threading lemma) — **do NOT stub with `sorry`, a
  vacuous def, a forbidden collapse, a single-anchor reshape, or a per-pair distribution.** This is a
  proof-engineering block on a non-refuted statement, not a non-theorem dead-end.
- **Estimated output:** ~300–500 lines (the flagged load-bearing core; split 3a/3b if it overruns).
- **Done when:** `endCharStep` def is green AND the k+1 case of `endChar_correct` is closed sorry-free;
  `lean_verify` = `[propext, Classical.choice, Quot.sound]`; scoped build GREEN. (Or `[BLOCKED]` with
  recorded goal per the contingency.)
- **Depends on:** 1, 2.
- **Files to modify:** `.../NavigatedEndChar.lean` (and/or `Base.lean` additively — new `endCharStep`).

### Phase 4: Recursion close + axiom audit [NOT STARTED]

- **Goal:** Define `endChar` by `Nat.rec` (base `endChar0`, step `endCharStep`), prove `endChar_correct` by
  induction on `k` (base from Phase 1, step from Phase 3), and confirm all definition-of-done gates
  (report 05 §6 Phase 4).
- **Reuse vs rebuild:** REUSE `endChar0` (base), `endCharStep` (Phase 3 step), `endCharNav0_correct`
  (NavigatedEndChar.lean:118), the Phase-1 statement and Phase-3 step proof. REBUILD nothing green.
- **Tasks:**
  - [ ] Close `endChar` = `Nat.rec endChar0 (fun k rec => endCharStep rec)`; confirm it genuinely recurses
        (not vacuous).
  - [ ] Prove `endChar_correct` by induction on `k`: base = Phase-1 `k=0`; step = Phase-3 k+1 with the IH
        instantiated to `endChar_correct k` (residual form).
  - [ ] `lean_verify endChar_correct` (fully qualified) = exactly `[propext, Classical.choice, Quot.sound]`,
        no `sorry`, no new axiom.
  - [ ] Whole-project `lake build` GREEN (scoped Base + NavigatedEndChar at minimum; full tree recommended).
  - [ ] Confirm G1–G5 and the FORBIDDEN list (`nf_char3_deeper_split`, arity-4 collapse, unconditional
        world-local form, `navPieceForm_correct`) are absent from the final term; `git status --short`
        shows only `Base.lean` (additive) + `NavigatedEndChar.lean` (+ plan/summary) — NO frozen-file edits.
  - [ ] Grep-confirm `endChar_correct` is a top-level citable name reachable by task 309 Phase 18/19.
- **Estimated output:** ~100–200 lines.
- **Done when:** `endChar`/`endChar_correct` sorry-free and green by induction; axiom audit exactly
  `[propext, Classical.choice, Quot.sound]`; full-tree build GREEN; file scope confirmed; 309-citable.
- **Depends on:** 3.
- **Files to modify:** `.../NavigatedEndChar.lean` (and/or `Base.lean` additively).

## Testing & Validation

- [ ] Scoped `lake build` of the Base module + `...NfMultiAnchorBridge.NavigatedEndChar` GREEN after every
      phase (per-phase gate).
- [ ] Final full-tree `lake build` GREEN.
- [ ] `lean_verify` on `endChar_correct`, `endCharStep`'s k+1 lemma, the Phase-2 step-reduction, and
      `endChar` = exactly `[propext, Classical.choice, Quot.sound]`, no `sorry`, no new axiom.
- [ ] `endChar_correct` is the RESIDUAL-CONDITIONED, x,t-EXPLICIT form (report 05 §3.2), carrying `h_res`
      at every `k` — NEVER the unconditional world-local shape (`endCharN0_correct_infeasible`).
- [ ] The arity-4 inner existential is reduced to ≤2-free-anchor pieces (Step A) BEFORE any Formula
      conversion; closed-`Formula` collapse occurs ONLY at the base `endChar0` (Step D).
- [ ] Navigation never climbs past anchor arity 3; `w`/`v` witnesses via `Fin.cons` are bracket witnesses,
      not free-anchor growth (G2/G4); `seg` interior non-trivial (G3); manual bridges only (G5).
- [ ] No occurrence of `nf_char3_deeper_split`, arity-4 collapse, `navPieceForm_correct`, or the
      unconditional world-local form in the new/added code; `EndCharCarrier` not widened.
- [ ] `git status --short` shows only `Base.lean` (additive) + `NavigatedEndChar.lean` under `Theories/`
      modified — NO `Lemma32Reduction.lean`, NO frozen-provider, NO `KampPrior.lean`, NO change to
      `nf_nvar_exist_all_depths`'s signature.
- [ ] `endChar`/`endChar_correct` are top-level, name-citable declarations reachable by task 309.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the report-04 NON-THEOREM refutation, the
report-05 adversarial self-verification (§5), the v4 postmortem, and known failure modes. Landing any
forbidden construct is a `[BLOCKED]` escalation, never a silent workaround.

**Do NOT**:
- State any `Formula`-valued inner converter fixed before the anchors `(x,t)` are quantified — the exact
  defect site `nf_char3_endpoint_tl` + `innerConv` (Base.lean:869/885). It is **parameter-independence**:
  constant-in-(x,t) LHS vs non-constant-in-(x,t) RHS (report 04 §2.1). DELETED from the critical path.
- State `navPieceForm_correct` — the non-theorem biconditional (report 05 §2). The `navPieceForm` *def*
  and the `navPiece_reduce` *reduction* are RETAINED as different objects (report 05 §5.3); only the
  `_correct` is forbidden.
- Use `nf_char3_deeper_split`, an arity-4 collapse, or an arity-4-enclosing-pair single-point read — the
  arity-4 enclosing-pair bridge is a machine-checked NON-THEOREM (report 04; `Lemma32Reduction.lean:290-306`).
- State the unconditional, x,t-implicit world-local `endChar_correct` — UNPROVABLE
  (`endCharN0_correct_infeasible`, Base.lean:1779). The correctness MUST carry `h_res` at every `k`.
- Use the naive per-pair `∀ij ∃w` distribution (SETTLED non-theorem for `n ≥ 3`) or the arity-collapsing
  quant `nfRestrict` (IS the non-theorem). The single witness stays outside (order-theoretic `∃w ∀ij`).
- Fake green with `sorry`, `def X := True`/`Unit`/`trivial`, or a `simp`/`omega`/`aesop` shortcut that
  silently weakens the RHS. A stuck main target is `[BLOCKED]` + `lean_goal` record.

**MUST preserve** (green, do not rebuild or regress — see Preserved Assets table):
- v4 Phase-1/2 assets: `nfEval3_reduction` (+shapes), `endCharNav0_correct` (+`_pairwise`),
  `navPieceForm`/`navPiece_reduce`.
- Base green machinery: `endChar0`/`endChar0_correct`, `seg`/`seg_holds_coupled`,
  `nf_zone_flatten_navigable`/`_correct`/`_brick`, `nf3_locus0`, `nfEval_le2_reduction`.
- The frozen `EndCharCarrier sig k` type and the negative guardrail `endCharN0_correct_infeasible`.

**Design decisions are SETTLED** (do not re-open without a concrete machine-checked counterexample):
- **`h_res` is the central invariant** (report 05 §5.3): `endChar_correct` is stated with the anchor
  residual at *every* `k`, never the unconditional form. `endChar0_correct` (green, with `h_res`) vs
  `endCharN0_correct_infeasible` (refuted, without `h_res`) is the exact discriminator.
- **Reduce arity FIRST, convert to Formula only at the base** (report 05 §1.1, §3.4): Lemma 3.2(2) reduces
  to ≤2 free (Step A); Prop 4.2/§5 navigates at exactly 2 free with x,t explicit and Prop-valued (Step B);
  Prop 3.5 collapses to a closed formula ONLY at ≤1 free (Step D, base only).
- **`nf_zone_flatten_navigable_correct` is the faithful x,t-explicit carrier** (report 05 §5.1 claim 1),
  NOT a new bridge lemma to spawn — it already exists and is green; its endpoint hooks are the depth IH.
- **Navigation re-anchors, never adds a third free variable** (Rabinovich Lemma 5.3, md:233–247): the fresh
  witness `w`/`v` is existentially bound and immediately becomes the new endpoint (G2/G4).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedEndChar.lean` — additive:
  the residual-conditioned `endChar_correct` statement + base (Phase 1), the Step-A step-reduction (Phase 2),
  `endCharStep` + k+1 correctness (Phase 3), and the `endChar`/`endChar_correct` recursion close (Phase 4).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — additive ONLY (new
  `endCharStep`, `endChar`, `endChar_correct` may land here per the report-05 §6 territory note); the seven
  frozen providers, `KampPrior.lean`, `Lemma32Reduction.lean`, and `nf_nvar_exist_all_depths`'s signature
  are UNTOUCHED.
- `specs/349_.../plans/05_faithful-residual-conditioned-endchar.md` (this plan; supersedes plans/04).
- `specs/349_.../summaries/05_faithful-residual-conditioned-endchar-summary.md` (on completion).

## Rollback/Contingency

- Work is confined to additive edits in `NavigatedEndChar.lean` and `Base.lean`; rollback is `git checkout`
  of the additive hunks (or `rm`/revert if uncommitted). The seven frozen providers, `Lemma32Reduction.lean`,
  and `KampPrior.lean` are never touched, so no green asset can be lost by a v5 rollback. Snapshot before any
  intentional rollback per "No Destructive Git on Uncommitted Work" (`bash .claude/scripts/git-snapshot.sh`
  first).
- Each green phase (and each 3a/3b sub-step) is committed as it lands (commit-per-green-substep mandate);
  no progress is lost across dispatches.
- **Phase 3 feasibility gate**: if residual threading cannot close green without a forbidden construct, mark
  Phase 3 `[BLOCKED]`, record the exact `lean_goal` + the missing residual-threading lemma, return
  `status: partial` with `requires_user_review: true`, and `/spawn 349` for the single missing lemma. Do
  NOT land a vacuous, `sorry`'d, unconditional-world-local, collapse, or per-pair-distributed `endChar`.
