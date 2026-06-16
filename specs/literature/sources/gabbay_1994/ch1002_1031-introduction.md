### 10.3.1 Introduction

To show separation over Dedekind complete time, we follow a similar procedure for eliminating occurrences of S from under the scope of a U and U from under S to that we have just finished above. Here the elimination and induction is slightly more complicated.

We will need to consider some new connectives:

- K⁺q = ¬U(⊤, ¬q), and
- K⁻q = ¬S(⊤, ¬q).

We have K⁺q true at t iff q is true arbitrarily close to t from the future, i.e.:

‖K⁺q‖ₜ = 1 iff ∀z > t, ∃y (t < y < z ∧ ‖q‖ᵧ = 1).

Similarly,

‖K⁻q‖ₜ = 1 iff ∀z < t, ∃y (z < y < t ∧ ‖q‖ᵧ = 1).

In integer time, these connectives are not very interesting for K⁺q = K⁻q = ⊤.

Now consider the wff PK⁺q. This wff is actually pure past — its truth at time t depends only on the behaviour of q in the past of t. More generally, if we build any wff out of S, K⁻, K⁺ only, we will obtain a pure past wff as long as any K⁺ is under the scope of an S (or a K⁻). The reason for this last restriction is that K⁺q itself is pure future, but under the scope of any S it does no harm since it expresses 'local' properties.

Thus, in doing eliminations as we did in the last section, we may leave K⁺ within the scope of an S, and still have a separated wff. This is just as well for in the language with just U and S it is impossible to rewrite such wffs as PK⁺q in such a way that there is no U in the scope of an S and vice versa.

In order to make our lives easier we will extend our temporal language to include K⁺ and K⁻ as connectives. It is clear that, since these new connectives can be defined in terms of U and S, separation and expressive completeness either hold for both or fail for both the temporal language with just U and S and its extension, which includes the K±.

Now it is possible to define syntactic separation in this extended language and then go through the eliminations and inductions to prove that any wff can be syntactically separated. However, for the benefit of the next chapter, we are going to make things slightly more complicated.

We will introduce still more connectives (Γ±), use a special atom (c) whose interpretation is restricted, and keep a close watch on how we go about rewriting wffs when we separate them. All this extra machinery means more work in this chapter (for example the Γ± eliminations are really redundant here) but saves us work in chapter 11.

First we define

**Definition 10.3.1**

Γ⁺(B) = ¬K⁺(¬B) ∧ K⁻(¬B)

and

Γ⁻(B) = ¬K⁻(¬B) ∧ K⁺(¬B).

Again note that the expressive power has clearly not been increased from that of U and S.

Next we introduce a new atom c and require that it is always interpreted *relatively densely* in the linear order, i.e. c is true somewhere in each interval of the form

- (a, b] = {z ∈ T | a < z ≤ b}, or
- [a, b) = {z ∈ T | a ≤ z < b},

for a < b from T. This seeming restriction on the structures which we are looking at is not really one in this chapter, as to any temporal structure we can add c to the language and interpret it as true everywhere. We do have

**Lemma 10.3.2** Over Dedekind complete time with c interpreted relatively densely K⁺(A) ↔ ¬U(c, ¬A) and the dual result.

In the rest of this chapter we will work in the language with connectives {U, S, K±, Γ±} and a special atom c. All equivalences will be valid in Dedekind complete structures with c interpreted relatively densely.

**Definition 10.3.3** A wff of {U, S, K±, Γ±} is *syntactically separated* iff it is a boolean combination of wffs of the form:

- atoms,
- U(A, B) without S,
- S(A, B) without U,
- K⁺(A) without S, and
- K⁻(A) without U.

For example, K⁺(S(p, q)) is not syntactically separated but S(K⁺(S(p, q)), r) is.

Note that Γ± must only appear nested below other temporal connectives.

**Lemma 10.3.4** Syntactic separation implies separation.

*Proof.* It is not difficult to prove by induction on the construction of any wff A of {U, S, K±, Γ±} that

- if A does not contain S then its truth at t ∈ T is determined by any s < t along with the interpretation of the atoms on {u ∈ T | s < u},
- and dually for U.

Then, given any wff U(A, B) with A and B not containing S, we know that its truth at t ∈ T depends just on the valuations of A and B at points > t but by the above these are determined by the interpretation of the atoms on {u ∈ T | t < u}, i.e. on the future of t.

And similarly for the other cases. □

### 10.3.2 Pre-eliminations

As before we have a useful negation lemma:

**Lemma 10.3.5** The following hold over Dedekind complete flows of time:

- ¬U(A, B) ↔ K⁺(¬B) ∨ ¬U(A, ⊤) ∨ U(¬A ∧ ¬B, ¬A) ∨ U(¬A ∧ Γ⁻(B), ¬A),
- ¬S(A, B) ↔ K⁻(¬B) ∨ ¬S(A, ⊤) ∨ S(¬A ∧ ¬B, ¬A) ∨ S(¬A ∧ Γ⁺(B), ¬A).

Now let us look more closely at the basic eliminations which we will need to carry out. Our elimination procedure may disregard any K⁺ in the scope of S or K⁻. However, since K± are allowed in the scope of S, a U may be under the scope of a K⁺ or a K⁻ which is itself in the scope of an S. Thus we must pull the U out of the scope of the K±, in order to pull it out further from under the scope of S. For example, in S(a ∧ K⁻(p ∧ U(A, B)), q) we must obtain the U out of the scope of K⁻ and then out of the scope of S.

Because of facts like K⁺(p ∨ q) being equivalent to K⁺(p) ∨ K⁺(q) it turns out that, in addition to the eight cases of eliminations needed for the integers, for this section we have to consider the four additional elimination cases seen in lemma 10.3.8.

We need similar results for Γ± but first a technical lemma:

**Lemma 10.3.6** Let Q(A, B, C) be the abbreviation

[C ⇒ ¬K⁺(¬B)]
∧ [(¬B ∨ Γ⁻(B)) ⇒ (S(C, ¬A) ⇒ A)].

1. If
   - ∀z ∈ (t₀, t₁), ‖C ⇒ U(A, B)‖_z = 1,
   - and ‖[(A ∧ ¬C) ∨ K⁺(A) ∨ U(A, B)]‖_{t₀} = 1,

   then ∀z ∈ (t₀, t₁), ‖Q(A, B, C)‖_z = 1.

2. If
   - ∀z ∈ (t₀, t₁), ‖Q(A, B, C)‖_z = 1,
   - and ‖A ∨ K⁻(A) ∨ (B ∧ U(A, B))‖_{t₁} = 1,

   then ∀z ∈ (t₀, t₁), ‖C ⇒ U(A, B)‖_z = 1.

*Proof.* Let Q = Q(A, B, C).

1. Suppose the conditions are true and z ∈ (t₀, t₁). If ‖C‖_z = 1 then ‖U(A, B)‖_z = 1 so we certainly have ‖¬K⁺(¬B)‖_z = 1.

   Assume ‖(¬B ∨ Γ⁻(B))‖_z = 1 and ‖S(C, ¬A)‖_z = 1. We show that ‖A‖_z = 1.

   There is u < z with ‖C‖_u = 1 and for all w ∈ (u, z), ‖¬A‖_w = 1. There are two cases:

   - u < t₀: when the initial conditions on t₀ imply that ‖U(A, B)‖_{t₀} = 1. Put u = t₀.
   - t₀ < u < z: when C being true at u implies that ‖U(A, B)‖_u = 1.

   In each case, since A is not true between u (where U(A, B) holds) and z, and B does not remain true past z, we must have A true at z, as required.

2. Suppose the conditions are true and z ∈ (t₀, t₁). Assume that ‖C‖_z = 1 and we show that ‖U(A, B)‖_z = 1.

   Let y = sup{z' ∈ (z, t₁) | for all u ∈ (z, z'), ‖B‖_u = 1}. Since ‖¬K⁺(¬B)‖_z = 1 we know that y exists and is > z. There are two cases:

   - z < y < t₁: Now we have either ¬B or Γ⁻(B) holding at y and thus, since Q also holds there we have ‖S(C, ¬A) ⇒ A‖_y = 1. If A is true anywhere between z and y then we are done (as B holds everywhere on that interval) but otherwise we have A holding at y (since S(C, ¬A) does) and we are again finished.
   - y = t₁: when it follows directly from the initial conditions on t₁ that U(A, B) is true at z as required.

□

**Lemma 10.3.7** The following hold over Dedekind complete flows of time:

- K⁺(A ∨ B) ↔ K⁺A ∨ K⁺B,
- K⁻(A ∨ B) ↔ K⁻A ∨ K⁻B.

Let us perform the four eliminations for U beneath K± first:

**Lemma 10.3.8** Over Dedekind complete time we have the following equivalences in which the abbreviation Q(A, B, p) is as defined in the Q lemma. Note that in the results U only appears as U(A, B) and not under S, K± or Γ±.

1. K⁺(p ∧ U(A, B))
   ↔ [K⁺p ∧ U(A, B)] ∨ [K⁺p ∧ K⁻(A ∧ S(p, B))].

2. K⁻(p ∧ U(A, B))
   ↔ [K⁻p ∧ A ∧ ¬K⁻(¬B)]
   ∨ [K⁻p ∧ ¬K⁻(¬B) ∧ B ∧ U(A, B)]
   ∨ [K⁻p ∧ K⁻(S(p, B) ∧ A)].

3. K⁺(p ∧ ¬U(A, B))
   ↔ K⁺p ∧ ¬U(A, B) ∧ [¬K⁺A ∨ K⁺(¬Q(A, B, p))].

4. K⁻(p ∧ ¬U(A, B))
   ↔ [K⁻p ∧ K⁻(¬Q(A, B, p))]
   ∨ [K⁻p ∧ ¬(A ∨ K⁻A ∨ (B ∧ U(A, B)))].

*Proof.* These are all very straightforward semantic arguments, the last two of which are simplified somewhat by use of the Q lemma. □

Notice that we sometimes don't end up with a syntactically separated wff after using the above equivalences: for example S appears (in Q) beneath K⁺ in the third. This doesn't matter in the proof where we just require the U(A, B) to be removed from beneath the K±.

Next the Γs.

**Lemma 10.3.9**

Γ⁺(A ∧ B) ↔ [Γ⁺(A) ∧ ¬K⁺(¬B)] ∨ [Γ⁺(B) ∧ ¬K⁺(¬A)],

and similarly Γ⁻(A ∧ B).

**Lemma 10.3.10** Each wff below is equivalent (over Dedekind complete time) to a wff in which U only appears as U(A, B) and is not nested beneath S, K±, or Γ±:

1. Γ⁻(q ∨ U(A, B));
2. Γ⁺(q ∨ U(A, B));
3. Γ⁻(q ∨ ¬U(A, B));
4. Γ⁺(q ∨ ¬U(A, B)).

Dual results with Γ⁺ exchanged with Γ⁻ and U exchanged with S hold.

In fact, we have:

1. Γ⁻(q ∨ U(A, B))
   ↔ [Γ⁻(q) ∧ ¬U(A, B) ∧ (¬K⁺(A) ∨ K⁺(¬Q))]
   ∨ [K⁺(¬q) ∧ ¬U(A, B) ∧ (¬K⁺(A) ∨ K⁺(¬Q)) ∧ ¬K⁻(¬Q) ∧ A]
   ∨ [K⁺(¬q) ∧ ¬U(A, B) ∧ Γ⁻(¬A) ∧ ¬K⁻(¬Q)]
   ∨ [K⁺(¬q) ∧ ¬U(A, B) ∧ Γ⁻(Q) ∧ K⁻(A)].

2. Γ⁺(q ∨ U(A, B))
   ↔ [Γ⁺(q) ∧ K⁻(¬Q)]
   ∨ [Γ⁺(q) ∧ ¬A ∧ ¬K⁻(A) ∧ (¬B ∨ ¬U(A, B))]
   ∨ [U(A, B) ∧ K⁻(¬q) ∧ ¬K⁻(¬Q) ∧ (¬B ∨ Γ⁻(B))]
   ∨ [U(A, B) ∧ K⁻(¬q) ∧ ¬A ∧ ¬K⁻(A) ∧ ¬B]
   ∨ [K⁺(A) ∧ Γ⁻(Q) ∧ K⁻(¬q)]
   ∨ [Γ⁻(¬A) ∧ ¬K⁺(¬Q) ∧ K⁻(¬q) ∧ ¬A ∧ (¬B ∨ ¬U(A, B))].

3. Γ⁻(q ∨ ¬U(A, B))
   ↔ [Γ⁻(q) ∧ U(A, B)]
   ∨ [Γ⁻(q) ∧ K⁺(A ∧ S(¬q, B))]
   ∨ [(¬A ∨ K⁻(¬B))
   ∧ ((Γ⁻(B) ∨ ¬B) ∧ ¬K⁻(S(¬q, B) ∧ A) ∧ K⁺(¬q) ∧ U(A, B))
   ∨ (¬(¬K⁻(¬B) ∧ B ∧ U(A, B))
   ∧ Γ⁻(¬A ∨ ¬S(¬q, B)) ∧ K⁺(¬q))].

4. Γ⁺(q ∨ ¬U(A, B))
   ↔ [Γ⁺(q) ∧ A ∧ ¬K⁻(¬B)]
   ∨ [Γ⁺(q) ∧ ¬K⁻(¬B) ∧ B ∧ U(A, B)]
   ∨ [Γ⁺(q) ∧ K⁻(S(¬q, B) ∧ A)]
   ∨ [K⁻(¬q) ∧ ¬U(A, B) ∧ ¬K⁺(A ∧ S(¬q, B) ∧ A ∧ ¬K⁻(¬B))]
   ∨ [K⁻(¬q) ∧ ¬U(A, B) ∧ Γ⁺(¬A ∨ ¬S(¬q, B))].

*Proof.* Rewrite Γ± in terms of K± and use the K± eliminations. Then rearrange and reform some Γ±s. □
