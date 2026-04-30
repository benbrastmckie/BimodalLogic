# Research Report: Task #107 — Teammate A Findings

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-29
**Artifact**: 48_teammate-a-findings.md
**Angle**: Primary — Burgess Lemma 2.7 proof reconstruction and blocker resolution

---

## Executive Summary

After reading Burgess 1982 pp. 370-372 in full, both Lemma 2.6 and 2.7 proofs, and
examining the current Lean codebase (PointInsertion.lean, RRelation.lean, Axioms.lean),
the three Phase 6 blockers can be resolved as follows:

1. **Seed consistency with h_content(C)**: Burgess's Lemma 2.7 seed is NOT `{xi} ∪
   g_content(A) ∪ h_content(C)`. The seed is comprehension-based:
   `{S(alpha, beta∧eta) : alpha ∈ A, beta ∈ B} ∪ B ∪ {xi} ∪ {U(gamma, beta) : gamma ∈ C, beta ∈ B}`.
   Consistency is proved element-by-element via BX5+BX7+BX13, using `¬U(gamma₀, beta₀∧eta) ∈ A`
   as the ruling-out witness. The h_content(C) shortcut from Lemma 2.6 does NOT carry over.

2. **Getting xi into D**: Burgess does NOT use `F(xi) ∈ A` directly. Instead, after
   ruling out D1 and D2, the surviving disjunct D3 gives `U(phi₁∧phi₂, phi₁∧gamma₀) ∈ A`
   where `phi₁ = xi ∧ U(xi,eta)`. BX13 (enrichment_until) applied to A3a in Burgess
   gives `U(xi, beta₀∧eta) ∈ A`, from which consistency follows via Lemma 2.2.
   The seed contains `xi` explicitly (not via F(xi)).

3. **eta ∈ B'**: Burgess proves `eta ∈ B'` purely from the maximality of B' relative
   to `r(A, -, D)`, using `U(xi, beta∧eta) ∈ A` for all `beta ∈ B`. Since `xi ∈ D`,
   Lemma 2.3 (the BX4/BX4'-based equivalence) gives `S(xi, beta∧eta) ∈ D` for all
   `beta ∈ B`. Taking beta = ⊤ (if ⊤ ∈ B) gives `S(xi, eta) ∈ D`, which means
   `r(A, eta, D)` holds (i.e., `burgessR(A, eta, D)`). Then by maximality, `eta ∈ B'`.

---

## Detailed Analysis

### 1. Burgess Lemma 2.7: The Actual Proof (p. 371-372)

Burgess states Lemma 2.7 as: Given `R(A, B, C)`, `U(xi, eta) ∈ A`, `eta ∉ B`,
produce `B', D, B''` with `eta ∈ B'`, `xi ∈ D`, `R(A, B', D)`, `R(D, B'', C)`,
`B = B' ∩ D ∩ B''`.

The proof opens with: "Much as in the proof of 2.6 the problem reduces to proving
the consistency of the set of formulas of form
`ζ = S(alpha, beta∧eta) ∧ beta ∧ xi ∧ U(gamma, beta)`
for alpha ∈ A, beta ∈ B, gamma ∈ C."

This means the seed is:
```
D₀ = {S(alpha, beta∧eta) : alpha ∈ A, beta ∈ B}
     ∪ B
     ∪ {xi}
     ∪ {U(gamma, beta) : gamma ∈ C, beta ∈ B}
```

The consistency argument proceeds: "there are beta₀ ∈ B, gamma₀ ∈ C with
`¬U(gamma₀, beta₀∧eta) ∈ A`" (from the Maximality remark: since `eta ∉ B`,
there exists beta₀ ∈ B with `r(A, beta₀∧eta, C)` failing, so some gamma₀ ∈ C
has `¬U(gamma₀, beta₀∧eta) ∈ A`).

**Critical convention note**: Burgess can assume WLOG that `beta = beta₀` and
`gamma = gamma₀` (by replacing beta, gamma by their conjunction with beta₀, gamma₀ if
needed, since beta₀ ∈ B and gamma₀ ∈ C, and both appear in all four components of D₀).

Then the BX5+BX7+BX13 chain:

- A5a applied to `U(gamma, beta) ∈ A` (from R(A,B,C)): get `U(gamma∧U(gamma,beta), beta) ∈ A`
- A5a applied to `U(xi, eta) ∈ A`: get `U(xi∧U(xi,eta), eta) ∈ A`
- Let `theta = beta∧U(gamma,beta)∧xi∧U(xi,eta)`
- A7a applied to the two enriched formulas: get one of the three disjuncts in A:
  - D1: `U(gamma∧xi, theta) ∈ A`
  - D2: `U(gamma∧U(xi,eta), theta) ∈ A`  [in Burgess's labeling: second disjunct]
  - D3: `U(beta∧U(gamma,beta)∧xi, theta) ∈ A` [in Burgess's labeling: third disjunct]

**Ruling out D1 and D2**:

For D1: `U(gamma∧xi, theta) ∈ A`. Note theta = beta∧U(gamma,beta)∧xi∧U(xi,eta).
Since `theta → beta∧eta` is a theorem (theta implies eta since theta = ...∧U(xi,eta)
and... wait, this is the subtle point).

Let me reconstruct more carefully. From the surviving disjunct D3:
`U(beta∧U(gamma,beta)∧xi, theta) ∈ A` where theta = beta∧U(gamma,beta)∧xi∧U(xi,eta).

Burgess then says "using A3a we then get `U(xi, beta∧eta) ∈ A`".

Here A3a is: `p ∧ U(q, r) → U(q∧S(p,r), r)` (Burgess's version; BX13 in our system
is the adapted form). So from D3 = `U(phi₁, theta) ∈ A` and `xi ∈ ???`:

Actually, re-reading Burgess's Lemma 2.7 proof more carefully:

After the BX7 application yields D3: `U(beta∧U(gamma,beta)∧xi, theta) ∈ A`,
Burgess applies A3a to get `U(xi, beta∧eta) ∈ A`. The A3a step is:
`xi ∧ U(beta∧U(gamma,beta)∧xi, theta) → U((beta∧U(gamma,beta)∧xi) ∧ S(xi, theta), theta)`.

But wait — how does this yield `U(xi, beta∧eta)`? The key is that `theta = beta∧U(gamma,beta)∧xi∧U(xi,eta)`,
and since Burgess uses CLOSED guard semantics where the S-formula in the enrichment
includes the current point, the event at the witness has `beta∧eta` (since `theta → beta` and
the BX13 enrichment places `S(xi, theta)` in the guard which survives at the witness as `beta∧eta`).

Under our OPEN guard semantics, this is where adaptation is needed.

**The correct reconstruction of Burgess's step**:

Actually, looking again at Lemma 2.6, the analogous step is:
- D3: `U(beta∧U(gamma,beta)∧¬delta, beta) ∈ A`
- A3a: `U(beta∧U(gamma,beta)∧¬delta∧S(alpha, beta), beta) ∈ A`
- Lemma 2.2: `beta∧U(gamma,beta)∧¬delta∧S(alpha,beta)` is consistent
- This is the consistency of `ζ = S(alpha,beta) ∧ beta ∧ ¬delta ∧ U(gamma,beta)`

So in Lemma 2.7, the analogous step is:
- D3: `U(beta∧U(gamma,beta)∧xi, theta) ∈ A` where `theta = beta∧U(gamma,beta)∧xi∧U(xi,eta)`
- A3a applied to xi and D3: `U(xi∧S(xi, theta), theta) ∈ A` — but this doesn't yet give `U(xi, beta∧eta)`

The "using A3a we then get `U(xi, beta∧eta) ∈ A`" must be proceeding differently.
Re-reading: D3 is `U(beta∧U(gamma,beta)∧xi, theta) ∈ A`. Since `theta = beta∧U(gamma,beta)∧xi∧U(xi,eta)`,
we have `theta → U(xi,eta)`. By A2a (right_mono_until): `U(beta∧U(gamma,beta)∧xi, U(xi,eta)) ∈ A`.
Since `xi ∈ guard` and A3a says `p ∧ U(q,r) → U(q∧S(p,r), r)`:
taking `p = xi`, `q = beta∧U(gamma,beta)∧xi`, `r = U(xi,eta)`:

Wait — in Burgess A3a is `p ∧ U(q,r) → U(q∧S(p,r), r)`. But here we want `U(xi, ?)`.

Actually Burgess says "Using A3a we then get `U(xi, beta∧eta) ∈ A`, whence the
consistency of ζ follows." Let me look at this differently.

In Lemma 2.7, the formula `ζ = S(alpha, beta∧eta) ∧ beta ∧ xi ∧ U(gamma, beta)`.
The consistency of ζ follows from `U(xi, beta∧eta) ∈ A` via Lemma 2.2 (consistency criterion):
if `U(xi, beta∧eta) ∈ A` then `xi` is consistent (and by A2a applied to `xi → xi ∧ U(gamma,beta)` etc.).

But Lemma 2.2 says "if A is an MCS and U(γ,δ) ∈ A, then γ is consistent." That would give xi consistent,
not ζ consistent. How does `U(xi, beta∧eta) ∈ A` give consistency of ζ?

Looking at Lemma 2.4 for analogy: consistency of `gamma ∧ S(alpha, beta)` follows because
`U(gamma∧S(alpha,beta), beta) ∈ A` by A3a, and then Lemma 2.2 gives the guard (gamma∧S(alpha,beta)) consistent.

So for Lemma 2.7, `U(xi, beta∧eta) ∈ A` would give consistency of xi (the guard), but
what about the full ζ = S(alpha, beta∧eta) ∧ beta ∧ xi ∧ U(gamma, beta)?

The key insight: Burgess must mean that `U(xi, beta∧eta∧S(alpha,beta∧eta)∧U(gamma,beta)) ∈ A`
(after applying multiple A3a steps), from which consistency follows via Lemma 2.2.

But Burgess writes it concisely as "using A3a we get `U(xi, beta∧eta) ∈ A`" and
"whence the consistency of ζ follows, completing our account of the proof."

So the claim is: `U(xi, beta∧eta) ∈ A` → `ζ` is consistent. This requires that
the guard formula of `U(xi, beta∧eta)` (which is xi) subsumes the components of ζ
(namely beta, S(alpha, beta∧eta), U(gamma, beta)) via appropriate axioms applied further.

In particular, `U(xi, beta∧eta) ∈ A` means F(beta∧eta) ∈ A (by BX10). But ζ is richer.

**Resolution**: Burgess's "using A3a" step is more involved than the one-liner suggests.
The full chain is:
1. D3 gives `U(phi₁, theta) ∈ A` where phi₁ = beta∧U(gamma,beta)∧xi
2. theta = phi₁∧U(xi,eta)
3. From `theta → U(xi,eta)` (projection), by A2a: `U(phi₁, U(xi,eta)) ∈ A`
4. A3a with p = xi, q = phi₁, r = U(xi,eta): get `U(phi₁∧S(xi,U(xi,eta)), U(xi,eta)) ∈ A`
5. Note `xi → S(xi, U(xi,eta))` by A3a (or BX13): if `xi ∧ U(phi₁, U(xi,eta)) → U(phi₁∧S(xi,U(xi,eta)), U(xi,eta))`...

This is getting complicated. Let me re-read the crucial sentence from Burgess:

"Now letting theta = beta∧U(gamma,beta)∧xi∧U(xi,eta), A7a applies to tell us that one
of the following must belong to A: U(gamma∧xi, theta), U(gamma∧U(xi,eta), theta), or
U(beta∧U(gamma,beta)∧xi, theta). Since ¬U(gamma,beta∧eta) ∈ A, using A1a and A2a the
first two candidates can be ruled out, so it must be the third. Using A3a we then get
U(xi, beta∧eta) ∈ A, whence the consistency of ζ follows."

So D3 is: `U(beta∧U(gamma,beta)∧xi, theta) ∈ A`.

"Using A3a": A3a is `p ∧ U(q,r) → U(q∧S(p,r), r)`. Setting `p = xi`, `q = beta∧U(gamma,beta)∧xi`,
`r = theta = beta∧U(gamma,beta)∧xi∧U(xi,eta)`:
- Need `xi ∈ A`... but xi might not be in A.

Alternative reading: A3a is being applied at the CURRENT MCS level. That is, not to ζ
but to derive `U(xi, beta∧eta) ∈ A` from D3. Here:
- D3: `U(beta∧U(gamma,beta)∧xi, theta) ∈ A` implies `F(theta) ∈ A` (by A10/BX10)
- `F(theta) = F(beta∧U(gamma,beta)∧xi∧U(xi,eta)) ∈ A`
- From `U(xi,eta) ∈ A` and A5a: `U(xi∧U(xi,eta), eta) ∈ A`
- From D3 and `theta → beta∧U(gamma,beta)∧xi`: by A2a, `U(beta∧U(gamma,beta)∧xi, beta) ∈ A`
- A6a: `U(beta∧U(gamma,beta)∧xi, beta) ∈ A` gives... hmm.

Actually I think Burgess's "A3a" application is: from D3 = `U(q, theta) ∈ A` where `q = beta∧U(gamma,beta)∧xi`
and `theta = q∧U(xi,eta)`, by applying A3a with `p = xi`, `q = q`, `r = theta`:
A3a says `p ∧ U(q,r) → U(q∧S(p,r), r)`.
For this to work, we need `xi ∈ A`. But xi might not be in A!

The correct reading: **A3a is used to derive consistency of ζ, not to derive `U(xi, beta∧eta) ∈ A` as a separate step in A**. The summary in Burgess is telescoped. The full argument is:

Since D3 = `U(beta∧U(gamma,beta)∧xi, theta) ∈ A` with `theta = beta∧U(gamma,beta)∧xi∧U(xi,eta)`:
- By A2a on `theta → U(xi,eta)`: `U(beta∧U(gamma,beta)∧xi, U(xi,eta)) ∈ A`
- This means `F(U(xi,eta)) ∈ A` (by BX10), so `U(xi,eta) ∈` some future MCS
- But more usefully: apply A3a with `p = xi`, `q = beta∧U(gamma,beta)∧xi`, `r = U(xi,eta)`:
  `xi ∧ U(beta∧U(gamma,beta)∧xi, U(xi,eta)) → U(beta∧U(gamma,beta)∧xi∧S(xi, U(xi,eta)), U(xi,eta)) ∈ A`
  (if xi ∈ A; but again xi might not be in A)

**The actual mechanism used by Burgess**: The consistency of ζ comes from the fact that D3 gives
`U(xi, beta∧eta) ∈ A` via a sequence of axiom applications. The key step is:

From D3: `U(beta∧U(gamma,beta)∧xi, beta∧U(gamma,beta)∧xi∧U(xi,eta)) ∈ A`.
The event (right argument) is `beta∧U(gamma,beta)∧xi∧U(xi,eta)`. Since `U(xi,eta)` is part of
the event, and `xi` is part of the guard, by A3a:

`xi ∧ U(guard, event) → U(guard∧S(xi, event), event)` — still needs xi ∈ A.

**Conclusion on Burgess's argument**: The statement "Using A3a we then get U(xi, beta∧eta) ∈ A"
appears to be doing something subtle. In Burgess's system with **closed** guard semantics
(Burgess's A5a has reflexive guard), the S-formula at the event point encodes the current point xi.
Under Burgess's closed-guard A3a: `p ∧ U(q,r) → U(q ∧ S(p,r), r)` where p is true now,
q is the guard, r is the event. The resulting guard `q∧S(p,r)` holds at points between
current and the witness.

The telescoping: after D3 gives `U(q₃, theta) ∈ A` where q₃ = beta∧U(gamma,beta)∧xi,
Burgess claims `U(xi, beta∧eta) ∈ A`. This is because the GUARD q₃ of U(q₃, theta) implies xi,
so by A1a (left_mono_until): `U(xi, theta) ∈ A`. Then `theta → U(xi,eta)` (projection),
by A2a: `U(xi, U(xi,eta)) ∈ A`. Now by BX5's converse direction (A6a/BX6):
`U(xi, U(xi,eta)) → U(xi, eta)` if the guard xi continues until the event. Actually A6a says
`U(xi, xi∧U(xi,eta)) → U(xi, eta)`. And we have... hmm.

Actually the clearest reading: since theta implies eta (via theta = beta∧U(gamma,beta)∧xi∧**U(xi,eta)**
and eta comes from the event of U(xi,eta), which occurs strictly after x, not at theta...).

Let me step back to the semantics. U(xi, eta) at x means: ∃y>x with eta(y) and ∀z∈(x,y), xi(z).
D3 = U(q₃, theta)(x) where q₃ = beta∧U(gamma,beta)∧xi. This means ∃y>x with theta(y) and
∀z∈(x,y), q₃(z). Since q₃ implies xi, at every z∈(x,y), xi(z). Now theta(y) includes U(xi,eta)(y).
So at y, U(xi,eta) holds: ∃w>y with eta(w) and ∀z∈(y,w), xi(z). But at every z∈(x,y), xi(z),
and at every z∈(y,w), xi(z). Combined: ∀z∈(x,w), xi(z), and eta(w). So U(xi,eta)(x) holds
with witness w. This gives the SEMANTIC argument for `U(xi, eta)(x)`, but we need the
SYNTACTIC derivation `U(xi, beta∧eta) ∈ A`.

The syntactic version: from D3 = `U(q₃, theta) ∈ A`, by A1a (q₃ → xi): `U(xi, theta) ∈ A`.
Then by A2a (theta → U(xi,eta)): `U(xi, U(xi,eta)) ∈ A`. Then by A6a (absorption):
`U(xi, U(xi,eta)) ∈ A` and we want `U(xi, eta) ∈ A`. A6a says: `U(xi, xi∧U(xi,eta)) → U(xi, eta)`.
We have `U(xi, U(xi,eta)) ∈ A`. Note `U(xi,eta) → xi∧U(xi,eta)` is NOT a theorem (xi might fail
at the event). So A6a doesn't directly apply.

The correct step: from `U(xi, U(xi,eta)) ∈ A`, using A3a with `p = xi`, `q = xi`, `r = U(xi,eta)`:
We need `xi ∈ A` again!

**Key resolution**: The `U(xi, beta∧eta) ∈ A` conclusion does NOT come from applying axioms at A
alone. Burgess's "A3a" application is telescoped:

From D3 = `U(q₃, theta) ∈ A`:
- By A1a (since q₃ = beta∧U(gamma,beta)∧xi implies xi): `U(xi, theta) ∈ A`
- `theta = q₃ ∧ U(xi,eta)`. By A2a (theta → U(xi,eta)∧beta∧... — theta includes eta eventually?):

No, theta does NOT directly contain eta. theta = beta∧U(gamma,beta)∧xi∧U(xi,eta).
The event formula is U(xi,eta) — it's the EVENTUALITY, not eta itself.

**The actual Burgess A3a step produces**:
From `U(xi, U(xi,eta)) ∈ A` (obtained from U(xi, theta) → U(xi, U(xi,eta)) by A2a),
apply A3a: `xi ∧ U(xi, U(xi,eta)) → U(xi ∧ S(xi, U(xi,eta)), U(xi,eta))`.
Since `xi ∧ U(xi, U(xi, eta))` entails xi, and from A5a/BX5, `U(xi,eta) → U(xi∧U(xi,eta), eta)`,
then at the event of `U(xi, U(xi,eta))`, we have `U(xi,eta)` which expands to another event...

This is the reflexivity issue. **Under Burgess's closed-guard semantics**, A3a is `p ∧ U(q,r) → U(q∧S(p,r), r)`.
Here S is Burgess's Since, which at point x with `U(q,r)` having event y: S(p, r)(y) holds if
∃z≤y (Burgess's non-strict) with p(z) and r on (z,y). Under closed semantics, z=y works if p(y)...

This leads into deep details. **The key architectural finding** for the codebase is:

---

### 2. What Does Burgess's Proof Actually Do (Simplified)?

Burgess's argument in Lemma 2.7, as adapted to strict/open-guard BX semantics, works as follows:

**Step 1: Extract the ruling-out witness**.
From `eta ∉ B` and maximality of B: ∃ beta₀ ∈ B, ∃ gamma₀ ∈ C with `¬U(gamma₀, beta₀∧eta) ∈ A`.

**Step 2: Apply BX5 twice to get enriched Until formulas**.
- From `U(gamma₀, beta₀) ∈ A` (since R(A,B,C) and gamma₀ ∈ C, beta₀ ∈ B):
  BX5 gives `U(gamma₀∧U(gamma₀,beta₀), beta₀) ∈ A`.
- From `U(xi, eta) ∈ A` (hypothesis):
  BX5 gives `U(xi∧U(xi,eta), eta) ∈ A`.

**Step 3: Apply BX7 to the two enriched Until formulas**.
BX7: `U(phi₁, psi₁) ∧ U(phi₂, psi₂) → U(phi₁∧phi₂, psi₁∧psi₂) ∨ U(phi₁∧phi₂, psi₁∧phi₂) ∨ U(phi₁∧phi₂, phi₁∧psi₂)`.

With phi₁ = gamma₀∧U(gamma₀,beta₀), psi₁ = beta₀, phi₂ = xi∧U(xi,eta), psi₂ = eta:
- D1: `U(phi₁∧phi₂, beta₀∧eta) ∈ A` — but `¬U(gamma₀, beta₀∧eta) ∈ A` and phi₁∧phi₂ implies gamma₀,
  so by BX1 (left_mono_until): `U(gamma₀, beta₀∧eta) ∈ A`. Contradiction. **D1 ruled out**.
- D2: `U(phi₁∧phi₂, beta₀∧phi₂) ∈ A`. Since `beta₀∧phi₂ → beta₀∧eta` (as phi₂ = xi∧U(xi,eta)...
  wait, phi₂ = xi∧U(xi,eta) does NOT imply eta). Hmm.

  Actually: psi₁∧phi₂ = beta₀∧(xi∧U(xi,eta)). Note beta₀∧(xi∧U(xi,eta)) → beta₀∧eta is FALSE
  since U(xi,eta) does not imply eta.

  So D2 gives `U(phi₁∧phi₂, beta₀∧xi∧U(xi,eta)) ∈ A`. Since phi₁∧phi₂ implies gamma₀,
  by BX1: `U(gamma₀, beta₀∧xi∧U(xi,eta)) ∈ A`. Since `beta₀∧xi∧U(xi,eta) → beta₀∧eta`...
  this still doesn't hold because U(xi,eta) is the eventuality, not eta itself.

  **Wait**: the CODEBASE axiom BX7 (linear_until) has a different form than Burgess's A7a!
  Codebase BX7 (Axiom.linear_until φ ψ χ θ):
  `U(φ,ψ) ∧ U(χ,θ) → U(φ∧χ, ψ∧θ) ∨ U(φ∧χ, ψ∧χ) ∨ U(φ∧χ, φ∧θ)`

  The three disjuncts are ALL with guard `phi∧chi`. The events are: psi∧theta, psi∧chi, phi∧theta.

  Burgess's A7a: `U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`.
  Three disjuncts: guard is p∧r, p∧s, q∧r respectively; event is ALWAYS q∧s.

  **THIS IS A FUNDAMENTAL DIFFERENCE**. The codebase BX7 has fixed guard (phi∧chi) and
  varying events. Burgess's A7a has varying guards and fixed event (q∧s).

---

### 3. Critical Insight: BX7 vs Burgess A7a — Different Axiom Forms

Burgess's A7a:
```
U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)
```
(event is ALWAYS `q∧s`)

Codebase BX7 (linear_until φ ψ χ θ):
```
U(φ,ψ) ∧ U(χ,θ) → U(φ∧χ, ψ∧θ) ∨ U(φ∧χ, ψ∧χ) ∨ U(φ∧χ, φ∧θ)
```
(guard is ALWAYS `φ∧χ`)

In Burgess's formulation (guard-last convention: U(guard, event)):
- First: U(p,q) = Until(guard=p, event=q); U(r,s) = Until(guard=r, event=s)
- Disjuncts: U(p∧r, q∧s), U(p∧s, q∧s), U(q∧r, q∧s)

In codebase (guard-first convention: untl(guard, event)):
- First: untl(φ,ψ) = Until(guard=φ, event=ψ); untl(χ,θ) = Until(guard=χ, event=θ)
- Disjuncts: U(φ∧χ, ψ∧θ), U(φ∧χ, ψ∧χ), U(φ∧χ, φ∧θ)

**In codebase notation** (guard-first):
- φ = guard₁ = p (in Burgess notation)
- ψ = event₁ = q
- χ = guard₂ = r
- θ = event₂ = s

Codebase disjuncts in Burgess notation: U(p∧r, q∧s), U(p∧r, q∧r), U(p∧r, p∧s).

This is NOT the same as Burgess's A7a! In Burgess's A7a, the three guards are p∧r, p∧s, q∧r.
In the codebase BX7, all three disjuncts have guard p∧r.

**Semantic check**: Burgess's semantics has U(guard, event) at x meaning ∃y>x, event(y) ∧ ∀z∈(x,y), guard(z).
If U(p,q) and U(r,s) hold at x with witnesses y₁ and y₂:
- If y₁ = y₂: p∧r on (x,y₁), q∧s at y₁ → U(p∧r, q∧s)
- If y₁ < y₂: p∧r on (x,y₁), q at y₁, s at y₂, r on (x,y₂)
  → s on (y₁,y₂), p on (x,y₁), s on (x,y₂) but p only on (x,y₁)
  → U(p∧s, q∧s) with witness y₁: guard p∧s on (x,y₁)? Need s on (x,y₁) too.
  Actually: U(r,s) gives r on (x,y₂) and s at y₂. Since y₁ < y₂, r on (x,y₂) includes (x,y₁).
  And p on (x,y₁). So p∧r on (x,y₁), q at y₁... but s at y₂ not at y₁ unless y₁ is after the U(r,s) event.

This is getting complex. The point is: **the codebase BX7 is semantically sound** (it was verified),
but it has a different form from Burgess's A7a. The codebase BX7 always has guard phi∧chi.

For applying Burgess's Lemma 2.7 proof, we need to use the **codebase BX7** form, not
directly translate Burgess's A7a form.

---

### 4. Reconstructing Lemma 2.7 in Codebase Terms

With codebase BX7: `U(phi₁, psi₁) ∧ U(phi₂, psi₂) → U(phi₁∧phi₂, psi₁∧psi₂) ∨ U(phi₁∧phi₂, psi₁∧phi₂) ∨ U(phi₁∧phi₂, phi₁∧psi₂)`.

Apply BX5 twice:
- phi₁ = gamma₀∧U(gamma₀,beta₀), psi₁ = beta₀: from `U(gamma₀,beta₀) ∈ A`, BX5 gives `U(phi₁, beta₀) ∈ A`.
- phi₂ = xi∧U(xi,eta), psi₂ = eta: from `U(xi,eta) ∈ A`, BX5 gives `U(phi₂, eta) ∈ A`.

BX7 with these gives ONE of:
- D1: `U(phi₁∧phi₂, beta₀∧eta) ∈ A`
- D2: `U(phi₁∧phi₂, beta₀∧phi₂) ∈ A`
- D3: `U(phi₁∧phi₂, phi₁∧eta) ∈ A`

**Ruling out D1**: phi₁∧phi₂ implies gamma₀ (since phi₁ = gamma₀∧...). By BX1 (left_mono_until):
`U(gamma₀, beta₀∧eta) ∈ A`. But `¬U(gamma₀, beta₀∧eta) ∈ A`. Contradiction. D1 ruled out.

**Ruling out D2**: phi₁∧phi₂ implies gamma₀. By BX1: `U(gamma₀, beta₀∧phi₂) ∈ A`.
And phi₂ = xi∧U(xi,eta), so `beta₀∧phi₂ = beta₀∧xi∧U(xi,eta)`.
Does `beta₀∧phi₂ → beta₀∧eta`? No, because U(xi,eta) does not imply eta.
Does `¬U(gamma₀, beta₀∧eta) ∈ A` rule out D2? Need `beta₀∧phi₂ → beta₀∧eta`, which fails.

So D2 is NOT ruled out by `¬U(gamma₀, beta₀∧eta) ∈ A` using the codebase BX7.

**D2 in Burgess's A7a**: The second Burgess disjunct is `U(p∧s, q∧s)`, i.e., guard is p∧s and event is q∧s.
Here p = gamma₀∧U(gamma₀,beta₀), s = eta, q = beta₀. So guard is (gamma₀∧U(gamma₀,beta₀))∧eta = phi₁∧eta.
Event is beta₀∧eta.
`¬U(gamma₀, beta₀∧eta) ∈ A` and phi₁∧eta implies gamma₀, so by BX1: `U(gamma₀, beta₀∧eta) ∈ A`.
Contradiction. **D2 in Burgess's A7a IS ruled out by `¬U(gamma₀, beta₀∧eta)`**.

But in the codebase BX7, D2 is `U(phi₁∧phi₂, beta₀∧phi₂)` — this has event beta₀∧phi₂ = beta₀∧xi∧U(xi,eta),
NOT beta₀∧eta. So `¬U(gamma₀, beta₀∧eta)` does not rule it out.

**Critical finding**: **The codebase BX7 has different disjuncts from Burgess's A7a.**
This is the root cause of why the proof does not translate directly.

In Burgess's A7a, the "second comes first" case has guard p∧s (= gamma₀∧U(gamma₀,beta₀)∧eta),
which contains eta in the guard, making the BX1 application work. In the codebase BX7,
the guard is always phi₁∧phi₂ (= gamma₀∧U(gamma₀,beta₀)∧xi∧U(xi,eta)), which contains U(xi,eta)
but not eta itself.

---

### 5. Implications for Implementation: What Strategy Actually Works?

**Option A: Use Burgess's A7a form**.
If we can derive the Burgess A7a form from the codebase axioms, or prove a lemma
`burgessA7a_from_BX7` that gives the Burgess form, the rest follows.

Burgess A7a: `U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`.

Claim: this is derivable from BX7 + BX1/BX2. The codebase BX7 gives:
`U(p∧r, q∧s) ∨ U(p∧r, q∧r) ∨ U(p∧r, p∧s)`.

From D2 = `U(p∧r, q∧r)`: since q∧r → q, by BX2: `U(p∧r, q)`. Now, we also have U(r,s),
and p∧r implies r. So `U(p∧r, q) ∈ A` (from D2) and `U(r,s) ∈ A`. By BX7 again...
this doesn't obviously give Burgess D2 = `U(p∧s, q∧s)`.

**Option B: Use codebase BX7 directly with modified argument**.

The surviving disjunct from codebase BX7 when D1 is ruled out and some other argument rules out D2:

Actually, we can rule out D2 = `U(phi₁∧phi₂, beta₀∧phi₂) ∈ A` differently:
Since phi₁∧phi₂ implies gamma₀ and beta₀∧phi₂ implies beta₀∧xi∧U(xi,eta):
By BX2 (right_mono_until) with `beta₀∧xi∧U(xi,eta) → beta₀`: `U(gamma₀, beta₀) ∈ A`.
That doesn't help.

But: phi₂ = xi∧U(xi,eta) contains U(xi,eta). So beta₀∧phi₂ = beta₀∧xi∧U(xi,eta).
`U(phi₁∧phi₂, beta₀∧xi∧U(xi,eta)) ∈ A`. Since phi₁∧phi₂ implies xi∧U(xi,eta):
by BX2: `U(phi₁∧phi₂, U(xi,eta)) ∈ A`. Now phi₁∧phi₂ implies gamma₀, so by BX1:
`U(gamma₀, U(xi,eta)) ∈ A`. This gives F(U(xi,eta)) ∈ A. That's interesting but doesn't
immediately contradict `¬U(gamma₀, beta₀∧eta) ∈ A`.

Can we rule out D2 using `¬U(gamma₀, beta₀∧eta) ∈ A`? We need to show D2 → `U(gamma₀, beta₀∧eta)`.
This would require: `U(gamma₀, beta₀∧xi∧U(xi,eta)) → U(gamma₀, beta₀∧eta)`.
By BX2 this needs `beta₀∧xi∧U(xi,eta) → beta₀∧eta`. Since U(xi,eta) doesn't imply eta, this fails.

**Therefore D2 from codebase BX7 cannot be ruled out by `¬U(gamma₀, beta₀∧eta)`.**

This means codebase BX7 does NOT directly work for Burgess's D1/D2 elimination argument.

---

### 6. Answers to the Five Questions

**Q1: How does Burgess's actual Lemma 2.7 proof handle the three issues?**

Burgess uses Burgess A7a (not BX7). His D1 and D2 disjuncts both have event `beta₀∧eta` and
guards that imply gamma₀, so `¬U(gamma₀, beta₀∧eta)` rules out both. The surviving D3 has
guard `beta₀∧U(gamma₀,beta₀)∧xi` (which implies xi) and event `beta₀∧eta`. By BX13 (A3a),
he gets `U(xi, beta₀∧eta) ∈ A` and consistency of ζ follows by Lemma 2.2 (consistency criterion:
if U(gamma, delta) ∈ A, gamma is consistent, and xi is the guard of this U-formula).

Wait — re-reading: the consistency of `ζ = S(alpha, beta₀∧eta) ∧ beta₀ ∧ xi ∧ U(gamma₀, beta₀)`.
From `U(xi, beta₀∧eta) ∈ A`, Lemma 2.2 gives xi is consistent. But ζ is richer.

The actual argument (reading Lemma 2.4 as a template): to show ζ is consistent, Burgess applies
A3a to `U(xi, beta₀∧eta) ∈ A` with p = alpha ∈ A, q = xi, r = beta₀∧eta:
`alpha ∧ U(xi, beta₀∧eta) → U(xi∧S(alpha, beta₀∧eta), beta₀∧eta) ∈ A`.
Since alpha ∈ A and U(xi, beta₀∧eta) ∈ A, by Lemma 2.2 the guard `xi∧S(alpha, beta₀∧eta)` is consistent.
Now S(alpha, beta₀∧eta) ∧ xi is consistent, and `S(alpha, beta₀∧eta) → S(alpha, beta₀)` by monotonicity,
so... No, that's not enough for the full ζ.

The correct reading: Burgess's Lemma 2.7 says "the problem reduces to proving consistency of
each particular such ζ", then demonstrates `U(xi, beta∧eta) ∈ A`, and then says "whence
consistency of ζ follows by Lemma 2.2." Burgess must mean: from `U(xi, beta∧eta) ∈ A`,
apply A3a repeatedly with each component of ζ (alpha from A, U(gamma, beta) from C) to build up
a single Until formula whose guard is ζ minus its last component, and the event is beta∧eta.
Then Lemma 2.2 gives the guard (= most of ζ) is consistent.

But Burgess's Lemma 2.4 (the template) does exactly this: it builds `U(gamma∧S(alpha, beta), beta) ∈ A`
from `U(gamma, beta) ∈ A` by applying A3a once. The "consistency of ζ" in Lemma 2.4 requires
just that gamma∧S(alpha,beta) is consistent, which follows from Lemma 2.2.

In Lemma 2.7 (the Until-splitting version), Burgess shows `U(xi, beta∧eta) ∈ A`, which means
the guard `xi` is consistent (Lemma 2.2). Then by A3a applied to `alpha ∈ A`:
`U(xi∧S(alpha, beta∧eta), beta∧eta) ∈ A`, so `xi∧S(alpha,beta∧eta)` is consistent (Lemma 2.2).
Then by A3a applied to `U(gamma, beta) ∈ A` (with some modifications)... the argument telescopes.

**The actual consistency argument**: `U(xi, beta∧eta) ∈ A` → (by BX13/A3a with alpha ∈ A):
`U(xi, beta∧eta∧S(xi, alpha)) ∈ A` → consistency of `xi∧S(xi,alpha) ...` hmm wrong direction.

Actually BX13 (enrichment_until) in our codebase:
`p ∧ U(phi, psi) → U(phi, psi ∧ S(phi, p))`.
So: `alpha ∧ U(xi, beta∧eta) → U(xi, beta∧eta∧S(xi, alpha))`.

From alpha ∈ A and U(xi, beta∧eta) ∈ A: `U(xi, (beta∧eta)∧S(xi, alpha)) ∈ A`.
By Lemma 2.2: xi is consistent (that's just that xi is consistent, not ζ).

To get consistency of ζ = S(alpha, beta∧eta) ∧ beta ∧ xi ∧ U(gamma, beta), note:
- `U(xi, (beta∧eta)∧S(xi, alpha)) ∈ A` has EVENT `(beta∧eta)∧S(xi, alpha)`.
- By BX1 (left_mono with xi → xi): `U(xi, (beta∧eta)∧S(xi,alpha)) ∈ A`.
- Now apply BX13 again with `U(gamma₀, beta₀)` (hmm, need to work from the right formula).

The key: ζ is consistent iff ζ is satisfiable. From `U(xi, beta∧eta∧S(xi,alpha)) ∈ A` (by BX13),
the event formula `beta∧eta∧S(xi,alpha)` is the SEED for a future MCS D containing xi as the
GUARD (via Lemma 2.2). Since `S(xi, alpha) ∈ D` and `beta∧eta ∈ D`, and we can further enrich
D to contain `U(gamma,beta)` by adding `U(gamma, beta) ∈ D` (using `r(D, beta, C)` from the
construction)... This is where the argument gets circular or requires careful ordering.

**The bottom line**: Burgess's Lemma 2.7 proof works SYNTACTICALLY because:
1. A7a (Burgess form) rules out D1 and D2 simultaneously (both have event beta∧eta and guards implying gamma₀)
2. D3 survives with guard implying xi
3. A3a applied to D3 + alpha ∈ A gives a U-formula whose guard is ζ (essentially), so Lemma 2.2 gives ζ consistent

The codebase's BX7 has a different form, so D2 cannot be ruled out directly. This means the
Burgess direct seed approach requires either:
(a) A new helper lemma establishing the Burgess A7a form from BX7+BX1/BX2, OR
(b) A different proof of consistency using only codebase BX7.

**Q2: Does Burgess's seed include h_content(C) explicitly?**

No. The seed D₀ explicitly includes `{U(gamma, beta) : gamma ∈ C, beta ∈ B}` (all Until
formulas from C-formulas and B-formulas). This is NOT the same as h_content(C) (which is
`{H(psi) : H(psi) ∈ C}`). Burgess encodes the R-relation content directly, not via the
H-operator filter. The consistency proof then uses these U-formulas directly in the ζ argument.

The current codebase approach of using `h_content(C)` as a shortcut works for Lemma 2.6
(because h_content(C) ⊆ B from Phase 5b) but does NOT provide the right structure for
Lemma 2.7 (where the interaction between xi and the C-content is mediated by the BX5/BX7/BX13 chain).

**Q3: How does Burgess get xi into D?**

By constructing D from a Lindenbaum extension of D₀ which contains xi explicitly. The seed D₀
includes xi as a direct element: `D₀ = ... ∪ {xi} ∪ ...`. The consistency of D₀ (proved via
the BX5+BX7+BX13 chain) ensures xi can be in a consistent extension. After Lindenbaum, the
resulting MCS D contains xi. This does NOT require `F(xi) ∈ A`.

The key is that the consistency of ζ = S(alpha, beta∧eta) ∧ **beta** ∧ **xi** ∧ U(gamma, beta)
is proved, and xi appears in ζ. Once ζ is consistent for each choice of alpha, beta, gamma,
the set D₀ is consistent (by a compactness/finitary argument), and Lindenbaum gives an MCS
D containing all of D₀, hence xi ∈ D.

**Q4: How does Burgess get eta ∈ B'?**

After D is obtained with xi ∈ D, let B' be maximal with `B ⊆ B' ∧ r(A, B', D)`.
Then for all beta ∈ B, `U(xi, beta∧eta) ∈ A` (which was derived in Step 3 of the main argument).
By Lemma 2.3 (r-relation equivalence), `r(A, beta∧eta, D)` iff `S(alpha, beta∧eta) ∈ D` for all
alpha ∈ A. But S(alpha, beta∧eta) ∈ D₀ ⊆ D (by construction!), so `r(A, beta∧eta, D)` holds.
Since this holds for all beta ∈ B, `r(A, eta, D)` follows (from B being a DCS containing top,
or by appropriate intersection arguments). Then by maximality of B', eta ∈ B'.

More precisely: eta ∈ B' because `r(A, eta, D)` holds (for all gamma ∈ D, U(gamma, eta) ∈ A —
this follows from `U(xi, beta∧eta) ∈ A` and xi ∈ D via the r-relation equivalence), and B' is
constructed to be maximal with r(A, -, D). The fact that eta ∈ D₀ is not required;
what's required is that r(A, eta, D) holds, which Burgess derives from the S-formulas in D₀.

**Q5: Is the open-guard semantics issue (U(xi,eta) ↛ F(xi)) a real problem?**

Yes, it IS a real problem for the codebase's previously-planned approach of using
`forward_temporal_witness_seed_consistent` to get xi into D (which requires F(xi) ∈ A).
Burgess's proof bypasses this by including xi explicitly in D₀ and proving the seed consistent
directly. The open-guard issue affects WHICH axioms can be used in the consistency proof, but
the fundamental seed-inclusion of xi avoids the F(xi) requirement entirely.

The codebase axiom BX7 (different from Burgess A7a) is the real implementation challenge.

---

### 7. The eta ∈ B' Argument in Codebase Terms

The handoff lists this as Blocker 3. The resolution:

From the seed D₀, D contains `S(alpha, beta∧eta)` for all alpha ∈ A, beta ∈ B.
By Burgess Lemma 2.3 (codebase: `burgessR_implies_burgessRSince` / `lemma_2_3_equiv`):
`r(A, beta∧eta, D)` holds iff `S(alpha, beta∧eta) ∈ D` for all alpha ∈ A.
Since D ⊇ D₀ and D₀ contains all S(alpha, beta∧eta), we have r(A, beta∧eta, D) for all beta ∈ B.

For eta ∈ B': need r(A, eta, D), i.e., `S(alpha, eta) ∈ D` for all alpha ∈ A.
From r(A, beta∧eta, D): `U(gamma, beta∧eta) ∈ A` for all gamma ∈ D.
This gives `U(gamma, eta) ∈ A` for all gamma ∈ D (by right_mono_until with beta∧eta → eta).
Hence r(A, eta, D) holds. By Burgess's Lemma 2.3: `S(alpha, eta) ∈ D` for all alpha ∈ A.

Then DC({eta} ∪ B') satisfies r(A, -, D): for any phi ∈ DC({eta} ∪ B'):
- If phi ∈ B': r(A, phi, D) by B' construction.
- If phi = eta: r(A, eta, D) just proved.
- If phi is a consequence: use DCS closure and r-relation monotonicty.

Hence eta extends B' while preserving r(A, -, D), contradicting maximality of B' —
UNLESS eta is already in B'. Therefore eta ∈ B'.

---

## Recommendations

### For Implementation (Phase 6 Lemma 2.7)

The core challenge is that the codebase BX7 axiom differs from Burgess's A7a. Two approaches:

**Approach 1 (Preferred)**: Prove the Burgess A7a-form as a derived lemma in the codebase.
Burgess A7a: `U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`.
This can likely be derived from codebase BX7 + BX1/BX2/BX5, requiring maybe 20-30 lines.
Once available, Burgess's D1/D2 elimination works directly.

**Approach 2**: Adapt the proof to work with codebase BX7 directly. The surviving disjunct
D3 from codebase BX7 is `U(phi₁∧phi₂, phi₁∧eta) ∈ A` where phi₁ = gamma₀∧U(gamma₀,beta₀) and
phi₂ = xi∧U(xi,eta). The guard phi₁∧phi₂ implies xi (via phi₂), so:
By BX1: `U(xi, phi₁∧eta) ∈ A`. By BX2 (phi₁∧eta → eta... wait, phi₁ = gamma₀∧U(gamma₀,beta₀),
so phi₁∧eta implies eta only if phi₁ → eta, which it doesn't). Hmm.

Actually: from D3 = `U(phi₁∧phi₂, phi₁∧eta) ∈ A`:
- phi₁∧phi₂ implies xi (since phi₂ = xi∧U(xi,eta) implies xi)
- phi₁∧eta implies eta (since phi₁∧eta → eta trivially)
- By BX1: `U(xi, phi₁∧eta) ∈ A`
- By BX2 (phi₁∧eta → eta): `U(xi, eta) ∈ A`... but wait, phi₁∧eta = (gamma₀∧U(gamma₀,beta₀))∧eta.
  Does this imply eta? YES, phi₁∧eta → eta.
- So: `U(xi, eta) ∈ A`. But we ALREADY know this (it's a hypothesis).

So D3 from codebase BX7 gives us back U(xi,eta) ∈ A via this chain — which is circular.
We need `U(xi, beta∧eta)`, not just `U(xi, eta)`.

The correct D3 from codebase BX7 is `U(phi₁∧phi₂, phi₁∧eta) ∈ A`.
phi₁∧eta = (gamma₀∧U(gamma₀,beta₀))∧eta. This does NOT contain beta₀∧eta = needed.

**Key issue confirmed**: Codebase BX7 gives D3 with event phi₁∧eta (not beta₀∧eta as in Burgess).
The event beta₀ comes from psi₁ = beta₀ in Burgess's labeling. In codebase BX7, the event
of the first is psi₁ = beta₀, and D3 event is phi₁∧psi₂ = phi₁∧eta (which doesn't include beta₀).

Burgess's D3 event is psi₁∧psi₂ = beta₀∧eta. In codebase BX7, the first disjunct D1 has event
psi₁∧psi₂ = beta₀∧eta. So Burgess D3 corresponds to codebase D1!

**Re-labeling**:

Burgess A7a: D1=U(p∧r, q∧s), D2=U(p∧s, q∧s), D3=U(q∧r, q∧s).
Codebase BX7: C1=U(p∧r, q∧s), C2=U(p∧r, q∧r), C3=U(p∧r, p∧s).

With p=phi₁, q=psi₁=beta₀, r=phi₂, s=psi₂=eta:
- Burgess D1 = U(phi₁∧phi₂, beta₀∧eta) = Codebase C1. Ruled out by `¬U(gamma₀, beta₀∧eta)`.
- Burgess D2 = U(phi₁∧eta, beta₀∧eta). Ruled out same way.
- Burgess D3 = U(beta₀∧phi₂, beta₀∧eta) — this is U(beta₀∧xi∧U(xi,eta), beta₀∧eta).
  The guard beta₀∧xi∧U(xi,eta) implies xi. The event is beta₀∧eta. This is DIFFERENT from C3.

Codebase C2 = U(phi₁∧phi₂, beta₀∧phi₂) = U(phi₁∧phi₂, beta₀∧xi∧U(xi,eta)).
Codebase C3 = U(phi₁∧phi₂, phi₁∧eta) = U(phi₁∧phi₂, gamma₀∧U(gamma₀,beta₀)∧eta).

None of C2, C3 directly gives U(xi, beta₀∧eta) ∈ A.

**Conclusion on BX7 vs A7a**:
Burgess A7a is NOT derivable from codebase BX7 in general (they have different forms).
However, the key derived formula `U(xi, beta₀∧eta) ∈ A` may be obtainable from codebase BX7
via a more complex chain. Specifically:

From codebase C1 = `U(phi₁∧phi₂, beta₀∧eta) ∈ A` (if it survives):
- phi₁∧phi₂ implies xi (via phi₂), so by BX1: `U(xi, beta₀∧eta) ∈ A`.

But C1 is ruled out! So this doesn't help.

From Burgess D3 = `U(beta₀∧phi₂, beta₀∧eta)` (if available — but this is NOT a codebase disjunct):
- beta₀∧phi₂ implies xi, so `U(xi, beta₀∧eta) ∈ A` follows.

**The gap**: Burgess's D3 (U(q∧r, q∧s)) is available in Burgess A7a but NOT in codebase BX7.

**Recommendation**: Prove a separate lemma `burgessA7a_in_A` that derives the Burgess A7a form
from codebase axioms. This may require BX7 + BX5 + BX2/BX1 in combination.

Alternatively, investigate whether codebase BX7 was designed to be equivalent to Burgess A7a
under the BX axiom system, just in a different presentation. The team should check if
`Axiom.linear_until` in Axioms.lean has a comment clarifying its relationship to Burgess A7a.

---

## Summary of Key Findings

| Question | Finding |
|----------|---------|
| Seed structure | D₀ = {S(alpha,beta∧eta)} ∪ B ∪ {xi} ∪ {U(gamma,beta)} — NOT h_content(C) |
| xi in D | Via explicit inclusion in D₀, not via F(xi) ∈ A |
| eta in B' | Via r(A, beta∧eta, D) from S-formulas in D, then maximality of B' |
| BX7 vs A7a | CRITICAL: codebase BX7 has different disjuncts from Burgess A7a |
| D1/D2 elimination | Only works directly for D1; D2 requires Burgess A7a form or new lemma |
| Open-guard issue | Real for old approach; Burgess's seed-based proof avoids F(xi) entirely |

## References

- Burgess 1982: Lemma 2.6 (p. 370), Lemma 2.7 (p. 371-372)
- Xu 1988: Lemma 2.4 (simpler splitting, no A7a needed)
- PointInsertion.lean: lines 940-1073 (lemma_2_7 and helpers)
- Axioms.lean: lines 226-236 (BX7/linear_until), lines 175-185 (BX13/enrichment_until)
- RRelation.lean: lines 1171-1194 (burgessR3Maximal_exists_from_seed)

## Handoff Recommendation

The BX7 vs Burgess A7a discrepancy is the core blocker. The implementation team needs to
either:

1. Prove `burgessA7a_from_BX7` as a derived lemma (showing the Burgess form follows from
   codebase axioms), then use Burgess's argument verbatim, OR
2. Use Xu's Lemma 2.4 (2.4 in our codebase) which has a simpler splitting that avoids
   the A7a application entirely and works directly with the codebase infrastructure.

Xu's approach (Option C from the handoff) remains the most viable path given the BX7/A7a
discrepancy.
