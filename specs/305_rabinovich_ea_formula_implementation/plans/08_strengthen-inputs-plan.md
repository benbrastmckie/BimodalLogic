# Implementation Plan: Strengthen nvar_transfer Inputs (h_rvar Hypothesis)

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Phases 1-5 [COMPLETED] (EANegationClosure.lean sorry-free, ~570 lines)
- **Research Inputs**:
  - specs/305_rabinovich_ea_formula_implementation/reports/06_zone3-gap-placement.md
  - specs/305_rabinovich_ea_formula_implementation/reports/05_vecEA2-level-lemma51.md
  - specs/305_rabinovich_ea_formula_implementation/reports/04_faithful-lemma51-design.md
  - specs/305_rabinovich_ea_formula_implementation/reports/01_ea-formula-research.md
- **Artifacts**: plans/08_strengthen-inputs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan replaces the failed bounded-interval realization approach (Plan v7, Phase 6a) with a less disruptive strategy: strengthening the inputs to `nvar_transfer_from_1var_agree` by adding a depth-(d+1) r-var agreement hypothesis (`h_rvar`). The calling contexts (`prior_nonconstenv_2var_agree_until/since`) already have this agreement available from `ih_strong`, so threading it through is straightforward. The additional hypothesis resolves the gap-placement circularity: from r-var agreement at depth d+1 between the current environments, the quantifier step can extract that any witness satisfying the NF is bounded by adjacent env' components, breaking the circular dependency between the IH and order matching.

### Research Integration

- **Report 06** (06_zone3-gap-placement.md): Root cause analysis confirming the circular dependency between IH application and order matching. The report identified Option 2 (strengthen theorem inputs) as the least disruptive resolution.
- **Prior Plan v7**: Phase 6a BLOCKER documented the exact failure mode -- `cross_extend_bwd_1var` provides order relative to ONE reference point but the IH requires order relative to ALL.

### Prior Plan Reference

Plan v7 (07_zone3-gap-placement-plan.md) attempted a bounded-interval realization helper (`prior_bounded_type_realization`) as Phase 6a but encountered a fundamental circularity. The induction on depth d with universally-quantified arity r means the IH at depth d for arity r+1 requires order matching, but establishing order matching requires the IH itself. This plan abandons the external helper approach and instead strengthens the theorem statement to break the circularity.

## Goals & Non-Goals

**Goals**:
- Modify `nvar_transfer_from_1var_agree` signature to accept `h_rvar : nf_agreement (d+1) r env env'` as an additional hypothesis
- Use `h_rvar` inside the quantifier step to extract witness bounding from the depth-(d+1) quantifier condition
- Fill sorry sites at lines 470/473 in `nvar_transfer_from_1var_agree`
- Update downstream consumers (lines 565/570/621/625) to pass `ih_strong`-derived r-var agreement
- Achieve `lake build` clean on the Kamp module

**Non-Goals**:
- External helper lemmas (`prior_bounded_type_realization`, gap classification) -- abandoned
- Model-independent biconditional for `neg_bracket_is_vbracket` (future work)
- Removing dead-code sorrys in NfCharFormula.lean (deprecated)
- Changes to EANegationClosure.lean (already sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Additional `h_rvar` hypothesis makes theorem harder to apply at call sites | M | L | Call sites (`prior_nonconstenv_2var_agree_until/since`) use `ih_strong` which provides r-var agreement at all lower depths. The weakening to depth d+1 is immediate via `nf_agreement_monotone`. |
| Extracting witness bounds from depth-(d+1) quantifier condition is non-trivial | M | M | The quantifier condition of `h_rvar` at depth d+1 says "for all sub_nf, exists w' in env' with depth-d (r+1)-var agreement at (w', env')". The witness w' from this existential is already bounded by the quantifier structure. If extraction is difficult, use `nf_characteristic` to identify the specific sub_nf that witnesses the desired element. |
| Signature change causes cascading type errors in downstream code | L | M | The change is additive (new parameter). All existing code compiles as-is until we fill the sorrys. The only required updates are at call sites which currently use `sorry` anyway. |
| IH application in the quantifier step still requires order matching for the extended environment | H | L | With `h_rvar` at depth d+1, the quantifier condition provides an existential witness with depth-d (r+1)-var agreement. This witness inherits order matching from the depth-(d+1) r-var quantifier structure -- the quantifier ranges over elements in specific gaps. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 6a | -- (completed phases 1-5 prerequisite) |
| 2 | 6b | 6a |
| 3 | 6c | 6b |
| 4 | 6d | 6c |
| 5 | 7 | 6d |

Phases within the same wave can execute in parallel.

---

### Phase 1: Interval Splitting Infrastructure [COMPLETED]

**Goal**: Define `BracketFormula.splitAt` and prove semantic correctness.
**Completed**: 2026-06-15

---

### Phase 2: Lemma 5.3 -- All-Betas-True Base Case [COMPLETED]

**Goal**: Prove `neg_orderedPointsExist_is_vbracket` sorry-free.
**Completed**: 2026-06-16

---

### Phase 3: Corollary 5.4 -- Partial Bracket Negation [COMPLETED]

**Goal**: Prove `neg_partialBracketExist_sufficient` sorry-free.
**Completed**: 2026-06-17

---

### Phase 4: Boneyard Port -- EANegationClosure.lean [COMPLETED]

**Goal**: Port helper definitions, bracket_tail_satisfiable, neg_interval_formula, neg_bounded_exists from Boneyard. All sorry-free.
**Completed**: 2026-06-18

---

### Phase 5: Proposition 4.2 -- VecEA2 Negation Closure [COMPLETED]

**Goal**: Port neg_vecEA2, neg_2var_vec_ea from Boneyard. All sorry-free.
**Completed**: 2026-06-19

---

### Phase 6a: Strengthen `nvar_transfer_from_1var_agree` Signature [COMPLETED]

**Goal**: Add `h_rvar` parameter to `nvar_transfer_from_1var_agree` encoding depth-(d+1) r-var agreement between the current environments. Update the theorem signature and propagate the type change through existing code without filling sorrys yet.

**Tasks**:
- [ ] Modify the theorem signature in `PriorComposition.lean` (line 381) to add the parameter:
  ```lean
  (h_rvar : ∀ nf : NormalForm sig (d + 1) r,
    nf_eval_nf M (d + 1) r env nf ↔ nf_eval_nf N (d + 1) r env' nf)
  ```
  This goes after `h_order` and before `char_fn`.
- [ ] In the `zero` case (line 402): the new parameter is unused (depth-1 r-var agreement is not needed for purely atomic transfer). Add `_` binding.
- [ ] In the `succ d` case (line 419): bind the parameter as `h_rvar`. The IH `ih` now requires `h_rvar` at one lower depth. Confirm that the IH application (once sorrys are filled) will receive `h_rvar`-derived input.
- [ ] Update all call sites that currently invoke `nvar_transfer_from_1var_agree` (search for the name in the file). Currently the sorrys at lines 565/570/621/625 are in the call sites. Verify they do not currently call `nvar_transfer_from_1var_agree` directly (they use `sorry` as a placeholder for the full proof).
- [ ] Verify the file still compiles (sorrys remain but no new type errors): `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition`

**Timing**: 0.5 hours

**Depends on**: 1-5 (completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- signature change (~5-10 lines modified)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds (sorrys remain, no new type errors)
- `grep -n "nvar_transfer_from_1var_agree" PriorComposition.lean` shows only the definition site

---

### Phase 6b: Order Extraction from h_rvar [COMPLETED]

**Goal**: Prove that from `h_rvar : nf_agreement (d+1) r env env'`, any element x in M satisfying a depth-d 1-var NF can be mapped to a witness x' in N that lies in the SAME gap of env' as x lies in env. The key lemma: the quantifier condition of the depth-(d+1) r-var NF encodes existential transfer with gap-preserving order.

**Tasks**:
- [ ] Within the `succ d` case of `nvar_transfer_from_1var_agree`, extract the quantifier part of `h_rvar`:
  ```lean
  -- h_rvar gives: for all sub_nf at depth d with arity r+1,
  -- (∃ w, nf_eval M d (r+1) (Fin.cons w env) sub_nf) ↔
  -- (∃ w', nf_eval N d (r+1) (Fin.cons w' env') sub_nf)
  obtain ⟨h_rvar_atoms, h_rvar_quant⟩ := h_rvar (nf_characteristic M (d+1) r env)
  ```
  The atom part gives order preservation; the quantifier part gives existential transfer at arity r+1.
- [ ] From the quantifier part of `h_rvar`, given x in M with `nf_eval_nf M d (r+1) (Fin.cons x env) sub_nf`:
  1. Form `nf_characteristic M (d+1) (r+1) (Fin.cons x env)` which is the unique depth-(d+1) (r+1)-var NF satisfied by `(x, env)` in M
  2. The r-var quantifier condition of `h_rvar` applied to the appropriate sub_nf yields existence of w' in N with `nf_eval_nf N d (r+1) (Fin.cons w' env') sub_nf`
  3. The sub_nf encodes both the 1-var type of w' AND its order relative to all env' components (via the AtomKind.order atoms)
  4. Therefore w' lies in the same gap as x: for all i, `env i < x ↔ env' i < w'`
- [ ] Prove the order extraction helper (may be inlined or a separate `have`):
  ```lean
  have h_order_ext : ∀ (i : Fin r), env i < x ↔ env' i < w' := by
    intro i
    -- From sub_nf containing AtomKind.order atoms at position 0 (x/w') vs position (i+1) (env/env')
    -- The atom agreement at arity r+1 between (x,env) and (w',env') gives this directly
    ...
  ```
- [ ] Verify the helper compiles sorry-free (or with minimal sorrys isolated to the main quantifier step)

**Timing**: 1.5 hours

**Depends on**: 6a

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- proof content in `succ d` case (~60-100 lines)

**Key Insight**: The depth-(d+1) r-var NF characteristic of `env` in M includes quantifier conditions that say "for each depth-d (r+1)-var sub_nf, there exists w with env in the right order relative to w AND nf_eval holds". Since `h_rvar` transfers this to N, the witness w' in N automatically inherits the correct order relative to ALL env' components. This breaks the circularity because we are using `h_rvar` (provided externally at depth d+1) rather than trying to derive order matching from the IH at depth d.

**Verification**:
- The order extraction compiles sorry-free
- `lean_goal` at the quantifier step shows the goal reduced to applying the IH with the correct order

---

### Phase 6c: Complete Quantifier Step (Lines 470/473) [COMPLETED]

**Goal**: Fill both sorry sites in `nvar_transfer_from_1var_agree` using the order extraction from Phase 6b combined with the IH at depth d, arity r+1.

**Tasks**:
- [ ] Forward direction (line 470): Given x in M with `nf_eval_nf M d (r+1) (Fin.cons x env) sub_nf`:
  1. Use `h_rvar` quantifier condition to get w' in N with depth-d (r+1)-var NF agreement at `(Fin.cons x env)` / `(Fin.cons w' env')` -- specifically, the sub_nf that characterizes `(x, env)` transfers to `(w', env')`.
  2. From the atom agreement embedded in the transferred sub_nf, extract `h_order_ext : ∀ i, env i < x ↔ env' i < w'`.
  3. Construct 1-var agreements for the extended environment: from `h_1var i` at depth d (weakened from d+1 via the NF structure) plus the order information, get depth-d 1-var agreement for each component of `(Fin.cons x env)` / `(Fin.cons w' env')`.
  4. Apply `ih` (the IH at depth d) with arity r+1, environments `Fin.cons x env` / `Fin.cons w' env'`, using the 1-var agreements and order from steps 2-3.
  5. The IH gives depth-d (r+1)-var agreement, which applied to `sub_nf` gives the existence witness.
- [ ] Backward direction (line 473): Symmetric -- use `h_rvar` in the reverse direction (the iff goes both ways), apply `ih` with the symmetric arguments.
- [ ] Handle the 1-var agreement for the new component (position 0 = x/w'):
  - From the sub_nf atom agreement, we know `nf_eval_nf N d 1 (fun _ => w') nf_1 ↔ nf_eval_nf M d 1 (fun _ => x) nf_1` for all depth-d 1-var NFs. This is the 1-var agreement for position 0.
  - For positions 1..r: use `h_1var i` weakened from depth d+1 to depth d via `nf_agreement_monotone`.
- [ ] Verify both directions compile sorry-free
- [ ] Run `lean_goal` at the quantifier step to confirm goals are closed

**Timing**: 1.5 hours

**Depends on**: 6b

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- fill lines 470/473 (~80-150 lines)

**Type Flow**:
```
h_rvar at depth (d+1), arity r:
  -> quantifier condition: ∀ sub_nf at depth d arity (r+1),
     (∃ x, nf_eval M d (r+1) (Fin.cons x env) sub_nf) ↔
     (∃ w', nf_eval N d (r+1) (Fin.cons w' env') sub_nf)
  -> apply to nf_characteristic of (x, env): get w' with matching NF
  -> atom part of matching NF: order(0, i+1) atoms give env' i < w' iff env i < x
  -> 1-var part: nf_eval N d 1 (fun _ => w') = nf_eval M d 1 (fun _ => x)
  -> h_1var i (weakened to depth d): gives env component 1-var agreement
  -> ih at depth d, arity r+1: gives depth-d (r+1)-var agreement
  -> applied to sub_nf: gives the existential witness
```

**Verification**:
- `nvar_transfer_from_1var_agree` compiles sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds with only lines 565/570/621/625 remaining

---

### Phase 6d: Fill Downstream Consumers (Lines 575/580/631/635) [BLOCKED]

**BLOCKER** (Phase 6d):
- **What failed**: The h_rvar approach cannot resolve the downstream consumers. `nvar_transfer_from_1var_agree` at depth K+1 arity 3 requires h_rvar at depth K+2 arity 3, which is HARDER than the goal (depth K+1 3-var). The depth arithmetic is fundamentally circular: `ih_strong` gives 2-var at depth K+1, whose quantifier condition gives 3-var existential transfer at depth K (not K+1). The gap from depth K to K+1 cannot be bridged without the outer theorem's conclusion.
- **What was tried**: (1) Using `nvar_transfer_from_1var_agree` with h_rvar from ih_strong -- requires depth K+2 (circular). (2) Using `exist_transfer_from_full_agree` from ih_strong -- gives depth K (not K+1). (3) Using `reconstruction_depth_agree` -- only reconstructs UP TO the input depth.
- **Why stuck**: The strong induction on K establishes depth-(K+2) 2-var from depth-(m+2) 2-var (m < K). The quantifier step needs depth-(K+1) 3-var existential transfer over `[x,t]/[x',t']`. This requires zone analysis with Prior-UZ/SZ to find witnesses with BOTH correct 1-var type AND correct zone placement. The zone analysis is the original unsolved problem (Rabinovich zone-3 argument).
- **What is needed**: Implement Prior-UZ/SZ zone-3 witness placement: given w in M between t and x, find w' in N between t' and x' with the same depth-(K+1) 1-var NF type. This requires characteristic formulas + Prior-UZ first/last occurrence axioms to squeeze the witness into the correct zone.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder.

**Goal (original, now blocked)**: Fill sorries at lines 575, 580, 631, 635 in `prior_nonconstenv_2var_agree_until` and `prior_nonconstenv_2var_agree_since` by calling `nvar_transfer_from_1var_agree` with the `h_rvar` parameter derived from `ih_strong`.

**Tasks**:
- [ ] For the Until case (lines 565/570): The goal is to show `nf_eval_nf N (K+1) 3 [w₂, x', t'] sub_nf`. Instead of using `w₂` as a direct witness, call `nvar_transfer_from_1var_agree` at depth K+1, arity 3:
  - `env = [w, x, t]` in M (the three elements from the Until zone)
  - `env' = [w', x', t']` in N (to be determined by the theorem)
  - `h_1var` for each component: from `h_t`, `h_x`, and the cross_extend witness 1-var agreement (`h_1var_w₂`), weakened via `nf_agreement_monotone`
  - `h_order`: order between the three components, derived from `h_order_M`/`h_order_N` and the cross_extend order witnesses
  - `h_rvar`: the **new parameter** -- depth-(K+2) 3-var agreement at `[w, x, t]` / `[w', x', t']`. This comes from `ih_strong` at K' < K giving 2-var agreement, extended to 3-var via the quantifier structure. Alternatively, the `ih_strong` directly provides the full `nf_agreement (K+2) 3` if the environments match.
- [ ] Determine how `ih_strong` provides `h_rvar`: The strong induction IH gives `prior_nonconstenv_2var_agree_until` at all K' < K. At K' = K-1 (depth K+1), this gives 2-var agreement at `[x', t']`. The quantifier condition of this 2-var agreement provides 3-var existential transfer at depth K, which is what `h_rvar` needs at depth K+1 for arity 3. Thread this through.
- [ ] Fill line 565 (Until forward): Apply `nvar_transfer_from_1var_agree` with the threaded `h_rvar`
- [ ] Fill line 570 (Until backward): Symmetric direction
- [ ] Fill line 621 (Since forward): Same pattern with reversed orders
- [ ] Fill line 625 (Since backward): Symmetric
- [ ] Verify all four sorries are eliminated

**Timing**: 1.5 hours

**Depends on**: 6c

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- fill lines 565/570/621/625 (~120-200 lines)

**Depth Arithmetic**:
- Available: `h_x` at depth K+2, `h_t` at depth K+2, `h_1var_w₂` at depth K+1 (from cross_extend)
- Need: `h_rvar` at depth (K+2) for arity 3 (i.e., depth-(K+2) 3-var agreement at the current environments)
- From `ih_strong` at K' < K: gives 2-var agreement at depth K'+2 < K+2
- The 2-var agreement's quantifier condition provides 3-var existential transfer at depth K'+1
- For K' = K-1: gives 2-var at depth K+1, with 3-var existential at depth K
- We need h_rvar at depth K+2 for arity 3. This may require using the direct IH from the surrounding `Nat.strong_induction_on K` applied to a different index, or restructuring to pass the available 2-var IH through the nvar_transfer call differently.
- **Fallback**: If threading `ih_strong` as `h_rvar` requires depth K+2 which is not directly available, use `nf_agreement_monotone` to weaken available agreements, or adjust the nvar_transfer call to use depth K+1 instead.

**Verification**:
- `grep -n sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` returns no results
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds sorry-free

---

### Phase 7: KampBypass Rewire and Integration [NOT STARTED]

**Goal**: Verify that sorry elimination in `PriorComposition.lean` propagates to `KampBypass.lean` and the full Kamp module compiles sorry-free on the critical path.

**Tasks**:
- [ ] Verify `prior_2var_transfer_until` and `prior_2var_transfer_since` in PriorComposition.lean compile sorry-free (these delegate to `prior_nonconstenv_2var_agree_until/since`)
- [ ] In KampBypass.lean, confirm `existPart_succ_n1_bypass` already calls `prior_2var_transfer_until/since` -- if so, no rewiring needed (sorry elimination propagates automatically)
- [ ] If KampBypass.lean has its own sorrys independent of PriorComposition, fill them using the now-available sorry-free theorems
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify `completeness_discrete` sorry-free
- [ ] Run full `lake build` -- verify clean project build
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no axiom leaks
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only non-critical code

**Timing**: 0.5 hours

**Depends on**: 6d

**Files to verify** (no modifications expected if PriorComposition propagation works):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`

**Verification**:
- `lake build` succeeds with no sorry on critical path
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior.completeness_discrete` reports no sorry axiom
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only: NfCharFormula.lean dead-code sorrys, optional EANegation.lean non-critical sorrys

## Testing & Validation

- [ ] Phase 6a: Signature change compiles (file builds with existing sorrys)
- [ ] Phase 6b: Order extraction from `h_rvar` compiles sorry-free
- [ ] Phase 6c: `nvar_transfer_from_1var_agree` compiles sorry-free (lines 470/473 filled)
- [ ] Phase 6d: `prior_nonconstenv_2var_agree_until/since` compile sorry-free (lines 565/570/621/625 filled)
- [ ] Phase 7: `completeness_discrete` compiles sorry-free
- [ ] Phase 7: Full `lake build` succeeds
- [ ] Phase 7: `lean_verify` confirms no axiom leaks
- [ ] Final sorry audit shows only non-critical-path sorrys

## Artifacts & Outputs

- `plans/08_strengthen-inputs-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- sorry-free (Phases 6a-6d)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- already sorry-free (Phases 4-5)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- sorry-free critical path (Phase 7)

## Sorry Elimination Roadmap

| Phase | Sorrys Before | Sorrys After | What Changes |
|-------|--------------|-------------|--------------|
| 1-5 (done) | 6 live (PriorComposition) | 6 live | Infrastructure + EANegationClosure sorry-free |
| 6a | 6 live | 6 live | Signature strengthened (additive, no sorry elimination yet) |
| 6b | 6 live | 6 live | Order extraction helper proved (internal to quantifier step) |
| 6c | 6 live | 4 live | nvar_transfer lines 470/473 filled |
| 6d | 4 live | 0 live | Downstream consumers lines 565/570/621/625 filled |
| 7 | 0 live | 0 live | Integration verified, full pipeline sorry-free |

## Rollback/Contingency

- Phase 6a is a signature-only change. Rollback = revert the signature (or git revert).
- Phases 6b-6c modify the proof body of `nvar_transfer_from_1var_agree`. If they fail, git revert to the sorry state (non-destructive since sorrys are the current state).
- Phase 6d modifies `prior_nonconstenv_2var_agree_until/since`. Same rollback strategy.
- Phase 7 is verification only. If KampBypass needs changes and fails, revert.
- Git per-phase commits enable rollback to any intermediate state.
- **If the h_rvar approach fails** (e.g., threading ih_strong through downstream consumers proves more complex than estimated): fall back to Option 1 (mutual induction on (d, r)) or Option 3 (encode gap constraint into higher-arity quantifier condition). These are more disruptive but mathematically sound alternatives identified in the research report.
