# Phase 27 blocker research: `doets_lemma_1_5` (Doets 3.1.8) and the `hcol` hypothesis

**Task**: 408 | **Type**: lean4 | **Mode**: `--hard` (H2/H3/H4)
**Session**: `sess_1785294686_04bad3`
**Focus**: blocker research — the mixing lemma and the coloured-index-order equivalence
**Reference grounding tier**: **Tier 1** (literature-backed — Doets 1987 thesis 3.1.8 / Doets 1989
Lemma 1.5, Reynolds 1992 §8; both read from the local corpus, not from recollection)

---

## Headline

**Half 2 is not blocked. It is solved.** A complete, sorry-free, axiom-clean proof of the
coloured-index-order equivalence — including the specialisation that discharges
`kEquiv_shuffle_shuffleReal`'s `hcol` hypothesis at the call site — was written and compiled
green during this dispatch. 219 lines, at

```
/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/5ec8c464-f1b9-45ff-aff6-a9f2888368a3/scratchpad/VERIFIED-half2-coloured-dlo.lean
```

`#print axioms hcol_shuffle_shuffleReal` returns `[propext, Classical.choice, Quot.sound]` — no
`sorryAx`.

**Half 1 is genuinely blocked and genuinely multi-dispatch**, and the implementer's obstacle
analysis is **correct** — but its *justification* is narrower than the truth, and the first slice
of the work turns out to be far cheaper than the handoff implies. Two further sorry-free
compiled artifacts were produced here:

- the two-index generalisation of `BiCompat` / `sum_nf_lift_gen` — the piece the handoff calls
  "the missing work" — compiles as a **verbatim mechanical port**, 90 lines, and in fact needs
  *fewer* hypotheses than the shared-index original
  (`VERIFIED-half1-phaseC1-lift.lean`);
- the cross-structure witness-extension lemmas needed by both halves, revived from the Boneyard
  under live names (`VERIFIED-nf-extend-revival.lean`).

What actually remains for Half 1 is `CompData` → `CompData₂` and `build_bicompat` →
`build_bicompat₂`: the dependent-cast bookkeeping, ~550 lines, 2–3 dispatches.

---

## 1. Adversarial check of the obstacle claim (mission item 1)

### 1.1 The re-association impossibility argument is **sound**, and the implementer under-sold it

The handoff's stated reason is:

> a convex partition of ℝ into countably many blocks cannot have quotient order ℚ (ℝ is
> Dedekind complete, ℚ is not)

The **countability clause is irrelevant** and slightly obscures the real content. The theorem is:

> **Any** quotient of a Dedekind-complete linear order by a convex partition into nonempty
> blocks is itself Dedekind complete.

*Proof.* Let `π : R → K` be the quotient, fibres convex and nonempty. Let `S ⊆ K` be nonempty and
bounded above by `q₀`. Then `T = π⁻¹(S)` is bounded above by any element of `π⁻¹(q₀)` (convexity),
so `x = sup T` exists; put `q = π x`. For `s ∈ S` pick `t ∈ π⁻¹(s)`: `t ≤ x`, so `s ≤ q` — `q` is
an upper bound. If `q' < q` were a smaller upper bound, take `y ∈ π⁻¹(q')`; then `y < x`, so some
`t ∈ T` has `y < t`, whence `q' ≤ π t ∈ S`, forcing `π t = q'`, i.e. `q' = max S`. Either way `S`
has a supremum. ∎

Since ℚ is not Dedekind complete, no convex-partition quotient of ℝ is order-isomorphic to ℚ.
Countability never enters.

### 1.2 The escape route is narrower than `kEquiv_orderedSum_of_orderIso` — and it is still closed

The handoff argues only that Phase 26's `kEquiv_orderedSum_of_orderIso`
(`RealModel/Shuffle.lean:300`) does not apply. That is not the whole re-association surface: the
tree has a **second** re-association tool, `kEquiv_orderedSum_blocks`
(`RealModel/Shuffle.lean:424`), which is strictly more general — it re-writes *any* structure as
a lexicographic sum along any order-respecting block map `cls : P.carrier → I`, with empty blocks
permitted and no surjectivity required. I checked that route explicitly and it is also closed:

- `hmono : ∀ x y, cls x < cls y → x < y` forces the blocks to be convex (if `x < z < y` with
  `cls x = cls y = i` and `cls z = j ≠ i`, either `j < i` gives `z < x` or `j > i` gives `y < z`).
- So a `ℚ`-indexed block decomposition of `shuffleReal` is a convex partition whose quotient is
  the *set of ℚ with nonempty block*, with the order induced from ℚ. By §1.1 that quotient is
  Dedekind complete (`shuffleReal`'s carrier is Dedekind complete — the tree proves it as
  `exists_isLUB_orderedSumReal`).
- To match `Σ_{q∈ℚ} σ(q)` summand-by-summand the quotient would have to be order-isomorphic to
  ℚ. A Dedekind-complete order is not.

**Verdict**: the blocker as framed is **correct**, not wrong and not narrower. It is in fact
*wider* than the handoff claimed — it closes both re-association tools in the tree, not just one
— and rests on a cleaner fact than the one cited.

### 1.3 Where the framing *is* wrong: "generalizing it is phase-sized work"

The handoff's sorry inventory says the missing work is

> Generalize `NEquivalence.lean`'s `sum_nf_agree` / `sum_lift_one_var` induction from a shared
> index set to a coloured correspondence between two index sets

and treats that as one indivisible phase. Two corrections:

1. **`sum_nf_lift_gen` is not the hard part.** Its two-index generalisation compiles as a
   near-verbatim port (§4.1) — `rintro ⟨⟨j, c'⟩, hc'⟩; obtain ⟨c, …⟩ := h_bc_fwd j c'` becomes
   `obtain ⟨i, c, …⟩ := h_bc_fwd j c'`, and nothing else changes. It also **drops** the
   `_h_comp` component-agreement hypothesis entirely, which the shared-index original carries
   but never uses in that lemma.
2. **`sum_lift_one_var` should not be generalised at all.** It is a bootstrap for
   `sum_nf_agree_sentence`'s single-index base case; in the two-index setting the corresponding
   base case is built from the *index game's* first move, not from a hand-rolled singleton
   `CompData`. Porting it would be wasted work.

The hard part is `CompData` → `CompData₂` and `build_bicompat` → `build_bicompat₂`
(`NEquivalence.lean:333` and `:512`), where the `if j' = j then … else …` dependent-cast surgery
(`Function.hfunext`, `cast_heq`, `Fin.heq_ext_iff`) lives.

---

## 2. Reference grounding (mission item 2)

Sources read directly this dispatch, not recalled:

| Source | Location read |
|---|---|
| Doets 1987 thesis, 3.1.6/3.1.7/3.1.8 | `Literature/sources/doets_1987/sec02_69-lemma.md:56-60` |
| Doets 1989, Lemmas 1.3/1.4/1.5 + proof sketch | `Literature/sources/doets_1989/sec01_…-introduction.md:205-249` |
| Reynolds 1992 §8, printed pp.186-188 | `Literature/sources/reynolds_1992/sec04_7-separability.md:67,69,139,145,147` |

### 2.1 The source statements, verbatim

Doets 1987 **3.1.8** (`sec02_69-lemma.md:60`):

> Suppose that $I$ and $J$ are ordered sets and that $m$ and $m'$ associate ordered models
> $m(i)$ resp. $m'(j)$ to each $i \in I$ resp. $j \in J$ such that:
> $(I, \{i \mid m(i) \models \sigma\})_{\sigma \in Z} \equiv^n (J, \{j \mid m'(j) \models
> \sigma\})_{\sigma \in Z}$, where $Z$ is the set of $n$-characteristics. Then
> $\sum_{i \in I} m(i) \equiv^n \sum_{j \in J} m'(j)$.

Doets 1989 Lemma 1.5 is the same statement; its proof is three lines:

> Use the Ehrenfeucht game-technique. If the first player chooses, say, `a ∈ Σ_I m(i)`, the
> second player locates the `i ∈ I` for which `a ∈ m(i)`, then uses (*) to find a `j`
> corresponding to `i`; in particular, `m'(j) ≡ⁿ m(i)`, and a counter-move is readily found; etc.

Reynolds 1992 p.188 (`sec04_7-separability.md:147`) — the consumer:

> Another simple game argument can be used to show that we can mix into a shuffle many more
> copies of the same structures without disturbing `k`-equivalence. … Now extend `σ` to
> `σ* : ℝ → {N_γ | γ ∈ G}` by `σ*(i) = N_{γ₁}` if `i ∈ ℝ − ℚ`. A game will show that
> `Σ_{q∈ℚ} σ(q) ≡_k Σ_{r∈ℝ} σ*(r)`.

**Fidelity verdict**: the tree's `doets_lemma_1_5` (`RealModel/ShuffleReal.lean:196`) is a
faithful transcription of 3.1.8. `Z := KType sig k` matches "the set of `n`-characteristics";
`colourStructure I (fun i => kTypeOf sig k (m i))` with `interp p i := (c i = p)` matches
`(I, {i | m(i) ⊨ σ})_{σ∈Z}`; the hypothesis and conclusion use the same depth `k`, as in the
source. No correction needed to the landed statement.

### 2.2 Lemma-mapping table

| Source statement | Intended Lean statement | Already in tree | Must be built |
|---|---|---|---|
| Doets 3.1.7 / 1989 L1.4 (shared index) | `doets_lemma_1_4` | ✔ `OrderedSum.lean:46`, proved | — |
| Doets 3.1.8 / 1989 L1.5 (two indices) | `doets_lemma_1_5` | statement only, `ShuffleReal.lean:196`, `sorry` | §4 |
| — (implicit in Doets' "uses (*) to find a `j`") | `nf_extend_fwd` / `nf_extend_bwd` | Boneyard draft behind `#exit`, stale names | **✔ revived & compiled, §4.0** |
| — (implicit in Doets' game) | `BiCompat₂`, `sum_nf_lift_gen₂` | — | **✔ compiled, §4.1** |
| — (implicit in Doets' game) | `CompData₂`, `build_bicompat₂` | shared-index versions at `NEquivalence.lean:333,512` | §4.2 — the real work |
| — (implicit in Doets' game) | `sum_nf_agree_sentence₂` → `doets_lemma_1_5` | shared-index version at `NEquivalence.lean:1005` | §4.3 |
| Reynolds p.186 "well defined up to isomorphism"; p.188 "a game will show" | `kEquiv_colourStructure` (the `hcol` fact) | — | **✔ compiled, §3** |
| Reynolds p.188 `Σ_ℚ σ ≡ₖ Σ_ℝ σ*` | `kEquiv_shuffle_shuffleReal` | proved *given* `doets_lemma_1_5` + `hcol` | `hcol` now discharged, §3.3 |

---

## 3. Half 2 — solved

### 3.1 What already existed (mission item 4)

- **Mathlib**: `Order.iso_of_countable_dense` (`Mathlib.Order.CountableDenseLinearOrder`)
  requires `[Countable α]` **and** `[Countable β]`, so it cannot relate `(ℚ, σ)` to `(ℝ, σ*)`;
  and it carries no colours. `Order.PartialIso.exists_across` is the exact *uncoloured* analogue
  of what is needed (`[DenselyOrdered β] [NoMinOrder β] [NoMaxOrder β] [Nonempty β] (f) (a) :
  ∃ b, ∀ p ∈ ↑f, cmp p.1 a = cmp p.2 b`) but gives no control over the witness's colour, so it
  cannot be applied — only imitated. `FirstOrder.Language.dlo_isComplete` exists but is for the
  pure order language, and this tree does not use Mathlib's `FirstOrder.Language` layer at all.
- **This tree**: `FormalSystem/Metalogic/WeakCanonical/EFGames/` is a *different* game (GHR93
  Stavi-formula games over intervals, `Ghr93DuplicatorWins`). `EFPosition` /
  `EfDuplicatorWins` (`EFGames/Defs.lean:54,73`) are a *position* predicate — order agreement
  plus predicate agreement — with **no** `n`-round strategy layer and no
  "Duplicator wins ⇒ `≡ₙ`" bridge. Nothing reusable for a coloured back-and-forth.

So: not present anywhere; had to be built. It now is.

### 3.2 The statements that were proved

```lean
/-- Every colour of `C` is taken strictly inside every interval, and every point is coloured
from `C`. -/
def DenselyColoured {Z I : Type} [LinearOrder I] (C : Set Z) (c : I → Z) : Prop :=
  (∀ i, c i ∈ C) ∧ ∀ z ∈ C, ∀ a b : I, a < b → ∃ x, a < x ∧ x < b ∧ c x = z

/-- **The colour-preserving Cantor extension step.** -/
theorem exists_colour_match [Nonempty J] [NoMinOrder J] [NoMaxOrder J]
    {C : Set Z} {c : I → Z} {c' : J → Z}
    (hI : ∀ i, c i ∈ C) (hJ : DenselyColoured C c')
    {n : Nat} (f : Fin n → I) (g : Fin n → J)
    (hord : ∀ p q, f p < f q ↔ g p < g q)
    (hcol : ∀ p, c (f p) = c' (g p)) (x : I) :
    ∃ y : J, (∀ p, f p < x ↔ g p < y) ∧ (∀ p, x < f p ↔ y < g p) ∧ c x = c' y

/-- **Depth-`k` normal-form agreement of two densely-coloured endpointless orders.** -/
theorem nfAgree_colourStructure [Nonempty I] [NoMinOrder I] [NoMaxOrder I]
    [Nonempty J] [NoMinOrder J] [NoMaxOrder J]
    {C : Set Z} {c : I → Z} {c' : J → Z}
    (hI : DenselyColoured C c) (hJ : DenselyColoured C c') :
    ∀ (k n : Nat) (f : Fin n → I) (g : Fin n → J)
      (_hord : ∀ p q, f p < f q ↔ g p < g q) (_hcol : ∀ p, c (f p) = c' (g p))
      (nf : NormalForm (colourSig Z) k n),
      NfEvalNf (colourStructure I c) k n f nf ↔
      NfEvalNf (colourStructure J c') k n g nf

theorem kEquiv_colourStructure [Nonempty I] [NoMinOrder I] [NoMaxOrder I]
    [Nonempty J] [NoMinOrder J] [NoMaxOrder J]
    (k : Nat) {C : Set Z} {c : I → Z} {c' : J → Z}
    (hI : DenselyColoured C c) (hJ : DenselyColoured C c') :
    KEquiv (colourSig Z) k (colourStructure I c) (colourStructure J c')
```

Notes worth carrying into implementation:

- **No finiteness of the palette is used anywhere.** `C : Set Z` is an arbitrary set; the finite
  palette of Reynolds' `G` is never needed for this half. Do not add a `Fintype` hypothesis.
- **No `Fintype sig.preds` / `DecidableEq sig.preds` on `colourSig Z` is needed** either — the
  normal-form machinery this half consumes (`NfEvalNf`, `nfCharacteristic`,
  `nf_agreement_from_shared_nf`, `atom_agreement_from_nf`) carries no instance binders.
- `AtomEval (colourStructure I c) f (.pred z p)` does **not** reduce automatically to
  `c (f p) = z`; the proof needs an explicit `show c (f p) = z ↔ c' (g p) = z` before `rw`.
- Density of the *order* is a consequence of `DenselyColoured` (given `C` nonempty), so it is not
  a separate hypothesis. `NoMinOrder`/`NoMaxOrder` **are** needed: they are what turn the
  bounded-interval density condition into "every colour occurs below/above any point".

### 3.3 The call-site discharge

```lean
theorem hcol_shuffle_shuffleReal (k : Nat) {ι : Type} (N : ι → OrderedMonadicStructure sig)
    {S : Finset ι} {γ₁ : ι} {σ : ℚ → ι} (hγ : γ₁ ∈ S) (hσ : IsShuffleMap S σ) :
    KEquiv (colourSig (KType sig k)) k
      (kTypeColouring sig k (fun q : ℚ => N (σ q)))
      (kTypeColouring sig k (fun r : ℝ => N (shuffleColourReal γ₁ σ r))) :=
  kEquiv_colourStructure k
    (denselyColoured_shuffle hσ N k)
    (denselyColoured_shuffleReal (isShuffleMapReal_shuffleColourReal hγ hσ) N k)
```

with `C := (fun i => kTypeOf sig k (N i)) '' (S : Set ι)`. The `k`-type colouring is a
*coarsening* of the palette colouring, and a coarsening of a dense colouring is dense, so the two
`DenselyColoured` facts are four-line consequences of `IsShuffleMap` / `IsShuffleMapReal`.
`isShuffleMapReal_shuffleColourReal` (`ShuffleReal.lean:119`) supplies the ℝ side unchanged.

**Signature change required at the consumer.** `kEquiv_shuffle_shuffleReal`
(`ShuffleReal.lean:218`) currently takes `(N) (γ₁) (σ)` and no density data, so `hcol` cannot be
discharged in its present form. It must gain `{S : Finset ι} (hγ : γ₁ ∈ S)
(hσ : IsShuffleMap S σ)` in place of `hcol`. The compiled candidate does this as
`kEquiv_shuffle_shuffleReal'`. This is a strict improvement: the density condition is what makes
the object a *shuffle*, and the current signature silently drops it.

---

## 4. Half 1 — the concrete route (mission item 3)

### 4.0 Prerequisite, compiled: cross-structure witness extraction

Both halves need "from depth-`(K+1)` agreement at `r` variables and a point on one side, get a
point on the other with depth-`K` agreement at `r+1` variables". This exists in the tree only as
a **Boneyard draft behind `#exit`** using stale names
(`Boneyard/KampBypassArchive/KampBypass.lean:40,61`, `nf_eval_nf` / `nf_characteristic`). Renaming
to `NfEvalNf` / `nfCharacteristic` is the **only** change required: both compile sorry-free and
axiom-clean, verified this dispatch. They belong in `NormalForm.lean` beside
`nf_agreement_from_shared_nf`, non-private, since three call sites want them.

### 4.1 Compiled: `BiCompat₂` and `sum_nf_lift_gen₂`

```lean
private noncomputable def BiCompat2 (sig : MonadicSignature) :
    Nat → (n : Nat) → (I J : Type) → [LinearOrder I] → [LinearOrder J] →
    (ms : I → OrderedMonadicStructure sig) → (ms' : J → OrderedMonadicStructure sig) →
    (env_M : Fin n → (orderedSum sig I ms).carrier) →
    (env_N : Fin n → (orderedSum sig J ms').carrier) → Prop
  | 0, _, _, _, _, _, _, _, _, _ => True
  | d + 1, n, I, J, _, _, ms, ms', env_M, env_N =>
    (∀ (j : J) (c' : (ms' j).carrier), ∃ (i : I) (c : (ms i).carrier),
      (∀ ak : AtomKind sig (n + 1),
        AtomEval (orderedSum sig I ms) (Fin.cons (orderedSumPt i c) env_M) ak ↔
        AtomEval (orderedSum sig J ms') (Fin.cons (orderedSumPt j c') env_N) ak) ∧
      BiCompat2 sig d (n + 1) I J ms ms'
        (Fin.cons (orderedSumPt i c) env_M) (Fin.cons (orderedSumPt j c') env_N)) ∧
    (∀ (i : I) (c : (ms i).carrier), ∃ (j : J) (c' : (ms' j).carrier),
      (∀ ak : AtomKind sig (n + 1), …) ∧ BiCompat2 sig d (n + 1) I J ms ms' … )
```

**This is the exact answer to "which induction hypothesis has to change and what its generalized
statement should be".** The change is: the responding index moves from a shared universally
quantified `j : I` into the existential. `sum_nf_lift_gen₂` then has signature

```lean
private theorem sum_nf_lift_gen2 (sig : MonadicSignature) :
    ∀ (d : Nat) (n : Nat) (I J : Type) [LinearOrder I] [LinearOrder J]
    (ms : I → OrderedMonadicStructure sig) (ms' : J → OrderedMonadicStructure sig)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig J ms').carrier)
    (_h_atoms : ∀ a : AtomKind sig n,
      AtomEval (orderedSum sig I ms) env_M a ↔ AtomEval (orderedSum sig J ms') env_N a)
    (_h_bc : BiCompat2 sig d n I J ms ms' env_M env_N)
    (nf : NormalForm sig d n),
    NfEvalNf (orderedSum sig I ms) d n env_M nf ↔
    NfEvalNf (orderedSum sig J ms') d n env_N nf
```

— note the shared-index original's `_h_comp` hypothesis is **gone**; it was never used. Compiled
sorry-free, axiom-clean, 90 lines including the redefinitions.

### 4.2 The remaining work: `CompData₂` and `build_bicompat₂`

The design that minimises the port cost keeps `sz`, `eM`, `eN` **indexed by `I`**, and carries the
index correspondence as a *total* function `ϕ : I → J`. Every `if j' = j then … else …`
dependent-cast block in the existing `build_bicompat` then survives verbatim, with `ms' j`
replaced by `ms' (ϕ j)`:

```lean
private structure CompData2 (sig : MonadicSignature) (Z : Type)
    (I J : Type) [LinearOrder I] [LinearOrder J]
    (ms : I → OrderedMonadicStructure sig) (ms' : J → OrderedMonadicStructure sig)
    (c : I → Z) (c' : J → Z) (budget : Nat) {n : Nat}
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig J ms').carrier)
    (ϕ : I → J)
    (h_idx : ∀ p : Fin n, ϕ (env_M p).1 = (env_N p).1) : Type where
  -- summand side: unchanged from `CompData` except for `ϕ` in `eN`'s type
  sz  : I → Nat
  eM  : (i : I) → Fin (sz i) → (ms i).carrier
  eN  : (i : I) → Fin (sz i) → (ms' (ϕ i)).carrier
  agree : ∀ i : I, ∀ nf : NormalForm sig (budget - sz i) (sz i),
    NfEvalNf (ms i) (budget - sz i) (sz i) (eM i) nf ↔
    NfEvalNf (ms' (ϕ i)) (budget - sz i) (sz i) (eN i) nf
  bound : ∀ i, sz i < budget
  sz_le_n : ∀ i, sz i ≤ n
  consistent : ∀ (p : Fin n) (i : I) (h : (env_M p).1 = i),
    ∃ q : Fin (sz i), h ▸ (env_M p).2 = eM i q ∧ (…) ▸ (env_N p).2 = eN i q
  -- index side: the running position in the coloured index game
  len   : Nat
  idxM  : Fin len → I
  idxAgree : ∀ nf : NormalForm (colourSig Z) (budget - len) len,
    NfEvalNf (colourStructure I c) (budget - len) len idxM nf ↔
    NfEvalNf (colourStructure J c') (budget - len) len (ϕ ∘ idxM) nf
  idxBound : len < budget
  idxCovers : ∀ p : Fin n, ∃ t : Fin len, idxM t = (env_M p).1
```

**The key structural fact that makes this tractable** — and which is worth stating explicitly
because it is not obvious from Doets' three-line proof: *the index budget and the summand budgets
do not interact.* The **quality** of a matched index pair `(i, ϕ i)` is the atomic colour
predicate `c i = c' (ϕ i)`, i.e. `kTypeOf sig budget (ms i) = kTypeOf sig budget (ms' (ϕ i))`,
i.e. `KEquiv sig budget (ms i) (ms' (ϕ i))` — full budget, and **it never degrades**, no matter
how many rounds the index game has consumed. The index depth `budget - len` is needed only to
keep *extending* `ϕ` to new indices. Consequently the `agree` field keeps its existing
`budget - sz i` shape unchanged, and the two clocks can be tracked independently.

Update steps in `build_bicompat₂`:

- **Point in an already-corresponded index** `i` (`sz i > 0`, `∃ t, idxM t = i`): `ϕ`, `len`,
  `idxM`, `idxAgree` all unchanged; `sz i` bumps by 1 exactly as today.
- **Point in a new index**: extend the index game by one move via §4.0's
  `nf_extend_fwd`/`nf_extend_bwd` at `colourStructure`, obtaining `j` and
  `idxAgree` at depth `budget - (len+1)`; set `ϕ' := fun i' => if i' = i then j else ϕ i'`. No
  transport is needed for `eN` at `i` because `sz i = 0` there (the fibre is `Fin 0`); for
  `i' ≠ i` the rewrite is along `if_neg`, the same `▸` pattern already used at
  `NEquivalence.lean:598-607`. The new pair's `agree` at depth `budget - 1` with 1 variable comes
  from `KEquiv sig budget (ms i) (ms' j)` (the colour) plus §4.0 inside the summand.
- Order/colour agreement between the new index and previously matched ones comes from
  `atom_agreement_from_nf` applied to `idxAgree` at depth 0 — note the tree's `AtomKind` has no
  equality atom, but preserving `.order` atoms in **both** directions in a linear order forces
  equality preservation, which is exactly what `idxCovers` + `consistent` rely on.

Ported alongside: `orderedSum_order_fwd_via_comp`, `orderedSum_order_bwd_via_comp`,
`extend_atoms`, `sum_atoms_one_var` — mechanical, `h_idx p : (env_M p).1 = (env_N p).1` becomes
`ϕ (env_M p).1 = (env_N p).1`.

### 4.3 `sum_nf_agree_sentence₂` and the discharge

At `n = 0` the base case does **not** reuse `sum_lift_one_var`: given `⟨j, b⟩` in the `J`-sum,
the first index-game move (§4.0 at `colourStructure`, `k+1` → `k`, 0 → 1 variables) produces `i`
with `c i = c' j`, hence `KEquiv sig (k+1) (ms i) (ms' j)`, hence by `k_equiv_monotone` component
agreement at every depth `≤ k+1`; then §4.0 *inside* the summand produces `a`. That builds the
initial one-index `CompData₂`, and `build_bicompat₂` + `sum_nf_lift_gen₂` finish, exactly
mirroring `NEquivalence.lean:1005-1137`.

---

## 5. Independence and dispatch sizing (mission item 5)

**The two halves are genuinely independent** — confirmed. Half 2 (`kEquiv_colourStructure`) does
not mention ordered sums; Half 1 (`doets_lemma_1_5`) takes the coloured-order equivalence as an
opaque hypothesis. Neither is on the other's critical path. They share exactly one prerequisite,
§4.0, which is 20 lines.

The consumer `kEquiv_shuffle_shuffleReal` needs both, so the *task* is not finished until both
land — but they can be dispatched in either order, or in parallel with a territory split
(Half 2 touches only a new module + `ShuffleReal.lean:218`; Half 1 touches only
`NEquivalence.lean` + `ShuffleReal.lean:196`).

**Can either be discharged in one bounded dispatch?**

| Slice | Content | Est. lines | Bounded? |
|---|---|---|---|
| **P0** | Revive `nf_extend_fwd`/`nf_extend_bwd` into `NormalForm.lean` | ~25 | Yes — **already written & compiled** |
| **P1** | Half 2 in full: `DenselyColoured`, `exists_colour_match`, `nfAgree_colourStructure`, `kEquiv_colourStructure`, the two `denselyColoured_*` specialisations, and the `kEquiv_shuffle_shuffleReal` signature change | ~200 | Yes — **already written & compiled** |
| **P2** | `BiCompat₂` + `sum_nf_lift_gen₂` | ~90 | Yes — **already written & compiled** |
| **P3** | `CompData₂` + the four ported transfer lemmas | ~250 | Yes, one dispatch |
| **P4** | `build_bicompat₂` (the cast-heavy induction) | ~300 | **Risk concentration** — one dispatch, but the one that can fail |
| **P5** | `sum_nf_agree_sentence₂` → discharge `doets_lemma_1_5` | ~150 | Yes, one dispatch |

**Half 2: yes, one bounded dispatch** — and it is done; the dispatch is now a transcription job.
**Half 1: no.** Three further dispatches (P3, P4, P5) after P2. P4 is where a dispatch can
plausibly stall, and it should be dispatched alone with the explicit instruction to preserve the
existing `if j' = j` cast idiom rather than re-derive it.

**Recommended order**: P0 + P1 (one dispatch, largely transcription of the verified candidate,
lands a real reduction in open obligations) → P2 → P3 → P4 → P5.

---

## 6. Adversarial Self-Verification

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Doets 1987 3.1.8 says exactly what `ShuffleReal.lean:196` states | `doets_1987/sec02_69-lemma.md:60`, read verbatim | Direct source read (`verified_conversion` provenance) | High |
| Doets 1989 Lemma 1.5 is the same lemma, with a 3-line proof sketch | `doets_1989/sec01_….md:230-249` | Direct source read | High |
| Reynolds 1992 p.188 is the consumer and gives no proof | `reynolds_1992/sec04_7-separability.md:147` | Direct source read | High |
| Any convex-partition quotient of a Dedekind-complete order is Dedekind complete | Proof given in §1.1; no counterexample found | Hand proof, checked against the `q' = max S` edge case | High |
| ⇒ re-association of the ℝ-sum over ℚ is impossible | Follows from the above + ℚ not complete | Derivation | High |
| The impossibility closes `kEquiv_orderedSum_blocks` too, not just `kEquiv_orderedSum_of_orderIso` | `Shuffle.lean:424` read; `hmono` shown to force block convexity in §1.2 | Source read + hand proof | High |
| The handoff's "countably many blocks" clause is inessential | §1.1 proof never uses countability | Hand proof | High |
| `Order.iso_of_countable_dense` cannot be used (needs both sides countable, no colours) | `lean_loogle` returned the full signature: `[Countable α] … [Countable β]` | `lean_loogle` hit, full type signature | High |
| `Order.PartialIso.exists_across` is the uncoloured analogue but gives no colour control | `lean_loogle` signature: `∃ b, ∀ p ∈ ↑f, cmp p.1 a = cmp p.2 b` — no predicate | `lean_loogle` hit, full type signature | High |
| This tree's `EFGames/` is a different (GHR93 Stavi) game with no `n`-round strategy layer | `EFGames/Defs.lean:54-77` (`EFPosition`, `EfDuplicatorWins` = position predicate only); `Composition.lean` is `Ghr93DuplicatorWins` over intervals | Direct file read | High |
| `nf_extend_fwd`/`nf_extend_bwd` revive with only a rename | Compiled: `#print axioms` → `[propext, Classical.choice, Quot.sound]` | **`lake env lean` green, axiom-clean** | High |
| `BiCompat₂` + `sum_nf_lift_gen₂` port mechanically and drop `_h_comp` | Compiled sorry-free, axiom-clean | **`lake env lean` green, axiom-clean** | High |
| `exists_colour_match` (colour-preserving Cantor step) is provable in ~55 lines | Compiled | **`lake env lean` green** | High |
| `kEquiv_colourStructure` (Half 2, general) is provable | Compiled; `#print axioms` → `[propext, Classical.choice, Quot.sound]` | **`lake env lean` green, axiom-clean** | High |
| `hcol` is discharged at the ℚ/ℝ call site | `hcol_shuffle_shuffleReal` compiled; `#print axioms` clean | **`lake env lean` green, axiom-clean** | High |
| `kEquiv_shuffle_shuffleReal` must gain `S`/`hγ`/`hσ` to consume the discharge | Its current signature (`ShuffleReal.lean:218`) has no density data; the compiled `kEquiv_shuffle_shuffleReal'` shows the working form | Source read + compiled alternative | High |
| No `Fintype`/`DecidableEq` instances on `colourSig Z` are required | `NfEvalNf`, `nfCharacteristic`, `nf_agreement_from_shared_nf`, `atom_agreement_from_nf`, `sum_nf_agree_sentence` all have no instance binders (`NormalForm.lean:214-342`, `NEquivalence.lean:1005`); and Half 2 compiled without them | Source read + compiled | High |
| Palette finiteness is not needed for Half 2 | Compiled with `C : Set Z` arbitrary | Compiled | High |
| `CompData₂` with a total `ϕ : I → J` preserves the existing cast idiom | Design argument in §4.2, matched against `NEquivalence.lean:593-631`; **not compiled** | Source read + design reasoning | **Medium** |
| P4 (`build_bicompat₂`) is ~300 lines and is the risk concentration | Extrapolated from the shared-index original's size and cast density; **not compiled** | Estimate from source | **Medium** |
| Order-atom preservation in both directions forces equality preservation of indices | `AtomKind` has only `.pred`/`.order` (`NormalForm.lean:65`); in a linear order `¬(x<y) ∧ ¬(y<x) ↔ x = y` | Source read + hand argument | High |

**Contradiction log**: one, resolved. The handoff frames the whole of "generalize
`sum_nf_agree`/`sum_lift_one_var` to a coloured correspondence" as the missing work; §4.1's
compiled artifact shows the `sum_nf_lift_gen` half is a mechanical port and `sum_lift_one_var`
should not be ported at all. Precedence: a compiled Lean artifact outranks a prose estimate in a
handoff. Resolved in favour of §4.1.

**Recommendations modified after verification**:

- Initially I planned to report Half 2 as "a bounded but real dispatch of ~300-450 lines". After
  compiling it, the recommendation changed to "already done; the dispatch is transcription".
- Initially I planned to recommend generalising `sum_lift_one_var`. After reading
  `NEquivalence.lean:890-986` and `:1005-1137` I dropped that: it is a single-index bootstrap
  whose two-index analogue is the index game's first move, not a port.
- I did **not** end up recommending the tempting alternative of replacing `doets_lemma_1_5`'s
  abstract `≡ₖ` index hypothesis with a full (depth-free) back-and-forth hypothesis. That would
  make P3/P4 substantially easier, but it would no longer be Doets 3.1.8 — it would not cover the
  scattered/complete-ordering applications in Doets §3.2-3.3 — and it would leave the landed
  statement's `sorry` standing. Flagged here as a deliberate rejection, not an oversight.

**Residual risk, stated plainly**: everything in §3 and §4.0-4.1 is compiled. §4.2-4.3 is
design, not code. The single unverified load-bearing claim is that a total `ϕ : I → J` lets
`build_bicompat`'s dependent-cast blocks be ported rather than rewritten. If that fails, P4 grows
rather than breaks — the fallback is `Fin len`-indexed `sz`/`eM`/`eN`, which is correct but adds
a second cast layer.

---

## 7. Verified artifacts produced by this dispatch

No Lean source in the tree was modified. Three compiled, sorry-free, axiom-clean candidates:

| Path | Contents | Lines |
|---|---|---|
| `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/5ec8c464-f1b9-45ff-aff6-a9f2888368a3/scratchpad/VERIFIED-half2-coloured-dlo.lean` | All of Half 2 incl. the call-site discharge | 219 |
| `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/5ec8c464-f1b9-45ff-aff6-a9f2888368a3/scratchpad/VERIFIED-half1-phaseC1-lift.lean` | `BiCompat₂` + `sum_nf_lift_gen₂` | 90 |
| `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/5ec8c464-f1b9-45ff-aff6-a9f2888368a3/scratchpad/VERIFIED-nf-extend-revival.lean` | `nf_extend_fwd`/`nf_extend_bwd` under live names | 48 |

Only deprecation and unused-section-variable warnings remain in these files; they should be
cleaned (`push_neg` → `push Not`, `omit [LinearOrder I] [LinearOrder J] in`) at transcription time.

## References

- Doets 1987, *Completeness and Definability* (thesis), 3.1.6-3.1.8 —
  `~/Projects/Literature/sources/doets_1987/sec02_69-lemma.md`
- Doets 1989, *Monadic Π¹₁ Theories*, Lemmas 1.3-1.5 —
  `~/Projects/Literature/sources/doets_1989/sec01_monadic-pi11-axiomatizations-introduction.md`
- Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*, §8 —
  `~/Projects/Literature/sources/reynolds_1992/sec04_7-separability.md`
- `FormalSystem/Metalogic/WeakCanonical/NEquivalence.lean` — `BiCompat`, `CompData`,
  `build_bicompat`, `sum_nf_lift_gen`, `sum_lift_one_var`, `sum_nf_agree_sentence`
- `FormalSystem/Metalogic/WeakCanonical/NormalForm.lean` — `NfEvalNf`, `nfCharacteristic`,
  `nf_eval_unique`, `nf_agreement_from_shared_nf`, `atom_agreement_from_nf`
- `FormalSystem/Metalogic/WeakCanonical/RealModel/Shuffle.lean` — `orderedSumReindexEquiv`,
  `kEquiv_orderedSum_reindex`, `kEquiv_orderedSum_of_orderIso`, `kEquiv_orderedSum_blocks`
- `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` — `colourSig`,
  `colourStructure`, `kTypeColouring`, `doets_lemma_1_5`, `kEquiv_shuffle_shuffleReal`
- Mathlib `Mathlib.Order.CountableDenseLinearOrder` — `Order.iso_of_countable_dense`,
  `Order.PartialIso.exists_across`
