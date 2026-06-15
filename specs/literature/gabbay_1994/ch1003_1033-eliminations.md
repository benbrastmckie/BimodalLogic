### 10.3.3 Eliminations

Remember that the simple equivalences of lemma 10.2.1, such as that involving S(A ∨ B, C), hold in any linear order.

Now we consider the cases of elimination which were also seen in the integer separations.

**Lemma 10.3.11** Consider the following wffs with a, q, A, and B being atoms:

1. S(a ∧ U(A, B), q),
2. S(a ∧ ¬U(A, B), q),
3. S(a, q ∨ U(A, B)),
4. S(a, q ∨ ¬U(A, B)),
5. S(a ∧ U(A, B), q ∨ U(A, B)),
6. S(a ∧ ¬U(A, B), q ∨ U(A, B)),
7. S(a ∧ U(A, B), q ∨ ¬U(A, B)), and
8. S(a ∧ ¬U(A, B), q ∨ ¬U(A, B)).

Over Dedekind complete time each of the above wffs can be syntactically separated in such a way that the only appearance of U in the separated wff is as U(A, B).

*Proof.*

1. In this case, the wff here is equivalent to the same wff obtained in the case of the integers in lemma 10.2.3, i.e. S(a ∧ U(A, B), q) is equivalent to

   [S(a, q) ∧ S(a, B) ∧ B ∧ U(A, B)]
   ∨ [A ∧ S(a, B) ∧ S(a, q)]
   ∨ S(A ∧ q ∧ S(a, B) ∧ S(a, q), q).

2. It is straightforward to show that S(a ∧ ¬U(A, B), q)
   ↔ S(K⁺(¬B) ∧ a, q)
   ∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q)
   ∨ S(¬A ∧ Γ⁻(B) ∧ q ∧ S(a, ¬A ∧ q), q)
   ∨ [S(a, ¬A ∧ q) ∧ ¬A ∧ (¬B ∨ ¬U(A, B))].

3. Below we show that S(a, U(A, B) ∨ q)
   ↔ S(a, q)
   ∨ [S(α, Q) ∧ β]
   ∨ S(A ∧ (q ∨ U(A, B)) ∧ S(α, Q), q)
   ∨ S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q),

   where

   α = a ∨ ((¬q ∨ Γ⁻(q)) ∧ S(a, q) ∧ (q ∨ U(A, B))),

   and

   β = A ∨ K⁻(A) ∨ [B ∧ U(A, B)].

   Elimination (1) used several times will give us separation.

   Let us outline the proof of the equivalence above:

   (⇒) Assume that S(a, U(A, B) ∨ q) holds at t. So there is s < t such that ‖a‖_s = 1 and U(A, B) ∨ q is true everywhere between s and t.

   Let

   L = {z ∈ (s, t) | ∀y ∈ (s, z), ‖q‖_y = 1},

   l = sup L (or l = s if L is empty),

   R = {z ∈ (s, t) | ∀y ∈ (z, t), ‖q‖_y = 1}

   and r = inf R (or r = t if R is empty).

   If L = (s, t) then ‖S(a, q)‖_t = 1 and we are done. So suppose that l < t.

   Clearly, l < r < t. Now either s = l so the first disjunct of α holds at l or s < l so the second holds. In each case K⁺(A) ∨ U(A, B) is true at l. We thus have S(α, Q) true at r.

   There are three cases:

   - r = t: Now we must have K⁻(¬q) true at t so K⁻(U(A, B)) also. This implies β and hence S(α, Q) ∧ β holds at t.
   - r < t and U(A, B) is false at r: We must have q true at r but since r = inf R we need also have Γ⁺(q) true here. Because K⁻(¬q) so K⁻(U(A, B)) holds and we have A ∨ K⁻(A). Thus S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q) holds at t and we finish.
   - r < t and U(A, B) holds at r: Suppose that w > r witnesses the until. It is clear then that Q is true at r and up until w so we have further sub-cases:
     - r < w < t: S(A ∧ S(α, Q), q) holds at t.
     - t ≤ w: Now A ∨ (B ∧ U(A, B)) holds at t so we have S(α, Q) ∧ β there.

   (⇐) Suppose that one of the four disjuncts holds at t. It is clear that if the first does then S(a, U(A, B) ∨ q) holds at t, as required. Now consider the cases of the other disjuncts holding.

   If the second disjunct holds put u = t and β holds here.

   If the third or fourth disjuncts hold let u < t witness the since so we have either A or K⁻(A) holding at u and q true between u and t.

   In each case we have a point u < t with ‖S(α, Q)‖_u = 1 and various other truth conditions depending on the case. Thus there is v < u where a holds and Q is true everywhere on (v, u). Either a holds at v when we put s = v or, if the other disjunct of α holds at v, there is s < v witnessing S(a, q).

   We are done when we show that q ∨ U(A, B) holds everywhere in (s, t). Consider z from this interval.

   - If s < z < v then q holds at z.
   - If s < z = v then q ∨ U(A, B) holds.
   - If v < z < u then since Q holds on (v, u) and β holds at u we have the Q lemma implying q ∨ U(A, B) at z.
   - If z = u < t then we have disjuncts three or four holding and the desired result.
   - If u < z < t then we have q true at z and we are done.

4. S(a, ¬U(A, B) ∨ q)
   ↔ ¬[ K⁻(U(A, B) ∧ ¬q)
   ∨ ¬S(a, ⊤)
   ∨ S(¬a ∧ U(A, B) ∧ ¬q, ¬a)
   ∨ S(¬a ∧ Γ⁺(¬U(A, B) ∨ q), ¬a) ]

   By lemma 10.3.3 the first disjunct can be separated. By the first elimination the third disjunct can be separated and by lemmas on Γ± and elimination (1) or (2) the fourth disjunct can be separated.

5. To separate S(a ∧ U(A, B), q ∨ U(A, B)) use elimination (3) to rewrite it equivalently as

   S(a ∧ U(A, B), q)
   ∨ [S(α, Q) ∧ β]
   ∨ S(A ∧ (q ∨ U(A, B)) ∧ S(α, Q), q)
   ∨ S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q),

   where Q = Q(A, B, ¬q),

   α = (a ∧ U(A, B))
   ∨ ((¬q ∨ Γ⁻(q)) ∧ S(a ∧ U(A, B), q) ∧ (q ∨ U(A, B))),

   and

   β = A ∨ K⁻(A) ∨ [B ∧ U(A, B)].

   The first elimination will separate the first disjunct and the expression α. Further use of that elimination will separate S(α, Q) and finally also the expression which the latter is nested within.

6. To separate S(a ∧ ¬U(A, B), q ∨ U(A, B)) use elimination (3) and then elimination (2) in a similar manner to the preceding elimination.

7. S(U(A, B) ∧ a, ¬U(A, B) ∨ q)
   ↔ S(a, B ∧ q) ∧ (A ∨ (B ∧ U(A, B)))
   ∨ S(S(a, B ∧ q) ∧ A ∧ (q ∨ ¬U(A, B)), ¬U(A, B) ∨ q).

   We then use the eighth and fourth eliminations.

8. S(¬U(A, B) ∧ a, ¬U(A, B) ∨ q)

   ↔ ¬[ K⁻(U(A, B) ∧ ¬q)
   ∨ ¬S(¬U(A, B) ∧ a, ⊤)
   ∨ S((U(A, B) ∨ ¬a) ∧ U(A, B) ∧ ¬q, U(A, B) ∨ ¬a)
   ∨ S((U(A, B) ∨ ¬a) ∧ Γ⁺(¬U(A, B) ∧ q), U(A, B) ∨ ¬a) ].

   This can be separated by lemmas 10.3.3, and eliminations (2) and (5).

□
