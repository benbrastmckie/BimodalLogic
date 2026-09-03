# Core MCS API Consolidation — Research Report

**Task**: 526 — Consolidate the maximal-consistent-set API in `FormalSystem/Metalogic/Core/` so the
three completeness routes consume one set of lemmas; run the MCS-automation experiment.
**Date**: 2026-09-03
**Sources**: `specs/reviews/2026-09-01-lean-engineering/` findings B-11, B-12, F-09, F-10, F-15,
F-22, A-14, D-12 (+ D-13, D-10 §5 utility ranking); live tree at `d0b931faf`.
**Toolchain**: Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1`, Aesop from `.lake/packages/aesop`.

---

## 1. Headline

Every proposed consolidation was **compiled and validated** against the live tree in scratch
modules before writing this report (nine experiment modules, E1–E9; all compile clean under
`lake env lean`). Six of the eight planned work items are confirmed and have working code below.
Two must change:

| # | Planned work | Verdict |
|---|---|---|
| 1 | `exists_maximal_of_chainClosed` + two instantiations | **VALIDATED** — compiles; 111 lines → 39 |
| 2 | `restricted_mcs_iter_bounded` via `Nat.find` | **VALIDATED, but the target is dead code** — the four lemmas have **zero** references anywhere. Boneyard is cheaper than refactor. |
| 3 | `SetMaximalConsistent.bot_not_mem` | **VALIDATED, and the scope is larger** — there are **four** copies, not three; the right lemma is on `SetConsistent`, not `SetMaximalConsistent` |
| 4 | `someFuture_mono` / `somePast_mono` | **VALIDATED** — 13 live sites (not 14+2); must be `def` / `noncomputable def`, not `theorem` |
| 5 | `CanonicalTask_backward` collapse | **MOOT** — task 520 already Boneyarded the entire family. Drop from scope. |
| 6 | `DerivationTree.ofWeakeningNil` + BL twin | **VALIDATED** — compiles; modest gain (~3 lines × 2 sites) but removes a fragile duplicated scaffold |
| 7 | `mcs_auto` Aesop experiment | **RUN. NEGATIVE. Do not ship.** Fails the stated acceptance bar on both required targets. Details in §4. |
| 8 | `Core/README.md` refresh | Confirmed stale; directory has moved on again (now 2026-09-02) |

**One large opportunity the review missed**: the composite idiom
`implication_property h_mcs (theorem_in_mcs h_mcs <derivation>) hφ` occurs **197 times** in the
live tree. A one-line helper collapses each to a single application. This is a bigger, safer win
than anything in items 1–7 and is the thing `mcs_auto` was reaching for but could not deliver.

---

## 2. Drift audit of the MEASURED STATE claims

Task 520 (IteratedTemporal relocation + Bundle dead-half retirement), 524 and 525 have all landed
since the review was written. Each claim re-verified:

| Claim | Status | Live location |
|---|---|---|
| `restricted_lindenbaum` at `Basic.lean:316`, 59 lines | **HOLDS** | `:316–375`, 60 lines |
| `set_lindenbaum` at `MaximalConsistent.lean:303`, 50 lines | **HOLDS** | `:303–353`, 51 lines |
| `restricted_mcs_F_bounded` at `:488`, `_P_bounded` at `:593`, 154 lines total | **HOLDS (±2)** | `:486–554` (69) and `:591–660` (70) = **139** lines; plus `iter_F_bound :467` / `iter_P_bound :571` (9 each) = **157** total |
| `bot_not_in_mcs` proved 3× and never in `Core/` | **UNDERSTATED** | **4** proofs: `BXCanonical/TruthLemma.lean:69`, `WeakCanonical/TruthLemma.lean:57`, `Decidability/FMP/TruthPreservation.lean:94`, plus inlined at `Algebraic/FlowFrame.lean:695`. `Transfer.lean:455,892,986,1036` cross-reference confirmed. |
| `right_mono_until … Formula.top` inlined 14× in `Bundle/` + 2 in `RRelation` | **DRIFTED** | 6 of the 14 were in `Bundle/SuccRelation.lean`, **Boneyarded by task 520**. Live count is **13**: `Bundle/TemporalContent.lean:176,195,229,246`, `Bundle/WitnessSeed.lean:72,91,118,138`, `BXCanonical/Chronicle/RRelation.lean:1263,1286,1304,1346`, `WeakCanonical/ReflexiveCanonical.lean:212`. `fMono`/`pMono` at `TemporalDerived.lean:407,417`. |
| `CanonicalTask_backward` at `Bundle/CanonicalTaskRelation.lean:286` | **GONE** | Now `FormalSystem/Boneyard/BundleDeadHalf/CanonicalTaskRelation.lean` (task 520, commit `ab24de633`). The F-10 recommendation's own escape hatch ("the cheapest variant is to Boneyard it") was taken. |
| `weakening` scaffold at `Soundness.lean:1422-1429` and `BaseLanguageSoundness.lean:382-393` | **DRIFTED (file moved)** | `Soundness.lean:1274–1281`; the BL file is now `FormalSystem/Metalogic/Conservativity/BaseLanguageSoundness.lean:410–418`. `derivable_valid_and_swap_validIn` is `Soundness.lean:1217`; `soundness_in` is `:1289` (`induction d generalizing τ t` at `:1295`). Both idioms confirmed present and distinct. |
| MCS API: 869 call sites; 340/315/139/38/37 split | **HOLDS (860 live)** | `theorem_in_mcs`/`implication_property`/`negation_complete`/`closed_under_derivation`/`neg_excludes` = **860** occurrences outside `Boneyard/`. Zero `aesop` in `Core/`. |
| "five of the twenty longest proofs are `UltrafilterMCS.lean` membership bookkeeping" | **FALSE** | See §4.2 — those five proofs contain **one** MCS-API call between them. |

`IteratedTemporal.lean` (task 520) now lives at
`FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean` and is **already imported** by
`Core/RestrictedMCS/Basic.lean:12`. Item 2 is unblocked; no import work is needed.

---

## 3. Validated designs (items 1–6)

All snippets below **compile as written** against the live tree.

### 3.1 Item 1 — one Zorn lemma (B-11)

Drop the `A : Set Formula` parameter from the review's sketch; the maximality conclusion is fully
general and the closure restriction belongs in the instantiation, not the statement.

```lean
theorem exists_maximal_of_chainClosed {P : Set Formula → Prop}
    (hchain : ∀ C : Set (Set Formula), (∀ T ∈ C, P T) → IsChain (· ⊆ ·) C → C.Nonempty →
      P (⋃₀ C))
    {S : Set Formula} (hS : P S) :
    ∃ M : Set Formula, S ⊆ M ∧ P M ∧ ∀ ψ : Formula, ψ ∉ M → ¬ P (insert ψ M) := by
  let CS : Set (Set Formula) := {T | S ⊆ T ∧ P T}
  have hch : ∀ C ⊆ CS, IsChain (· ⊆ ·) C → C.Nonempty → ∃ ub ∈ CS, ∀ T ∈ C, T ⊆ ub := by
    intro C hCsub hCchain hCne
    refine ⟨⋃₀ C, ⟨?_, ?_⟩, fun T hT => Set.subset_sUnion_of_mem hT⟩
    · obtain ⟨T, hT⟩ := hCne
      exact Set.Subset.trans (hCsub hT).1 (Set.subset_sUnion_of_mem hT)
    · exact hchain C (fun T hT => (hCsub hT).2) hCchain hCne
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty CS hch S ⟨Set.Subset.refl S, hS⟩
  refine ⟨M, hSM, hmax.prop.2, ?_⟩
  intro ψ hψ hP
  exact hψ (hmax.le_of_ge ⟨Set.Subset.trans hSM (Set.subset_insert ψ M), hP⟩
    (Set.subset_insert ψ M) (Set.mem_insert ψ M))
```

`set_lindenbaum` (51 lines → 7):

```lean
theorem set_lindenbaum {fc : FrameClass} (S : Set Formula) (hS : SetConsistent (fc := fc) S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent (fc := fc) M := by
  obtain ⟨M, hSM, hM, hmax⟩ :=
    exists_maximal_of_chainClosed (P := SetConsistent (fc := fc))
      (fun _C hc hchain hne => consistent_chain_union hchain hne hc) hS
  exact ⟨M, hSM, hM, hmax⟩
```

`restricted_lindenbaum` (60 lines → 14). **Note the type mismatch B-11 correctly predicted**:
`RestrictedMCS`'s maximality field (`Basic.lean:78-80`) demands `¬SetConsistent (insert psi S)`,
while the generic lemma yields `¬RestrictedConsistent phi (insert psi S) fc`. The gap is exactly
the four-line closure-preservation obligation, which survives as the instantiation bridge:

```lean
theorem restricted_lindenbaum (phi : Formula) (S : Set Formula)
    (h_restricted : ClosureRestricted phi S) (h_cons : SetConsistent (fc := fc) S) :
    ∃ M : Set Formula, S ⊆ M ∧ RestrictedMCS phi M fc := by
  obtain ⟨M, hSM, hM, hmax⟩ :=
    exists_maximal_of_chainClosed (P := fun T => RestrictedConsistent phi T fc)
      (fun _C hc hchain hne => restricted_consistent_chain_union hchain hne hc)
      (⟨h_restricted, h_cons⟩ : RestrictedConsistent phi S fc)
  refine ⟨M, hSM, hM, ?_⟩
  intro psi h_psi_clos h_psi_not hcons_insert
  refine hmax psi h_psi_not ⟨?_, hcons_insert⟩
  intro chi h_mem
  cases Set.mem_insert_iff.mp h_mem with
  | inl h_eq => exact h_eq ▸ h_psi_clos
  | inr h_in => exact hM.1 h_in
```

**Deletable once this lands**: `ConsistentSupersets` (`MaximalConsistent.lean:286`),
`self_mem_consistent_supersets` (`:292`), `RestrictedConsistentSupersets` (`Basic.lean:274`),
`self_mem_restricted_consistent_supersets` (`:281`) — all four have **zero** consumers outside the
two Lindenbaum proofs. Net: **111 → 39 lines**, plus 4 dead definitions removed.

### 3.2 Item 2 — one boundedness lemma (B-12 / F-22)

**Finding that changes the recommendation**: `restricted_mcs_F_bounded`, `restricted_mcs_P_bounded`,
`restricted_mcs_iter_F_bound` and `restricted_mcs_iter_P_bound` are referenced **nowhere** —
not in `FormalSystem/`, not in `Tests/`, not in `docs/`. The only mentions outside their own
declarations are two source comments and one docstring cross-reference. Their docstrings advertise
them as "the key lemma for proving `f_nesting_is_bounded` in the `succ_chain_fam` construction";
`succ_chain_fam` lives in `FormalSystem/Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean`.
This is **157 lines of dead code**.

**Recommendation**: Boneyard all four. If the plan prefers to keep them (they are genuine facts
about `RestrictedMCS` and cheap to maintain once collapsed), the validated replacement is below —
139 lines of proof become 16 + 14 + 14 = 44, and the well-founded/truncated-subtraction plumbing
disappears entirely. The generic core is stated over a bare `Nat → Prop`, which is both simpler
than the review's `{it, b, op}` signature and reusable:

```lean
theorem exists_boundary_of_one {P : Nat → Prop} (h1 : P 1) (hesc : ∃ n, ¬ P (n + 1)) :
    ∃ d : Nat, d ≥ 1 ∧ P d ∧ ¬ P (d + 1) := by
  classical
  set k := Nat.find hesc with hk
  have hspec : ¬ P (k + 1) := Nat.find_spec hesc
  have hk1 : 1 ≤ k := by
    rcases Nat.eq_zero_or_pos k with h | h
    · rw [h] at hspec; exact absurd h1 (by simpa using hspec)
    · exact h
  refine ⟨k, hk1, ?_, hspec⟩
  have hmin := Nat.find_min hesc (m := k - 1) (by omega)
  have heq : k - 1 + 1 = k := by omega
  rw [heq, not_not] at hmin
  exact hmin

theorem restricted_mcs_F_bounded (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M fc) (h_F_in : Formula.someFuture phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iterF d phi ∈ M ∧ iterF (d + 1) phi ∉ M := by
  refine exists_boundary_of_one (P := fun n => iterF n phi ∈ M) ?_ ?_
  · simpa only [iter_F_one_eq_some_future] using h_F_in
  · refine ⟨closureFBound phi - 1, ?_⟩
    have hb : closureFBound phi - 1 + 1 = closureFBound phi := by
      unfold closureFBound; omega
    rw [hb]
    intro h_mem
    exact iter_F_leaves_closure phi (restricted_mcs_is_closure_restricted h_mcs h_mem)
```

`restricted_mcs_P_bounded` is the same 14 lines with `iterF→iterP`, `closureFBound→closurePBound`,
`iter_F_one_eq_some_future→iter_P_one_eq_some_past`, `iter_F_leaves_closure→iter_P_leaves_closure`
— and, unlike today, the *only* thing that differs is the four names. The two 9-line
`iter_*_bound` lemmas are absorbed into the `hesc` argument and can be deleted.

The `classical` tactic is required (`Nat.find` needs `DecidablePred`; `_ ∈ M` for `M : Set Formula`
is not decidable). No `open Classical` at module scope is needed.

### 3.3 Item 3 — one `bot_not_mem` (F-09)

The review's `SetMaximalConsistent.bot_not_mem` covers three of the four copies. The fourth
(`Decidability/FMP/TruthPreservation.lean:94`) is stated for a `ClosureMCSBundle`, which is *not* a
`SetMaximalConsistent` — but it reaches consistency through `closure_mcs_consistent`
(`ClosureMCS.lean:153`), which returns `SetConsistent`. State the lemma on `SetConsistent` and all
four fall out:

```lean
theorem SetConsistent.bot_not_mem {fc : FrameClass} {S : Set Formula}
    (h : SetConsistent (fc := fc) S) : Formula.bot ∉ S := by
  intro h_bot
  exact h [Formula.bot]
    (fun ψ hψ => by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hψ; rw [hψ]; exact h_bot)
    ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩

theorem SetMaximalConsistent.bot_not_mem {fc : FrameClass} {S : Set Formula}
    (h : SetMaximalConsistent (fc := fc) S) : Formula.bot ∉ S :=
  SetConsistent.bot_not_mem h.1
```

Home: `Core/MCSProperties.lean` (which already owns `negation_complete`, `implication_property`,
`neg_excludes`, `set_consistent_not_both`).

Then:
- delete `BXCanonical/TruthLemma.lean:69-77` and `WeakCanonical/TruthLemma.lean:57-64`;
- replace `Algebraic/FlowFrame.lean`'s inlined `| bot` branch (`:693-697`) with the call;
- replace `Decidability/FMP/TruthPreservation.lean:94-105` with
  `SetConsistent.bot_not_mem (closure_mcs_consistent S.is_mcs)`;
- re-point `WeakCanonical/Transfer.lean:455,892,986,1036` at `Core` — this is the change that
  removes the accidental `WeakCanonical → BXCanonical` dependency.

Note `WeakCanonical/TruthLemma.lean:57` takes `x : ReflCanDomain` (a subtype) and calls
`x.property`; the call sites there become `SetMaximalConsistent.bot_not_mem x.property`. There is
an unrelated `bot_not_mem_predFormulas` in `Transfer.lean:60` and an `Ultrafilter.bot_not_mem`
field in `Algebraic/UltrafilterMCS.lean:50` — neither collides (different namespaces).

### 3.4 Item 4 — `someFuture_mono` / `somePast_mono` (F-15)

**These must be `def`, not `theorem`** — `⊢[fc] φ` is `DerivationTree`, which is `Type`, not `Prop`
(`theorem` is rejected: *"type of theorem is not a proposition"*). And `somePast_mono` must be
`noncomputable def`, because `FormalSystem.Theorems.pastNecessitation` is noncomputable. This
asymmetry matters for `Automation/ProofStepExport.lean:60`'s "computable, suitable for
ProofStepExport" list — `someFuture_mono` qualifies, `somePast_mono` does not.

```lean
def someFuture_mono {fc : FrameClass} {φ ψ : Formula} (h : ⊢[fc] φ.imp ψ) :
    ⊢[fc] φ.someFuture.imp ψ.someFuture :=
  DerivationTree.modus_ponens [] _ _ (fMono φ ψ) (DerivationTree.temporal_necessitation _ h)

noncomputable def somePast_mono {fc : FrameClass} {φ ψ : Formula} (h : ⊢[fc] φ.imp ψ) :
    ⊢[fc] φ.somePast.imp ψ.somePast :=
  DerivationTree.modus_ponens [] _ _ (pMono φ ψ) (FormalSystem.Theorems.pastNecessitation _ h)
```

Home: `Theorems/TemporalDerived.lean`, directly below `fMono`/`pMono` (`:407`, `:417`).

Worked replacement, validated against `Bundle/WitnessSeed.lean:60-79` (14-line body → 4):

```lean
lemma some_future_all_future_neg_absurd {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) (psi : Formula)
    (h_F : Formula.someFuture psi ∈ M)
    (h_G_neg : Formula.allFuture (Formula.neg psi) ∈ M) : False := by
  have h_sf_nn : Formula.someFuture psi.neg.neg ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (someFuture_mono (Combinators.notNotIntro psi))) h_F
  exact set_consistent_not_both h_mcs.1 (Formula.someFuture psi.neg.neg) h_sf_nn h_G_neg
```

This also removes the `lift`-vs-`base_le` inconsistency F-15 flagged: the old body built at
`.Base` and applied `DerivationTree.lift (fc₁ := .Base) trivial`; `someFuture_mono` is already
`{fc}`-generic via `fMono`'s `FrameClass.base_le fc`, so the `lift` disappears.

**All 13 live sites** (see §2) use `Formula.top` as the third axiom argument, so all 13 are in
scope. Estimated reduction: 13 × ~9 lines ≈ **115 lines**.

### 3.5 Item 5 — `CanonicalTask_backward`: out of scope

Task 520 phase 4 (`ab24de633`, "retire the dead set and re-point the archive") moved the whole
family to `FormalSystem/Boneyard/BundleDeadHalf/CanonicalTaskRelation.lean`. F-10's own note
("this whole family is currently unconsumed outside its own file — so the cheapest variant is to
Boneyard it") has already been acted on. **Remove this item from the plan.** Touching the Boneyard
copy would be pure churn.

### 3.6 Item 6 — `DerivationTree.ofWeakeningNil` (A-14)

Validated:

```lean
def DerivationTree.ofWeakeningNil {fc : FrameClass} {Γ' : Context} {φ : Formula}
    (d : DerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : Context)) : DerivationTree fc [] φ :=
  (List.eq_nil_of_subset_nil h_sub) ▸ d

@[simp] theorem DerivationTree.height_ofWeakeningNil {fc : FrameClass} {Γ' : Context}
    {φ : Formula} (d : DerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : Context)) :
    (d.ofWeakeningNil h_sub).height = d.height := by
  have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
  subst h_eq
  rfl

theorem DerivationTree.height_ofWeakeningNil_lt {fc : FrameClass} {Γ' : Context}
    {φ : Formula} (d : DerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : Context)) :
    (d.ofWeakeningNil h_sub).height <
      (DerivationTree.weakening Γ' ([] : Context) φ d h_sub).height := by
  simp only [DerivationTree.height_ofWeakeningNil, DerivationTree.height]
  omega
```

Home: `ProofSystem/Derivation.lean`. The `Soundness.lean:1274-1281` arm becomes:

```lean
  | .weakening Gamma' _ _ d' h_sub =>
    have h_term := DerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact derivable_valid_and_swap_validIn (d'.ofWeakeningNil h_sub)
```

`h_term` must stay as a `have` — it is consumed implicitly by the `omega` in the file's
`decreasing_by` block (`Soundness.lean:1283-1287`), which reads it out of the local context. That
is the fragility A-14 names, and naming the height fact is what makes it survive a change to
`DerivationTree.height`.

**A BL twin is required, not optional**: `BaseLanguage.DerivationTree` is a *different inductive
type*; one lemma cannot cover both files. Write the mirror beside the BL derivation type and use it
at `Conservativity/BaseLanguageSoundness.lean:410-418`.

Net saving is small (~10 lines). The value is the removal of a duplicated, `omega`-dependent
termination scaffold from two files. **Do not attempt A-14's second half** (unifying
`soundness_in`'s `induction … generalizing` with `derivable_valid_and_swap_validIn`'s
`match`/`termination_by`) in this task: they have genuinely different statements
(`TruthAt` at a fixed history/time under a context hypothesis, versus a context-free `Valid`
pair), and the docstrings at `Soundness.lean:1252-1272` explain why the empty-context form is the
one the necessitation cases can consume. That is a separate, larger piece of work.

---

## 4. The `mcs_auto` experiment (D-12) — negative result

### 4.1 Mechanics discovered

**A named Aesop rule set cannot be declared and used in the same module.** Attempting it produces,
on every attribute and every call site:

```
error: no such rule set: 'MCS'
  (Use 'declare_aesop_rule_set' to declare rule sets.
   Declared rule sets are not visible in the current file; they only become visible once you
   import the declaring file.)
```

`declare_aesop_rule_sets` elaborates to a `meta initialize` block
(`.lake/packages/aesop/Aesop/Frontend/Command.lean:22-32`), which only takes effect at import time.
Aesop's own test suite is split for exactly this reason (`AesopTest/RuleSets0.lean` declares,
`RuleSets1.lean` attributes and uses). **So D-12's single `Core/MCSAesop.lean` is not implementable
— it needs two modules.** The `macro "mcs_auto"` itself is unaffected: it expands to
`aesop (rule_sets := [MCS])` at the use site and can live in the second module.

The named-rule-set part of D-12's rationale is sound: rules registered under `(rule_sets := [MCS])`
do not touch the default set, so this would *not* repeat the `AesopRules.lean` mistake (D-13).
Performance is also a non-issue: a three-step forward chain closes in **45 ms**.

### 4.2 The stated validation targets are both wrong

D-12 nominates `RestrictedMCS/Basic.lean:137` (`restricted_mcs_negation_complete`, 127 lines) and
"one `UltrafilterMCS` lemma", describing the latter as `have` chains that are "almost entirely
membership bookkeeping: get `φ ∈ S`, apply `implication_property`, split with `negation_complete`,
discharge with `neg_excludes`". Both descriptions are wrong about the live code:

- `restricted_mcs_negation_complete` (`Basic.lean:137-263`) contains **zero** uses of the five-lemma
  MCS API. It is a Lindenbaum-style argument over `deductionTheorem`, `DerivationTree.weakening`,
  `List.filter`, and `derivesBotFromPhiNegPhi`. There is nothing for an MCS rule set to fire on.
- The five `UltrafilterMCS.lean` hot spots (`:149`, `:259`, `:360`, `:674`, `:782`; 106 `have`s
  between them) contain **one** MCS-API call in total (a single `theorem_in_mcs` at `:149`). They
  are Boolean-algebra bookkeeping: `U.carrier`, `toQuot`, `List.foldl … ⊓ …`, `U.inf_mem`,
  `U.mem_of_le`.

Where the API is actually dense: `BXCanonical/Chronicle/PointInsertion.lean` (**146**
occurrences), `RRelation.lean` (103), `CounterexampleElimination.lean` (68),
`WeakCanonical/ReflexiveCanonical.lean` (67), `ChronicleToCountermodelBasic.lean` (57).

### 4.3 What the rule set can and cannot do

Rule set as specified in D-12 (`safe forward`: `implication_property`, `neg_excludes`,
`closed_under_derivation`, `theorem_in_mcs`; `unsafe 50%`: `negation_complete`;
`norm simp`: `Set.mem_insert_iff`, `Set.mem_singleton_iff`, `List.mem_cons`).

**Succeeds** on goals whose implications are already present as hypotheses:

| Goal | `mcs_auto` | plain `aesop` (control) |
|---|---|---|
| `(φ→ψ)∈S, (ψ→χ)∈S, φ∈S ⊢ χ∈S` | ✅ | ❌ *failed after exhaustive search* |
| `(φ→ψ)∈S, (ψ→χ)∈S, (χ→θ)∈S, φ∈S ⊢ θ∈S` | ✅ (45 ms) | ❌ |
| `φ.neg∈S, φ∈S ⊢ False` | ✅ | ❌ |
| `(φ→ψ)∈S, ψ.neg∈S ⊢ φ∉S` | ✅ | ❌ |

The control confirms the rule set is doing real work, not `simp`.

**Fails** on both real proofs from the tree that are *pure* MCS-API reasoning —
`PointInsertion.lean:227` `conj_mcs` (7-line body, 3 API calls) and its neighbour `or_elim_mcs`
(4-line body, 2 API calls):

```
error: Tactic `aesop` failed, made no progress
```

The reason is structural and not fixable by tuning. Both proofs turn on
`negation_complete h_mcs (φ.imp ψ.neg)` — the branching rule instantiated at a formula that does
not appear anywhere in the goal or context. Aesop has no way to synthesise it. Adding
`Formula.and`/`Formula.or` to the `norm simp` set (so the goal unfolds to `(φ.imp ψ.neg).neg ∈ A`)
does not help; Aesop still stops with the unfolded goal open. `negation_complete` is the only rule
in the set that could ever close a goal whose hypotheses are not already implication memberships,
and it is exactly the rule Aesop cannot instantiate.

The other two `safe forward` rules are inert for a related reason: `theorem_in_mcs` and
`closed_under_derivation` take a `DerivationTree fc [] φ` / `DerivationTree fc L φ` as an argument.
Registering them is harmless (verified: attributes elaborate, nothing breaks) but they can only fire
when such a derivation is already a local hypothesis, which is essentially never — in the dense
files the derivation is *constructed inline* at the point of use.

### 4.4 Verdict and the decision to record

The task's own bar is *"keep it only if it shortens BOTH"* targets. It shortens **neither**: one
target has no MCS-API content at all, and the other class of target fails outright. `mcs_auto`
would apply only to goals that are already one- or two-line `exact` terms.

**Recommendation: do not add `Core/MCSAesop.lean`.** Record the negative result in
`Core/README.md` with enough detail that it is not reopened:

> **MCS Aesop rule set — evaluated and rejected (2026-09-03).** A named `MCS` rule set
> (`safe forward`: `implication_property`, `neg_excludes`; `unsafe 50%`: `negation_complete`;
> `norm simp`: `Set.mem_insert_iff`, `Set.mem_singleton_iff`, `List.mem_cons`) was built and
> measured. It closes synthetic forward chains of implication memberships in ~45 ms, and plain
> `aesop` cannot. It closes **no** real proof in the tree. The blocker is structural:
> `negation_complete` is the only rule that helps a goal whose hypotheses are not already
> implication memberships, and Aesop cannot instantiate its `φ` (the real sites need it at a
> formula, e.g. `φ.imp ψ.neg`, that appears in neither goal nor context). `theorem_in_mcs` and
> `closed_under_derivation` are inert as forward rules because their `DerivationTree` argument is
> constructed inline at every real call site rather than being a hypothesis. Two further mechanics,
> if this is ever revisited: a rule set must be *declared in a separate imported module* from the
> one that attributes to it, and the named set does not pollute Aesop's default set.
> The productive consolidation at these sites is `SetMaximalConsistent.mp_of_theorem` (below), not
> automation.

---

## 5. New finding: the 197-site composite idiom

The pattern the dense files actually repeat is not a chain of memberships but

```lean
SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs <derivation>) hφ
```

typically spread over three or four lines. It occurs **197 times** in the live tree:

| File | Sites |
|---|---|
| `BXCanonical/Chronicle/PointInsertion.lean` | 34 |
| `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` | 25 |
| `BXCanonical/Chronicle/RRelation.lean` | 22 |
| `BXCanonical/CanonicalModel.lean` | 19 |
| `BXCanonical/Chronicle/CounterexampleElimination.lean` | 16 |
| `Bundle/WitnessSeed.lean` | 14 |
| `WeakCanonical/ReflexiveCanonical.lean` | 11 |
| `BXCanonical/Frame.lean` | 9 |
| 12 further files | 47 |

Validated helper (home: `Core/MCSProperties.lean`, beside `implication_property`):

```lean
/-- Modus ponens through an MCS against a *theorem* of the system. -/
theorem SetMaximalConsistent.mp_of_theorem {fc : FrameClass} {S : Set Formula} {φ ψ : Formula}
    (h : SetMaximalConsistent (fc := fc) S) (d : DerivationTree fc [] (φ.imp ψ))
    (hφ : φ ∈ S) : ψ ∈ S :=
  SetMaximalConsistent.implication_property h (theorem_in_mcs h d) hφ
```

`G_implies_F_mcs` (`PointInsertion.lean:376-406`, 31 lines, 14 API calls) is the showcase: six of its
`have`s are this idiom verbatim. Rewriting it with `mp_of_theorem` removes one nested application
and one line per site.

This is a mechanical, low-risk, high-count change, and it is the honest answer to the question
D-12 was asking. It is **not** currently in the task's planned work; the plan should add it, either
as its own phase or folded into the item-4 pass (both touch `Bundle/WitnessSeed.lean` and
`RRelation.lean`).

---

## 6. Risks, ordering, and territory

**File ownership.** These groups are disjoint and can be sequenced or parallelised freely:

| Group | Files touched |
|---|---|
| A (Zorn) | `Core/MaximalConsistent.lean`, `Core/RestrictedMCS/Basic.lean` |
| B (boundedness) | `Core/RestrictedMCS/Basic.lean` (+ `Boneyard/` if retired) |
| C (`bot_not_mem`) | `Core/MCSProperties.lean`, `BXCanonical/TruthLemma.lean`, `WeakCanonical/TruthLemma.lean`, `WeakCanonical/Transfer.lean`, `Algebraic/FlowFrame.lean`, `Decidability/FMP/TruthPreservation.lean` |
| D (`*_mono`) | `Theorems/TemporalDerived.lean`, `Bundle/TemporalContent.lean`, `Bundle/WitnessSeed.lean`, `BXCanonical/Chronicle/RRelation.lean`, `WeakCanonical/ReflexiveCanonical.lean` |
| E (`ofWeakeningNil`) | `ProofSystem/Derivation.lean`, `Metalogic/Soundness.lean`, `Metalogic/Conservativity/BaseLanguageSoundness.lean`, BL derivation module |
| F (`mp_of_theorem`) | `Core/MCSProperties.lean` + the 20 consumer files in §5 |
| G (docs) | `Core/README.md` |

A and B collide on `Core/RestrictedMCS/Basic.lean`; C and F collide on `Core/MCSProperties.lean`;
D and F collide on `Bundle/WitnessSeed.lean` and `RRelation.lean`. Order A→B, C→F, D→F, or serialise
those pairs.

**Build cost.** `Core/MCSProperties.lean` and `ProofSystem/Derivation.lean` are near the root of the
import graph; editing either invalidates most of the tree. Group E in particular forces a
near-full rebuild. Every `lake build` must be detached and guarded
(`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- <args>` under
`Bash(run_in_background: true)`) per `context/project/lean4/operations/long-builds.md`.

**Zero-debt.** No step here needs a `sorry` or a new axiom; every replacement was compiled end to
end. The tree's structural-`sorry` count is 0 and must stay 0.

**C2 baseline.** None of these changes touch an axiom or a flagship theorem's statement, so
`scripts/check-module-invariants.sh`'s C2 axiom sets should be unchanged. Run it after group E
specifically — that group edits `soundness_in`'s sibling recursion, which is on the flagship path.

**Item 8 detail.** `Core/README.md:162` still says *Last verified: 2026-05-29*. The directory has
moved again since the review measured it: `MCSProperties.lean` is dated 2026-09-02 and the README
itself 2026-09-01. Whoever refreshes it should also record the §4.4 `mcs_auto` decision there.

---

## 7. Acceptance-criteria mapping

| Acceptance criterion | Delivered by | Status |
|---|---|---|
| One Zorn lemma | Group A | validated §3.1 |
| One iteration-boundedness lemma | Group B | validated §3.2 (or retire as dead) |
| One `bot_not_mem` in the live tree | Group C | validated §3.3 (4 copies, not 3) |
| Zero inline `right_mono_until`-with-top idioms in `Bundle/` | Group D | validated §3.4; 8 of the 13 live sites are in `Bundle/` |
| `Transfer.lean` no longer imports BXCanonical for a one-liner | Group C | 4 call sites re-pointed |
| `mcs_auto` decision recorded | Group G | §4.4 supplies the text; **decision is: reject** |
| `lake build` green | all groups | detached + guarded builds required |
| C2 baseline unchanged | all groups | no axiom/statement changes; verify after group E |

Two acceptance items need the plan amended rather than executed as written: item 5
(`CanonicalTask_backward`) is already done by task 520 and should be struck, and the `mcs_auto`
acceptance is satisfied by recording a *negative* decision, not by shipping the tactic.
