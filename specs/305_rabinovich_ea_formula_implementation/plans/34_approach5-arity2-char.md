# Implementation Plan: Task #305 (v34, HARD MODE)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (resumes from build-passing v33 state)
- **Research Inputs**: reports/18_circularity-resolution-n1.md (primary), reports/19_critical-path-research.md (supporting)
- **Artifacts**: plans/34_approach5-arity2-char.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, lean4.md, literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false
- **Mode**: HARD (H3 reference grounding, H8 phase sizing, H9 wrap-up discipline)

## Overview

This plan eliminates the **two remaining `sorry`** in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (lines 406 and 409), the sole blockers for a sorry-free `kamp_prior_expressive_completeness`. The plan commits to **Approach 5** from report 18: rather than building the arity-2 NF characteristic via an NF-disjunction at depth k+2 (which creates a genuine fixed-point/2-cycle that no well-founded measure can rank — see report 18 §3/§6), we build a new arity-2 characteristic formula `nf_succ_char_formula2` whose quantifier layer is fed by the **depth-k arity-3 induction hypothesis** that is already structurally in scope on the `k+1` arm of `nf_nvar_exist_all_depths`. The outer `∃ x` is then bound using the existing sorry-free `translateEF1` / `nf_2var_exist_depth0_tl` binding pattern. Every dependency lives at depth ≤ k; there is no reference to depth k+2 anywhere, so the recursion measure is depth `k` alone and the cycle disappears.

### Research Integration

- **Report 18 (primary, HIGH confidence)** establishes that the circularity is an artifact of the k+2 strategy, not a mathematical obstruction. It REFUTES the mutual-definition Approach 2 (non-decreasing measure on a constant-index char↔exist 2-cycle, report 18 §3 termination table) and recommends Approach 5 directly. Its §8 gives concrete implementation steps; its §5 gives the 5-column lemma-mapping table reproduced below; its §6 Challenge 2 isolates the single principal risk (the Fin 2 telescoping bridge).
- **Report 19 (supporting)** independently derives the arity-tower resolution ("strong induction on depth with depth-0 all-arity as base case", §6.3) and confirms (§7) that the NF construction needs NO V-EA negation — temporal `Formula.neg` suffices, which is exactly why `nf_succ_char_formula`-style construction is correct.

### Prior Plan Reference

Plan v33 (`plans/33_nf-strong-induction.md`) is partially implemented: **Phases 1-2 complete, Phase 3 partial.** It established the `nf_nvar_exist_all_depths` skeleton (KampPrior.lean:252) with the `| 0` arm and the `n=0` sub-case of the `| k+1` arm both proved sorry-free, plus the `char_k1` / `exist_tl_fn_k` infrastructure (lines 333-361). Its handoff framed the n=1 case as a fixed-point circularity and proposed mutual definition — which report 18 has now refuted. Effort calibration from v33: the `n=0` arm and `char_k1` wiring took roughly the volume report 18 predicts for the new pieces. This plan does NOT re-plan any completed v33 work; it starts from the current build-passing state with exactly 2 sorry.

### Roadmap Alignment

No ROADMAP.md found at `specs/ROADMAP.md` was supplied to this planning run, and `roadmap_flag` was not set. No roadmap phases are included.

## Preserved Assets (DO NOT RE-PLAN)

The following are DONE, sorry-free, and build-passing as of the current HEAD. They are inputs to this plan and MUST NOT be re-implemented, refactored, or destabilized:

| Asset | Location | Role in this plan |
|-------|----------|-------------------|
| `nf_depth0_char_formula` (+ `_correct`, `_correct_arity1`) | Separation / KampPrior.lean:208 | Atom layer for arity-1 and the depth-0 portion of arity-2 char |
| `nf_succ_char_formula` (+ `_correct`) | KampPrior.lean:107 / 121 | Arity-1 template to generalize; reused verbatim by `char_k1` |
| `nf_quant_clause_tl` (+ `_correct`) | KampPrior.lean (above 107) | Quantifier-clause builder reused by `nf_succ_char_formula2` |
| `nf_2var_exist_depth0_tl` / `_fn` (+ `_correct`) | NfToVecEA / KampPrior.lean:181 | The outer-`∃ x` binding pattern (primary binder for Phase 2) |
| `nf_nvar_exist_depth0_tl` / `_fn` (+ `_correct`) | NfDepth0Generalized.lean:1267 | Depth-0 all-arity base case (the `\| 0` arm of `nf_nvar_exist_all_depths`) |
| `nf_nvar_exist_all_depths` `\| 0` arm | KampPrior.lean:264-267 | Base case, DONE |
| `nf_nvar_exist_all_depths` `\| k+1`, `n=0` sub-case | KampPrior.lean:375-386 | DONE; uses `char_k1` |
| `char_k1` / `exist_tl_fn_k` (+ correctness) | KampPrior.lean:333-361 | In-scope at `k+1` arm; reused as-is |
| Fin 1 telescoping bridge (`h_env_eq`) | KampPrior.lean:317-331 (also 497-513) | Template to generalize to Fin 2 |
| `translateEF1` (+ `_correct`), `buildRight`/`buildLeft` (+ `_correct`) | Translation.lean:243/199 | Prop 3.5 interval→Until/Since; backbone of the x-binder |
| `VecEA_m.existClosure` (+ `_correct`, `_correct_rev`) | VecEA_m.lean:208/251/314 | FALLBACK x-binder if the `translateEF1` pattern stalls |
| `insertEnv` (+ `_zero`, `_last`, `_init`) | NfDepth0Generalized.lean:42-56 | Environment-splicing identities for the bridge |

**Scope boundary**: this plan touches ONLY the `| 1` arm (line 406) and the `| n+2` arm (line 409) of `nf_nvar_exist_all_depths`, plus one new helper definition `nf_succ_char_formula2` (with its correctness lemma) and one generalized bridge lemma. Nothing above line 333 or below line 410 in the existing structure is modified except to insert the new helper before the def and to replace the two `sorry` tokens.

## Goals & Non-Goals

**Goals**:
- Replace `sorry` at KampPrior.lean:406 (n=1, critical path) with a real proof via Approach 5.
- Replace `sorry` at KampPrior.lean:409 (n≥2, off critical path) so the file is fully sorry-free.
- Add `nf_succ_char_formula2` (arity-2 characteristic) + correctness as the single genuinely new artifact.
- Achieve: `lake build` passes, zero `sorry` in KampPrior.lean, `lean_verify kamp_prior_expressive_completeness` shows no new axioms.

**Non-Goals**:
- No mutual `char`/`exist` definition (Approach 2 — refuted, report 18 §3).
- No NF-disjunction at depth k+2 (recreates the cycle, report 18 §2.1).
- No BracketFormula convention refactor (Approach B, report 19 §5 — too risky).
- No V-EA negation biconditional work (not needed; temporal `Formula.neg` suffices, report 19 §7).
- No changes to any Preserved Asset listed above.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fin 2 telescoping bridge (outer ∃x ∘ inner ∃y ↔ IH's ∃env:Fin 2) is fiddly | H | H | This is THE principal risk (report 18 §6 Challenge 2). Generalize the proven Fin 1 bridge at lines 317-331 step-by-step; use `lean_goal` after each rewrite; isolate in its own lemma (Phase 1) so it is verified before wiring. |
| `(x,t)` order-zone split inside `char2` must be written explicitly (not delegated) | M | M | Report 18 §6 Challenge 5 flags this as the "up to 500 lines" case. Mitigate by delegating the inner ∃y zone split wholesale to the IH `nf_nvar_exist_all_depths k 2` (report 18 §4.2) rather than re-deriving zones by hand. |
| `translateEF1` x-binder does not compose cleanly with `char2` | M | L | Fallback to `VecEA_m.existClosure` (both directions sorry-free, VecEA_m.lean:251/314), report 18 §6 Challenge 4. Decide binder vehicle in Phase 1 via `lean_multi_attempt` before committing. |
| New helper breaks elaboration / termination of `nf_nvar_exist_all_depths` | H | L | Helper is a standalone `noncomputable def` placed BEFORE the recursive def; it takes `exist_tl_fn3` as a parameter so it introduces no new recursion. Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` after each phase. |
| n≥2 arm harder than expected | L | M | Off critical path; can be marked [PARTIAL] without blocking the main result. Phase 4 is intentionally last and small. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are strictly sequential (each consumes the artifact of the prior); no parallelism. Each phase is bounded to one agent run (~100-300 lines output, H8).

---

### Phase 1: Add `nf_succ_char_formula2` + Fin 2 bridge lemma [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: The arity-2 characteristic-plus-binder cannot be realized as a standalone
  `nf_succ_char_formula2 : ... → Formula` characterizing the pair (x,t), because a `Formula`
  evaluates at a single point. The x-binder must be intrinsic to the construction (the report's
  own framing in §4.1: correctness is stated AFTER binding x). So Phase 1 and Phase 2 are not
  separable; the real artifact is the full n=1 arm.
- **What was tried**: Read the depth-0 binder `nf_2var_exist_depth0_tl` (NfToVecEA.lean:702) and
  its VecEA2 zone machinery (`nf_vecEA2_future/past`, `VecEA2` with `TemporalPred` endpoints);
  read the depth-0 merge machinery `mergeNF`/`merge_forward` (NfDepth0Generalized.lean:157/168);
  read `nf_nvar_exist_depth0_tl` (the all-arity depth-0 converter). Mapped the n=1 goal's three
  order zones (x<t, x>t, x=t) onto the depth-0 template.
- **Why stuck (NEW finding, refines report 18 Challenge 2)**: report 18 claimed the ONLY risk is
  the "Fin 2 telescoping bridge". The actual blocker is deeper and twofold:
  1. **Joint x–t coupling in the quant layer**: at depth k+1, `nf_eval_nf M (k+1) 2 (x,t) sub_nf`
     has a quantifier clause `∃ y, nf_eval_nf M k 3 (y,x,t) qnf ↔ sub_nf.2 qnf` that couples the
     bound x with the free t. The depth-0 binder gets away with INDEPENDENT x-projection and
     t-projection (`nf_x_proj'`, `nf_t_proj`) precisely because depth-0 NFs have NO quant layer.
     At depth k+1 the endpoint predicates are NOT independent, so the depth-0 VecEA2 template does
     not transfer directly.
  2. **Depth-0-only support machinery**: both the zone-split (`nf_vecEA2_future/past`, VecEA2
     reconstruction) and the merge/collapse machinery (`mergeNF`, `merge_forward`) are written for
     `NormalForm sig 0 _` only. The x=t zone needs collapsing the arity-3 quant NF (y,x,t) to
     (y,t,t) — a merge that exists only at depth 0. The x≷t zones need interval-bracket endpoint
     predicates that are depth-k characterizations, not atom predicates.
- **What is needed**: A depth-(k+1) generalization of the arity-2 existential binder. Concretely
  (recommended for next dispatch, in order):
  (a) Generalize `mergeNF`/`merge_forward` from `NormalForm sig 0 (m+1)` to `NormalForm sig k (m+1)`
      (the x=t zone collapse), proving the merge respects the depth-k quant layer.
  (b) Generalize the VecEA2 zone construction so endpoint `TemporalPred`s can be the depth-(k+1)
      arity-1 characterisation `char_k1` (already sorry-free, in scope at the k+1 arm) PLUS the
      per-clause quant formulas from the arity-3 IH `nf_nvar_exist_all_depths atomMap h_surj k 2`.
  (c) Assemble the three zones with `translateLeft`/`translateRight`/equality, mirroring
      `nf_2var_exist_depth0_tl`'s four-way match, but with depth-(k+1) endpoints.
- **Prohibited**: Do NOT use sorry as a "leaf placeholder" for (a)/(b); they must be real lemmas.
  Do NOT pivot to the k+2 NF-disjunction or mutual def (refuted, report 18 §3/§6).

**Goal**: Build the single new artifact — the arity-2 analogue of `nf_succ_char_formula` — and the generalized telescoping bridge lemma, both verified in isolation before any wiring into the recursive def.

**Tasks**:
- [ ] Add `noncomputable def nf_succ_char_formula2` before `nf_nvar_exist_all_depths` (line ~250). Signature: takes `atomMap`, `h_surj`, `{k}`, `exist_tl_fn3 : NormalForm sig k 3 → Formula`, `nf : NormalForm sig (k+1) 2`; returns `Formula`. Mirror lines 107-118: atom layer via `nfPredAtPos` + order literal between positions 0 and 1; quant layer via `nf_quant_clause_tl ∘ exist_tl_fn3` mapped over `Finset.univ : NormalForm sig k 3`.
- [ ] Add `theorem nf_succ_char_formula2_correct`: given `exist_tl_fn3` correct (characterizes `∃ y, nf_eval_nf M k 3 (Fin.cons y env2) qnf` for the pair env2=(x,t)), conclude `temporal_truth M atomMap t (nf_succ_char_formula2 …) ↔ nf_eval_nf M (k+1) 2 (x,t) nf` — mirror lines 121-177, doubling the atom-order cases for the two positions.
- [ ] Add `theorem insertEnv_fin2_bridge` (or inline `have`): `insertEnv env t = Fin.cons (env 0) (Fin.cons (env 1) (fun _ => t))` for `env : Fin 2`, generalizing lines 317-331. Prove with `funext ⟨i,hi⟩` + `interval_cases i` / `omega`.
- [ ] Decide the x-binder vehicle (`translateEF1` pattern vs `VecEA_m.existClosure`) via `lean_multi_attempt`; record the choice in the Phase 2 entry.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` - insert new def + 2 lemmas before line 252.

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds with the new declarations sorry-free (the two arm `sorry`s still present — sorry count stays 2).
- `lean_goal` confirms `nf_succ_char_formula2_correct` closes.

---

### Phase 2: Wire the n=1 arm (critical path) [NOT STARTED]

**Goal**: Replace the `sorry` at line 406 using Phase 1's artifacts, feeding the depth-k arity-3 IH and binding x.

**Tasks**:
- [ ] In the `| 1` arm, set `exist_tl_fn3 := nf_nvar_exist_all_depths_fn atomMap h_surj k 2` (the IH at depth k, arity 3, binds y and x) with correctness from `nf_nvar_exist_all_depths_fn_correct`.
- [ ] Build `char2 := nf_succ_char_formula2 atomMap h_surj exist_tl_fn3 sub_nf`; its correctness for the pair (x,t) from `nf_succ_char_formula2_correct`.
- [ ] Bind the outer `∃ x` via the vehicle chosen in Phase 1 (primary: `nf_2var_exist_depth0_tl`-style `translateEF1` future/past chains; fallback: `VecEA_m.existClosure`). Provide the witness `A` and its biconditional.
- [ ] Discharge the telescoping obligation: outer `∃ x` ∘ inner `∃ y` (inside `char2`/IH) matches the IH's `∃ env : Fin 2`, using `insertEnv_fin2_bridge` (Phase 1) and `Fin.cons`.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` - replace `sorry` at line 406.

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds; `sorry` count drops from 2 to 1 (only the n≥2 arm at line 409 remains).
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_prior_expressive_completeness` no longer reports `sorryAx` in its dependency chain (n≥2 is off-path).

---

### Phase 3: Verify critical path is sorry-free end-to-end [NOT STARTED]

**Goal**: Confirm the main theorem `kamp_prior_expressive_completeness` is sorry-free and axiom-clean with only the off-path n≥2 sorry remaining.

**Tasks**:
- [ ] Run full `lake build` (not just scoped) to confirm no downstream breakage from the new declarations.
- [ ] `lean_verify` the main theorem and assert no `sorryAx` / no new axioms beyond the standard `propext`, `Classical.choice`, `Quot.sound`.
- [ ] Confirm `grep -n sorry KampPrior.lean` shows exactly one code `sorry` (line ~409, n≥2).

**Timing**: 0.5 hours

**Depends on**: 2

**Files to modify**:
- None (verification only).

**Verification**:
- Full `lake build` passes.
- `lean_verify` clean for `kamp_prior_expressive_completeness`.

---

### Phase 4: Eliminate the off-path n≥2 sorry [NOT STARTED]

**Goal**: Make KampPrior.lean fully sorry-free by discharging the `| n+2` arm (line 409).

**Tasks**:
- [ ] Generalize `nf_succ_char_formula2` to `nf_succ_char_formula_n` (arity n+1), OR apply the arity-merge approach (`mergeNF` / `merge_forward`) over the n=1 result, per report 18 §8 step 5.
- [ ] Wire the `| n+2` arm: `exist_tl_fn := nf_nvar_exist_all_depths_fn atomMap h_surj k (n+1)` (IH at depth k, arity n+2), bind the n+1 outer variables.
- [ ] Replace `sorry` at line 409.

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` - replace `sorry` at line 409.

**Verification**:
- `lake build` passes; `grep -n sorry KampPrior.lean` shows zero code `sorry`.
- If this arm proves substantially harder than the n=1 case, mark Phase 4 [PARTIAL] — the critical path (Phases 1-3) already delivers a sorry-free main theorem.

---

## H3 Reference Grounding: Lemma Mapping Table

Each construction step is tied to its Rabinovich source and the Lean lemma realizing it (from report 18 §5, verified present and sorry-free unless noted).

| Claim (this plan's step) | Rabinovich source | Lean lemma | Status | Risk |
|--------------------------|-------------------|------------|--------|------|
| Exists-forall normal form type | Def 3.1 (§3) | `NormalForm sig k n` (NormalForm.lean:134) | exists, sorry-free | LOW |
| NF satisfaction semantics | Def 3.1 semantics | `nf_eval_nf` (NormalForm.lean:198) | exists, sorry-free | LOW |
| Char formula, arity-1 NF at depth k+1 (template) | construction layer | `nf_succ_char_formula` / `_correct` (KampPrior.lean:107/121) | exists, sorry-free | LOW |
| **Char formula, arity-2 NF at depth k+1 (NEW)** | construction layer | `nf_succ_char_formula2` (Phase 1) | **MISSING — primary new artifact** | M |
| Depth-k arity-3 existential (inner ∃y, fed to char2) | Prop 4.3/4.4 analog | `nf_nvar_exist_all_depths` IH at `(k,2)` (KampPrior.lean:252) | in-scope IH (depth k) | LOW |
| Depth-0 all-arity base case | infrastructure | `nf_nvar_exist_depth0_tl` / `_fn_correct` (NfDepth0Generalized.lean:1267) | exists, sorry-free | LOW |
| Prop 3.5: V-EA(1 free var) ⇒ TL(U,S) (outer ∃x binder) | Prop 3.5 (§3, l.87-94) | `translateEF1` / `_correct` (Translation.lean:243) | exists, sorry-free | M |
| Interval ⇒ nested Until/Since | Prop 3.5 chains | `buildRight`/`buildLeft` (+ `_correct`) (Translation.lean:199) | exists, sorry-free | LOW |
| Lemma 3.4: ∃-closure of V-EA (fallback x-binder) | Lemma 3.4 (§3, l.85) | `VecEA_m.existClosure` (+ `_correct`, `_correct_rev`) (VecEA_m.lean:208/251/314) | exists, sorry-free | M |
| insertEnv / Fin.cons telescoping bridge | encoding | `insertEnv` (+ `_zero/_last/_init`) (NfDepth0Generalized.lean:42-56); new `insertEnv_fin2_bridge` (Phase 1) | exists; bridge NEW | **H (principal)** |
| Temporal negation of quantifier clause (no V-EA negation needed) | n/a (report 19 §7) | `Formula.neg` + `nf_quant_clause_tl_correct` | exists, sorry-free | LOW |
| Main result: FOMLO(1 var) ⇒ TL(U,S) | Thm 4.4 (§4, l.112) | `kamp_prior_expressive_completeness` (KampPrior.lean:535) | depends on sorry #1 only | — |

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` passes after each of Phases 1, 2, 4.
- [ ] Full `lake build` passes (Phase 3).
- [ ] `grep -n "sorry" KampPrior.lean` returns zero code `sorry` after Phase 4 (one after Phase 2).
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_prior_expressive_completeness` reports no `sorryAx` and no new axioms (only `propext`, `Classical.choice`, `Quot.sound`).
- [ ] No Preserved Asset declaration changed (diff review confined to lines 252-410 plus the inserted helper block).

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`:
  - New: `nf_succ_char_formula2` + `nf_succ_char_formula2_correct` + `insertEnv_fin2_bridge`.
  - n=1 arm (line 406) proof.
  - n≥2 arm (line 409) proof (or [PARTIAL] marker if off-path arm stalls).
- Sorry-free `kamp_prior_expressive_completeness`.
- Execution summary at `summaries/MM_*-summary.md` (on /implement).

## Rollback/Contingency

- All work is additive within one file; revert via `git checkout Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` to restore the current build-passing 2-sorry state.
- If the Fin 2 bridge (Phase 1/2) stalls: fall back from the `translateEF1` x-binder to `VecEA_m.existClosure` (report 18 §6 Challenge 4). If both stall, mark Phase 2 [PARTIAL], commit the verified Phase 1 helper, and re-dispatch with the bridge isolated.
- If Phase 4 (n≥2) proves intractable: leave the single off-path `sorry` at line 409, mark Phase 4 [PARTIAL]. The critical path (sorry-free main theorem) is already delivered by Phases 1-3 — this is an acceptable terminal state for the task's primary goal.
- Do NOT pivot to Approach 2 (mutual def) or the k+2 NF-disjunction under any failure: both are refuted (report 18 §3, §6).
