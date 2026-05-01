# Research Report: Task #107

**Task**: Burgess chronicle construction for BX representation theorem
**Date**: 2026-05-01
**Mode**: Team Research (4 teammates)

## Summary

Four teammates investigated the proof architecture for `dd_countermodel_chronicle`, building on the sorry architecture audit (report 50). The team uncovered two fundamental architectural gaps that explain the 50-report churn cycle, resolved a critical conflict about "dead code" status, and produced a streamlined path to sorry closure.

**Key breakthrough**: The "dead code" diagnosis from report 50 is wrong. `lemma_2_6_splitting` and `lemma_2_7` have zero callers because the call sites ARE the sorry sites — they are **unfinished integration**, not dead code. Archiving them would destroy exactly the infrastructure needed to close the remaining sorries.

**Two architectural gaps identified**:
1. The finite-stage g-function is a phantom — never populated during point insertion, so c2' (BurgessR3Maximal for adjacent pairs) cannot hold at finite stages where C4 elimination needs it.
2. The C5 elimination is structurally incomplete — only handles the base case (Burgess 2.10 n=0), producing weak witnesses without guard information, which blocks FUC/FSC.

## Key Findings

### 1. The "Dead Code" Diagnosis Is Wrong (Teammates B, C)

**Confidence: HIGH** (unanimous B+C, partially confirmed by A)

Report 50 concluded that `lemma_2_6_splitting` and `lemma_2_7` have zero callers and should be archived to Boneyard. This is a dangerous misdiagnosis:

- **Burgess Lemma 2.9** (C4 elimination, n=0 case, p. 222) explicitly calls **Lemma 2.6**: "By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6."
- **Burgess Lemma 2.10** (C5 elimination, n>0 case, p. 230-234) explicitly calls **Lemma 2.7 or 2.8** to insert a point between existing points.

The codebase's `eliminate_C4_counterexample` has a `sorry` at line 412 — exactly where Burgess calls Lemma 2.6. The `eliminate_C5_counterexample` completely omits the n>0 case that uses Lemma 2.7.

**However**: The CURRENT implementations use a non-Burgess seed (`{β.neg} ∪ g_content(A) ∪ h_content(C)`) that has an unprovable sorry (density gap). The correct action is to REWRITE `lemma_2_6_splitting` with Burgess's actual D0 seed, not archive it.

**What IS dead code** (safe to delete):
- `g_content_sub_B`, `h_content_sub_B`, `splitting_seed_consistent` — helpers for the non-Burgess seed that will be replaced
- `G_conj_strengthen`, `H_conj_strengthen` — helpers for the above
- The comment block at lines 771-776 documenting prior archival

**What MUST be kept and rewritten**:
- `lemma_2_6_splitting` — needed by C4 elimination (rewrite with Burgess D0 seed)
- `lemma_2_7` and its helpers (`right_mono_until_mcs`, `untl_conj_eta_of_g_content`) — needed for full C5 elimination

### 2. Gap A: The g-Function Phantom (Teammates B, C)

**Confidence: HIGH**

The deepest architectural problem: the g-function at finite stages is never given meaningful values. Every elimination step returns `∀ a b, χ'.g a b = χ.g a b` — g is inherited unchanged. Since the singleton chronicle starts with `g = fun _ _ => ∅`, the g-function is empty throughout the omega chain.

In Burgess's construction, each point insertion EXPLICITLY assigns g-values:
- Lemma 2.4: sets g'(x,y) = B where R(A, B, C)
- Lemma 2.6: sets g'(x,z) = B', g'(z,y) = B'' with B = B' ∩ D ∩ B''
- C3 determines g'(w,z) for non-adjacent pairs

The `limit_g` is defined independently at the limit as `{φ | ∀ y ∈ dom, x < y → y < z → φ ∈ limit_f(y)}`, which is correct and satisfies C3 by construction. But **finite-stage c2' is impossible** with empty g-values — BurgessR3Maximal(A, ∅, C) requires r(A, ∅, C) which is vacuously true, but maximality requires that no proper extension of ∅ satisfies r — which is almost never the case.

**Impact**: The C4 elimination (Lemma 2.9 n=0) requires R(f(w), g(w,w_next), f(w_next)) for adjacent pairs. With g = ∅, this is unavailable. This is why the c2' approach was abandoned.

**Resolution options**:
1. **Extend g during point insertion**: Modify `EliminationResult` to carry new g-values, and update each elimination function to assign B, B' etc. This matches Burgess but is the largest refactor (~200-400 lines across 3 files).
2. **Reconstruct c2' locally**: At the C4 sorry site, construct BurgessR3Maximal from available information without the stored g-value. This requires `g_content(f(w)) ⊆ f(w_next)` which is NOT guaranteed at finite stages.
3. **Inline the Lemma 2.6 argument**: Instead of needing c2' as a precondition, build the full Lemma 2.6 seed consistency proof (Burgess D0) inline at the sorry site, using only f-values and the axiom system. This bypasses g entirely.

**Recommended**: Option 3 (inline D0). The Burgess D0 seed `{S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}` only needs `R(A, B, C)` (which follows from c2'), but we can ALSO derive D from just A and C using the axiom system. The key insight: at the C4 sorry site, we have neg(untl(γ,δ)) ∈ f(w) and can derive the splitting D from f(w) and f(w_next) directly using `burgessR3_gamma_not_in_B` plus Lindenbaum, without needing an explicit g-value.

### 3. Gap B: Incomplete C5 Elimination (Teammates A, B, C)

**Confidence: HIGH**

The current `eliminate_C5_counterexample` only handles Burgess's base case (n=0): it places the witness y BEYOND all domain points using `exists_rat_gt_finset`. This means:
- The C5 witness is always after all existing points
- The guard condition is vacuously true at the finite stage (no intermediate points)
- Later density insertions add intermediate points whose f-values don't carry the guard

Burgess's Lemma 2.10 has an inductive case (n=m+1):
- Let x' be the successor of x in dom(f)
- If η∧U(ξ,η) ∈ f(x') and η ∈ g(x,x'): reduce to n=m (replace x by x')
- If ξ ∈ f(x') and η ∈ g(x,x'): not a counterexample
- Otherwise: apply Lemma 2.7 or 2.8 to insert between x and x'

The codebase skips this entirely, producing `limit_satisfies_c5_weak` which gives endpoints only.

**Impact**: `cantor_bfmcs_restricted_fuc` needs the guard (φ ∈ fam.mcs(r) for intermediate r). Without it, FUC/FSC are blocked.

### 4. FUC/FSC Resolution Path (Teammate A)

**Confidence: MEDIUM**

Teammate A explored 6 approaches (A-F) for FUC/FSC. Key findings:

- The guard condition in FUC maps exactly to `φ ∈ limit_g(x', y)` via the Cantor isomorphism
- `limit_g` satisfies C3 by construction, so if φ ∈ limit_g(x,y), then φ ∈ limit_f(w) for all intermediate w
- The missing piece is proving φ ∈ limit_g(x,y) for the C5 witness y

**Two viable paths**:

**Path 1: Strengthen EliminationResult** — Add guard info to `c5_forward_witness`, modify `eliminate_potential_counterexample` to carry it. Mechanical but touches ~200 lines across multiple functions. The "already a witness" case (CE.lean:763) already has guard info but discards it (the `_` in the destructuring).

**Path 2: Direct limit argument** — Prove `limit_satisfies_c5_full` directly without modifying finite stages. This requires showing that the omega-chain's iterative construction eventually establishes the guard at all intermediate points. Harder to prove but requires no infrastructure changes.

**Teammate A's key observation**: In CE.lean:763, the code destructures `h_actual h_mem h_until` and gets `⟨y, hy_dom, hy_lt, hy_η, _⟩` — that `_` IS the guard info being discarded. Recovering it is a 1-line fix in the "already witnessed" case. The "new insertion" case is harder.

### 5. Independence of C4/C4' and FUC/FSC (Teammate A)

**Confidence: HIGH**

The two blocker groups have NO mutual dependencies:
- C4/C4' requires Lemma 2.6 + c2' (or an alternative construction)
- FUC/FSC requires C5 with guard (or a limit argument)

Neither depends on the other. They CAN be worked in parallel.

### 6. BX Axiom Correspondence (Teammate C)

**Confidence: MEDIUM** — needs explicit verification

Burgess's proofs use A3a, A4a, A5a, A7a. The codebase replaces these with BX axioms:
- A3a → BX13 (enrichment_until) — **needs verification** that BX13 suffices for Lemma 2.6 D0 consistency
- A4a → BX14 — **needs verification** for Lemma 2.6
- A5a → BX5 — confirmed valid
- A7a → removed as unsound; BX7 is replacement — Lemma 2.7 must use BX7, not A7a

Given that A7a was discovered unsound after being assumed valid for months, A3a/A4a soundness under BX semantics deserves explicit verification before implementing the D0 seed proof.

### 7. Sorry Census (Teammate D)

**Confidence: HIGH**

22 total sorry sites in BXCanonical/. Only 4 are on the critical path to `bx_completeness`:

| # | File | Line | Function | Path? |
|---|------|------|----------|-------|
| 4 | CounterexampleElimination.lean | 412 | C4 hard case | Critical |
| 5 | CounterexampleElimination.lean | 510 | C4' hard case | Critical |
| 6 | ChronicleToCountermodel.lean | 615 | FUC | Critical |
| 7 | ChronicleToCountermodel.lean | 619 | FSC | Critical |

The other 18 sorries are off the critical path: 3 are dead code in PointInsertion.lean, 12 are irreflexive-semantics artifacts, and 3 are in the bypassed RootScopedChain.

## Synthesis

### Conflicts Resolved

**Conflict 1: Dead code status of sorries 1-3**
- Report 50 says "archive to Boneyard"
- Teammate D says "delete"
- Teammates B and C say "NOT dead code — unfinished integration"
- **Resolution**: The non-Burgess seed helpers (g_content_sub_B etc.) ARE dead code and should be deleted. But `lemma_2_6_splitting` must be REWRITTEN with Burgess D0 seed and wired into C4 elimination. `lemma_2_7` should be kept for potential C5 n>0 implementation but is lower priority.

**Conflict 2: Feasibility of c2' reconstruction**
- Report 50 suggests using `burgessR3Maximal_from_g_content_sub` at the sorry site
- Teammates B and C show g is empty, so g_content inclusion can't be verified at finite stages
- **Resolution**: c2' from stored g-values is impossible. The correct approach is either (a) extend g during insertion or (b) inline the Burgess D0 argument using only f-values + axiom system, bypassing g entirely.

**Conflict 3: FUC/FSC approach**
- Teammate A: strengthen EliminationResult or direct limit argument
- Teammates B, C: need full Lemma 2.10 (n>0 case)
- Teammate D: use limit_g + C3
- **Resolution**: Two-pronged approach. First try to recover the discarded guard info in the "already witnessed" case (1-line fix at CE.lean:763). For the "insertion needed" case, either strengthen the insertion or prove a direct limit argument.

### Gaps Identified

1. **BX13/BX14 sufficiency for Burgess D0**: Nobody has verified that BX13 provides A3a's role in the D0 consistency proof, or that BX14 provides A4a's role. This must be checked BEFORE implementing the D0 seed.

2. **The C5 "new insertion" case guard**: Even if we fix the "already witnessed" case, the new insertion creates y beyond all domain points with vacuous guard. Later density insertions add intermediate points. The guard at those points is not established by the current architecture.

3. **limit_g and the r-relation**: Nobody has verified that `r(limit_f(x), limit_g(x,y), limit_f(y))` holds for the Burgess r-relation. This is needed for Claim 2.11 but may follow from the definition.

### Recommendations

**Phase 0: Clean non-Burgess cruft** (1 hour)
- Delete: g_content_sub_B, h_content_sub_B, splitting_seed_consistent, G_conj_strengthen, H_conj_strengthen (~150 lines of helper code for the non-Burgess seed)
- Keep: lemma_2_6_splitting (rewrite target), lemma_2_7 (implementation target), their helpers
- Update stale comments in Completeness.lean and ROADMAP.md
- `lake build` + commit

**Phase 1: Verify BX13/BX14 for D0 seed** (0.5 hours)
- Use `lean_hover_info` on BX13 (enrichment_until) and BX14 to check their exact statements
- Confirm they provide A3a and A4a's roles in Burgess's D0 consistency proof
- If insufficient, identify what axiom is actually needed

**Phase 2: Rewrite lemma_2_6_splitting with Burgess D0** (4-5 hours)
- Implement Burgess's actual D0 seed: `{S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}`
- Prove D0 consistency via BX5 + BX14 + BX13 chain (Burgess pp. 370-371)
- This makes lemma_2_6_splitting sorry-free

**Phase 3: Close C4/C4' (sorries 4-5)** (2-3 hours)
- Wire lemma_2_6_splitting into eliminate_C4_counterexample at the sorry site
- For the c2' precondition: construct inline using f-values at the adjacent pair + Burgess D0 argument (bypassing the phantom g)
- Mirror for C4'

**Phase 4: Close FUC/FSC (sorries 6-7)** (3-5 hours)  
- First: recover discarded guard info at CE.lean:763 (the `_` in `⟨y, hy_dom, hy_lt, hy_η, _⟩`)
- Strengthen `EliminationResult.c5_forward_witness` to carry guard
- Prove `limit_satisfies_c5_full` with guard
- Close FUC/FSC using limit_satisfies_c5_full + cantor_iso transfer

**Phase 5: ROADMAP + audit** (0.5 hours)

**Total estimate: 11-15 hours**

Note: Phases 2-3 and Phase 4 are independent and can execute in parallel.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary | completed | medium | FUC/FSC resolution paths, independence of C4 and FUC |
| B | Alternatives | completed | high | "Dead code" refutation, g-function phantom, Burgess D0 seed |
| C | Critic | completed | high | Structural incompleteness of C5, churn pattern analysis |
| D | Horizons | completed | high | Sorry census (22 total, 4 critical), streamlined plan |

## References

- Burgess 1982: `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` — Lemmas 2.4-2.10, Claim 2.11
- Report 50: `specs/107_chain_design_diagnostics_for_representation_theorem/reports/50_sorry-architecture-audit.md`
- Plan v35: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/49_implementation-plan.md`
- CounterexampleElimination.lean:412,510 — C4/C4' sorry sites
- ChronicleToCountermodel.lean:615,619 — FUC/FSC sorry sites
- ChronicleConstruction.lean:837 — limit_g definition
- PointInsertion.lean:908 — lemma_2_6_splitting
- RRelation.lean:836 — burgessR3_gamma_not_in_B
