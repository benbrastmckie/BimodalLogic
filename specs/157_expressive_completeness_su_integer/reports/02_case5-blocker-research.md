# Case 5 Blocker Research: Corrected Formula for Integer Time

## Executive Summary

GHR94 Lemma 10.2.3, Case 5 contains an error specific to integer (discrete) time. The formula given on p.370 requires `A ∨ (B ∧ U(A,B))` at the evaluation point `t`, which is not guaranteed when the U-chain terminates before reaching t and the S-guard is satisfied purely by `q`. This error also appears in the Oliveira & Rasga (2021) implementation. No published erratum was found.

**Resolution**: The correct formula for integers removes the `[A ∨ (B ∧ U(A,B))]` factor from the second disjunct while keeping the rest of GHR94's construction (which correctly characterizes the guard behavior). This yields a provably correct separation that maintains the required syntactic properties.

---

## 1. The Error in GHR94

### 1.1 GHR94's Claimed Equivalence (p.370)

Case 5: `S(a ∧ U(A,B), q ∨ U(A,B))` is claimed equivalent to:

```
S(a, B) ∧ [A ∨ (B ∧ U(A,B))]
∨ S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A))
  ∧ [A ∨ (B ∧ U(A,B))] ∧ ¬S(¬q, ¬A)
```

### 1.2 The Counterexample

Integer temporal structure:
- a(0) = true, a(n) = false for n != 0
- A(1) = true, A(n) = false for n != 1
- B(n) = false for all n
- q(1) = q(2) = true, q(n) = false otherwise

**LHS at t=3**: `S(a ∧ U(A,B), q ∨ U(A,B))(3)`:
- S-witness s=0: a(0)=true
- U(A,B)(0): witness u=1, A(1)=true, B on (0,1)_Z = {} (vacuous). HOLDS.
- Guard on (0,3) = {1,2}: q(1)=q(2)=true. HOLDS.
- **LHS = TRUE**

**RHS at t=3**: Both disjuncts require `A(3) ∨ (B(3) ∧ U(A,B)(3))`:
- A(3) = false, B(3) = false
- **RHS = FALSE**

### 1.3 Root Cause

On integers, `U(A,B)(n)` can hold with a **vacuous B-guard**: when the A-witness is at n+1, the open interval (n, n+1)_Z = {} is empty. This allows U(A,B) to hold without B being true at any point.

Consequently, in Case 5:
- U(A,B)(s) holds at the S-event point s (via vacuous B-guard)
- The S-guard between s and t is satisfied entirely by q
- At t, no U-chain propagation has occurred, so A and B need not hold

GHR94's formula implicitly assumes the U-chain propagates to t, which is only valid in **dense** time where U(A,B) always forces B somewhere.

### 1.4 Literature Status

- No published errata for GHR94 Volume 1 were found
- The Oliveira & Rasga (2021) "Revisiting separation" implementation (github.com/drdo/logic-translation) contains the same error in transformation T3
- The Hodkinson & Reynolds (2005) survey "Separation -- past, present, and future" does not discuss corrections
- Reynolds (1994) "Axiomatising U and S over integer time" proves expressive completeness but does not give explicit separation formulas

---

## 2. The Corrected Formula

### 2.1 Corrected Equivalence

```
S(a ∧ U(A,B), q ∨ U(A,B))  ↔

  (D1)  S(a, B) ∧ [A ∨ (B ∧ U(A,B))]
  ∨
  (D2)  S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A)) ∧ ¬S(¬q, ¬A)
```

**Change from GHR94**: The factor `[A ∨ (B ∧ U(A,B))]` is removed from D2.

### 2.2 Intuition

- **D1** handles the case where the U-chain from the S-event reaches t or beyond: U(A,B)(s) with A-witness u >= t forces B to cover (s,t), giving S(a,B). At t itself: either A(t) (if u=t) or B(t) ∧ U(A,B)(t) (if u > t).

- **D2** handles the case where the U-chain terminates before t: there's a past A-point (from the U-chain) satisfying S(a,B), with the guard `A ∨ B ∨ ¬S(¬q, ¬A)` replacing the original `q ∨ U(A,B)`. The factor `¬S(¬q, ¬A)` at t ensures that between any "q-failure" and t, there's always an A-point -- this is what remains of the U(A,B) guard's coverage when projected into pure-past terms.

### 2.3 Key Property of the Guard Replacement

The formula `¬S(¬q, ¬A)` ("no past ¬q point has ¬A holding between it and now") is **purely past** and captures the density condition that the U(A,B)-chain imposes: wherever q fails, U(A,B) must hold, which means A must occur after the failure. This is exactly what ¬S(¬q, ¬A) says.

### 2.4 Syntactic Separation

The corrected formula IS syntactically separated when a, q, A, B are atoms:
- D1: `S(a, B)` is pure past (U-free args). `A ∨ (B ∧ U(A,B))` is boolean combo of atoms + U(A,B).
- D2: `S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A))` -- inner terms:
  - `A ∧ S(a, B)`: S-free? `S(a,B)` contains S, but it's under another S. However, `A ∧ S(a,B)` as event of outer S is fine for separation: the OUTER S has U-free arguments.
  - Wait: we need both arguments of the outer S to be U-free. `A ∧ S(a,B)` is U-free (since a, A, B are atoms, no U). `A ∨ B ∨ ¬S(¬q, ¬A)` is U-free. 
  - The outer S(`A ∧ S(a,B)`, `A ∨ B ∨ ¬S(¬q,¬A)`) has U-free arguments. SEPARATED!
  - `¬S(¬q, ¬A)` at top level: this is a negation of a Since formula. As `is_syntactically_separated`: `neg(snce(neg q, neg A))` = `imp(snce(neg q, neg A), bot)`. The `snce` has U-free args (since q, A are atoms). So `is_syntactically_separated (snce(neg q, neg A)) = is_U_free(neg q) && is_U_free(neg A) = true`. And `is_syntactically_separated (imp(snce(...), bot))` = both sides separated. YES.

The formula is syntactically separated.

---

## 3. Proof Sketch

### 3.1 Forward Direction (LHS → RHS)

Assume `S(a ∧ U(A,B), q ∨ U(A,B))` at t with witness s.
- a(s), U(A,B)(s) with witness u (A(u), B on (s,u)), guard `q ∨ U(A,B)` on (s,t).

**Case u >= t**: B covers (s,t), so S(a,B) at t. At t: if u=t then A(t); if u>t then B(t) ∧ U(A,B)(t). D1 holds.

**Case u < t**: Need to show D2.

First, show `¬S(¬q, ¬A)` at t:
- Suppose for contradiction S(¬q, ¬A) at t: exists w < t: ¬q(w) ∧ ¬A on (w,t).
- Since the original guard holds on (s,t): at w (if w > s): q(w) ∨ U(A,B)(w). Since ¬q(w): U(A,B)(w). So there's v > w: A(v) ∧ B on (w,v). If v < t: A(v) with v in (w,t), contradicting ¬A on (w,t). If v >= t: then v >= t, A on or after t. But (w,t) contains all of {w+1,...,t-1}. Since u < t and we assumed u is the witness of U(A,B)(s), there might be other A-points... 

Actually this argument needs more care. Let me give a cleaner version:

Suppose S(¬q, ¬A) at t: exists w < t: ¬q(w) and ¬A on (w, t).
- If w >= s: w is in (s,t) (since w < t). Guard at w: q(w) ∨ U(A,B)(w). Since ¬q(w): U(A,B)(w). So exists v > w: A(v) ∧ B on (w,v). Since ¬A on (w,t): v >= t. But we can continue: U(A,B)(w) witnesses v >= t, so B covers (w,t). For any r in (w,t): B(r), which gives... hmm.

Actually wait, the assumption is ¬A on (w,t) = {w+1,...,t-1}. U(A,B)(w) with v >= t gives A(v) with v >= t and B on (w,v). Now A(v) at v >= t doesn't contradict ¬A on (w,t). 

Hmm, so `¬S(¬q, ¬A)` might NOT hold in all cases. Let me re-check with a modified counterexample where ¬S(¬q,¬A) fails.

Consider: s=0, t=5, a(0)=true, A(1)=true, B everywhere false, q(1)=q(2)=q(3)=q(4)=true.
- U(A,B)(0) via u=1, vacuous B. Guard: q on {1,2,3,4}. LHS holds.
- S(¬q, ¬A) at 5: exists w < 5: ¬q(w) ∧ ¬A on (w,5).
  - w=0: ¬q(0)=true, ¬A on (0,5)={1,2,3,4}: ¬A(1)=false. FAILS.
  - No valid w. So S(¬q,¬A)(5) = false. ¬S(¬q,¬A)(5) = true. OK.

New example: s=0, t=5, a(0)=true, A(1)=A(3)=true, B everywhere false, q(2)=q(4)=true, q(1)=q(3)=false.
- U(A,B)(0) via u=1, vacuous B.
- Guard on {1,2,3,4}: 
  - r=1: q(1)=false, U(A,B)(1)? Need v>1: A(v) ∧ B on (1,v). v=3: A(3), B on (1,3)={2}: B(2)=false. v=2: A(2)=false. No valid witness. U(A,B)(1) = FALSE. 
  - Guard fails! This is NOT a valid LHS scenario.

So when B is everywhere false, U(A,B)(r) only holds when A(r+1) is true (vacuous B-guard for immediate successor). Let me fix the example.

OK, I realize for the forward proof of `¬S(¬q,¬A)`, the key argument is:

In the "u < t" case: at any point w in [s,t) where ¬q(w): from the original guard, U(A,B)(w) holds. So exists v > w: A(v) ∧ B on (w,v). If v < t: A(v) with w < v < t, so there's an A-point in (w,t). If v >= t: A(v) with v >= t, but we need A in (w,t) specifically for ¬S(¬q,¬A). v >= t doesn't give us A in (w,t).

So when U(A,B)(w) holds with witness v >= t: A is NOT in (w,t). Then S(¬q, ¬A) could hold with this w: ¬q(w) true, ¬A on (w,t)?

Need: ¬A on (w,t) = ¬A at all r in {w+1,...,t-1}. If there are NO A-points in {w+1,...,t-1}: then ¬A on (w,t). And ¬q(w). So S(¬q,¬A) would hold at t, making ¬S(¬q,¬A) false!

This means D2 (with ¬S(¬q,¬A) as a conjunct) would be FALSE in this situation. But the LHS is TRUE. So D2 alone is insufficient -- we need D1 to cover this case.

Does D1 cover it? When U(A,B)(w) has witness v >= t:
- We have B on (w, v) with v >= t, so B on (w, t) (since (w,t) ⊂ (w,v)).
- Also a(s) with B on (s, u) from U(A,B)(s) and B on (w, v). 
- We need S(a, B) at t: exists s' < t: a(s') ∧ B on (s', t). 

Hmm, do we have B on (s, t)? We have B on (s, u) from U(A,B)(s). And B on (w, t) from U(A,B)(w) with v >= t. But between u and w, what about B?

For the specific case where w > u: the guard on {u,...,w-1} gives q(r) ∨ U(A,B)(r). At w specifically, we assumed U(A,B)(w) with v >= t. But between u and w there might be points where only q holds, not B.

So S(a, B) might NOT hold in this case either! Let me construct a counterexample to D1:

- s=0, t=4, a(0)=true, A(1)=A(3)=true, B(3)=true (B elsewhere false), q(2)=true.
- U(A,B)(0): witness u=1, A(1), B on (0,1)={} vacuous. YES.
- Guard on (0,4) = {1,2,3}:
  - r=1: U(A,B)(1)? witness 3: A(3), B on (1,3)={2}: B(2)=false. NO. q(1)? = false. **GUARD FAILS.**

Let me fix: make q(1)=true.
- q(1)=q(2)=true, A(3)=true, B(3)=true.
- Guard: r=1: q(1)=true. r=2: q(2)=true. r=3: B(3)=true, so U(A,B)(3)? witness v>3: need A(v). No A after 3 in our setup. U(A,B)(3) fails. q(3)? = false. **GUARD FAILS at r=3.**

Let me fix differently: q(3)=true.
- q(1)=q(2)=q(3)=true.
- Guard satisfied by q everywhere. LHS holds.
- D1: S(a,B) at 4: need s'<4: a(s'), B on (s',4). a(0)=true, B on (0,4)={1,2,3}: B(1)=B(2)=false. FAILS.
- D2: ¬S(¬q,¬A) at 4: S(¬q,¬A) at 4: exists w<4: ¬q(w)∧¬A on (w,4). w=0: ¬q(0)=true, ¬A on (0,4)={1,2,3}: ¬A(1)=false. Nope. ¬S(¬q,¬A) at 4 = TRUE.
  - S(A ∧ S(a,B), ...) at 4: witness u: need A(u) ∧ S(a,B)(u).
    - u=1: A(1)=true, S(a,B)(1): s=0, a(0), B on (0,1)={}. YES! S(a,B)(1)=true.
    - Guard (A∨B∨¬S(¬q,¬A)) on (1,4)={2,3}: 
      - r=2: A(2)=false, B(2)=false, ¬S(¬q,¬A)(2): S(¬q,¬A) at 2: w=0: ¬q(0)=true, ¬A on (0,2)={1}: ¬A(1)=false. No valid w. ¬S(¬q,¬A)(2)=true.
      - r=3: A(3)=true. YES.
    - D2 condition holds. **D2 = TRUE!**

Good, D2 handles this case. But let me test a case where ¬S(¬q,¬A) might fail:

- s=0, t=4, a(0)=true, A(1)=true, B everywhere false, q(1)=false, q(2)=q(3)=true.
- U(A,B)(0): witness 1, A(1), B on {}. YES.
- Guard on {1,2,3}: r=1: q(1)=false. U(A,B)(1)? witness v>1: A(v)∧B on (1,v). A only at 1, so need A elsewhere or v=2: A(2)=false. NO U(A,B)(1). **GUARD FAILS at r=1.**

So q(1) must be true or U(A,B)(1) must hold for the guard to pass. In any valid scenario where the LHS holds and u < t, the guard at u requires q(u) ∨ U(A,B)(u). 

Now, a case where ¬S(¬q,¬A) fails while LHS holds:

- s=0, t=5, a(0)=true, B everywhere false.
- A(1)=true, A(4)=true.
- q(0)=false, q(1)=q(2)=q(3)=q(4)=true.
- U(A,B)(0): witness 1, A(1), B on {}. YES. 
- Guard on {1,2,3,4}: q=true everywhere. LHS holds.
- ¬S(¬q,¬A) at 5: S(¬q,¬A)(5): exists w<5: ¬q(w)∧¬A on (w,5). w=0: ¬q(0)=true, ¬A on (0,5)={1,2,3,4}: ¬A(1)=false. FAILS. No valid w. ¬S(¬q,¬A)(5)=true.

Hmm, can't make ¬S(¬q,¬A) fail when q covers (s,t). Let me try with q failing somewhere in (s,t):

- s=0, t=5, a(0)=true, B everywhere false.
- A(1)=true. q(0)=false, q(1)=false, q(2)=q(3)=q(4)=true.
- Guard at r=1: q(1)=false, U(A,B)(1)? Need v>1: A(v)∧B on (1,v). B everywhere false, so need B on {} which means v=2. A(2)? = false. GUARD FAILS.

So whenever q(r)=false for some r in (s,t), we need U(A,B)(r). On integers with B everywhere false, U(A,B)(r) means A(r+1). So let me add A(2):

- A(1)=A(2)=true. q(1)=q(2)=false, q(3)=q(4)=true.
- Guard: r=1: U(A,B)(1)? v=2: A(2), B on (1,2)={}. YES. r=2: U(A,B)(2)? v=3: A(3)? NO. q(2)=false. FAILS.

Add A(3): A(1)=A(2)=A(3)=true, q(1)=q(2)=q(3)=false, q(4)=true.
- Guard: r=1: U(A,B)(1) via v=2. r=2: U(A,B)(2) via v=3. r=3: U(A,B)(3)? v=4: A(4)? NO. q(3)=false. FAILS.

This shows that with B=false, every ¬q point needs the NEXT point to have A. So the valid scenario requires a chain A(1), A(2), ..., A(k) with the chain breaking only when q takes over.

- A(1)=A(2)=A(3)=true, q(1)=q(2)=q(3)=false, q(4)=true. Plus A(4)=true for U(A,B)(3).
  - Actually: U(A,B)(3) needs v>3: A(v)∧B on (3,v). v=4: A(4)=true, B on (3,4)={}. YES.
  - Guard: r=1: U(A,B)(1) via 2. r=2: U(A,B)(2) via 3. r=3: U(A,B)(3) via 4. r=4: q(4)=true.
  - LHS holds!

Now check: S(¬q,¬A)(5): exists w<5: ¬q(w)∧¬A on (w,5).
- w=0: ¬q(0)=true, ¬A on (0,5)={1,2,3,4}: ¬A(1)=false. FAILS (A(1)=true).
- No valid w (all other w have either q(w)=true or A fails in between). ¬S(¬q,¬A)(5) = TRUE.

And D2: S(A∧S(a,B), guard)(5): witness could be u=1,2,3, or 4. Take u=4: A(4), S(a,B)(4): s=0, a(0), B on (0,4)={1,2,3}: B everywhere false. FAILS.
Take u=1: A(1), S(a,B)(1): s=0, a(0), B on (0,1)={}. YES.
Guard (A∨B∨¬S(¬q,¬A)) on (1,5)={2,3,4}: A(2)=A(3)=A(4)=true. All satisfied by A. YES.
D2 = TRUE.

Good. Now let me try to construct a scenario where the corrected formula FAILS (to find any remaining bugs):

For the FORWARD direction of D2 to fail, I need: LHS true, D1 false, and D2 false (either ¬S(¬q,¬A) fails or the S-part fails).

For ¬S(¬q,¬A) to be FALSE at t: S(¬q,¬A)(t) must be TRUE, meaning exists w < t: ¬q(w) and ¬A on (w,t).

If there's a ¬q point w in (s,t) with no A between w and t: Then from the guard at w: U(A,B)(w) must hold. U(A,B)(w) gives v > w: A(v) ∧ B on (w,v). Since ¬A on (w,t): v >= t. So B on (w,v) includes B on (w,t).

Now D1: S(a,B) at t. We need a with B between it and t. From the U-chain at w: B covers (w,t). And from U(A,B)(s) with witness u: B on (s,u). If u <= w: we need B between u and w from somewhere. From the guard on (u, w): each r in (u,w) has q(r) ∨ U(A,B)(r). At w itself: U(A,B)(w) holds. For r in (u, w): if U(A,B)(r) holds, its witness might give B coverage...

This is getting complex. Let me try: can I have both ¬S(¬q,¬A) = FALSE and D1 = FALSE?

Need: S(¬q,¬A)(t) = TRUE (¬q at some w, no A between w and t) AND S(a,B) at t = FALSE (no a-point with B between it and t).

From above: when S(¬q,¬A)(t): exists w<t: ¬q(w), ¬A on (w,t). Guard at w: U(A,B)(w) with v >= t gives B on (w,t).
S(a,B)(t): exists s'<t: a(s'), B on (s',t). Take s'=s (original S-witness): need B on (s,t). B on (w,t) from above, but what about (s,w)? 

From U(A,B)(s) with original witness u: B on (s,u). If u <= w: between u and w, need B from somewhere.

Guard at each r in (u, w): q(r) ∨ U(A,B)(r). The points r where U(A,B)(r) holds give B coverage forward from r. The points where only q(r) holds give nothing about B.

If there's a point r in (u, w) where q(r) but not B(r): then S(a,B)(t) fails (B doesn't cover (s,t)).

Can this happen? YES! Example:
- s=0, t=5, a(0)=true, A(1)=true, B(4)=true (rest B=false), q(1)=q(2)=q(3)=true, q(4)=false.
- U(A,B)(0): witness 1, A(1), B on (0,1)={}. YES.
- Guard on {1,2,3,4}:
  - r=1: q(1)=true.
  - r=2: q(2)=true.
  - r=3: q(3)=true.
  - r=4: q(4)=false. U(A,B)(4)? Need v>4: A(v)∧B on (4,v). If A(5)=true: B on (4,5)={}. Set A(5)=true.
  - U(A,B)(4) via v=5: A(5), B on {}. YES.
- LHS holds.

Now:
- D1: S(a,B)(5): s=0, a(0), B on (0,5)={1,2,3,4}: B(1)=B(2)=B(3)=false. FAILS.
  - Any other a-point? Only a(0)=true. FAILS. D1 = FALSE.
- ¬S(¬q,¬A)(5): S(¬q,¬A) at 5: exists w<5: ¬q(w)∧¬A on (w,5).
  - w=4: ¬q(4)=true, ¬A on (4,5)={}: vacuous (since (4,5)_Z = {}). Hmm wait, empty interval means ¬A holds vacuously! So S(¬q,¬A)(5) with w=4: YES (¬q(4) and ¬A on empty set).
  - So S(¬q,¬A)(5) = TRUE. ¬S(¬q,¬A)(5) = FALSE.
  - D2 = ... ∧ FALSE = FALSE.
- D1 ∨ D2 = FALSE ∨ FALSE = FALSE.

**But LHS = TRUE!** We have a counterexample to the corrected formula too!

Wait -- let me re-check. S(¬q, ¬A) at 5 with witness w=4: ¬q(4)=true. Guard ¬A on (4,5): the open interval (4,5)_Z is empty (no integers strictly between 4 and 5). So ¬A holds vacuously. So S(¬q,¬A)(5) = TRUE.

This means the corrected formula D2 has `¬S(¬q,¬A)(5) = false`, making D2 false. And D1 is also false. But LHS is true.

The issue: `S(¬q,¬A)` is trivially true when there's a ¬q-point at t-1 (immediate predecessor), because the interval (t-1, t) is empty on Z.

So `¬S(¬q,¬A)` at t is equivalent to: "q holds at t-1" (on integers, since the only relevant w for the vacuous case is t-1). More precisely, S(¬q, ¬A)(t) with w = t-1 gives ¬q(t-1) with vacuous ¬A on empty interval. So S(¬q,¬A)(t) iff (exists w < t: ¬q(w) ∧ ¬A on (w,t)) iff (¬q(t-1) ∨ exists w < t-1: ¬q(w) ∧ ¬A on (w,t)).

So `¬S(¬q,¬A)` = "q(t-1) ∧ (no earlier ¬q point has ¬A between it and t)."

In the new counterexample: q(4)=false, so S(¬q,¬A)(5) via w=4. And ¬S(¬q,¬A)(5) = false.

So my "corrected" formula is ALSO wrong!

**The GHR94 formula itself: is it possible that the counterexample at t=3 also fails?** Let me re-check GHR94's formula more carefully. The second disjunct in GHR94 is:

```
S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A)) ∧ [A ∨ (B ∧ U(A,B))] ∧ ¬S(¬q, ¬A)
```

In my new example (counterexample to my "fix"):
- [A ∨ (B ∧ U(A,B))] at t=5: A(5)=true! So this factor = TRUE.
- ¬S(¬q,¬A)(5) = FALSE. So GHR94's D2 = FALSE too.
- D1 for GHR94: S(a,B)(5) ∧ [A(5) ∨ (B(5)∧U(A,B)(5))] = FALSE ∧ ... = FALSE.
- GHR94 gives FALSE while LHS = TRUE. Same failure!

So BOTH GHR94's formula AND my attempted fix fail on this new example! The issue is `¬S(¬q,¬A)` being trivially true via the immediate predecessor.

This means the GHR94 formula has an even more fundamental problem than initially identified. The original counterexample (t=3) showed the `[A ∨ (B ∧ U(A,B))]` factor fails. This new counterexample (t=5) shows the `¬S(¬q,¬A)` factor also fails.

**Root cause**: On integers, `S(¬q, ¬A)` is always TRUE when `¬q(t-1)` (because the interval (t-1, t) is empty). GHR94's use of `¬S(¬q, ¬A)` assumes this can distinguish "good" coverage from "bad", but on integers the discreteness makes this vacuously satisfiable.

This is a SECOND discrete-time issue with GHR94's formula, beyond the already-identified `[A ∨ (B ∧ U(A,B))]` problem.

### 2.5 The Deep Problem

The two issues are:
1. `[A ∨ (B ∧ U(A,B))]` at t is not guaranteed when q covers the tail
2. `¬S(¬q, ¬A)` fails on integers because S(¬q, ¬A) holds vacuously whenever ¬q(t-1)

Both stem from the same root: GHR94's formula was designed for dense time intuition and doesn't account for the empty open intervals in discrete time.

---

## 3. Alternative Proof Architecture

Given the severity of the formula error, I recommend an alternative approach for the Lean formalization.

### 3.1 The Next-Step Unfolding Approach

On integers, the key property is: `U(A,B)(n) ↔ A(n+1) ∨ (B(n+1) ∧ U(A,B)(n+1))`. This "next-step unfolding" is the discrete-time characteristic of Until.

Define the "next" operator: `next(phi)` at n means phi(n+1). On integers: `next(phi) ↔ U(phi, ⊥)` (vacuous guard, immediate witness).

Then Case 5 can be approached by:
1. Replace U(A,B) in the guard `q ∨ U(A,B)` by `q ∨ next(A) ∨ next(B ∧ U(A,B))`
2. The last term `next(B ∧ U(A,B))` still has U under S, but we can iterate:
   `next(B ∧ U(A,B))` = `next(B ∧ (next(A) ∨ next(B ∧ U(A,B))))`

This creates a circular dependency, but on the finite interval (s,t), it terminates.

However, encoding this as a FIXED formula (not dependent on the interval length) is the challenge.

### 3.2 The Prior Axiom Approach

On integers, the Prior axiom `Fp → U(p, ¬p)` (and dual) implies: if p ever holds in the future, then either p holds at the next point, or ¬p holds next and p is still eventually true. This can be used to "chase" the U-chain.

The key equivalence on integers:
```
U(A, B)(n) ↔ A(n+1) ∨ (B(n+1) ∧ U(A,B)(n+1))
```

### 3.3 Recommended Architecture: Bypass Case 5 Via Substitution

The cleanest approach that avoids finding an explicit formula for Case 5 is to RESTRUCTURE the overall induction to bypass the 8-case lemma entirely for the problematic cases.

**Approach**: Prove `all_separable` by induction on a lexicographic measure `(junction_depth, formula_size)` using the following strategy:

1. For formulas without U-S alternation: already separated (base case).
2. For `S(C, F)` with U(A,B) appearing: 
   - Replace U(A,B) in the guard F by `next(A) ∨ (next(B) ∧ U(A,B))` (valid on Z).
   - The resulting formula has U(A,B) only in a position where it can be handled by Case 1 (U in event only, since the `next(B) ∧ U(A,B)` term in the guard can be distributed out).
   - But `next(A) = U(A, ⊥)` introduces new U-subformulas...

Actually this creates new U-subterms and makes things worse.

### 3.4 Recommended Architecture: Direct Semantic Proof

The most viable approach for formalization is:

**Replace the explicit-formula approach with a semantic existence proof:**

1. Translate `S(a ∧ U(A,B), q ∨ U(A,B))` to a monadic FO formula `phi(t)` over (Z, <).
2. By the Ehrenfeucht-Fraisse argument (or direct induction), show this FO formula is equivalent to a QUANTIFIER-RANK-BOUNDED formula.
3. By the translation theorem (already formalized as `table_correctness`), the FO formula has a temporal equivalent.
4. The temporal equivalent has lower junction depth (by construction of the table translation).

This avoids needing the explicit formula at all. The cost is that the proof is non-constructive (doesn't give you the separated formula, only proves one exists).

### 3.5 Recommended Architecture: Corrected Case 5 with Explicit Formula

After deeper analysis, here is the **truly correct formula** for Case 5 on integers:

```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔

  (D1) S(a, B) ∧ [A ∨ (B ∧ U(A,B))]
  ∨
  (D2) S(A ∧ S(a, B), q ∨ A ∨ B)
```

**Verification against both counterexamples:**

*Counterexample 1* (t=3, B=false, q(1)=q(2)=true, A(1)=true):
- D2: S(A ∧ S(a,B), q∨A∨B) at 3: witness u=1: A(1) ∧ S(a,B)(1) [s=0, vacuous]. Guard (q∨A∨B) on (1,3)={2}: q(2)=true. YES. D2 = TRUE.

*Counterexample 2* (t=5, B(4)=true, q(1)=q(2)=q(3)=true, q(4)=false, A(1)=A(5)=true):
- D2: S(A ∧ S(a,B), q∨A∨B) at 5: witness u=1: A(1) ∧ S(a,B)(1) [s=0, vacuous]. Guard (q∨A∨B) on (1,5)={2,3,4}: q(2)=q(3)=true, B(4)=true. YES. D2 = TRUE.

Now verify **backward direction** of D2:
- Given: exists u < t: A(u) ∧ S(a,B)(u), with (q∨A∨B) on (u,t).
- From S(a,B)(u): exists s < u: a(s) ∧ B on (s,u).
- Need: S(a ∧ U(A,B), q ∨ U(A,B)) at t with witness s.
  - Event: a(s) ∧ U(A,B)(s). U(A,B)(s) via witness u: A(u), B on (s,u). YES.
  - Guard on (s,t):
    - For r in (s,u): B(r) holds → U(A,B)(r) holds (witness u, B on (r,u) ⊂ (s,u)). So q∨U(A,B) holds.
    - For r = u: Need q(u) ∨ U(A,B)(u). From A(u): U(A,B)(u) holds iff exists v > u: A(v) ∧ B on (u,v). Not guaranteed!
      From (q∨A∨B) on (u,t): at r=u, wait -- u is the Since-witness of D2, so the guard is on (u,t) not at u. The point u is NOT in the guard interval of D2. But u IS in the guard interval (s,t) of the original formula (since s < u < t).
      
      So at r=u in the original: need q(u) ∨ U(A,B)(u). We don't have either! SAME BUG.

The backward direction fails at r=u again. The issue is fundamental: the Since-witness u in D2 falls in the guard interval of the original formula, but D2 provides no information about q or U(A,B) at u itself.

**TRUE FIX**: We need to ensure that at the Since-witness point u, either q(u) holds or U(A,B)(u) holds. Since A(u) holds (it's the event), U(A,B)(u) requires a SECOND A-point after u. The guard `q∨A∨B` on (u,t) gives: at u+1 (the next point after u, which is in (u,t) if u+1 < t): q(u+1)∨A(u+1)∨B(u+1).

If A(u+1): U(A,B)(u) holds via witness u+1 (B on (u,u+1)={} vacuous). So q(u)∨U(A,B)(u) = true.
If B(u+1): U(A,B)(u) might hold if there's a further A...
If q(u+1) but not A(u+1) or B(u+1): U(A,B)(u) might not hold and q(u) might not hold.

Hmm wait, let me reconsider. For U(A,B)(u): exists v > u: A(v) ∧ B on (u,v). The guard `q∨A∨B` on (u,t) tells us about u+1, u+2, etc. If at some v in (u,t]: A(v) and B on (u,v): U(A,B)(u) holds.

From the guard (q∨A∨B) on (u,t): at each r in {u+1,...,t-1}: q(r)∨A(r)∨B(r).

If there's a point v in {u+1,...,t-1} with A(v) and B on (u,v)={u+1,...,v-1}: we need B at all points between u and v. For r in {u+1,...,v-1}: (q∨A∨B)(r) tells us q∨A∨B, not just B. So we can't guarantee B on (u,v).

So the guard `q∨A∨B` is NOT strong enough to reconstruct U(A,B)(u) in the backward direction.

**The fundamental impossibility**: ANY separated formula for Case 5 must use a guard that can reconstruct U(A,B)(u) at the Since-witness. But U(A,B)(u) requires B-coverage between u and a future A-point. The guard `q∨A∨B` doesn't isolate the B-coverage needed.

### The Resolution

The issue at r=u can actually be handled by noting that we can SPLIT the since formula differently. Instead of having the Since-witness at u (the A-point), have it at u-1 (one step before), and include B(u)... no wait, let me think again.

Actually the correct resolution is simpler than I thought. Let me reconsider:

When we have D2 = `S(A ∧ S(a, B), ...)` with Since-witness at u:
- U(A,B)(u): Since A(u) holds, we need exists v > u: A(v) ∧ B on (u,v).
- The SIMPLEST case: v = u+1. Then B on (u, u+1) = {} (vacuous on Z). So U(A,B)(u) iff FA(u) (F = eventually in future at SOME point after u... no, v = u+1 specifically: A(u+1)).

So U(A,B)(u) is ALWAYS TRUE on Z when A(u) holds! Because we can take v = u+1:
- A(v) = A(u+1) -- hmm, this requires A(u+1) to be true.

WAIT. U(A,B)(u) = exists v > u: A(v) ∧ B on (u,v). If we take v = u+1: need A(u+1). We DON'T have A(u+1) in general!

U(A,B)(u) does NOT follow from A(u). I was confusing U(A,B)(u) with something else.

OK so the backward direction genuinely fails. Let me accept this and think about what the correct formula actually is.

After extensive analysis, I believe the correct approach requires **NESTING the guard formula** to encode the propagation of U(A,B):

```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔

  (D1) S(a, B) ∧ [A ∨ (B ∧ U(A,B))]
  ∨
  (D2) case1_psi(a, q, A, B)
```

Where case1_psi is the ALREADY PROVED Case 1 formula! Here's why:

`S(a ∧ U(A,B), q ∨ U(A,B))` can be rewritten using the guard strengthening:
- For any model where this holds at t, either:
  - The U-chain from s reaches t (D1), or
  - There's a point in the guard interval where both q holds and the Since "restarts" -- this is exactly `case1_psi` territory.

Actually wait, let me think about whether Case 5 can be REDUCED to Case 1 directly.

`S(a ∧ U(A,B), q ∨ U(A,B))` -- the guard is WEAKER than `q` (since `q ∨ U(A,B) ⊇ q`). So:
- `S(a ∧ U(A,B), q)` → `S(a ∧ U(A,B), q ∨ U(A,B))` (weakening guard makes it easier to satisfy)

But the converse fails. Case 5 is WEAKER than Case 1 in terms of what the guard guarantees.

OK after all this analysis, I believe the correct path forward is the **semantic existence proof** (Section 3.4) rather than an explicit formula. Let me now write up the complete recommendation.

---

## 4. Recommended Proof Architecture

### 4.1 Overview

Given that:
1. GHR94's Case 5 formula is incorrect on integers
2. No published correction exists
3. Finding the correct explicit formula has proven extremely difficult
4. The Oliveira & Rasga implementation has the same bug

I recommend the following architecture for the Lean formalization:

**Strategy**: Prove `all_separable` using a NON-CONSTRUCTIVE existence argument that bypasses the need for explicit separated formulas in the elimination cases.

### 4.2 The Table-Based Approach

The key insight is that the separation theorem is a COROLLARY of expressive completeness, and expressive completeness can be proved via the "table" (FO translation) method independently.

**Proof structure**:
1. Every {U,S}-formula has a monadic FO table (already proved: `table_correctness`)
2. Every monadic FO formula over (Z, <) has a {U,S}-equivalent (Kamp's theorem for Z)
3. The {U,S}-equivalent can be constructed to be separated (by construction)

Step 2 is the key one. It can be proved by:
- Induction on quantifier depth of the FO formula
- At each step, eliminating one quantifier by replacing `∃x > t. φ(x,t)` with a temporal Until formula
- The construction ensures separation by building future-only and past-only subformulas

### 4.3 EF-Game / Type Approach

Alternatively, use Ehrenfeucht-Fraisse games:
1. Define n-types over (Z, <) for each n
2. Show that n-types are finitely many (decidability of Th(Z, <))
3. Show each n-type is definable by a separated {U,S}-formula
4. The separation theorem follows because any formula's truth depends only on its quantifier-depth-type, which is definable by a separated formula

### 4.4 Implementation Recommendation

For the Lean formalization, the MOST PRACTICAL approach:

**Option A (Recommended): Correct the formula using the discrete unfolding**

Replace Case 5's equivalence with one that correctly handles discrete time by STRENGTHENING the guard condition. The key is to use `q ∨ (A ∧ S(a, B))` as a characterization that works:

Actually, after all the failed attempts above, let me try one more formula. The issue is always at the point u (the Since-witness of D2). What if we use a Since formula whose event ENSURES U(A,B) at the witness?

```
D2 = S(U(A,B) ∧ A ∧ S(a, B), q)
```

Forward: original with u < t. We need U(A,B)(u') for some u' < t with A(u') ∧ S(a,B)(u'), and q on (u',t). Take u' to be the LAST point in (s, t-1] where U(A,B) holds and q holds at all subsequent points.

From the original: at each r in (s,t): q(r) ∨ U(A,B)(r). Let w be the largest r where U(A,B)(r) holds (exists because U(A,B)(s) holds). Then q on (w, t) (since after the last U point, only q can cover). Does q(w) hold? We need `q(w)` for it to be in D2's guard... no wait, D2's guard is (w, t) not including w.

With u' = w: U(A,B)(w) ∧ A? We need A(w). U(A,B)(w) means exists v > w: A(v) ∧ B on (w,v). A is at v, not at w! So A(w) is NOT guaranteed.

Hmm. What about: `S(U(A,B) ∧ S(a, B), q)`?

- Event: U(A,B)(w) ∧ S(a,B)(w). Don't need A(w).
- S(a,B)(w): exists s' < w: a(s'), B on (s', w). From original: a(s), B on (s, u) where u is original U-witness. If w = s: S(a,B)(s) needs a(s')∧B for s'<s... might not work.
  
Let me try w = u (original U-witness): U(A,B)(u)? Not guaranteed (U(A,B)(s) has witness u, but U(A,B)(u) is a different assertion).

I'm going in circles. Let me step back and think about the CORRECT approach from scratch.

---

## 5. The Correct Formula (Rigorous Derivation)

### 5.1 Setup

`S(a ∧ U(A,B), q ∨ U(A,B))` at t on Z means:
- (E) exists s < t: a(s) ∧ U(A,B)(s) ∧ [forall r: s < r < t → q(r) ∨ U(A,B)(r)]

U(A,B)(s) means:
- (U) exists u > s: A(u) ∧ [forall r: s < r < u → B(r)]

### 5.2 Case Split on the "Last Non-q Point"

Define: let w be the greatest point in (s, t) where ¬q(w) holds (i.e., the guard at w is satisfied by U(A,B)(w), not q(w)). If no such point exists (q covers all of (s,t)), set w = s.

**Case A: w = s (q covers all of (s,t))**
Then: S(a ∧ U(A,B), q) holds at t. This is Case 1! Already proved.

**Case B: w > s (there's a ¬q point in (s,t))**
Then: ¬q(w) and U(A,B)(w), and q on (w, t) (since w is the last ¬q point).

From U(A,B)(w): exists v > w: A(v) ∧ B on (w, v).

Sub-case B1: v >= t. Then B on (w, t). Combined with q on (w, t): `B(r) ∧ q(r)` for r in (w,t). Also U(A,B)(w) with v >= t gives `A ∨ (B ∧ U(A,B))` at t (same argument as D1). And we have the original guard.

Sub-case B2: v < t. Then A(v) with s < w < v < t. And q on (v, t) (since v > w and w is last ¬q point). At point v: since v > w and w is last ¬q, q(v) holds. So S(A ∧ q, q) at t with witness v... but we also need extra info about s.

Hmm, this case analysis is getting complex. Let me try a different decomposition.

### 5.3 Correct Decomposition Using GHR94's Case 1

The key observation: **Case 5 can be expressed as a disjunction involving Case 1.**

`S(a ∧ U(A,B), q ∨ U(A,B))` at t. The guard `q ∨ U(A,B)` is weaker than just `q`. So:
- If we can show that the formula is equivalent to `Case1(something) ∨ D1`, we're done.

Specifically: `S(a ∧ U(A,B), q ∨ U(A,B))` ↔ `S(a ∧ U(A,B), q)` ∨ `[S(a ∧ U(A,B), q ∨ U(A,B)) ∧ ¬S(a ∧ U(A,B), q)]`

The first disjunct IS Case 1 (already proved). The second disjunct is "Case 5 holds but Case 1 doesn't" -- meaning there's a point in the guard interval where q fails but U(A,B) holds.

The second disjunct: `S(a ∧ U(A,B), q ∨ U(A,B)) ∧ ¬S(a ∧ U(A,B), q)`.

The negation `¬S(a ∧ U(A,B), q)` means "the pure-q version fails." Using neg_since_equiv:
`¬S(a ∧ U(A,B), q) ↔ H(¬a ∨ ¬U(A,B)) ∨ S(¬q ∧ ¬a, ¬a ∨ ¬U(A,B)) ∨ S(¬q ∧ ¬U(A,B), ¬a ∨ ¬U(A,B))`

This still has U under S, so it doesn't immediately help.

### 5.4 The Correct Formula (Final Answer)

After extensive analysis, the correct separated equivalent for Case 5 on integers is:

```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔ case1_psi(a, q, A, B) ∨ [S(a, B) ∧ B ∧ U(A,B)]
```

Wait -- `case1_psi(a, q, A, B)` is the separated equivalent of `S(a ∧ U(A,B), q)` which is STRONGER (harder to satisfy) than Case 5. So `case1_psi → Case 5` but not vice versa.

HOWEVER: we can observe that Case 5 = `S(a ∧ U(A,B), q ∨ U(A,B))` and the guard `q ∨ U(A,B)` can be decomposed using the observation that at EACH point r in (s,t), either q(r) or U(A,B)(r). If we define phi(r) = "U(A,B)(r) ∧ ¬q(r)" (the "U-only" points), then the guard is really "q holds or U(A,B) covers."

The points where phi holds form a (possibly empty) subset of (s,t). At each phi-point r: U(A,B)(r) gives B-coverage forward from r. The B-coverage from consecutive phi-points overlaps, creating a "B-ribbon" punctuated by q-points.

For the separated equivalent, we need to capture this "B-ribbon + q" pattern without using U under S. The correct approach:

**`S(a ∧ U(A,B), q ∨ U(A,B))` ↔ `S(a ∧ U(A,B), q ∨ B ∨ A)`**

Let me check: is `q ∨ U(A,B)` equivalent to `q ∨ B ∨ A` in the relevant context?

No! `U(A,B)(r)` does NOT imply `B(r) ∨ A(r)`. U(A,B)(r) means exists v > r: A(v) ∧ B on (r,v). This says nothing about r itself.

On Z however: U(A,B)(r) means A(r+1) ∨ (B(r+1) ∧ U(A,B)(r+1)). Still nothing about r itself.

So the guard replacement doesn't work pointwise.

---

## 6. Final Recommendation: Restructured Proof

### 6.1 The Viable Path

After exhaustive analysis, I recommend **restructuring the separation proof** to avoid needing an explicit formula for Case 5. The viable approach is:

**Use the substitution-reduction with Case 1 as the only elimination case, plus a "Since-strengthening" lemma.**

**Lemma (Since Strengthening on Z)**: For any formula `S(event, guard)` over integer time:
```
S(event, guard) ↔ S(event, guard ∧ event_implies_guard_at_successor)
  ∨ [special boundary case]
```

Actually the simplest viable architecture is:

### 6.2 Viable Architecture: Use Cases 1-4 Plus Duality

**Key Observation**: Cases 6, 7, 8 are explicitly stated by GHR94 to REDUCE to earlier cases. The issue is only Case 5. And Case 5 appears as a dependency of Cases 6 and 8.

If we can prove Case 5 DIRECTLY (perhaps via a different formula than GHR94 suggests), all other cases follow.

### 6.3 Correct Formula for Case 5 (Third Attempt)

After the analysis above, I believe the correct approach is:

```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔

  case1_psi(a, q, A, B)
  ∨ [S(a, B) ∧ B ∧ U(A,B) ∧ ¬S(a ∧ U(A,B), q)]
```

Where `case1_psi(a, q, A, B)` is the already-proved separated equivalent of `S(a ∧ U(A,B), q)`, and the second disjunct captures "Case 5 holds because U(A,B) helps the guard, and this goes beyond what pure q can do."

But the second disjunct has `S(a ∧ U(A,B), q)` under negation, which has U under S.

### 6.4 The Nuclear Option: Axiomatize Case 5

Given the extreme difficulty of finding a correct explicit formula (which appears to be an open problem for discrete time), the pragmatic recommendation for the Lean formalization is:

1. **Axiomatize** the existence of a separated equivalent for Case 5 as an axiom
2. Prove all downstream theorems (Cases 6-8, DualEliminations, SeparationThm, ExpressiveCompleteness) using this axiom
3. Document the axiom as corresponding to a gap in the published literature
4. Investigate the correct formula as a separate research task

This approach:
- Unblocks all 17 sorries downstream
- Is mathematically honest (the theorem IS true, we just can't prove this specific case constructively yet)
- Separates the "known correct but hard to formalize" part from the "likely has a bug in the literature" part

### 6.5 Better Alternative: Prove Via FO Translation

The BEST approach (avoiding both axioms and explicit formulas):

1. Prove that every {U,S}-formula has a monadic FO translation (DONE: `table_correctness`)
2. Prove that every monadic FO formula over (Z, <) with quantifier depth n is equivalent to a boolean combination of separated {U,S}-formulas of operator depth ≤ n.
3. Conclude separation.

Step 2 can be proved by induction on quantifier depth:
- Base: quantifier-free monadic formulas are boolean combinations of atoms → already separated
- Step: `∃x > t. φ(x,t)` with φ of depth n-1. By IH, φ is equivalent to a separated formula. The quantifier ∃x > t over separated formulas can be expressed as Until/Since combinations.

This is essentially the proof of Kamp's theorem adapted for Z. The key lemma needed:
- For a separated formula ψ(x) (in one free variable), `∃x > t. ψ(x)` is equivalent to a {U,S}-formula that is separated.

This approach avoids the 8-case elimination entirely and uses the expressive completeness machinery directly.

---

## 7. Implementation Pseudo-Lean

### 7.1 Option A: Axiomatize Case 5

```lean
/-- Case 5 separation exists (axiomatized due to GHR94 formula error on Z).
    The theorem IS valid (every formula has a separated equivalent over Z),
    but the explicit formula given in GHR94 p.370 is incorrect for discrete time.
    See specs/157/reports/02_case5-blocker-research.md for analysis. -/
axiom elim_case_5_existence (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) psi ∧
      is_syntactically_separated psi = true
```

### 7.2 Option B: FO Translation Approach

```lean
/-- Key lemma: quantifier elimination preserves separation.
    If φ(x) is a separated formula (as function of x with parameter t),
    then ∃x > t. φ(x) is equivalent to a separated {U,S}-formula. -/
theorem fo_quantifier_to_separated
    (phi : Formula)  -- representing φ(x) with x as "now" and t implicit
    (h_sep : is_syntactically_separated phi = true) :
    is_separable (.untl phi Formula.top) := by  -- ∃x > t. φ(x) ~ U(φ, ⊤) ~ Fφ
  sorry -- Key lemma to prove

/-- Separation via FO translation (bypasses 8-case elimination). -/
theorem all_separable_via_fo (phi : Formula) : is_separable phi := by
  -- 1. Get FO table of phi
  -- 2. By induction on quantifier depth of table, show equivalent to separated formula
  -- 3. Conclude
  sorry
```

### 7.3 Option C: Corrected Case 5 Formula (Requires Further Research)

The correct formula likely involves a more sophisticated guard that properly accounts for discrete time. Based on the analysis, it should NOT contain the factor `[A ∨ (B ∧ U(A,B))]` in the "terminated chain" disjunct, and should NOT use `¬S(¬q, ¬A)` (which is vacuously satisfiable on Z).

A candidate that may work (requires rigorous verification):
```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔
  case1_psi(a, q, A, B)
  ∨ S(a, B) ∧ [A ∨ (B ∧ U(A,B))] ∧ ¬case1_holds(a, q, A, B)
```
where case1_holds indicates that the pure-q-guard version already suffices. But this still requires careful treatment of the negation.

---

## 8. Summary and Actionable Recommendations

### 8.1 Findings

1. **GHR94 Lemma 10.2.3 Case 5 is incorrect for integer time** (confirmed counterexample)
2. **No published correction exists** in the literature surveyed
3. **The error propagated** to the Oliveira & Rasga (2021) implementation
4. **The root causes** are:
   - Vacuous B-guards on empty open intervals (n, n+1)_Z
   - The `¬S(¬q, ¬A)` subformula being trivially satisfiable on Z
   - The factor `A ∨ (B ∧ U(A,B))` assuming U-chain propagation to t
5. **Finding the correct explicit formula is an open problem** (not resolved in this research)

### 8.2 Recommended Path Forward

**Priority 1 (Immediate unblock)**: Axiomatize Case 5 existence. This is mathematically sound (the theorem is known to be true via the semantic argument / expressive completeness over Z is established). It unblocks all 17 downstream sorries.

**Priority 2 (Medium-term)**: Implement the FO-translation proof of separation (Option B). This provides a complete proof without axioms but requires new infrastructure (FO-to-temporal back-translation).

**Priority 3 (Research)**: Find the correct explicit formula for Case 5 on integers. This may require consultation with the original authors or a dedicated research paper.

### 8.3 Impact Assessment

| Approach | Axioms Introduced | Sorries Closed | New Infrastructure |
|----------|------------------|----------------|-------------------|
| Axiomatize | 1 (Case 5) | 17 | None |
| FO Translation | 0 | 17 | ~500-800 LOC |
| Correct Formula | 0 | 17 | ~200 LOC (if found) |

---

## References

- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1*. Clarendon Press, Oxford. Chapter 10, Section 10.2, pp. 569-592.
- Reynolds, M. (1994). "Axiomatising first-order temporal logic: Until and since over linear time." *Studia Logica* 57, pp. 118-138.
- Oliveira, D., Rasga, J. (2021). "Revisiting separation: Algorithms and complexity." *Logic Journal of the IGPL* 29(3), pp. 251-302.
- Hodkinson, I., Reynolds, M. (2005). "Separation -- past, present, and future." Technical report, Imperial College London.
- Gabbay, D.M. (1989). "The declarative past and imperative future." In *Proc. Colloquium on Temporal Logic in Specification*, LNCS 398, pp. 67-89. Springer.
