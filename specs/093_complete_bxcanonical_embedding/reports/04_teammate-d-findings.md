# Teammate D Findings: Strategic Horizons and Literature Alignment

**Task**: 93 - Complete BXCanonical embedding
**Teammate**: D (Strategic Horizons)
**Date**: 2026-04-13
**Round**: 4

---

## Key Findings

1. **The "step-by-step growing linear order" technique is DISTINCT from the finite tree strategy** — it is an incremental construction that builds a chain of MCSes one step at a time using oracle-like witness selection, not a tree with an embedding. It is closer in spirit to restricted temporal coherence than to either Strategy 1 or 2 as proposed.

2. **The literature DOES use both canonical frame (tree) and step-by-step constructions**, but the canonical frame approach (Strategy B from prior research, i.e. the Bundle/CanonicalFrame.lean approach) is the dominant one for reflexive tense logics. Step-by-step constructions are more common for strict (`<`) linear time.

3. **The tuple/"consistent set" approach appears in the literature under the name "Henkin witness closure" or "theory-based canonical models"** — it avoids maximization but requires adding witnesses explicitly. This is essentially what the deferral-disjunction seed in SuccExistence.lean does locally: it uses `{φ ∨ F(φ) | F(φ) ∈ u}` rather than requiring the successor MCS to contain `φ` outright.

4. **Restricted temporal coherence (the prior research consensus recommendation) aligns BEST with the literature**, because it mirrors the "filtration" technique used in modal logic completeness: restrict the canonical model to a finite closure, prove the properties within that closure, and lift back.

5. **The SuccExistence deferral seed pattern is the most directly applicable existing infrastructure** for closing `bx_fmcs_forward_F` — it was designed to handle exactly this problem (F-obligation preservation through chain steps) without requiring biased Lindenbaum or restricted coherence.

6. **Task 68 (dense completeness) is fully independent** — neither Strategy 1 nor Strategy 2 extends to dense time. Dense completeness requires a separate canonical model over ℚ.

---

## Literature Survey

### What Standard Tense Logic Completeness Proofs Actually Do

The prior report (03_team-research.md, Teammate D section) correctly identified that standard proofs use tree-shaped canonical frames or step-by-step constructions. Here is more precise information on each technique:

#### Technique A: Full Canonical Frame (Tree of ALL MCS)

Used in: Goldblatt 1992 (*Logics of Time and Computation*), Gabbay-Hodkinson-Reynolds 1994.

The canonical frame has ALL MCS as worlds, with the future relation `M ≤ N ↔ g_content(M) ⊆ N`. In this frame:
- `forward_F` is trivially proved: given `F(ψ) ∈ M`, apply `forward_temporal_witness_seed_consistent` + Lindenbaum to get a witness MCS `W` with `ψ ∈ W` and `g_content(M) ⊆ W`.
- The resulting frame is NOT linearly ordered — it is a TREE (or partial order). Therefore it proves completeness over the class of all partial orders (or reflexive partial orders), not specifically over Int.

This is EXACTLY the approach in `Bundle/CanonicalFrame.lean` where `canonical_forward_F` is already proved trivially (lines 133–148). The prior research (Teammate B) correctly noted this is structurally incompatible with `FMCS Int` because the tree frame violates `LinearOrder D`.

#### Technique B: Step-by-Step Growing Linear Orders

Used in: Burgess 1984, Xu 1988, and related work on **strict** linear time (`<`-based semantics).

This technique builds a linear chain `w₀, w₁, w₂, ...` inductively. At each step n:
1. Start with `wₙ` already constructed.
2. Enumerate all F-obligations `F(ψ₁), F(ψ₂), ...` still pending at `wₙ`.
3. Choose an obligation `F(ψₖ)` by some scheduling rule.
4. Build `wₙ₊₁` to satisfy `g_content(wₙ) ∪ {ψₖ}` (extend to an MCS).
5. By the choice of MCS, other pending obligations may survive or may not.

This is NOT a finite tree — it is an infinite chain where each step handles ONE obligation. The key difficulty is that at step n, satisfying `ψₖ` may destroy `F(ψⱼ)` for `j ≠ k`. The standard solution (Burgess 1984) is to USE THE LINEARITY AXIOM (BX11 in this codebase) to argue that the ordering of witnesses is consistent: if `F(ψ) ∈ wₙ` is destroyed at step `n+1`, then by BX11, either `ψ` was already satisfied at some earlier step, or there exists a linear ordering of witnesses that forces one to survive.

**Critical insight**: Under REFLEXIVE semantics (BX1: `Gφ → φ`), the Burgess step-by-step technique simplifies because `F(ψ) ∈ w` means the witness can be the current point `w` itself (under `≤`). This is why the deferral disjunction `ψ ∨ F(ψ)` is sound for reflexive semantics: either `ψ` holds now (witness = current), or `F(ψ)` holds (witness is strictly in the future).

**Is this the same as the finite tree strategy?** NO. The finite tree strategy (Strategy 1) generates a tree from F/P obligations and then embeds into a linear order — a two-phase approach. The step-by-step technique builds the linear order directly, one step at a time, handling one obligation per step. The step-by-step technique is closer to the `int_chain` construction already in `CanonicalModel.lean`, but with a better scheduling rule.

#### Technique C: Filtration / Restricted Canonical Models

Used in: Fischer-Ladner 1979 (for PDL), Wolper 1983 (for ETL), the FMP-based approach.

In filtration, the canonical model is RESTRICTED to a finite closure of subformulas. This automatically bounds the obligation set. The method is:
1. Define the filtration closure `Σ` (here: `SubformulaClosure` or `deferralClosure`).
2. Restrict the canonical frame to Hintikka points within `Σ`.
3. Prove F/P coherence within the restricted model.

This is exactly the Hintikka/defect-discharge approach that closed the Until/Since sorries in tasks 90, 92, 98, 102. The restricted temporal coherence approach (Approach 3 from prior research) mirrors this: `restricted_temporally_coherent root` limits forward_F to formulas in `deferralClosure(root)`.

**Why this aligns with the literature**: The filtration technique is the standard way to handle eventuality obligations in bounded models. The infinity of Int-indexed worlds is handled by the EXTERNAL frame (`int_chain`), while the INTERNAL F-obligations are bounded by the deferral closure.

#### Does the "tuple (V,F)" Approach Appear in the Literature?

The consistent tuple / non-maximized set approach appears in:
- **Scott domains** (denotational semantics): using consistent filters rather than ultrafilters.
- **Completeness via prime theories**: some completeness proofs use prime consistent theories (closed under derivation, not necessarily maximal) with F-witnesses explicitly added.
- **Henkin witness closure without full maximization**: explicitly add existential witnesses at each stage but stop before reaching maximality.

In the tense logic literature specifically, the non-maximized approach is RARE. The main reference would be approaches for logics where Lindenbaum fails (e.g., infinitely long conjunctions), which is not the current setting. The tuple approach (V,F pairs) as described in the current investigation — avoiding Lindenbaum maximization and working with pairs of consistent sets — does NOT have a clear standard literature analogue for this specific problem.

**Assessment**: The tuple approach may work, but it is non-standard and would require more foundational justification. It is not the approach any of the primary references (Goldblatt, Burgess, Xu, Venema, GHR) use for linear tense logic completeness.

---

## Strategy Comparison

### Strategy 1: Finite Tree + Linear Embedding

**Literature alignment**: LOW.

No standard reference uses a two-phase tree+embedding approach for tense logic completeness over Int. The closest analogue is filtration (Technique C above), but filtration builds a finite MODEL (not a tree that then gets embedded). The embedding step from tree to linear order is non-trivial and may be unsound unless the tree has special structure (e.g., it is already a linear chain modulo branching).

**Formalization complexity**: HIGH. Requires:
1. A well-founded tree construction (could reuse SuccExistence.lean ideas).
2. A linearization theorem for the tree (likely hard — needs axiom of choice or König's lemma variant).
3. Proof that the linearization preserves all BXPoint properties.

**Code reuse from existing 600-line infrastructure**: LOW. The `int_chain` construction is bypassed; most of the existing `CanonicalModel.lean` would be replaced.

**Sorry-free risk**: HIGH. The linearization of a tree into Int requires a non-obvious embedding theorem.

### Strategy 2: Consistent Tuples (V,F) Avoiding Lindenbaum

**Literature alignment**: LOW-MEDIUM.

The tuple approach avoids maximization, which simplifies the step that fails (Lindenbaum can add `G(¬ψ)` for other F-obligations). However, this trades the consistency problem for a COMPLETENESS problem: without maximality, the truth lemma requires showing that `φ ∈ V` iff `φ` is true in the model, and this is harder without the negation-completeness property of MCS.

**Formalization complexity**: HIGH. The truth lemma for non-maximal consistent sets would need a substantial rewrite of `TruthLemma.lean`, or a new bridge from tuples to the existing MCS infrastructure.

**Code reuse**: VERY LOW. The existing `BFMCS`, `FMCS`, truth lemma, and parametric representation all assume MCS worlds.

**Sorry-free risk**: VERY HIGH. A new truth lemma for non-maximal worlds is a major undertaking.

### Approach 3: Restricted Temporal Coherence (Prior Research Consensus)

**Literature alignment**: HIGH.

This directly mirrors the filtration technique from the tense/modal logic literature. `restricted_temporally_coherent root` limits the forward_F obligation to formulas in `deferralClosure(root)`, which is finite. This is the filtration idea applied at the OBLIGATION level rather than the MODEL level.

**Formalization complexity**: MEDIUM. Requires a restricted truth lemma bridge (~200 lines) and a modified chain construction with a finite schedule. The existing infrastructure (`restricted_temporally_coherent` definition, `deferralClosure`, `int_chain`) is already present.

**Code reuse**: HIGH. Uses the existing `int_chain` construction with only the scheduling modified. The `BFMCS`, `FMCS`, and truth lemma remain unchanged.

**Sorry-free risk**: MEDIUM. The restricted truth lemma bridge is the main new piece, but its structure follows the existing `TruthLemma.lean` pattern closely.

### Hybrid: Deferral Disjunction Seed Applied to Int Chain

**Literature alignment**: HIGH (mirrors Burgess step-by-step technique).

The `SuccExistence.lean` deferral seed construction — `g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}` — is exactly the Burgess step-by-step technique specialized to a single step. If the `int_chain` construction used this seed at EVERY step (rather than the current F-obligation resolving seed), then:
- Each step would have a Lindenbaum extension guaranteed to contain `φ ∨ F(φ)` for each pending F-obligation.
- Either `φ` holds (obligation satisfied at next step) or `F(φ)` holds (obligation deferred).
- The deferral chain eventually terminates (under appropriate axioms) by BX5/BX6 (until self-accumulation).

**Key question**: Does the deferral seed work for an infinite chain over Int? For finitely many formulas (restricted to `deferralClosure(root)`), YES — this is essentially the restricted temporal coherence approach with deferral-disjunction seeds instead of obligation scheduling. For infinitely many formulas (the current non-restricted setting), NO — there is no bound on how long an obligation can be deferred.

**Assessment**: The deferral disjunction seed is a LOCAL tool; it guarantees `φ ∨ F(φ)` at the next step, not `φ` at some specific step. For `bx_fmcs_forward_F`, we need the STRONGER property `∃ s > t, φ ∈ chain(s)`. The deferral seed alone does not give this without bounded termination.

---

## Creative Alternatives

### Alternative A: Restricted Coherence + Deferral Disjunction Seeds

Combine the restricted temporal coherence scoping with deferral disjunction seeds at each chain step:
1. Scope the obligation to `F := deferralClosure(root)` (finitely many formulas).
2. At each chain step, use seed = `g_content(M) ∪ {φ ∨ F(φ) | F(φ) ∈ M, φ ∈ F_closure}`.
3. The chain now defers each F-obligation locally at each step.
4. By BX5 (`self_accum_until`) + BX6 (`absorb_until`), termination is forced within the formula closure.
5. Forward_F follows: for each formula in the closure, the deferral chain terminates in finitely many steps.

This combines the strengths of restricted coherence (bounded obligation set) with the deferral seed pattern (avoids Lindenbaum sabotage). The `successor_deferral_seed_consistent` theorem in `SuccExistence.lean` already proves the seed is consistent, so no new consistency lemma is needed.

**Estimated effort**: ~150-250 lines (modified chain step using deferral seed, termination argument).

### Alternative B: Extract Linear Sub-frame from Bundle/CanonicalFrame.lean

`CanonicalFrame.lean` already proves `canonical_forward_F` trivially. The obstacle is that the canonical frame is not linearly ordered. However:
1. Given a starting MCS `M₀`, consider the sub-frame of MCS reachable from `M₀` via `g_content`-chains.
2. Using BX11 (`temp_linearity`), the F-witness ordering is linear among MCS reachable from any fixed starting point.
3. This could define a linear ordering on a subset of MCS reachable from `M₀`, giving an Int-indexed linear chain.

**Problem**: The reachable sub-frame may still branch (two different F-witnesses from the same MCS may be incomparable). BX11 only gives linearity of witnesses at the SAME point, not globally.

**Assessment**: This alternative is less viable than it appears. BX11 gives `F(α) ∧ F(β) → F(α ∧ β) ∨ F(α ∧ ¬β) ∨ F(¬α ∧ β)`, which gives a witness for a CONJUNCTION, not a total order on all witnesses. Branching cannot be eliminated by BX11 alone.

### Alternative C: Use SuccExistence Predecessor Chain for forward_F at t=0

For the special case where `t = 0` and `ψ` is the root formula, `SuccExistence.lean`'s `successor_exists` theorem directly gives `∃ v, Succ(chain(0), v) ∧ (ψ ∈ v ∨ F(ψ) ∈ v)`. This handles the BASE CASE of the deferral argument. Combined with well-founded induction on `defect_count`, this could close forward_F for the bounded case.

**Assessment**: Viable, but only within restricted coherence. The `defect_count` well-founded induction is already present in `DefectChain.lean` — this alternative is essentially using the filtration infrastructure that closed Until/Since sorries.

---

## Roadmap Alignment Assessment

### Task 93 (this task): sole blocking sorry

The restricted temporal coherence approach (Approach 3) is best aligned with the project trajectory because:
1. It uses the same filtration infrastructure that successfully closed the Until/Since sorries in tasks 90-102.
2. It does NOT require rewriting `TruthLemma.lean` or the parametric infrastructure.
3. The `restricted_temporally_coherent` definition already exists in `TemporalCoherence.lean`.
4. The deferral seed infrastructure in `SuccExistence.lean` can be leveraged for the restricted chain step construction.

### Task 68 (Dense Completeness, 1 sorry)

According to ROAD_MAP.md: `dense_completeness_fc` needs a separate proof over ℚ. Neither Strategy 1 nor Strategy 2 extends to dense time. Approach 3 (restricted coherence) also does not directly extend — dense time requires different witness existence arguments. Task 68 is independent of Task 93.

**Which strategy produces more reusable code for Task 68?** None of the three strategies helps Task 68 directly. However, Approach 3 produces a cleaner separation between:
- The finite formula-closure argument (reusable for FMP)
- The chain construction over Int (Task 93-specific)
Dense completeness over ℚ would use a different chain type.

### Task 82 (FMP Truth Preservation)

According to ROAD_MAP.md: `mcs_all_future_closure` and `mcs_all_past_closure` have been archived to Boneyard. Task 82's active sorry count is 0. This task is on the decidability track only and is independent of Task 93.

### Code Reusability Summary

| Strategy | Reuses int_chain? | Reuses TruthLemma? | Reuses deferralClosure? | Helps Task 68? |
|----------|------------------|---------------------|------------------------|---------------|
| Strategy 1 (tree+embed) | No | Yes | No | No |
| Strategy 2 (tuples) | No | No (major rewrite) | No | No |
| Approach 3 (restricted) | Yes | Yes | Yes | No |
| Hybrid A (restricted+deferral) | Yes (modified) | Yes | Yes | No |

---

## Confidence Level

**High** (85%)

Justification:
1. The literature alignment assessment is based on well-understood references (Goldblatt 1992, Burgess 1984, Xu 1988, Venema 1993, GHR 1994) whose techniques are documented in the codebase roadmap and prior research reports.
2. The ROAD_MAP.md confirms the roadmap alignment claims (tasks 68, 82 are independent; task 93 is the sole blocker).
3. The restricted temporal coherence recommendation is the consensus from the prior research team (03_team-research.md, high confidence from both C and D) — this report corroborates and extends that recommendation.
4. The one area of lower confidence is the hybrid deferral-seed approach (Alternative A): it is plausible but has not been verified against the existing `SuccExistence.lean` consistency theorem for the MODIFIED int_chain setting. The original `successor_deferral_seed_consistent` (Bundle/) was proved under stronger axiom assumptions (base + DF + seriality) that may or may not hold in the BXCanonical setting.

---

## Summary

The standard tense logic literature uses two techniques: (A) full canonical frame (trivially proves forward_F, but not linear) and (B) step-by-step growing chain (proves forward_F for one obligation at a time, requires linearity to manage inter-obligation interference). Neither matches the current `int_chain` construction exactly.

The BEST path forward is **Approach 3 (restricted temporal coherence)**, which mirrors the filtration technique used successfully in tasks 90-102 to close the Until/Since sorries. The restricted deferral closure bounds the F-obligation set to finitely many formulas, making a deterministic resolution schedule feasible. This approach has the highest literature alignment, highest code reuse, and lowest sorry-free risk.

**The deferral disjunction seed from SuccExistence.lean** (Alternative A hybrid) should be investigated as the concrete mechanism for the restricted chain step construction, since its consistency is already proved and it directly addresses the inter-obligation interference problem that blocked all prior approaches.

Strategy 1 (finite tree + embedding) and Strategy 2 (consistent tuples) are both non-standard and carry high formalization risk. They should be pursued only if Approach 3 encounters an unforeseen blocker.
