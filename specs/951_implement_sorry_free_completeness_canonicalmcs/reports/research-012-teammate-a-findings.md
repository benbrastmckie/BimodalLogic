# Teammate A Findings: G/H Symmetry in Temporal Relation

## Summary

G and H play **equal and symmetric** roles in defining the temporal relation in the canonical frame. The codebase defines TWO canonical relations (`CanonicalR` and `CanonicalR_past`) and proves a critical duality bridge between them. The system's temporal structure is fully G/H-symmetric; neither direction is privileged.

## Key Findings

### 1. Two Canonical Relations, Not One

The canonical frame (`CanonicalFrame.lean`, lines 58-72) defines **both** a future relation and a past relation:

```lean
-- Line 63-64: Future relation
def CanonicalR (M M' : Set Formula) : Prop :=
  GContent M ⊆ M'

-- Line 71-72: Past relation
def CanonicalR_past (M M' : Set Formula) : Prop :=
  HContent M ⊆ M'
```

Where `GContent` and `HContent` are defined in `TemporalContent.lean`:

```lean
-- Line 25-26
def GContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

-- Line 35-36
def HContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}
```

These definitions are perfectly symmetric: GContent strips the G operator, HContent strips the H operator.

### 2. Four Canonical Properties, Fully Symmetric

`CanonicalFrame.lean` proves four key properties in symmetric pairs:

| Future Direction | Past Direction |
|---|---|
| `canonical_forward_G` (line 86): G(phi) in M, CanonicalR M M' => phi in M' | `canonical_backward_H` (line 96): H(phi) in M, CanonicalR_past M M' => phi in M' |
| `canonical_forward_F` (line 122): F(psi) in M => exists W with CanonicalR M W and psi in W | `canonical_backward_P` (line 151): P(psi) in M => exists W with CanonicalR_past M W and psi in W |
| `canonicalR_reflexive` (line 180): uses temp_t_future (G phi -> phi) | `canonicalR_past_reflexive` (line 194): uses temp_t_past (H phi -> phi) |
| `canonicalR_transitive` (line 217): uses temp_4 (G phi -> GG phi) | `HContent_chain_transitive` (line 244): uses temp_4_past (H phi -> HH phi) |

### 3. The Critical Duality Bridge: G Implies H and Vice Versa

The most important finding is in `DovetailingChain.lean` (lines 765-824), which proves **two dual bridge lemmas**:

**Lemma 1** (`GContent_subset_implies_HContent_reverse`, line 767):
```
If CanonicalR M M'  (i.e., GContent(M) ⊆ M'),
then HContent(M') ⊆ M  (i.e., CanonicalR_past M' M).
```

**Lemma 2** (`HContent_subset_implies_GContent_reverse`, line 797):
```
If CanonicalR_past M M'  (i.e., HContent(M) ⊆ M'),
then GContent(M') ⊆ M  (i.e., CanonicalR M' M).
```

These two lemmas establish that **CanonicalR and CanonicalR_past are converses**: if M sees M' in the future, then M' sees M in the past, and vice versa. This is the formal G/H symmetry.

**Proof mechanism**: Lemma 1 uses the axiom `temp_a: phi -> G(P(phi))` (the present was in the past of the future). Lemma 2 uses the derived `past_temp_a: phi -> H(F(phi))` (the present will be in the future of the past), obtained via temporal duality from temp_a.

### 4. The Axiom System Is G/H-Symmetric Via Temporal Duality

The axiom system (`Axioms.lean`) has:
- `temp_k_dist` for G only (line 212): `G(phi -> psi) -> (G phi -> G psi)`
- `temp_4` for G only (line 220): `G phi -> GG phi`
- `temp_a` for G direction (line 231): `phi -> G(P(phi))`
- `temp_t_future` (line 262): `G phi -> phi`
- `temp_t_past` (line 275): `H phi -> phi`

The H-direction analogs of `temp_k_dist` and `temp_4` are NOT axioms but are **derived** via the `temporal_duality` inference rule:

```lean
-- Derivation.lean, line 136
| temporal_duality (phi : Formula)
    (d : DerivationTree [] phi) : DerivationTree [] phi.swap_past_future
```

Where `swap_temporal` exchanges `all_future` <-> `all_past` throughout a formula (Formula.lean, lines 396-402). This rule is an involution (swap twice = identity, proven at line 412).

Derived facts used in the codebase:
- `past_k_dist` (GeneralizedNecessitation.lean, line 85): `H(A -> B) -> (HA -> HB)` -- from temp_k_dist via duality
- `temp_4_past` (Completeness.lean, line 401): `H phi -> HH phi` -- from temp_4 via duality
- `past_temp_a` (DovetailingChain.lean, line 755): `phi -> H(F(phi))` -- from temp_a via duality

So the axiom system is written with G as the "primary" direction but H gets all the same properties through the temporal duality rule. The system is G/H-symmetric at the derived theorem level.

### 5. F and P Are Duals of G and H (Not of Each Other)

The formula constructors (Formula.lean):
- `all_future` (G) and `all_past` (H) are **primitive** constructors
- `some_future` (F) and `some_past` (P) are **derived**:
  ```lean
  def some_future (phi) := phi.neg.all_future.neg   -- F phi = not(G(not phi))
  def some_past (phi) := phi.neg.all_past.neg        -- P phi = not(H(not phi))
  ```

So F is the dual of G, and P is the dual of H. The user's observation is correct: G and H are not duals of each other -- they are independent primitive operators connected by axioms (temp_a, temp_t_future/past) and the temporal duality rule. F and P are their respective De Morgan duals.

### 6. The Fragment Preorder Uses CanonicalR Only (G-Direction)

In `BidirectionalReachable.lean` (line 263):
```lean
noncomputable instance : Preorder (BidirectionalFragment M0 h_mcs0) where
  le a b := CanonicalR a.world b.world
  le_refl a := canonicalR_reflexive a.world a.is_mcs
  le_trans a b c hab hbc := canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc
```

The preorder uses `CanonicalR` (G-direction). But `backward_H` in the FMCS is recovered via the duality bridge:

```lean
-- CanonicalCompleteness.lean, line 79-81
backward_H := fun w1 w2 _ h_le h_H =>
    (GContent_subset_implies_HContent_reverse w2.world w1.world w2.is_mcs w1.is_mcs h_le) h_H
```

When `w2 <= w1` (i.e., `CanonicalR w2.world w1.world`), the duality bridge gives `HContent(w1) ⊆ w2`, so H(phi) in w1 implies phi in w2.

### 7. The FMCS Structure Requires Both Directions

The FMCS structure (`FMCSDef.lean`, line 80) has four fields, reflecting both directions:
- `forward_G`: G phi at t, t <= t' => phi at t'
- `backward_H`: H phi at t, t' <= t => phi at t'

And the completeness proof also requires:
- `forward_F`: F(phi) at t => exists t' >= t with phi at t'
- `backward_P`: P(phi) at t => exists t' <= t with phi at t'

All four are proven sorry-free in `CanonicalCompleteness.lean`.

## Evidence Table

| Claim | File | Lines | Verified |
|---|---|---|---|
| CanonicalR defined via GContent | CanonicalFrame.lean | 63-64 | Yes |
| CanonicalR_past defined via HContent | CanonicalFrame.lean | 71-72 | Yes |
| G->H duality bridge | DovetailingChain.lean | 767-793 | Yes |
| H->G duality bridge | DovetailingChain.lean | 797-824 | Yes |
| temp_a axiom (phi -> G(P phi)) | Axioms.lean | 231 | Yes |
| past_temp_a derived (phi -> H(F phi)) | DovetailingChain.lean | 755-763 | Yes |
| Preorder uses CanonicalR | BidirectionalReachable.lean | 263-266 | Yes |
| backward_H recovered via duality | CanonicalCompleteness.lean | 79-81 | Yes |
| temporal_duality inference rule | Derivation.lean | 136-137 | Yes |
| swap_temporal involution | Formula.lean | 412-420 | Yes |

## Implications for Syntactic Construction of D

1. **CanonicalR is sufficient as the single ordering relation**: Although the codebase defines CanonicalR_past separately, the duality bridges prove that CanonicalR_past(M, M') is equivalent to CanonicalR(M', M) (for MCS pairs). So a single ordering based on CanonicalR captures both temporal directions.

2. **The task_rel in TaskFrame.lean is duration-indexed** (`task_rel w x u` where x is a duration), not direction-indexed. The canonical model converts CanonicalR into a preorder (non-negative direction = future, reverse = past). The nullity axiom (d=0) maps to reflexivity, and compositionality (d1+d2) maps to transitivity.

3. **Any construction of D (the duration type) must respect both GContent and HContent propagation**. Since `w1 <= w2` means `GContent(w1) ⊆ w2`, the forward direction is built-in. The backward direction (`HContent(w2) ⊆ w1`) is guaranteed by the duality bridge, so no additional constraint on D is needed for the H-direction.

4. **The syntactic construction approach need not treat G and H separately**: because any chain ordered by CanonicalR automatically satisfies both the G-propagation and (via duality) the H-propagation. The FMCS `backward_H` field is proven from `GContent_subset_implies_HContent_reverse`, not from a separate construction.

## Confidence Level

**High**. Every claim is backed by specific code citations with verified line numbers. The G/H symmetry is structurally built into the codebase through:
1. Parallel definitions (CanonicalR / CanonicalR_past)
2. Parallel theorems (forward_G / backward_H, forward_F / backward_P, etc.)
3. Formal duality bridges (GContent_subset_implies_HContent_reverse and its converse)
4. The temporal_duality inference rule ensuring all G-axioms have H-analogs

The user's concern about whether "the reverse direction" (HContent for future times) is handled is fully addressed: the duality bridges (`GContent_subset_implies_HContent_reverse` / `HContent_subset_implies_GContent_reverse`) ensure that CanonicalR M M' implies CanonicalR_past M' M and vice versa, so a single ordering captures both G and H directions.
