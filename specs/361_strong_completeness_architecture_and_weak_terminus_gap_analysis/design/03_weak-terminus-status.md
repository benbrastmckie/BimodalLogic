# Design: verified weak-terminus status and the Base route analysis

**Source**: `reports/01_strong-completeness-architecture-gap-analysis.md` §1 and §4 (authoritative),
**re-verified against the live tree in this session** — see §1 and §7 for two divergences found.
**Status**: analysis document. **Nothing in this document exists in the tree.**
**Intended consumers**: tasks 169 and 170, and the spawned tasks N1 (symbolic `B0`+`B1`) and
N2 (symbolic `B2`+`B3`).

---

## STANDING CONSTRAINT BANNER

> Every Lean fragment in this document is a **design proposal held inside a `specs/` document**,
> not a tree edit. At the time of writing, a separate session owns task 418 and holds the
> advisory build lock `.lake/.task-418-build.lock`. While that lock is held:
>
> - **MUST NOT** run `lake build`, `lake clean`, `lake exe`, or the `lean_build` MCP tool.
> - **MUST NOT** create, edit, or delete any file under `FormalSystem/` or `Tests/`.
> - **PERMITTED**: read-only `lean-lsp` queries and `Read`/`Grep`/`Glob` over the tree.
>
> The downstream implementer inherits this constraint **only if the lock is still held** when
> the task is dispatched. Check `.lake/.task-418-build.lock` before assuming it applies.

---

## 1. Machine-checked axiom sets

All three rows below were obtained **in this session** by `lean_verify` against current oleans —
not read off the file's own comments, and not copied from the research report. The `Completeness.lean`
import cone was unmodified in the working tree at the time (`git status --short -- FormalSystem/`
was empty).

| Declaration | Location | `#print axioms` (verified this session) | Verdict |
|---|---|---|---|
| `FormalSystem.Metalogic.BXCanonical.completeness_dense` | `Metalogic/BXCanonical/Completeness.lean:255` | `["propext", "Classical.choice", "Quot.sound"]` | **sorry-free** |
| `FormalSystem.Metalogic.BXCanonical.completeness_discrete` | `.../Completeness.lean:296` | `["propext", "Classical.choice", "Quot.sound"]` | **sorry-free** |
| `FormalSystem.Metalogic.BXCanonical.completeness` | `.../Completeness.lean:196` | `["propext", "sorryAx", "Classical.choice", "Quot.sound"]` | **1 sorry** |

Note the strengthening over the research report: the report obtained rows 1 and 3 by `lean_verify`
and took row 2 (`completeness_discrete`) from the file's in-file audit comment. **This session
verified all three by `lean_verify`**, so `completeness_discrete` is now machine-confirmed rather
than comment-attested.

---

## 2. Live-sorry inventory — and a DIVERGENCE from the report

### 2.1 The re-scan, and its raw output

Per the plan's Scope Hypothesis, the report's counts were **not** taken on trust. The tree-wide
re-scan was run read-only in this session. Because a plain `grep -n 'sorry'` matches hundreds of
*docstrings containing the word* "sorry" (this codebase discusses its own sorries extensively),
the discriminating scan is for `sorry` **in tactic position** — a line consisting of whitespace
plus the bare token:

```
$ grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -v Boneyard
FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean:201:  sorry
FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242:  sorry

$ grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -vc Boneyard
2
$ grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -c Boneyard
91
```

A complementary scan for the other tactic-position forms (`:= sorry`, `by sorry`, `; sorry`,
`<;> sorry` at end of line) returned **no** non-Boneyard hits:

```
$ grep -rn --include='*.lean' -E '(:=|\bby\b|<;>|;)\s*sorry\s*$' FormalSystem/ | grep -v Boneyard
(no output)
```

### 2.2 DIVERGENCE: two live sorry sites outside `Boneyard/`, not three

> **[DIVERGENCE FROM REPORT]** The research report §1.2 states "exactly three outside `Boneyard/`"
> and presents a three-row table. **The observed count is TWO.** The report's third table row is
> `Metalogic/WeakCanonical/Kamp/Boneyard/*` — which is *itself* a `Boneyard/` sub-tree, and is
> therefore excluded by the report's own stated criterion. The report's table content is correct;
> only its summary count of "three outside Boneyard" is off by one, through counting an archived
> sub-tree as a non-archived site.
>
> **The observed value, 2, is the one recorded here.** This divergence does not affect any verdict
> in this document or in the report: the number of sorries *reachable from `completeness`* is
> unchanged at exactly one, which is the load-bearing claim.

### 2.3 The inventory as observed

| File:line | Declaration | Reachable from `completeness`? | Reachable from `completeness_dense`? |
|---|---|---|---|
| `Metalogic/WeakCanonical/Transfer.lean:1242` | `countermodel_discrete` | **YES — sole source** | no |
| `Metalogic/WeakCanonical/RealModel/ShuffleReal.lean:201` | `doets_lemma_1_5` | no | no |
| `Metalogic/WeakCanonical/Kamp/Boneyard/*`, `FormalSystem/Boneyard/*` (91 sites) | archived sub-trees | no | no |

`ShuffleReal.doets_lemma_1_5` sits on the Reynolds/Dedekind axis and is owned by task 408
(`faithful_route_to_strong_completeness_for_the_dedekind_extension`, currently `implementing`). It
is on **neither** weak terminus tracked here.

The `Transfer.lean` sorry's isolation is corroborated by the tree's own docstring at
`Transfer.lean:1207-1211`, verified verbatim: "This is the repository's sole live `sorry`, and the
sole `sorryAx` source reaching `BXCanonical.completeness`. It is a genuine open obligation, not
dead code: its axiom set is `[propext, sorryAx]` — a *direct terminal* sorry with no inherited
taint."

---

## 3. Corrections to the task brief

Reproduced from report §1.3. Each "actual state" cell was spot-checked against the tree this
session; all four matched.

| Brief claim | Actual state |
|---|---|
| "`completeness` … dense-arm `countermodel_dense`" | The dense arm of `completeness` uses `countermodel_dense_enriched` (`Completeness.lean:133`, called at :221), which is sorry-free. `Chronicle.countermodel_dense` (`ChronicleToCountermodelBasic.lean:829`) is no longer consumed by `completeness`; `Completeness.lean:413-415` flags it verbatim as "no longer consumed by `completeness` … audit retained pending archival". |
| "`dd_countermodel_chronicle_mixed_sorry`" | Archived. The mixed case is closed by `Chronicle.mcs_mixed_case_absurd` (`MCSMixedCase.lean`, called from `Completeness.lean:231`), sorry-free, used by both `completeness` and `completeness_discrete`. |
| "`completeness_dense` … inherits `ChronicleToCountermodel.lean` `succ_reaches_dom_N` / `chronicle_gap_contradiction`; `MCSMixedCase.lean`" | All three are gone from live code. `succ_reaches_dom_N` and `chronicle_gap_contradiction` live only in `Boneyard/DeadChronicleGapElimination/` and `Boneyard/SorriedDeclExcisions/`. `MCSMixedCase.lean` exists and is sorry-free. `completeness_dense` is verified clean (§1 above). |
| "`countermodel_discrete` … deprecated Transfer.lean route" | Correct, and it is the *only* remaining gap. |

### The consequence, stated explicitly

1. **The Dense weak terminus is ALREADY SATISFIED.** `completeness_dense` is machine-verified
   sorry-free. Task 170's stated obligation names three declarations that have **all** been
   archived to `Boneyard/`; none of them is reachable from `completeness_dense`.
2. **`completeness` has EXACTLY ONE reachable sorry, not three.** It is
   `WeakCanonical.countermodel_discrete` at `Transfer.lean:1242`.

---

## 4. Dense recommendation (task 170)

**There is no Lean work to do at task 170.** The remaining action is administrative, and it must
be performed by a build-lock holder:

1. Run an independent **clean-build** `#print axioms FormalSystem.Metalogic.BXCanonical.completeness_dense`.
   (This session's `lean_verify` consumed *existing* oleans; a clean-build re-verification is the
   stronger evidence and is the one the closure should rest on.)
2. If it reports exactly `propext, Classical.choice, Quot.sound`, transition task 170 to
   `[COMPLETED]` with a completion summary **recording the verified axiom set verbatim**.

> **DIRECTIVE: no implementation agent should be dispatched at task 170.** Dispatching one would
> spend a full implementation budget searching for sorries that do not exist, against a theorem
> that is already green. If task 170 is picked up by an orchestrator, the correct action is the
> two-step verification above, not `/implement`.

The status transition itself is deliberately **not** performed by task 361, which may not take the
build lock and therefore cannot produce the clean-build evidence the transition should rest on.

---

## 5. Base route analysis (task 169)

### 5.1 The obligation, verbatim

`WeakCanonical.countermodel_discrete`, `Transfer.lean:1225-1242`, re-read this session:

```lean
theorem countermodel_discrete (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box nextTop ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬TruthAt TM Omega τ t φ
```

**What the conclusion does NOT demand.** This is the single most important observation for route
selection: the existential asks only for `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`,
`Nontrivial`. It does **not** require `D` to be `ℤ`, does **not** require discreteness, and does
**not** require Archimedean-ness. **Any nontrivial ordered abelian group will do.**

### 5.2 A naming caution before the verdicts

The tree's own comment at `Transfer.lean:1239-1241` names **two** candidate routes:

> `-- Two candidate routes: (i) a Base-MCS → Discrete-MCS transfer lemma that lets`
> `-- countermodel_discrete_reynolds_v2 apply, or (ii) a Henkin-style discrete canonical`
> `-- model built directly from a Base-MCS. See the section docstring above.`

The research report uses its own numbering **(i)/(ii)/(iii)** which does *not* line up with the
tree's. To avoid a costly mis-read downstream, the correspondence is fixed here:

| Label used below | Tree's label | Content |
|---|---|---|
| **Route (i)** | tree's (i) | Base-MCS → Discrete-MCS transfer lemma |
| **Route (ii)** | a *concretization* of the tree's (ii) | Direct construction over a **non-Archimedean discrete carrier** (`ℚ ×ₗ ℤ`) |
| **Route (iii)** | **not in the tree's comment at all** | Reuse the existing ℚ dense chronicle |

### 5.3 Route (i) — Base-MCS → Discrete-MCS transfer: **REFUTED**

`FrameClass.Discrete` adds exactly three axiom schemes over Base. Verified at
`ProofSystem/Axioms.lean` via `Axiom.minFrameClass` (:557-559): `prior_UZ _ => .Discrete`,
`prior_SZ _ => .Discrete`, `z1 _ => .Discrete`. The third is, per its own docstring
(`Axioms.lean:327-331`, verified verbatim), "the characteristic axiom of IsSuccArchimedean frames":

```lean
/-- Z1: `G(Gφ→φ) → (FGφ→Gφ)`. … This is the
  characteristic axiom of IsSuccArchimedean frames: backward induction from any
  reachable Gφ-witness yields Gφ everywhere. -/
| z1 (φ : Formula) :
    Axiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture))
```

**The witness.** Take `D := ℤ ×ₗ ℤ` (lexicographic, first coordinate dominant) and let `p` hold
exactly at points `≥ (1,0)`.

| Step | Claim | Why |
|---|---|---|
| 1 | `□U(⊤,⊥)` holds | every point `(a,b)` has immediate successor `(a,b+1)`, so `U(⊤,⊥)` holds everywhere |
| 2 | `G(Gp → p)` holds at `(0,0)` | `Gp` holds exactly at points `≥ (1,0)`; therefore `Gp → p` holds everywhere |
| 3 | `FGp` holds at `(0,0)` | witness `(1,0)` |
| 4 | `Gp` **fails** at `(0,0)` | witness `(0,1)`, which is `> (0,0)` but `⊁ (1,0)`, and `p` fails there |
| 5 | **`z1 p` is FALSE at `(0,0)`** | steps 2+3 give the antecedent, step 4 denies the consequent |

Hence `{□U(⊤,⊥), G(Gp→p), FGp, ¬Gp}` is satisfiable over an ordered abelian group, therefore
**Base-consistent**, therefore (by Lindenbaum — `set_lindenbaum`, `Core/MaximalConsistent.lean:303`,
verified present) extends to a Base-MCS `A` with `□U(⊤,⊥) ∈ A` that is **Discrete-inconsistent**.

> **No Base-to-Discrete MCS transfer lemma can exist.** Route (i) is dead.

**Required fix, and it is part of task N1's deliverable**: the two docstring sentences at
`Transfer.lean:1239-1241` proposing this route must be **corrected**, not left standing. Leaving
them there guarantees a future dispatch re-attempts a refuted route.

### 5.4 Route (iii) — reuse the ℚ dense chronicle: **BLOCKED**, and here is exactly where

Tempting, because the restricted truth lemma only constrains `subformulaClosure φ`, and `U(⊤,⊥)`
need not be in it. But `h_box_dense` is **not** bookkeeping. It feeds `box_dense_gives_density`
(`ChronicleToCountermodelBasic.lean:435`, verified), which is what licenses the Cantor isomorphism
of the chronicle order with `ℚ` used by `rootedCantorFmcsDense` (:500, verified) and threaded
through all three restricted-coherence proofs:

| Proof | Line (verified this session) | Report said |
|---|---|---|
| `cantor_bfmcs_dense_restricted_tc` | **629** | 629 ✓ |
| `cantor_bfmcs_dense_restricted_buc` | **680** | 682 — *off by 2* |
| `cantor_bfmcs_dense_restricted_fuc` | **755** | 757 — *off by 2* |

(Minor line drift only; the declarations exist and the structural claim is unaffected.)

With `□U(⊤,⊥) ∈ A` the chronicle order is **discrete**, and the `ℚ` isomorphism is simply
unavailable. Route (iii) requires a *different* carrier — which is route (ii).

### 5.5 Route (ii) — non-Archimedean discrete carrier: **RECOMMENDED**

The old BX pipeline died at `succ_cofinal`, refuted by the "ℤ+ℤ counterexample"
(`Boneyard/BXPipelineGapAnalysis/`). The key realization:

> **`succ_cofinal` was only ever needed to force the chronicle into `ℤ` — i.e. to make it
> Archimedean.** `FrameClass.Base` imposes no Archimedean-ness: `valid` (`Validity.lean:79`,
> verified verbatim) has binder list `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
> [Nontrivial D]` and **no** `IsSuccArchimedean` binder. So the ℤ+ℤ shape is **not a
> counterexample to the construction — it is the intended carrier.**

Concretely: a countable discrete linear order without endpoints decomposes into ℤ-blocks whose
block order is a countable linear order. If the block order is densified (the same Cantor step the
dense branch already performs), the carrier `ℚ ×ₗ ℤ` — lexicographic, `ℚ` dominant — is:

- an **ordered abelian group** (lex product of ordered abelian groups) — see §5.6, this is now
  *confirmed available in Mathlib*;
- **discretely ordered** with successor `(q, n) ↦ (q, n+1)`, so it validates `U(⊤,⊥)` everywhere,
  discharging `h_box_discrete`;
- **non-Archimedean**, so `z1` is not required of it — which is exactly what §5.3 showed Base
  permits;
- **countable**, so the existing Cantor/chronicle bookkeeping transfers.

### 5.6 CORRECTION to the report's first risk: the Mathlib instance EXISTS

> **[DIVERGENCE FROM REPORT — in the route's favour]** Report §4.2 states: "Mathlib's `Prod.Lex`
> has `LinearOrder`, but I did not find an `IsOrderedAddMonoid (α ×ₗ β)` instance under
> `Mathlib/Algebra/Order/`. If absent it is a short supply … but the phase should verify instance
> availability before committing."
>
> **The instance exists.** Located this session at
> `.lake/packages/mathlib/Mathlib/Algebra/Order/Monoid/Prod.lean:52-59`, verbatim:
>
> ```lean
> namespace Lex
>
> @[to_additive]
> instance isOrderedMonoid [CommMonoid α] [Preorder α] [MulLeftStrictMono α]
>     [CommMonoid β] [Preorder β] [IsOrderedMonoid β] :
>     IsOrderedMonoid (α ×ₗ β) where
>   mul_le_mul_left _ _ hxy z := (le_iff.1 hxy).elim
>     (fun hxy => left _ _ <| mul_lt_mul_left hxy _)
>     (fun hxy => le_iff.2 <|
>       Or.inr ⟨by simp only [ofLex_mul, fst_mul, hxy.1], mul_le_mul_left hxy.2 _⟩)
> ```
>
> The `@[to_additive]` attribute generates the additive form `IsOrderedAddMonoid (α ×ₗ β)` with
> hypotheses `[AddCommMonoid α] [Preorder α] [AddLeftStrictMono α] [AddCommMonoid β] [Preorder β]
> [IsOrderedAddMonoid β]`. A companion `Lex.isOrderedCancelMonoid` sits at :61-68, also
> `@[to_additive]`.
>
> **Consequence**: the report's "short supply" risk on route (ii) is **retired**. Task N1's
> instance probe becomes a *confirmation* step rather than a *supply* step, which is materially
> cheaper.
>
> **Residual `[UNVERIFIED]`**: the exact `to_additive`-generated instance *name* (presumably
> `Prod.Lex.isOrderedAddMonoid`) was not resolved by name lookup, only inferred from the attribute
> — and no elaboration check was run, because that would require the build lock. The probe should
> confirm the instance actually *fires* for `ℚ ×ₗ ℤ` (in particular that `AddLeftStrictMono ℚ` is
> found), not merely that a matching instance is declared.

### 5.7 The remaining open risk on route (ii)

One genuine risk survives §5.6, and it is the main risk in task N2 (`B2`):

> **Can the chronicle's block order always be densified without disturbing MCS-chain coherence?**
> A countable discrete order without endpoints is a ℤ-indexed fibration over its block order, but
> making the *total* structure a **group** requires the block order to carry a compatible group
> structure. Densifying the block order into `ℚ` is the natural move and is what the dense branch
> already does — but it was **not** verified that this densification leaves the MCS-chain coherence
> undisturbed. (Report §6 item 2 names this as unresolved; nothing in this session changed that.)

This risk is unresolved and must be carried into task N2's description as its named principal risk.

---

## 6. Route verdicts, summarized

| Route | Verdict | Where it dies / lives |
|---|---|---|
| **(i)** Base-MCS → Discrete-MCS transfer | **REFUTED** | `ℤ ×ₗ ℤ` witness validates `□U(⊤,⊥)` and falsifies `Axiom.z1` (§5.3) |
| **(iii)** Reuse the ℚ dense chronicle | **BLOCKED** | `box_dense_gives_density` (`ChronicleToCountermodelBasic.lean:435`) is load-bearing for the ℚ Cantor iso; unavailable when the order is discrete (§5.4) |
| **(ii)** Non-Archimedean discrete carrier `ℚ ×ₗ ℤ` | **RECOMMENDED** | `FrameClass.Base` imposes no Archimedean-ness; Mathlib's lex ordered-monoid instance confirmed available (§5.5-§5.6) |

---

## 7. Divergences from the research report — consolidated

| # | Report claim | Observed | Impact |
|---|---|---|---|
| 1 | "exactly three [live sorries] outside `Boneyard/`" (§1.2) | **two** — the report's third row is itself a `Boneyard/` sub-tree | None on any verdict. The count of sorries *reachable from `completeness`* is unchanged at exactly one. |
| 2 | `completeness_discrete` axiom set taken "per in-file audit" (§1.1) | **machine-verified this session** by `lean_verify`: `[propext, Classical.choice, Quot.sound]` | Strengthens the report — comment-attested becomes machine-attested. |
| 3 | "I did not find an `IsOrderedAddMonoid (α ×ₗ β)` instance under `Mathlib/Algebra/Order/`" (§4.2) | **The instance exists**, `Mathlib/Algebra/Order/Monoid/Prod.lean:52-59`, `@[to_additive]` | Retires a named risk on the recommended route; N1's probe is now confirmation, not supply. |
| 4 | `cantor_bfmcs_dense_restricted_buc` at :682, `_fuc` at :757 | :680 and :755 | Cosmetic line drift; declarations exist, structural claim unaffected. |
| 5 | Route labels (i)/(ii)/(iii) | The tree's own comment names only two routes, with different content under label (ii); the report's (iii) is not in the tree at all | Documented as a naming caution in §5.2 to prevent a downstream mis-read. |

Every other file:line anchor reproduced from the report — `Completeness.lean:133`/:196/:255/:296/:413-415,
`Transfer.lean:1207-1211`/:1225-1242/:1239-1241, `Axioms.lean:327-331`/:557-559,
`MaximalConsistent.lean:303`, `ChronicleToCountermodelBasic.lean:435`/:500/:629/:829,
`Validity.lean:79` — was independently re-verified this session and matched.
