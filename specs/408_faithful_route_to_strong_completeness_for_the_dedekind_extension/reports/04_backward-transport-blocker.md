# Blocker Research: the refuted backward Until/Since transport at the real extension

- **Task**: 408 — faithful route to strong completeness for the Dedekind extension
- **Type**: lean4 (hard mode: H2, H3, H4; `--lit`)
- **Question**: Phase 7.1's `BFMCS.toRealBundle_restricted_backward_until_since` is refuted. Is
  `cantor_bfmcs_dense_real_restricted_buc` reachable, by which route, and is the residual the
  implementer named the right one?
- **Reference-grounding tier**: Tier 1 (literature-backed). Primary sources: Burgess 1982 I
  (the `U`/`S` completeness proof this tree's chronicle is a transcription of), Burgess 1984
  §2.7 (the Dedekind-completion construction), Reynolds 1992 §§5–6 (the Prior gap axioms).

---

## Verdict (short)

**`cantor_bfmcs_dense_real_restricted_buc` is reachable, and all four of its cases close.** The
missing ingredient is **not** the bounded witness the Phase 7.1 handoff named. It is the
**Prior-S mirror of Phase 6.2's gap lemma, applied to the guard formula `ψ` rather than to a
witness**:

> **(G)** at an unselected real `r`, if `ψ ∈ m q` for every rational `q ∈ (r, c)` for some
> rational `c > r`, then `ψ ∈ limitSetBelow m r` — i.e. `ψ` also holds on a whole interval of
> rationals abutting `r` **from below**.

(G) is `Axiom.prior_S_gap` — "the `ψ`-region has no definable right gap" — and it is exactly the
step Reynolds performs at every gap in §6. With (G) in hand:

- **Refutation 1** (backward `snce`, gap witness) dies because its `V(ψ) = (g,5)` has a definable
  right gap at `g`; the guard extends below `g` and the `snce` witness is then placed **below the
  gap**, where `limitMCSBelow_cofinal_below` already supplies it. No bounded witness is needed.
- **Refutation 2** (backward `untl`, gap target) dies because its oscillating `V(ψ)` contradicts
  (G) at `g`; once `ψ` holds on `(a, g)`, rational backward coherence puts `untl φ ψ` in `m q`
  for every rational `q ∈ (a,g)`, hence in `limitSetBelow m g ⊆ limitMCSBelow m g`.

**The handoff's bounded residual is provable too** — but from `Axiom.prior_S_gap` via the same
lemma (G) instantiated at `χ := φ.neg`, **not** from Phase 6.2's `LimitFutureWitness`, which is a
Prior-**U** statement and cannot bound anything. It is also **not needed**: the guard-extension
route is shorter and closes cases the bounded witness does not reach.

**Plan fidelity: the v3 plan deviates**, in one specific and correctable way (§4). Phase 7.1
asked for an `fc`-generic bundle-level transport whose only hypothesis on the rational bundle is
restricted backward coherence. That is precisely the point at which both primary sources reach
for a gap axiom, and the plan's own Phase 6.2 already established the correct shape
(`fc`-conditional, chronicle-discharged) for the sibling obligation. **A plan revision is
required before re-dispatching implementation.** Phase 7.2's forward case B is unaffected.

---

## 1. The key literature for *this* obstruction

The obstruction is: transporting `U`/`S` coherence from a dense (rational) chronicle to its
Dedekind completion, at a point where the witness or the target sits on the far side of a gap.
Three sources bear on it, and they divide the work in a way that is decisive for the verdict.

### 1.1 Burgess 1982 I — the `U`/`S` source. It has **no** Dedekind variant.

`Burgess - 1982 - Axioms for tense logic. I. "Since" and "until".pdf`, Notre Dame Journal of
Formal Logic 23(4), pp. 367–374. Page mapping verified against the running heads: PDF page `i` ↔
printed `366 + i`.

This is the paper the tree's chronicle layer is a transcription of — Burgess's `(f,g)` chronicle
with conditions **C0–C5** is `cantorBfmcsDense`'s ancestor. Its variants table, **printed p.369**,
reads verbatim:

> **1.6 Variants** By adding extra axioms to `𝒥₀` we can get sound and complete axiomatizations
> for the `S`, `U`-tense logics of various subclasses of `𝒦₀`, characterized by additional
> postulates on the order relation `<`. We tabulate the results:
>
> | Postulates on `<`: | Axioms for `S`, `U`: |
> |---|---|
> | Density | `F'⊤` |
> | Discreteness | `G'⊥ ∧ H'⊥` |
> | First Element | `FPH⊥` |
> | Last Element | `PFG⊥` |
> | No First Element | `P⊤` |
> | No Last Element | `F⊤` |

**There is no Continuity / Dedekind-completeness row, and the paper ends at printed p.374 without
one.** Burgess's `U`/`S` completeness proof never leaves the rationals: the construction
(printed p.373) says "*We now let `X` be the union of the sets dom `fₙ` … the order being the
usual order on the rationals*". Every witness-placement lemma places its new point **strictly
between two existing rational points** or immediately after the last one — 2.9 case `n = 0`
(printed p.372): "*Let `z = x + y/2`*"; 2.10 case `n = 0` (printed p.373): "*Set `y = x + 1`*";
2.10 case `n = m+1`: "*Set `z = x + x'/2`*". **No witness is ever placed at a gap.**

Two further facts from this paper matter to the tree:

1. Burgess's Until-guard is an **interval datum**, not a pointwise quantification. **Printed
   p.372**, verbatim:

   > **(C1)** `g` is a function from `{(x,y) : x, y ∈ dom f ∧ x < y}` to the set of all DCSs.
   > **(C3)** Whenever `x, y, z ∈ dom f` and `x < y < z`, then
   > `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)`.
   > **(C5a)** Whenever `x ∈ dom f` and `U(ξ,η) ∈ f(x)`, there is some `y ∈ dom f` with `x < y`
   > and `ξ ∈ f(y)` and `η ∈ g(x,y)`.

   The pointwise reading is a *consequence* (2.11, printed p.373: "*If `z ∈ X` and `x < z < y`,
   then by C3 we have `g(x,y) ⊆ f(z)`*"), not the definition. The tree's
   `RestrictedForwardUntilSinceCoherent` / `RestrictedBackwardUntilSinceCoherent` are the
   pointwise forms — which is faithful to what the truth lemma consumes (2.11 uses C4a
   pointwise), but it means the tree has **discarded** the interval datum `g(x,y)` that carries
   guard information across the *addition of new points*. That is why re-adding points (the
   Dedekind completion does exactly this) breaks the guard, and it is the structural root of both
   refutations.

2. **C4a** is exactly the tree's backward coherence, contraposed. **Printed p.372**: "*Whenever
   `x, y ∈ dom f` and `x < y` and `∼U(γ,δ) ∈ f(x)` and `γ ∈ f(y)`, there is some `z ∈ dom f`
   with `x < z < y` and `∼δ ∈ f(z)`.*"

### 1.2 Burgess 1984 §2.7 — the completion route. It runs **only** in the `F`/`G` fragment.

`Burgess_1984_Basic_Tense_Logic.pdf`, chunk `burgess_1984_sec05`. **Printed pp.109–110**
(page markers "## Page 31 / … 109" and "## Page 32 / 110 JOHN P. BURGESS"). Verbatim:

> LEMMA: Let `T` be a perfect chronicle on a total order `(X,R)`, and `(Y,Z)` a gap in `(X,R)`.
> Then if `Ga ∈ T(z)` for all `z ∈ Z`, then `Ga ∈ T(y)` for some `y ∈ Y`.
>
> *Proof.* Suppose for contradiction that `Ga ∈ T(z)` for all `z ∈ Z` but `F∼a ∧ ∼Ga ∈ T(y)` for
> all `y ∈ Y`. For any `y₀ ∈ Y` we have `F∼a ∧ FGa ∈ T(y₀)`. Hence, by A7a,
> `F(Ga ∧ HF∼a) ∈ T(y₀)`, and there is an `x` with `y₀Rx` and `Ga ∧ HF∼a ∈ T(x)`. But this is
> impossible, since if `x ∈ Y` then `Ga ∈ T(x)`, while if `x ∈ Z` then `HF∼a ∉ T(x)`. □

and, for the completion itself:

> For each gap `(Y,Z)` in `(X,R)`, the set `C(Y,Z) = {Pa : ∃y ∈ Y(a ∈ T(y))} ∪ {Fa : ∃z ∈ Z
> (a ∈ T(z))}` is consistent. … Now if `Fa ∈ T*(w(Y,Z))`, we claim that `Fa ∈ T(z)` for some
> `z ∈ Z`. For if not, then `G∼a ∈ T(z)` for all `z ∈ Z`, and by the previous Lemma,
> `G∼a ∈ T(y)` for some `y ∈ Y`. But then `PG∼a`, which implies `∼Fa`, would belong to
> `C(Y,Z) ⊆ T*(w(Y,Z))`, a contradiction.

**Answer to dispatch question (2), part one.** Where does Burgess place the witness when the
completion point needs one on the other side of a gap? **In `Z` — the far side — with no bound
whatsoever**, and the licence is the **continuity axiom A7a** (`F∼p ∧ FGp → F(Gp ∧ HF∼p)`)
routed through the Lemma above. His obligation has **no guard**, because `F`/`G` has none;
consequently **no bounded witness ever arises in Burgess's proof**. The tree's
`BFMCS.LimitFutureWitness` is *literally* this claim, and Phase 6.2 discharged it — with
Reynolds' Prior-U in place of Burgess's A7a, which is the same move in a different axiom system.

`§2.7` says nothing about `U`/`S` at a gap. **The step Phase 7.1 attempted appears in neither
Burgess paper.**

### 1.3 Reynolds 1992 §§5–6 — the gap axioms, and the pattern our route must copy

`Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`. Page mapping re-verified against
running heads: PDF page `i` ↔ printed `164 + i` (report 03 recorded `165 + i`; that offset is off
by one, though its *printed*-page attributions were correct — see the Contradiction Log).

**Printed p.175** defines the pattern the Prior axioms exclude, verbatim:

> Given a temporal formula `A`, we can define a connective `γ⁺` by saying that `γ⁺(A)` holds
> exactly when `A` remains true for a while after now but only up until a gap after which `A` is
> arbitrarily soon false. If `γ⁺(A)` is true anywhere we call the indicated gap an `A` **left
> gap** and more generally a **definable gap**. Dually there is `γ⁻` and **right gaps**.

**Printed p.176**, Theorem 3's proof — the shape Phase 6.2 transcribed:

> Suppose for contradiction that `M ⊨ U'(A,B)(t)` in some Prior structure `M`. Thus `B` holds for
> a while up until a gap after which `¬B` is true arbitrarily soon. By Prior–U applied to `B` we
> have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction.

**Printed p.176**, §6 opening — the scoping caveat the plan already quotes:

> We know that the Prior axioms ensure that there will not be any definable gaps in a model. To
> show that our model can be made into a model over the reals we actually need a stronger result.

**Answer to dispatch question (2), part two.** Reynolds' witness-placement discipline at a gap is
uniform and is applied **to whichever formula is constant on an interval abutting the gap** —
never to the witness. §6, printed p.178 (Lemma 3): "*Prior-U applied to `R` implies that `M`
contains a last point of this stretch of `R` … or a first point of `¬R`*"; and, in the same
proof, "*`B` holds in `s`'s class up to the gap and is false arbitrarily soon after the gap.
This contradicts Prior-U applied to `B`.*" Every one of the seven Prior-U/Prior-S appeals in §6
has this form: *find the formula that is uninterruptedly true on an interval ending at the gap,
and apply the gap axiom to it.*

**In our obligation, that formula is the guard `ψ`.** The hypothesis of the backward transport
literally hands us `ψ` true throughout an interval abutting the gap — so Prior-S's antecedent
`S(⊤,ψ)` is free, exactly as Phase 6.2's `U(⊤,χ)` was free for `χ = Fφ`. This is the faithful
mechanism, and it is why the bounded-witness framing is off-source: it applies the axiom to the
wrong formula.

**Caveat, recorded honestly**: Reynolds' §6 Lemma 2 obtains its formula `R` "*by the expressive
completeness of `U` and `S`*", which the plan's Postmortem Constraints forbid building. Our use
does **not** inherit that dependency, because our `ψ` is *given by the hypothesis* rather than
constructed by expressive completeness. Only the Prior-S appeal is copied, not the machinery
around it.

---

## 2. Lemma-level source-to-implementation mapping (H3, Tier 1)

All type signatures below were read out of the tree at the cited line; none is reconstructed.

| Source | Prop / Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| Reynolds 1992, printed p.168 | Prior-S (gap form) `S(⊤,φ) ∧ P(¬φ) → S(¬φ ∨ K⁻(¬φ), φ)` | `Axiom.prior_S_gap` | `Axiom ((Formula.and (Formula.snce Formula.top φ) φ.neg.somePast).imp (Formula.snce (Formula.or φ.neg (Formula.kMinus φ.neg)) φ))` | EXISTS (`ProofSystem/Axioms.lean:387`), already proved sound (`prior_S_gap_valid`, `Metalogic/Soundness.lean:1531`), **unused anywhere on the completeness route** |
| Reynolds 1992, printed p.168 | `K⁻A = ¬S(⊤,¬A)` | `Formula.kMinus` | `def kMinus (φ : Formula) : Formula := (Formula.snce Formula.top φ.neg).neg` | EXISTS (`Syntax/Formula.lean:193`) |
| Reynolds 1992, printed p.176 | "Prior axioms ⇒ no definable gaps" | — | `Axiom.minFrameClass (.prior_S_gap _) = .Dedekind` | EXISTS (`Axioms.lean:524` block) |
| Reynolds 1992, printed p.175 (`γ⁻` / right gaps) + p.176 (Thm 3 proof pattern) | **the new general lemma** | `limitGuardBelow_of_priorS` | see §3, Statement 1 | **TO PROVE** |
| Reynolds 1992, printed p.176 (`fc`-conditional discharge, same shape as 6.2) | **the new chronicle discharge** | `cantor_bfmcs_dense_limit_guard_below` | see §3, Statement 3 | **TO PROVE** |
| Burgess 1984, printed pp.109–110 (prophecy at a gap, unbounded far-side witness) | Phase 6.2's landed sibling | `cantor_bfmcs_dense_limit_future_witness` | `(fc) (hfc : FrameClass.Dedekind ≤ fc) (A) (h_mcs) (h_box_dense) (root : Formula) : (cantorBfmcsDense fc A h_mcs h_box_dense).LimitFutureWitness root` | EXISTS (`Chronicle/ChronicleLimitGapWitness.lean:203`) |
| Burgess 1984, printed pp.109–110 (same, generic form) | Phase 6.2's general lemma — the **template** for Statement 1 | `limitFutureWitness_of_priorU` | `{fc} (hfc : FrameClass.Dedekind ≤ fc) (m : Rat → Set Formula) (hm) (hUf) (hUb) (r : ℝ) (hr : ¬ ∃ q : Rat, (q:ℝ) = r) (φ) (hF : Formula.someFuture φ ∈ limitMCSBelow m r) : ∃ s : Rat, r < (s:ℝ) ∧ φ ∈ m s` | EXISTS, sorry-free (`ChronicleLimitGapWitness.lean:~85`) |
| Burgess 1982 I, printed p.372 (C5a + C3) | rational forward `U`/`S` coherence, unrestricted via self-root | `cantor_bfmcs_dense_restricted_fuc` | `(fc) (A) (h_mcs) (h_box_dense) (root) : (cantorBfmcsDense fc A h_mcs h_box_dense).RestrictedForwardUntilSinceCoherent root` — `.2` is the `snce` conjunct | EXISTS (`ChronicleToCountermodelBasic.lean:755`) |
| Burgess 1982 I, printed p.372 (C4a, contraposed) | rational backward `U`/`S` coherence | `cantor_bfmcs_dense_restricted_buc` | ditto, `RestrictedBackwardUntilSinceCoherent root` | EXISTS (`:680`) |
| Burgess 1982 I, printed p.373 (2.11's `g(x,y) ⊆ f(z)`) | guard transport, rational→real | `guard_transport_realLimitMCS` | `(m) (δ a b : ℝ) (ψ) (hguard : ∀ q : Rat, a < (q:ℝ) → (q:ℝ) < b → ψ ∈ m q) (r : ℝ) (hra : a < r + δ) (hrb : r + δ < b) : ψ ∈ realLimitMCS m δ r` | EXISTS, landed 7.1 (`ChronicleRealExtension.lean:153`) |
| tree | witness interpolation (descends) | `exists_rat_witness_of_realLimitMCS` | `(m) (δ s : ℝ) (φ) (hφ : φ ∈ realLimitMCS m δ s) (z : ℝ) (hz : z < s + δ) : ∃ u : Rat, z < (u:ℝ) ∧ (u:ℝ) ≤ s + δ ∧ φ ∈ m u` | EXISTS, landed 7.1 (`:183`) |
| tree | descent handle | `limitMCSBelow_cofinal_below` | `(m) (r : ℝ) {A} (hA : A ∈ limitMCSBelow m r) (z : ℝ) (hz : z < r) : ∃ q : Rat, z < (q:ℝ) ∧ (q:ℝ) < r ∧ A ∈ m q` | EXISTS (`Bundle/LimitMCS.lean:379`) |
| tree | interval ⇒ ultrafilter | `limitSetBelow_subset_limitMCSBelow` | `(m) (r : ℝ) : limitSetBelow m r ⊆ limitMCSBelow m r`; `limitSetBelow m r = {A | ∃ z < r, ∀ q : Rat, z < q → q < r → A ∈ m q}` | EXISTS (`LimitMCS.lean:366`, def at `:136`) |
| tree | selection | `realLimitMCS_of_rat` / `_of_not_rat` | `(m) (δ x : ℝ) (q : Rat) (h : (q:ℝ) = x + δ) : realLimitMCS m δ x = m q`; `(h : ¬ ∃ q, (q:ℝ) = x + δ) : realLimitMCS m δ x = limitMCSBelow m (x + δ)` | EXISTS (`Bundle/RealExtension.lean:99`, `:110`) |
| tree | the four target cases | `BFMCS.RestrictedBackwardUntilSinceCoherent` | `∀ fam ∈ B.families, (∀ t φ ψ, untl φ ψ ∈ subformulaClosure root → (∃ s, t < s ∧ φ ∈ fam.mcs s ∧ ∀ r, t < r → r < s → ψ ∈ fam.mcs r) → untl φ ψ ∈ fam.mcs t) ∧ (snce mirror)` | EXISTS (`Bundle/TemporalCoherence.lean:589`) |
| tree | the two landed cases | `toRealBundle_backward_until_selected`, `toRealBundle_backward_since_selected_of_rat_witness` | see `ChronicleRealExtension.lean:270`, `:304` | EXISTS, sorry-free |
| tree | `⊤ ∈ m q`, MCS plumbing | `theorem_in_mcs` + `identity`, `conj_mcs`, `SetMaximalConsistent.{negation_complete, neg_excludes, implication_property}` | as used verbatim in `ChronicleLimitGapWitness.lean:100-190` | EXISTS |

---

## 3. The route, stated exactly

Throughout, `m := fam.mcs`, `T := t + δ` is the target's shifted coordinate, `S := s + δ` the
witness's. Selected = `∃ p : Rat, (p:ℝ) = ·`.

### Statement 1 — the general gap lemma (the one new mathematical object)

```lean
theorem limitGuardBelow_of_priorS {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
    (hSf : ∀ (t : Rat) (α β : Formula), Formula.snce α β ∈ m t →
      ∃ s : Rat, s < t ∧ α ∈ m s ∧ ∀ p : Rat, s < p → p < t → β ∈ m p)
    (hSb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, s < t ∧ α ∈ m s ∧ ∀ p : Rat, s < p → p < t → β ∈ m p) →
      Formula.snce α β ∈ m t)
    (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (ψ : Formula)
    (c : Rat) (hc : r < (c : ℝ))
    (hguard : ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ m q) :
    ψ ∈ limitSetBelow m r
```

Read: *a formula true on an interval abutting an unselected real from above is true on an
interval abutting it from below* — "the `ψ`-region has no definable **right** gap at `r`"
(Reynolds' `γ⁻`, printed p.175).

**Proof** (mirrors `limitFutureWitness_of_priorU` step for step; `hSf`/`hSb` are the `.2`
projections of `_fuc`/`_buc`, where 6.2 used `.1`):

Fix a rational `t ∈ (r, c)` by `exists_rat_btwn hc`. Let `htop q : Formula.top ∈ m q` be the
same three-line `theorem_in_mcs (hm q) (identity (fc := fc) Formula.bot)` 6.2 already uses.

- **Case 1 — `ψ.neg.somePast ∉ m t`.** Contraposing `hSb` at `t` with `α := ψ.neg`, `β := ⊤`
  (guard trivial by `htop`): no rational `s < t` has `ψ.neg ∈ m s`. By
  `SetMaximalConsistent.negation_complete`, `ψ ∈ m s` for every rational `s < t`. Take the
  threshold `z := r - 1`; every rational `q ∈ (z, r)` satisfies `q < r < t`, so `ψ ∈ m q`. Done.
- **Case 2 — `ψ.neg.somePast ∈ m t`.** Build the Prior-S antecedent:
  - `snce ⊤ ψ ∈ m t` by `hSb` at `t` with a rational witness `w₀ ∈ (r, t)` (`exists_rat_btwn`),
    `⊤ ∈ m w₀` by `htop`, and guard `∀ p ∈ (w₀, t) : p ∈ (r, c)` so `hguard` applies.
  - `conj_mcs` combines the two;
    `theorem_in_mcs (hm t) (DerivationTree.axiom [] _ (Axiom.prior_S_gap ψ) hfc)` plus
    `SetMaximalConsistent.implication_property` yields
    `snce (Formula.or ψ.neg (Formula.kMinus ψ.neg)) ψ ∈ m t`.
  - `hSf` at `t` gives a rational `w < t` with `Formula.or ψ.neg (kMinus ψ.neg) ∈ m w` and
    `ψ ∈ m p` for every rational `p ∈ (w, t)`.
  - **`(w:ℝ) < r`.** Trichotomy. `(w:ℝ) = r` is excluded by `hr` — *this is the only use of
    unselectedness, exactly as in 6.2.* If `(w:ℝ) > r` then `w ∈ (r,c)`, so `ψ ∈ m w` by
    `hguard`, so `ψ.neg.neg ∈ m w`, and since `Formula.or a b = a.neg.imp b`
    (`Syntax/Formula.lean:438`), `implication_property` gives `kMinus ψ.neg ∈ m w`, i.e.
    `(snce ⊤ ψ.neg.neg).neg ∈ m w`. But `hSb` at `w` with a rational witness in `(r, w)` and
    guard `ψ.neg.neg` on `(·, w) ⊆ (r,c)` gives `snce ⊤ ψ.neg.neg ∈ m w` — `neg_excludes`,
    contradiction.
  - Then `⟨(w:ℝ), by exact_mod_cast …, fun q h₁ h₂ => …⟩` : every rational `q ∈ (w, r)` has
    `q < r < t`, hence `q ∈ (w,t)`, hence `ψ ∈ m q`. ∎

Estimated 130–170 lines — smaller than 6.2's 209 because there is no outer `by_contra` and no
Step-D double-negation dance.

### Statement 2 — the bundle predicate (mirror of `BFMCS.LimitFutureWitness`)

```lean
def BFMCS.LimitGuardBelow {fc : FrameClass} (B : BFMCS (fc := fc) Rat) : Prop :=
  ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ ψ : Formula, ∀ c : Rat,
    r < (c : ℝ) → (∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ fam.mcs q) →
    ψ ∈ limitSetBelow fam.mcs r
```

**State it without any closure hypothesis.** `LimitFutureWitness` carries
`φ ∈ deferralClosure root` and the chronicle discharge throws it away (`intro … φ _ hF`). Here a
closure hypothesis would be actively wrong: the guard `ψ` of an `untl φ ψ ∈ subformulaClosure
root` lives in `subformulaClosure`, not necessarily in `deferralClosure`, and adding the wrong
one would be an unprovable side condition at the call site.

### Statement 3 — the chronicle discharge

```lean
theorem cantor_bfmcs_dense_limit_guard_below (fc : FrameClass)
    (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) :
    (cantorBfmcsDense fc A h_mcs h_box_dense).LimitGuardBelow
```

Proof: byte-for-byte the shape of `cantor_bfmcs_dense_limit_future_witness`
(`ChronicleLimitGapWitness.lean:203-221`), with `.1` replaced by `.2` and
`root := Formula.snce α β`:

```lean
hSf := fun t α β h => (cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
         (Formula.snce α β) fam hfam).2 t α β (self_mem_subformulaClosure _) h
hSb := fun t α β h => (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
         (Formula.snce α β) fam hfam).2 t α β (self_mem_subformulaClosure _) h
```

No chronicle declaration is modified; no closure is enlarged.

### Statement 4 — the strengthened transport, and its four cases

```lean
theorem BFMCS.toRealBundle_restricted_backward_until_since {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_lgb : B.LimitGuardBelow) :
    (B.toRealBundle).RestrictedBackwardUntilSinceCoherent root
```

The **only** change from the plan's refuted statement is the added `h_lgb`, which is discharged
in the same dispatch by Statement 3. Case analysis (`rintro G ⟨fam, hfam, δ, rfl⟩` as in
`RealExtensionBundle.lean:311`):

| # | Case | Route |
|---|---|---|
| 1 | `untl`, `T` selected | **landed**: `toRealBundle_backward_until_selected` |
| 2 | `untl`, `T` unselected | `exists_rat_witness_of_realLimitMCS` at the witness with threshold `T` gives rational `u ∈ (T, S]`, `φ ∈ m u`; each rational `q ∈ (T,u)` is a selected real in `(t,s)` so the real guard reads off `ψ ∈ m q` via `realLimitMCS_of_rat`; `h_lgb` at `r := T`, `c := u` gives `ψ ∈ limitSetBelow m T`, i.e. a threshold `a < T` with `ψ` on all rationals of `(a,T)`; for each rational `q ∈ (a,T)`, `h_rbuc` at `q` with witness `u` (guard on `(q,u)` covered by `(a,T) ∪ (T,u)`, and `T` is not rational) gives `untl φ ψ ∈ m q`; conclude by `limitSetBelow_subset_limitMCSBelow` |
| 3 | `snce`, `T` selected, `S` selected | **landed**: `toRealBundle_backward_since_selected_of_rat_witness` |
| 3′ | `snce`, `T` selected, `S` unselected | `h_lgb` at `r := S`, `c := T` (guard from the real guard on `(s,t)`) gives `a < S` with `ψ` on rationals of `(a,S)`; `limitMCSBelow_cofinal_below m S hφ a` gives rational `u ∈ (a,S)` with `φ ∈ m u`; `h_rbuc` at `T` with witness `u`, guard on `(u,T) ⊆ (a,S) ∪ (S,T)` |
| 4 | `snce`, `T` unselected | first obtain a rational `u < T` with `φ ∈ m u` and `ψ` on all rationals of `(u,T)` — directly if `S` is selected, else by 3′'s two steps; then `h_rbuc` at **every** rational `q ∈ (u,T)` with the same witness `u` gives `snce φ ψ ∈ m q`, so `snce φ ψ ∈ limitSetBelow m T` with threshold `(u:ℝ)`; conclude by `limitSetBelow_subset_limitMCSBelow`. **No gap lemma is needed at the target itself.** |

### Statement 5 — the chronicle real instance (the phase's deliverable)

```lean
theorem cantor_bfmcs_dense_real_restricted_buc (fc : FrameClass)
    (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    ((cantorBfmcsDense fc A h_mcs h_box_dense).toRealBundle).RestrictedBackwardUntilSinceCoherent
      root :=
  BFMCS.toRealBundle_restricted_backward_until_since _ root
    (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense root)
    (cantor_bfmcs_dense_limit_guard_below fc hfc A h_mcs h_box_dense)
```

Signature parity with the landed `cantor_bfmcs_dense_real_restricted_tc` (same `hfc` threading,
same non-modification of `cantor_bfmcs_dense_restricted_buc`).

---

## 4. Why the two refutations die, and what the residual really is

### 4.1 Refutation 1 (backward `snce`, selected target `5`, gap witness `g`)

`V(φ) = (0,g)`, `V(ψ) = (g,5)`. The family violates the hypotheses of the strengthened transport
in **two** independent ways, both diagnosable at the gap `g`:

- **It violates `LimitGuardBelow`.** `ψ` is true on all rationals of `(g,5)` and on **no**
  rational below `g`. That is a `ψ`-**right gap** at `g` in Reynolds' sense (printed p.175),
  excluded by `Axiom.prior_S_gap`.
- **It also violates Phase 6.2's already-landed `LimitFutureWitness`.** `someFuture φ ∈ m q` for
  every rational `q < g` (a real `φ`-point exists in `(q,g)`), so
  `someFuture φ ∈ limitSetBelow m g ⊆ limitMCSBelow m g`, yet no rational `s > g` has `φ ∈ m s`
  because `V(φ) = (0,g)`. This is a stronger statement than the handoff's "*neither family
  satisfies the unrestricted rational forward Until coherence*" — the family is excluded by a
  hypothesis the tree **already has in hand**.

With `LimitGuardBelow`, case 3′ places the `snce` witness **below the gap** (`u ∈ (a,g)` from
`limitMCSBelow_cofinal_below`), not above it. This is the correction to the handoff's diagnosis:
"*descending from the witness leaves the guarded interval*" is true only because the guarded
interval was taken to stop at `g`. Prior-S extends it past `g`, and the descent lands inside.

### 4.2 Refutation 2 (backward `untl`, unselected target `g`)

`V(ψ) = (⋃ₙ(tₙ,αₙ)) ∪ (g,3)`, `V(φ) = (g,3)`. Here `ψ` is uninterruptedly true on `(g,3)` and
**false arbitrarily recently** below `g` (the oscillation) — verbatim Reynolds' `γ⁻` pattern.
`LimitGuardBelow` at `r := g` is therefore violated, and the family is excluded.

This family also fails **unrestricted rational backward Until coherence**, which is worth
recording because it is a cleaner exclusion than the docstring's claim about `φ.neg`'s definable
gap (see the Contradiction Log). Take `β := ψ ∨ ¬P'ψ ∨ ¬F'ψ` (with `P' = kMinus`,
`F' = kPlus`). `β` is true at every rational of `(q,s)` for `q < g < s < 3` — at `αₙ` because
`¬F'ψ` holds there, inside `(αₙ,tₙ₊₁)` because `¬P'ψ` holds, and above `g` because `ψ` holds —
but **false at the real `g`**, where `ψ` is false, `P'ψ` is true and `F'ψ` is true. Rational
backward coherence would then put `untl φ β` in `m q`, which is false in the generating real
model. So Refutation 2's family is not a model of the hypotheses either.

### 4.3 The handoff's bounded residual: provable, from Prior-S, and not needed

The handoff states the residual as: *from `φ ∈ limitMCSBelow m g` produce a rational `u` with
`g < u < c` and `φ ∈ m u`, for a prescribed rational bound `c > g`*, and says "*the unbounded
form is derivable from Phase 6.2's `LimitFutureWitness` … the BOUND is the whole probe*".

Three findings:

1. **It is provable** — from Statement 1 instantiated at `ψ := φ.neg`. If no rational `u ∈ (g,c)`
   has `φ ∈ m u`, then by negation-completeness `φ.neg ∈ m u` for every rational `u ∈ (g,c)`;
   Statement 1 yields a threshold `a < g` with `φ.neg` on every rational of `(a,g)`; but
   `limitMCSBelow_cofinal_below m g hφ a` produces a rational `q ∈ (a,g)` with `φ ∈ m q` —
   contradiction via `neg_excludes`. **Semantically this is precisely "`φ`'s region has no
   definable right endpoint at a gap", which is what "no definable gaps" means.**
2. **It is not derivable from `LimitFutureWitness`.** `LimitFutureWitness` is the Prior-**U**
   statement; it is discharged by `by_contra` on "*no `φ`-point above `r` at all*" and its
   conclusion is unbounded by construction. It has no purchase on a family whose `φ`-region is
   cofinal above `r` but starts late. So the handoff's stated derivation path is not available,
   and the bound is not a "residual" of 6.2 — **it needs a different axiom (`prior_S_gap`), and
   that axiom then closes the whole obligation more directly anyway.**
3. **It is not needed.** No case in §3's table uses it. Cases 3′ and 4 place the witness below
   the gap; case 2 needs no witness relocation at all.

**This is the single most important correction in this report**: a dispatch that took the
handoff's residual at face value would have looked for a bound via Prior-U, found none (correctly),
and reported the phase blocked a second time.

---

## 5. Plan-fidelity verdict

**The v3 plan deviates. A revision is required before the next implementation dispatch.**

### 5.1 The deviation, exactly

Phase 7.1's task 1 asks for

> `BFMCS.toRealBundle_restricted_backward_until_since` … The witness-pattern direction is the
> easier of the two: a real witness `s` restricts to a rational one by interpolation, and the
> guard on `(t, s)` weakens to the rational guard.

— an **`fc`-generic bundle transport whose only hypothesis on the rational bundle is restricted
backward coherence**, classified as "mechanical". Both primary sources say this cannot be
mechanical:

- Burgess 1984 (printed pp.109–110) reaches for the **continuity axiom A7a** at the analogous
  step in the strictly easier `F`/`G` fragment.
- Burgess 1982 I has **no Dedekind variant at all** (printed p.369), and never places a witness
  at a gap.

The plan's own Phase 6.2 already found the right shape for the sibling obligation and recorded it
as settled — "*the discharge of `LimitFutureWitness` is `fc`-conditional, not `fc`-generic … This
is not a weakness of the route — it is the route finally using the axioms that distinguish the
class it is proving completeness for*". **Phase 7.1 did not apply that settled design decision to
the guard obligation.** The deviation is therefore internal-consistency as much as
literature-fidelity: v3 knew the pattern and did not repeat it.

The plan's *scoping* prose is right — Phase 7.2 correctly records "*Burgess runs the completion
route only in the `F`/`G` fragment (printed pp.109-110) and says nothing about `U`/`S` at a gap*"
— but that scoping was attached only to forward case B. It applies to the backward direction
just as much, and Phase 7.1 was budgeted at "4 hours, mechanical" on the strength of that
mis-scoping.

### 5.2 The faithful decomposition (recommended revision)

**Do not widen Phase 7.2's charter, and do not dispatch this as a sibling probe.** Both framings
carry the "two-outcome probe" budget, and this obligation is not a probe: the route is
determined, the axiom is identified, the four cases are enumerated, and the discharge template is
a landed file. Framing it as a probe invites another analysis-only dispatch.

Instead:

- **New Phase 6.3 — "The definable-right-gap discharge of the guard"** (or `7.0`; the number
  matters less than the ordering). Owns a new module
  `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardWitness.lean` plus the
  `LimitGuardBelow` definition in `Bundle/RealExtensionBundle.lean`. Deliverables: Statements 1,
  2, 3. Depends on 6.2. Estimated ~180–220 lines. **One agent run (H8).** This phase is an exact
  structural clone of Phase 6.2 and should be written by pointing the implementer at
  `ChronicleLimitGapWitness.lean` as the template, with `.1 → .2`, `untl → snce`,
  `prior_U_gap → prior_S_gap`, `kPlus → kMinus`.
- **Phase 7.1 re-opened as 7.1′** (or a new 7.3) with the BLOCKER retired into a RESOLUTION
  block. Deliverables: Statement 4's three unlanded cases (2, 3′, 4) and Statement 5. The two
  landed selected-case lemmas and the guard lemma are consumed, not rewritten. Estimated
  ~140–180 lines. **One agent run (H8).** Depends on 6.3.
- **Phase 7.2** unchanged. Its forward case B is genuinely a probe and this report does not clear
  it: there the guard is the *conclusion*, so Prior-S's antecedent `S(⊤,ψ)` is **not** free, and
  the plan's interval-failure family stands. Phase 7.2's dependency should be re-pointed at 7.1′.
- **Phase 8** unchanged except that it now consumes `cantor_bfmcs_dense_real_restricted_buc` as
  landed; the `hfc` threading it already anticipates covers the new `prior_S_gap` use.
- **Postmortem Constraints**: add "*(v3.1) Do NOT re-attempt an `fc`-generic backward Until/Since
  transport whose only rational-side hypothesis is restricted backward coherence — it is refuted;
  the two counterexample families are in `ChronicleRealExtension.lean`'s docstring*", and amend
  the "*Design decisions are SETTLED*" entry about `fc`-conditionality to say it governs **every**
  gap-facing obligation on this route, not just `LimitFutureWitness`.

### 5.3 Postmortem Constraints compliance of the proposed route

Checked against every prohibition; **no amendment is required.**

| Constraint | Status |
|---|---|
| No two-sided / symmetric limit; no per-point side choice | **Respected.** The limit stays `limitMCSBelow`. `prior_S_gap` is consumed by a *lemma*, not by changing the limit's shape. The constraint's cost analysis warns that a two-sided limit "*would acquire a mirror `prior_S_gap` obligation it does not have now*" for the `somePast` half — that half is untouched here and remains unconditional; this route adds a `prior_S_gap` use in a **new** lemma only. Flagging it explicitly since the constraint's prose names the axiom. |
| No witness-aware / F-obligation-aware selection | **Respected.** Selection is unchanged; the ultrafilter limit and `limitMCSBelow_cofinal_below` are consumed as-is. |
| No modification of any `cantorBfmcsDense` chronicle declaration | **Respected.** `_fuc`/`_buc` are consumed at self-roots via `.2`, exactly as 6.2 consumed `.1`. |
| No enlargement of `deferralClosure` / `extendedDeferralClosure` / the root | **Respected**, and reinforced: `LimitGuardBelow` is stated with **no** closure hypothesis. |
| No undischarged predicate on the terminus | **Respected.** `LimitGuardBelow` is discharged in the same dispatch (Statement 3), exactly the "phase-internal with a named discharge" shape the constraints permit. |
| No re-attempt of Prior-U at the `φ` level | **Respected, and this is not that.** The refuted move applied Prior-U to a formula whose truth region below the gap need not be an interval. Here the interval is **handed to us by the hypothesis** — the guard says `ψ` holds on all of `(r,c)` — so Prior-S's antecedent `S(⊤,ψ)` is discharged from data, not from a shape argument. Different statement, different formula, different axiom. |
| No `sorry`, no vacuous definition, no new axiom | **Respected.** Every step above is a `theorem` with a proof sketch grounded in existing signatures. |
| No task numbers in `.lean` files | Cite Reynolds printed pp.175–176 and Burgess 1982 I printed p.369 / 1984 printed pp.109–110 in the new module's docstring. |

---

## 6. Adversarial Self-Verification

Every load-bearing claim was re-checked against the actual file contents or the actual PDF page
after the draft was written. Four claims were modified or added as a result; two are listed
after the table, and one contradiction was resolved.

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `Axiom.prior_S_gap` exists with the shape `S(⊤,φ) ∧ P(¬φ) → S(¬φ ∨ K⁻(¬φ), φ)` and `minFrameClass = .Dedekind` | Reynolds 1992, printed p.168 | Direct read of `ProofSystem/Axioms.lean:387-389` and the `minFrameClass` match block; `Formula.kMinus` at `Syntax/Formula.lean:193`; `Formula.somePast` at `:141`; `Formula.or a b = a.neg.imp b` at `:438` | High |
| `prior_S_gap` is used **nowhere on the completeness route**, and is already proved sound | — | `grep -rn "prior_S_gap\|prior_U_gap" FormalSystem/Metalogic/Bundle/ FormalSystem/Metalogic/BXCanonical/` returns only `prior_U_gap` (six hits, five of them docstrings, one the Phase 6.2 consumption at `ChronicleLimitGapWitness.lean:151`) — **zero** `prior_S_gap` hits. Elsewhere in the tree `prior_S_gap` appears only in soundness: `prior_S_gap_valid` (`Metalogic/Soundness.lean:1531`) plus exhaustive-match arms, so consuming it adds **no** soundness obligation | High — the draft claimed "nowhere in `FormalSystem/`", which the grep refuted; narrowed to the completeness route and corrected |
| Statement 1's proof closes, using unselectedness exactly once | Refutation 1 and 2 both violate its conclusion, and both are excluded by it — the lemma is exactly as strong as it must be | Step-by-step transcription against the landed `limitFutureWitness_of_priorU` proof script (`ChronicleLimitGapWitness.lean:96-190`), which uses the identical plumbing (`htop`, `conj_mcs`, `theorem_in_mcs (DerivationTree.axiom … hfc)`, `implication_property`, `neg_excludes`, `negation_complete`, `exists_rat_btwn`) with `.1`/`untl`/`kPlus` where Statement 1 needs `.2`/`snce`/`kMinus` | High — every tactic and lemma named has a landed use at the mirrored position; **not** machine-checked (this is research, no Lean was written) |
| Self-root instantiation at `.2` supplies unrestricted `hSf`/`hSb` with no chronicle work | — | `cantor_bfmcs_dense_restricted_fuc` (`ChronicleToCountermodelBasic.lean:755`) and `_buc` (`:680`) are `root`-polymorphic; the predicates' `.2` conjuncts (`TemporalCoherence.lean:565-568`, `:596-599`) take closure membership as a hypothesis, discharged by `self_mem_subformulaClosure (Formula.snce α β)`; 6.2 already does this for `.1` at `:210-221` | High |
| All four backward cases close with Statement 1 as the only new ingredient | Case-by-case derivation in §3's table; case 2 was checked against Refutation 2's shape and case 3′ against Refutation 1's | Hand-derivation against the verified signatures of `exists_rat_witness_of_realLimitMCS` (`≤`, descends), `limitMCSBelow_cofinal_below` (caller-chosen threshold `z`), `limitSetBelow` (`∃ z < r, ∀ q ∈ (z,r)`), `realLimitMCS_of_rat`/`_of_not_rat` | Medium-High — the four derivations are complete and each step names a landed lemma, but no `lake build` was run; the residual risk is elaboration friction (`δ`-shift casts), not mathematical |
| Refutation 1's family violates the **already-landed** `LimitFutureWitness` | `V(φ) = (0,g)`: `someFuture φ ∈ m q` for every rational `q < g`, hence in `limitSetBelow m g ⊆ limitMCSBelow m g`; no rational `s > g` has `φ ∈ m s` | Read of the predicate at `RealExtensionBundle.lean:292-296` (unselectedness hypothesis present, `g` irrational ✓) against the family in `ChronicleRealExtension.lean:63-89` | Medium — turns on `φ ∈ deferralClosure root` for `root = snce φ ψ`, which was **not** verified (`deferralClosure = baseDeferralClosure`, `TemporalFormulas.lean:276`, not unfolded here). Not load-bearing: the verdict rests on `LimitGuardBelow`, which excludes the family unconditionally |
| Refutation 2's family violates unrestricted rational **backward** Until coherence | Separating formula `β := ψ ∨ ¬P'ψ ∨ ¬F'ψ`: true at every rational of `(q,s)`, false at the real `g`; so a rational witness + rational guard exists for `untl φ β` at `q` while `untl φ β ∉ m q` | Hand-evaluated against the family's valuation as written in `ChronicleRealExtension.lean:91-107` and the `U`/`S` semantics of Burgess 1982 I §1.2 (printed p.368) | Medium — a hand semantic computation, not machine-checked; it *supersedes* the module docstring's claim (see Contradiction Log) but the verdict does not depend on either |
| The handoff's bounded residual is provable from `prior_S_gap` and **not** from `LimitFutureWitness` | Derivation in §4.3 at `ψ := φ.neg`; and `limitFutureWitness_of_priorU`'s `by_contra` hypothesis is `∀ s : Rat, r < s → φ ∉ m s`, which is vacuous for a family whose `φ`-region is cofinal above `r` | Read of `ChronicleLimitGapWitness.lean:96-97` (`by_contra hcon; push Not at hcon`) confirming the contradiction hypothesis is the *unbounded* one | High |
| Burgess 1982 I has no Dedekind/continuity variant, and never places a witness at a gap | Its variants table lists only Density, Discreteness, First/Last Element, No First/No Last Element; witness placement is `z = x + y/2`, `y = x + 1`, `z = x + x'/2` | **Direct PDF page read** of pages 3, 6, 7, 8 = printed 369, 372, 373, 374; page mapping fixed by the running heads ("367", "368 JOHN P. BURGESS", "AXIOMS FOR TENSE LOGIC I 369", …, "374 JOHN P. BURGESS" followed by the REFERENCE block) | High |
| Burgess 1982's Until-guard is an interval datum `g(x,y)`, with the pointwise form a consequence of C3 | C1/C3/C5a printed p.372; 2.11 printed p.373: "*by C3 we have `g(x,y) ⊆ f(z)`*" | Direct PDF page read (pages 6–7) | High |
| Burgess 1984 places the gap witness on the far side, unbounded, licensed by A7a; no guard arises | "*Now if `Fa ∈ T*(w(Y,Z))`, we claim that `Fa ∈ T(z)` for some `z ∈ Z`. For if not, then `G∼a ∈ T(z)` for all `z ∈ Z`, and by the previous Lemma …*"; the Lemma's proof: "*Hence, by A7a, `F(Ga ∧ HF∼a) ∈ T(y₀)`*" | Direct read of `burgess_1984/sec05_basic-tense-logic-continuity.md:75-113`, whose page markers "## Page 31 … 109" / "## Page 32 / 110 JOHN P. BURGESS" fix printed pp.109–110 | High |
| Reynolds applies the gap axioms to the formula constant on an interval abutting the gap, never to a witness | "*`B` holds in `s`'s class up to the gap and is false arbitrarily soon after the gap. This contradicts Prior-U applied to `B`.*"; "*Prior-U applied to `R` implies that `M` contains a last point of this stretch of `R` … or a first point of `¬R`*" | Direct read of `reynolds_1992/sec03_…md:42-104`, cross-checked against **direct PDF page reads** of pages 11–13 = printed 175–177 | High |
| Reynolds' `γ⁻` / "right gap" is exactly Statement 1's excluded pattern | "*`γ⁺(A)` holds exactly when `A` remains true for a while after now but only up until a gap after which `A` is arbitrarily soon false … we call the indicated gap an `A` **left gap** … Dually there is `γ⁻` and **right gaps**.*" — printed p.175 | Direct PDF page read (page 11) | High |
| Reynolds' §6 machinery depends on expressive completeness, which the constraints forbid; our use does not | "*Now by the expressive completeness of `U` and `S` there is temporal `R` …*"; "*`B` exists by expressive completeness.*" | Direct read of `sec03_…md:30,52` and PDF page 13 (printed p.177) | High — and the non-inheritance is structural: our `ψ` is a hypothesis binder, not a constructed formula |
| No plan constraint is violated by the proposed route | §5.3 table | Read of the Postmortem Constraints block (`plans/03:298-435`) line by line against each proposed step | High |

**Recommendations modified or added after verification:**

1. *Initially drafted*: "the bounded residual is the real obligation; find it via a bounded
   Prior-U." *Retracted* after checking `limitFutureWitness_of_priorU`'s `by_contra` hypothesis
   and finding it unbounded by construction. Replaced by the guard-extension route, and the
   bounded residual demoted to a corollary of Statement 1 that the route does not use. **This is
   the correction that changes the dispatch's outcome.**
2. *Initially drafted*: "state `LimitGuardBelow` with a `deferralClosure` hypothesis, mirroring
   `LimitFutureWitness`." *Changed to*: state it with no closure hypothesis, after noticing that
   the guard `ψ` of an `untl φ ψ ∈ subformulaClosure root` need not lie in `deferralClosure root`
   — the mirrored hypothesis would have been an unprovable side condition at the call site.
3. *Initially drafted*: "recommend widening Phase 7.2's charter, per the implementer's hint."
   *Changed to*: a dedicated non-probe phase pair (6.3 + 7.1′), because the obligation is
   determined rather than open, and probe-shaped budgeting is what produced the analysis-only
   risk here in the first place.
4. *Added after PDF verification*: the Burgess 1982 I variants-table finding. It was not in the
   draft, and it is the single strongest piece of evidence that the plan's "mechanical"
   classification of the backward transport was unsupported.

**Contradiction Log.** Two contradictions were found; both are resolved.

- *A*: `ChronicleRealExtension.lean:113-116` — "*Neither family satisfies the unrestricted
  rational forward Until coherence that `cantorBfmcsDense` enjoys: … in Refutation 2 the same
  happens for the definable gap of `φ.neg` at `g`.*"
  *B*: this report — Refutation 2's family fails unrestricted rational **backward** Until
  coherence (via `β := ψ ∨ ¬P'ψ ∨ ¬F'ψ`), and I could not construct a *forward* violation: for
  every candidate `untl α β` at a rational `q < g` in that family, a rational witness below `g`
  or in `(g,3)` is available, because `V(φ) = (g,3)` is entered immediately above `g` and the
  `θ`-points `{αₙ}` are themselves rational.
  *Resolution* (precedence: tree source > report prose, but a hand computation on either side is
  only Medium): **both cite the same underlying fact — the family is not `cantorBfmcsDense`-
  realizable — and the report's version is the sharper and better-supported one.** The docstring's
  claim is not shown false, only unsupported as written. Neither claim is load-bearing: the
  operative exclusion is `LimitGuardBelow`, which both families violate directly and
  unconditionally. **Recommended action**: when the new phase lands, amend the docstring's "*What
  these do and do not settle*" paragraph to say the families are excluded by the guard-side gap
  discharge, and drop the unsupported forward-coherence claim rather than defending it.
- *A*: report 03's Adversarial Self-Verification — "*page mapping verified: PDF index `i` ↔
  printed `165+i`*" for Reynolds 1992.
  *B*: this report's direct PDF reads — PDF page 11 = printed 175, page 12 = printed 176, page 13
  = printed 177, i.e. `i` ↔ `164 + i`.
  *Resolution* (precedence: direct source read > prior report): **B is correct; report 03's offset
  is off by one.** Report 03's *printed*-page attributions (p.176 for Theorem 3 and the §6
  opening, p.178 for Lemma 3) are nevertheless **correct** — it read the right content and
  mis-stated the index arithmetic. No citation in the plan or in any landed docstring needs
  changing; only report 03's parenthetical. Downstream risk: nil, since all citations in this
  tree are by printed page.

No unresolved contradictions.

---

## 7. What this does **not** settle

- **Phase 7.2 / forward case B is not cleared.** The Prior-S technique does not transfer: in the
  forward direction the guard is the *conclusion*, so nothing supplies `S(⊤,ψ)` or `U(⊤,ψ)`, and
  the plan's interval-failure family (`plans/03:1690-1700`) stands unrefuted. Keep 7.2's
  two-outcome probe framing and its fallback ladder verbatim.
- **No Lean was written or built.** Every signature quoted was read from the tree; no proof was
  elaborated. The next dispatch is an implementation dispatch, not another research one.
- **The realizability question raised in Phase 7.1's handoff ("the chronicle instance is not
  settled either way") is now settled in the positive direction** — but by construction of a
  proof route, not by showing the two families unrealizable. Their unrealizability follows as a
  corollary of the route, not the other way round.
