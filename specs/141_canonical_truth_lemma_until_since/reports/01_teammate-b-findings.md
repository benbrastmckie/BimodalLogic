# Teammate B Research Findings: Alternative Approaches
## Task 141 — Canonical Truth Lemma Until/Since and ReflexiveCanonical Infrastructure

**Focus**: Alternative patterns, prior art, and comparative analysis with existing code.

---

## Key Findings

### 1. The 8 sorries split into two distinct problems

The 8 sorries are structurally dissimilar:

**Group A: TruthLemma.lean (WeakCanonical), 6 sorries**
- `until_forward_mcs` (lines 419-427): the intermediate guard condition
- `until_backward_mcs` (lines 442-443): contrapositive of until backward
- `since_forward_mcs` (lines 474-479): same guard issue for past direction
- `since_backward_mcs` (lines 490-494): same contrapositive for since
- `truth_lemma` `untl` backward case (line 548): needs `until_backward_mcs`
- `truth_lemma` `snce` backward case (line 563): needs `since_backward_mcs`

**Group B: ReflexiveCanonical.lean, 2 sorries**
- `reflCanR_linear` (line 144): forward cone is linearly ordered
- `canS5R_symm` (line 424): S5 modal relation is symmetric

### 2. The BXCanonical pattern for Until/Since is a dead end here

`BXCanonical/TruthLemma.lean` has two sorried lemmas with DIFFERENT problems from WeakCanonical:
- `until_backward_refl_mcs` and `since_backward_refl_mcs` (lines 293-321): these are
  explicitly flagged as unsound — "ψ → (φ U ψ) is NOT axiomatically valid under irreflexive
  semantics." These are dead code with no downstream consumers.

The WeakCanonical truth lemma uses REFLEXIVE `tempR_fwd` semantics (g_content-based), not
BXCanonical's irreflexive bx_le. This is a fundamental architectural difference that means
BXCanonical sorries cannot simply be ported.

### 3. The guard condition sorry has a well-understood structure

The `until_forward_mcs` sorry sits at: given U(ψ₁,ψ₂) ∈ x, we have found y with tempR_fwd x y
and ψ₁ ∈ y. The missing piece is: ∀ z, tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.

The codebase already proves the first part via `Bundle.forward_temporal_witness_seed_consistent`
(BX10 + Lindenbaum). The intermediate guard condition requires a different argument.

The **self-accumulation approach** (BX5: `U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂))`) is the key:
this propagates U(ψ₁,ψ₂) at all intermediate g_content-linked points. Combined with
`g_content_closed_derivation`, one can show that ψ₂ must be in all MCS intermediate between
x and y, because U(ψ₁,ψ₂) persists through g_content steps (by BX5) and implies ψ₂ is in
the guard.

Specifically: if tempR_fwd x z (g_content x ⊆ z), and tempR_fwd z y (g_content z ⊆ y),
and U(ψ₁,ψ₂) ∈ x, then by BX5 applied at x, we get U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x. Since
g_content x ⊆ z, we need G(U(ψ₁,ψ₂)) ∈ x — which would give U(ψ₁,ψ₂) ∈ z by g_content
forward. But we do NOT know G(U(ψ₁,ψ₂)) ∈ x without additional work.

### 4. The DovetailingChain approach is over-engineered for this problem

`BXCanonical/Quasimodel/` and `Filtration/` are complex structures designed for the BX
completeness proof. The comment in `until_forward_mcs` says "needs infrastructure from
DovetailingChain.lean or similar, not yet ported to ReflCanDomain." However, DovetailingChain
infrastructure was designed for the BX irreflexive setting and uses g_content subset inclusion
as the ordering — exactly what `tempR_fwd` uses.

A simpler alternative avoids the full dovetail chain entirely:

**The g_content propagation argument** (direct, no chain needed):

If U(ψ₁,ψ₂) ∈ x and tempR_fwd x z and tempR_fwd z y:
1. BX5 gives: U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x
2. This means there exists a future witness where ψ₂ ∧ U(ψ₁,ψ₂) holds
3. The until_F axiom (BX10) only gives a witness, not intermediate guard

The fundamental issue: `tempR_fwd` is a SET INCLUSION relation, not a successor relation.
There is no "immediate next step" to induct along. Any two points z with tempR_fwd x z and
tempR_fwd z y might have arbitrary g_content relationships to each other.

### 5. The correct approach for the guard condition

Reading `UntilSinceCoherence.lean` carefully reveals the key insight: `backward_until_from_step`
is parameterized over a "step transfer hypothesis" (line 111). The analogous problem for
`until_forward_mcs` in the reflexive canonical model needs a different framing.

The `reflCanTruth` Until semantics (lines 60-62) says:
```
∃ y, tempR_fwd x y ∧ reflCanTruth y ψ₁ ∧
  (∀ z, tempR_fwd x z → tempR_fwd z y → reflCanTruth z ψ₂)
```

The guard condition "∀ z intermediate between x and y" with tempR_fwd being g_content inclusion
means: for any MCS z where g_content(x) ⊆ z.val and g_content(z) ⊆ y.val, we need ψ₂ ∈ z.val.

The **until_F_expansion approach** (BX5 + BX6 combination) works as follows:

- BX5: U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) — so at the witness y, ψ₂ ∧ U(ψ₁,ψ₂) ∈ y
- For intermediate z with tempR_fwd x z and tempR_fwd z y:
  - We need to show ψ₂ ∈ z
  - Since g_content(x) ⊆ z, we have: G(U(ψ₁,ψ₂)) ∈ x → U(ψ₁,ψ₂) ∈ z
  - But do we know G(U(ψ₁,ψ₂)) ∈ x? Only if we can derive it from U(ψ₁,ψ₂) ∈ x using g_content_closed_derivation. This requires U(ψ₁,ψ₂) ∈ g_content(x), i.e., G(U(ψ₁,ψ₂)) ∈ x...which is circular.

This is the **fundamental blocker** documented in the existing sorries. The codebase comments
correctly identify this: "requires chain construction using until_F_expansion (self-accumulation)
to propagate ψ₂ through intermediate MCS."

### 6. The `until_backward_mcs` sorry (contrapositive form)

This sorry has the signature:
```lean
h_not_until : Formula.untl ψ₁ ψ₂ ∉ x.val ⊢
¬ (∃ y, tempR_fwd x y ∧ ψ₁ ∈ y.val ∧ (∀ z, tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val))
```

The comment says this is NOT needed for the chronicle+Reynolds pipeline. This is an important
point: if the completeness proof can bypass this sorry using a different path, it need not be
proved at all for the main goal.

### 7. Alternative approach: reframe the Until/Since truth in reflCanTruth

The reflexive canonical model uses `tempR_fwd = g_content inclusion`. The Until semantics
requires witnesses with intermediate guard. One **genuinely simpler alternative** is to use
a DIFFERENT definition of `reflCanTruth` for Until/Since that is easier to connect to MCS
membership:

Instead of the universal guard form, use the Venema/Burgess axiom-system form: U(ψ₁,ψ₂) ∈ x
iff there exists a finite chain x = x₀ R x₁ R ... R xₙ with ψ₁ ∈ xₙ and ψ₂ ∈ xᵢ for
0 < i < n. This requires discrete structure (successor relation) not available with just
g_content inclusion.

The existing truth definition cannot be changed without significant downstream impact.

### 8. Alternative for `reflCanR_linear` (the BX11 approach vs alternatives)

The comment in ReflexiveCanonical.lean (lines 122-143) outlines the standard BX11 approach:
contradict incomparability via F(¬ψ) and F(¬χ) at x, then BX11 (temp_linearity) at x forces
an ordering.

**Alternative 1: Zorn's lemma / well-ordering principle**
Not applicable since the conclusion is linearity (a totality property), not an existence result.

**Alternative 2: Direct contrapositive using BX11 at the MCS level**

BX11 states: F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)

If ¬tempR_fwd y z: ∃ ψ with Gψ ∈ y but ψ ∉ z. By negation completeness: ¬ψ ∈ z.
Since tempR_fwd x y: Gψ ∈ g_content y... wait, we need Gψ ∈ y.val.

Actually: tempR_fwd x y means g_content x ⊆ y.val. We do NOT have any formula in g_content y
being available at x without more structure.

The BX11 approach requires: from ¬tempR_fwd y z, obtain F(¬ψ) at x, and similarly F(¬χ) at x.
The step from "Gψ ∈ y, ψ ∉ z, tempR_fwd x y, tempR_fwd x z" to "F(¬ψ) ∈ x" requires
knowing that ¬ψ is in z.val (negation completeness gives us ¬ψ ∈ z) and tempR_fwd x z
(g_content x ⊆ z). But F(¬ψ) ∈ x means G(¬¬ψ) ∉ x which follows... this is the exact
chain the comment describes.

The blocker is the "F-truth lemma (forward temporal witness existence) not yet formalized
for ReflCanDomain." This is itself just `bx_forward_witness` ported to ReflCanDomain:
if F(φ) ∈ x.val, then ∃ y with tempR_fwd x y and φ ∈ y.val. But this is ALREADY
available via:
```lean
Bundle.forward_temporal_witness_seed_consistent + set_lindenbaum
```
The WeakCanonical TruthLemma.lean already uses this pattern for G_backward_mcs (lines 261-296).
The same pattern proves: if F(φ) ∈ x.val then ∃ y : ReflCanDomain, tempR_fwd x y ∧ φ ∈ y.val.

So `reflCanR_linear` is actually provable with the existing infrastructure — the comment's
claim that it needs DovetailingChain porting is INCORRECT. The forward_temporal_witness
for ReflCanDomain is: use `forward_temporal_witness_seed_consistent` + Lindenbaum, exactly
as done in G_backward_mcs.

### 9. Alternative for `canS5R_symm`

The comment says "not needed for discrete completeness." The proof uses modal_b: φ → □◇φ.

Standard proof: Given canS5R x y (∀ φ, □φ ∈ x.val → φ ∈ y.val), prove canS5R y x.
Take φ : Formula and □φ ∈ y.val. Need: φ ∈ x.val.

By modal_b: φ → □◇φ. If φ ∉ x.val, then ¬φ ∈ x.val (negation completeness).
By modal_b on ¬φ: ¬φ → □◇(¬φ) is a theorem, so □◇(¬φ) ∈ x.val.
By canS5R x y: ◇(¬φ) ∈ y.val.
But □φ ∈ y.val and □φ → φ (modal_t), so φ ∈ y.val.
And ◇(¬φ) = ¬□¬¬φ... wait, ◇(¬φ) = (¬φ).neg.box.neg = ¬□(¬¬φ).
By DNE: ¬¬φ ↔ φ at the theorem level, so □(¬¬φ) ∈ y.val.
By modal_t: ¬¬φ ∈ y.val, hence φ ∈ y.val (by DNE at y).

But ◇(¬φ) ∈ y.val means ¬□(¬¬φ) ∈ y.val, so □(¬¬φ) ∉ y.val... and □φ → □(¬¬φ) by
G_dne argument, so □(¬¬φ) ∈ y.val. Contradiction.

This is a clean proof using only modal_b and standard MCS properties. No chain construction
is needed. This sorry is solvable in ~30 lines following the box_backward_mcs pattern.

### 10. The Bundle approach to Until/Since (UntilSinceCoherence.lean)

The Bundle approach acknowledges the same fundamental blocker for forward coherence, and
parameterizes over a step-transfer hypothesis. This is documented in detail in
`UntilSinceCoherence.lean` lines 24-43. The approach for the reflexive canonical model
cannot use the Bundle's BFMCS parameterization without instantiating the step-transfer —
which requires the same g_content propagation argument.

---

## Alternative Approaches

### Approach A: Port `bx_forward_witness` to ReflCanDomain for `reflCanR_linear`

**Complexity**: Low. This just instantiates the existing Lindenbaum construction for
ReflCanDomain. The pattern is already in G_backward_mcs (WeakCanonical/TruthLemma.lean).

**Steps**:
1. Prove `reflCan_forward_witness`: if F(ψ) ∈ x.val then ∃ y : ReflCanDomain, tempR_fwd x y ∧ ψ ∈ y.val.
   (3-4 lines using forward_temporal_witness_seed_consistent + set_lindenbaum)
2. Use it in reflCanR_linear to instantiate witnesses from F(¬ψ) and F(¬χ) at x.
3. Apply BX11 (temp_linearity at MCS level) to derive the ordering.
4. The rest of reflCanR_linear follows the BXCanonical comment outline exactly.

**Confidence**: High that this works. The infrastructure exists.

### Approach B: Direct proof of `canS5R_symm` using modal_b

**Complexity**: Low (~30 lines).

**Steps**:
1. Take h: canS5R x y. Suppose □φ ∈ y.val.
2. By contraposition: assume φ ∉ x.val, derive contradiction.
3. ¬φ ∈ x.val by negation completeness.
4. modal_b on ¬φ: ¬φ → □◇(¬φ) is a theorem, so □◇(¬φ) ∈ x.val.
5. By h (canS5R x y): ◇(¬φ) ∈ y.val, i.e., ¬□(¬¬φ) ∈ y.val.
6. By DNE theorem: □(¬¬φ) → □φ is provable (G_dne_theorem adapted to box).
7. By contrapositive: ¬□φ ∈ y.val.
8. But □φ ∈ y.val. Contradiction.

This is self-contained, does not need any chain infrastructure, and directly follows from
the modal_b axiom already in the system.

**Confidence**: High. This is the standard S5 completeness argument. The analogous proof
`box_backward_mcs` in WeakCanonical/TruthLemma.lean (lines 133-238) shows the full
pattern already exists.

### Approach C: Reframe the Until/Since forward guard sorry as a structural assumption

Since `until_backward_mcs` is explicitly flagged as "NOT needed for the chronicle+Reynolds
pipeline," and the `until_forward_mcs` guard condition is the deep blocker, one approach
is to:

1. Discharge `until_backward_mcs` and `since_backward_mcs` trivially (they are negations
   of existentials that simply assert the sorry is not needed, which they are correctly stated).
2. Discharge the `truth_lemma` backward cases for `untl`/`snce` by showing these cases
   are unreachable in the downstream proof pipeline, OR by accepting them as assumptions
   on the model.

**Risk**: This changes the statement of the truth lemma to be conditional, which may break
downstream completeness if those cases are in fact needed.

**Confidence**: Low without understanding the full downstream dependency chain.

### Approach D: Use `BX5 + g_content_closed_derivation` chain argument for the guard

For the guard condition in `until_forward_mcs`:

Given U(ψ₁,ψ₂) ∈ x and intermediate z with tempR_fwd x z and tempR_fwd z y:

1. BX5 at x: U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)), so U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.
2. By BX10 on this: F(ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x... still just says there exists a witness.
3. The problem: need G(ψ₂) "for the g_content interval" without a global G-formula.

This approach fails because g_content inclusion does not give us induction along the path.

**Confidence**: Low. The fundamental blocker is real: g_content-based ordering lacks a
step-induction principle.

### Approach E: Alternative semantics for `reflCanTruth` for Until/Since

Replace the current definition with a simpler one that avoids the guard condition entirely
and uses only F/P witnesses:

```lean
| Formula.untl ψ₁ ψ₂ =>
    ∃ (y : ReflCanDomain), tempR_fwd x y ∧ reflCanTruth y ψ₁
    -- no guard condition
```

This weakens the semantics but the truth lemma becomes: U(ψ₁,ψ₂) ∈ x ↔ F(ψ₁) with witness.
This no longer matches the intended Until semantics and would break soundness.

**Confidence**: This is not a valid approach without redesigning the whole semantic layer.

---

## Trade-off Analysis

| Sorry | Primary Approach | Alternative | Risk |
|-------|-----------------|-------------|------|
| `reflCanR_linear` | Port bx_forward_witness to ReflCanDomain, then BX11 argument | No simpler alternative identified | Low — infrastructure exists |
| `canS5R_symm` | Direct proof via modal_b (Approach B) | None needed | Very Low — standard proof |
| `until_forward_mcs` guard | BX5 + chain propagation | No simple alternative — fundamental blocker | High |
| `until_backward_mcs` | Not needed per codebase comment — may be dischargeable | N/A | Medium (depends on downstream) |
| `since_forward_mcs` guard | Same as until_forward_mcs | Same | High |
| `since_backward_mcs` | Same as until_backward_mcs | N/A | Medium |
| `truth_lemma` untl/snce | Depends on above | Depends on above | High |

**Key asymmetry**: The 2 ReflexiveCanonical.lean sorries are solvable with existing
infrastructure. The 6 TruthLemma.lean sorries face the fundamental DovetailingChain /
g_content-propagation blocker. These are not the same class of problem.

---

## Evidence / Examples

### Evidence that `reflCan_forward_witness` is straightforward

The G_backward_mcs proof at WeakCanonical/TruthLemma.lean:261-304 is structurally identical
to what reflCan_forward_witness would need:
1. By contradiction: assume F(ψ) ∈ x.val but ∀ y, tempR_fwd x y → ψ ∉ y.val
2. Seed {¬ψ} ∪ g_content x — consistent by same argument
3. Extend to MCS y via Lindenbaum
4. g_content x ⊆ y gives tempR_fwd x y
5. ψ ∉ y (from ¬ψ ∈ y)
This is already proved for G; the F-witness is the exact same Lindenbaum extension.

### Evidence that `canS5R_symm` follows modal_b

The `box_backward_mcs` proof in WeakCanonical/TruthLemma.lean:133-238 already contains the
modal_b + negation completeness + S5 pattern that canS5R_symm needs, just inverted. That
proof uses modal_4 + modal_t + Lindenbaum to show □φ ∈ x when all accessible worlds satisfy φ.
The canS5R_symm proof needs the converse direction: use modal_b (φ → □◇φ) to propagate
from assumption to contradiction.

### Evidence on the guard condition blocker

`UntilSinceCoherence.lean` explicitly documents (lines 24-43) that the step-transfer
property is not available from bare FMCS structure. The comment "Under BX reflexive
semantics, (⊥ U α) ↔ α in any MCS, so the deterministic chain is constant" is the key:
ONLY for the discrete/successor setting with deterministic chains can the step-transfer
be instantiated. The reflexive canonical model lacks this.

### Literature evidence (Venema 1993)

Venema 1993 proves completeness for well-orderings via expressive completeness + Doets's
n-equivalents theorem. This approach is fundamentally different from canonical model
construction — it avoids the Until/Since guard condition by appealing to model equivalence
rather than constructing witnesses directly. The mosaic method (Caleiro-Vigano-Volpe 2013)
uses finite partial models (mosaics) rather than MCS-based canonical models, again avoiding
the guard propagation issue. Neither literature source provides a direct path for porting
the guard condition proof in the existing ReflCanDomain architecture.

---

## Confidence Levels

| Item | Confidence | Reason |
|------|------------|--------|
| `reflCanR_linear` is provable with existing infra | High | reflCan_forward_witness exists implicitly in G_backward_mcs pattern |
| `canS5R_symm` is provable in ~30 lines | High | Standard S5 argument, all lemmas present |
| Until/Since guard condition is a deep blocker | High | Multiple task history notes and codebase comments confirm this |
| `until_backward_mcs` / `since_backward_mcs` not needed for main proof | Medium | Codebase comment says "not needed for chronicle+Reynolds pipeline" but downstream verification needed |
| The DovetailingChain port is the intended approach for guards | High | Multiple comments point to this |
| Venema/Caleiro approaches offer alternative semantics | Low (for direct use) | Would require redesigning reflCanTruth definition |

---

## Summary Recommendation

**Quick wins (implement first)**:
1. `canS5R_symm`: Direct proof via modal_b. 30 lines. High confidence. No new infrastructure.
2. `reflCanR_linear`: Port `reflCan_forward_witness` (3 lines) then apply BX11 argument.
   20-40 lines. Existing infrastructure in G_backward_mcs covers the forward_witness part.

**Hard sorries (require plan decision)**:
3. The 6 TruthLemma.lean sorries for Until/Since are blocked by the same fundamental issue:
   g_content-based ordering has no step-induction principle. The DovetailingChain approach
   (task description: "porting DovetailingChain.lean to ReflCanDomain") is the intended path
   but is a significant undertaking. The `until_backward_mcs`/`since_backward_mcs` sorries
   may be closeable as "not needed" if downstream proof confirms this.

**Critical note on task scope**: Tasks 141-142 may intend that the guard condition
is proved via a new chain construction for ReflCanDomain. This is a different problem from
the `reflCanR_linear` and `canS5R_symm` sorries. The implementer should prioritize the
two ReflexiveCanonical.lean sorries first (solvable now), then scope the Until/Since guard
work separately.
