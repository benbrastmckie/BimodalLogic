# Research Report: Task #155 — Phase 3 Blockers and GHR93-Faithful Path

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Mode**: Team Research (4 teammates, opus)

## Summary

Four parallel research agents investigated the Phase 3 blockers from complementary angles. The research converges on a unified picture: the grid dispatch difficulty is a symptom of a deeper architectural divergence from GHR93, and the correct fix is a GHR93-faithful rewrite of Case II combined with tactic infrastructure improvements. The full general result (arbitrary linear orders, Cases III/IV with real proofs) requires ~15-25 hours of additional work but is well-understood and achievable.

## Key Findings

### 1. Root Cause of Grid Dispatch Failure (Teammate A, HIGH confidence)

The `same_order_type_grid` macro expands to `(intro i j; simp only [game_tuple]; split_ifs)` and is used with `<;>`, making `i` and `j` inaccessible (`i✝`, `j✝`) in broadcast subgoals. The `first` combinator dispatches fixed-element cases but fails on selection-index cases that require `Fin n` values from `i` and `j`.

**Verified fix**: `unhygienic (intro i j; ...)` preserves variable accessibility through `<;>`. Tested with `lean_run_code`. An `order_reverse` helper theorem (deriving `b < a ↔ b' < a'` from `a < b ↔ a' < b'` via trichotomy) closes missed reverse-ordering goals like goal 1 at line 1668.

### 2. Architectural Divergence from GHR93 (Teammates B+C, HIGH confidence)

The current Case II proof constructs e_n via a d-compatible forward game (`h_d_compat_left`, lines 1257-1288), NOT from U(B,A) as GHR93 prescribes. This creates the fundamental problem:

- **GHR93**: e_n is a U(B,A) witness above e_{n-1}, so e_{n-1} < e_n is immediate. All orderings are trivial from monotonicity + Until witness.
- **Formalization**: resp_tau(k) and e_n come from DIFFERENT games. No direct ordering relationship exists, requiring the `resp_mod` indirection (line 1418) and non-trivial `sel_pn_ord` proofs.

The current Case II is ~1170 lines for what GHR93 proves in ~2 pages. A faithful rewrite would produce ~400-600 lines.

### 3. Critical Path Correction (Teammate D, HIGH confidence)

`completeness_discrete` **DOES** have `sorryAx` — confirmed via `#print axioms` in a live build. The `lean_verify` MCP tool gave a false negative. The single root sorry is `succ_cofinal` (ChronicleToCountermodel.lean:1885). The Reynolds pipeline IS needed to eliminate this.

However, CaseAnalysis.lean is NOT currently imported by Transfer.lean. The game pipeline must be wired in (Phase 5.2) after closing all CaseAnalysis sorries.

### 4. CharacteristicFormula Existence Sorries Gate Everything (Teammate C)

`x_t_formula_exists` (line 221) and `x_interval_formula_exists` (line 285) are on the critical path for the GHR93 Case II rewrite. Without them, B and A cannot be constructed for the U(B,A) approach. These require proving finiteness of the rank_type quotient.

### 5. Cases III/IV Require Real Proofs for General Result

Cases III/IV (gap handling) are vacuous on Z, but the user requires the full general result for arbitrary linear orders. This means:
- GapFormulas.lean must be created with left(B,D), right(B,D), and Lemma 9 correctness
- Cases III/IV winning condition assembly (~200-300 lines) must be proved, not sorry'd
- The extra effort is ~150-250 lines and ~5-8 hours beyond the Case II work

## Synthesis

### Conflict Resolution

**Conflict 1: Tactic fix vs architectural rewrite**
- Teammate A recommends `unhygienic intro` + sel case-splits to close existing grid dispatch
- Teammate C recommends GHR93 rewrite first, which may eliminate most grid dispatch goals

**Resolution**: Both are needed. The GHR93 rewrite changes the proof structure (eliminating resp_mod and simplifying orderings), but the rewritten proof will still have a grid dispatch step that needs the tactic improvements. The tactic infrastructure (unhygienic grid, order_reverse) should be built first as general-purpose tools, then the GHR93 rewrite applied, then any remaining grid goals closed with the new tactics.

**Conflict 2: Discrete-only shortcut vs general result**
- Teammate D identified that Cases III/IV are vacuous on Z, saving 5-8 hours

**Resolution**: User directive overrides — full general result required, no sorries acceptable.

### Recommended Attack Order

1. **CharacteristicFormula existence sorries** (3-5 hours) — gates everything
2. **Tactic infrastructure** (2-3 hours) — `order_reverse`, `same_order_type_grid_uh`
3. **GHR93 Case II rewrite** (6-10 hours) — replace forward-game e_n with U(B,A) witness, eliminate resp_mod, simplify Round 2
4. **Cases III/IV with gap formulas** (5-8 hours) — GapFormulas.lean, left/right formula infrastructure, Lemma 9
5. **Transfer.lean rewiring** (3-5 hours) — wire game pipeline, verify sorry-free completeness_discrete
6. **Verification** (1-2 hours) — `#print axioms`, `lake build`, zero sorryAx

Total: ~20-33 hours

### Gaps Identified

1. **Transfer.lean rewiring (Phase 5.2) is underspecified** — needs type-signature compatibility analysis between game pipeline output and what Completeness.lean expects
2. **Monotonicity underexploited** — sorted selections give `a_init(k) ≤ p_n` for all k, but the degenerate case (a_init(k) = p_n) is not handled upfront
3. **lean_verify MCP tool unreliable** — gave false negative for completeness_discrete. Always use `#print axioms` via `lean_run_code`

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Tactic engineering | completed | high | Verified `unhygienic intro` fix, classified all 8 goals |
| B | GHR93 literature | completed | high | Traced divergence: forward-game e_n vs U(B,A) |
| C | Critic/gaps | completed | high | Import chain analysis, architectural simplification case |
| D | Strategic horizons | completed | high | Ground truth: completeness_discrete HAS sorryAx |

## References

- GHR93 pp. 117-119: Claim 1 Cases II-IV
- GHR94 ch. 12, pp. 812-850: Expanded treatment
- Teammate reports: specs/155_reynolds_pipeline_activation/reports/44_teammate-{a,b,c,d}-findings.md
