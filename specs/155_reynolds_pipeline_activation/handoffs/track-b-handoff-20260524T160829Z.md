# Track B Handoff — 2026-05-24T160829Z

## Immediate Next Action

Phase B3 (Formula C resolution, Approach C) — but blocked pending deeper analysis of `c ≤ e_n` in `ghr93_case_II`. Before attacking B3, first investigate whether `c ≤ e_n` can be derived from the forward game's ordering data in `ghr93_case_II`, or whether `obtain_split_point_props` needs to export this bound as part of `SplitPointProps`.

The most tractable next step is: **add `hc_le_en : c ≤ e_n` derivation inside `ghr93_case_II`** by extracting it from `hord_fwd ⟨n+1, _⟩ ⟨n+2, _⟩` combined with the N-side constraint `a_N(n) ≤ d` (which needs to be established from `SplitPointProps` or the tau game).

## Current State

**Phase B1 (COMPLETED before this session)**: All 6 h_fwd_r1 signature locations in `ExpressivenessGeneral.lean` already use `r + 2`. Verified by grep — no `r + 1` occurrences remain in the relevant signatures.

**Phase B2 (COMPLETED this session)**: Atom type determination done.
- `StaviFormula` is a **monomorphic inductive type** (no atom type parameter)
- Atoms are `Formula` (the base bimodal logic formulas) — an **infinite** type
- `Fintype { A : StaviFormula // stavi_depth A ≤ r }` is **NOT constructible** (formula type is infinite)
- `NormalForm (muSig sig) (2*r) 1` IS Fintype and already used in pigeonhole machinery
- **Decision: Approach C (case-split)** — Approach A (direct BoundedStaviFormula enumeration) is blocked by infinite atoms

**Phases B3–B9 (NOT STARTED this session)**: Deep analysis reveals the sorry landscape:

| Sorry | Line | Status | Blocker |
|-------|------|--------|---------|
| S1 | 3901 | Open | Boundary edge case (c_inf = y), needs formula for C at y' boundary |
| S2 | 3935 | Open | Gap r2_resp + formula materialization (Approach C case split) |
| S3 | 4412 | Open | Multi-round cont_transfer adaptation (mechanical, ~90 lines) |
| S4 | 4424 | Open | Multi-round K^-(~D_M) — inherits S1/S2 |
| S5 | 4468 | Open | Multi-round gap case (mechanical mirror of existing proof) |
| S6 | 4483 | Open | Position constraint: rank_down loses a'_rd(0) = d tracking |
| S7 | 4508 | Open | Same as S6 for right boundary |
| S8 | 5945 | Open | Multiple goals in same_order_type_grid; needs `c ≤ e_n` |
| S9 | 6045 | Open | Sigma strategy instantiation for cross-boundary ordering |
| S10 | 6098 | Open | Same as S9 |
| S11 | 7028 | Open | Needs Lemma 9 (gap detection correctness) |
| S12 | 7390 | Open | Needs Lemma 10 (strategy restriction) |
| S13 | 10086 (EFGames) | Open | Keystone: full GHR93 induction |
| S14 | 863 (IntegerModel) | Open | Reynolds Theorem 5 |

## Key Decisions Made

### B2 Decision: Approach C (Case-Split)
`StaviFormula` uses infinite `Formula` atoms. `Fintype (StaviFormula)` is NOT constructible. The code must use `NormalForm (muSig sig)` (which IS Fintype) as the finite characterization vehicle. The case-split approach in reports 38/39 is the correct path.

### S8 Root Cause: c ≤ e_n Missing
The sorry at line 5945 in `ghr93_case_II` has 5-6 sub-goals from `same_order_type_grid`. Most require the bound `c ≤ e_n` (where c is the split point on M-side and e_n is the forward game's response to p_n). The existing pivot arms cover all cases EXCEPT those involving b_resp vs p_n/e_n cross-boundary orderings.

Derivable in principle: `c < e_n ↔ a_N(n) < p_n` from `hord_fwd ⟨n+1, _⟩ ⟨n+2, _⟩`. But `a_N(n) ≤ d` (needed to conclude `a_N(n) ≤ p_n`) is NOT in scope in `ghr93_case_II`. This bound would need to come from `SplitPointProps` or be derived from the tau game.

### S3, S5 Mechanical Closures Are Independent
S3 (line 4412) and S5 (line 4468) are mechanical adaptations of existing proofs (h_cont_transfer and h_r2_resp_ge_d gap case) with multi-round indices. They do NOT require S1/S2 to be closed first and are independently attackable.

## What NOT to Try

1. **Do NOT attempt Approach A** (direct StaviFormula enumeration via Fintype). Atoms are `Formula` (infinite), not `muSig sig`. `Fintype (StaviFormula)` is not constructible.

2. **Do NOT attempt NormalForm → StaviFormula inversion (Approach B)** — circular per Superseded Approaches section of the plan.

3. **Do NOT use `h_d_unique`** — it was removed from the codebase as MATHEMATICALLY FALSE (Superseded Approaches).

4. **Do NOT try to derive `c ≤ e_n` from forward game ordering alone** without knowing where `a_N(n)` sits relative to `d`. The chain `c < e_n ↔ a_N(n) < p_n` requires `a_N(n) ≤ d` which is not available in `ghr93_case_II`.

## Critical Context

### File: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

**Diagnostic state**: No errors. 4 declarations with sorry warnings:
- `obtain_split_point_props` (line 2255) — S1-S7 cluster
- `ghr93_case_II` (line 5675) — S8 (line 5945) and more at S9/S10 (lines 6045, 6098)
- `ghr93_cases_III_IV` (line 7007) — S11 (line 7028)
- `ghr93_forward_to_backward_rank_varying` (line 7266) — S12 (line 7390)

**S8 goal structure at line 5945**: Inside `same_order_type_grid <;> ... first | ... | sorry`. The sorry is the last arm of a `first` tactic. The remaining goals are:
1. `(b_resp < x' ↔ b_sp < x)` — both False; should be caught by existing "b_resp vs x" arm
2. `(b_resp < p_n ↔ b_sp < e_n)` — needs pivot through d/c with `c ≤ e_n`
3. `(y' < a_bwd⟨j-1,...⟩ ↔ y < resp_tau⟨j-1,...⟩)` — both False
4. `(p_n < b_resp ↔ e_n < b_sp)` — needs `c ≤ e_n` to confirm False
5. `(a_bwd⟨i-1,...⟩ < p_n ↔ resp_tau⟨i-1,...⟩ < e_n)` — needs pivot through d/c with `c ≤ e_n`
6. `(p_n < a_bwd⟨j-1,...⟩ ↔ e_n < resp_tau⟨j-1,...⟩)` — needs `d < p_n ↔ c < e_n`

**S3 context at line 4412**: Inside a `by` tactic block with access to the multi-round forward game `h_mr1`. The proof is ~90 lines of index arithmetic identical to `h_cont_transfer` (lines 3240-3330) with game indices `(2+3n, 3+3n, 4+3n)` instead of `(1, 2, 3)`. This IS independently closable.

**S5 context at line 4468**: The gap case for mr_resp. Mirror of existing gap case at lines 3994-4250 with adapted indices. Also independently closable.

### File: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`

S13 at line 10086 (`nf_characterizable_by_stavi`) is the keystone. Requires all S1-S12 closed.

## Recommended Attack Order for Next Session

1. **Close S3 (line 4412)**: Mechanical ~90-line copy of h_cont_transfer with indices (2+3n, 3+3n, 4+3n). No blockers. Highest-confidence win.

2. **Close S5 (line 4468)**: Mechanical ~255-line copy of h_r2_resp_ge_d gap case with adapted indices. No blockers.

3. **Fix S8 via SplitPointProps extension**: Add `hc_le_en : c ≤ e_n` (or a field that enables deriving it) to `SplitPointProps`. This requires knowing `a_N(n) ≤ d`, which could be established in `obtain_split_point_props` using the fact that `d ≤ a_N(n) ≤ y'` is wrong direction... OR restructuring how e_n is constructed in Case II. Alternatively, derive `c ≤ e_n` by using `fwd_x_b` extended: `c ≤ y` (trivially) and `p_n ≤ y'` and checking if `c < e_n ↔ a_N(n) < p_n` with `a_N(n) ≤ p_n` from the Case II constraint.

4. **Once S8 is closed**: S9/S10 (cross-boundary sigma pivoting) become the next targets.

## References

- Plan: `specs/155_reynolds_pipeline_activation/plans/28_reynolds-pipeline-plan.md`
- Forward inventory: `specs/155_reynolds_pipeline_activation/reports/30_forward-inventory.md`  
- Teammate A findings: `specs/155_reynolds_pipeline_activation/reports/28_teammate-a-findings.md`
- Team research synthesis: `specs/155_reynolds_pipeline_activation/reports/28_team-research.md`
- Mechanical strategy: `specs/155_reynolds_pipeline_activation/reports/30_mechanical-strategy.md`
- Main file: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
- EFGames: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`
