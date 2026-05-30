# Teammate D Findings: Strategic Alternatives and Long-Term Alignment
## Task 202: Reynolds K-Equivalence Bypass
## Date: 2026-05-30
## Artifact: 16 (teammate-d)

---

## Key Findings

### F1: Is completeness_discrete the right goal?

Yes, `completeness_discrete` is the right goal and cannot be deferred. The
ROADMAP establishes it as the final unresolved sorry on the critical path to
sorry-free completeness. The dense variant (`completeness_dense`) and soundness
are already sorry-free. The discrete case is genuinely needed to complete the
formalization of TM as described in the publication target: "TM is complete with
respect to TaskFrames over totally ordered abelian groups."

A well-documented sorry on `completeness_discrete` would mean the publication
claim is unverified by Lean. Since the project goal is Lean verification
(not just informal proof), the sorry cannot remain in a publication-ready
formalization. The strategic importance has not diminished across 17 implementation
cycles -- it remains the one remaining mathematical gap.

### F2: Accept-and-defer strategy (axiom instead of sorry)

The question is whether `reynolds_model_surgery_core` (or its two sub-lemmas
`gap_prior_UZ_contradiction` / `gap_prior_SZ_contradiction`) could be elevated
to a named `axiom` declaration rather than remain a `sorry`.

**Verdict: Feasible as an interim strategy, but with significant costs.**

Lean 4 permits:
```lean
axiom gap_prior_UZ_contradiction_axiom (sig : MonadicSignature) (k : Nat) ... : False
```

This is semantically cleaner than `sorry` because:
- `#print axioms completeness_discrete` would report the axiom by name
- The axiom is mathematically true (Reynolds 1994 proves it)
- It signals "conditioned on this mathematical result" rather than "unverified"

The costs:
1. The axiom would still make `completeness_discrete` non-sorry-free under the
   zero-debt policy definition (axioms count as non-standard foundations)
2. Using `axiom` for a theorem that IS provable from Mathlib foundations is
   architecturally unsatisfying -- Lean's kernel would no longer verify it
3. It would appear in every `#print axioms` audit and require documentation
4. If Reynolds' Lemmas 6-13 are eventually proved, the axiom becomes dead weight

**Recommendation**: Do NOT elevate to `axiom` yet. The sorry is better contained
in the current architecture (two named sorry sites in `gap_prior_UZ/SZ_contradiction`
with detailed proof sketches). If after 5 more implementation cycles the sorry
remains, revisiting axiom-elevation would be appropriate.

### F3: Different proof architecture -- alternative levels or strategies

Multiple alternative architectures were systematically analyzed across 17 cycles.
The key findings from that record:

**a) Chronicle level instead of OrderedMonadicStructure level**: Already tried
(plans v11-v12). The chronicle-level approach via `PriorModelData` failed because
`no_gaps_faithful` is mathematically FALSE (the Z+Z counterexample with constant
predicates disproves it even with h_accessible). The current architecture at
the OrderedMonadicStructure level with h_surj is the correct setting.

**b) Game-theoretic argument**: The EF-game infrastructure exists in
`EFGames/Defs.lean` but is NOT connected to `contemp_equiv` (which uses
`very_good` / `good` / `k_equiv` via normal forms, not EF games). Bridging
them would require ~300-500 lines of additional sorry-free infrastructure.
The connection is mathematically possible but requires significant new work.
This is a genuine alternative that has not been fully explored. See F4.

**c) Ramsey theory or compactness**: No viable path identified. The problem
is inherently about order-theoretic structure, not combinatorial density.
Compactness arguments would need to be instantiated to the specific setting
of discrete linear orders with Prior-UZ/SZ, which is essentially what
Reynolds' model surgery achieves constructively.

**d) Decidability-based approach**: Explicitly excluded by the ROADMAP as a
path to the representation theorem. A decision procedure cannot substitute for
the structural correspondence between proof-theoretic and semantic notions.

**e) Direct Prior-UZ contradiction (no surgery)**: Definitively analyzed in
report 15 (Section A.4-A.6) and confirmed FAILS in Case B. When predicates
vary across the gap, predicate transitions at successor pairs in the complement
are legitimate and do not create contradictions. The Z+Z counterexample
demonstrates this concretely.

**Conclusion**: The full Reynolds model surgery (Lemmas 6-13) at the
OrderedMonadicStructure level with h_surj is the only confirmed-correct approach.

### F4: Scope reduction -- weaker versions of no_gaps_discrete

**Could a weaker theorem suffice?**

The call chain is:
```
no_gaps_discrete -> one_class -> chronicle_is_good_direct
  -> countermodel_discrete_reynolds -> completeness_discrete
```

The theorem `no_gaps_discrete` says: given a discrete Prior structure with h_surj,
all points are contemp_equiv (one equivalence class). The downstream theorem
`one_class` is exactly this.

For the completeness theorem, what is actually needed is:
- The specific chronicle structure (produced from a consistent formula phi)
- With its specific atomMap_fwd (satisfying h_surj via mkAtomMapFwd_surj)
- Can be embedded in a Z-interval

Could we prove `no_gaps_discrete` for this SPECIFIC type of structure (chronicle
as monadic structure) without the general theorem?

**Answer**: Yes, potentially. The chronicle has additional structure not present
in a general OrderedMonadicStructure:
- It has a specific MCS-based predicate assignment
- It is produced by the omega-chain construction
- The MCS assignment is "faithful": temporal_truth at root matches the original formula

If faithfulness implies that the Z+Z counterexample is inapplicable (which requires
that the chronicle's predicate assignment is non-constant -- because a consistent
formula phi.neg in the root MCS forces some variation), then the simpler Case B
argument from report 15 might work specifically for the chronicle.

**Critical obstacle**: The Z+Z counterexample has h_accessible but not h_surj.
With h_surj at the chronicle level, if all predicates are constant (Case A in
report 15), all points are already contemp_equiv (contradiction). If predicates
vary (Case B), the first-transition argument in report 15 fails. But for the
CHRONICLE specifically, if predicates vary across the gap, the transition must
happen at the MCS level, and the MCS structure may impose additional constraints
that force a contradiction.

**Assessment**: This "chronicle-specific" approach is moderately unexplored.
It would require showing that the chronicle's Prior-UZ/SZ + faithfulness +
h_surj forces the first predicate transition to be at a gap boundary (not a
successor boundary in the complement). This has not been definitively proven
or disproven.

**Regarding k=0 first**: This does not simplify the core problem because the
contemp_equiv relation is defined for fixed k, and the completeness theorem uses
k = operator_depth(phi) + 2, which may be large. A k=0 proof would not generalize.

**Regarding Z-interval structures only**: The current architecture already restricts
to Z-interval structures (via `good` and `ZIntervalStructure`). The general theorem
handles exactly this case.

### F5: External formalization survey

**Is there an existing Lean/Coq/Isabelle formalization of Reynolds' theorem?**

Based on the project history and literature: NO. Reynolds 1994 ("Axiomatising
U and S over Integer Time") is a relatively specialized paper in temporal logic,
and no Mathlib-adjacent formalization of Theorems 6-14 has been identified across
the research cycles. The closest is the `PriorExpressiveness.lean` file which
formalizes Reynolds Theorem 5 (US expressive completeness), which IS sorry-free
and serves as the foundation for Lemma 6 in the model surgery.

The expressive completeness theorem (Theorem 5) being sorry-free is the key
non-trivial piece that Reynolds' proof depends on. Lemmas 6-13 are "only"
a model surgery argument that builds on Theorem 5. The hard external dependency
is already solved.

A search for Coq/Isabelle/HOL formalizations of Reynolds 1994 (Theorems 6-14
specifically) has not been performed in this research cycle and might be worth
attempting. Reynolds' result is related to the Ehrenfeucht-Fraisse games in
temporal logic, a more well-studied area. However, porting from Coq/Isabelle
to Lean 4 with its specific type class system and Mathlib structures would
likely require as much effort as a direct formalization.

### F6: Task splitting -- should task 202 be divided?

**Current sorry map** (2 mathematical + 1 engineering in Transfer.lean):

1. `gap_prior_UZ_contradiction` (GoodStructuresModelSurgery.lean:702) -- Reynolds Lemmas 6-13 upward case, ~300-400 lines
2. `gap_prior_SZ_contradiction` (GoodStructuresModelSurgery.lean:728) -- Reynolds Lemmas 6-13 downward case, ~200-300 lines (can use Order.dual from upward case)
3. Z-interval to TaskFrame packaging (Transfer.lean:1289) -- engineering, ~150-300 lines

**Current state**: Phase 1 (h_surj construction) is COMPLETED (mkAtomMapFwd_surj
exists and sorry-free). Phase 2 (model surgery) is IN PROGRESS with the sorry
isolated to two theorems. Phase 3 (wire no_gaps_discrete) is straightforward
wiring. Phase 4 (packaging) remains.

**Should task 202 be split?**

Yes, splitting into 2-3 separate tasks would clarify responsibilities and enable
independent progress:

**Task A: Reynolds Model Surgery (mathematical core)**
- Close `gap_prior_UZ_contradiction` (upward case, Lemmas 6-13)
- Close `gap_prior_SZ_contradiction` (downward case, via Order.dual)
- Wire `no_gaps_discrete` in GoodStructures.lean
- Status: [IN PROGRESS], dependency: none
- Effort: 12-16 hours
- File: GoodStructuresModelSurgery.lean

**Task B: Z-interval TaskFrame Packaging (engineering)**
- Construct TaskFrame countermodel from Z-interval
- Handle box modality correspondence
- Dependency: Task A (needs no_gaps_discrete sorry-free)
- Effort: 4-6 hours
- File: Transfer.lean

**Task C: Rewire and Verify (final integration)**
- Rewire completeness_discrete to Reynolds pipeline
- Full lake build + axiom audit
- Dependency: Task B
- Effort: 2 hours
- File: Completeness.lean

**Dependency graph**:
```
Task A -> Task B -> Task C -> sorry-free completeness_discrete
```

**Warning** on the Transfer.lean packaging (Task B / Plan v14 Phase 4): The
comment at Transfer.lean:1180-1192 marks `countermodel_discrete_reynolds` as
having an "UNSOLVABLE sorry" and warns against attempting to fix it. However,
this warning appears to reflect an earlier architectural state where the approach
being attempted was the WRONG one. The plan v14 Phase 4 specifies a concrete
approach (WorldHistory-based model for atom formulas, MCS-based for box). This
warning should be re-evaluated rather than treated as a permanent blocker.

---

## Recommended Approach

### Primary recommendation: Full model surgery, current architecture

Proceed with plan v14 as specified. The model surgery approach is mathematically
correct and the only confirmed-sound path. No strategic pivot is warranted.

**Specific tactical recommendations**:

1. **For gap_prior_UZ_contradiction**: Implement Lemmas 6-13 in exact sequence.
   The most dangerous subproof is Lemma 12 (model surgery truth preservation,
   13 subcases for U + 13 for S). Break each subcase into a separate named lemma
   to keep the file modular and to enable partial lake build verification.

2. **For gap_prior_SZ_contradiction**: After gap_prior_UZ_contradiction is proved,
   use `Order.dual` to map the downward case to the upward case. This should reduce
   the additional proof to ~50-100 lines rather than 300.

3. **For Transfer.lean packaging**: Override the "UNSOLVABLE" warning. The comment
   reflects an old approach. The current plan v14 Phase 4 approach (WorldHistory
   model where Omega = {tau_t | t in Z-interval}, ShiftClosed by successor shift)
   is architecturally sound. The box modality correspondence requires careful
   alignment between temporal_truth treating box as a predicate and truth_at
   quantifying over WorldHistories. The key insight: the chronicle MCS assignment
   determines box truth, and the Z-interval inherits this via k-equivalence.

4. **Task splitting**: Consider splitting task 202 into Task A (model surgery) +
   Task B (packaging) to enable clearer progress tracking. Task A is purely
   mathematical and Task B is purely engineering, and they have a single clean
   dependency.

### Secondary recommendation: Explore chronicle-specific shortcut

If the model surgery implementation stalls again after 3-4 more attempts, revisit
the "chronicle-specific" scope reduction (F4 above). The key hypothesis to test:

> **Hypothesis**: For the chronicle monadic structure (produced from a consistent
> formula phi by the omega-chain construction), h_surj + Prior-UZ/SZ + faithfulness
> implies one_class directly, WITHOUT the full model surgery.

This is worth a 2-4 hour research sprint to either confirm or refute. If confirmed,
it would reduce the mathematical burden substantially (avoiding Lemmas 7-13) by
exploiting the chronicle's specific structural properties.

### Alternative under continued failure: Axiom-elevation

If 5+ additional implementation cycles fail on the model surgery sorry, consider:
1. Elevate `gap_prior_UZ_contradiction` and `gap_prior_SZ_contradiction` to named
   `axiom` declarations
2. Document them as "unproved Reynolds lemmas awaiting formalization"
3. Complete Phases 3-5 of plan v14 (which are engineering, not mathematical)
4. Mark `completeness_discrete` as "sorry-free modulo Reynolds axioms"
5. File a separate task for eventual closure

This would allow Phases 3-5 (packaging, rewiring, verification) to proceed
independently of the mathematical blocker, potentially unblocking the publication
pipeline.

---

## Evidence and Examples

### Evidence for "full model surgery is required"

Report 15, Section A.4-A.6 documents the exhaustive analysis of the direct
Prior-UZ contradiction proof (without model surgery). The Case B failure is concrete:

- The first-transition point `s` (first point with a different predicate value above
  the class of `a`) must be in the complement (past the gap)
- `pred(s)` is also in the complement (proved in the report)
- The predicate transitions from True at `pred(s)` to False at `s`
- This transition is at a successor pair `(pred(s), s)` WITHIN the complement
- This does not violate Prior-UZ (which allows transitions at successor pairs)
- No contradiction is reached

The report concludes: "The direct argument fails because predicate transitions at
successor pairs in the complement do not create contradictions." (Section A.7)

### Evidence for architecture correctness

The sorry-free infrastructure already in GoodStructuresModelSurgery.lean
establishes all the building blocks for Lemmas 6-13:

- `right_gap_class_prop` (definition of right gap class, sorry-free)
- `right_gap_class_invariant` (class membership is class-invariant, sorry-free)
- `right_gap_class_succ` (preserved under successor, sorry-free)
- `right_gap_class_pred` (preserved under predecessor, sorry-free)
- `contemp_equiv_succ_iterate` (class succ-iteration, sorry-free)
- `class_gap_exists` (gap construction from bounded succ-closed class, sorry-free)
- `prior_UZ_first_transition` (first-transition lemma, sorry-free)
- `cut_succ_closed`, `complement_pred_closed` (gap structural lemmas, sorry-free)

The two sorry sites are narrowly contained in `gap_prior_UZ_contradiction` and
`gap_prior_SZ_contradiction`. The downstream chain (`reynolds_model_surgery_core`,
`gap_contradicts_prior`, `gap_contradicts_prior_below`, `no_gaps_discrete_model_surgery`)
is already sorry-free given these two lemmas.

### Evidence for task split value

The Transfer.lean packaging sorry (line 1289) is architecturally independent of
the model surgery sorry. The packaging work can proceed as soon as `no_gaps_discrete`
is closed, regardless of how the model surgery is ultimately proved. The "UNSOLVABLE"
warning at lines 1180-1192 was written during an earlier implementation cycle and
does not reflect the current architectural state where the WorldHistory construction
approach was not yet explored.

---

## Confidence Level

**On the full model surgery being mathematically correct**: HIGH (9/10). Reynolds
1994 Lemmas 6-13 are mathematically sound, and the codebase has the necessary
infrastructure to support the formalization. The proof is long but elementary
given the infrastructure.

**On the packaging step being solvable**: MEDIUM (6/10). The box modality
correspondence between temporal_truth (treating box as predicate) and truth_at
(WorldHistory quantification) is the key tension. The ROADMAP and Transfer.lean
comments indicate this was the blocking issue. A concrete construction strategy
exists but has not been verified.

**On the chronicle-specific shortcut**: LOW-MEDIUM (4/10). The hypothesis is
plausible but not confirmed. Case B failure documented in report 15 applies to
general OrderedMonadicStructures; whether the chronicle's extra structure avoids
it requires a focused research sprint.

**On the axiom-elevation strategy being viable**: HIGH (9/10). It is technically
straightforward. The question is whether it is strategically appropriate given
the publication goal.

**On task splitting improving outcomes**: HIGH (8/10). The clear separation between
mathematical work (model surgery) and engineering work (packaging, wiring) would
make progress tracking more granular and allow independent agents to work in parallel.
