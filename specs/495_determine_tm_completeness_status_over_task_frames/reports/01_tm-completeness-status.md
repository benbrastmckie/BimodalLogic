# Research Report: TM completeness status over task frames

**Task**: 495 — Determine TM completeness status over task frames
**Task Type**: formal
**Domains**: logic (modal/tense logic, Kripke semantics, proof theory), math (ordered abelian groups)
**Session**: sess_1788265374_c18aa8_495
**Dispatch**: 2

---

## Executive Summary

1. **TM is NOT complete over task frames.** The verdict is negative, and the reason is
   structural rather than incidental: TM's completeness over task frames is *logically
   equivalent* to the forward conservativity direction that
   `FormalSystem/Metalogic/Conservativity.lean` records as refuted. That equivalence is a
   two-line consequence of theorems already in this tree (`BXCanonical.completeness`,
   `Metalogic.soundness`, `bl_soundness_valid`, `Semantics.blValid_iff_valid_tr`) and is
   itself machine-checkable **today**, with no new semantics and no `sorry`.

2. **The task brief's "subtlety" applies to the Base row only, not to the Discrete row.** At
   `FrameClass.Discrete` the refuting structure *is* a task frame — the non-Archimedean
   discrete carrier `ℚ ×ₗ ℤ` (or `ℤ ×ₗ ℤ`), which is a perfectly legitimate
   `TemporalOrder` because a lexicographic product of ordered abelian groups is an ordered
   abelian group. The CEF refutation therefore never leaves `TaskFrame`.

3. **CEF is machine-checkable now**; the one missing piece is *not* a countermodel but a
   **binder-weakened BL soundness theorem**. `bl_soundness_discrete` carries
   `[IsSuccArchimedean]`/`[IsPredArchimedean]`, which the countermodel carrier deliberately
   fails. A sibling at `[SuccOrder] [PredOrder]` only is needed, and its axiom obligations
   reduce to **exactly one new semantic proof** (DF, plus its `swapBL` dual); every other
   axiom and every rule is discharged by re-using `bl_soundness_valid`.

4. **CEB is NOT machine-checkable now**, and `Conservativity.lean`'s current statement that
   "the missing prerequisite is now the countermodels alone" is **too optimistic for the Base
   row**. `BLTruthAt` and `bl_soundness` are both `TaskFrame`-bound, and — as the brief
   correctly says — *no task frame can refute (Sp)*. The genuinely missing prerequisite is a
   whole semantic layer: a frame notion outside `TaskFrame` plus a **native** (non-composed)
   BL soundness theorem over it. Recommended docstring correction in §7.

5. **New: the TM⁺ half of the CEB witness becomes machine-checkable now, via completeness
   rather than via the source's syntactic derivation.** `(Sp) := □(DF φ) ∨ □(DN ψ)` is
   BL-valid on every task frame for a purely order-theoretic reason (§4.1), so
   `blValid_iff_valid_tr` + `BXCanonical.completeness` deliver `⊢[Base] tr (Sp)` without ever
   invoking TMP-NB or M5. This puts CEB's TM⁺ half on the same footing `z1_translate` already
   gives CEF's.

6. **What TM *is* sound and complete for**: TM is sound over a class strictly larger than the
   task frames — the natural candidate is the bimodal Kripke class (S5 for `□`, Kt4.3 +
   two-sided seriality for `H`/`G`, with MF's frame condition `R_□ ∘ R_< ⊆ R_□`), over which
   TM is complete by standard Sahlqvist canonicity. Whether that Kripke class corresponds to
   any natural class of *task* structures is open. Row by row, the paper itself states (in a
   commented line at `possible_worlds.tex:4614`) that **TM_f is sound over the full discrete
   class** and that its completeness there **remains open**.

---

## 1. Domain analysis

Primarily **logic** (bimodal tense logic, conservativity of a definitional extension,
Kripke-frame completeness). One **math** dependency is load-bearing and is what makes the whole
question sharp: `Semantics/TemporalOrder.lean` requires `F.Duration` to be a *nontrivial totally
ordered abelian group*, not an arbitrary linear order. Ordered abelian groups are
**order-homogeneous** (translation is an order-automorphism), and that single fact is the pivot
of §4.

---

## 2. Ground truth established from the tree and the live paper

### 2.1 The paper

`cor:tm-completeness` (`possible_worlds.tex:4657 ff.`, live text, read directly) carries
completeness for **BL⁺ systems only**:

| System | Claim |
|---|---|
| TM⁺ | strongly complete over all task frames |
| TM⁺_d | strongly complete over the dense task frames |
| TM⁺_f | **weakly complete over ℤ-time** |
| TM⁺_c | weakly complete over the dense-and-complete class |

TM, TM_f, TM_d, TM_c appear nowhere in it. Confirmed: the evidence item (1) in the task brief
is accurate.

Two further live-paper facts materially change the analysis:

- `def:TMplus-f` (line 4612): "**TMP-Z1** is a backward induction principle that is
  characteristic of **successor-Archimedean** task frames. It follows by Hölder's theorem that a
  nontrivial discrete Archimedean totally ordered abelian group is isomorphic to ℤ, and so the
  successor-Archimedean discrete class to which BX_f and TM⁺_f are sound and complete is exactly
  ℤ-time."

- Line 4614, **commented out** in the source but the author's own statement of the target
  claim: "TM_f, by contrast, **is sound over the full class of discrete frames**, since DF is
  valid on every discrete order and not only on ℤ-time; **whether TM_f is complete over that
  broader class remains open**, as discussed at cor:tm-completeness."

That commented line is, verbatim, the answer to scope item (b) for the Discrete row. Cite it as
the author's own position, but note it is commented and therefore not currently live text.

### 2.2 The tree

| Fact | Location | Status |
|---|---|---|
| `TemporalOrder` = nontrivial totally ordered abelian group | `Semantics/TemporalOrder.lean:76-92` | structure fields |
| `TaskFrame` = `Σ (D : TemporalOrder), FrameOver D` — one shared `Duration` per frame | `Semantics/TaskFrame.lean` | definition |
| `BLTruthAt` native six-clause recursion on `BLFormula`, over a `TaskFrame` | `Semantics/BLTruth.lean` | sorry-free |
| `BLValid φ := ∀ (F : TaskFrame) M τ (τ.IsTotal) t, BLTruthAt …` | `Semantics/BLValidity.lean:77` | definition |
| `blValid_iff_valid_tr : BLValid φ ↔ valid (tr φ)` | `Metalogic/BaseLanguageSoundness.lean` | sorry-free |
| `bl_soundness_valid : ⊢ᴮᴸ[Base] φ → BLValid φ` | `Metalogic/BaseLanguageSoundness.lean` | sorry-free |
| `soundness : ⊢[Base] ψ → …` and `completeness : valid ψ → ⊢[Base] ψ` | `Metalogic/Soundness.lean`, `Metalogic/BXCanonical/Completeness.lean:196` | both sorry-free |
| `completeness_discrete : ValidDiscrete ψ → ⊢[Discrete] ψ` | `BXCanonical/Completeness.lean:296` | sorry-free |
| `ValidDiscrete` / `BLValidDiscrete` bind `[SuccOrder] [PredOrder] [IsSuccArchimedean] [IsPredArchimedean]` | `Semantics/Validity.lean:239`, `Semantics/BLValidity.lean:111` | definitions |
| `z1_translate : ⊢[Discrete] tr (Z1 φ)` | `Metalogic/Conservativity.lean` | sorry-free |
| At `.Discrete` the admissible BL axioms are exactly Base ∪ {`df`} (`Dense ≰ Discrete`) | `ProofSystem/Axioms.lean:538-578`, `BaseLanguage/Axioms.lean` | `decide`-checked in tree |
| `multiFamTaskFrameGen D FamIdx` — shift frame, `WorldState = FamIdx × ↑D`, all four frame axioms discharged generically in `D` | `Metalogic/Algebraic/FlowFrame.lean:152` | sorry-free |
| `multiFamHistoryGen f w₀` total, `states t = (f, w₀ + t)` | `Metalogic/Algebraic/FlowFrame.lean:192, 219` | sorry-free |
| `ℚ ×ₗ ℤ` discharges all four `TemporalOrder` binders; discrete via `(q,n) ↦ (q,n+1)`; non-Archimedean | `BXCanonical/DiscreteCarrierProbe.lean:24-28, 65-68` | `example`s in tree |

---

## 3. The reduction: TM's completeness over task frames **is** forward conservativity

This is the cleanest finding of the investigation and it costs nothing new.

Define, both as plain `Prop`s (neither asserted):

```
TMCompleteBase := ∀ φ : BLFormula, BLValid φ → BaseLanguage.Derivable .Base [] φ
ForwardBase    := ∀ φ : BLFormula, ProofSystem.Derivable .Base [] (tr φ)
                                    → BaseLanguage.Derivable .Base [] φ
```

**Theorem (machine-checkable today).** `TMCompleteBase ↔ ForwardBase`.

- `→`: from `⊢[Base] tr φ`, `Metalogic.soundness` gives `valid (tr φ)`;
  `blValid_iff_valid_tr` gives `BLValid φ`; apply `TMCompleteBase`.
- `←`: from `BLValid φ`, `blValid_iff_valid_tr` gives `valid (tr φ)`;
  `BXCanonical.completeness` gives `⊢[Base] tr φ`; apply `ForwardBase`.

The `←` direction is where TM⁺'s *completeness* over all task frames does the work — that is
exactly `cor:tm-completeness` row 1, machine-checked in-tree.

The same reduction runs at `.Discrete` against `completeness_discrete` / `soundness_discrete`
and `BLValidDiscrete`, once the trivial mirror lemma
`blValidDiscrete_iff_validDiscrete_tr` is added (a five-line copy of `blValid_iff_valid_tr`
with the extra instance binders threaded).

**Consequence.** Since `Conservativity.lean` records `ForwardBase` as refuted, TM is **not**
complete over task frames. The reduction also means the two questions must never be answered
differently: any future claim of TM completeness over task frames is, by this theorem, a claim
of forward conservativity, and falls under the same hard constraint.

**Compliance with the hard constraint.** The reduction states an *equivalence between two
propositions*, asserts neither, and needs no `sorry`. It is the strongest statement about
forward conservativity that can be landed without violating `Conservativity.lean`'s
prohibition.

---

## 4. Scope (a): settling the Base row — the (Sp) witness

### 4.1 Why (Sp) is valid on every task frame — a purely order-theoretic reason

Write, in BL:

```
DF φ := ((Hφ ∧ φ) ∧ F⊤) → F(Hφ)          -- BaseLanguage.Axiom.df's formula
DN ψ := GGψ → Gψ                          -- BaseLanguage.Axiom.dn's formula
Sp    := □(DF φ) ∨ □(DN ψ)
```

**Lemma A (elementary; no Mathlib lemma found, ~15 lines).** Every nontrivial totally ordered
abelian group `D` either is densely ordered or has a least positive element.
*Proof.* If not densely ordered, pick `a < b` with nothing strictly between; then `d := b - a`
is least positive, since `0 < c < d` gives `a < a + c < b`. ∎

**Lemma B.** If `D` has a least positive element `d`, then every `t` has the immediate
successor `t + d`, and `DF φ` is true at **every** model, history and time. *Proof.* Assume
`Hφ ∧ φ ∧ F⊤` at `t`. Witness `F(Hφ)` at `s := t + d`: `t < s`, and any `u < s` satisfies
`u ≤ t` (else `0 < u - t < d`), so `φ(u)` by `Hφ` or by `φ` at `t`. ∎

**Lemma C.** If `D` is densely ordered, `DN ψ` is true everywhere. *Proof.* Given `GGψ` at `t`
and `t < s`, density supplies `t < r < s`, and `GGψ` at `t` applied to `r` then `s` gives
`ψ(s)`. ∎

Because a `TaskFrame` carries **one** `Duration` shared by every history, Lemma A's dichotomy
is a property of the frame, and Lemmas B/C then make one of the two disjuncts true at *every*
history at *every* time — which is exactly what `□` needs. Hence `BLValid Sp`, for **all** φ, ψ.

**This is machine-checkable today** (Lemmas A–C are elementary and `BLTruth.someFuture_iff`,
`past_iff`, `future_iff`, `box_iff` are already `@[simp]`). Composing with §3 gives
`⊢[Base] tr (Sp)` from `BXCanonical.completeness` — **without** the source's TMP-NB + M5
derivation, and therefore without depending on the `discrete_box_necessity` /
`modal_5_collapse` frame-class reading that `Conservativity.lean` currently leans on. This is
a strictly cheaper and strictly more robust route to CEB's TM⁺ half, and it puts that half on
the same in-tree footing `z1_translate` gives CEF's.

### 4.2 Why the refutation must leave `TaskFrame` — and a sharpening

The brief is right that no task frame refutes (Sp); §4.1 proves it rather than asserting it.
Worth recording a further, non-obvious sharpening that constrains what a witness can look like:

**The `□` is essential; the un-boxed disjunction is useless as a witness.** `DF φ ∨ DN ψ` is
valid on *every strict linear order whatsoever*, not just on task frames. At any point `t`:
if `t` has an immediate successor, Lemma B's argument (which uses only the successor, not the
group) makes `DF φ` true at `t`; if `t` has no immediate successor, then for `DN ψ` to fail at
`t` one would need a `ψ`-counterexample `s₀ > t` with no point strictly between `t` and `s₀`
— i.e. an immediate successor. So one of the two disjuncts always holds, pointwise, with no
frame condition at all.

Consequently the failure (Sp) detects is **not a temporal failure but a modal-rigidity
failure**: what task frames enforce and general TM structures do not is that *the same*
disjunct works at *every history*. A refuting structure must therefore be one in which
different histories see differently-shaped time.

### 4.3 The witness structure

The two-fibre structure of the `Conservativity.lean` docstring, made explicit:

- Points: `(ℤ-fibre) ⊔ (ℝ-fibre)`, each fibre linearly ordered by its own order, no temporal
  relation across fibres.
- `R_□` := universal on all points (an S5 relation).
- Valuation: `p` false exactly on `{x ∈ ℝ-fibre : x > 0}`; `q` false exactly at `1` in the
  ℤ-fibre.

TM is sound here — checked axiom by axiom: MK/MT/M5 hold because `R_□` is universal; MF
(`□φ → □Gφ`) is trivial for universal `R_□`; TK/T4/TA/TL hold within each fibre (a disjoint
union of linear orders is still weakly connected along `<`, since no point sees the other
fibre); TB holds because each fibre is unbounded above; MN is sound for universal `R_□`; TD is
sound because each fibre's order is reverse-isomorphic to itself.

And (Sp) fails everywhere: `DF p` fails at `0` in the ℝ-fibre (no `s > 0` has `Hp` at `s`,
since `s/2 > 0` is a `¬p` point), so `□(DF p)` is false at every point; `DN q` fails at `0` in
the ℤ-fibre (`GGq` holds — everything `≥ 2` is a `q`-point — while `Gq` fails at `1`), so
`□(DN q)` is false at every point. ∎

**Verdict for scope (a): TM is not complete over task frames.** Machine-checked status: the
reduction of §3 and the validity half of §4.1 are checkable now; the refutation half (§4.3) is
not, for the reason in §7.

---

## 5. Scope (b): what TM *is* sound and complete for

Three distinct answers, at three levels of confidence. They should not be conflated.

**(i) Kripke level — standard, unformalized, high confidence.** TM's frame correspondents are:
`R_□` an equivalence (S5: MK/MT/M5); `R_<` transitive (T4), serial in both directions (TB with
TD), with converse-connectedness (TA) and weak linearity (TL, the Lemmon `.3` schema); and MF
(`□φ → □Gφ`) corresponding to `R_□ ∘ R_< ⊆ R_□`, which with reflexivity of `R_□` yields
`R_< ⊆ R_□`. Every one of these is a Sahlqvist formula, so TM is canonical and hence **sound
and complete over exactly that Kripke class**. The two-fibre structure of §4.3 is a member of
it. This is textbook (Burgess, *Basic Tense Logic*; Goldblatt, *Logics of Time and
Computation*) but is **not** stated in the paper and is not formalized here — treat it as the
principled answer, not as an established repository result.

**(ii) Task-structure level — open.** Whether that Kripke class is the class of models of any
natural *task* structure is open. The natural generalization the paper's own semantics
suggests is a **fibred task structure**: a family of task frames, possibly over different
temporal orders, with `□` read globally across the family. Task frames are the degenerate
one-fibre case. Nothing in the tree or the paper defines this, and this is where the real
research content lies.

**(iii) Row by row — settled for CEF, open elsewhere.**

| System | Sound over | Complete over |
|---|---|---|
| TM | all task frames (`bl_soundness_valid`, in-tree) | **not** all task frames (§3, §4) |
| TM_f | **all discrete task frames** (paper line 4614; needs the new theorem of §6.1 to be in-tree) | **not** ℤ-time (§6); over the full discrete class: **open** (paper's own word) |
| TM_d | dense task frames (`bl_soundness_dense_valid`) | open |
| TM_dc | `BLValidDedekindDense` (`bl_soundness_dedekind_valid`) | open; CEC additionally inherits the open question of whether TMP-CO alone axiomatizes the BL⁺ logic, with the converse separately refuted in `Independence/CoNotPriorU.lean` |

A caution on TM_f's soundness over the full discrete class: it is **not** currently a
repository theorem. `bl_soundness_discrete` is proved by *composition* through
`soundness_discrete`, and therefore inherits `[IsSuccArchimedean]`/`[IsPredArchimedean]`. The
paper's claim is true, but establishing it here requires §6.1.

---

## 6. Scope (c): can CEB and CEF now be machine-checked?

### 6.1 CEF — YES, and it never leaves `TaskFrame`

The Discrete row does **not** face the brief's subtlety. `Z1` is unsound on non-Archimedean
discrete orders, and those *are* task frames: a lexicographic product of ordered abelian groups
is an ordered abelian group, so `ℚ ×ₗ ℤ` (and `ℤ ×ₗ ℤ`) satisfies all four `TemporalOrder`
binders. The tree already has `example`s witnessing this for `ℚ ×ₗ ℤ`
(`BXCanonical/DiscreteCarrierProbe.lean:65-68`), which is why `ℚ ×ₗ ℤ` is the recommended
carrier over the paper's `ℤ ×ₗ ℤ` — identical mathematics, existing instance evidence.

**The countermodel, verified by hand.** Let `D := ℚ ×ₗ ℤ`,
`F := multiFamTaskFrameGen (TemporalOrder.of D) Unit`, `τ := multiFamHistoryGen () 0` (total by
`multiFamHistoryGen_total`), and `M.valuation := fun w _ => 1 ≤ w.2.1` (the ℚ-coordinate of the
world state). Then `BLTruthAt M τ t (atom p) ↔ 1 ≤ t.1`. Evaluate:

- `G p` at `t`: if `t.1 ≥ 1`, every `s > t` has `s.1 ≥ t.1 ≥ 1`, so true; if `t.1 < 1`, then
  `s := (t.1, t.2 + 1) > t` has `s.1 < 1`, so false. Hence `Gp ↔ p` pointwise.
- `G(Gp → p)` at `(0,0)`: true, since `Gp ↔ p` at every point.
- `F(Gp)` at `(0,0)`: true, witnessed by `(1,0) > (0,0)`.
- `G p` at `(0,0)`: false, since `(0,1) > (0,0)` and `¬p` there.

So `Z1 p` is **false** at `(M, τ, (0,0))`. ∎

**What is still missing is not the countermodel — it is one soundness theorem.**
`bl_soundness_discrete` cannot be applied at this carrier: its `[IsSuccArchimedean]` binder is
precisely what `ℚ ×ₗ ℤ` fails. A sibling is needed:

```
BLValidDiscreteSucc φ := ∀ (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
                           (M : TaskModel F) (τ : WorldHistory F) (_ : τ.IsTotal)
                           (t : F.Duration), BLTruthAt M τ t φ

bl_soundness_discrete_succ : ⊢ᴮᴸ[.Discrete] φ → BLValidDiscreteSucc φ
```

**Its obligations are far smaller than a fresh soundness development**, because of a
frame-class fact already `decide`-checked in the tree: at `FrameClass.Discrete` the admissible
BL axioms are exactly the Base ones plus `df` (`Dense ≰ Discrete` and `Dedekind ≰ Discrete`
kill `dn` and `co`). So, by induction on `BaseLanguage.DerivationTree .Discrete`:

| Case | Discharge |
|---|---|
| `axiom` with `minFrameClass = .Base` | `bl_soundness_valid (.axiom [] _ ax (FrameClass.base_le _))`, then weaken `BLValid → BLValidDiscreteSucc` |
| `axiom` = `dn` / `co` | impossible: `absurd h_fc (by decide)` |
| `axiom` = `df` | **the one new semantic proof** — Lemma B of §4.1 with `Order.succ`, needing only `[SuccOrder]` and no maximum (supplied by `F⊤` in the antecedent) |
| `assumption`, `modus_ponens`, `weakening` | structural |
| `necessitation`, `temporal_necessitation` | validity-level, as in `bl_soundness` |
| `temporal_duality` | swap-strengthened induction, mirroring `SoundnessLemmas/DenseValidity.lean`'s per-axiom `…_swap` pattern. **Cheap here**: the swap of any *Base* BL axiom is itself a Base BL theorem (`.temporal_duality _ (.axiom …)`), so `bl_soundness_valid` covers it for free; only `swapBL (df)` = `(Gφ ∧ φ ∧ P⊤) → P(Gφ)` needs a new proof, and it is the `[PredOrder]` mirror of the `df` case |

**Net new mathematical content: two dual semantic lemmas (DF and its past-dual).** Everything
else is plumbing over existing sorry-free results.

**Two deliverables then follow immediately.**

1. **Forward conservativity is refuted at `.Discrete`, machine-checked.**
   `z1_translate` gives `⊢[Discrete] tr (Z1 p)`; `bl_soundness_discrete_succ` plus the
   countermodel gives `¬ ⊢ᴮᴸ[Discrete] Z1 p`. This upgrades CEF from *documented* to
   *machine-checked*, with **both** halves in-tree.

2. **TM_f is not weakly complete over ℤ-time, machine-checked.**
   `BLValidDiscrete (Z1 p)` follows from `z1_translate` + `soundness_discrete` + `truthAt_tr`
   (all in-tree today); combined with `¬ ⊢ᴮᴸ[Discrete] Z1 p` this refutes the `.Discrete` row
   of the §3 reduction. By Hölder (paper line 4613) `ValidDiscrete` is validity over ℤ-time up
   to isomorphism, so this is exactly the TM_f-vs-TM⁺_f completeness gap.

Small Mathlib gap to note: there is **no** `SuccOrder`/`PredOrder` instance for `Prod.Lex` in
the pinned Mathlib. Both must be supplied (successor `(q, n) ↦ (q, n + 1)`, predecessor
`(q, n) ↦ (q, n - 1)`); each is a short `SuccOrder.ofSuccLeIff`-style construction.
`¬ IsSuccArchimedean` never has to be *proved* — it is merely not assumed — though an
`example` recording it is worth having as documentation.

### 6.2 CEB — NO, and the current docstring overstates readiness

`Conservativity.lean` says the missing prerequisite "has simply narrowed from three items to
one" — the countermodels. **For the Base row that is not right.** The BL semantics that arrived
(`BLTruthAt`) is defined over `TaskFrame`, and `bl_soundness` is obtained by *composition*
through the BL⁺ soundness theorem. Both are structurally incapable of hosting the CEB
refutation, for the reason §4.1 proves: (Sp) is BL-valid on every task frame, so no
`TaskFrame`-indexed soundness theorem can ever refute `TM ⊢ Sp`. Worse, the composition route
is unavailable *in principle* on the two-fibre class — TM⁺ **proves** `tr (Sp)`, so TM⁺ is
*unsound* there, and `translate`-then-`soundness` cannot be run.

What CEB actually needs, in order:

1. **A new frame notion** outside `TaskFrame` — a fibred/multi-duration structure, or a plain
   bimodal Kripke frame `⟨P, R_□, R_<⟩` with the §5(i) conditions. New file, new definitions.
2. **A new truth definition** for `BLFormula` over that notion.
3. **A native BL soundness theorem** over it: all 11 TM axiom schemata verified *directly*
   against the new truth definition (no composition available), plus MP, MN, temporal
   necessitation and TD, the last via a swap-strengthened induction. This is the bulk of the
   work — roughly the size of `SoundnessLemmas/` on the BL⁺ side, though simpler because BL
   has no `untl`/`snce`.
4. **The two-fibre instance** and the evaluation of §4.3.

Item 3, not item 4, is the real prerequisite. The countermodel itself is the easy part.

Balancing this: **the TM⁺ half of CEB *can* be machine-checked now**, by §4.1 + §3 —
`BLValid Sp` semantically, then `blValid_iff_valid_tr` + `BXCanonical.completeness`. That is a
genuinely new, cheap, in-tree result and it is the CEB analogue of `z1_translate`.

---

## 7. Recommended in-tree corrections

Three, all to `FormalSystem/Metalogic/Conservativity.lean`'s module docstring. None touches a
theorem statement; none introduces a `sorry`.

1. **"What a machine-checked refutation would need" is now row-dependent.** Replace the single
   "the missing prerequisite is now the countermodels alone" with:
   - **CEF**: the missing prerequisite is a *binder-weakened* BL soundness theorem
     (`bl_soundness_discrete_succ`, §6.1) — `bl_soundness_discrete`'s `[IsSuccArchimedean]`
     binder is exactly what the countermodel carrier fails. The countermodel itself is
     assembly over `multiFamTaskFrameGen` at `ℚ ×ₗ ℤ`.
   - **CEB**: the missing prerequisite is a *frame notion outside `TaskFrame`* plus a **native**
     BL soundness theorem over it. `BLTruthAt`/`bl_soundness` do not supply this and cannot,
     because (Sp) is valid on every task frame and TM⁺ is unsound on the two-fibre class.

2. **The CEF section should record that the refuting structure is a task frame.** The current
   text can be read as implying the ℤ ×ₗ ℤ countermodel is exotic; it is an ordinary
   `TemporalOrder`, and the tree already probes the sibling carrier `ℚ ×ₗ ℤ` for exactly these
   binders.

3. **Add the §3 reduction as a landed theorem** (`Metalogic/BaseLanguageSoundness.lean` or a
   new `Metalogic/TMCompletenessReduction.lean`), so that "TM is complete over task frames"
   and "forward conservativity holds at Base" are formally pinned as the same proposition, and
   a future dispatch cannot attempt the first while honouring the prohibition on the second.

---

## 8. Risks and mitigations

| Risk | Mitigation |
|---|---|
| The exact `(Sp)` of the source is not recoverable — `thm:ConservativeExtension` was deleted from the paper at `b07ceb31` | §4.1 does not need it. `Sp := □(DF φ) ∨ □(DN ψ)` is validated here from first principles, and its TM⁺ half is obtained from `completeness` rather than from the source's TMP-NB/M5 derivation. Cite the reconstruction as such, not as the source's formula. |
| §5(i)'s Sahlqvist-canonicity claim is textbook but unformalized and not in the paper | Report it as the principled answer with its provenance, never as an established repository result. Formalizing it is a separate, large task. |
| `SuccOrder`/`PredOrder` for `Prod.Lex` absent from pinned Mathlib | Construct locally; both are short. Alternatively prove the `df` case with an explicit successor function and drop the `SuccOrder` binder in favour of a bare hypothesis `∀ t, ∃ s, t < s ∧ ∀ u, u < s → u ≤ t`, which sidesteps the instance entirely. |
| The `temporal_duality` case of `bl_soundness_discrete_succ` is the only structurally new induction | Mirror `SoundnessLemmas/DenseValidity.lean`'s established per-axiom `…_swap` pattern; and note that swaps of Base BL axioms are free via `bl_soundness_valid ∘ .temporal_duality`. |
| Landing the §3 reduction could be misread as approaching forward conservativity | The reduction asserts neither side. State the prohibition explicitly in its docstring, and note that it *strengthens* the prohibition by showing a second phrasing of the same forbidden claim. |
| Lemma A has no Mathlib counterpart under the pinned version (searched `Algebra/Order/Group/`, `Order/SuccPred/`) | Prove locally; ~15 lines, no dependencies beyond `IsOrderedAddMonoid`. |

---

## 9. Verdict summary against the task's scope

**(a) Is TM complete over task frames?** **No.** Established by the §3 reduction (TM
completeness at Base ≡ forward conservativity at Base, machine-checkable today) together with
the §4 (Sp) argument, whose validity half is machine-checkable today and whose refutation half
needs the §6.2 layer. The parallel Discrete-row claim — TM_f is not weakly complete over
ℤ-time — is fully machine-checkable once §6.1 lands.

**(b) What is TM complete for?** Not a task-frame class. At the Kripke level, the S5 ⊗ Kt4.3 +
MF class, by Sahlqvist canonicity (standard, unformalized). At the task-structure level, a
fibred multi-duration generalization — undefined anywhere and the real open research content.
Row-specifically, TM_f is sound over the full discrete class (the paper's own commented
sentence at line 4614) and its completeness there is open.

**(c) Can CEB and CEF now be machine-checked?** **CEF: yes**, entirely inside `TaskFrame`,
gated on one binder-weakened soundness theorem whose only new content is the DF schema and its
past-dual. **CEB: no** — the prerequisite is a new frame notion plus a native, non-composed BL
soundness theorem, not a countermodel. But CEB's **TM⁺ half becomes machine-checkable now**,
via §4.1 + `completeness`, giving it the same standing `z1_translate` gives CEF's.

**Hard constraint honoured**: no forward-conservativity theorem is proposed anywhere in this
report, and the §3 reduction is deliberately an equivalence between two unasserted `Prop`s.
