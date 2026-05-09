# Teammate C Findings: FMCS/BFMCS on ℤ Construction

**Task**: 117 — Round 3: Concrete construction of FMCS/BFMCS on ℤ via discrete limit domain embedding
**Date**: 2026-05-08
**Focus**: How to replace D=Rat with D=Int, using an order iso X ≅ ℤ instead of Cantor iso X ≅ ℚ

## Key Findings

### 1. The Cantor → ℤ Swap Is Structurally Mechanical

The coherence proofs in ChronicleToCountermodel.lean (`cantor_bfmcs_restricted_tc`, `_buc`, `_fuc`) use `cantor_iso` ONLY through:
- `cantor_iso.symm.strictMono` — strict monotonicity of the inverse iso
- `OrderIso.apply_symm_apply` — round-trip cancellation
- `OrderIso.symm_apply_apply` — reverse round-trip

**`DenselyOrdered` appears ONLY in**:
- `limitDomSubtype_denselyOrdered` instance (line 98-104) — used only by `cantor_iso`
- `cantor_iso` definition (line 189-192) — calls `Order.iso_of_countable_dense`

None of the coherence proofs reference `DenselyOrdered`, density, or any density-specific property. They are purely iso-transfer proofs. Replacing `cantor_iso : LimitDomSubtype ≃o Rat` with `discrete_iso : LimitDomSubtype ≃o Int` produces identical proof structure.

### 2. Mathlib Provides `orderIsoIntOfLinearSuccPredArch`

Mathlib provides the discrete analogue of `Order.iso_of_countable_dense`:

```
orderIsoIntOfLinearSuccPredArch :
  {ι : Type} → [LinearOrder ι] → [SuccOrder ι] → [PredOrder ι] →
  [IsSuccArchimedean ι] → [NoMaxOrder ι] → [NoMinOrder ι] → [Nonempty ι] → ι ≃o ℤ
```

From `Mathlib.Order.SuccPred.LinearLocallyFinite`.

**Required instances on LimitDomSubtype (without density case)**:
- `LinearOrder` ✓ — inherited from Rat subtype
- `SuccOrder` — NEEDS PROOF: every non-max element has an immediate successor in limit_dom
- `PredOrder` — NEEDS PROOF: every non-min element has an immediate predecessor
- `IsSuccArchimedean` — NEEDS PROOF: any two elements connected by finite succ steps
- `NoMaxOrder` ✓ — already proved (`limitDomSubtype_noMaxOrder`)
- `NoMinOrder` ✓ — already proved (`limitDomSubtype_noMinOrder`)
- `Nonempty` ✓ — already proved (`limitDomSubtype_nonempty`)

### 3. LimitDomSubtype IS Discrete Without Density Case

Without the `.density` counterexample kind, the omega chain construction inserts points only for C4a/C4b/C5a/C5b counterexamples. Each finite-stage chronicle has a finite domain (Finset). In the limit, X = ⋃ dom f_n is countable.

**Crucially**: Without density elimination, adjacent pairs (x, y) in the limit domain CAN persist — there exist pairs x < y in X with no z ∈ X satisfying x < z < y. This means X is NOT dense, hence the Cantor iso is unavailable.

**But X IS discrete**: For any x ∈ X, since X ⊂ ℚ and X is countable, the set {y ∈ X | x < y} is non-empty (by `limit_dom_no_max`) and well-ordered as a subset of ℚ. Its minimum is the successor of x. Similarly for predecessors. So `SuccOrder` and `PredOrder` can be constructed.

**For `IsSuccArchimedean`**: Any two points x < y in X have finitely many points between them (since they're both rational and the domain grows by inserting finitely many points at each finite stage). So y is reachable from x by finitely many succ steps.

**However**: The proofs of `SuccOrder`, `PredOrder`, and `IsSuccArchimedean` for `LimitDomSubtype` without density need to be formalized. These are non-trivial but mathematically clear.

An alternative: use `LinearLocallyFiniteOrder.succOrder` from Mathlib, which derives `SuccOrder` from `LocallyFiniteOrder`. If we can show `LocallyFiniteOrder LimitDomSubtype`, we get `SuccOrder` for free. This requires showing `Finset.Icc x y` is finite for any x, y ∈ LimitDomSubtype — which follows from X being a countable subset of ℚ with the property that every bounded interval contains finitely many points.

### 4. Chronicle API Used in ChronicleToCountermodel

The countermodel construction uses exactly these limit-construction APIs:

| API | Used In | Needs Density? |
|-----|---------|---------------|
| `limit_f` | cantor_f, all coherence proofs | No |
| `limit_c0` | cantor_f_is_mcs, limit_dom_no_max/no_min | No |
| `limit_f_zero` | cantor_f_at_zero | No |
| `limit_dom` | LimitDomSubtype definition | No |
| `zero_mem_limit_dom` | limitDomSubtype_nonempty, cantor_zero | No |
| `limit_forward_G` | cantor_fmcs.forward_G | No |
| `limit_backward_H` | cantor_fmcs.backward_H | No |
| `limit_F_resolution` | cantor_bfmcs_restricted_tc (F case) | No |
| `limit_P_resolution` | cantor_bfmcs_restricted_tc (P case) | No |
| `limit_satisfies_c4` | cantor_bfmcs_restricted_buc (Until) | No |
| `limit_satisfies_c4'` | cantor_bfmcs_restricted_buc (Since) | No |
| `limit_satisfies_c5_strong` | cantor_bfmcs_restricted_fuc (Until) | No |
| `limit_satisfies_c5'_strong` | cantor_bfmcs_restricted_fuc (Since) | No |
| `limit_dom_dense` | limitDomSubtype_denselyOrdered | **YES — density only** |
| `limit_dom_no_max` | limitDomSubtype_noMaxOrder | No |
| `limit_dom_no_min` | limitDomSubtype_noMinOrder | No |

**Only `limit_dom_dense` needs the density case.** All other APIs are independent. Removing density and `limit_dom_dense` leaves all coherence proof prerequisites intact.

### 5. Concrete Construction: `int_fmcs` / `int_bfmcs`

Given `e : LimitDomSubtype A h_mcs ≃o ℤ` (from `orderIsoIntOfLinearSuccPredArch`):

```lean
-- MCS assignment: every integer maps to an MCS via the inverse iso
noncomputable def int_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (e : LimitDomSubtype A h_mcs ≃o ℤ) : ℤ → Set Formula :=
  fun n => limit_f A h_mcs (e.symm n).val

-- The integer corresponding to 0 in the limit domain
noncomputable def int_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (e : LimitDomSubtype A h_mcs ≃o ℤ) : ℤ :=
  e ⟨0, zero_mem_limit_dom A h_mcs⟩

-- int_f at int_zero = A (root MCS)
theorem int_f_at_zero : int_f A h_mcs e (int_zero A h_mcs e) = A := by
  unfold int_f int_zero; simp [OrderIso.symm_apply_apply]; exact limit_f_zero A h_mcs

-- Every integer maps to an MCS
theorem int_f_is_mcs (n : ℤ) : SetMaximalConsistent (int_f A h_mcs e n) := by
  unfold int_f; exact limit_c0 A h_mcs _ (e.symm n).property

-- FMCS over Int
noncomputable def int_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (e : LimitDomSubtype A h_mcs ≃o ℤ) : FMCS Int where
  mcs := int_f A h_mcs e
  is_mcs := int_f_is_mcs A h_mcs e
  forward_G := by
    intro t t' φ h_lt h_G
    have h_lt_dom := e.symm.strictMono h_lt   -- SAME as cantor_fmcs
    exact limit_forward_G A h_mcs
      (e.symm t).val (e.symm t').val
      (e.symm t).property (e.symm t').property
      h_lt_dom φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_lt_dom := e.symm.strictMono h_lt   -- SAME as cantor_fmcs
    exact limit_backward_H A h_mcs
      (e.symm t).val (e.symm t').val
      (e.symm t).property (e.symm t').property
      h_lt_dom φ h_H

-- Shifted/rooted FMCS (identical structure, Int arithmetic)
noncomputable def shifted_int_fmcs (s : ℤ) : FMCS Int where
  mcs t := (int_fmcs A h_mcs e).mcs (t - s)
  is_mcs t := (int_fmcs A h_mcs e).is_mcs (t - s)
  forward_G t t' φ h_lt h_G := (int_fmcs A h_mcs e).forward_G (t - s) (t' - s) φ
    (by exact sub_lt_sub_right h_lt s) h_G
  backward_H t t' φ h_lt h_H := (int_fmcs A h_mcs e).backward_H (t - s) (t' - s) φ
    (by exact sub_lt_sub_right h_lt s) h_H

noncomputable def rooted_int_fmcs (s : ℤ) : FMCS Int :=
  shifted_int_fmcs A h_mcs e (s - int_zero A h_mcs e)

-- BFMCS over Int (identical structure to cantor_bfmcs)
noncomputable def int_bfmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (e : LimitDomSubtype M₀ h₀ ≃o ℤ) : BFMCS Int where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : ℤ),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = rooted_int_fmcs N h_N eN s }  -- eN = iso for N's chronicle
  -- ... modal_forward, modal_backward identical via box_stable
```

### 6. The Box-Equivalence Issue for `int_bfmcs`

In `cantor_bfmcs`, each box-equivalent MCS N gets its OWN `cantor_iso N h_N`. In `int_bfmcs`, each N would get its OWN `discrete_iso N h_N`. This is fine structurally — each MCS produces its own chronicle with its own limit domain and its own discrete iso. The BFMCS bundles them via box-equivalence, exactly as before.

### 7. Coherence Proofs Transfer Mechanically

Every coherence proof in ChronicleToCountermodel follows this pattern:
1. Unfold the shifted/rooted FMCS to get `limit_f N h_N (iso.symm (t - offset)).val`
2. Extract the `.property` to get domain membership
3. Call a `limit_*` API (limit_F_resolution, limit_satisfies_c4, etc.)
4. Transfer the result back via `iso.strictMono` and `simp [OrderIso.apply_symm_apply]`

Replacing `cantor_iso : LimitDomSubtype ≃o Rat` with `discrete_iso : LimitDomSubtype ≃o Int` changes NOTHING in this pattern. The proofs are parametric over the iso — only its type signature and strict monotonicity matter.

### 8. The `dd_countermodel_chronicle_int` Theorem

```lean
theorem dd_countermodel_chronicle_int (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_neg_in : φ.neg ∈ M) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  -- Int satisfies all required typeclasses:
  -- AddCommGroup Int ✓, LinearOrder Int ✓, IsOrderedAddMonoid Int ✓, Nontrivial Int ✓
  refine ⟨Int, inferInstance, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Int, ParametricCanonicalTaskModel Int,
    ShiftClosedParametricCanonicalOmega (int_bfmcs M h_mcs e),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (rooted_int_fmcs M h_mcs e 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨rooted_int_fmcs M h_mcs e 0,
       ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  -- ... identical proof using fully_restricted_parametric_representation_from_neg_membership
```

### 9. What Needs to Be Done (Archival vs. Removal)

**Archive to Boneyard/ (density-specific code that's correct but not needed for base logic)**:
- `limitDomSubtype_denselyOrdered` instance (lines 98-104) — move to dense variant
- `cantor_iso` definition (lines 189-192) — move to dense variant
- `cantor_f`, `cantor_zero`, `cantor_f_at_zero`, `cantor_f_is_mcs` (lines 203-231) — superseded by `int_f` etc.
- `cantor_fmcs`, `shifted_cantor_fmcs`, `rooted_cantor_fmcs` (lines 243-314) — superseded by int versions
- `box_stable_in_rooted_cantor_fmcs` (lines 325-364) — will need int version
- `cantor_bfmcs` (lines 376-418) — superseded by int_bfmcs
- `cantor_bfmcs_restricted_tc/buc/fuc` (lines 436-663) — will need int versions
- The `.density` case in `PotentialCounterexampleKind` (CE:575) — move to dense variant
- `eliminate_density_counterexample` (CE:530+) — move to dense variant
- `density_witness` field in `EliminationResult` (CE:638-640) — move to dense variant
- The `.density =>` branch in `eliminate_potential_counterexample` (CE:3535+) — move to dense variant
- `limit_dom_dense` in ChronicleConstruction.lean — move to dense variant

**Keep (shared infrastructure)**:
- `LimitDomSubtype` definition (line 82-84) ✓
- `limitDomSubtype_countable` ✓
- `limitDomSubtype_noMaxOrder`, `limitDomSubtype_noMinOrder`, `limitDomSubtype_nonempty` ✓
- `limit_dom_no_max`, `limit_dom_no_min` ✓
- All `limit_*` APIs in ChronicleConstruction.lean (except `limit_dom_dense`)

**New code needed**:
- `SuccOrder LimitDomSubtype` instance (without density)
- `PredOrder LimitDomSubtype` instance
- `IsSuccArchimedean LimitDomSubtype` instance
- `discrete_iso : LimitDomSubtype ≃o ℤ` (from `orderIsoIntOfLinearSuccPredArch`)
- `int_f`, `int_zero`, `int_f_at_zero`, `int_f_is_mcs`
- `int_fmcs`, `shifted_int_fmcs`, `rooted_int_fmcs`
- `box_stable_in_rooted_int_fmcs`
- `int_bfmcs`
- `int_bfmcs_restricted_tc/buc/fuc` (mechanical transfer from cantor versions)
- `dd_countermodel_chronicle` updated to use Int

### 10. Risk: SuccOrder / IsSuccArchimedean on LimitDomSubtype

The main non-mechanical work is proving `SuccOrder` and `IsSuccArchimedean` on `LimitDomSubtype` without density. Two approaches:

**Approach A (direct)**: Define `succ` explicitly as the minimum of {y ∈ X | x < y}. This requires showing the set is non-empty (from `limit_dom_no_max`) and has a minimum. The minimum exists because X ⊂ ℚ and the set is bounded below by x — but ℚ doesn't have well-ordering, so this requires choosing a minimum from a countable set. Use `Nat.find` or well-ordering of ℕ via the enumeration.

**Approach B (via LocallyFiniteOrder)**: Show that for any x < y in LimitDomSubtype, the interval [x, y] ∩ X is finite. Then `LinearLocallyFiniteOrder.succOrder` gives SuccOrder. The finiteness follows from the construction: x and y both enter the domain at some finite stage n, and at stage n the interval [x, y] ∩ dom(f_n) is finite. All subsequent stages only ADD points, so at any stage m ≥ n, [x, y] ∩ dom(f_m) is finite. In the limit... wait, the limit could have infinitely many points in [x, y] if C4a/C5a keep inserting points between them.

Actually, C4a inserts z = (x+y)/2 between adjacent x, y. Then C4a might insert between x and z, and between z and y, etc. Recursively, this CAN insert infinitely many points in [x, y] in the limit — this is how the dense case works. But without the density case, C4a still inserts points between adjacent pairs that have C4a counterexamples. So the interval [x, y] could still accumulate infinitely many points in the limit.

**This is the critical question**: Without the `.density` elimination, can C4a/C5a insertions still make the limit domain dense between two points?

**Answer: YES.** C4a (Lemma 2.9) inserts z between x and y whenever there's a C4a counterexample: ¬U(γ,δ) ∈ f(x) and γ ∈ f(y). As long as such counterexamples exist at adjacent pairs, C4a keeps inserting. In the limit, the interval [x, y] could contain infinitely many C4a-inserted points, making the interval dense.

**BUT**: This is density arising from C4a counterexample elimination, not from the `.density` kind. The `.density` kind explicitly inserts midpoints between ALL adjacent pairs regardless of counterexample status. C4a only inserts when there's an actual ¬U counterexample.

**So the limit domain might be "accidentally" dense in some intervals and discrete in others.** It's NOT necessarily globally discrete.

### 11. CRITICAL FINDING: X Is Not Necessarily Discrete

Without the `.density` case, the limit domain X is NOT guaranteed to be globally discrete. C4a counterexample elimination can insert points between adjacent pairs, and these insertions can cascade, producing arbitrarily many points in any interval.

**Example**: Consider x < y with ¬U(γ₁,δ₁) ∈ f(x) and γ₁ ∈ f(y). C4a inserts z₁ = (x+y)/2. Now if ¬U(γ₂,δ₂) ∈ f(x) and γ₂ ∈ f(z₁), C4a inserts z₂ = (x+z₁)/2. This can continue, inserting infinitely many points in [x, y].

**However**: Burgess's construction enumerates ALL potential counterexamples (including all (x, y, γ, δ, .c4_forward) tuples) and processes each one exactly once (modulo re-processing via Cantor unpairing). So only finitely many C4a counterexamples exist for each x (since there are only countably many formulas, and each x can have at most countably many C4a counterexamples). The question is whether the CASCADE of insertions terminates.

**In practice**: The cascade does NOT necessarily terminate. Each C4a insertion creates new adjacent pairs, and these new pairs might have their own C4a counterexamples. The construction handles this via the Cantor unpairing (re-processing), ensuring every new counterexample is eventually processed. But this means the limit domain CAN have accumulation points.

**Conclusion**: Without the density case, `LimitDomSubtype` is NOT necessarily discrete. It is NOT necessarily order-isomorphic to ℤ. The claim "Burgess's base construction produces a discrete order" is INCORRECT in general — the C4a insertions alone can produce density.

### 12. Revised Assessment

**The density case (`.density` in PotentialCounterexampleKind) is NOT the only source of density.** C4a counterexample elimination itself can produce density by cascading midpoint insertions. The `.density` case is a SEPARATE concern: it inserts midpoints between ALL adjacent pairs regardless of counterexample status, which guarantees GLOBAL density. Without it, density can still arise LOCALLY from C4a cascades.

**This means**: The embedding X ≅ ℤ approach only works if we can prove X is discrete. This requires either:
- Proving that C4a cascades terminate (i.e., the number of C4a-inserted points in any interval is finite) — unclear
- OR accepting that X might not be discrete and using a different embedding

**If X is not discrete**: We cannot use `orderIsoIntOfLinearSuccPredArch`. We'd need a different AddCommGroup D' to embed into. Options:
- Rat (current approach, but needs DenselyOrdered which needs the sorry)
- Some other group

**Alternative**: If X has both dense and discrete parts, it's a more general countable linear order. The classification of countable linear orders is complex (Hausdorff's theorem). The key question becomes: can we embed ANY countable linear order without endpoints into an AddCommGroup in an order-preserving way?

## Confidence Level

**HIGH** on the mechanical transfer of coherence proofs (iso swap is purely syntactic).

**HIGH** on the Mathlib theorem `orderIsoIntOfLinearSuccPredArch` and its requirements.

**HIGH** on the critical finding that X is NOT necessarily discrete without the density case.

**MEDIUM** on whether C4a cascades can actually produce density in practice (depends on the specific formula and MCS structure).

## Key Recommendation

The assumption "Burgess's base construction produces a discrete order" needs to be re-examined. C4a (Lemma 2.9) inserts midpoints between adjacent pairs with counterexamples, and cascading C4a insertions can produce dense intervals. The approach of embedding X ≅ ℤ only works if we can prove X is discrete, which requires showing C4a cascades are finite — a non-trivial property that depends on the formula structure.

**Safest approach**: Keep D = Rat, extend limit_f to all of Rat without the Cantor iso. This avoids the discreteness question entirely. The extension assigns MCS values to non-domain rationals via Lindenbaum extension of g_content, and the coherence proofs transfer via the identity embedding (limit_dom ⊂ Rat).
