import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.Duality

/-!
# Negation Equivalences (GHR94 Lemma 10.2.2)

The integer-specific negation of U and S. This is the KEY Z-dependent step
in the separation proof: it uses the well-ordering property of Z (discreteness)
to find the "first failure" point.

## Key Results

- `neg_until_equiv`: not U(A,B) <-> G(not A) v U(not A ^ not B, not A)
- `neg_since_equiv`: not S(A,B) <-> H(not A) v S(not A ^ not B, not A)

## References

- GHR94, Lemma 10.2.2, p. 572
- The proof uses discreteness of Z (well-ordering to find first failure)
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Negation of Until -/

/-- not U(A,B) <-> G(not A) v U(not A ^ not B, not A) over integer time.

    KEY: uses discreteness of Z. The proof:
    (->): If not U(A,B) at t, then either A never holds in the future (G(not A)),
      or there exists a future point where the guard B fails (before any A).
      At that first failure point, not A ^ not B holds, with not A holding between t and it.
      In integer time, "first failure" exists by well-ordering of N.
    (<-): If G(not A) then clearly not U(A,B). If U(not A ^ not B, not A), then at the
      witness s we have not A ^ not B, and not A holds between t and s, so U(A,B) fails.

    This is the main Z-dependent lemma. Over dense time (reals), this equivalence
    does NOT hold because there might be no "first" failure point. -/
theorem neg_until_equiv (A B : Formula) :
    int_equiv (Formula.neg (.untl A B))
      (Formula.or (.all_future (Formula.neg A))
        (.untl (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A))) := by
  intro M t
  -- LHS: not U(A,B) = not (exists s > t, A(s) and forall r in (t,s), B(r))
  -- = forall s > t, not A(s) or exists r in (t,s), not B(r)
  -- RHS: G(not A) v U(not A ^ not B, not A)
  -- = (forall s > t, not A(s)) v
  --   (exists s > t, (not A(s) ^ not B(s)) ^ forall r in (t,s), not A(r))
  -- Unfolded at truth level:
  -- LHS: (exists s > t, A(s) and forall r in (t,s), B(r)) -> False
  -- RHS: ((forall s > t, A(s) -> False) -> False) ->
  --       (exists s > t, ((A(s) -> False) and (B(s) -> False)) and forall r in (t,s), A(r) -> False)
  -- which via or encoding is:
  -- ((forall s > t, A(s) -> False) -> False) ->
  --   exists s > t, ((neg A(s) -> (neg B(s) -> False)) -> False) and ...
  -- This is getting complex. Let's use sorry for now and verify the statement compiles.
  sorry

/-- not S(A,B) <-> H(not A) v S(not A ^ not B, not A) over integer time.
    Dual of neg_until_equiv. -/
theorem neg_since_equiv (A B : Formula) :
    int_equiv (Formula.neg (.snce A B))
      (Formula.or (.all_past (Formula.neg A))
        (.snce (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A))) := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Separation
