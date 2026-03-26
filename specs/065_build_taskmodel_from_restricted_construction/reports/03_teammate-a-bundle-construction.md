# Teammate A: Incremental Bundle Construction

## Summary

The existing `construct_bfmcs_bundle` construction in `UltrafilterChain.lean` already provides the mechanism to build Omega with **multiple distinct histories** that can distinguish `G(phi)` from `Box(phi)`. The key insight is that `boxClassFamilies` creates families from **different base MCSes** that agree on Box-formulas but can disagree on other formulas. This is precisely what is needed.

The critical mechanism is `box_theory_witness_exists`: when `Diamond(psi)` is in an MCS M, there exists a **different** MCS W with `psi in W` but the same Box-theory. These different MCSes generate different families (histories) that share modal accessibility but have distinct temporal trajectories.

## Key Findings

### 1. Existing Bundle Construction Analysis

**Location**: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean:2853-2864`

The `construct_bfmcs_bundle` builds a BFMCS from an initial MCS M0:

```lean
noncomputable def construct_bfmcs_bundle (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    BFMCS_Bundle where
  families := boxClassFamilies M0 h_mcs
  nonempty := boxClassFamilies_nonempty M0 h_mcs
  modal_forward := boxClassFamilies_modal_forward M0 h_mcs
  modal_backward := boxClassFamilies_modal_backward M0 h_mcs
  bundle_forward_F := fun fam hfam phi t h_F =>
    boxClassFamilies_bundle_forward_F M0 h_mcs fam hfam t phi h_F
  bundle_backward_P := fun fam hfam phi t h_P =>
    boxClassFamilies_bundle_backward_P M0 h_mcs fam hfam t phi h_P
  eval_family := SuccChainFMCS (MCS_to_SerialMCS M0 h_mcs)
  eval_family_mem := eval_family_mem_boxClassFamilies M0 h_mcs
```

The bundle contains:
- **Multiple families**: Generated from different MCSes in the same "box class" (same Box-theory)
- **Time shifts**: Each family can be shifted to place its base MCS at any time point

### 2. Diamond Witness Mechanism

**Location**: `UltrafilterChain.lean:903-930`

When `Diamond(psi)` is in MCS M, the construction spawns a **new family**:

```lean
theorem box_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : Formula.diamond psi in M) :
    exists W : Set Formula, SetMaximalConsistent W and psi in W and box_class_agree M W
```

**How it works**:
1. Start with seed set: `{psi} union box_theory(M)`
2. `box_theory(M)` = `{Box(a) | Box(a) in M} union {neg(Box(a)) | Box(a) not in M}`
3. Prove this seed is consistent using S5 axiom 5 (negative introspection)
4. Extend to MCS W via Lindenbaum's lemma
5. W has `psi in W` AND `box_class_agree M W`

**Critical**: W is a **different** MCS from M (when psi is not in M), but they agree on all Box-formulas. This creates multiple histories in the same modal accessibility class.

### 3. F/P Witness Mechanism

**Locations**:
- `UltrafilterChain.lean:2004-2045` (forward)
- `UltrafilterChain.lean:2102-2143` (backward)

For temporal witnesses (`F(psi)` and `P(psi)`), the construction is more complex:

**Forward (F(psi) in M)**:
```lean
theorem forward_theory_chain_witness_exists (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) (psi : Formula) (h_F : Formula.some_future psi in omega_chain_forward M0 h_mcs0 n) :
    exists W : Set Formula, SetMaximalConsistent W and psi in W and
      G_theory_agrees M0 W and box_class_agree M0 W
```

The temporal witnesses:
1. **Stay within the SAME family** for G-content propagation
2. But **may spawn a NEW family** if they require different Box-theory (they don't - G/H don't affect Box)
3. Use `temporal_theory_witness_exists` and `past_theory_witness_exists`

**Key Property**: Temporal coherence within a family is separate from modal coherence across families.

### 4. Box/G/H Closure

The closure properties are enforced by the FMCS structure (`Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`):

```lean
structure FMCS (D : Type*) [Preorder D] [Zero D] where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t <= t' -> all_future phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' <= t -> all_past phi in mcs t -> phi in mcs t'
```

- **Box closure**: `Box(phi) in M` propagates via `box_persistent` (uses TF axiom)
- **G closure**: `G(phi) in mcs(t)` implies `phi in mcs(s)` for all `s > t` (via `forward_G`)
- **H closure**: `H(phi) in mcs(t)` implies `phi in mcs(s)` for all `s < t` (via `backward_H`)

### 5. Lindenbaum Completion Strategy

**Location**: `Theories/Bimodal/Metalogic/Bundle/Construction.lean:137-153`

```lean
noncomputable def lindenbaumMCS_set (S : Set Formula) (h_cons : SetConsistent S) :
    Set Formula :=
  Classical.choose (set_lindenbaum S h_cons)
```

The completion preserves structure because:
1. The seed set already contains all required Box-formulas (via `box_theory`)
2. The seed set already contains all required G-formulas (via `G_theory`)
3. Lindenbaum extension only adds formulas consistent with the seed
4. MCS negation-completeness then gives us all the "backward" properties

### 6. Shift Closure for Bundle Omega

**Location**: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean:337-382`

The ShiftClosed Omega is built as:

```lean
def ShiftClosedCanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { sigma | exists (fam : FMCS Int) (_ : fam in B.families) (delta : Int),
    sigma = WorldHistory.time_shift (to_history fam) delta }
```

This includes:
1. All canonical histories from bundle families (`delta = 0`)
2. All time-shifts of those histories

**Key theorem**: `shiftClosedCanonicalOmega_is_shift_closed` (line 367-373)

The shift closure interacts with the bundle via:
- **Box case in truth lemma**: Quantifies over ShiftClosedCanonicalOmega
- **Box persistence**: `Box(phi)` in any family's MCS at time t implies `Box(phi)` at ALL times (TF axiom)
- This means the shifted histories still evaluate Box-formulas correctly

## Recommended Construction

For building Omega that distinguishes G from Box, the existing construction already works:

**Step 1: Initial Seed**
- Start with consistent set S0 containing `neg(phi)`
- Extend S0 to MCS M0 via Lindenbaum

**Step 2: Build BFMCS_Bundle**
```lean
let B := construct_bfmcs_bundle M0 h_mcs0
```
This creates:
- `boxClassFamilies M0 h_mcs0` = all families from MCSes with same Box-theory as M0
- Each family is a SuccChainFMCS possibly shifted in time

**Step 3: Diamond Witnesses (Automatic)**
The bundle construction automatically includes:
- For every `Diamond(psi)` in any family's MCS at time t
- There exists a family with `psi` at that time
- Via `box_theory_witness_exists` + `boxClassFamilies_modal_backward`

**Step 4: Build Omega**
```lean
let Omega := ShiftClosedCanonicalOmega B.toBFMCS
```

**Step 5: Verify G vs Box Distinction**

For `G(phi) & ~Box(phi)` to be satisfiable:
- `G(phi)` requires phi true at all **future times within the SAME history**
- `~Box(phi)` requires some **other history** in Omega where phi is false at time t

The construction guarantees:
- Different families have different base MCSes
- A family with `Diamond(neg(phi))` will have `neg(phi)` somewhere (via witness existence)
- This witness family is in `boxClassFamilies` (same Box-theory)
- Therefore `phi` fails in that family at time t, making `Box(phi)` false

## How This Differs from Previous Approach

The previous approach (task 58) attempted to build Omega from a **single history** plus shifts. This fails because:

1. **Single history limitation**: `time_shift(tau, delta)` evaluates `G(phi)` and `Box(phi)` at the same world-state (just shifted). Both see the same temporal trajectory.

2. **Cannot distinguish modalities**: In a single-history Omega:
   - `G(phi)` checks: "phi holds at all future times in this trajectory"
   - `Box(phi)` checks: "phi holds in all sigma in Omega at time t"
   - But Omega = {time_shift(tau, delta) | delta in Int}
   - All these shifted histories agree at time t (they share the same state trajectory)

3. **The fix - Multiple families**:
   - Bundle construction creates families from **different** base MCSes
   - Different base MCSes can have `phi` vs `neg(phi)` at the same time
   - This breaks the G/Box equivalence

**Example**: To satisfy `G(phi) & ~Box(phi)`:
- Let M0 be an MCS with `G(phi)` and `Diamond(neg(phi))`
- By `box_theory_witness_exists`: there exists MCS W with `neg(phi)` and `box_class_agree M0 W`
- The family from W has `neg(phi)` at its base time
- The family from M0 has `phi` at all times (by G)
- Bundle Omega includes both families
- Result: `G(phi)` is true (in M0's family), `Box(phi)` is false (W's family has `neg(phi)`)

## Confidence Level

**HIGH**

The existing `construct_bfmcs_bundle` construction is specifically designed to create multiple families that share modal accessibility (Box-theory) but can differ on non-modal formulas. This is exactly what distinguishes G from Box:
- G quantifies over times **within** a family
- Box quantifies **across** families in the bundle

The construction is well-documented and the key theorems (`boxClassFamilies_modal_forward`, `boxClassFamilies_modal_backward`, `box_theory_witness_exists`) are all sorry-free.

The only sorries in the chain are in `SuccChainTemporalCoherent` (for temporal coherence within families), which is orthogonal to the G-vs-Box distinction - that depends on having multiple families, which is already working.

## Open Questions

1. **Connection to task 65**: How does the restricted construction interact with the bundle? Does `construct_bfmcs_bundle` need to be modified to work with `RestrictedMCS` instead of full MCS?

2. **Shift closure preservation**: When we shift a family's history, does the valuation (MCS membership) transfer correctly? (This should be automatic from `box_persistent` and the temporal coherence within families.)

3. **The `boxClassFamilies` definition** (line 1553-1557) creates families from:
   ```lean
   { f | exists (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
     box_class_agree M0 W and
     f = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k }
   ```
   This is an **infinite** set (all W in the same box-class, all shifts k). Is this problematic for any downstream constructions?
