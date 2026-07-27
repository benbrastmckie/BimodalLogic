# Blocker Research: Discharging `BFMCS.LimitFutureWitness`

- **Task**: 408 — faithful route to strong completeness for the Dedekind extension
- **Type**: lean4 (hard mode: H2, H3, H4, H5)
- **Date**: 2026-07-27
- **Question**: can `BFMCS.LimitFutureWitness` be discharged for `cantorBfmcsDense`, and by what
  construction? If not, what must change in Phases 7–8?
- **Reference-grounding tier**: Tier 1 (literature-backed) — Reynolds 1992 and Burgess 1984 are
  both primary sources for the exact step at issue.

---

## Verdict

**Yes. `LimitFutureWitness` is dischargeable for `cantorBfmcsDense`, but only after two
corrections, neither of which is a construction change.**

1. **The predicate as currently stated is false and must be repaired.** It quantifies over *all*
   `r : ℝ`, including rational ones. At a rational `r = (p : ℝ)` where `φ` has a maximum
   (`φ ∈ m p`, `φ ∉ m u` for every rational `u > p`), the hypothesis holds and the conclusion
   fails. The consumer only ever calls it at **unselected** points, and already has
   `hx : ¬ ∃ p : Rat, (p:ℝ) = t + δ` in scope, so adding that hypothesis to the predicate costs
   one line at the definition and zero lines at the call site.

2. **The route was never using the axioms that distinguish `FrameClass.Dedekind`.** The
   obstruction is exactly a *definable gap* in the rational chronicle, and definable gaps are
   precisely what Reynolds' `Axiom.prior_U_gap` / `Axiom.prior_S_gap` exclude. `prior_U_gap`
   appears nowhere in `Bundle/`, nowhere in `BXCanonical/Chronicle/`, and nowhere in plan v2's
   Phases 3–8. The blocker is not a defect in the extension shape; it is a **missing use of the
   Dedekind axiom layer**, and the discharge is `fc`-conditional (`FrameClass.Dedekind ≤ fc`),
   not `fc`-generic.

The unlocking observation that makes the axiom applicable is a **closure fact about the concrete
chronicle**: `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc`
(`ChronicleToCountermodelBasic.lean:629,680,755`) each **discard** their closure-membership
argument (`intro t φ _ h_F`, `intro t φ ψ _ ⟨u, …⟩`, `intro t φ ψ _ h_until`), because the
underlying `limit_F_resolution` (`ChronicleConstruction.lean:722`), `limit_satisfies_c4` (`:776`)
and `limit_satisfies_c5_strong` (`:1482`) are unrestricted in the formula. **The Cantor dense
chronicle therefore satisfies full, unrestricted Until/Since coherence for every formula**, and
the auxiliary Prior-U formulas (`U(⊤, Fφ)`, `U(⊤, ¬¬Fφ)`, `U(¬Fφ ∨ K⁺¬Fφ, Fφ)`) are available at
zero cost by instantiating those three theorems at *self-roots* and discharging the membership
side condition with `self_mem_subformulaClosure`.

**Cost to Phases 7–8**: Phase 6.1 closes with a one-line predicate change plus one new module
(~200–260 lines, one general gap lemma + one chronicle instantiation). Phase 8 needs one
signature change (`countermodel_dedekind_dense` acquires `FrameClass.Dedekind ≤ fc`). **Phase 7
is a different story and this report does not clear it** — see "Phase 7: a strictly harder
instance, not cleared" below. Its Forward-case-B obstruction is of the same species but is *not*
solved by this argument, and there is a candidate refuting family for it. Phase 7 should get its
own probe before dispatch.

---

## Findings

### Lemma-level source-to-implementation mapping (H3, Tier 1)

| Source | Prop / Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| Reynolds 1992 | Prior-U axiom, printed p.168 | `Axiom.prior_U_gap` | `Axiom ((Formula.and (Formula.untl Formula.top φ) φ.neg.someFuture).imp (Formula.untl (Formula.or φ.neg (Formula.kPlus φ.neg)) φ))` | EXISTS (`ProofSystem/Axioms.lean:377`) |
| Reynolds 1992 | "Prior structure ⇒ no definable gaps", printed p.176 | — | `Axiom.minFrameClass (.prior_U_gap φ) = .Dedekind` | EXISTS (`Axioms.lean:524`) |
| Reynolds 1992 | Thm 3 proof, printed p.176: "By Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction" | *(to build)* | `limitFutureWitness_of_priorU` — see Statement 2 | TO PROVE |
| Reynolds 1992 | Lemma 3 proof, printed p.178: "Prior-U applied to `R` implies that `M` contains a last point of this stretch of `R` … or a first point of `¬R`" | *(pattern)* | Steps C–D of the proof below | TO PROVE |
| Reynolds 1992 | `K⁺A = ¬U(⊤,¬A)`, printed p.168 | `Formula.kPlus` | `def kPlus (φ) : Formula := (Formula.untl Formula.top φ.neg).neg` | EXISTS (`Syntax/Formula.lean:180`) |
| Burgess 1984 | §2.7 Continuity, printed p.109, Lemma ("if `Ga ∈ T(z)` for all `z ∈ Z`, then `Ga ∈ T(y)` for some `y ∈ Y`") | *(analogue)* | Step B/D contradiction below | TO PROVE (Reynolds route used instead) |
| Burgess 1984 | §2.7, printed p.109–110 ("Now if `Fa ∈ T*(w(Y,Z))`, we claim that `Fa ∈ T(z)` for some `z ∈ Z`") | `BFMCS.LimitFutureWitness` | see Statement 1 | EXISTS, statement wrong (`Bundle/RealExtensionBundle.lean:271`) |
| tree | descent handle | `limitMCSBelow_cofinal_below` | `(hA : A ∈ limitMCSBelow m r) (z : ℝ) (hz : z < r) : ∃ q : Rat, z < (q:ℝ) ∧ (q:ℝ) < r ∧ A ∈ m q` | EXISTS (`Bundle/LimitMCS.lean:379`) |
| tree | unrestricted U-forward for the chronicle | `cantor_bfmcs_dense_restricted_fuc` | `… (root : Formula) : (cantorBfmcsDense fc A h_mcs h_box_dense).RestrictedForwardUntilSinceCoherent root` (proof ignores the closure hypothesis) | EXISTS (`ChronicleToCountermodelBasic.lean:755`) |
| tree | unrestricted U-backward for the chronicle | `cantor_bfmcs_dense_restricted_buc` | ditto, `RestrictedBackwardUntilSinceCoherent root` | EXISTS (`:680`) |
| tree | self-root discharge | `self_mem_subformulaClosure` | `(phi : Formula) : phi ∈ subformulaClosure phi` | EXISTS (`Syntax/SubformulaClosure/Closure.lean:42`) |
| tree | conjunction introduction in an MCS | `conj_mcs` | `(fc) (h_mcs : SetMaximalConsistent (fc := fc) A) (φ ψ) (h_φ : φ ∈ A) (h_ψ : ψ ∈ A) : Formula.and φ ψ ∈ A` | EXISTS (`Chronicle/PointInsertion.lean:227`) |
| tree | axiom instance into an MCS | `theorem_in_mcs` + `DerivationTree.axiom` | `axiom (Γ) (φ) (h : Axiom φ) (h_fc : h.minFrameClass ≤ fc) : DerivationTree fc Γ φ` | EXISTS (`Core/MaximalConsistent.lean:491`, `ProofSystem/Derivation.lean:98`) |

### The obstruction, restated exactly

Write `S_φ := {q : Rat | φ ∈ fam.mcs q}` and `χ := Formula.someFuture φ = untl φ ⊤`.

Because the chronicle satisfies forward-F coherence (`Fφ ∈ m q → ∃ s > q, φ ∈ m s`) and its
converse is free from `forward_G` plus negation-completeness, we get, for every rational `q`:

> `χ ∈ m q ⟺ ∃ s : Rat, q < s ∧ φ ∈ m s`.

Hence `{q | χ ∈ m q}` is exactly `(-∞, sup S_φ) ∩ ℚ`. Therefore:

- If `r < sup S_φ`, a witness above `r` exists by definition of `sup`. No obligation.
- If `r > sup S_φ`, then `(sup S_φ, r)` is a `limitFilterBelow r` generator disjoint from
  `{q | χ ∈ m q}`, so `χ ∉ limitMCSBelow fam.mcs r`. Hypothesis vacuous.
- **The only failure point is `r = sup S_φ` exactly**, with `S_φ` accumulating at `r` from below
  and no member at or above `r`.

So:

> **`LimitFutureWitness` (restricted to unselected `r`) holds iff, for every `φ` in the deferral
> closure and every family, `sup S_φ` is rational or `±∞`** — i.e. iff the chronicle has no
> definable gap for `Fφ`.

At *selected* `r` the predicate is refutable: `r = (p : ℝ)` with `p = max S_φ` satisfies the
hypothesis (`χ ∈ m q` for all `q < p`) and refutes the conclusion. This is finding (1).

### The discharge

Reynolds 1992, printed p.176, Theorem 3's proof is exactly this argument in semantic form:
> "Suppose for contradiction that `M ⊨ U'(A,B)(t)` in some Prior structure `M`. Thus `B` holds
> for a while up until a gap after which `¬B` is true arbitrarily soon. By Prior-U applied to `B`
> we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction."

Instantiate `B := χ = Fφ`. The reason this works where plan v2's Phase 4 attempt failed is that
Phase 4 applied Prior-U **to `φ` itself**, whose region need not be an interval; `χ`'s region
*is* an interval `(-∞, r)`, so Prior-U's antecedent `U(⊤, χ)` is satisfied for free. Phase 4's
OUTCOME block records the refutation of the `φ`-level attempt correctly; it does not refute the
`Fφ`-level attempt, which was never tried.

Full proof (all four steps verified against actual signatures in the tree):

Let `fc` satisfy `FrameClass.Dedekind ≤ fc`, let `m : Rat → Set Formula` be a family of
`fc`-MCSs with unrestricted forward (`hUf`) and backward (`hUb`) Until coherence, let `r : ℝ`
with `¬ ∃ q : Rat, (q:ℝ) = r`, and assume `χ ∈ limitMCSBelow m r`. Suppose for contradiction

> (†) `∀ s : Rat, r < (s:ℝ) → φ ∉ m s`.

- **Step A — `χ ∈ m q` for every rational `q` with `(q:ℝ) < r`.**
  `limitMCSBelow_cofinal_below` at `z := (q:ℝ)` yields `q' : Rat` with `q < q' < r` and
  `χ ∈ m q'`. `hUf` at `q'` (with `α := φ`, `β := ⊤`) gives `s > q'` with `φ ∈ m s`; by (†) and
  irrationality of `r`, `(s:ℝ) < r`. Then `hUb` at `q` with witness `s` (guard trivial, `β = ⊤`)
  gives `χ = untl φ ⊤ ∈ m q`.

- **Step B — `χ.neg ∈ m u` for every rational `u` with `r < (u:ℝ)`.**
  If `χ ∈ m u`, `hUf` gives `s > u > r` with `φ ∈ m s`, contradicting (†). Negation-completeness.

- **Step C — the Prior-U antecedent holds at any rational `t` with `(t:ℝ) < r`.**
  - `untl ⊤ χ ∈ m t`: `hUb` at `t` with witness any rational `s ∈ (t, r)` (`exists_rat_btwn`);
    guard is `∀ p ∈ (t,s), χ ∈ m p`, true by Step A since `p < s < r`; `⊤ ∈ m s` by
    `theorem_in_mcs`.
  - `χ.neg.someFuture = untl χ.neg ⊤ ∈ m t`: `hUb` at `t` with witness any rational `u₀ > r`
    (`exists_rat_gt`); `χ.neg ∈ m u₀` by Step B; guard trivial.
  - `conj_mcs` combines them into the axiom's antecedent, and
    `theorem_in_mcs (hm t) (DerivationTree.axiom [] _ (Axiom.prior_U_gap χ) hfc)` plus
    `SetMaximalConsistent.implication_property` yields
    `untl (Formula.or χ.neg (Formula.kPlus χ.neg)) χ ∈ m t`.

- **Step D — contradiction.**
  `hUf` at `t` on that formula gives `u > t` with `Formula.or χ.neg (kPlus χ.neg) ∈ m u` and
  `χ ∈ m p` for all rationals `p ∈ (t,u)`.
  - `(u:ℝ) < r`: if `(u:ℝ) > r`, pick a rational `p ∈ (r, u)`; then `p ∈ (t,u)` so `χ ∈ m p`,
    contradicting Step B. `(u:ℝ) = r` is excluded by irrationality.
  - By Step A, `χ ∈ m u`, so `χ.neg ∉ m u`, so `χ.neg.neg ∈ m u`. Since
    `Formula.or a b = a.neg.imp b` (`Syntax/Formula.lean:438`), `implication_property` gives
    `kPlus χ.neg ∈ m u`, i.e. `(untl ⊤ χ.neg.neg).neg ∈ m u`, i.e.
    `untl ⊤ χ.neg.neg ∉ m u`.
  - But `hUb` at `u` with witness any rational `s ∈ (u, r)` gives `untl ⊤ χ.neg.neg ∈ m u`:
    the guard is `∀ p ∈ (u,s), χ.neg.neg ∈ m p`, true by Step A (`p < s < r`) plus MCS
    double-negation. Contradiction. ∎

Irrationality of `r` is used exactly twice (Step A and Step D's first bullet), and this is
precisely why finding (1) is forced rather than cosmetic.

### Exact statements to prove

**Statement 1 — predicate repair** (`Bundle/RealExtensionBundle.lean`, replaces `:271`):

```lean
def BFMCS.LimitFutureWitness {fc : FrameClass} (B : BFMCS (fc := fc) Rat) (root : Formula) :
    Prop :=
  ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ φ : Formula,
    φ ∈ deferralClosure root →
    Formula.someFuture φ ∈ limitMCSBelow fam.mcs r → ∃ s : Rat, r < (s : ℝ) ∧ φ ∈ fam.mcs s
```

The only consumer is `BFMCS.toRealBundle_restricted_temporally_coherent`
(`RealExtensionBundle.lean:306`), whose call already sits inside the `hx : ¬ ∃ p : Rat, …`
branch; the call becomes `h_lfw fam hfam (t + δ) hx φ hdc hFφ'` with `hx` reshaped by
`Rat.cast` congruence. The docstring's counterexample stays valid and should be *retained* with
an added paragraph noting that it is refuted at `fc = FrameClass.Dedekind` and why.

**Statement 2 — the gap lemma** (new module; see "Module placement" below):

```lean
theorem limitFutureWitness_of_priorU {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
    (hUf : ∀ (t : Rat) (α β : Formula), Formula.untl α β ∈ m t →
      ∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p)
    (hUb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p) →
      Formula.untl α β ∈ m t)
    (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (φ : Formula)
    (hF : Formula.someFuture φ ∈ limitMCSBelow m r) :
    ∃ s : Rat, r < (s : ℝ) ∧ φ ∈ m s
```

**Statement 3 — chronicle instantiation** (Phase 7's new module or a new Phase 6.2):

```lean
theorem cantor_bfmcs_dense_limit_future_witness (fc : FrameClass)
    (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) (root : Formula) :
    (Chronicle.cantorBfmcsDense fc A h_mcs h_box_dense).LimitFutureWitness root
```

Proof: `intro fam hfam r hr φ _ hF`; build

```lean
hUf := fun t α β h =>
  (Chronicle.cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
      (Formula.untl α β) fam hfam).1 t α β (self_mem_subformulaClosure _) h
hUb := fun t α β h =>
  (Chronicle.cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
      (Formula.untl α β) fam hfam).1 t α β (self_mem_subformulaClosure _) h
```

then `exact limitFutureWitness_of_priorU hfc fam.mcs fam.is_mcs hUf hUb r hr φ hF`. **No new
chronicle-level work is required and no existing chronicle declaration is modified.**

**Module placement.** `conj_mcs` lives in `BXCanonical/Chronicle/PointInsertion.lean`, which is
*above* `Bundle/` in the import graph, while `limitMCSBelow_cofinal_below` lives in
`Bundle/LimitMCS.lean`. Two clean options: (a) put Statement 2 in a new
`Bundle/LimitGapWitness.lean` and re-derive `and`-introduction locally (three lines, `fc`-generic
— the same pattern `negBoxIntrospection` used in Phase 6.1); or (b) put Statement 2 in
`BXCanonical/Chronicle/ChronicleRealExtension.lean` alongside Statement 3, where `conj_mcs` is
already in scope. (b) is cheaper; (a) keeps the lemma reusable for the Since/past mirror. Prefer
(b) unless the `prior_S_gap` mirror is wanted immediately.

---

## Rejected alternatives

### Direction 1 — "the Cantor enrichment already places the witnesses" — REJECTED as stated, but its conclusion survives in amended form

The chronicle's construction invariants do **not** exclude the counterexample family. Its
witness-placement machinery (`limit_F_resolution`, `limit_satisfies_c4`,
`limit_satisfies_c5_strong`) delivers exactly forward/backward Until coherence — and the
counterexample family satisfies both in full; that is what the BLOCKER block's isolation note
already established. The "enrichment" in `countermodel_dense_enriched` /
`extendedDeferralClosure` is about density (`nextTop`) and deferral bookkeeping, not about the
supremum-rationality of `S_φ`. So the back-and-forth is not what saves the day. What saves the
day is the **frame class**: at `fc = FrameClass.Dedekind` every `m q` contains all
`Axiom.prior_U_gap` instances. The predicate *is* dischargeable for the concrete object (that
part of Direction 1's conclusion is right), just not for the reason Direction 1 proposed, and not
`fc`-generically.

### Direction 2 — two-sided / symmetric limit — REJECTED, and the literature says why

Burgess 1984, printed p.109, defines exactly the two-sided seed at a gap `(Y,Z)`:
`C(Y,Z) = {Pa : ∃y ∈ Y, a ∈ T(y)} ∪ {Fa : ∃z ∈ Z, a ∈ T(z)}`. **It does not solve this step.**
Burgess's very next paragraph (printed p.109–110) has to *prove* "if `Fa ∈ T*(w(Y,Z))` then
`Fa ∈ T(z)` for some `z ∈ Z`" — the literal content of `LimitFutureWitness` — and the proof
routes through his continuity axiom `A7a` via the preceding Lemma. So the two-sided seed makes
the limit MCS *coherent* but still needs the gap axiom for *prophecy*. Adopting it here would
therefore not remove the obligation, while costing:

- `limitMCSBelow_cofinal_below` (`LimitMCS.lean:379`) has no two-sided analogue that is
  simultaneously usable in both temporal directions; all four `limitMCSBelow`-source coherence
  variants added in Phase 6 route through it;
- `box_mem_realLimitMCS_iff` (`RealExtensionBundle.lean`) and both modal fields consume the same
  descent handle;
- the `somePast` half of `toRealBundle_restricted_temporally_coherent`, currently
  **unconditional**, would acquire a mirror obligation (`prior_S_gap`) that it does not have now.

Net: strictly more obligations for no gain. A per-point choice of side is worse still — the
extension's `forward_G`/`backward_H` fields quantify over *all* pairs of real points, so a
side-choice that varies with the point breaks the 2×2 case matrix that Phases 5–6 closed.

### Direction 3 — witness-aware selection at the unselected branch — REJECTED

Refining the unselected branch by an F-obligation-aware filter means abandoning the ultrafilter
limit. Plan v2's Phase 4 OUTCOME already recorded the consequence: `limitMCSLindenbaum` (the
arbitrary-extension variant, `LimitMCS.lean:291`) has **no descent path back to `m q`**, which is
exactly why `limitMCSBelow` was built. Every downstream asset that Phases 5, 6 and 6.1 landed —
the four `limitMCSBelow`-source coherence variants, `realLimitMCS_is_mcs`,
`box_mem_realLimitMCS_iff`, both modal fields, and the unconditional `somePast` half — consumes
`limitMCSBelow_cofinal_below`. Direction 3 discards all of them and re-opens Phases 4–6.1. It is
also unnecessary: the object we already have satisfies the property once the frame class is used.

### Direction 4 — restricted-closure finiteness — REJECTED as a fix; its *inverse* is the enabler

The obligation is already restricted to `deferralClosure root`, a `Finset`, and that does not
weaken it enough: the BLOCKER's counterexample uses a single **atom** `φ`, which lies in
`deferralClosure root` whenever it occurs in `root`. A finite conjunction of individually-false
obligations is still false. More importantly, the premise behind Direction 4 — that the
chronicle's coherence is genuinely closure-bounded — is **false for this chronicle**:
`cantor_bfmcs_dense_restricted_tc/_buc/_fuc` all bind their closure argument to `_` and never use
it. That is the opposite of a limitation, and it is what makes the winning route affordable: the
auxiliary Prior-U formulas need no closure enlargement, no enriched root, and no change to
`extendedDeferralClosure`. Direction 4's investigation was worth doing and its payoff is this
fact, not the reduction it hoped for.

---

## Cost to Phases 7–8

### Phase 6.1 (currently `[BLOCKED]`) — clears

| Item | Cost |
|---|---|
| Statement 1 (predicate + docstring amendment) | ~15 lines, 1 call-site line |
| Statement 2 (gap lemma) | ~140–180 lines |
| Statement 3 (chronicle instantiation) | ~25 lines |
| **Total** | one agent run; suggest a **new Phase 6.2** rather than reopening 6.1 |

Phase 6.1's already-landed five tasks are untouched. Nothing in `LimitMCS.lean`,
`LimitMCSCoherence.lean` or `RealExtension.lean` changes.

### Phase 8 — one signature change

`countermodel_dedekind_dense` is specified in the plan as `{fc : FrameClass}`-generic. It must
acquire `(hfc : FrameClass.Dedekind ≤ fc)` (or be pinned at `fc := FrameClass.Dedekind`), because
Statement 3 is `fc`-conditional. This is benign: `completeness_dedekind_engine` instantiates at
`FrameClass.Dedekind` anyway, and `Dedekind ≤ Dedekind` is `by decide` (`Axioms.lean:491`).
`consequence_completeness_dedekind_of_engine`'s pinned signature (commit `bd9ae0ac1`) is
unaffected — it is stated at `.Dedekind`. The Phase 8 note that the three Phase 7 chronicle
instances are "polymorphic in `root`" stays true; they additionally become conditional on `hfc`.

### Phase 7 — a strictly harder instance, NOT cleared by this report

Plan v2's Phase 7 Forward-case-B (`plans/02:1148–1156`) is the same species of obstruction —
`untl φ ψ ∈ limitMCSBelow m (t+δ)` needs a witness strictly above `t` — and the plan proposes to
re-invoke `limitMCS_no_oscillation`, which **Phase 4's OUTCOME already refuted**. That
instruction is dead and must be rewritten regardless of what replaces it.

The Prior-U technique does **not** transfer verbatim, and the reason is precise: Step A of the
proof above works because the truth region of `someFuture φ` below a gap is an **interval**
`(-∞, r)`. The truth region of `untl α β` need not be. Concretely, a family in which `β` fails at
rationals `t_n ↗ r`, `α` holds at one point `α_n ∈ (t_n, t_{n+1})`, and `α` fails everywhere
above `r`, has `untl α β` true on `⋃(t_n, α_n)` and false on `⋃(α_n, t_{n+1})` — cofinal below
`r` in both directions. Prior-U applied to `untl α β` at `t_n` is then satisfied *locally* (its
witness `u` can land in `[α_n, t_{n+1}]` where `¬(untl α β)` genuinely holds), so no
contradiction arises. Whether such a family survives inside `cantorBfmcsDense` at
`fc = FrameClass.Dedekind`, and whether the below-limit ultrafilter can put
`{q | untl α β ∈ m q}` in, are open. Partial structure that *is* established:

- **Case (a)** — some rational Until-witness lands strictly above `r + δ`: closes cleanly with
  the plan's own guard lemma, since the rational guard on `(q, s')` covers `(r, s')` and every
  unselected real in between inherits `β` from a `limitFilterBelow` generator. No new work.
- **Case (b)** — all rational witnesses squeeze to `r`: Statement 2 applied to `α` does produce a
  rational `α`-point above `r` (so the *eventuality* half is fine), but supplies **no guard** on
  the interval between `r` and that point. This is the residual gap.

Reynolds is explicit that "no definable gaps" is not by itself enough for the reals construction:
§6, printed p.176 — "We know that the Prior axioms ensure that there will not be any definable
gaps in a model. To show that our model can be made into a model over the reals we actually need
a stronger result." His stronger result (Lemma 2/Lemma 3, printed p.177–178) is about
contemporaneous equivalence classes, and his overall route reaches ℝ via Doets' theorem and the
`Axiom.sep` separability axiom rather than by a Dedekind completion of a rational chronicle. This
tree's route is the completion route, which is Burgess's — and **Burgess only ever runs it in the
`F`/`G` fragment** (printed p.109–110); his §2.7 says nothing about `U`/`S` at a gap. So Phase 7
is doing something neither primary source does directly.

**Recommendation for Phase 7**: do not dispatch it against the current task list. Insert a
dedicated probe phase whose deliverable is either (i) a proof of a `limitUntilWitness_of_priorU`
analogue with an explicit guard, or (ii) a refutation exhibiting an admissible
`cantorBfmcsDense`-realizable family, in which case the route needs `Axiom.sep` and the
contemporaneous-equivalence machinery and the completion shape must be revisited. Phase 7's
*backward* Until/Since transport and its guard lemma are unaffected and can land first.

---

## Adversarial Self-Verification

Every load-bearing claim below was re-checked against the actual file contents or the actual PDF
page after the draft was written; three claims were modified as a result (listed after the
table).

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `LimitFutureWitness` is false at selected (rational) `r` whenever `S_φ` has a maximum | Counterexample: `r = (p:ℝ)`, `φ ∈ m p`, `φ ∉ m u` for `u > p`; hypothesis holds via `forward_G` contrapositive, conclusion needs `s > p` | Read of `Bundle/RealExtensionBundle.lean:271-274`; the predicate quantifies `∀ (r : ℝ)` with no unselectedness guard | High |
| The consumer only calls the predicate at unselected points and has `hx` in scope | `RealExtensionBundle.lean:305-306`: the call `h_lfw fam hfam (t + δ) φ hdc hFφ'` is inside the `· rw [realLimitMCS_of_not_rat …]` branch of `by_cases hx` | Read of the proof script, lines 293–310 | High |
| `Axiom.prior_U_gap` exists with the antecedent `U(⊤,φ) ∧ F(¬φ)` and consequent `U(¬φ ∨ K⁺¬φ, φ)` | Reynolds 1992 printed p.168 (system US/R) | Read of `ProofSystem/Axioms.lean:377-379`; `Formula.kPlus` at `Syntax/Formula.lean:180`; `Formula.or` at `:438`; `someFuture` at `:131` | High |
| `Axiom.minFrameClass (prior_U_gap _) = .Dedekind`, and `Dense ≤ Dedekind` | — | Read of `Axioms.lean:524`, `:460-461`, `:490` (`example : FrameClass.Dense ≤ FrameClass.Dedekind := by decide`) | High |
| `cantorBfmcsDense` is `fc`-generic, so it can be instantiated at `FrameClass.Dedekind` | — | Read of `ChronicleToCountermodelBasic.lean:552` (`cantorBfmcsDense (fc : FrameClass) …`) | High |
| The chronicle's three restricted-coherence theorems discard their closure hypothesis, hence hold for **all** formulas | — | Read of `ChronicleToCountermodelBasic.lean:642` (`intro t φ _ h_F`), `:691` (`intro t φ ψ _ ⟨u, …⟩`), `:766` (`intro t φ ψ _ h_until`); and of the underlying `limit_F_resolution` (`ChronicleConstruction.lean:722-727`), `limit_satisfies_c4` (`:776-782`), `limit_satisfies_c5_strong` (`:1482-1488`), all of which take `φ`/`ξ`/`η` as unconstrained `Formula` arguments | High |
| The self-root trick supplies unrestricted `hUf`/`hUb` with no new chronicle work | — | `self_mem_subformulaClosure` signature confirmed at `Syntax/SubformulaClosure/Closure.lean:42`; the restricted predicates take the membership as a hypothesis (`TemporalCoherence.lean:558-568`), so instantiating `root := untl α β` discharges it | High |
| `limitMCSBelow_cofinal_below` takes the threshold `z` as a caller-chosen parameter | — | Read of `Bundle/LimitMCS.lean:379-385` | High |
| Reynolds' Prior-U argument has exactly the shape used in Steps C–D | Reynolds 1992, printed p.176: "By Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction"; and printed p.178 Lemma 3: "Prior-U applied to `R` implies that `M` contains a last point of this stretch of `R` … or a first point of `¬R`" | Direct PDF text extraction of `Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`, PDF pages 11 and 13 = printed pp. 176 and 178 (page mapping verified: PDF index `i` ↔ printed `165+i`, cross-checked against the literal "176"/"178" running heads) | High |
| `LimitFutureWitness` is literally Burgess's prophecy claim at a gap, and the two-sided seed does not avoid needing the continuity axiom | Burgess 1984, printed p.109–110: "Now if `Fa ∈ T*(w(Y,Z))`, we claim that `Fa ∈ T(z)` for some `z ∈ Z`. For if not, then `G¬a ∈ T(z)` for all `z ∈ Z`, and by the previous Lemma, `G¬a ∈ T(y)` for some `y ∈ Y`" — where "the previous Lemma" is proved from `A7a` | Direct read of `burgess_1984/sec05_basic-tense-logic-continuity.md` lines 55–120, whose page marker "## Page 32 / 110 JOHN P. BURGESS" fixes printed p.109–110 | High |
| `conj_mcs` and `theorem_in_mcs`/`DerivationTree.axiom` provide the MCS plumbing for Step C | — | `Chronicle/PointInsertion.lean:227-230`; `Core/MaximalConsistent.lean:491`; `ProofSystem/Derivation.lean:98` (the `h_fc : h.minFrameClass ≤ fc` field is what `hfc` discharges) | High |
| `conj_mcs` is above `Bundle/` in the import graph, forcing the module-placement choice | — | File path `BXCanonical/Chronicle/PointInsertion.lean` vs `Bundle/LimitMCS.lean`; `Bundle/` is imported by `BXCanonical/` (Phase 6.1 landed `negBoxIntrospection` locally in `Bundle/` for exactly this reason, per the PHASE 6.1 OUTCOME block) | Medium — import direction inferred from the Phase 6.1 OUTCOME note rather than from a `lake` dependency dump; if wrong, option (a) simply becomes unnecessary |
| Phase 7 Forward-case-B is not solved by this argument | Candidate family: `¬β` at `t_n ↗ r`, single `α`-point `α_n ∈ (t_n, t_{n+1})`, `¬α` above `r`. `untl α β` is then true on `⋃(t_n, α_n)` and false on `⋃(α_n, t_{n+1})`, so its truth region below `r` is not an interval and Prior-U at `t_n` is satisfied by a witness `u ∈ [α_n, t_{n+1}]` | Hand-checked against the `untl` semantics fixed by `RestrictedForwardUntilSinceCoherent` (`TemporalCoherence.lean:558-568`) | Medium — the family is not shown to be *realizable* inside `cantorBfmcsDense`, so this establishes "the argument does not transfer", not "Phase 7 is impossible" |
| Reynolds' route to ℝ is not a completion of a rational chronicle | Reynolds 1992, printed p.176 (§6 opening): "We know that the Prior axioms ensure that there will not be any definable gaps in a model. To show that our model can be made into a model over the reals we actually need a stronger result." | Direct PDF read, PDF page 11 | High |
| Plan v2's Phase 4 refutation of Prior-U does not refute the `Fφ`-level use | Phase 4 OUTCOME (`plans/02:704-721`) refutes deriving negation-completeness of `limitSetBelow` from "no definable gaps", and notes Prior-U's antecedent "already requires `A` to be constantly true on an interval abutting the gap" — which is a statement about applying it to `A := φ`. Step A above establishes that hypothesis for `A := Fφ` | Read of the plan's Phase 4 OUTCOME block against the proof sketch | High |

**Recommendations modified after verification:**

1. *Initially drafted*: "state Statement 2 in `Bundle/LimitGapWitness.lean`". *Changed to*: offer
   (a)/(b) with (b) preferred, after finding that `conj_mcs` sits above `Bundle/`. The confidence
   on the import direction is Medium, so the report deliberately gives both options rather than
   pinning one.
2. *Initially drafted*: "the same Prior-U technique fixes Phase 7 case B." *Retracted* after
   constructing the interval-failure family; Phase 7 is now reported as **not cleared**, with a
   probe recommended. This is the single most important correction in this pass — the draft would
   have handed Phase 7 a technique that provably does not apply to it.
3. *Initially drafted*: Direction 2 rejected on cost grounds only. *Strengthened* after reading
   Burgess printed p.109–110: the two-sided seed is what Burgess actually uses and it **still**
   needs the continuity axiom for this exact step, which is a much better reason than cost.

**Contradiction Log.** One contradiction was found and resolved.

- *A*: plan v2's Phase 4 OUTCOME — "`limitMCS_no_oscillation` as stated in the task list is
  false"; Prior-U "cannot yield" the property, "the refutation is at the level of the cited
  source, so no further attempt is warranted."
- *B*: this report — Prior-U *does* yield the property needed at Phase 6.1.
- *Resolution* (precedence: primary source > tree source > plan prose): both are correct about
  different statements. Phase 4's target was negation-completeness of `limitSetBelow m r`, i.e.
  eventual constancy of *every* formula below `r`, applied to `φ` directly; that is genuinely
  unobtainable from Prior-U and Phase 4's refutation stands unamended. This report's target is
  the supremum-rationality of `S_φ`, obtained by applying Prior-U to `Fφ`, whose interval
  structure supplies the antecedent Phase 4 correctly said was missing for `φ`. The plan's blanket
  "no further attempt is warranted" should be narrowed in place to "no further attempt at the
  `φ`-level is warranted."

No unresolved contradictions.

---

## Recommended plan edits (for `/revise`)

1. **New Phase 6.2** — "The definable-gap discharge of `LimitFutureWitness`": Statements 1, 2, 3.
   Depends on 6.1. `[NOT STARTED]`.
2. **Phase 6.1** — retire the BLOCKER block into a Revision Rationale entry; the phase's own
   deliverables are complete and the residual hypothesis moves to 6.2.
3. **Phase 7** — delete the `limitMCS_no_oscillation` instruction from Forward-case-B (Phase 4
   refuted it). Split Phase 7 into 7a (backward direction + guard lemma + forward case A, all
   mechanical) and **7b, a probe** for forward case B with an explicit two-outcome deliverable
   (proof, or refuting family). Do not budget 7b as proof engineering.
4. **Phase 8** — add `(hfc : FrameClass.Dedekind ≤ fc)` to `countermodel_dedekind_dense` and
   thread it through the three chronicle coherence instances.
5. **Testing & Validation** — add: no declaration asserts `LimitFutureWitness` at a selected real;
   `#print axioms` on the new declarations is `[propext, Classical.choice, Quot.sound]`.
