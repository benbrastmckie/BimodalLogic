# Research Report: Dense Case of Case-Split Completeness Approach

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Status**: Research complete
- **Type**: lean4
- **Artifacts**: reports/05_dense-case-research.md

## Executive Summary

The case-split completeness approach (dense case + discrete case) is **viable in principle but requires careful handling of three subtleties**. This report analyzes the dense case in detail, verifying each step of the proposed argument against the codebase.

**Key findings**:
1. **C4 instantiation works**: `limit_satisfies_c4` with xi=bot, eta=top directly gives density from F'T in all f(x). The proof is straightforward.
2. **F'T propagation via axiom extension works**: If F'T is an AXIOM of an extended system, then by temporal/past necessitation, G(F'T) and H(F'T) are theorems, so every MCS contains F'T at all domain points. This is correct.
3. **Cantor iso restoration is clean**: The archived code in `Boneyard/DenseChronicle/` can be restored with minimal changes once `DenselyOrdered LimitDomSubtype` is proved.
4. **Case-split exhaustiveness is NON-TRIVIAL**: The dichotomy between dense and discrete is exhaustive ONLY for Archimedean ordered abelian groups (via Mathlib's `LinearOrderedAddCommGroup.discrete_or_denselyOrdered`). The codebase's `valid` does NOT require Archimedean, so an additional argument is needed.
5. **Extended system approach has a cleaner alternative**: Instead of adding F'T as an axiom to a new proof system, we can simply extend the root MCS A0 with {G(F'T), H(F'T), G(P'T), H(P'T)} and check consistency. This stays within the base BX system.

---

## Question 1: C4 Formulation in the Codebase

### Exact Signature

File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`, line 741:

```lean
theorem limit_satisfies_c4 (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hxy : x < y) (ξ η : Formula)
    (h_neg_until : (Formula.untl η ξ).neg ∈ limit_f A h_mcs x)
    (h_event : η ∈ limit_f A h_mcs y) :
    ∃ z ∈ limit_dom A h_mcs, x < z ∧ z < y ∧ ξ.neg ∈ limit_f A h_mcs z
```

### Comparison with Burgess C4a

Burgess C4a (using the codebase's convention where `untl(event, guard)`):
- Hypothesis: `neg(untl(eta, xi)) in f(x)` and `eta in f(y)` and `x < y`
- Conclusion: `exists z, x < z < y and neg(xi) in f(z)`

The codebase's `limit_satisfies_c4` matches this EXACTLY. The convention is:
- `Formula.untl eta xi` = U(eta, xi) = Until with event=eta, guard=xi
- `(Formula.untl eta xi).neg` = neg(U(eta, xi)) = "not Until"
- Conclusion: `xi.neg in f(z)` = neg(guard) at the intermediate point

### Instantiation with gamma=top, delta=bot

To get density from C4:
- Set `xi := Formula.bot` (the guard is bot)
- Set `eta := Formula.bot.imp Formula.bot` (the event is top)
- `h_neg_until` needs: `(Formula.untl top bot).neg in f(x)` which is `F'T in f(x)`
- `h_event` needs: `top in f(y)` -- trivially true since every MCS contains top
- Conclusion: `exists z in limit_dom, x < z < y and bot.neg in f(z)`
- Since `bot.neg = bot.imp bot = top`, the formula part is trivial
- The important output is the EXISTENCE of z with `x < z < y` and `z in limit_dom`

**This gives exactly the density condition.**

### Lean code sketch for the density proof

```lean
theorem limit_dom_dense_from_F'T (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_F'T_all : ∀ x, x ∈ limit_dom A h_mcs → 
      (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg ∈ limit_f A h_mcs x)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hxy : x < y) :
    ∃ z ∈ limit_dom A h_mcs, x < z ∧ z < y := by
  set top := Formula.bot.imp Formula.bot
  have h_mcs_y := limit_c0 A h_mcs y hy
  have h_top_y : top ∈ limit_f A h_mcs y :=
    theorem_in_mcs h_mcs_y (Bimodal.Theorems.Combinators.identity Formula.bot)
  obtain ⟨z, hz_dom, hxz, hzy, _⟩ :=
    limit_satisfies_c4 A h_mcs x y hx hy hxy Formula.bot top (h_F'T_all x hx) h_top_y
  exact ⟨z, hz_dom, hxz, hzy⟩
```

---

## Question 2: DenselyOrdered from C4

### What DenselyOrdered Requires

From Mathlib (`Mathlib.Order.Basic`):

```lean
class DenselyOrdered (α : Type) [LT α] : Prop where
  dense : ∀ (a₁ a₂ : α), a₁ < a₂ → ∃ a, a₁ < a ∧ a < a₂
```

### From limit_dom_dense to DenselyOrdered LimitDomSubtype

If `limit_dom_dense` is proved (i.e., between any two domain points there's a third), then `DenselyOrdered (LimitDomSubtype A h_mcs)` follows immediately. The archived code in `Boneyard/DenseChronicle/DenseLimitDomain.lean` (line 82-88) shows exactly this:

```lean
instance limitDomSubtype_denselyOrdered (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    : DenselyOrdered (LimitDomSubtype A h_mcs) where
  dense := by
    intro ⟨a, ha⟩ ⟨b, hb⟩ hab
    obtain ⟨z, hz, haz, hzb⟩ := limit_dom_dense A h_mcs a b ha hb hab
    exact ⟨⟨z, hz⟩, haz, hzb⟩
```

This is a 3-line proof. No issues here.

### DenselyOrdered + other instances -> Cantor iso

Once `DenselyOrdered (LimitDomSubtype A h_mcs)` is established, the Cantor iso follows from Mathlib's `Order.iso_of_countable_dense`:

```lean
Order.iso_of_countable_dense (α β : Type)
    [LinearOrder α] [LinearOrder β]
    [Countable α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α] [Nonempty α]
    [Countable β] [DenselyOrdered β] [NoMinOrder β] [NoMaxOrder β] [Nonempty β]
    : Nonempty (α ≃o β)
```

The codebase already has `limitDomSubtype_countable`, `limitDomSubtype_noMaxOrder`, `limitDomSubtype_noMinOrder`, and `limitDomSubtype_nonempty` in `ChronicleToCountermodel.lean` (lines 82-153). Combined with the new `limitDomSubtype_denselyOrdered`, ALL prerequisites for `Order.iso_of_countable_dense` are satisfied.

---

## Question 3: Cantor Iso Restoration

### Archived Code Location

`Theories/Bimodal/Boneyard/DenseChronicle/CantorIsoCountermodel.lean`

### What the archived code provides

The file contains the complete Cantor iso pathway (after `#exit` to prevent compilation):
- `cantor_iso`: `LimitDomSubtype A h_mcs ≃o Rat`
- `cantor_f`: MCS assignment via `cantor_iso.symm`
- `cantor_zero`, `cantor_f_at_zero`, `cantor_f_is_mcs`
- `cantor_fmcs`: FMCS Rat with `forward_G` and `backward_H`
- Stubs for `shifted_cantor_fmcs`, `rooted_cantor_fmcs`, `cantor_bfmcs`, etc.

### What depends on `limitDomSubtype_denselyOrdered`

Only ONE definition: `cantor_iso` itself (line 48-51):

```lean
noncomputable def cantor_iso (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    : LimitDomSubtype A h_mcs ≃o Rat :=
  Classical.choice (Order.iso_of_countable_dense (LimitDomSubtype A h_mcs) Rat)
```

Everything else builds on `cantor_iso` downstream.

### Restoration effort

Minimal changes needed:
1. Restore `limitDomSubtype_denselyOrdered` (the 3-line instance)
2. Remove `#exit` and un-comment the archived code
3. Complete the stubs (shifted/rooted/bfmcs) -- these were sketched but not fully proved before archival
4. Wire into `dd_countermodel_chronicle`

The key subtlety: the archived `cantor_fmcs` has `forward_G` and `backward_H` proofs that use `limit_forward_G` and `limit_backward_H` transported through `cantor_iso`. These are already written and correct in the archive.

**What was NOT completed before archival**: The `shifted_cantor_fmcs`, `rooted_cantor_fmcs`, `cantor_bfmcs` with modal_forward/backward, and the final wiring. The archive says "See git history for the complete code (~540 lines)." The full code existed at some point and was truncated during archival.

### Estimate

If the `DenselyOrdered` instance is available and the full git history code is recovered: 10-15 hours to restore and verify the Cantor iso pathway.

---

## Question 4: Extended Axiom System

### Current Axiom System

File: `Theories/Bimodal/ProofSystem/Axioms.lean`, line 67:

```lean
inductive Axiom : Formula → Type where
  | prop_k ... | prop_s ... | ex_falso ... | peirce ...
  | modal_t ... | modal_4 ... | modal_b ... | modal_5_collapse ... | modal_k_dist ...
  | temp_k_dist ... | temp_4 ... | serial_future | serial_past
  | left_mono_until ... | left_mono_since ... | left_mono_until_G ... | left_mono_since_H ...
  | right_mono_until ... | right_mono_since ...
  | connect_future ... | connect_past ...
  | enrichment_until ... | enrichment_since ...
  | separation_until ... | separation_since ...
  | self_accum_until ... | self_accum_since ...
  | absorb_until ... | absorb_since ...
  | linear_until ... | linear_since ...
  | until_F ... | since_P ...
  | temp_linearity ... | temp_linearity_past ...
  | F_until_equiv ... | P_since_equiv ...
  | modal_future ... | temp_future ...
```

### Option A: Add F'T as a new axiom constructor

Add to the `Axiom` inductive:
```lean
  | density_future : Axiom (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg
  | density_past : Axiom (Formula.snce (Formula.bot.imp Formula.bot) Formula.bot).neg
```

**Consequences**: This changes the Axiom type, which affects:
- Soundness proofs (must prove F'T is valid on dense orders)
- Frame class classification (`Axiom.frameClass` must return `FrameClass.Dense`)
- All match expressions on Axiom (dozens across the codebase)
- The DerivationTree would derive F'T from any context
- By `temporal_necessitation`, G(F'T) is automatically a theorem
- By `past_necessitation`, H(F'T) is automatically a theorem

This is a HEAVY change to the base system. We do NOT want this for the base BX logic.

### Option B: Separate extended system (NOT recommended for base completeness)

Create a parallel `ExtendedAxiom` type and `ExtendedDerivationTree`. This duplicates much infrastructure. The `ConservativeExtension/` module exists but is for adding atoms, not axioms.

### Option C: Extend A0 directly (RECOMMENDED for the case-split approach)

Instead of changing the axiom system, work within the BASE BX system:

1. Assume {neg(phi)} is BX-consistent
2. Case split: is {neg(phi), G(F'T), H(F'T), G(P'T), H(P'T)} BX-consistent?
3. If YES: extend to MCS A0 containing all of these. Build chronicle from A0.
   - G(F'T) in A0 + limit_forward_G ensures F'T in f(x) for all x > 0
   - H(F'T) in A0 + limit_backward_H ensures F'T in f(x) for all x < 0
   - F'T in A0 (derivable from G(F'T) via seriality + forward_G) covers x = 0
   - Actually: F'T is NOT derivable from G(F'T) in irreflexive semantics!
     G(F'T) means "at all STRICTLY future points, F'T holds" -- not at the current point.

**CRITICAL SUBTLETY**: Under irreflexive semantics, G(phi) at t means phi holds at all t' > t, NOT at t itself. So G(F'T) in A0 does NOT imply F'T in A0.

We need to extend A0 with {neg(phi), F'T, P'T, G(F'T), H(F'T), G(P'T), H(P'T)}.

Then:
- F'T in A0 = f(0) -- directly from the extension
- G(F'T) in A0 + limit_forward_G gives: for any x in limit_dom with x > 0, for any y > x, F'T in f(y). But wait, limit_forward_G gives: G(phi) in f(x) and x < y implies phi in f(y). We need G(F'T) in f(x) for x > 0, which follows from... well, G(F'T) in f(0) and limit_forward_G gives F'T in f(x) for x > 0. But we need G(F'T) in f(x) for arbitrary x > 0.

From G(F'T) in f(0), we get F'T in f(x) for all x > 0 (by limit_forward_G). But do we get G(F'T) in f(x)?

temp_4 (axiom): G(phi) -> G(G(phi)). So G(F'T) in f(0) implies G(G(F'T)) in f(0), i.e., at all future points, G(F'T) holds. So G(F'T) in f(x) for x > 0 follows from limit_forward_G applied to G(G(F'T)) at f(0).

Wait, let me be more careful:
- G(F'T) in f(0) (from the extension of A0)
- temp_4: G(F'T) -> G(G(F'T)) is a theorem, so G(G(F'T)) in f(0) (by MCS closure)
- limit_forward_G with phi = G(F'T): G(G(F'T)) in f(0) and 0 < x implies G(F'T) in f(x)
- So G(F'T) in f(x) for all x > 0
- Then limit_forward_G with phi = F'T: G(F'T) in f(x) and x < y implies F'T in f(y)
- So F'T in f(y) for all y > x > 0, i.e., for all y > 0

This gives F'T at all points > 0. For points < 0, we use H(F'T) and a past version of temp_4.

But what about 0 itself? We directly included F'T in A0, so F'T in f(0).

**Complete propagation**:
- F'T in f(0): direct
- F'T in f(x) for x > 0: from G(F'T) in f(0) via limit_forward_G
- G(F'T) in f(x) for x > 0: from G(G(F'T)) in f(0) via limit_forward_G (using temp_4)
- F'T in f(x) for x < 0: from H(F'T) in f(0) via limit_backward_H
- H(F'T) in f(x) for x < 0: from H(H(F'T)) in f(0) via limit_backward_H (using past temp_4, derivable via duality)

Does temp_4 for H exist? temp_4 is `G(phi) -> G(G(phi))`. The past mirror would be `H(phi) -> H(H(phi))`. This IS derivable via temporal duality from temp_4.

**Result**: If A0 contains {F'T, P'T, G(F'T), H(F'T), G(P'T), H(P'T)}, then F'T and P'T are in f(x) for ALL x in limit_dom.

### Consistency of the extension

The consistency check is: is {neg(phi), F'T, P'T, G(F'T), H(F'T), G(P'T), H(P'T)} BX-consistent?

If YES: proceed with the dense case.
If NO: BX derives that neg(phi) implies neg(F'T) or neg(P'T) or neg(G(F'T)) or ... This means phi is related to density/discreteness properties. Use the discrete case.

**Note**: We could simplify by checking {neg(phi), G(F'T), H(F'T), G(P'T), H(P'T)} (without F'T and P'T separately). Since we need F'T in A0 but G(F'T) does NOT imply F'T under irreflexive semantics, we DO need F'T explicitly. However, by BX4 (connect_future: phi -> G(P(phi))), if F'T in A0 then G(P(F'T)) in A0. And by P-resolution, P(F'T) at any future point gives a witness of F'T in the past. This is related but not identical to G(F'T).

Actually, there's a simpler approach: use the set {neg(phi), G(F'T), H(P'T)}. By BX4 (connect_future), F'T -> G(P(F'T)), but this doesn't directly give G(F'T). We really need the full set.

Actually, let me reconsider: do we need H(F'T)? H(F'T) ensures F'T at past points. But limit_backward_H already gives: H(phi) in f(x), y < x implies phi in f(y). So H(F'T) in f(0) gives F'T in f(y) for y < 0. And we need H(F'T) at all points, which comes from H(H(F'T)) at f(0).

Let `D = {F'T, P'T, G(F'T), H(F'T), G(P'T), H(P'T)}`. We also need G-closure of the G parts:
- G(G(F'T)) follows from temp_4 applied to G(F'T) in any MCS
- H(H(F'T)) follows from past temp_4

These are automatic from MCS closure + axioms, not additional extension requirements.

**So the minimal extension set is: {neg(phi), F'T, P'T, G(F'T), H(F'T), G(P'T), H(P'T)}.**

---

## Question 5: F'T Propagation

### If F'T is just in A0 (not globally)

F'T in A0 does NOT automatically give G(F'T) in A0. Under irreflexive semantics:
- G(phi) at t means phi holds at all t' > t, not at t
- There is NO rule phi in MCS implies G(phi) in MCS
- Temporal necessitation only applies to THEOREMS (derivable from empty context)

So F'T in A0 gives F'T at f(0) only. We do NOT get F'T at any other point.

### If G(F'T) is in A0

G(F'T) in f(0) + limit_forward_G gives F'T in f(x) for all x > 0 in limit_dom.
G(G(F'T)) in f(0) (from temp_4) + limit_forward_G gives G(F'T) in f(x) for all x > 0.
Then F'T propagates forward indefinitely.

### Full propagation requires the extension set

{F'T, P'T, G(F'T), H(F'T), G(P'T), H(P'T)} in A0 gives:
- F'T in f(x) for ALL x in limit_dom (forward via G, backward via H, at 0 directly)
- P'T in f(x) for ALL x in limit_dom (similarly)
- Therefore the limit domain is dense (by C4 instantiation)
- Therefore DenselyOrdered LimitDomSubtype
- Therefore Cantor iso exists
- Therefore countermodel on Rat

---

## Question 6: Relationship to Existing limit_dom_dense

### Archived limit_dom_dense

File: `Boneyard/DenseChronicle/DenseLimitDomain.lean`, line 36:

The old `limit_dom_dense` used the `.density` counterexample kind. It worked by:
1. Getting the density counterexample enumeration for the pair (x, y)
2. Invoking `density_witness` from `EliminationResult`
3. The density elimination inserted z = (x+y)/2 between adjacent x,y
4. This required `SetConsistent (chi.g x y)` -- the sorry at CE:3570

### New approach (C4-based density)

The new approach is fundamentally different:
- Old: density was a SEPARATE counterexample kind that inserted points unconditionally
- New: density follows from the FORMULA F'T being in all f(x), using the existing C4 mechanism

The C4 mechanism already exists and is sorry-free. The only new requirement is ensuring F'T propagates to all domain points, which is handled by the extension set {F'T, G(F'T), H(F'T), ...}.

**The old sorry at CE:3570 is completely bypassed.** We don't need the `.density` counterexample kind at all. Density emerges from the formula content of the MCS assignment, not from explicit midpoint insertion.

---

## Critical Issue: Case-Split Exhaustiveness

### The Mathlib Dichotomy

```lean
LinearOrderedAddCommGroup.discrete_or_denselyOrdered :
  ∀ (G : Type) [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G],
    Nonempty (G ≃+o Z) ∨ DenselyOrdered G
```

This says: Archimedean linearly ordered abelian groups are either isomorphic to Z or densely ordered.

### The Problem

The codebase's `valid` quantifies over ALL `D : Type` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`. It does NOT require `[Archimedean D]`.

Non-Archimedean ordered abelian groups exist (e.g., Z x Z with lexicographic order). A formula could be valid on all dense groups AND all discrete groups but fail on a non-Archimedean group.

### Potential Resolutions

**Resolution 1: Add Archimedean to valid**
Change `valid` to require `[Archimedean D]`. This would make the dichotomy exhaustive but requires re-proving soundness with the additional typeclass constraint. Since soundness is `valid phi -> Derivable phi` (wait, soundness is `Derivable phi -> valid phi`), we need to verify all axioms are valid on Archimedean groups. This is trivially true since the existing proofs work for all AddCommGroup+LinearOrder.

Actually, SOUNDNESS says `Derivable phi -> valid phi`. If we restrict `valid` to Archimedean groups, we get a WEAKER statement (valid over fewer groups = more formulas are valid). This makes soundness EASIER. Completeness becomes HARDER because we need to refute validity over a SMALLER class.

But wait: `valid phi` with Archimedean restriction subsumes the original `valid phi` (every Archimedean group is an ordered abelian group). So if phi is Archimedean-valid, it might NOT be generally valid. We'd be proving: Archimedean-valid -> derivable, which is STRONGER than needed.

Actually, the situation is the opposite. We want: general-valid -> derivable. If Archimedean-valid -> derivable, and general-valid -> Archimedean-valid (which is trivially true since Archimedean groups are a subset), then general-valid -> derivable follows.

Wait, no: general-valid means "valid on ALL groups". Archimedean-valid means "valid on Archimedean groups". general-valid IMPLIES Archimedean-valid (specialization). So: general-valid -> Archimedean-valid -> derivable. This is correct.

**So proving completeness for Archimedean groups suffices for general completeness.** This is because the contrapositive direction works: if NOT derivable, we build a countermodel on an Archimedean group (Rat or Int), which is also a valid countermodel for general validity.

This means: the Archimedean restriction is NOT needed in `valid`. We just need to build countermodels on Archimedean groups (Rat or Int), which the case-split approach already does.

**Resolution 2: Direct case split on derivability (CLEANER)**

The case split should be on derivability in the base system, not on model-theoretic properties:

1. BX not derives phi
2. Either {neg(phi), F'T, P'T, G(F'T), H(F'T), G(P'T), H(P'T)} is BX-consistent or not
3. **Dense case**: If consistent, build countermodel on Rat (Archimedean, dense)
4. **Complement case**: If inconsistent, then BX derives: neg(phi) -> neg(F'T v P'T v G(F'T) v H(F'T) v G(P'T) v H(P'T)). Need to show a countermodel exists on a non-dense domain.

For the complement case, we'd need to handle the situation where density fails. One possibility:
- If {neg(phi), G(neg(F'T)), H(neg(F'T)), G(neg(P'T)), H(neg(P'T))} is consistent (global discreteness), build countermodel on Int
- Otherwise, more complex mixed-order handling

**The exhaustiveness of dense + discrete for Archimedean groups means**: if {neg(phi)} is BX-consistent, either:
(a) {neg(phi)} has a model on Rat (dense) -- use dense case
(b) {neg(phi)} has a model on Int (discrete) -- use discrete case
(c) {neg(phi)} has a model on some other ordered abelian group -- but (a) or (b) already covers this IF the dichotomy is exhaustive for Archimedean groups AND every BX-model on a non-Archimedean group can be "collapsed" to one on an Archimedean group.

The last condition (collapsing non-Archimedean to Archimedean) is non-trivial and may require separate research.

**Actually, there's a simpler argument**: BX is sound w.r.t. ALL ordered abelian groups. If BX not derives phi, then the SYNTACTIC consistency of {neg(phi)} guarantees a model exists (by completeness -- which is what we're proving). The model we BUILD (on Rat or Int) is a specific Archimedean group. We don't need the model to exist on a specific group a priori; we CONSTRUCT it.

The case split is:
1. BX not derives phi
2. Check: is {neg(phi), density-formulas} BX-consistent?
3. If yes: build Rat model (dense case) -- this is a valid countermodel for `valid`
4. If no: BX derives neg(phi) -> neg(density). Then {neg(phi)} is still consistent, and in any MCS extending {neg(phi)}, density fails somewhere. Use discrete construction (Int) for the countermodel.

The gap in step 4: "density fails somewhere" does NOT mean "global discreteness holds". We'd need a more careful argument for the discrete case.

---

## Summary Table

| Question | Answer | Status |
|----------|--------|--------|
| C4 matches Burgess C4a? | YES, exactly | Verified |
| C4 with gamma=top, delta=bot gives density? | YES | Verified |
| DenselyOrdered from C4 + F'T? | YES, 3-line proof | Verified |
| Cantor iso restorable? | YES, minimal changes | Verified (archived code exists) |
| F'T as axiom -> propagation? | YES via TG + temp_4 | Verified |
| F'T in A0 only -> propagation? | NO, need G(F'T) + H(F'T) | Verified |
| Extension set consistency? | Must be checked case by case | Requires proof |
| Case-split exhaustiveness? | NOT trivial -- needs Archimedean argument | Open |
| Non-Archimedean collapse? | Unknown -- may need research | Open |

---

## Recommendations

### For the dense case specifically

The dense case is **solid and implementable**. The steps are:

1. Case-split on consistency of {neg(phi), F'T, P'T, G(F'T), H(F'T), G(P'T), H(P'T)}
2. If consistent: extend to MCS A0
3. Build chronicle from A0 (existing infrastructure, sorry-free)
4. Prove F'T in f(x) for all x (via limit_forward_G/backward_H + temp_4)
5. Prove limit_dom_dense (via C4 instantiation -- 5-line proof)
6. Prove DenselyOrdered LimitDomSubtype (3-line proof)
7. Restore Cantor iso from archive (10-15 hours)
8. Wire into dd_countermodel_chronicle

### For the overall case-split approach

Two open questions remain:
1. **Discrete case implementation**: How to build a countermodel on Int when density is inconsistent with neg(phi). This is a separate research question.
2. **Exhaustiveness of dense + discrete**: Must confirm that when neither {neg(phi), density-formulas} NOR {neg(phi), discreteness-formulas} is consistent, we have a contradiction. This follows from: if {neg(phi)} is consistent, extend to MCS M. In any model satisfying M, the domain D (as an Archimedean ordered abelian group) is either dense or discrete. So either the density formulas or the discreteness formulas hold in M. This means at least one of the two extensions is consistent. But this argument uses the COMPLETENESS THEOREM (any consistent set has a model) -- which is what we're trying to prove. CIRCULARITY.

**Breaking the circularity**: The case split needs to be SYNTACTIC (about derivability/consistency in BX), not SEMANTIC (about models). The syntactic version requires: from {neg(phi)} BX-consistent, derive that either the density extension or the discreteness extension is consistent. This is NOT automatic and requires a non-trivial consistency transfer argument.

### CRITICAL WARNING

The case-split approach has a **circularity risk**: proving that the two cases are exhaustive may require the completeness theorem itself. This needs careful analysis before committing to implementation.

### Alternative (may be needed)

If the exhaustiveness proof is circular, a possible fix:
- Prove BX + F'T + P'T is a CONSERVATIVE extension of BX (for formulas not mentioning Until/Since with specific patterns). Then completeness of BX + F'T + P'T for dense models gives completeness of BX for those formulas. Handle the Until/Since cases separately.
- Or: prove completeness for a RESTRICTED formula class first, then lift.

---

## Files Referenced

| File | Lines | Content |
|------|-------|---------|
| `Chronicle/ChronicleConstruction.lean` | 741-771 | `limit_satisfies_c4` signature and proof |
| `Chronicle/ChronicleConstruction.lean` | 1035-1080 | `limit_forward_G` proof |
| `Chronicle/ChronicleConstruction.lean` | 1089-1134 | `limit_backward_H` proof |
| `Chronicle/ChronicleToCountermodel.lean` | 74-153 | LimitDomSubtype instances |
| `Chronicle/ChronicleToCountermodel.lean` | 155-182 | BLOCKED status, dd_countermodel placeholder |
| `Boneyard/DenseChronicle/DenseLimitDomain.lean` | 36-88 | Archived limit_dom_dense + DenselyOrdered |
| `Boneyard/DenseChronicle/CantorIsoCountermodel.lean` | 48-102 | Archived Cantor iso pathway |
| `Boneyard/DenseChronicle/DenseCounterexampleElimination.lean` | 32-90 | Archived density CE kind |
| `ProofSystem/Axioms.lean` | 67-359 | Axiom inductive type |
| `ProofSystem/Derivation.lean` | 69-137 | DerivationTree constructors |
| `Semantics/Validity.lean` | 73-78 | `valid` definition |
| `Semantics/Validity.lean` | 162-186 | `valid_dense`, `valid_discrete` |
| `Metalogic/BXCanonical/Completeness.lean` | 128-151 | `bx_completeness` theorem |
