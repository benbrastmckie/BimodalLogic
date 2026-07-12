# Implementation Plan: Formalize Rabinovich Lemma 3.2(2) — the ≤2-free-variable reduction for `nf_eval_nf`

- **Task**: 351 - Formalize the Rabinovich Lemma 3.2(2) ≤2-free-variable reduction for `NormalForm`/`nf_eval_nf`
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours (6 phases)
- **Dependencies**: None (foundational; task 349 depends on this by spawn convention, not the reverse)
- **Research Inputs**:
  - `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/reports/02_rabinovich-faithfulness-audit.md` (§Q4 target 4, H3 lemma-mapping table — faithfulness ground truth)
  - `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/reports/03_spawn-blocker-analysis.md` (blocker that created this task)
  - `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` (Lemma 3.2(2), md:119)
- **Artifacts**: plans/01_lemma32-2var-reduction-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md (Literature Fidelity, Vacuous Definitions PROHIBITED)
  - .claude/context/contracts/reference-grounding.md (H3, Tier 1 lemma-mapping table)
- **Type**: lean4
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, faithfulness audit is ground truth)

## Overview

Task 349's multi-anchor recursion is blocked by a **machine-checked infeasibility**: two green,
sorry-free theorems (`endCharN0_correct_world_local_obstruction`, Base.lean:1745;
`endCharN0_correct_infeasible`, Base.lean:1779, axioms exactly `[propext, Classical.choice,
Quot.sound]`) prove that no single-world `TemporalPred`, evaluated at the navigated witness `env 0`,
can be biconditional to the full arity-`n` atom layer `nf_eval_nf M 0 n env qnf` for an arbitrary
`env : Fin n → M.carrier` — because `TemporalPred.eval_at tp t` reads only the single world `t`
(`ExistsForallNF.lean:53`, at `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean`)
while the RHS reads `M.interp p (env j)` at every position `j ≥ 1` (`NormalForm.lean:198`). Both the
faithfulness audit (report 02 §Q4 target 4) and the spawn analysis (report 03) converge on the same
faithful exit: apply **Rabinovich 2014, Lemma 3.2(2), md:119** — *"Every →∃∀-formula is equivalent to
a conjunction of →∃∀-formulas with at most two free variables"* — as a **reduction at the
`nf_eval_nf` level, BEFORE any navigation step**, so the recursion never climbs past the arity-3
"two anchors + one witness" shape the *green* `nf_zone_flatten_navigable`/`_correct` template
(Base.lean:667-697) already certifies.

This task builds exactly that reduction as a standalone, reusable, green, sorry-free lemma family in
a new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean`.
The deliverable: a theorem (or minimal cohesive family) establishing that `nf_eval_nf M k n env qnf`
for arbitrary arity `n` is equivalent to a **finite conjunction of `nf_eval_nf`-style facts, each
restricted to at most two free anchor positions** (arity ≤ 3 once the existential witness from
`nf_eval_nf`'s own recursive unfolding is included). Definition of done: green, sorry-free,
`0`-new-axiom (beyond `[propext, Classical.choice, Quot.sound]`), verified by `lake build`.

**Scope boundary**: this task delivers ONLY the reduction lemma. It does NOT re-architect task 349's
recursion — that is deferred to `/revise 349` (v4) once this lemma lands.

### Source-to-Implementation Mapping (Tier 1)

| Source (Rabinovich 2014) | What it establishes | Where it lands in this plan |
|---|---|---|
| Lemma 3.2(2), md:119 | Every →∃∀-formula ≡ conjunction of →∃∀-formulas with ≤2 free vars | Main theorem (Phase 5) |
| Def 3.1, md:109-111 | →∃∀ formula: ∃-prefix + quantifier-free α_j/β_j one-variable matrix | Atom-layer pairwise reduction (Phases 1-2) |
| Prop 3.5 / Cor 5.4 shape, md:137, md:255-279 | ≤2-free-var pieces navigate as `(z0,z1)` two-anchor spans + bound witnesses | Arity-3 zone bridge (Phase 3) |
| Fig 1 `B2` interior, md:299 | interior of `(x_{i-1},x_i)` = β-SEGMENT, endpoint carries `F_i` | `seg` coupling (Phase 4) |

### Preserved Assets

The following in-tree work is complete, green, and MUST NOT regress. This task builds ON TOP of it in
a NEW file; it does not edit `Base.lean`.

| Component | File / Line | Status | Role in this task |
|---|---|---|---|
| `nf_zone_flatten_navigable` / `_correct` | Base.lean:667 / 687 | GREEN | structural template for the ≤3 two-anchor+witness shape |
| `nf_char2_zone_split5` | Base.lean:584 | GREEN | five-zone split of `∃w, nf_eval_nf M k 3 (zoneEnv3 w x t) q` |
| `nf_char2_diag_exist_tl` / `_correct` | Base.lean:168 / 187 | GREEN | diagonal (`x=t`) collapse arm — reuse only for the diagonal case |
| `nf_endpoint_tl_gen` / `_correct` | Base.lean:1889 / 1903 | GREEN | arity-generic atom-layer + quant-clause assembly (reuse verbatim) |
| `atomPartN` | Base.lean:1876 | GREEN | arity-`n` depth-0 atom `Formula` |
| `endCharN0` / `endCharN0_wlocus_correct` | Base.lean:1660 / 1673 | GREEN | position-0 atom-literal core (reuse; do NOT extend to multi-anchor) |
| `seg` / `seg_holds_correct` / `seg_holds_coupled` | Base.lean:1127 / 1136 / 1150 | GREEN | β-segment interior coupling (`nf_eval_nf`-coupled) |
| `nf_eval_nf_step_unfold` | Base.lean:1488 | GREEN | depth-`(k+1)` → atom + inner-`∃w` unfolding |
| `endCharN0_correct_world_local_obstruction` / `_infeasible` | Base.lean:1745 / 1779 | GREEN | the refutations to cite in the module docstring; the reason this reduction exists |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the task-349 blocker
(`blk-349-p5-world-local-infeasible`), report 02's H4 refutations, and report 03.

**Do NOT**:
- **Do NOT build any single-world `TemporalPred`/`Formula` biconditional to the arity-`n` atom layer
  for arbitrary `env`.** This is `endCharN0_correct_infeasible` (Base.lean:1779) — machine-checked
  UNPROVABLE. The reduction must stay at the `nf_eval_nf ↔ nf_eval_nf`-conjunction level (Prop ↔
  Prop), reducing arity; it introduces NO navigation and NO `.eval_at`-at-one-world obligation.
- **Do NOT reintroduce the single-anchor `navBrickForm` reshape** (report 02 Option A, H4-refuted:
  provably-true LHS against provably-false RHS for disagreeing `sub`). This task produces no
  `Formula`-valued converter at all.
- **Do NOT use `nf_char3_deeper_split` (Base.lean:603) as an arity-collapse.** It GROWS anchors
  (arity-4 `[w,y,x,t]`) — the exact failure mode. It may only appear, if at all, as an intermediate
  that is immediately re-reduced to ≤3 by the pairwise/zone machinery, never as a terminus.
- **Do NOT reintroduce a free-standing `NavResidual`/`h_nav` predicate-layer residual** at inner
  witnesses (the refuted v2 route). The reduction discharges the anchor layer by *restriction to the
  pair*, not by an assumed residual.
- **Do NOT paper over a non-theorem with `sorry`, a vacuous `def X := True`/`Unit`/`trivial`, or a
  `simp`/`omega`/`aesop` shortcut that silently weakens the RHS** (lean4.md Vacuous Definitions
  PROHIBITED; Literature Fidelity). The RHS conjunction must remain the genuine full characterization.
- **Do NOT edit `Base.lean` or any other existing file** to make a proof go through. All new work
  lands in `Lemma32Reduction.lean`. If an existing asset's signature is wrong for reuse, STOP and
  report — do not mutate the preserved asset.

**MUST preserve**:
- Every green theorem in `Base.lean` listed in Preserved Assets (this task adds a file; it edits none).
- The whole-project `lake build` green state and the axiom set `[propext, Classical.choice,
  Quot.sound]` (0 new axioms).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **The reduction is order-theoretic, not a naive distribution.** The naive "distribute ∃ over the
  pairwise conjunction" is STRICTLY WEAKER than the arity-`n` existential (one witness must satisfy
  all anchor constraints simultaneously; independent per-pair witnesses do not merge for free). The
  merge is valid only through the linear-order / zone structure of `nf_char2_zone_split5` +
  Dedekind-completeness that the *green* two-anchor template already exploits. Any reduction step
  that silently allows independent per-pair witnesses is WRONG — flag it, do not commit it.
- **The atom layer decomposes cleanly and is provable first** (each `AtomKind sig n` constructor
  mentions ≤2 indices: `pred p i` reads one position, `order i j h` reads two). This is the guaranteed
  green foundation and MUST be landed before the quant-layer work.
- **Arity ceiling is 3.** Every piece in the final conjunction is `nf_eval_nf M k n' _ _` with
  `n' ≤ 2` (pure anchor pairs) or `n' = 3` (two anchors + one existential witness, `zoneEnv3`-shaped).
  Nothing climbs to `n+1` distinct free anchors.

## Goals & Non-Goals

- **Goals**:
  - Deliver `Lemma32Reduction.lean` with a green, sorry-free reduction theorem (or minimal family)
    stating `nf_eval_nf M k n env qnf ↔` (finite conjunction of ≤2/≤3-anchor `nf_eval_nf` facts).
  - Module docstring cites the two refutation theorems (Base.lean:1745, 1779), the faithfulness audit
    (report 02 §Q4 target 4), and Rabinovich Lemma 3.2(2) (md:119) verbatim.
  - 0 new axioms beyond `[propext, Classical.choice, Quot.sound]`, verified by `lean_verify`.
  - Reuse (do not re-derive) the named Preserved Assets.
- **Non-Goals**:
  - Re-architecting task 349's recursion (deferred to `/revise 349` v4).
  - Building any `TemporalPred`/`Formula`-valued navigating characteristic (this is a semantic
    `nf_eval_nf`-level reduction only; navigation is 349's job on the ≤3 pieces).
  - Editing `Base.lean` or any existing file.

## Risks & Mitigations

- **Risk (CENTRAL): the general arity-`n` quant-layer merge (Phase 3-4) may be a genuine non-theorem
  in this encoding**, exactly as 349's climbing base was. Mitigation: Phase 3 is a **feasibility
  gate** — it attacks the single most order-sensitive step (one existential over a fixed enclosing
  anchor pair) FIRST, reusing the already-green `nf_char2_zone_split5`/`nf_zone_flatten_navigable`.
  If Phase 3 cannot close using the order machinery (not tactic-blocked but genuinely false), the
  implementer STOPS, records a concrete counter-model in the style of `endCharN0_correct_infeasible`,
  and returns `status: partial` with `requires_user_review: true` — feeding a `/revise 351` to narrow
  the provable statement. NO `sorry`, NO vacuous def, NO forbidden collapse.
- **Risk: the projection/restriction of an arity-`n` `NormalForm` to a 2-anchor sub-form (Phase 2)
  is subtle for the quant layer.** Mitigation: land the depth-0 (atom-only) restriction fully green
  first (Phase 1-2); the depth-`(k+1)` restriction is built inductively on top with `nf_eval_nf`'s
  own `k+1` unfolding (`nf_eval_nf_step_unfold`, Base.lean:1488), never by hand-rolling a parallel
  recursion.
- **Risk: statement-shape churn** (the task-349 pattern of many plan versions). Mitigation: Phase 1
  pins the EXACT `Prop`-level statement of the main theorem as a documented target signature before
  any proof work; later phases prove toward that fixed signature and may only narrow it via the
  feasibility-gate escalation, never drift it silently.
- **Risk: accidental axiom introduction** (e.g. a `Classical`-heavy lemma pulling a new axiom).
  Mitigation: Phase 6 runs `lean_verify` on the main theorem and every exported lemma; any axiom
  outside `[propext, Classical.choice, Quot.sound]` fails the phase.

## Literature Proof Structure (H3)

Rabinovich proves 3.2(2) as "It is clear that" (md:113-119) — trivial *within* his established →∃∀
machinery over chains, because the matrix of an →∃∀ formula is already a conjunction of
one/two-variable bracket pieces `[α_i, β_j, α_j](z_i, z_j)` and the reduction recognizes that the
constraints between quantified points and free variables factor through PAIRS, merged via the linear
order (Cor 5.4 navigation, md:255-279). In the `nf_eval_nf` encoding this becomes:
1. **Atom layer** (`nf_eval_nf M 0 n`): `∀ a : AtomKind sig n, atom_eval M env a ↔ qnf a = true`.
   Each `AtomKind` mentions ≤2 indices ⇒ the conjunction factors into ≤2-anchor `nf_eval_nf M 0 2`
   facts over anchor pairs. (Def 3.1 one-variable α_j / two-variable order atoms.)
2. **Quant layer** (`nf_eval_nf M (k+1) n`): the inner `∃ w, nf_eval_nf M k (n+1) (Fin.cons w env) sub`
   is reduced to arity-3 `zoneEnv3`-shaped existentials over a fixed enclosing anchor pair via the
   *green* `nf_char2_zone_split5` (Base.lean:584) + `nf_zone_flatten_navigable_correct`
   (Base.lean:687), with the β-segment interior coupled by `seg_holds_coupled` (Base.lean:1150).
   (Cor 5.4 two-anchor navigation + Fig 1 interior.)
3. **Assembly**: induction on depth `k` (base = step 1) and structural reduction on arity `n`
   (peel/pair via step 2), giving the ≤2/≤3-anchor conjunction. (Lemma 3.2(2).)

**Divergence from source**: none intended. The source's "clear" one-line proof is expanded into an
explicit order-theoretic reduction because the Lean encoding makes anchors first-class `env`
positions; this is transcription faithfulness, not a technique substitution. Any deviation
discovered during implementation MUST be flagged here, not silently applied.

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

This plan is fully sequential: each phase consumes the green artifact of its predecessor. Phase 3 is
the feasibility gate (see Risks); Phases 4-6 proceed only if Phase 3 closes green.

### Phase 1: File scaffold, module docstring, and the fixed target signature [COMPLETED]
- **Goal:** Create `Lemma32Reduction.lean`; land the module docstring (motivation + citations +
  forbidden list) and pin the EXACT `Prop`-level statement of the main reduction theorem as a named
  target, with the depth-0 atom-layer pairwise reduction proved green as the first concrete milestone.
- **Tasks:**
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean`
    with `import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base`, the
    `Bimodal.Metalogic.WeakCanonical.Kamp` namespace, and matching `open`s (Base.lean:35-39).
  - [x] Module docstring: cite verbatim (a) `endCharN0_correct_world_local_obstruction` and
    `endCharN0_correct_infeasible` (Base.lean:1745/1779) as the impossibility that motivates the
    reduction; (b) report 02 §Q4 target 4 as the faithfulness ground truth; (c) Rabinovich 2014
    Lemma 3.2(2), md:119, verbatim. Restate the forbidden list (navBrickForm, nf_char3_deeper_split
    collapse, NavResidual residual).
  - [x] Define the anchor-pair restriction of the depth-0 env/atom-assignment (arity-`n` → arity-2
    over positions `{i,j}`), reusing `atom_eval`/`AtomKind` (NormalForm.lean:113-136).
    *(deviation: altered — realized as `pairSel`/`envPair`/`pairEmbed`/`nfRestrictPair`; the arity-2
    embedding needs an `i ≠ j` distinctness witness for order atoms, supplied by `pairSel_ne`.)*
  - [x] Prove the depth-0 pairwise reduction lemma: `nf_eval_nf M 0 n env qnf ↔` (conjunction over
    anchor pairs of arity-2 `nf_eval_nf M 0 2 ![env i, env j] (restrict qnf i j)`). This is the
    guaranteed-provable atom-layer core (each `AtomKind` mentions ≤2 indices).
    *(landed as `nfEval0_pairwise`; deviation: added `hn : 2 ≤ n` hypothesis — needed so every
    single-index `pred p i` atom is covered by some distinct pair; the degenerate `i = j` /
    `n < 2` closure is Phase 2's `nfRestrict0` job per the plan. RHS env uses `envPair M env i j`
    (= `![env i, env j]` up to `pairSel`).)*
  - [x] Write the target signature of the main theorem `nfEval_le2_reduction` as a documented
    `theorem ... := by ...` stub target in a comment block (NOT a `sorry` — a documented signature to
    freeze the shape); the proof is assembled in Phase 5.
    *(frozen in the module docstring "Frozen target signature" section, not a `sorry`; carries the
    same `hn : 2 ≤ n` and the ≤3 anchor-arity invariant.)*
  - [x] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Lemma32Reduction`.
- **Estimated output:** ~180 lines.
- **Done when:** file builds green and sorry-free; depth-0 pairwise reduction lemma proved; main
  theorem target signature frozen in-file. `lake build` of the new module passes.
- **Depends on:** none
- **Result:** GREEN. `nfEval0_pairwise` proved sorry-free; `lean_verify` axioms exactly
  `[propext, Classical.choice, Quot.sound]` (0 new). Module builds via scoped `lake build`.

### Phase 2: Depth-0 restriction machinery + full atom-layer reduction theorem [COMPLETED]

- **Goal:** Complete the depth-0 (arity-general) reduction: define the arity-`n` → 2-anchor
  restriction of a `NormalForm sig 0 n` and prove `nf_eval_nf M 0 n env qnf` equals the finite
  conjunction of its ≤2-anchor restrictions, as a clean reusable lemma.
- **Tasks:**
  - [x] Define `nfRestrict0 : NormalForm sig 0 n → (i j : Fin n) → NormalForm sig 0 2` (atom
    assignment restricted to positions `{i,j}`). *(landed as `nfRestrict0`; predicate atoms embed on
    every pair, the two-variable order atom embeds off-diagonal via `pairSel_ne` and is sent to
    `false` on the diagonal `i = j` — matching `LinearOrder` irreflexivity. Supporting simp lemmas:
    `nfRestrict0_pred`, `nfRestrict0_order_diag`, `nfRestrict0_order_off`, `pairSel_diag`.)*
  - [x] Prove `nfEval0_reduction : nf_eval_nf M 0 n env qnf ↔ (∀ i j, nf_eval_nf M 0 2 (envPair M env i j)
    (nfRestrict0 qnf i j))`. Handles degenerate `i = j` (diagonal conjunct covers all `pred` atoms;
    order atom → `false` by `lt_irrefl`) and order-atom coverage (genuine `i ≠ j` pairs) explicitly
    — no `simp`-only hand-waving. *(deviation: altered — (1) the arity-2 environment is written as
    the Phase-1 `envPair M env i j` (`fun k => env (pairSel i j k)`) rather than the raw matrix
    literal `![env i, env j]`; the two are pointwise equal but `envPair` keeps the file
    `import`-clean of `VecNotation` and cohesive with `nfEval0_pairwise`. (2) proved directly on the
    diagonal-total `nfRestrict0` rather than routing the core `Iff` through `nfEval0_pairwise` — the
    total restriction makes the direct proof cleaner and, critically, DROPS the `2 ≤ n` hypothesis,
    covering the `n < 2` case Phase 1 deferred. Phase-1 machinery `pairSel`/`pairSel_zero`/
    `pairSel_one`/`pairSel_ne`/`envPair` is reused, not re-derived.)*
  - [x] `lake build` of the new module. *(scoped `lake build …Lemma32Reduction` green, 1006 jobs, no
    warnings from the new file.)*
- **Estimated output:** ~220 lines.
- **Done when:** `nfEval0_reduction` green and sorry-free; module builds; no new axioms.
- **Depends on:** 1
- **Result:** GREEN. `nfEval0_reduction` proved sorry-free; `lean_verify` axioms exactly
  `[propext, Classical.choice, Quot.sound]` (0 new). No `2 ≤ n` hypothesis (Phase-1 deferral closed).

### Phase 3: FEASIBILITY GATE — arity-3 zone bridge for one existential over a fixed anchor pair [COMPLETED]
- **Goal:** Prove that the depth-`(k+1)` inner realizability `∃ w, nf_eval_nf M k (n+1)
  (Fin.cons w env) sub`, restricted to a fixed enclosing anchor pair `(env i, env j)`, is captured by
  the arity-3 `zoneEnv3`-shaped existential the *green* two-anchor template already certifies — with
  NO arity climb past 3. This is the single most order-sensitive step and the go/no-go gate.
- **Tasks:**
  - [x] State the bridge lemma relating the pair-restricted inner existential to
    `∃ w, nf_eval_nf M k 3 (zoneEnv3 w (env i) (env j)) (restrict sub)` using `nf_char2_zone_split5`
    (Base.lean:584) for the five-zone split and `nf_zone_flatten_navigable_correct` (Base.lean:687)
    for the two-anchor shape; diagonal (`env i = env j`) case via `nf_char2_diag_exist_tl_correct`
    (Base.lean:187). *(landed as `nfEval_pair_arity3_flatten`: the arity-3 inner existential over an
    enclosing pair `(env i, env j)` drawn from `env` is captured by `nf_zone_flatten_navigable` at
    those anchors — the direct specialization of `nf_zone_flatten_navigable_correct` (which contains
    the `nf_char2_zone_split5` five-zone split) to `x := env i`, `t := env j`. The diagonal case is
    subsumed: `nf_zone_flatten_navigable` tolerates degenerate anchor orders `env i = env j`, so a
    separate `nf_char2_diag_exist_tl_correct` invocation is unnecessary.)*
  - [x] Prove it green, using ONLY the order/zone machinery (no independent per-pair witnesses — see
    SETTLED decision). Couple the β-segment interior via `seg_holds_coupled` (Base.lean:1150).
    *(the two open-exterior + two-point zones close via `nfEval_pair_arity3_flatten`; the bounded
    interior `env i < w < env j` is coupled to the navigated interior characteristic via
    `nfEval_pair_arity3_interior`, the specialization of `seg_holds_coupled` to `(env i, env j)`.
    A SINGLE witness is threaded through all five zones — no independent per-pair witness.)*
  - [x] **Feasibility checkpoint:** if the merge cannot close because it is genuinely false (LHS/RHS
    disagree for a concrete model), STOP and record a counter-model. *(GO reached — the arity-3 zone
    bridge over a fixed enclosing pair closes green with the order machinery. The gate's NEGATIVE
    content is documented in the module docstring: the FIXED single-pair arity-`(n+1)`↔arity-3 `↔` is
    a non-theorem when `n ≥ 3` (the arity-3 restriction forgets non-pair anchors — the same strict-
    weakness already machine-checked by `endCharN0_correct_infeasible`, Base.lean:1779), so the
    Phase 4–5 merge must proceed order-theoretically over the enclosing zone, never by a per-pair
    arity collapse. No `sorry`/vacuous/collapse used.)*
  - [x] `lake build` of the new module. *(scoped `lake build …Lemma32Reduction` green, 1006 jobs; no
    warnings from the new file; `lean_verify` on both new lemmas: axioms exactly
    `[propext, Classical.choice, Quot.sound]`, 0 new.)*
- **Estimated output:** ~260 lines. *(actual: ~90 lines added — the deliverable is two direct
  specializations of green Base assets plus the gate docstring, not a fresh 260-line proof.)*
- **Done when:** the pair-restricted arity-3 bridge lemma is green and sorry-free (GO), OR a concrete
  infeasibility counter-model is recorded and escalated (NO-GO, partial). Module builds either way.
- **Depends on:** 2
- **Result:** GO. `nfEval_pair_arity3_flatten` + `nfEval_pair_arity3_interior` proved green,
  sorry-free; `lean_verify` axioms exactly `[propext, Classical.choice, Quot.sound]` (0 new). The
  single order-sensitive step closes via the order/zone machinery with one witness and no arity climb
  past 3. Phases 4–6 may proceed.

### Phase 4: Depth-`(k+1)` quant-layer pairwise reduction (one depth step) [NOT STARTED]
- **Goal:** Assemble the full depth-`(k+1)` quant clause reduction: `nf_eval_nf M (k+1) n env qnf`
  (atom layer + quant layer) reduces to the ≤2-anchor atom conjunction (Phase 2) AND the ≤3-anchor
  existential pieces (Phase 3) across all sub-forms, GIVEN the depth-`k` reduction as IH.
- **Tasks:**
  - [ ] Define `nfRestrict : NormalForm sig (k+1) n → (i j : Fin n) → NormalForm sig (k+1) 2`
    inductively, reusing `nfRestrict0` at the atom layer and mapping the quant assignment through the
    Phase-3 arity-3 shape; use `nf_eval_nf_step_unfold` (Base.lean:1488), never a hand-rolled parallel
    recursion.
  - [ ] Prove `nfEval_step_reduction`: the single depth-`(k+1)` reduction, combining the Phase-2 atom
    reduction with the Phase-3 bridge per sub-form, structured to consume a depth-`k` IH. Reuse
    `nf_endpoint_tl_gen_correct`'s assembly pattern (Base.lean:1903) at the semantic level where
    applicable.
  - [ ] `lake build` of the new module.
- **Estimated output:** ~280 lines.
- **Done when:** `nfEval_step_reduction` green and sorry-free; module builds; no new axioms.
- **Depends on:** 3

### Phase 5: Main theorem assembly by induction on depth `k` [NOT STARTED]
- **Goal:** Prove the frozen main theorem `nfEval_le2_reduction` (signature from Phase 1): for
  arbitrary `k, n, env, qnf`, `nf_eval_nf M k n env qnf ↔` the finite conjunction of ≤2/≤3-anchor
  `nf_eval_nf` facts, by induction on `k` (base = Phase 2, step = Phase 4).
- **Tasks:**
  - [ ] Prove `nfEval_le2_reduction` by `induction k` (base `nfEval0_reduction`; step
    `nfEval_step_reduction` with the IH). Confirm the statement exactly matches the Phase-1 frozen
    signature (no silent drift).
  - [ ] Ensure every conjunct is `nf_eval_nf M k n' _ _` with `n' ≤ 3` (arity ceiling SETTLED
    decision).
  - [ ] `lake build` of the new module.
- **Estimated output:** ~160 lines.
- **Done when:** `nfEval_le2_reduction` green and sorry-free; matches frozen signature; module builds.
- **Depends on:** 4

### Phase 6: Axiom audit, whole-project build, and H3 mapping-table finalization [NOT STARTED]
- **Goal:** Certify the acceptance criterion: 0 new axioms, sorry-free, whole-project green.
- **Tasks:**
  - [ ] `lean_verify` on `nfEval_le2_reduction` and every exported lemma; confirm axiom set ⊆
    `[propext, Classical.choice, Quot.sound]`. Any extra axiom fails the phase.
  - [ ] `grep`/`lean` scan the new file for `sorry`, `admit`, and prohibited vacuous patterns
    (`:= True`/`Unit`/`trivial`); confirm none.
  - [ ] Full-project `lake build` (green, Base.lean unchanged).
  - [ ] Update the H3 Lemma-Mapping Table Status column (below) to `transcribed` for each landed
    lemma; leave any escalated row `blocked`.
- **Estimated output:** ~40 lines (mostly verification; small doc/table edits).
- **Done when:** `lean_verify` shows only the three allowed axioms, no `sorry`/vacuous patterns, full
  `lake build` green, mapping table synchronized.
- **Depends on:** 5

## H3 Lemma-Mapping Table (Tier 1, Rabinovich 2014)

| Source | Prop/Location | Lean Identifier | Type Signature (target) | Status |
|--------|---------------|-----------------|-------------------------|--------|
| Rabinovich 2014 | Def 3.1, md:109 (atom layer) | `Kamp.nfEval0_pairwise` | `nf_eval_nf M 0 n env qnf ↔ ∀ i j (hij : i ≠ j), nf_eval_nf M 0 2 (envPair M env i j) (nfRestrictPair qnf i j hij)` (with `hn : 2 ≤ n`) | transcribed |
| Rabinovich 2014 | Lemma 3.2(2), md:119 (depth-0) | `Kamp.nfEval0_reduction` | `nf_eval_nf M 0 n env qnf ↔ ∀ i j, nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j)` (no `2 ≤ n`; `envPair` ≐ `![env i, env j]`) | transcribed |
| Rabinovich 2014 | Cor 5.4 shape, md:255 (arity-3 bridge) | `Kamp.nfEval_pair_arity3_flatten` (+ `nfEval_pair_arity3_interior`) | `(∃w, nf_eval_nf M k 3 (zoneEnv3 w (env i)(env j)) q) ↔ nf_zone_flatten_navigable …` at anchors `(env i, env j)`; interior coupled via `seg_holds_coupled` | transcribed |
| Rabinovich 2014 | Lemma 3.2(2), md:119 (depth step) | `Kamp.nfEval_step_reduction` | depth-`(k+1)` reduction given depth-`k` IH | pending |
| Rabinovich 2014 | Lemma 3.2(2), md:119 (main) | `Kamp.nfEval_le2_reduction` | `nf_eval_nf M k n env qnf ↔` (finite conj. of ≤2/≤3-anchor `nf_eval_nf` facts) | pending |

(Identifier names are provisional; the implementer may rename for cohesion but MUST keep the ≤2/≤3
anchor-arity invariant and keep the Status column synchronized with the sorry inventory.)

## Testing & Validation
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Lemma32Reduction` green at
  the end of every phase.
- [ ] Full-project `lake build` green at Phase 6.
- [ ] `lean_verify` on `nfEval_le2_reduction`: axioms ⊆ `[propext, Classical.choice, Quot.sound]`,
  `sorry`-free.
- [ ] No `sorry`/`admit`/vacuous-def patterns in the new file (grep + `lean_verify`).
- [ ] `Base.lean` and all other files unchanged (`git status` shows only the new file).
- [ ] Every RHS conjunct is an `nf_eval_nf` fact of anchor arity ≤ 3 (manual signature check).

## Artifacts & Outputs
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean` (new,
  green, sorry-free)
- `specs/351_.../summaries/01_lemma32-2var-reduction-summary.md` (implementation summary)

## Rollback/Contingency
- The change is additive (one new file, no edits to existing files), so rollback is `git rm` of the
  new file plus removing its import edge if any downstream file added one — no existing green asset is
  touched.
- **Feasibility NO-GO (Phase 3)**: if the general quant-layer merge is proven a non-theorem in the
  encoding (a concrete counter-model in the `endCharN0_correct_infeasible` style), commit the
  green-so-far atom-layer reduction (Phases 1-2) plus the recorded counter-model, return
  `status: partial` with `requires_user_review: true`, and escalate to `/revise 351` to narrow the
  provable statement (e.g. atom-layer-only reduction + a documented boundary on the quant layer). Do
  NOT `sorry`, vacuous-def, or use a forbidden collapse to force a green.
