# Teammate D (Horizons) Findings: Task #123 — Strategic Direction

**Focus**: Long-term alignment, strategic positioning, and publication readiness
**Date**: 2026-05-11

## Key Findings

1. **The completeness proof's three-case architecture (dense/discrete/mixed) determines which approach has lasting value.** Dense completeness is internally sorry-free. Discrete completeness is blocked on `succ_embed_surjective`. Mixed completeness is a sorry stub requiring task 117's architectural changes. The two sorry sites at lines 2053 and 2056 in `ChronicleToCountermodel.lean` are the sole blockers for the discrete case.

2. **The mixed case is architecturally distinct from the surjectivity question.** Regardless of how the discrete case is resolved, the mixed case requires building a countermodel where some box-accessible worlds see discrete time and others see dense time. This needs a domain type that simultaneously supports `U(T,bot)` truth (discrete) and `F'T` truth (dense) across different families. Neither Z nor Q works alone (report 01 from task 122, Section 4). The choice between Option A (direct surjectivity proof) and Option B (Icc finiteness) has no bearing on the mixed case.

3. **The downstream task chain is strictly sequential.** Task 123 (surjectivity) unblocks task 122 (wire BFMCS on Z, close `dd_countermodel_chronicle_nondense_sorry`), which unblocks Phase 2 axiom cleanup (tasks 124, 115, 116), which unblocks Phase 3 algebraic representation (task 125, Jonsson-Tarski for S/U/Box). Every month of delay on task 123 delays the entire pipeline.

4. **The succ_embed approach is structurally complete except for surjectivity.** BUC is sorry-free. TC and FUC are structurally complete but invoke `succ_embed_surjective`. The BFMCS on Z (`cantor_bfmcs_discrete`) is sorry-free. All downstream wiring (discrete countermodel, completeness case split) is done. This is NOT a design problem -- it is a single mathematical lemma.

5. **There are exactly two families of proof strategy for surjectivity.** (a) Prove the orbit is cofinal (unbounded in both directions), then apply `succ_embed_squeeze`. This is the current plan's Phase 4. (b) Prove `Icc` finiteness for `LimitDomSubtype` in the discrete case, from which `IsSuccArchimedean` follows and surjectivity is immediate. Both are mathematically sound; the question is formalizability.

## Strategic Assessment

### Which approach better positions us for the mixed case?

**Neither approach directly helps the mixed case**, because the mixed case's difficulty is orthogonal to surjectivity. The mixed case requires:
- A domain D that accommodates both discrete and dense families
- A BFMCS structure on D where some families validate `U(T,bot)` and others validate `F'T`
- A parametric representation theorem that works with such a mixed BFMCS

This is task 117/122 territory, not task 123. However, **Option A (direct surjectivity)** is marginally better because it validates the succ_embed pipeline for the discrete families, which the mixed case will also need for its discrete sub-families. If we instead used a collapse quotient (which would bypass surjectivity), the mixed case would face the same quotient problem for its discrete sub-families -- requiring the quotient to interact with the dense sub-families' domain, which is harder.

### Which approach produces more reusable infrastructure?

**Option B (Icc finiteness)** produces more reusable infrastructure:

1. `Icc_finite` for `LimitDomSubtype` directly gives `LocallyFiniteOrder`, which enables counting arguments, decidability results, and combinatorial reasoning about the discrete temporal structure.
2. `IsSuccArchimedean` plugs into Mathlib's `orderIsoIntOfLinearSuccPredArch`, giving an order isomorphism `LimitDomSubtype ≃o Z` for free. This isomorphism could replace the manually-constructed `succ_embed` entirely.
3. The finiteness proof technique (bounded discrete sets in Q cannot accumulate) is reusable for any construction on countable subsets of Q with the no-gap property.

**Option A (orbit cofinality)** produces less reusable infrastructure:
1. The cofinality lemma is specific to the succ-orbit from root.
2. It does not establish LocallyFiniteOrder or IsSuccArchimedean as typeclass instances.
3. However, it is simpler and more direct.

### Which approach is more publishable?

**Option B (Icc finiteness)** is more publishable because it gives a cleaner statement:

> The limit domain of the Burgess omega-chain construction in the discrete case is locally finite, hence isomorphic to Z by Mathlib's `orderIsoIntOfLinearSuccPredArch`.

This is a clean structural result about the construction that a reviewer can verify against the mathematical definition. The proof factors into: (1) no-gap property (proved), (2) bounded no-gap sets in Q are finite (a clean lemma about Q), (3) Mathlib pipeline from locally finite to Z-isomorphism.

**Option A (orbit cofinality)** is less clean for publication:

> The succ-orbit from root is cofinal in the limit domain, therefore every point is in the orbit by the squeeze lemma.

This is a correct argument but requires the reader to understand the squeeze lemma and trust that "cofinal orbit + no-gap implies surjective" is proved correctly. It is more ad hoc.

## Mathlib Alignment Analysis

### The Mathlib pipeline

Mathlib provides a complete pipeline from structural assumptions to Z-isomorphism:

```
LinearOrder + SuccOrder + PredOrder + IsSuccArchimedean + NoMaxOrder + NoMinOrder + Nonempty
  → orderIsoIntOfLinearSuccPredArch : Type ≃o Z
```

`LimitDomSubtype` already has `LinearOrder`, `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, and `Nonempty` (all sorry-free). The only missing piece is `IsSuccArchimedean`.

### Proving IsSuccArchimedean

`IsSuccArchimedean` says: for any `a <= b`, there exists `n` such that `succ^[n](a) = b`. This is equivalent to single-orbit, which is equivalent to `succ_embed_surjective`.

To prove `IsSuccArchimedean`, the two options are:
- **Direct**: Show that for any `a < b`, iterating succ from `a` eventually reaches `b`. This is the orbit cofinality argument applied to each pair.
- **Via Icc finiteness**: If `Set.Icc a b` is finite, then the succ-iteration from `a` through the finite set must terminate at `b` (since `NoMaxOrder` in `Icc a b` would contradict finiteness if the iteration never reached `b`).

### Maintenance burden

**Icc finiteness approach (Option B)**: If Mathlib changes the API for `orderIsoIntOfLinearSuccPredArch`, we need to update the typeclass proof. However, Mathlib's order theory is very stable (this pipeline has existed since 2022). The maintenance burden is LOW.

**Direct surjectivity (Option A)**: We manually construct `succ_embed : Z -> LimitDomSubtype` and prove it is bijective. This is self-contained with ZERO Mathlib dependency for the isomorphism. The maintenance burden is ZERO for the isomorphism itself but does not benefit from Mathlib improvements.

**Recommendation**: If Icc finiteness can be proved cleanly (under 100 lines), prefer it for Mathlib alignment. If it requires deep real analysis (convergence of bounded monotone sequences in Q, embedding Q into R), prefer the direct surjectivity approach -- the Mathlib overhead is not worth the proof complexity.

### What the Mathlib pipeline actually saves

If we establish `IsSuccArchimedean` on `LimitDomSubtype`, we get:
- `orderIsoIntOfLinearSuccPredArch : LimitDomSubtype ≃o Z` (for free)
- This replaces the manually-built `succ_embed` and its strict monotonicity proof
- The transport of FMCS properties through the isomorphism is cleaner (order isos compose with monotonicity automatically)

However, the current `succ_embed` pipeline is already sorry-free and working. Replacing it with the Mathlib pipeline would mean discarding ~200 lines of working code and rebuilding the FMCS transport. This is only worthwhile if Icc finiteness is provable without excessive effort.

## Unconventional Approaches

### A. Restructure the construction (Verbrugge-style)

Verbrugge et al. 2004 build Z directly by assigning successors at dedicated (odd) stages, preventing later counterexample elimination from disrupting the successor structure. If we adopted this approach:

**Cost**: The omega-chain construction in `ChronicleConstruction.lean` (~1520 lines) and `CounterexampleElimination.lean` (~3488 lines) would need substantial refactoring. The interleaving of successor assignment and counterexample elimination would change. All 17+ sorry-free lemmas about the omega chain (c5 witnesses, limit domain properties, etc.) would be at risk.

**Benefit**: Single-orbit becomes trivially true (each point gets exactly one successor at its assignment stage, and the assignment is permanent).

**Verdict**: NOT RECOMMENDED. The cost (~1000-2000 new lines plus regression risk on ~5000 lines of sorry-free code) vastly exceeds the benefit of avoiding a ~100-200 line surjectivity proof. The construction IS correct -- it just needs one more structural lemma.

### B. Well-founded induction on stage of entry

Define `stage(x) = min{K : x.val in dom(K)}` for each `x in LimitDomSubtype`. Prove surjectivity by well-founded induction on some measure involving stages.

**The obstacle** (from report 05): `pred(w)` in the FULL limit domain may have `stage(pred(w)) > stage(w)`. This is because later stages can insert points between `w` and its stage-K predecessor, creating a new limit-domain predecessor at a later stage. So any simple stage-based measure does not decrease along the pred-chain.

**A possible fix**: Use a lexicographic measure `(max(stage(w), stage(pred(w)), ..., stage(pred^k(w))), k)` where k is the number of pred-steps from the initial point. But this measure is not obviously well-founded.

**Verdict**: POSSIBLE but the measure definition is complex and the well-foundedness proof is non-trivial. Not recommended unless the other approaches fail.

### C. Use the C5-walk for U(T,bot) directly

In the discrete case, every point `x` in `limit_dom` has `U(T,bot) in limit_f(x)`. The C5-walk for this formula (at some omega-chain stage) produces a successor witness `y` with `bot in limit_f(w)` for all `w` between `x` and `y`. Since `bot` is never in an MCS, this means no limit_dom points between `x` and `y` -- so `y` is the immediate successor of `x` in limit_dom, and `y = limitDomSubtype_succ(x)`.

**The insight**: The C5-walk for U(T,bot) at EVERY stage maintains the invariant that the succ-chain covers all domain points up to the newly-added witness. If we could formalize this stage-by-stage coverage invariant, surjectivity would follow by induction.

**The difficulty**: The C5-walk inserts `y` at a specific stage K+1, but `limitDomSubtype_succ(x)` in the FULL limit may differ from `y` if later stages insert points between `x` and `y`. However, in the discrete case, the bot-gap property prevents such insertions -- so `limitDomSubtype_succ(x) = y` (the point from the C5-walk). This property has NOT been formalized.

**Verdict**: This is a genuinely interesting "third option." If one could prove `limitDomSubtype_succ(x) = c5_witness(x)` (the limit-domain successor equals the C5-walk successor for U(T,bot)), then surjectivity would follow by a clean stage induction. Estimated effort: 100-200 lines, with the main challenge being the proof that no later stage inserts a point between `x` and its C5-bot-witness. This is a construction-specific argument that directly addresses the formalization gap identified in all prior research. WORTH INVESTIGATING.

### D. Accept the sorry and document it

The sorry in `succ_embed_surjective` is mathematically true (confirmed by all 4 teammates in round 2, supported by the literature review). It could be accepted as a "known formalization gap" with detailed documentation, allowing the rest of the pipeline to proceed.

**Verdict**: Acceptable as a last resort, but unsatisfying for a project targeting sorry-free completeness. The ROADMAP explicitly lists "sorry-free bx_completeness" as the Phase 1 goal. A documented sorry is better than a blocked pipeline, but should be temporary.

## Publication Readiness

### Current publishable results (no sorry required)

1. **Soundness** of TM logic under irreflexive semantics (all 3 variants, sorry-free)
2. **FMP completeness** (`fmp_completeness`, sorry-free)
3. **Dense completeness** (`dd_countermodel_chronicle_dense`, internally sorry-free)
4. **45-axiom system** for bimodal S5+LTL with irreflexive semantics, including Prior-UZ/SZ
5. **Decidability** (`decide`, sorry-free)

### Results blocked by task 123

6. **Discrete completeness** (1 sorry: `succ_embed_surjective`)
7. **Full `bx_completeness`** (transitively blocked)

### Publication format considerations

For a conference paper (LICS, IJCAR, ITP), the dense completeness result is already substantial and publishable. The discrete case adds significant value -- it demonstrates the Prior-UZ/SZ axioms working correctly and validates the entire Burgess 1982 construction for the discrete class of linear orders.

A paper reporting "dense completeness sorry-free, discrete completeness modulo a single structural lemma (confirmed true but not yet formalized)" would be acceptable at most venues. The lemma's status as "mathematically confirmed but technically blocked by Lean formalization challenges" is a recognized phenomenon in the proof assistant community.

However, a paper with **fully sorry-free discrete completeness** would be stronger and more memorable. The difference between "one sorry" and "zero sorries" is disproportionately impactful for the formalization community.

### What a reviewer would find most natural

A mathematical reviewer expects one of:
1. The construction produces Z directly (Verbrugge approach) -- most natural, no isomorphism needed
2. The construction produces a countable discrete set, and an explicit isomorphism to Z is given (our approach with `succ_embed`)
3. The construction produces a countable discrete set, and a Mathlib-certified pipeline gives the isomorphism (Icc finiteness + `orderIsoIntOfLinearSuccPredArch`)

Option 3 is most impressive from a formalization perspective (leveraging Mathlib). Option 2 is most transparent (everything is explicit). Option 1 is most natural mathematically but would require construction refactoring.

## Recommended Path

**Short-term (task 123 completion):**

1. **Try the C5-walk approach first** (Unconventional Approach C above). If the bot-gap property prevents later stages from inserting points between `x` and its C5-bot-witness, this gives a clean stage-induction proof of surjectivity with no real analysis required. Estimated: 100-200 lines.

2. **If C5-walk fails, try Icc finiteness** (Option B). The key lemma is: a bounded discrete subset of Q with the no-gap property is finite. The proof by contradiction uses the fact that accumulation at any point (in or out of limit_dom) violates the no-gap property or the properties of limit_dom successors. Estimated: 80-150 lines.

3. **If both fail, prove orbit cofinality directly** (Option A). The interleaving argument where pred-chain elements from a bounding point eventually enter orbit gaps. This requires the most delicate Lean formalization. Estimated: 80-150 lines.

4. **Last resort: accept the sorry with documentation.** Mark `succ_embed_surjective` as a known gap, document why it is true, and proceed with tasks 122 and beyond. Revisit when a formalization strategy becomes clear.

**Medium-term (tasks 122, 124, 115, 116):**

Once task 123 is resolved, task 122 (wire discrete BFMCS into the nondense sorry) should take 8-15 hours. Then Phase 2 axiom cleanup (tasks 124, 115, 116) proceeds sequentially, touching overlapping files. These are lower-risk, well-understood refactoring tasks.

**Long-term (task 125, Jonsson-Tarski):**

The algebraic representation theorem for the bimodal logic with S/U/Box requires all preceding tasks. Its research is not yet started but the literature base (Venema 1991/1993/1997, GHV 2003, de Rijke-Venema 1995) is assembled in `literature/`. This is the capstone result that would make the formalization publishable as a comprehensive contribution.

## Confidence Level

**HIGH** on the strategic assessment: the downstream task chain is clear and well-documented.

**HIGH** on the publication analysis: dense completeness alone is publishable; sorry-free discrete would be significantly stronger.

**MEDIUM** on the C5-walk approach: it is a genuine insight that no prior research round identified, but the key technical lemma (no later stage inserts between x and its C5-bot-witness) has not been verified.

**MEDIUM** on the Icc finiteness approach: the mathematics is sound but formalization in Lean may require more real analysis infrastructure than expected.

**LOW** on time estimates: the surjectivity problem has consistently taken longer than estimated (3 implementation attempts, 7+ research reports, 2 team research rounds). Any estimate should be treated as a lower bound.
