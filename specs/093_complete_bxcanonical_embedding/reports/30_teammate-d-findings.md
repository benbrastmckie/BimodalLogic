# Teammate D Findings: Literature, Infrastructure, and Architectural Alternatives

## 1. Literature Survey

### 1.1 Burgess (1982) / Xu (1988): The Original BX System

Burgess's completeness proofs for Since/Until tense logics over linear orders are described as "relatively simple modifications of the usual proofs for ordinary tense logic without S and U." The key technique is:

- **Standard canonical model construction** with MCS as worlds
- **Eventuality resolution via semantic argument**: The truth lemma is proved by induction on formula complexity. For the Until case, the key step is: if `phi U psi` is in MCS w, then either `psi in w` (base) or `phi in w` and `phi U psi` propagates forward via `fwd_succ`. The witness is found by **well-founded induction on the number of unresolved defects** within the subformula closure.

Crucially, Burgess does NOT build a single chain and then prove forward_F about it. Instead, the completeness argument is **semantic**: the truth lemma is proved simultaneously with the model construction, using induction on formula depth. The forward_F property is a CONSEQUENCE of the truth lemma, not a prerequisite.

### 1.2 Goldblatt (1992): Logics of Time and Computation

Goldblatt's treatment of tense logics follows the standard canonical model pattern. For linear temporal logics, the completeness proof uses:

- Canonical frame with MCS as worlds, ordered by g_content inclusion
- Truth lemma by formula induction
- For Until: the quasimodel/defect-discharge technique (counting unresolved Until obligations in the subformula closure)

The key insight from Goldblatt that applies here: the **finite model property** and **filtration** are the standard tools for handling eventualities. The canonical model is infinite, but the eventuality arguments work because the subformula closure is finite.

### 1.3 Verbrugge (2004): Completeness by Construction

The "completeness by construction" method (de Jongh, Veltman, Verbrugge) is directly relevant. It was developed in Amsterdam in the 1970s-80s for tense logics over linear discrete structures (copies of Z). The method:

- Builds the model **incrementally**, point by point
- At each step, resolves one defect (an unmet eventuality obligation)
- Terminates because defects decrease within the finite subformula closure
- The resulting structure is a **quasimodel**: a finite partial model that can be unraveled/embedded into the full canonical model

This is EXACTLY what the existing sorry-free `Quasimodel/Construction.lean` implements. The project already has this technique formalized.

### 1.4 Gabbay, Hodkinson, Reynolds (1994)

GHR's comprehensive treatment uses step-by-step model construction for temporal logics with Until. The key technique for the Until case involves:

- Building chains of MCS where each step resolves one Until-defect
- Using the BX axioms (especially BX5 self-accumulation and BX6 absorption) to ensure the chain terminates
- The chain is finite (bounded by |subformula closure|)

### 1.5 Mosaic Method (Marx et al.)

The mosaic method provides an alternative to canonical models for temporal logics. Relevant finding: the method has been extended to **logics combining linear tense operators with an "orthogonal" S5-like modality** -- which is precisely the structure of TM (S5 + linear temporal). Mosaics are "partial models" whose consistent assembly proves completeness. However, formalizing the mosaic method from scratch would be a major undertaking (~2000+ LOC) and the project already has substantial canonical model infrastructure.

### 1.6 Blackburn, de Rijke, Venema (2001): Step-by-Step Method

BdRV's Chapter 4 describes the "step-by-step technique" as a method for proving completeness when canonicity fails. The technique builds models incrementally, adding worlds to satisfy unmet demands. This is conceptually similar to the quasimodel approach but works at the level of Kripke frames rather than syntactic closures.

### 1.7 Key Literature Consensus

**All standard references handle the Until eventuality SEMANTICALLY, not syntactically on a pre-built chain.** The pattern is:

1. Build the canonical model (MCS as worlds)
2. Prove the truth lemma by induction on formula structure
3. For Until: use the quasimodel/defect-discharge argument within the truth lemma itself
4. forward_F is a CONSEQUENCE, not an input

The project's current approach (trying to prove forward_F about a pre-built chain, then feeding it to the truth lemma) **inverts the standard dependency order**.

## 2. Existing Sorry-Free Infrastructure Analysis

### 2.1 What's Already Sorry-Free

The project has an impressive amount of sorry-free infrastructure:

| Component | LOC | Sorry-Free? | Key Capability |
|-----------|-----|-------------|----------------|
| Frame.lean | 673 | YES | BXPoint, bx_le, all witness constructions |
| TruthLemma.lean | 320 | YES | Full truth lemma (all formula cases) |
| Completeness.lean | 152 | YES | `bx_completeness` (delegates to `dd_countermodel`) |
| Quasimodel/* | 1,816 | YES | Hintikka points, defect-discharge, realization |
| Filtration/* | 316 | YES | Sigma-ordering, defect chains |
| CanonicalChain.lean | 157 | YES | MCS-level BX axiom bridges |
| CanonicalModel.lean | 498 | YES | fwd_succ, bwd_pred, schedule, f_carry |
| OrderedSeedConsistency.lean | 255 | YES | Seed consistency for ordered discharge |
| ParametricRepresentation.lean | ~300 | YES | D-parametric representation theorem |
| RestrictedParametricTruthLemma.lean | ? | YES | Restricted truth lemma |

**Total sorry-free infrastructure: ~4,500+ lines.**

### 2.2 The Sorry-Free Quasimodel Path

The quasimodel infrastructure (`Construction.lean` 887 lines, `Realization.lean` 444 lines) already proves:

- `until_eventuality_resolution`: Given `phi U psi in w` and `psi not-in w`, exists `v` with `bx_le w v` and `psi in v` and `phi in w`
- `since_eventuality_resolution`: Symmetric backward version
- `bx_until_backward` / `bx_since_backward`: Guard properties

These are exactly the eventuality witnesses needed for the truth lemma, and the truth lemma is ALREADY SORRY-FREE using them.

### 2.3 What the Sorry-Free Path Produces vs. What's Needed

The sorry-free quasimodel produces: **abstract BXPoint witnesses** (individual MCS points related by `bx_le`).

What `dd_bfmcs` needs: **Int-indexed FMCS families** where `forward_F` holds for all formulas in the deferral closure.

The gap: BXPoint witnesses are unordered (they satisfy `bx_le` but are not embedded in a specific Int-indexed chain). The FMCS requires a function `mcs : Int -> Set Formula` where all temporal coherence properties hold across the entire timeline.

## 3. Architectural Alternatives (Ranked by Feasibility)

### Alternative A: Quasimodel-Based BFMCS Construction (RECOMMENDED)

**Idea**: Instead of building `dd_fmcs` from a round-robin chain and then trying to prove forward_F about it, build the FMCS directly from quasimodel witnesses.

**Construction**:
1. Start with root MCS M0 at position 0
2. For each unresolved F(psi) at position t, use the sorry-free `until_eventuality_resolution` to get a witness BXPoint v with psi in v
3. Place v at position t+1 (or an appropriate later position)
4. Repeat, using the finite subformula closure to bound the process

**Key insight**: The quasimodel chain from `Construction.lean` is already a finite sequence of BXPoints with the defect-discharge property. We just need to embed it into Int.

**Embedding strategy**: A quasimodel chain of length k can be embedded into Int positions [0, 1, ..., k]. For positions outside this range, extend by "repeating" the endpoint (using `fwd_succ` with non-resolving steps to preserve g_content).

**Feasibility**: HIGH. The core mathematical work is done (quasimodel construction is sorry-free). The new work is:
- An embedding function from quasimodel chain indices to Int (~100-200 LOC)
- Proving the FMCS properties (mcs, g_content propagation) for the embedded chain (~200-300 LOC)
- Proving restricted_temporally_coherent from the quasimodel's defect-discharge property (~200-300 LOC)

**Estimated LOC**: 500-800 new lines.

**Risk**: The quasimodel produces BXPoints related by `bx_le`, but the FMCS needs g_content inclusion to hold between consecutive Int-indexed points. Since `bx_le` IS g_content inclusion, this should align directly.

### Alternative B: Redefine dd_chain Using Per-Formula Resolution

**Idea**: Replace `rr_fwd_chain` (round-robin with `enriched_fwd_step`) with a new chain that uses `fwd_succ` and resolves F-defects using quasimodel sub-chains.

**Construction**:
1. Start with M0
2. Enumerate all F(psi) defects in the subformula closure
3. For each defect, insert a quasimodel resolution sub-chain
4. Concatenate all sub-chains into a single Int-indexed chain

**Feasibility**: MEDIUM. More complex than Alternative A because it requires interleaving multiple quasimodel chains while maintaining global g_content coherence.

**Estimated LOC**: 800-1200 new lines.

### Alternative C: Semantic Truth Lemma Approach (Standard Literature Pattern)

**Idea**: Restructure the entire proof to follow the standard literature pattern where forward_F is proved as part of the truth lemma by formula induction, not as a property of a pre-built chain.

**Construction**: Rewrite `dd_countermodel` to:
1. Build an FMCS using ANY chain (even the existing `rr_fwd_chain`)
2. Prove the restricted truth lemma simultaneously with restricted temporal coherence
3. The Until case of the truth lemma uses the quasimodel eventuality resolution
4. forward_F falls out as a corollary

**Why this might work**: The truth lemma is already sorry-free. The restricted coherence properties (forward_F, backward_P, Until/Since coherence) are only needed for formulas in `deferralClosure(root)`. The quasimodel provides witnesses for each such formula individually.

**Feasibility**: MEDIUM-HIGH. The key question is whether the existing `RestrictedParametricTruthLemma.lean` can be restructured to avoid needing forward_F as an input.

**Risk**: The parametric truth lemma currently takes `restricted_temporally_coherent` as a hypothesis. Restructuring to prove them simultaneously is a significant refactor.

**Estimated LOC**: 400-600 new lines + refactoring.

### Alternative D: Weakened Coherence (forward_F on Demand)

**Idea**: Weaken `restricted_temporally_coherent` to only require forward_F for formulas that are actually used in the truth lemma evaluation of `root`.

**Current definition**: forall fam, forall t, forall phi in deferralClosure(root), F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)

**Weakened**: Only require this for phi where the truth lemma actually invokes forward_F during the inductive proof.

**Feasibility**: LOW-MEDIUM. Would require careful analysis of which formulas the truth lemma actually needs forward_F for, and may not actually simplify the proof.

### Alternative E: Bypass dd_bfmcs Entirely

**Idea**: Wire `bx_completeness` directly through the quasimodel infrastructure without going through BFMCS at all.

**Why this won't work easily**: The completeness theorem uses `dd_countermodel`, which produces a `TaskModel` (with histories, world states, etc.). The quasimodel produces abstract BXPoint chains. Converting quasimodel output to a TaskModel requires the same BFMCS machinery that's currently sorry-laden.

However, a lighter-weight version might work: define a `TaskModel` directly from a single quasimodel chain (for the temporal direction) combined with modal witnesses (for the box direction), without the full BFMCS abstraction layer.

**Feasibility**: LOW. Would require significant restructuring of the parametric representation theorem.

### Alternative F: Mosaic Method (Complete Rewrite)

**Idea**: Implement the mosaic method from scratch, proving completeness via mosaic consistency.

**Feasibility**: VERY LOW. Estimated 2000+ LOC, throws away most existing infrastructure. Only worth considering if all other approaches fail.

## 4. Strategic Recommendations

### Immediate Recommendation: Alternative A (Quasimodel-Based BFMCS)

Build the FMCS by embedding quasimodel chains into Int-indexed families. This:
- Leverages the 1,816 lines of sorry-free quasimodel infrastructure
- Avoids the perpetual deferral problem entirely (quasimodel chains have bounded length)
- Aligns with the standard literature approach (defect-discharge)
- Has the lowest estimated LOC (500-800)

### Fallback: Alternative C (Semantic Truth Lemma)

If Alternative A hits an unforeseen obstruction in the embedding, restructure the truth lemma to prove coherence simultaneously rather than taking it as input.

### What NOT to Do

1. **Do not continue trying to prove forward_F about `rr_fwd_chain`**. Report 26 proves this is blocked by perpetual deferral. 26 rounds of research have confirmed this dead end.

2. **Do not try to enrich the chain seed further**. Dead ends 13, 22, 23, 24 show that all enriched seed approaches fail due to inconsistency of `{target} union g_content(M) union f_carry(M)`.

3. **Do not attempt the Goldblatt WF-induction on the existing chain** (plan v27 Section 3). The depth-0 base case analysis in `RootScopedChain.lean:1613-1678` shows that F(psi) can be lost at resolving steps for other targets, and once lost it stays lost forever. WF-induction on f_nesting_depth does NOT help for depth-0 formulas.

### Long-Term Architecture

The project's architecture (BXCanonical -> ParametricRepresentation -> dd_countermodel) is fundamentally sound. The BFMCS abstraction layer is the right way to combine modal (S5) and temporal (linear) structure. The issue is specifically in HOW the FMCS families are constructed -- the round-robin chain approach is a dead end, but the quasimodel approach should work.

## 5. The Key Question Answered

**Is the current architecture (dd_chain -> dd_fmcs -> dd_bfmcs -> dd_countermodel) fundamentally the right approach?**

YES, with one critical modification: **dd_chain should be built from quasimodel witnesses, not from a round-robin `enriched_fwd_step` chain.**

The dd_fmcs -> dd_bfmcs -> dd_countermodel pipeline is correct. The ParametricRepresentation theorem is correct. The truth lemma is correct. The ONLY problem is in the construction of the Int-indexed chain within each FMCS, specifically the forward_F property.

The sorry-free quasimodel infrastructure already solves this problem at the BXPoint level. The missing piece is a bridge from quasimodel chains to Int-indexed FMCS families.

**Should we route through the quasimodel directly?** Not "instead of" BFMCS, but "as the construction method for" BFMCS families. The quasimodel provides the temporal chain construction; BFMCS provides the modal bundling. They serve different roles and should be combined.

## 6. Confidence Level

- Literature findings: **HIGH** (95%). Standard references consistently use semantic/defect-discharge approaches.
- Alternative A feasibility: **HIGH** (85%). The mathematical path is clear; main risk is unforeseen Lean 4 formalization difficulties in the embedding.
- Assessment that round-robin chain is a dead end: **VERY HIGH** (98%). 26 rounds of research, 26 documented dead ends.
- Assessment that quasimodel-to-BFMCS bridge is the right approach: **HIGH** (80%). Aligns with literature, leverages existing infrastructure, avoids known obstructions.

## Sources

- [Burgess 1982, "Axioms for tense logic I"](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-I-Since-and-until/10.1305/ndjfl/1093870149.pdf)
- [Goldblatt 1992, "Logics of Time and Computation"](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- [Verbrugge 2004, "Completeness by construction for tense logics of linear time"](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Gabbay, Hodkinson, Reynolds 1994, "Temporal Logic"](https://global.oup.com/academic/product/temporal-logic-9780198537694)
- [Blackburn, de Rijke, Venema 2001, "Modal Logic" Chapter 4](https://www.cambridge.org/core/books/modal-logic/F7CDB0A265026BF05EAD1091A47FCF5B)
- [Marx et al., "The Mosaic Method for Temporal Logics"](https://link.springer.com/chapter/10.1007/10722086_26)
- [Stanford Encyclopedia: Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
