# Frame-Class Uniformity: Research Report

**Task**: 450 — frame_class_parameterization_restricted_mcs
**Session**: sess_1787033965_d6c07f_450
**Date**: 2026-08-18
**Status**: researched

---

## Executive Summary

Every machine-checked claim the task description rests on is **confirmed**, and the two
highest-risk deliverables — (a) the parameterisation and (c) the Discrete consistency lemma —
were both **spiked to a green build during this research**, not merely argued for.

Three findings change the shape of the plan:

1. **The description's spelling of deliverable (a) does not compile.** `{fc : FrameClass :=
   FrameClass.Base}` is a **syntax error** in Lean 4 — `optParam` is not permitted on implicit
   binders. The working spelling is a **trailing explicit** `(fc : FrameClass :=
   FrameClass.Base)` on definitions, with **leading implicit `{fc : FrameClass}`** on theorems
   (inferred from the hypothesis). Both leading-explicit optParam and `variable`-level optParam
   were tested and **fail**. See §3.

2. **The real generalisation surface is ~4x the description's estimate, and grep cannot see
   it.** `⊢ φ` is itself a Base pin: `notation:50 "⊢ " φ => DerivationTree FrameClass.Base [] φ`
   (`ProofSystem/Derivation.lean:330`). The 668-occurrence census counts only *grep-visible*
   `FrameClass.Base` tokens. Counting declarations instead, `FormalSystem/Theorems/` holds
   **244 declarations, 202 of them Base-pinned** — against the 32 grep hits the description
   cites for the same files. A polymorphic sibling notation `⊢[fc] φ` already exists
   (`Derivation.lean:320`), so the fix is mechanical but touches ~2,300 turnstile sites. See §4.

3. **Deliverable (a) is a pure mechanical transform with zero proof repair.** The full
   generalisation of `Core/RestrictedMCS/Basic.lean` (662 lines, 23 Base occurrences, including
   the 9-occurrence `restricted_mcs_negation_complete`) compiles with **zero errors**, and the
   entire downstream FMP layer rebuilds **unchanged**. See §5 — this is the single most
   plan-relevant result in this report.

---

## 1. Verification of the Description's Premises

### 1.1 The Base pin is the anomaly (CONFIRMED)

`SetConsistent` is already frame-class polymorphic:

```lean
-- Core/MaximalConsistent.lean:96
def SetConsistent {fc : FrameClass} (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent (fc := fc) L
```

and `RestrictedConsistent` / `RestrictedMCS` pin it for no reason:

```lean
-- Core/RestrictedMCS/Basic.lean:71-80
def RestrictedConsistent (S : Set Formula) : Prop :=
  ClosureRestricted phi S ∧ SetConsistent (fc := FrameClass.Base) S

def RestrictedMCS (S : Set Formula) : Prop :=
  RestrictedConsistent phi S ∧
  ∀ psi ∈ closureWithNeg phi, psi ∉ S → ¬SetConsistent (fc := FrameClass.Base) (insert psi S)
```

Line numbers in the description (:72, :80) are off by one against the current tree (:71, :78);
the content matches exactly.

Stronger than the description claims: **the entire MCS core is already polymorphic.**
`MaximalConsistent.lean` (`Consistent`, `SetConsistent`, `SetMaximalConsistent`,
`set_lindenbaum`, `consistent_chain_union`) and `MCSProperties.lean` (`closed_under_derivation`,
`implication_property`, `negation_complete`, …) take `{fc : FrameClass}` on **every**
declaration. All 12 `FrameClass.Base` hits across those two files are **stale prose in
docstrings**, describing generic code as Base-only. Nothing downstream is *forced* to Base;
every pin in the tree is a caller-side choice.

### 1.2 The filteredStep_fwd falsity result (CONFIRMED, re-verified)

The evidence file lives at
`specs/archive/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`
(the 417 task directory has been **archived**; the description's un-archived paths no longer
resolve). I recompiled it against the current tree with `lake env lean`. It compiles clean, and
all 9 audited declarations report:

```
'Spike417.succIndicator'            depends on axioms: [propext, Classical.choice, Quot.sound]
'Spike417.unfoldForward'            … same
'Spike417.unfoldBackward'           … same
'Spike417.noBlockingTriple'         … same
'Spike417.nextConj'                 … same
'Spike417.unfoldTableForward'       … same
'Spike417.unfoldTableBackward'      … same
'Spike417.filteredStep_fwd_fails'   … same
'Spike417.filteredStep_not_universal' … same
```

**No `sorryAx`.** The obstruction argument is sound and current.

### 1.3 Incomparability of Discrete and Dedekind (CONFIRMED)

`ProofSystem/Axioms.lean` (the description's :511-517 is now ~:505-517) states it explicitly and
gives the reason: the intersection theory `Th(ℤ) ∩ Th(ℝ)` is not itself a frame class, and
adding one would require an axiom set the tree does not have. `FrameClass.base_le` (:600) makes
`Base ≤ fc` trivially true for all `fc`, which is exactly why the Base pins buy nothing.

### 1.4 Verification-contract corrections (BOTH the description AND the team-lead correction are stale)

I ran the full harness. **Everything is green:**

```
PASS  C1   lake build exits 0
PASS  C1   lake build BimodalTest exits 0
PASS  C2   all four flagship axiom sets match baseline
PASS  C3   sole structural sorry is countermodel_discrete (WeakCanonical/Transfer.lean)
PASS  C4   all 1371 import lines resolve
PASS  C5   all module-shaped paths in 1658 markdown files resolve
PASS  C6   all 37 unreachable live modules are manifested; all 35 manifested still compile
PASS  C7   447 live .lean files (393 FormalSystem / 53 Tests)
PASS  C8   every subdirectory has exactly one sibling aggregator
PASS  C9   zero task-number citations under FormalSystem/
PASS  C10  zero references to FormalSystem/{docs,latex,typst} outside specs/
ALL CHECKS PASSED
```

- The description's claimed pre-existing RED (C6, C9, BimodalTest `#guard_msgs` drift) is
  **gone** — task 453 is `completed` in `state.json` and fixed all three.
- **The description's C6 claim was misattributed in the first place.** It describes C6 as
  "`SoundnessLemmas/CoValidity.lean:104 simp made no progress`". C6 is the
  *unreachable-module-manifest* check; it never reported that. There is no live `simp`-failure
  in `CoValidity.lean` today. The in-scope-if-frame-class-related clause is therefore **moot** —
  there is nothing to fix.
- Baseline for this task is: **all ten check groups PASS, exactly 1 live sorry.**

---

## 2. Deliverable (c): the Discrete Consistency Lemma — MACHINE-CHECKED ✅

This is the description's designated *first* lemma. The proposed route works, with **one
addition the description does not mention**.

**Verified proof** (compiled via `lake env lean`, sorry-free):

```lean
import FormalSystem.Metalogic.Soundness
import Mathlib.Data.Int.SuccPred          -- ← REQUIRED, and NOT currently imported by Soundness.lean

theorem not_derivable_nil_bot_discrete :
    ¬ Derivable FrameClass.Discrete [] Formula.bot := by
  rintro ⟨d⟩
  obtain ⟨τ⟩ :=
    TaskFrame.hF_nonempty_of_frameAxioms (D := ℤ) TaskFrame.trivialFrame
  exact Truth.bot_false
    (FormalSystem.Metalogic.soundness_discrete_valid d ℤ TaskFrame.trivialFrame
      TaskModel.allFalse τ.val τ.property 0)
```

```
'not_derivable_nil_bot_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**The import is load-bearing.** My first attempt — with only
`import FormalSystem.Metalogic.Soundness`, matching where `not_derivable_nil_bot` already lives —
**failed to synthesize `SuccOrder ℤ` and `PredOrder ℤ`**, which `ValidDiscrete`'s binder list
requires:

```lean
def ValidDiscrete (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D] …
```

`Semantics/Validity.lean` imports `Mathlib.Order.SuccPred.Basic` and `.Archimedean` (the
*classes*) but not `Mathlib.Data.Int.SuccPred` (the *ℤ instances*). Adding that one import to
`Soundness.lean` is the whole fix; the tree already imports it in five other places
(`BXCanonical/Completeness.lean`, `WeakCanonical/Transfer.lean`,
`Decidability/Verified/Bridge/Embed.lean`, `Semantics/IntNormalForm.lean`,
`Examples/TemporalStructures.lean`).

**Naming**: `not_derivable_nil_bot_discrete` mirrors the existing `not_derivable_nil_bot`
(`Soundness.lean:1969`) and its `¬ Derivable …` rather than `Consistent []` phrasing, for the
same import-graph reason given in that theorem's docstring.

The structure follows the spike's `dense_consistent` (evidence file :547) exactly, with `ℚ` → `ℤ`
and `soundness_dense_valid` → `soundness_discrete_valid`.

---

## 3. Deliverable (a): How to Spell the Parameterisation

The description says "parameterise by `{fc : FrameClass}`, **defaulting to Base**". Taken
literally that does not compile. I tested four spellings:

| Spelling | Result |
|---|---|
| `{fc : FrameClass := FrameClass.Base}` (implicit + optParam) | ❌ **syntax error**: `unexpected token ':='; expected '}'` |
| `(fc : FrameClass := FrameClass.Base)` **leading** explicit | ❌ positional args misassign: `argument phi … expected optParam FrameClass` |
| `variable (fc : FrameClass := FrameClass.Base)` | ❌ same failure — `variable` inserts fc *first* |
| `(fc : FrameClass := FrameClass.Base)` **trailing** explicit | ✅ **works** |

**The working design**, verified end-to-end:

```lean
-- DEFINITIONS: trailing explicit optParam
def RestrictedConsistent (S : Set Formula) (fc : FrameClass := FrameClass.Base) : Prop :=
  ClosureRestricted phi S ∧ SetConsistent (fc := fc) S

def RestrictedMCS (S : Set Formula) (fc : FrameClass := FrameClass.Base) : Prop :=
  RestrictedConsistent phi S fc ∧
  ∀ psi ∈ closureWithNeg phi, psi ∉ S → ¬SetConsistent (fc := fc) (insert psi S)

-- THEOREMS: leading implicit, inferred from the hypothesis
variable {phi : Formula} {fc : FrameClass}

theorem restricted_consistent_is_consistent {S : Set Formula}
    (h : RestrictedConsistent phi S fc) : SetConsistent (fc := fc) S := h.2
```

Elaboration behaviour, all verified:

- Legacy call site `RestrictedConsistent phi S` → `fc` defaults to `Base`. **Unchanged.**
- Legacy `restricted_consistent_is_consistent h` → `{fc}` unifies to `Base` from `h`. **Unchanged.**
- New positional `RestrictedMCS phi S FrameClass.Discrete` → works.
- New named `RestrictedMCS phi S (fc := FrameClass.Discrete)` → works.

Resulting signature: `@RestrictedMCS : Formula → Set Formula → optParam FrameClass FrameClass.Base → Prop`.

**Precedent in-tree**: `FMCSDef.lean:103` `structure FMCS (fc : FrameClass := FrameClass.Base)`,
`BFMCS.lean:91`, `TemporalCoherence.lean:158`, `ReflexiveCanonical.lean:45` already use optParam
— but all with `fc` as the *sole or first* parameter, where leading and trailing coincide. They
are not counterexamples to the ordering constraint above.

---

## 4. The Hidden Surface: `⊢` Is Itself a Base Pin

`ProofSystem/Derivation.lean` declares both a polymorphic and a pinned turnstile:

```lean
notation:50 "⊢[" fc "] " φ => DerivationTree fc [] φ      -- :320  polymorphic
notation:50 Γ " ⊢ "  φ     => DerivationTree FrameClass.Base Γ φ  -- :325  PINNED
notation:50 "⊢ "     φ     => DerivationTree FrameClass.Base [] φ -- :330  PINNED
```

`Derivable.lean:87,92` mirrors this for `|-!`. **A declaration written with bare `⊢` is
Base-pinned and produces no `FrameClass.Base` grep hit.** The 668-occurrence census therefore
undercounts the deliverable-(e) surface by roughly 4x.

Repo-wide (FormalSystem, non-Boneyard): **2,316 bare `⊢ `** vs **355 `⊢[`** vs 19 bare `|-!`.

Declaration-level count for `FormalSystem/Theorems/` — the actual deliverable (e) surface:

| File | decls | already `{fc}` | **Base-pinned** |
|---|---:|---:|---:|
| TemporalDerived.lean | 45 | 0 | **45** |
| ContextualProofs.lean | 72 | 1 | **71** |
| Perpetuity/Principles.lean | 20 | 0 | **20** |
| Perpetuity/MonotonicityDuality.lean | 19 | 0 | **19** |
| Propositional/Core.lean | 15 | 5 | **10** |
| Propositional/Connectives.lean | 14 | 0 | **14** |
| ModalS5.lean | 12 | 0 | **12** |
| ModalS4.lean | 4 | 0 | **4** |
| Propositional/Reasoning.lean | 4 | 0 | **4** |
| Perpetuity/Helpers.lean | 6 | 3 | **3** |
| Combinators.lean | 12 | 12 | 0 |
| DedekindDerived.lean | 15 | 15 | 0 |
| GeneralizedNecessitation.lean | 6 | 6 | 0 |
| **Total** | **244** | **42** | **202** |

Named confirmation of the description's "half polymorphic" claim for `Propositional/Core.lean`:

- Already `{fc}`: `efqAxiom` (:77), `peirceAxiom` (:88), `doubleNegation` (:135), `lceImp` (:650), `rceImp` (:668)
- Base-pinned: `em` (:55), `botOfAndNeg` (:205), `impNegImp` (:257), `impOfNeg` (:326), `negImp` (:342), `orInl` (:354), `orInr` (:406), `impOfNegImpNeg` (:438), `andLeft` (:513), `andRight` (:582)

`Propositional/Connectives.lean` is **0/14 polymorphic** — all 14 pinned (`classicalMerge`,
`iffIntro`, `iffElimLeft`, `iffElimRight`, `contraposeImp`, `contraposition`, `contraposeIff`,
`iffNegIntro`, the four De Morgan forward/backward pairs, `demorganConjNeg`, `demorganDisjNeg`).

`DedekindDerived.lean` is the model to copy: all 15 declarations `{fc}`-polymorphic, with
`co_derived` (:406) taking an explicit `(h_fc : FrameClass.Dedekind ≤ fc)` where the class is
genuinely needed, and a `baseThm` lift helper (:83) using `FrameClass.base_le`. Its 4 grep hits
are 3 docstrings + that helper.

### 4.1 Triplicated combinators — a concrete consolidation target

The description's claim that the spike "had to rebuild orElim/andIntro/guardMono/eventMono from
scratch" understates it. There are now **three** copies of the same polymorphic combinators:

- `Theorems/DedekindDerived.lean` has `topThm` (:87), `andIntro` (:100), `orElimBot` (:116) —
  but declared **`private`**, so nothing else can use them.
- The spike file re-derives `topThm`, `andIntro`, `orIntroL/R`, `orElim`, `guardMono`, `eventMono`.
- `guardMono`, `eventMono`, `orIntroL`, `orIntroR` exist **nowhere** in the live tree.

Promoting these (de-`private`-ising the DedekindDerived set and lifting the spike's) is the
natural companion to deliverable (d).

---

## 5. Deliverable (a) Spiked to Green — the Key Result

I mechanically generalised the whole of `Core/RestrictedMCS/Basic.lean` (662 lines) using the
§3 design and compiled it.

**Transform applied** (fully mechanical, no proof edits):
1. Three defs (`RestrictedConsistent`, `RestrictedMCS`, `RestrictedConsistentSupersets`) gain a
   trailing `(fc : FrameClass := FrameClass.Base)`.
2. `SetConsistent (fc := FrameClass.Base)` → `SetConsistent (fc := fc)`.
3. Applications gain an `fc` argument.
4. Remaining `FrameClass.Base` in proof bodies → `fc` (14 sites, incl. all 9 in
   `restricted_mcs_negation_complete` and the `DerivationTree.axiom (fc := …)` in
   `restricted_mcs_from_formula`).
5. `variable {phi : Formula}` → `variable {phi : Formula} {fc : FrameClass}`.

**Result — standalone compile:**

```
Basic_gen.lean:415:4: warning: Try this: intro L hL ⟨d⟩
```

**Zero errors.** The single warning is pre-existing (it is at :414 in the untouched original,
shifted one line by the added binder).

**Result — downstream regression firewall.** I temporarily applied the generalisation to the
real file and ran the description's named check:

```
⚠ [1370/1375] Built FormalSystem.Metalogic.Core.RestrictedMCS.Basic (1.1s)
✔ [1371/1375] Built FormalSystem.Metalogic.Decidability.FMP.ClosureMCS (983ms)
✔ [1372/1375] Built FormalSystem.Metalogic.Decidability.FMP.Filtration (1.1s)
✔ [1373/1375] Built FormalSystem.Metalogic.Decidability.FMP.FiniteModel (1.0s)
✔ [1374/1375] Built FormalSystem.Metalogic.Decidability.FMP.TruthPreservation (1.0s)
⚠ [1375/1375] Built FormalSystem.Metalogic.Decidability.FMP.FMP (1.0s)
Build completed successfully (1375 jobs).   exit 0
```

**The entire FMP layer rebuilt with zero source changes.** Default-to-Base is confirmed as a
working regression firewall, and deliverable (b) — preserving
`mcs_finite_model_property` / `fmp_contrapositive` / `fmp_size_bound` verbatim — is satisfied
*automatically*, since those three keep their explicit `¬Derivable FrameClass.Base [] phi`
statements untouched.

**The working tree was reverted; `git diff` on the file is empty.** Nothing from this spike is
left in the repository.

---

## 6. Repo-Wide Audit (deliverable (f), first pass)

Classification of all 522 grep-visible `FrameClass.Base` occurrences under `FormalSystem/`
(the 670 repo-wide total is 522 FormalSystem + 148 Tests). Categories: **(i)** legitimately
Base-specific, **(ii)** gratuitous pin, **(iii)** structural/definitional, **(iv)** doc/comment.

| Group | total | (i) legit | (ii) gratuitous | (iii) structural | (iv) doc |
|---|---:|---:|---:|---:|---:|
| Theorems/ | 32 | 0 | **28** | 1 | 3 |
| Metalogic/Bundle/ | 92 | 0 | **75** | 12 | 5 |
| Metalogic/BXCanonical/ | 138 | 4 | **112** | 11 | 11 |
| Metalogic/Algebraic + WeakCanonical/ | 134 | 0 | **126** | 5 | 3 |
| Metalogic/Decidability/ | 51 | 6 | **33** | 5 | 7 |
| Everything else | 75 | 16 | 19 | 8 | **32** |
| **Total** | **522** | **26** | **393** | **42** | **61** |

**~75% (393/522) are gratuitous** — and this counts only grep-visible tokens; §4 shows the true
figure is far higher once `⊢` is included.

### Root pins (fixing these cascades)

| Root | Site | Unlocks |
|---|---|---|
| `⊢` / `Γ ⊢` / `|-!` notations | `Derivation.lean:325,330`; `Derivable.lean:87,92` | ~202 decls in Theorems/ + all grep-invisible pins tree-wide |
| `RestrictedConsistent` / `RestrictedMCS` | `RestrictedMCS/Basic.lean:71,78` | 19 in Core/ + the Decidability/FMP layer (33) — **spiked green, §5** |
| `BXPoint.is_mcs` field + chain defs | `BXCanonical/Frame.lean:61`; `CanonicalModel.lean` | ~120 in BXCanonical/ |
| `Derives` + `mcsToUltrafilter`/`ultrafilterToMcs` | `LindenbaumQuotient.lean:46`; `UltrafilterMCS.lean:524,970` | ~90 in Algebraic/ |
| `lindenbaumMCS` / `LindenbaumMCSSet` | `Bundle/Construction.lean:113,143` | most of Bundle/ (75) |

### Category (i) — leave pinned

`Soundness.lean` (`soundness`, `not_derivable_nil_bot`, `axiom_valid`);
`SoundnessLemmas/FrameClassVariants.lean` (6 × `minFrameClass ≤ Base` admissibility splits);
`FrameConditions/Soundness.lean` + `Compatibility.lean`; `Axioms.lean:600` `FrameClass.base_le`;
`BXCanonical/Completeness.lean` `completeness`; `Decidability/ProofExtraction.lean` (4
`minFrameClass ≤ Base` guards); `Decidability/Correctness.lean` `fmp_completeness` /
`fmp_incompleteness_witness`. These state facts *about* the Base system and must not drift —
same rationale as deliverable (b).

### Category (iv) — cheap but actively misleading

`Core/MCSProperties.lean` (6) and `Core/MaximalConsistent.lean` (6) are **100% stale prose**:
docstrings saying "Base" on declarations that are already fully `{fc}`-generic. Zero code change;
high documentation value.

### Already-duplicated code the pin caused

`BXCanonical/CanonicalModel.lean:426` carries the comment *"The existing chain (FwdSucc,
BwdPred, IntChain, etc.) is hardcoded to FrameClass.Base"*, and :544-572 define parallel
`fwdChainFc` / `bwdChainFc` / `IntChainFc` / `FwdSuccFc` / `BwdPredFc` twins with `fc` free.
Generalising the originals lets the twins be **deleted**.

### Non-cosmetic limitation worth flagging

`Automation/Tactics/Helpers.lean:1010,1062` hardcode `mkConst ``FrameClass.Base`` when building
K-distribution terms. `tryModalK` / `tryTemporalK` therefore **cannot fire at non-Base classes**
— a real capability gap, not a naming issue. Recommend deferring with a reason (category iii/
deliberate), since fixing it is metaprogramming work orthogonal to the rest.

---

## 7. Deliverable (d): Promotion Inventory

All 7 named targets are sorry-free in the evidence file and **absent from the live tree** (0
occurrences each for `succIndicator`, `nextConj`, `unfoldTableForward`, `unfoldTableBackward`,
`unfoldForward`, `unfoldBackward`, `noBlockingTriple`).

| Declaration | Evidence line | Class |
|---|---:|---|
| `nxt` (= `Formula.next`) | :61 | — (abbreviation) |
| `succIndicator` | :191 | `⊢[FrameClass.Discrete]` |
| `unfoldForward` | :212 | Discrete |
| `unfoldBackward` | :280 | Discrete |
| `nextConj` | :303 | `{fc}` polymorphic |
| `unfoldTableForward` | :347 | Discrete |
| `unfoldTableBackward` | :369 | Discrete |
| `noBlockingTriple` | :398 | Discrete |

Polymorphic plumbing to promote alongside (evidence :66-186): `necG`, `wk`, `topThm`,
`andIntro`, `orIntroL`, `orIntroR`, `orElim`, `guardMono`, `eventMono`, `topNegImpBot`,
`untlBotFalse` — all `{fc}`.

**Recommendation**: new file `FormalSystem/Theorems/DiscreteUnfolding.lean` (does not exist) for
the Discrete-specific schema; route the polymorphic plumbing into
`Theorems/Propositional/Core.lean` and `Theorems/Combinators.lean` where its siblings already
live, rather than duplicating a fourth time. **Note**: `Theorems/` has a sibling-aggregator
invariant (check C8) — a new file must be added to the `Theorems.lean` aggregator.

**Argument-order caution**: the evidence file is **guard-first / event-second**
(`Formula.untl g e`), per `specs/decisions/untl-snce-argument-order.md` (DECIDED 2026-08-17).
The pretty-printer renders event-first `U(e,g)`. Promotion must preserve the constructor order,
not the rendering.

---

## 8. Recommended Phasing

Sized so each phase is one agent run and ends at a green `lake build`.

| Phase | Content | Risk | Evidence |
|---|---|---|---|
| **1** | **(c)** `not_derivable_nil_bot_discrete` in `Soundness.lean` + `import Mathlib.Data.Int.SuccPred`. **Must be first** — everything else is vacuous without it. | **none** | §2, compiled |
| **2** | **(a)** Generalise `Core/RestrictedMCS/Basic.lean` per §3/§5. Verify with `lake build FormalSystem.Metalogic.Decidability.FMP.FMP`. | **none** | §5, compiled + downstream green |
| **3** | **(a)** cont. — `closure_mcs_deductively_closed` (`FMP/ClosureMCS.lean:171`) and the rest of `Decidability/FMP/*` (33 gratuitous). **(b)** is satisfied by construction: leave the three FMP theorem statements untouched. | low | §5 shows layer rebuilds clean |
| **4** | **(d)** Promote the spike schema + plumbing; de-`private` the `DedekindDerived` combinators; wire the aggregator (C8). | low | §7, evidence recompiles clean |
| **5** | **(e)** `Theorems/Propositional/{Core,Connectives}.lean` — 24 decls, `⊢` → `⊢[fc]`. The largest *behavioural* win: unblocks library reuse. | medium | §4 |
| **6** | **(e)** `ModalS5` (12), `ModalS4` (4), `Propositional/Reasoning` (4). | medium | §4 |
| **7** | **(e)** `TemporalDerived` (45), `ContextualProofs` (71), `Perpetuity/*` (42) — the long tail. **Splittable**; a legitimate deferral point if budget runs out. | medium | §4 |
| **8** | **(f)** Final audit table + docstring sweep for category (iv), incl. the 12 misleading `Core/` docstrings. | none | §6 |

**Scope note for the planner.** Phases 1-4 are demonstrated-green and cover everything task 417's
Task B needs to unblock. Phases 5-7 are the discipline pass, and phase 7 alone is ~158
declarations — larger than phases 1-6 combined. The description explicitly forbids treating this
as a minimal patch, so phases 5-7 belong in the plan; but they are the natural place to split a
follow-up task if the budget binds. **Deliverable (f) must then classify the deferred remainder
as category (iii) with a reason**, which is exactly what the description permits.

**Groups B/C/D of §6 (Bundle, BXCanonical, Algebraic — 364 occurrences, ~313 gratuitous) are not
scheduled above.** The description's known-defect list names them, but they are far larger than
the named deliverables and touch the canonical-model construction, which the FMP work does not
depend on. **Recommend explicitly deferring them in the audit table with a reason**, rather than
silently omitting them or attempting them under this task.

---

## 9. Zero-Debt Compliance

No approach in this report requires `sorry`, a new axiom, or a weakened statement:

- Deliverable (c) compiles sorry-free (axioms: `propext`, `Classical.choice`, `Quot.sound`).
- Deliverable (a) compiles with zero errors and zero proof repair.
- Deliverable (b) is satisfied by construction — the three preserved theorems are not edited.
- Deliverable (d) promotes declarations already audited sorry-free.

Repository live-sorry count must stay at exactly **1** (`countermodel_discrete`,
`WeakCanonical/Transfer.lean`), verified via `scripts/check-module-invariants.sh` (check C3),
never naive grep.

---

## 10. Artifacts and Commands

**Referenced files** (absolute):
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean` — deliverable (a) primary target
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Core/MaximalConsistent.lean` — already polymorphic; 6 stale docstrings
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Soundness.lean` — deliverable (c) home
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/ProofSystem/Derivation.lean` — the `⊢` notation root pin
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Semantics/Validity.lean` — `ValidDiscrete` binder list
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/FMP/FMP.lean` — deliverable (b) preserved theorems
- `/home/benjamin/Projects/BimodalLogic/specs/archive/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean` — deliverable (d) source

**Reproduction commands**:
```bash
lake env lean specs/archive/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean
bash scripts/check-module-invariants.sh
lake build FormalSystem.Metalogic.Decidability.FMP.FMP
```

**Scratch spikes** (outside the repo, in the session scratchpad — not deliverables):
`discrete_consistent.lean`, `design_probe2.lean`, `Basic_gen.lean`.
