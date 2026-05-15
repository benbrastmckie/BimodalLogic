# Teammate D (Horizons) Research Findings — Task 140

**Date**: 2026-05-15
**Task**: 140 — Truth transfer and succ_cofinal elimination
**Researcher**: Teammate D (strategic/horizons perspective)

---

## Strategic Position

Task 140 occupies the fulcrum of the critical path. It is the task where the Reynolds pipeline
transitions from "structurally wired but dormant" to "load-bearing". Everything before it (tasks
129, 139, 143) provides the scaffolding; everything after it (141, 142) can only land their
sorries in a world where the Reynolds transfer actually runs.

The three-layer architecture in Transfer.lean is already clearly articulated:
1. Chronicle Extraction (ChronicleExtraction.lean) -- done
2. Reynolds Compression (IntegerModel.lean) -- partially done, blocked on sum_preservation
3. Truth Transfer (Transfer.lean) -- the main target of task 140

Task 140's stated scope is:
- Implement `table` (the standard FO translation of temporal formulas)
- Prove `table_depth_bound` (quantifier depth bounded by operator depth)
- Wire the Reynolds pipeline into `doets_countermodel_discrete` to replace the chronicle fallback
- Verify `#print axioms doets_countermodel_discrete` is clean of `succ_cofinal`

**The critical architectural question that this research must answer**: Is the path currently
clear to complete step 3 (truth transfer), or are there hidden blockers?

### Dependency Map as of 2026-05-15

```
table (Table.lean)
  -- needs: mkSigFrom (done, placeholder), mkAtomMap (done, placeholder)
  -- needs: proper signature construction (current mkSigFrom uses Fin 1 placeholder)

table_depth_bound (Table.lean)
  -- needs: table (non-sorried body)
  -- straightforward structural induction once table is concrete

chronicle_is_good (IntegerModel.lean)  <-- BLOCKED
  -- needs: very_good_implies_good
  -- which needs: sum_preservation (Doets Lemma 1.4)
  -- sum_preservation is sorried in KEquivalenceFramework
  -- Task 143 (Doets Lemma 1.1 normal forms) may help but is about finite_types not sum_preservation

doets_countermodel_discrete wiring (Transfer.lean)
  -- needs: table, table_depth_bound
  -- needs: chronicle_is_good (BLOCKED per above)
  -- currently falls back to chronicle construction
```

**The critical finding**: The `chronicle_is_good` path through `sum_preservation` (Doets Lemma
1.4) is a deeper blocker than the task description acknowledges. Task 140 cannot complete step 3
(replace chronicle fallback) without either:
(a) proving `sum_preservation` (EF-game formalization, major work), or
(b) finding an alternative route to `very_good_implies_good` that bypasses sum_preservation.

This makes task 140 potentially a two-part task:
- Part A: `table` implementation and `table_depth_bound` proof (achievable, 3-5h)
- Part B: `doets_countermodel_discrete` wiring (blocked by `sum_preservation`)

Confidence: HIGH (based on reading IntegerModel.lean, OrderedSum.lean, and Transfer.lean).

---

## Downstream Impact

### Effect on Task 141 (Canonical Truth Lemma Until/Since)

Task 141's revised plan (02_revised-plan.md) already concluded that the 6 TruthLemma.lean
Until/Since sorries are dead code relative to `bx_completeness`. The parametric truth lemma
in the Algebraic module handles the completeness proof. Task 141 therefore does NOT depend on
task 140's completion.

The one live sorry in ReflexiveCanonical.lean (`reflCanR_linear`) is needed for Reynolds
Theorem 15 in the general setting but has no current downstream consumer in `bx_completeness`.
Task 140 does not affect this.

**Conclusion**: Task 141 is independent of task 140. The two can proceed in parallel.

### Effect on Task 142 (Mixed-Case Countermodel)

Task 142's description lists task 140 as a dependency. However, examining the TODO.md scope
carefully: the mixed case `dd_countermodel_chronicle_mixed_sorry` in ChronicleToCountermodel.lean
is about the third branch of `bx_completeness` where neither `box(F'T)` (dense) nor
`box(U(T,bot))` (discrete) is in the MCS.

The Reynolds pipeline (which task 140 activates) is specifically the discrete branch. The
mixed case is a different logical problem: whether S5 modal accessibility can be "mixed"
(some worlds discrete, some dense) and what countermodel construction handles this. The
Reynolds pipeline does not directly address this.

The dependency of task 142 on task 140 may be overstated. Task 142 likely depends on
understanding the *architecture* that task 140 produces (knowing where the discrete
case lands), but does not technically wait for task 140 to be sorry-free before
task 142 can be researched.

**Recommendation**: Begin task 142 research immediately rather than waiting for task 140
to complete. The mixed-case problem is architecturally independent.

### Effect on `succ_cofinal` elimination

The `succ_cofinal` sorry is in the chronicle construction path (BXCanonical/Chronicle/).
The Reynolds pipeline was designed specifically to bypass `succ_cofinal` by using the
weak/reflexive Henkin canonical model (Sahlqvist canonicity applies there) and then
compressing to Z via Doets. Once `doets_countermodel_discrete` routes through the Reynolds
pipeline rather than the chronicle fallback, `succ_cofinal` drops off the axiom set.

But this only works if `chronicle_is_good` is sorry-free, which requires `sum_preservation`.
The pipeline will remain blocked at the chronicle fallback until that is resolved.

---

## Literature Opportunities

### Reynolds 1994: What the Table Actually Is

Reynolds Section 6 (pp. 122-123) gives the complete inductive definition of the standard
translation `C_A(t)`. The key cases not yet implemented in Table.lean:

- **Atom p**: `P(t)` -- atom p maps to predicate symbol P evaluated at t
- **Until(A,B)**: `∃s > t (C_A(s) ∧ ∀u(t < u ∧ u < s → C_B(u)))`
- **Since(A,B)**: `∃s < t (C_A(s) ∧ ∀u(s < u ∧ u < t → C_B(u)))`
- **G(A)**: `∀s > t C_A(s)` -- i.e., `all(lt 1 0 → atom_A 0)` in De Bruijn
- **H(A)**: `∀s < t C_A(s)` -- symmetric

Reynolds explicitly says: "A simple induction establishes that all temporal formulas A have
a corresponding monadic formula C_A in one free variable." (p. 122, confirmed in literature).

This means `table` is a pure syntactic translation with no semantic content -- just formula
rewriting. It should be implementable without sorries by direct induction on `Formula`.
The only design question is: what MonadicSignature do we use and how do we map atoms?

**Opportunity**: The signature question (current `mkSigFrom` uses `Fin 1` placeholder) is the
main design decision for task 140. Reynolds assumes atoms map 1-to-1 to predicate symbols.
The cleanest design would be `preds := subformAtoms φ` (the finite set of atoms in φ).
This requires decidable equality on atoms, which `Atom` likely has.

Confidence: HIGH (Reynolds 1994 Section 6 directly specifies the table function).

### Doets 1989: What sum_preservation Actually Requires

Doets Lemma 1.4 (p. 223) is stated concisely: "If for all i∈I, m(i) =_n m'(i), then
Σ_{i∈I} m(i) =_n Σ_{i∈I} m'(i)."

The proof: "straightforward to describe a winning strategy for the second player in the
Ehrenfeucht n-game between these sums under the condition given."

The Ehrenfeucht-Fraisse (EF) game approach requires:
1. Defining EF games on ordered monadic structures (not yet in the codebase)
2. Showing that pointwise equivalence of summands gives a winning strategy for the duplicator
3. Formalizing the game-theoretic argument in Lean 4

This is genuinely hard to formalize from scratch. The Lean 4 / Mathlib ecosystem does have
EF-game infrastructure (there is a `FirstOrder.Language.BoundedFormula` framework that
encodes some of this), but adapting it to the monadic ordered setting would require significant
bridging work.

**Opportunity**: An alternative to EF-games is a direct algebraic/syntactic proof of
sum_preservation using the quantifier-rank characterization. For each sentence σ of depth ≤ n,
one can verify that its truth in the sum depends only on the truth of sentences of depth ≤ n
in individual summands. This "truth-in-sum decomposition" approach avoids EF-game formalism.
It is more work to write out but may be more Lean-friendly.

Confidence: MEDIUM (this is a design choice for a follow-up task, not for task 140 itself).

### Reynolds Theorem 15 vs. Just Closing `table`

The strategic insight here: task 140 has TWO distinct sub-goals with different difficulty levels:

1. **Close `table` and `table_depth_bound`**: Pure syntactic implementation. Table.lean already
   has `operator_depth` defined correctly. The `table` function just needs a concrete body.
   Straightforward 2-3h work once signature design is decided.

2. **Wire `doets_countermodel_discrete` to use Reynolds pipeline**: Requires `chronicle_is_good`
   (sorry-free), which requires `very_good_implies_good`, which requires `sum_preservation`.
   This is the hard part that may not be achievable in task 140 scope.

**Strategic recommendation**: Split task 140's "definition of done" into two parts:
- Primary: `table` and `table_depth_bound` sorry-free (achievable)
- Secondary: `doets_countermodel_discrete` wiring (blocked, move to new task or task 143+)

Closing just `table` and `table_depth_bound` reduces the sorry count by 2, which is the stated
metric in TODO.md. The wiring is a separate architectural step.

Confidence: HIGH.

### Venema 1993 / 1991: Relevant for S/U Translation but Not Blocking

Venema's work on the Since/Until algebra (anti-axioms paper, dissertation Chapter III) focuses
on the algebraic representation side (BAO, ultraproducts). This is relevant for Phase 4
(algebraic representation, task 125) but not for task 140's FO translation.

Venema does not offer an alternative to Reynolds for the table correctness result.

The "Completeness via Completeness" technique in Venema 1993 (Since and Until) is about showing
completeness of strict-time logics via completeness of reflexive-time logics -- which is
exactly what the Reynolds pipeline does! The reflexive canonical model is used precisely because
the weak G relation makes it Sahlqvist-canonical. This is an independent confirmation that the
Reynolds approach is correct.

Confidence: HIGH that Venema 1993 (Since and Until) validates the architectural choice of using
a reflexive canonical model; MEDIUM that it offers anything new for the implementation.

### Caleiro-Vigano-Volpe 2013: Alternative Proof Path

The mosaic method paper (completeness for S5 + linear tense = exactly BX structure) provides
an alternative completeness proof via mosaic construction. However:
- The mosaic approach does not use the standard translation or Z-compression
- It would require completely different formalization infrastructure
- It is more relevant as a cross-check or as an alternative to the entire Reynolds pipeline

This is not useful for task 140 implementation. It could be relevant if the Reynolds pipeline
is ultimately too hard to complete (as a fallback route for task 142 mixed case).

Confidence: LOW relevance for task 140 specifically.

---

## Architectural Recommendations

### Recommendation 1: Implement `table` with Proper Atom-to-Predicate Mapping

The current `mkSigFrom` and `mkAtomMap` stubs in Transfer.lean use `Fin 1` as the predicate
type, which is a placeholder. Task 140 needs to replace these with a genuine construction.

Recommended design:
```lean
-- Use the set of atoms appearing in φ as the signature
def mkSigFrom (φ : Formula) : MonadicSignature where
  preds := φ.atoms  -- subtype or finset of Atom appearing in φ
  fintypePreds := φ.atoms_fintype  -- finite by structural induction
  decEqPreds := ...

-- Map each predicate back to its atom formula
def mkAtomMap (φ : Formula) : (mkSigFrom φ).preds → Formula :=
  fun p => Formula.atom p.val
```

This requires `Formula.atoms : Formula → Finset Atom` (may already exist -- `lean_local_search`
should check). The `table` function then maps `Formula.atom a` to `MonadicFormula.atom ⟨a, ha⟩ 0`
where `ha : a ∈ φ.atoms`.

The signature dependency (table takes sig as a parameter) means the correctness theorem will
need to state: for φ and the signature `mkSigFrom φ`, `table (mkSigFrom φ) φ` correctly encodes
the truth conditions. The sig parameter should be unified with `mkSigFrom φ` in the wiring.

Confidence: HIGH (this is the natural design).

### Recommendation 2: Separate `table` Implementation from Pipeline Wiring

Given the blocker at `sum_preservation`, task 140 should aim to:
1. Implement `table` with concrete body (sorry-free)
2. Prove `table_depth_bound` (sorry-free)
3. Prove `table_correctness` as the main semantic theorem (sorry-free)
4. Leave `doets_countermodel_discrete` wiring as a documented TODO with the steps
   already commented in Transfer.lean

This delivers the 2 sorries reduction stated in the task scope (the `table` and
`table_depth_bound` sorries) without needing `sum_preservation`.

The Transfer.lean already has the 6-step pipeline commented out. Once `table_correctness`
is proved, step 5 of the comment can be filled in. But steps 3-4 (chronicle_is_good,
extract Z-interval) require `sum_preservation`.

Confidence: HIGH that this is achievable; HIGH that full wiring is not achievable in
task 140 scope.

### Recommendation 3: Truth Transfer Theorem Statement

The `table_correctness` theorem that task 140 needs is approximately:

```lean
theorem table_correctness (φ : Formula) (t : M.carrier) (M : OrderedMonadicStructure sig)
    (atomSatisfied : ∀ p, M.interp p t ↔ atomMap p ∈ someSet) :
    truthInOriginalModel M φ t ↔ eval M (Fin.cons t Fin.elim0) (table sig φ)
```

The exact statement depends on how the correspondence between the monadic structure's
predicates and the temporal formula's atoms is set up. Reynolds (p. 122) states: "for all
structures (T, <), for all valuations h, for all t ∈ T, (T, <, h) |= A(t) iff
(T, <, h) |= C_A(t)." The key insight is that the monadic structure (T, <, h) simultaneously
is a temporal structure and the FO structure for interpreting `C_A`.

For the chronicle-as-monadic-structure construction (`chronicleAsMonadicStructure`), the
predicate `interp p x = (atomMap p ∈ M.fmcs x)`. The truth transfer says: temporal truth
at x in the chronicle equals FO truth of `table sig φ` at x in the monadic structure.

Proof strategy: structural induction on φ. Each case unfolds both sides and uses:
- Atom: definitional equality (interp p x = (atom p ∈ fmcs x) by definition)
- Bot/Imp: trivial (both are classical)
- G/H: quantifier interchange (∀ y > x, ... ↔ eval M (Fin.cons x Fin.elim0) (all (lt ...)))
- Until/Since: existential quantifier interchange with the explicit FO encoding

This is the type of proof that `simp`/`aesop` may handle well once the definitions are in
place. The mathematical content is thin (it's a definitional equivalence); the formal work
is in unfolding definitions correctly.

Confidence: HIGH that the proof is achievable; MEDIUM on exact statement (needs `lean_goal`
inspection during implementation).

### Recommendation 4: Revise `mkSigFrom` and `mkAtomMap` Before `table`

Currently `mkSigFrom` uses `Fin 1` (single predicate) and `mkAtomMap` maps everything to
`Formula.bot`. These placeholders are fine for compiling the file but will break when table
is implemented. The first step of task 140 implementation should be to fix these signatures.

If `Formula.atoms` does not exist in the codebase, it needs to be added to the Syntax module.
This is a 20-line definition by structural induction returning a `Finset Atom`.

### Recommendation 5: Clarify What "succ_cofinal Elimination" Means in Practice

The task title says "eliminate succ_cofinal from the axiom set of doets_countermodel_discrete."
This is only achievable if `doets_countermodel_discrete` routes through the Reynolds pipeline
(not the chronicle fallback). As analyzed above, this requires `sum_preservation` first.

The team should set expectations clearly:
- "succ_cofinal free `doets_countermodel_discrete`" requires `sum_preservation` (not in 140 scope)
- "table sorry-free" is achievable in task 140 scope
- The task title might be misleading the implementer toward a harder goal than what is
  achievable

Consider updating the task description to reflect this split.

---

## Creative and Unconventional Approaches

### Approach A: Use `native_decide` for `table` Finiteness Claims

The `table_depth_bound` theorem is a purely structural claim about formula syntax. It is
a decidable property in principle (finite structural induction). If `Formula` has `DecidableEq`
and `Repr`, `decide` might close this automatically. However, given the parametric nature
(arbitrary `sig`), this probably won't work. Standard structural induction is the right path.

### Approach B: Generalize `table` to All FO Temporal Connectives

Reynolds' insight is that U and S are FO-expressible. The same is true for G, H, F, P, and even
the Prior-UZ derived connectives. A fully general `table` that handles the entire formula syntax
(including box via some modal translation) would be more reusable for future tasks (e.g.,
task 127 time-addition operator, task 128 open-set operator).

However, this would require extending `MonadicFormula` to handle the modal box operator, which
currently has no FO analog in purely linear temporal logic. The S5 modal component of BX cannot
be translated into monadic FO over the linear order alone -- it would need a second sort for
worlds. This generalization is out of scope.

**Narrower opportunity**: The `table` function could be structured to make future extension easy
by separating the "translate temporal operator" case from the "translate modality" case, even
if the modal case currently returns a placeholder.

### Approach C: `table_correctness` as a Semantic Tautology

If `MonadicStructure` is defined precisely as "the first-order reduct of a temporal structure,"
then `table_correctness` becomes essentially definitional -- the table translation is defined
precisely so that it is equivalent. In this case, the proof might be trivially by `rfl` or
`simp [table, eval]` after the right definitions are put in place.

Reynolds' construction relies on this definitional identity. The challenge in Lean is ensuring
that the `eval` function for `MonadicFormula` unfolds in sync with the temporal truth definition.
If both are defined by structural induction in the same way, `simp` with the appropriate lemmas
should handle each case.

This suggests that `table_correctness` may be much shorter than expected -- perhaps 50-100 lines
with `simp` automation handling most cases.

### Approach D: Bypass `sum_preservation` via Direct Z-Embedding

The `very_good_implies_good` proof (Reynolds Lemma 16) uses `sum_preservation` to assemble the
Z-interval from the (~M)-class structure. However, for the specific case of the chronicle
(countable, discrete, no endpoints, Prior-UZ/SZ), there may be a more direct construction.

The one-class theorem (`one_class`) says all points are contemporaneously equivalent in the
chronicle. This means the entire chronicle is in one class. A single-class structure is
trivially "very good" (every subinterval is in one class, which is finite by discreteness,
which is good by `finite_structures_good`). One might argue that `very_good_implies_good` for
a single-class structure does not need the full `sum_preservation` -- it only needs to realize
the one k-type in some Z-interval.

**Potential path**: Specialize `very_good_implies_good` to the single-class case, where the
Z-interval realization is simpler (just find a Z-interval with the same k-type as any single
point). This might avoid `sum_preservation` entirely for the chronicle case.

However, `finite_structures_good` is also sorried (requires Doets Theorem 1.1). So the
path single-class → finite subintervals → `finite_structures_good` → good is also blocked.

This suggests task 143 (Doets Lemma 1.1 normal form KType redesign) is more critical for
unblocking the pipeline than initially appreciated. Task 143 may need to land before
`doets_countermodel_discrete` can route through Reynolds.

Confidence: MEDIUM (the single-class specialization idea is worth exploring).

---

## Summary Assessment: Sorry Reduction Achievable in Task 140

| Sorry | Location | Achievable in Task 140? | Confidence |
|-------|----------|------------------------|------------|
| `table` | Table.lean:66 | YES -- implement by induction | HIGH |
| `table_depth_bound` | Table.lean:80 | YES -- follows from table | HIGH |
| Chronicle fallback replacement | Transfer.lean | BLOCKED by sum_preservation | HIGH |
| `succ_cofinal` elimination | (via Reynolds wiring) | BLOCKED by sum_preservation | HIGH |

**Net sorry reduction achievable in task 140**: 2 sorries (table, table_depth_bound).

The `chronicle_is_good` and Reynolds pipeline activation require `sum_preservation` (task 143+
or a separate task for EF-game formalization). The task description's "eliminate succ_cofinal
from the axiom set" goal is not achievable in one task given current state.

**Recommended scoping for task 140**: 
1. Implement `table` (the translation function itself)
2. Prove `table_depth_bound`
3. State and prove `table_correctness` (the semantic preservation theorem)
4. Update Transfer.lean to partially activate the pipeline (fill in the `table`-using steps
   while leaving the `chronicle_is_good` step as a comment/sorry with explicit blocker note)
5. Do NOT claim `succ_cofinal` elimination until `sum_preservation` lands

This is an honest, achievable 8-12 hour task that delivers real value and sets up the pipeline
to be fully activated once task 143 (or a new task for sum_preservation) completes.

---

## Confidence Summary

| Finding | Confidence |
|---------|------------|
| `table` is implementable in task 140 (2-3h) | HIGH |
| `table_depth_bound` follows immediately from `table` (1h) | HIGH |
| `table_correctness` proof is ~50-100 lines, definitional nature | MEDIUM-HIGH |
| Full Reynolds pipeline wiring is blocked by `sum_preservation` | HIGH |
| Task 141 is independent of task 140 | HIGH |
| Task 142 can be researched independently of task 140 | MEDIUM |
| Task 143 (Doets Lemma 1.1) is needed before full pipeline activation | HIGH |
| Reynolds 1994 Section 6 directly specifies `table` implementation | HIGH |
| `mkSigFrom`/`mkAtomMap` need redesign (current stubs are wrong) | HIGH |
| Single-class specialization might bypass `sum_preservation` for chronicle case | MEDIUM |
