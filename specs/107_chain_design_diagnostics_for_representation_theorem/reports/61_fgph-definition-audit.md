# F/G/H/P Definition Audit: Primitives vs. Burgess Definitions

## Summary

G (all_future) and H (all_past) are **primitive constructors** of the Formula inductive type. F (some_future) and P (some_past) are **derived abbreviations** defined as duals: `F(phi) = neg(G(neg(phi)))`, `P(phi) = neg(H(neg(phi)))`. This design **differs from Burgess 1982**, where F and P are defined in terms of U and S (`F(alpha) = U(alpha, top)`, `P(alpha) = S(alpha, top)`), and G and H are derived as duals of F and P. The current system has two bridge axioms (BX12/BX12') that connect these worlds: `F(phi) -> untl(top, phi)` and `P(phi) -> snce(top, phi)`, plus BX10/BX10' providing the reverse for the event: `untl(phi, psi) -> F(psi)`. A full definitional equivalence `F(phi) <-> untl(top, phi)` is **not yet proven** but is derivable from existing axioms. Redefining F/P/G/H is **not recommended** due to extreme blast radius.

---

## Q1: How are F, P, G, H currently defined?

### G (all_future) and H (all_past): Primitive constructors

File: `Theories/Bimodal/Syntax/Formula.lean`, lines 66-83

```lean
inductive Formula : Type where
  ...
  | all_past : Formula -> Formula    -- H (line 76)
  | all_future : Formula -> Formula  -- G (line 78)
  | untl : Formula -> Formula -> Formula  -- U (line 80)
  | snce : Formula -> Formula -> Formula  -- S (line 82)
```

G and H are primitive inductive constructors with direct pattern-matching support across the entire codebase.

### F (some_future) and P (some_past): Derived abbreviations

File: `Theories/Bimodal/Syntax/Formula.lean`, lines 394-406

```lean
def some_past (phi : Formula) : Formula := phi.neg.all_past.neg    -- P = neg(H(neg(phi)))
def some_future (phi : Formula) : Formula := phi.neg.all_future.neg  -- F = neg(G(neg(phi)))
```

F and P are defined as De Morgan duals of G and H. They are `def`s, not constructors, so they cannot be pattern-matched and instead unfold to nested `imp`/`all_future`/`bot` expressions.

### Semantic definitions

File: `Theories/Bimodal/Semantics/Truth.lean`, lines 119-130

```lean
| Formula.all_past phi => forall (s : D), s < t -> truth_at M Omega tau s phi    -- H: strict past
| Formula.all_future phi => forall (s : D), t < s -> truth_at M Omega tau s phi  -- G: strict future
| Formula.untl phi psi => exists s : D, t < s /\ truth_at ... s psi /\ forall r, t < r -> r < s -> truth_at ... r phi
| Formula.snce phi psi => exists s : D, s < t /\ truth_at ... s psi /\ forall r, s < r -> r < t -> truth_at ... r phi
```

Semantics are irreflexive (strict `<`), not reflexive. G means "all strictly future times", U means "strict witness with open guard". This is the **A2 guard convention** throughout the project.

---

## Q2: How are U (Until) and S (Since) defined?

Yes, `Formula.untl` and `Formula.snce` are primitive constructors (lines 80-82 of Formula.lean). Their semantics match Burgess exactly:

- `U(phi, psi)` at t: there exists s > t with psi(s), and for all r with t < r < s, phi(r)
- `S(phi, psi)` at t: there exists s < t with psi(s), and for all r with s < r < t, phi(r)

**Key difference from Burgess**: In Burgess 1982, the argument order is `U(event, guard)` where the first argument is the eventuality and the second is the guard. In this codebase, the convention is `untl(guard, event)` -- **guard-first**. This is stated in comments but is critical to understand: `untl phi psi` means "phi holds as guard until psi (event) occurs."

Wait -- checking Burgess more carefully: Burgess defines `U(alpha, beta)` where semantically `V(U(alpha, beta)) = {x : exists y > x, y in V(alpha), forall z (x < z < y implies z in V(beta))}`. So Burgess's first argument is the **event** and second is the **guard**. The ProofChecker follows the same convention: `untl phi psi` has `psi` as event (witnessed at s) and `phi` as guard (on the open interval). Checking line 127: `exists s, t < s /\ truth_at ... s psi /\ forall r, t < r -> r < s -> truth_at ... r phi`. So `psi` is the event and `phi` is the guard. In terms of Burgess: `untl(phi, psi)` = `U(psi, phi)` in Burgess notation, or equivalently, the **guard is first, event is second** in the ProofChecker.

Actually, re-reading Burgess: `V(U(alpha, beta)) = {x : exists y(x < y, y in V(alpha), forall z(x < z < y => z in V(beta)))}`. Here `alpha` is the event (at witness y) and `beta` is the guard (on the interval). But in the codebase: `untl phi psi` has `phi` as guard and `psi` as event. So `untl(guard, event)` = Burgess's `U(event, guard)`. The arguments are **swapped** relative to Burgess. This is documented and consistent throughout.

---

## Q3: Does the current definition of F/G/H/P match Burgess?

**No.** The definitions are structurally different:

| Operator | Burgess 1982 | ProofChecker |
|----------|-------------|--------------|
| F(alpha) | `U(alpha, top)` -- defined via Until | `neg(G(neg(alpha)))` -- defined via G dual |
| P(alpha) | `S(alpha, top)` -- defined via Since | `neg(H(neg(alpha)))` -- defined via H dual |
| G(alpha) | `neg(F(neg(alpha)))` -- derived from F | Primitive constructor `all_future` |
| H(alpha) | `neg(P(neg(alpha)))` -- derived from P | Primitive constructor `all_past` |

The Burgess approach is "U/S are primitive, F/P are defined from U/S, G/H are defined from F/P." The ProofChecker approach is "G/H/U/S are all primitive constructors, F/P are derived from G/H."

### Semantic equivalence

Despite the definitional difference, the **semantic equivalence holds**: Under irreflexive semantics, `F(phi)` = `neg(G(neg(phi)))` = "there exists s > t with phi(s)" which is exactly `untl(top, phi)` = "there exists s > t with phi(s) and top holds on (t,s)." The guard condition `top` is vacuously true, so `F(phi) <-> untl(top, phi)` is semantically valid.

### Bridge axioms

The system has two axioms connecting F and U:

1. **BX10** (`until_F`): `untl(phi, psi) -> F(psi)` -- Until implies eventuality of event
2. **BX12** (`F_until_equiv`): `F(phi) -> untl(top, phi)` -- F implies Until with vacuous guard

Together, BX10 (with phi=top) + BX12 give: `F(phi) <-> untl(top, phi)`. But the **biconditional is not stated as a single theorem** in the codebase. The forward direction (BX12) is an axiom. The reverse direction is an instance of BX10 with the guard specialized to top.

### What is missing

A clean equivalence theorem:
```lean
theorem F_iff_untl_top (phi : Formula) : derives (iff (some_future phi) (untl top phi))
```
This is derivable from BX10 + BX12 but has not been stated or proved.

---

## Q4: Implications for the chronicle construction (task 107)

### How the chronicle construction uses these

The chronicle construction in `BXCanonical/Chronicle/` uses the bridge between F and U extensively:

1. **`limit_F_resolution`** (ChronicleConstruction.lean:635): When `F(phi) in f(x)`, applies BX12 to get `untl(top, phi) in f(x)`, then resolves the Until via C5_weak.

2. **`forward_G`** (ChronicleConstruction.lean:1105-1140): To show `G(phi) in f(x)` and `y > x` implies `phi in f(y)`, uses BX10 contrapositively: if `phi.neg in f(y)`, then `untl(top, phi.neg)` would give `F(phi.neg)`, contradicting `G(phi)`.

3. **`F_imp_top_until_mcs`** (CanonicalChain.lean:48): Lifts BX12 to MCS level.

4. **`ChronicleConstruction.lean:1526`**: Uses BX12 directly in RRelation proofs.

### The critical question: Is BX10 derivable from definitions?

In Burgess's system where `F(alpha) := U(alpha, top)`, the analogue of BX10 (`U(phi, psi) -> F(psi)`) is NOT a trivial definitional consequence. It requires the axioms (specifically, it follows from the fact that if `U(phi, psi)` holds with witness s, then `U(psi, top)` holds with the same witness s). In Burgess's system, this would still need A2a (right monotonicity) or similar reasoning.

In the ProofChecker, BX10 is an independent axiom regardless of how F is defined. Even if F were redefined as `untl(top, phi)`, BX10 would still need to be proved: the content is that the event of any Until can be extracted as an eventuality. This is a genuine axiom about Until, not about F.

### Impact on task 107

The definitional structure does **not** block the chronicle construction. The bridge axioms BX10 and BX12 are already in place and are used correctly. The chronicle construction never relies on F being definitionally equal to `untl(top, phi)` -- it always goes through the axioms.

---

## Q5: Should F/P/G/H be redefined in terms of U/S?

### Recommendation: **Do not redefine.** The costs vastly outweigh the benefits.

### Benefits of redefining (small)

1. **Closer to Burgess**: Would make the formalization track the paper more directly.
2. **One fewer axiom**: BX12 (`F(phi) -> untl(top, phi)`) would become trivial by definition. BX10 would still be needed.
3. **Conceptual simplicity**: F is "really" a special case of U.

### Costs of redefining (catastrophic)

1. **Blast radius**: G (all_future) and H (all_past) are **primitive constructors** pattern-matched in 133 match arms across the codebase. Every `match` on `Formula` would break because:
   - G/H would no longer be constructors; they'd be abbreviations for `neg(untl(top, neg(phi)))` and `neg(snce(top, neg(phi)))`.
   - Every function defined by structural recursion on Formula (complexity, modalDepth, temporalDepth, subformulas, atoms, swap_temporal, beq_refl, eq_of_beq, etc.) would need to handle G/H as nested imp/untl/bot patterns instead of simple constructor arms.

2. **File count**: At least 82 files reference `all_future` and 68 files reference `all_past`. That is the majority of the codebase.

3. **Semantic definition**: `truth_at` defines G/H semantics by direct structural recursion. If G becomes `neg(untl(top, neg(phi)))`, then `truth_at` for G would need to unfold through imp/bot/untl, making proofs far more complex.

4. **Sorry-free proofs would break**: Existing sorry-free proofs (soundness lemmas, time-shift preservation, swap_temporal properties) depend on pattern-matching `all_future`/`all_past` as constructors. Every single one would need rewriting.

5. **Structural recursion**: Lean's equation compiler recognizes `all_future` as a constructor for termination checking. Derived operators cannot participate in structural recursion patterns.

6. **Estimated effort**: 200+ hours of rewriting across 80+ files, with high risk of introducing new sorry obligations.

### Alternative approach (recommended)

Instead of redefining, add explicit equivalence theorems:

```lean
-- Already derivable from BX10 + BX12
theorem F_iff_untl_top (phi : Formula) :
    derives (iff (some_future phi) (untl (bot.imp bot) phi))

theorem P_iff_snce_top (phi : Formula) :
    derives (iff (some_past phi) (snce (bot.imp bot) phi))

-- G/H characterization (from BX10 + contraposition)
theorem G_iff_neg_untl_top_neg (phi : Formula) :
    derives (iff (all_future phi) (neg (untl (bot.imp bot) (neg phi))))
```

These theorems let any proof that needs the Burgess relationship use it as an equivalence, without disrupting the constructor-based infrastructure.

---

## Q6: Existing equivalence theorems

### Already proven (sorry-free)

| Theorem | Location | Direction |
|---------|----------|-----------|
| `until_implies_some_future` | TemporalDerived.lean:199 | `untl(phi,psi) -> F(psi)` (BX10) |
| `since_implies_some_past` | TemporalDerived.lean:207 | `snce(phi,psi) -> P(psi)` (BX10') |
| `until_imp_F` | TemporalDerived.lean:273 | Same as above (duplicate) |
| `since_imp_P` | TemporalDerived.lean:281 | Same as above (duplicate) |
| `F_until_equiv_valid` | Soundness.lean:385 | Semantic validity of BX12 |
| `P_since_equiv_valid` | Soundness.lean:399 | Semantic validity of BX12' |
| `F_imp_top_until_mcs` | CanonicalChain.lean:48 | BX12 lifted to MCS level |
| `P_imp_top_since_mcs` | CanonicalChain.lean:57 | BX12' lifted to MCS level |

### Not yet proven (but derivable)

| Theorem | Status | How to derive |
|---------|--------|---------------|
| `F_iff_untl_top` (biconditional) | Missing | BX12 + BX10(phi:=top) |
| `P_iff_snce_top` (biconditional) | Missing | BX12' + BX10'(phi:=top) |
| `G_iff_neg_untl_top_neg` | Missing | Contraposition of F_iff_untl_top |
| `H_iff_neg_snce_top_neg` | Missing | Contraposition of P_iff_snce_top |

### Sorry-stubbed (related, not directly equivalences)

| Theorem | Location | Status |
|---------|----------|--------|
| `refl_F` (alpha -> F(alpha)) | TemporalDerived.lean:427 | Sorry -- invalid under irreflexive semantics |
| `refl_P` (alpha -> P(alpha)) | TemporalDerived.lean:436 | Sorry -- invalid under irreflexive semantics |
| `G_implies_topUntil` (G(a) -> untl(top, a)) | TemporalDerived.lean:174 | Sorry -- required BX8 (removed) |

Note: `refl_F` and `refl_P` are **genuinely invalid** under irreflexive semantics (the current time does not witness F/P). The sorry stubs are correct annotations of unprovable statements.

---

## Conclusion

The current design (G/H primitive, F/P derived as duals) is well-suited to the Lean formalization and has deep structural integration across 80+ files. The Burgess definitional relationship (F = U(top, _)) is captured by the BX10/BX12 axiom pair, which provides the bidirectional bridge needed for the chronicle construction.

**Action items** (low priority, not blocking task 107):

1. Add `F_iff_untl_top` and `P_iff_snce_top` biconditional theorems to TemporalDerived.lean -- straightforward from existing axioms.
2. Add `G_iff_neg_untl_top_neg` and `H_iff_neg_snce_top_neg` for documentation completeness.
3. No changes to the Formula inductive type, semantics, or axiom system.
