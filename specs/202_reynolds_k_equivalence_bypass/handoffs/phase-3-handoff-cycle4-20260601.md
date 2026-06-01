# Phase 3 Handoff: Task 202 (Cycle 4)

## Session
sess_1780325631_z4lda

## Current State
Phase 3 is PARTIAL. New infrastructure added in cycle 4:

### New Infrastructure (this cycle)

1. **contemp_eq_body : MonadicFormula sig 2** -- Encodes contemp_equiv(var 0, var 1) using
   ∀d ∀c guard → good_rel_lifted. The key innovation: binding ∀d FIRST (then ∀c) puts
   c at var 0 and d at var 1, matching good_rel_lifted's convention (lo=var0, hi=var1).

2. **contemp_eq_body_correct** -- SORRY: the correctness proof requires reducing nested
   Fin.cons lookups at De Bruijn indices. The semantic content is correct but Lean's
   tactic layer needs explicit guidance for `Fin.cons a (Fin.cons b ...) ⟨2, _⟩ = c`.
   A utility lemma that normalizes Fin.cons lookups would resolve this.

3. **spread_formula : MonadicFormula sig 1** -- Encodes "∃ y ~M x, A(y)" using
   .ex (.and contemp_eq_body ((table A).lift 1)). This is the key formula for class_spread.

4. **class_spread** -- PROVED (modulo contemp_eq_body_correct sorry). For any temporal
   formula A, if A holds at s, then for any t, ∃ t' ~M t, A(t'). The proof constructs
   spread_formula, proves it's contemp_equiv-invariant, applies invariant_formula_constant,
   and derives existence or contradiction.

### Remaining Blockers (2 sorry sites)

#### Sorry 1: contemp_eq_body_correct (Fin.cons bookkeeping)
- **What failed**: The correctness proof for contemp_eq_body reduces to showing
  `Fin.cons c (Fin.cons d (Fin.cons x (Fin.cons y Fin.elim0))) ⟨2, _⟩ = x` etc.
  Lean's tactic layer (simp, dsimp) doesn't reduce these Fin.cons lookups.
- **What was tried**: simp with eval_*, Fin.cons_zero/succ, dsimp, show/change.
- **Why stuck**: Fin.cons is defined via Fin.cases, and `⟨2, _⟩` is not in the
  canonical `Fin.succ (Fin.succ ⟨0, _⟩)` form that triggers Fin.cons_succ.
- **What is needed**: A utility lemma or simp extension that reduces
  `Fin.cons a f ⟨n, h⟩` for concrete n. Or use `native_decide` / `Decidable` instances.

#### Sorry 2: gap_prior_UZ_contradiction (truth preservation + final contradiction)
- **What failed**: The forward direction of truth preservation for Until/Since when the
  witness is outside class(a) requires "ordered spread" -- showing B₁ holds ABOVE t
  in class(a), not just somewhere in class(a).
- **What was tried**: class_spread gives B₁ somewhere in class(a) but doesn't guarantee
  it's above t. Multiple attempts to use class_spread recursively with temporal formulas
  like U(B₁, ⊤) failed because they give witnesses at arbitrary positions.
- **Why stuck**: class_spread gives UNORDERED spread; the ORDERED spread (cofinality)
  requires Reynolds Lemma 11 (density) which depends on k-equivalence of all classes.
  Proving k-equivalence of classes requires showing eval on class substructures agrees
  for all MonadicSentences, which can't be directly expressed as a sig 1 invariant formula.
- **What is needed**: Either (a) prove k-equivalence of classes via the normal form
  machinery + doets_lemma_1_4 and derive the contradiction from contemp_equiv a y directly,
  bypassing truth preservation; or (b) formalize Reynolds Lemma 11 (density/cofinality)
  to get ordered spread, enabling truth preservation.

## Key Decisions
1. contemp_eq_body uses ∀d∀c (not ∀c∀d) to align De Bruijn indices with good_rel_lifted.
2. class_spread uses spread_formula + invariant_formula_constant (not k-type arguments).
3. Truth preservation approach is blocked on ordered spread; may need to switch to
   direct k-equivalence of classes approach for the final contradiction.

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
  - Lines ~1000-1070: New definitions (contemp_eq_body, spread_formula, contemp_eq_body_correct)
  - Lines ~1330-1395: class_spread proof (sorry-free modulo contemp_eq_body_correct)
  - Lines ~1395-1415: Truth preservation + contradiction (sorry)

## Next Action
Fix contemp_eq_body_correct (Fin.cons bookkeeping) first, then either:
(a) Prove k-equivalence of all classes → contemp_equiv a y → contradiction, OR
(b) Formalize Reynolds Lemma 11 (density) → ordered spread → truth preservation.
