# Teammate A Findings: Truth Lemma Completeness Audit

**Task**: #86 - Close BXCanonical completeness sorries
**Focus**: Can we state and prove fragment completeness for {bot, imp, box, G, H}?
**Date**: 2026-04-08

## 1. Truth Lemma Case-by-Case Status

### TruthLemma.lean — Full File Audit

| Constructor | Theorem | Sorry-free? | Dependencies |
|-------------|---------|-------------|--------------|
| `bot` | `bot_not_in_mcs` (L61) | YES | MCS consistency only |
| `imp` | `imp_iff_mcs` (L74) | YES | MCS implication property, negation completeness, deduction theorem |
| `box` | `box_iff_mcs` (L150) | YES | `bx_modal_equiv`, `bx_modal_witness`, MCS properties, S5 axioms |
| `all_future (G)` | `G_iff_mcs` (L124) | YES | `bx_G_forward`, `bx_G_backward` |
| `all_past (H)` | `H_iff_mcs` (L137) | YES | `bx_H_forward`, `bx_H_backward` |
| `untl (U)` | `until_iff_mcs` (L281) | SORRY (transitive) | `bx_until_eventuality_resolution` (sorry), `bx_until_backward` (sorry) |
| `snce (S)` | `since_iff_mcs` (L315) | SORRY (transitive) | `bx_since_eventuality_resolution` (sorry), `bx_since_backward` (sorry) |

**Verdict**: The truth lemma for {bot, imp, box, G, H} is COMPLETELY proved with NO sorry dependencies.

### Atom Case

There is no separate `atom_iff_mcs` theorem in TruthLemma.lean. The atom case would be handled directly in the model embedding (canonical valuation). The comment at line 18 says "atom: By definition of canonical valuation." This means the atom truth lemma is deferred to the model embedding step, not proved as a standalone theorem here.

## 2. Frame.lean Dependency Analysis

### Sorry-Free Theorems (used by G/H/Box truth lemma)

| Theorem | Lines | Status | Used by |
|---------|-------|--------|---------|
| `bx_le_refl` | 140 | sorry-free | G_iff_mcs, H_iff_mcs, until_iff_mcs |
| `bx_le_trans` | 153 | sorry-free | (general infrastructure) |
| `bx_G_forward` | 192 | sorry-free | G_iff_mcs forward direction |
| `bx_G_backward` | 208 | sorry-free | G_iff_mcs backward direction |
| `bx_H_forward` | 266 | sorry-free | H_iff_mcs forward direction |
| `bx_H_backward` | 277 | sorry-free | H_iff_mcs backward direction |
| `bx_modal_equiv_refl` | 332 | sorry-free | (modal infrastructure) |
| `bx_modal_equiv_symm` | 335 | sorry-free | (modal infrastructure) |
| `bx_modal_equiv_trans` | 339 | sorry-free | (modal infrastructure) |
| `bx_modal_witness` | 358 | sorry-free | box_iff_mcs backward direction |
| `bx_forward_witness` | 164 | sorry-free | (general temporal infrastructure) |
| `bx_backward_witness` | 176 | sorry-free | (general temporal infrastructure) |
| `g_content_closed_derivation` | 79 | sorry-free | bx_G_backward |
| `h_content_closed_derivation` | 101 | sorry-free | bx_H_backward |
| `g_content_set_consistent` | 122 | sorry-free | bx_G_backward |

### Sorry'd Theorems (ALL Until/Since-specific)

| Theorem | Lines | Status |
|---------|-------|--------|
| `bx_until_eventuality_resolution` | 541-562 | sorry |
| `bx_until_backward` | 573-584 | sorry |
| `bx_since_eventuality_resolution` | 592-599 | sorry |
| `bx_since_backward` | 606-613 | sorry |

**Critical finding**: The G/H/Box truth lemma cases have ZERO dependency on the Until/Since sorry sites. The dependency graph is completely clean:

```
G_iff_mcs
  -> bx_G_forward (sorry-free)
  -> bx_G_backward (sorry-free)
     -> g_content_closed_derivation (sorry-free)
     -> set_lindenbaum (sorry-free, from Core)

H_iff_mcs
  -> bx_H_forward (sorry-free)
     -> g_content_subset_implies_h_content_reverse (sorry-free, from Bundle)
  -> bx_H_backward (sorry-free)
     -> h_content_closed_derivation (sorry-free)
     -> set_lindenbaum (sorry-free)

box_iff_mcs
  -> bx_modal_witness (sorry-free)
     -> set_lindenbaum (sorry-free)
     -> S5 axioms (modal_4, modal_5_collapse, modal_t) (sorry-free)
  -> MCS properties (sorry-free)
```

### Transitive Import Check

Frame.lean imports:
- `Bimodal.Metalogic.Core.MaximalConsistent` -- sorry-free
- `Bimodal.Metalogic.Core.MCSProperties` -- sorry-free
- `Bimodal.Metalogic.Bundle.TemporalContent` -- sorry-free
- `Bimodal.Metalogic.Bundle.WitnessSeed` -- sorry-free
- `Bimodal.Metalogic.Bundle.CanonicalFrame` -- sorry-free
- `Bimodal.Syntax.Formula` -- sorry-free
- `Bimodal.Theorems.GeneralizedNecessitation` -- sorry-free

The one sorry in Bundle (SuccRelation.lean line 548) is NOT imported by Frame.lean and NOT in the dependency chain.

## 3. Completeness.lean Analysis

### Current sorry (line 144)

The proof reaches this state:
```
h_valid : valid φ
h_not_in : φ ∉ M          -- where M is an MCS containing ¬φ
```

It needs: Build a canonical TaskModel where the truth lemma connects MCS membership to semantic truth, then use `h_valid` to derive `φ ∈ M`, contradicting `h_not_in`.

### What the Model Embedding Requires

The sorry decomposes into these sub-obligations:

1. **Time domain choice**: Pick a type `D` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`. (E.g., `Int` or `Rat`.)

2. **TaskFrame construction**: Build `F : TaskFrame D` with states corresponding to BXPoints (or some encoding).

3. **WorldHistory construction**: For each BXPoint, construct a `WorldHistory F` such that:
   - The temporal ordering on histories matches `bx_le` on BXPoints
   - Modal equivalence on histories matches `bx_modal_equiv` on BXPoints

4. **Omega construction**: Define `Omega : Set (WorldHistory F)` that is `ShiftClosed` and contains a history for each BXPoint.

5. **Valuation**: Define `M.valuation` so that atoms in an MCS are true at the corresponding world-time.

6. **Truth lemma bridge**: Prove that for the constructed model:
   ```
   truth_at M Omega τ_w t φ ↔ φ ∈ w.formulas
   ```
   for all formula constructors.

### Fragment vs Full Decomposition

Sub-obligations 1-5 are **common** to both fragment and full completeness. They don't depend on Until/Since at all -- they're about building the model.

Sub-obligation 6 (truth lemma bridge) decomposes by constructor:
- **bot, imp**: Trivial (structural).
- **atom**: Depends on valuation definition (sub-obligation 5). Fragment-specific, no Until/Since needed.
- **box**: Needs modal equivalence correspondence (sub-obligation 3b). The MCS-level theorem `box_iff_mcs` is sorry-free, but we need to show the embedding preserves modal structure. No Until/Since dependency.
- **G, H**: Needs temporal ordering correspondence (sub-obligation 3a). The MCS-level theorems `G_iff_mcs` and `H_iff_mcs` are sorry-free, but we need the embedding to preserve temporal ordering. No Until/Since dependency.
- **U, S**: Needs temporal ordering correspondence PLUS linearity/density properties. This is where the Until/Since sorries bite.

**Therefore**: Fragment completeness can be stated and proved by building the canonical model embedding (sub-obligations 1-5) and proving the truth lemma bridge for {bot, imp, atom, box, G, H} only. The Until/Since cases can be left as separate sorries or future work.

## 4. The `valid` Definition

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

This quantifies over ALL formulas -- it does not restrict to the fragment. For fragment completeness, we have two design options:

### Option A: Restrict the formula, keep `valid`
```lean
def UntilSinceFree : Formula → Prop
  | .atom _ => True
  | .bot => True
  | .imp φ ψ => UntilSinceFree φ ∧ UntilSinceFree ψ
  | .box φ => UntilSinceFree φ
  | .all_past φ => UntilSinceFree φ
  | .all_future φ => UntilSinceFree φ
  | .untl _ _ => False
  | .snce _ _ => False

theorem fragment_completeness (φ : Formula) (h_frag : UntilSinceFree φ) :
    valid φ → Nonempty (DerivationTree [] φ)
```

### Option B: No restriction needed
Since `valid φ` quantifies over ALL models, and the proof is by contrapositive (build ONE countermodel), the fragment restriction matters only for the truth lemma bridge in the countermodel. If `φ` is Until/Since-free, then `truth_at` for `φ` never touches the `untl`/`snce` cases. So the proof of the truth lemma bridge is automatically restricted.

**Recommendation**: Option A is cleanest. Define `UntilSinceFree` as a decidable predicate and state fragment completeness. No predicate like this currently exists in the codebase.

### Why `valid` Doesn't Need to Change

The key insight: `valid φ` doesn't change based on fragment membership. If `φ` has no Until/Since, its truth is determined solely by {bot, imp, box, G, H, atom} cases of `truth_at`. The canonical model only needs to get those cases right to refute validity. The Until/Since rows of `truth_at` are simply never evaluated.

## 5. Canonical Model Embedding Analysis (Sorry #5)

The canonical model embedding (sorry at Completeness.lean:144) breaks into:

### Sub-obligation 1: Time Domain
**Difficulty**: Low. Use `Int` (or even a custom type indexing BXPoints along a chain).
**Fragment-specific**: No.

### Sub-obligation 2: TaskFrame
**Difficulty**: Medium. Need states, and the frame structure.
**Fragment-specific**: No.

### Sub-obligation 3: WorldHistory + Ordering Correspondence
**Difficulty**: HIGH. This is the crux.
- 3a (temporal): Need `bx_le w v ↔ (time of w ≤ time of v)` in the model. This requires embedding BXPoints into a linear order.
- 3b (modal): Need `bx_modal_equiv w v ↔ (w and v are in the same Omega)`. This requires partitioning BXPoints by modal equivalence classes.
**Fragment-specific**: No -- same embedding needed regardless.

### Sub-obligation 4: ShiftClosed Omega
**Difficulty**: Medium. Depends on how WorldHistories are constructed.
**Fragment-specific**: No.

### Sub-obligation 5: Valuation
**Difficulty**: Low. `M.valuation s p ↔ atom p ∈ (MCS corresponding to s)`.
**Fragment-specific**: No.

### Sub-obligation 6: Truth Lemma Bridge
**Difficulty**: Medium for fragment, HIGH for full (Until/Since).
- For fragment: Structural induction on Until/Since-free formulas. Each case already proved at MCS level.
- For full: Requires solving the Until/Since eventuality resolution.
**Fragment-specific**: YES -- this is where fragment completeness wins.

### Summary of Effort

| Sub-obligation | Difficulty | Fragment-specific? |
|----------------|-----------|-------------------|
| Time domain | Low | No |
| TaskFrame | Medium | No |
| WorldHistory + ordering | HIGH | No |
| ShiftClosed Omega | Medium | No |
| Valuation | Low | No |
| Truth lemma bridge (fragment) | Medium | YES (advantage) |
| Truth lemma bridge (Until/Since) | Blocked | N/A |

**Key insight**: The hardest part (sub-obligations 1-5) is SHARED between fragment and full completeness. Fragment completeness buys us a clean stopping point where we can close off the {bot, imp, atom, box, G, H} truth lemma bridge without solving the Until/Since problem, but we still need to do all the model embedding work.

## 6. Feasibility Assessment

### Can fragment completeness be proved now?

**Yes, in principle.** The MCS-level truth lemma is fully proved for {bot, imp, box, G, H}. What remains is:

1. Define `UntilSinceFree` predicate (trivial, ~20 lines)
2. Build canonical model embedding (substantial, ~300-500 lines)
3. Prove truth lemma bridge for fragment cases only (moderate, ~100-200 lines, using already-proved MCS theorems)
4. State and prove `fragment_completeness` (short, ~30 lines, uses contrapositive + Lindenbaum + truth lemma)

### What is the hardest part?

The canonical model embedding (item 2). This requires:
- Choosing a representation for the time domain
- Embedding BXPoints as states in WorldHistories
- Ensuring `bx_le` corresponds to temporal ordering
- Ensuring `bx_modal_equiv` corresponds to being in the same admissible set
- Proving `ShiftClosed` for the constructed Omega

This is genuinely nontrivial and is the SAME work needed for full completeness. Fragment completeness doesn't simplify this part at all.

### What does fragment completeness BUY us?

1. A clean theorem statement that documents what IS proved
2. Avoidance of the Until/Since eventuality resolution problem
3. A checkpoint: the model embedding can be tested against fragment cases before tackling Until/Since
4. Incremental progress: full completeness later only needs to extend the truth lemma bridge

### Risks

1. The model embedding might be designed in a way that doesn't extend to Until/Since later. Careful design needed.
2. The `UntilSinceFree` restriction propagates through the proof -- need to ensure structural induction works cleanly with this predicate.
3. `ShiftClosed` might impose constraints that interact with Until/Since semantics in unexpected ways.

## 7. Recommended Approach

### Phase 1: Define Fragment Infrastructure (~1 hour)
- Define `UntilSinceFree : Formula → Prop` (decidable, recursive)
- State `fragment_completeness` theorem
- Prove structural lemma: if `UntilSinceFree φ`, then `truth_at` doesn't depend on Until/Since model properties

### Phase 2: Canonical Model Embedding (~4-8 hours)
- Choose time domain (suggest `Int` for simplicity)
- Build canonical TaskFrame with BXPoints as states
- Construct WorldHistories from BXPoint chains
- Define Omega and prove ShiftClosed
- Define canonical valuation

### Phase 3: Fragment Truth Lemma Bridge (~2-4 hours)
- Prove bridge for each constructor in {atom, bot, imp, box, G, H}
- Each case leverages the already-proved MCS theorems
- Restricted induction on `UntilSinceFree` formulas

### Phase 4: Close Fragment Completeness (~1 hour)
- Wire together: Lindenbaum + model embedding + truth lemma bridge
- Close the sorry in `fragment_completeness`

### Alternative: Refactor `bx_completeness` itself
Instead of a separate theorem, refactor the sorry at line 144 into:
```lean
-- The model embedding (shared infrastructure)
sorry -- sub-obligations 1-5
-- The truth lemma bridge (fragment-only for now)
sorry -- sub-obligation 6, will be closed for fragment
```
This makes the structure visible without a separate theorem.
