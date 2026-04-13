# Teammate A: Primary Strategy Deep Dive

## Key Findings

1. **BXPoint and ParametricCanonicalWorldState are structurally identical**: `BXPoint` wraps `(formulas : Set Formula, is_mcs : SetMaximalConsistent formulas)` while `ParametricCanonicalWorldState` is `{ M : Set Formula // SetMaximalConsistent M }`. The bridge is a trivial coercion `fun w => ⟨w.formulas, w.is_mcs⟩`, and `bx_le w v` is definitionally `ExistsTask w.formulas v.formulas` (both mean `g_content w.formulas ⊆ v.formulas`).

2. **The guard interval trick for Until coherence is the critical simplification for D=Int**: When D=Int, to satisfy `forward_until_since_coherent` for `phi U psi in fam.mcs t`, we need `s >= t` with `psi in fam.mcs s` and `phi in fam.mcs r` for all `t <= r < s`. If `s = t` (psi already in fam.mcs t), the guard is vacuous. If `s = t+1`, the guard requires only `phi in fam.mcs t` (since the only integer r with `t <= r < t+1` is r=t). BX9 gives `phi in w` when `phi U psi in w` and `psi notin w`. This means 2-element chains suffice for Until.

3. **For dense D (e.g., Rat), the guard interval trick FAILS**: Between t and t+epsilon there are infinitely many rationals. The guard `phi in fam.mcs r` for all `t <= r < s` requires phi membership at uncountably many intermediate MCS values. This fundamentally changes the construction: you need a continuous/monotone chain where phi persists through intermediate steps. This is a qualitatively harder problem.

4. **The existing dovetailed chain in Boneyard is deprecated and architecturally blocked**: All 6 sorries stem from an X-vs-G mismatch where Until formulas don't propagate through g_content-based chain steps. However, its overall architecture (fair scheduling via `Nat.unpair` + `Denumerable Formula`, forward/backward chain construction) provides a useful template.

5. **Full temporal coherence (forward_F/backward_P for ALL formulas) is achievable for D=Int with the BXCanonical witnesses**: `bx_forward_witness` gives `F(psi) in w => exists v >= w, psi in v`, and `bx_backward_witness` gives the past dual. These are exactly what forward_F and backward_P need. The dovetailed chain ensures ALL F/P obligations are eventually resolved.

6. **The BFMCS construction from BXPoints is more natural than previously realized**: Modal saturation (adding Diamond witness families) uses `bx_modal_witness` which produces modally equivalent BXPoints. The `box_preserved_along_bx_le` theorem ensures Box formulas are invariant along chains, so modal coherence within a single chain is automatic.

## Discrete vs Dense Analysis

### D = Int (Discrete)

**FMCS Construction**: Dovetailed chain from starting BXPoint w0.
- Forward chain: At step n, use `Nat.unpair n = (i, j)` to target formula `Denumerable.ofNat j` at position `i`. If `F(phi_j) in chain(i)`, use `bx_forward_witness` to extend.
- Backward chain: Symmetric using `bx_backward_witness`.
- Chain is monotone in bx_le (forward) and reverse-monotone (backward).

**forward_G**: If `G(phi) in fam.mcs t` and `t <= t'`, then by transitivity of `bx_le` along the chain, `phi in fam.mcs t'`. This uses `bx_le_trans` and the fact that each chain step preserves bx_le.

**backward_H**: Symmetric, using h_content duality.

**forward_F** (the hard one): If `F(psi) in fam.mcs t`, eventually the dovetailing schedule targets `(t, psi_index)`, producing s > t with `psi in fam.mcs s`. The witness exists because `bx_forward_witness` guarantees it. The challenge is proving the dovetailing eventually reaches every (position, formula) pair -- this follows from surjectivity of `Nat.unpair`.

**backward_P**: Symmetric to forward_F.

**Until forward coherence**: Given `phi U psi in fam.mcs t`:
- Case 1: `psi in fam.mcs t`. Take `s = t`. Guard `{r : t <= r < t}` is empty, so vacuously satisfied. Done.
- Case 2: `psi notin fam.mcs t`. By BX10 (`until_F`), `F(psi) in fam.mcs t`. The dovetailed chain eventually resolves this at some `s > t` with `psi in fam.mcs s`.
  - **Guard obligation**: Need `phi in fam.mcs r` for all `t <= r < s`.
  - **Key insight for Int**: We can place the witness at `s = t + 1`. Then the guard is just `{r : t <= r < t+1}` which for integers is only `{t}`. By BX9 (`until_elim`), `phi in fam.mcs t` (since `phi U psi in fam.mcs t` and `psi notin fam.mcs t`). DONE.
  - **But this requires control over where psi appears**: The dovetailed chain doesn't guarantee psi appears at t+1 specifically -- it only guarantees psi appears eventually. To get psi at t+1, we need to modify the chain construction so that Until obligations are resolved at the NEXT step, not at some arbitrary future step.

**Refined Int construction**: Instead of pure F-obligation dovetailing, use a priority system:
1. At each step n+1 from position n, first check for Until obligations at n
2. If `phi U psi in fam.mcs n` and `psi notin fam.mcs n`, resolve psi at n+1 specifically
3. Otherwise fall back to standard F-dovetailing

This ensures the guard is always satisfied with a single-step gap (vacuous guard for Int).

### D = Rat (Dense)

**The fundamental problem**: For `phi U psi in fam.mcs t` with witness at `s > t`, the guard requires `phi in fam.mcs r` for ALL rationals `r in [t, s)`. But the chain has only countably many "construction points" -- at most one per rational. Ensuring phi at ALL intermediate rationals requires that phi is in the MCS at every chain position between t and s.

**What goes wrong**: Each chain step uses Lindenbaum extension, which introduces freedom. There is no guarantee that a Lindenbaum extension at some intermediate rational r will contain phi, unless we specifically seed it with phi. But seeding with phi at every intermediate step means infinitely many seeding obligations before reaching s.

**Approaches for dense D**:
1. **Restricted coherence**: Use `restricted_forward_until_since_coherent` which only requires Until coherence for subformulas of the root formula. This bounds the obligation set.
2. **Interval filling**: For each Until obligation, construct a sub-chain that explicitly maintains phi at all intermediate positions. This requires showing that `{phi} union g_content(fam.mcs t)` is consistent for each intermediate step.
3. **Dense chain with Until-aware construction**: Build chains where Until obligations dictate the intermediate MCS structure. This is closer to Burgess 1984's original construction.

**Assessment**: Dense completeness requires a fundamentally different chain construction. It is NOT a simple parametric generalization of the Int case. Recommend focusing on D=Int first.

### Typeclass Constraints for Abstract D

A `TemporalDomain D` typeclass would need:
```
class TemporalDomain (D : Type*) extends AddCommGroup D, LinearOrder D, IsOrderedAddMonoid D where
  -- For Until guard trick: adjacent elements have no intermediate elements
  -- This is exactly what SuccOrder provides for discrete orders
```

For base TM completeness: `AddCommGroup D + LinearOrder D + IsOrderedAddMonoid D` suffices, and D=Int is instantiated.

For the guard interval trick: need `SuccOrder D` (no element between t and succ t). This IS Int but NOT Rat.

**Conclusion**: Abstracting over D is possible for the frame/model infrastructure (already done in ParametricCanonical), but the BFMCS construction is inherently D-specific. The chain construction must be specialized to the order-theoretic properties of D.

## Chain Construction Assessment

### Existing Infrastructure (Boneyard)

**DovetailedChain.lean** (deprecated, 6 sorries):
- Architecture: forward_step using `temporal_theory_witness_with_g_exists`, fair scheduling via `Nat.unpair`
- Blocked by: X-vs-G mismatch (Until formulas don't propagate through g_content chain steps)
- Reusable: Fair scheduling pattern, forward/backward chain structure

**UltrafilterChain.lean** (3700+ lines, Boneyard):
- Contains `construct_bfmcs_bundle` which builds a BFMCS from an MCS
- Contains `BundleTemporallyCoherent` proofs
- Working modal saturation via `boxClassFamilies`
- BUT: Uses strict semantics (G quantifies over strict future s > t), while current FMCS uses reflexive semantics (t <= t')

**SuccChainFMCS.lean** (Boneyard):
- Successor-based chain for D=Int
- More structured than dovetailed approach
- Also blocked by strict/reflexive semantics mismatch

### What Can Be Reused

| Component | Source | Reusability |
|-----------|--------|-------------|
| Fair scheduling pattern | DovetailedChain.lean | High -- `Nat.unpair` + `Denumerable` |
| Modal saturation pattern | UltrafilterChain.lean:boxClassFamilies | High -- same Box-equivalence structure |
| `construct_bfmcs_bundle` shape | UltrafilterChain.lean | Medium -- needs adaptation to reflexive semantics |
| Chain step function | DovetailedChain.forward_step | Medium -- replace temporal_theory_witness with bx_forward_witness |
| Bundle temporal coherence | UltrafilterChain.lean | Low -- proofs are for strict semantics |

### New Construction Needed

The new FMCS chain must use BXCanonical witnesses (`bx_forward_witness`, `bx_backward_witness`) which are already proved for reflexive semantics. The chain construction is:

```
chain : Int -> BXPoint
chain 0 = w0
chain (n+1) = resolve_next_obligation (chain n)
chain (-(n+1)) = resolve_next_past_obligation (chain (-n))
```

Where `resolve_next_obligation` uses `bx_forward_witness` and the fair scheduling selects which obligation to resolve. The FMCS is then `fam.mcs t = (chain t).formulas`.

**forward_G proof**: `G(phi) in (chain t).formulas` and `t <= t'` implies `phi in (chain t').formulas`. This follows by induction on `t' - t`:
- Base: t = t', use bx_le_refl
- Step: chain(t') to chain(t'+1) preserves bx_le (by construction), and bx_le is transitive

**forward_F proof**: By surjectivity of `Nat.unpair`, every (position, formula) pair is eventually targeted. So `F(psi) in chain(t).formulas` means at some future step the scheduler targets (t, psi_index), and `bx_forward_witness` produces a chain extension containing psi.

**Estimated lines**: 200-300 for the chain + FMCS construction with all coherence proofs.

## Bridge Analysis

### BXPoint to ParametricCanonicalWorldState

The bridge is trivial:
```lean
def bxpoint_to_pcws (w : BXPoint) : ParametricCanonicalWorldState :=
  ⟨w.formulas, w.is_mcs⟩
```

**Are they definitionally equal?** No -- `BXPoint` is a structure with named fields `formulas` and `is_mcs`, while `ParametricCanonicalWorldState` is a subtype `{ M : Set Formula // SetMaximalConsistent M }`. But the coercion is definitional in the sense that `(bxpoint_to_pcws w).val = w.formulas` holds by `rfl`.

**Propositional equivalence of relations**:
- `bx_le w v` = `g_content w.formulas ⊆ v.formulas` = `ExistsTask w.formulas v.formulas`
- `parametric_canonical_task_rel (bxpoint_to_pcws w) d (bxpoint_to_pcws v)` for `d > 0` = `ExistsTask w.formulas v.formulas`

These are definitionally equal. No transport lemma needed.

**Can we avoid the bridge entirely?** Yes, in two ways:
1. Build the FMCS directly using `Set Formula` (not BXPoint), where `fam.mcs t` is a set of formulas with `fam.is_mcs t` proving MCS. This is what the FMCS structure already expects.
2. Use BXPoint internally for the chain construction, then project to `Set Formula` at the end.

Option 2 is cleaner: build the chain as `chain : Int -> BXPoint` using BXCanonical witnesses, then define `fam.mcs t = (chain t).formulas` and `fam.is_mcs t = (chain t).is_mcs`.

### Bridge in the Completeness Proof

The sorry at `Completeness.lean:154` has:
- `h_valid : valid phi` -- quantifies over ALL D, ALL TaskFrame D, ALL TaskModel, ALL ShiftClosed Omega, ALL histories, ALL times
- `h_not_in : phi notin M` -- where M is an MCS

To close the sorry:
1. Construct BFMCS over Int from M
2. Get `not truth_at (ParametricCanonicalTaskModel Int) Omega (parametric_to_history fam) 0 phi` from `parametric_representation_from_neg_membership`
3. Instantiate `h_valid` at D=Int, F=ParametricCanonicalTaskFrame Int, M_model=ParametricCanonicalTaskModel Int, Omega=ShiftClosedParametricCanonicalOmega B, tau=parametric_to_history fam, t=0
4. This gives `truth_at ... phi` which contradicts step 2.

**Key requirement**: `valid phi` quantifies `D : Type` (universe 0), so D=Int works since `Int : Type`. The parametric canonical frame satisfies all TaskFrame axioms (already proved). ShiftClosed is proved for `ShiftClosedParametricCanonicalOmega`.

**Estimated bridge code**: ~50-100 lines in Completeness.lean to instantiate valid and derive contradiction.

## Elegance and Generality Recommendations

### Recommendation 1: Focus on D=Int, defer dense generality

The Int case is substantially simpler due to the guard interval trick. Dense completeness (D=Rat) requires a fundamentally different chain construction that handles infinite guard intervals. These should be separate tasks.

The parametric infrastructure already supports both -- the split is only in the BFMCS construction (the `construct_bfmcs` callback).

### Recommendation 2: Use BXCanonical witnesses directly, not Boneyard code

The BXCanonical Frame.lean witnesses (`bx_forward_witness`, `bx_backward_witness`, `bx_modal_witness`, `bx_until_eventuality_resolution`, `bx_since_eventuality_resolution`) are all proved and use reflexive semantics. The Boneyard code uses strict semantics and is deprecated. Building fresh on BXCanonical is cleaner than adapting Boneyard code.

### Recommendation 3: Separate FMCS construction from BFMCS bundling

- **Phase 1**: Build `bx_chain : Int -> BXPoint` with dovetailed scheduling
- **Phase 2**: Wrap as `FMCS Int` with forward_G, backward_H, forward_F, backward_P
- **Phase 3**: Build `BFMCS Int` via modal saturation (add Diamond witness families)
- **Phase 4**: Prove backward_until_since_coherent and forward_until_since_coherent
- **Phase 5**: Close the sorry by instantiating `parametric_algebraic_representation_conditional`

### Recommendation 4: Until guard via immediate successor placement

For the Until forward coherence on Int: when `phi U psi in fam.mcs t` and `psi notin fam.mcs t`, modify the chain so that the next step (t+1) is specifically constructed to contain psi (using `bx_forward_witness` with the F(psi) obligation from BX10). The guard is then vacuously satisfied since no integers lie strictly between t and t+1.

This means the chain construction should have a two-tier priority:
1. Until/Since immediate obligations (must be resolved at the next step)
2. F/P dovetailed obligations (resolved eventually by fair scheduling)

### Recommendation 5: Consider whether full or restricted coherence suffices

The `parametric_canonical_truth_lemma` requires full `B.temporally_coherent`, `B.backward_until_since_coherent`, and `B.forward_until_since_coherent`. However, `restricted_forward_until_since_coherent` exists as a weaker alternative (only for subformulas of root).

For completeness, we only need to falsify ONE formula phi. If the truth lemma can be used with restricted coherence, the Until/Since obligation is narrower. Check whether `parametric_shifted_truth_lemma` accepts restricted coherence -- if so, this simplifies the construction.

**Finding**: The current `parametric_shifted_truth_lemma` requires FULL coherence, not restricted. But modifying it to accept restricted coherence for a specific root formula would reduce the Until/Since construction burden from "all formulas" to "subformulas of phi". This is a worthwhile optimization but not strictly necessary for D=Int where the guard trick works.

## Confidence Level

**High confidence** (8/10) that Strategy B with D=Int is achievable:
- All needed witnesses exist and are proved in BXCanonical Frame.lean
- The bridge to parametric infrastructure is trivial
- The guard interval trick eliminates the hardest part of Until coherence for Int
- Estimated 400-600 lines of new code

**Medium confidence** (5/10) on the dovetailed chain forward_F proof:
- The surjectivity argument for Nat.unpair is clean mathematically
- But formalizing "every obligation is eventually resolved" in Lean requires careful bookkeeping
- The Boneyard dovetailed chain had this same structure and its forward_F was sorry'd (though for different reasons -- the X-vs-G mismatch, not the scheduling argument)

**Low confidence** (3/10) on generalizing to dense D:
- The guard interval problem is fundamentally different
- No existing infrastructure handles it
- Should be a separate task

## References

| File | Key Content |
|------|-------------|
| `Metalogic/BXCanonical/Completeness.lean:154` | The sorry to close |
| `Metalogic/BXCanonical/Frame.lean:164-186` | `bx_forward_witness`, `bx_backward_witness` |
| `Metalogic/BXCanonical/Frame.lean:358-499` | `bx_modal_witness` with full S5 modal equivalence |
| `Metalogic/BXCanonical/Frame.lean:538` | `box_preserved_along_bx_le` |
| `Metalogic/BXCanonical/Frame.lean:623-671` | Until/Since eventuality resolution |
| `Metalogic/Algebraic/ParametricCanonical.lean:62-88` | `ParametricCanonicalWorldState`, task relation |
| `Metalogic/Algebraic/ParametricRepresentation.lean:254-269` | `parametric_algebraic_representation_conditional` |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | Truth lemma requiring temporal + Until/Since coherence |
| `Metalogic/Bundle/FMCSDef.lean:99-117` | FMCS structure (reflexive: `t <= t'`) |
| `Metalogic/Bundle/BFMCS.lean:84-116` | BFMCS structure with modal coherence |
| `Metalogic/Bundle/TemporalCoherence.lean:147-153` | TemporalCoherentFamily (strict: `t < s`) |
| `Metalogic/Bundle/TemporalCoherence.lean:265-268` | BFMCS.temporally_coherent (strict: `t < s`) |
| `Metalogic/Bundle/TemporalCoherence.lean:503-525` | backward/forward Until/Since coherence |
| `Semantics/Validity.lean:73-76` | `valid` quantifies over `D : Type` |
| `Semantics/Truth.lean:120-131` | `truth_at` definition including Until/Since |
| `Boneyard/StrictSemanticsLegacy/Algebraic/DovetailedChain.lean` | Deprecated chain (template only) |
