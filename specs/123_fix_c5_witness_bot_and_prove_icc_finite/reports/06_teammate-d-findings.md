# Teammate D (Horizons): Strategic Direction and Roadmap Alignment

Task: 123 | Date: 2026-05-11

## Key Findings

### 1. Scope Assessment: IsSuccArchimedean Is the Right Goal

After reviewing the full dependency chain and alternative architectures, proving `IsSuccArchimedean` for `LimitDomSubtype` IS the correct goal. Restructuring to avoid it would be significantly more costly than solving it.

**The dependency chain is tight and well-understood:**

```
limitDomSubtype_isSuccArchimedean (1 sorry, line 1303)
  |
  +-> succ_embed_surjective
       |
       +-> cantor_bfmcs_discrete_restricted_tc
       +-> cantor_bfmcs_discrete_restricted_fuc
            |
            +-> dd_countermodel_chronicle_discrete
                 |
                 +-> bx_completeness (purely discrete branch)
```

Everything downstream of `IsSuccArchimedean` is already sorry-free conditional on this single instance. The succ_embed approach is structurally complete -- 6 of 7 typeclass prerequisites exist, and the BFMCS construction, all three coherence conditions, and the countermodel theorem are all built and compiling. The report `07_collapse-bfmcs-design.md` independently confirmed that a collapse-based redesign would require 400-800 lines of new infrastructure while still needing the same cofinality argument.

**Why restructuring is wrong:**
- The `succ_embed` approach directly evaluates `limit_f` at embedded points -- no quotient, no representative transfer, no well-definedness proofs needed.
- The BUC coherence condition is already sorry-free.
- TC and FUC are structurally complete, depending only on `succ_embed_surjective`.
- Any alternative approach to the Z-isomorphism (e.g., collapse quotient, direct stage-based enumeration) would need to rebuild all three coherence conditions from scratch (~800 lines).

### 2. Alternative Architectures: High Cost, Same Core Difficulty

Three alternative architectures were evaluated:

**Alternative A: Collapse-based Z-isomorphism.** Build `CollapseClass ≃o Z` using the quotient of LimitDomSubtype under succ-reachability. The quotient is IsSuccArchimedean by construction (each class = one succ-orbit), but proving this formally still requires showing the quotient's succ matches `SuccOrder.ofSuccLeIff`. Moreover, the FMCS construction through the quotient introduces representative-choice problems: `limit_f` is NOT constant on equivalence classes (C4/C5 processing changes MCS assignments along the succ-chain), so proving G/H coherence through representatives requires careful direction-aware transfer. **Estimated blast radius: ~800 lines of new code, no sorry savings.**

**Alternative B: Direct stage-based enumeration.** Define `to_int(x)` = position of x in the stage-ordered enumeration of limit_dom. This would avoid IsSuccArchimedean entirely but requires proving the enumeration is order-preserving AND rebuilding the entire BFMCS/coherence pipeline against the new embedding. **Estimated blast radius: ~1000+ lines, complete rebuild of discrete pipeline.**

**Alternative C: Verbrugge-style construction.** Build a Z-isomorphic model directly, following de Jongh/Veltman/Verbrugge 2004. Their method constructs the model step-by-step using adequate sets (finite subformula closures) and cyclic treatment of G-formulas. This is architecturally cleaner than Burgess for the discrete case. However, adopting it would require:
- Replacing the entire Chronicle construction (6 files, ~9500 lines) with a new construction
- Rebuilding the parametric representation pipeline
- Re-proving all soundness-direction results
- **Estimated blast radius: entire Metalogic directory (~15000 lines)**

None of these alternatives avoid the core mathematical difficulty. The gap-at-L scenario (two infinite orbits converging from opposite sides with no domain point at L) is an order-theoretic obstacle that any construction-based Z-isomorphism proof must rule out using construction-specific properties.

### 3. Sorry Inventory and Path to Sorry-Free bx_completeness

The current sorry inventory on the critical path:

| Sorry | Location | Case | Status |
|-------|----------|------|--------|
| `limitDomSubtype_isSuccArchimedean` | ChronicleToCountermodel.lean:1303 | Discrete | Task 123 (in progress) |
| `dd_countermodel_chronicle_nondense_sorry` | ChronicleToCountermodel.lean:839 | Nondense | Task 122 (depends on 123) |
| `dd_countermodel_chronicle_mixed_sorry` | ChronicleToCountermodel.lean:2730 | Mixed | Task 122 |

The path to sorry-free `bx_completeness`:

1. **Close IsSuccArchimedean** (task 123) -- makes discrete pipeline sorry-free
2. **Build nondense/mixed countermodels** (task 122) -- the nondense case constructs a BFMCS on Z (analogous to the discrete case but starting from a non-box-discrete MCS). The mixed case, where some box-accessible worlds are dense and others discrete, is genuinely novel and may require ultraproducts or enriched frames.

After task 122, `bx_completeness` becomes sorry-free. Then Phase 2 (axiom cleanup: tasks 124, 115, 116) and Phase 3 (algebraic representation: task 125) proceed.

### 4. Partial Wins If IsSuccArchimedean Proves Too Hard

If the construction-specific argument for ruling out the gap-at-L scenario cannot be formalized:

**Partial win A: TC without surjectivity (highest value).** Teammate D's earlier finding (round 5 research) showed that TC (temporal coherence) CAN be proved without `succ_embed_surjective` by using `limit_forward_G` and `limit_backward_H` directly on `succ_embed` points. This narrows the sorry dependency: only FUC (forward Until/Since coherence) would need surjectivity. This is implementable independently of the IsSuccArchimedean proof.

**Partial win B: Weaker completeness statement.** Prove completeness restricted to models where the temporal order is already Z-isomorphic (i.e., assume the model comes with a Z-isomorphism). This is vacuously useful for discrete cases but does not help with the mixed case.

**Partial win C: Conditional sorry.** Leave the sorry with a well-documented comment explaining the mathematical gap and the construction-specific argument needed. The sorry is extremely well-localized (single goal: `False` from `forall n, succ^[n](a) < b`) and does not leak into any other module.

### 5. Mixed/Nondense Cases and Cross-Cutting Concerns

The `dd_countermodel_chronicle_nondense_sorry` and `dd_countermodel_chronicle_mixed_sorry` are related but independent of IsSuccArchimedean:

**Nondense case (line 839):** Requires building a discrete BFMCS on Z when `neg(box(F'T)) in A` (i.e., not all box-accessible worlds are dense). The construction is analogous to the discrete case: build chronicle for the MCS A, establish discreteness from `neg(F'T) in some box-accessible world`, then use succ_embed to transport to Z. The key question is whether `U(T,bot)` is in all domain MCS's when `neg(box(F'T)) in A` -- if not, the limit domain may not be uniformly discrete.

**Mixed case (line 2730):** The genuinely hard case. When neither `box(F'T)` nor `box(U(T,bot))` is in A, some box-accessible worlds are dense and others discrete. Different families in the BFMCS need different domain types (Q for dense, Z for discrete). The current architecture cannot handle this because `BFMCS D` requires a single domain type D.

**Would a different approach to discrete help with mixed?** Partially. If the discrete construction is simplified (e.g., avoiding the IsSuccArchimedean proof by using a direct Z-construction), the nondense case benefits directly. The mixed case, however, requires a fundamentally different strategy regardless of how the discrete case is proved. Possible approaches from the literature:

- **Doets 1987**: Uses "reduct" models that project mixed structures onto uniform ones. Could be adapted for the mixed case.
- **Reynolds 1994**: Axiomatizes U and S over Z specifically, using adequate sets (finite subformula closures). The adequate set method naturally handles the Z case without needing IsSuccArchimedean. However, Reynolds works with weak completeness (single formula) while the current approach proves strong completeness.
- **Venema 1993 (Derivation Rules as Anti-Axioms)**: Uses ultraproduct/Boolean algebra techniques that can handle mixed frame classes. The planned Phase 3 (task 125, Jonsson-Tarski representation) builds on Venema's methods.

### 6. Literature-Informed Assessment

The literature broadly confirms that the current Burgess-based approach is sound:

**Burgess 1982**: The canonical reference for chronicle constructions. The codebase's construction is a faithful formalization of Burgess's method, with the C4/C5 argument swap corrected (task 107 finding). The difficulty with IsSuccArchimedean is NOT present in Burgess because he works over all linear orderings (general completeness), not specifically over Z. The Z-specific completeness is the added challenge.

**Verbrugge 2004 (de Jongh/Veltman/Verbrugge)**: Their step-by-step method for Z (Theorem 6) constructs the model directly as a Z-structure using adequate sets. The construction is notably simpler than Burgess for the specific Z case:
- Build a finite "middle stretch" by treating all G-formulas
- Extend both ends cyclically (the "maximal" and "minimal" endpoints repeat the same G-formula pattern)
- The Z-isomorphism is built into the construction (no separate proof needed)

This approach avoids IsSuccArchimedean entirely because the Z structure is explicit. However, it requires abandoning the chronicle construction and rebuilding the completeness pipeline from scratch. This is a Phase 3+ consideration, not a near-term fix.

**Reynolds 1994**: Uses a two-phase approach: first build a Q-model (using Burgess), then "Dedekind-complete" it to obtain a Z-model. The Dedekind completion identifies equivalence classes of "definably equivalent" points, producing a discrete structure. This is conceptually similar to the collapse approach but operates at the formula level rather than the order level.

## Strategic Recommendations

### Near-Term (Task 123)

1. **Continue with the construction-specific approach in plan v5.** The three ordered approaches (A: L-in-domain, B: Icc finiteness, C: WellFoundedGT) are well-prioritized. The mathematical gap is real but the construction should provide the properties needed to rule out the gap-at-L scenario.

2. **Prioritize Approach A (L-in-domain) with the omega-chain stage argument.** The key insight: each limit_dom point enters at a finite stage K. If the gap-at-L scenario occurs, then infinitely many stages insert points on both sides of L, but no stage inserts a point at L. The omega-chain construction processes counterexamples in a fixed enumeration. Between any two succ-orbit elements `succ^[n](a)` and `succ^[n+1](a)`, there are no domain points (bot-gap property). The C5 elimination for `U(T,bot)` at `succ^[n](a)` produces `succ^[n+1](a)` as the immediate successor. If the orbit "converges" to L without reaching b, then for large n, `succ^[n](a)` is close to L from below. The pred-chain `pred^[k](b)` is close to L from above. Between any orbit element and any pred-chain element, there are domain points (contradicting the bot-gap property only if we can find a pair that are adjacent in the limit domain). This is where the argument must leverage the construction: the bot-gap property ensures adjacency, so no accumulation can occur.

3. **If Approach A fails after 2 hours, pivot to Approach B (Icc finiteness).** The stage-counting argument is more mechanical and may be easier to formalize.

### Medium-Term (Tasks 122, 124-125)

4. **Task 122 (nondense + mixed cases) is the real bottleneck.** The discrete case, once IsSuccArchimedean is proved, becomes sorry-free. The mixed case requires genuinely new mathematics. Consider whether:
   - The uniformity axioms (discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd) can be strengthened to force `box(U(T,bot))` whenever `U(T,bot)` is present
   - A "product frame" approach can handle mixed worlds (discrete Z for some families, dense Q for others)
   - The mixed case can be reduced to the nondense case by showing `neg(box(F'T))` implies `box(U(T,bot))` via the uniformity axioms

5. **Phase 2 axiom cleanup (tasks 124, 115, 116) should proceed in parallel** with the mixed case investigation. They touch overlapping files but are mathematically independent.

### Long-Term (Post-Completion)

6. **Consider the Verbrugge approach for future discrete extensions.** If the project expands to other discrete structures (Z x Z, Z * n), the adequate-set method from Verbrugge 2004 provides cleaner completeness proofs that avoid the entire IsSuccArchimedean difficulty. This could replace the Burgess-based discrete pipeline in a future refactoring.

7. **The Phase 3 algebraic representation (task 125) can address the mixed case systematically.** Venema's Boolean algebra with operators approach (using ultraproduct closure from orthodox axiomatizability) naturally handles mixed frame classes. The literature files `Venema_1993_Derivation_Rules_Anti_Axioms.md` and `Goldblatt_Hodkinson_Venema_2003_BAOs_Modal_Logic.md` are relevant.

## Roadmap Alignment

| Roadmap Goal | Current Status | Impact of Task 123 |
|-------------|---------------|-------------------|
| Sorry-free discrete completeness | 1 sorry (IsSuccArchimedean) | Closes it |
| Sorry-free bx_completeness | 3 sorries (discrete + nondense + mixed) | Closes 1 of 3, unblocks task 122 |
| Phase 2 axiom cleanup | All [PLANNED/RESEARCHED], waiting on Phase 1 | No direct impact, but psychologically unblocks |
| Phase 3 algebraic representation | [NOT STARTED] | No direct impact |
| Publication quality | Blocked by sorries | Advances significantly |

Task 123 is correctly positioned as the highest-priority work item. Its completion:
- Makes the discrete pipeline sorry-free
- Unblocks task 122 (the last sorry-bearing task on the critical path)
- Reduces `publication_path_sorries` from 1 to 1 (the nondense/mixed case, which is genuinely different)
- Maintains the current architecture, which is well-understood and has 9500+ lines of sorry-free infrastructure

## Confidence Level

- **IsSuccArchimedean is provable**: HIGH (85%). The bot-gap property in the limit domain means the succ-orbit cannot accumulate -- every orbit element has an immediate successor with nothing between. The mathematical argument is sound; the formalization challenge is connecting the abstract order-theoretic convergence to the construction-specific omega-chain properties.
- **Correct approach identified**: HIGH (90%). Plan v5 with the three ordered approaches is well-structured. Approach A is most likely to succeed.
- **Task 123 is the right priority**: VERY HIGH (95%). No alternative architecture avoids the core difficulty while preserving the existing 9500+ lines of sorry-free infrastructure.
- **Mixed case (task 122) is genuinely hard**: HIGH (80%). This is a different kind of problem requiring new mathematical ideas, not just formalization engineering.
- **Full sorry-free bx_completeness within reach**: MEDIUM (60%). Depends on whether the mixed case can be solved. The uniformity axioms may force the mixed case to be vacuous (i.e., `neg(box(F'T))` might imply `box(U(T,bot))`), which would eliminate it entirely.
