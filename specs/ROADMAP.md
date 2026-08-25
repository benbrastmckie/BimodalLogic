# Roadmap: BX Completeness and Publication

## Overview

TM is a bimodal logic combining S5 modality with irreflexive linear temporal logic,
axiomatized via the **Burgess-Xu (BX) system**. This roadmap describes the current
state of the completeness effort as of 2026-07-07 (multi-agent trajectory assessment:
git archaeology, sorry inventory, Rabinovich coverage mapping, convergence audit).
Header sections below are current; reference sections further down retain their
original dates and remain valid as historical/technical documentation.

**Architecture**: The proof system has 41 BX axioms organized in 6 layers:
propositional (4), S5 modal (5), Burgess-Xu temporal (26), modal-temporal
interaction (2), uniformity (4), and Prior-UZ/SZ (2, discrete-only). The temporal
semantics is **irreflexive**: G/H quantify over `t < s` / `s < t` (strict
inequality), and Until/Since require strictly future/past witnesses.

**Convention**: `untl(event, guard)` matches Burgess 1982 `U(α, β)` where α=event
(at witness), β=guard (at intermediates). Migrated by task 107 Phase 9.

**Completeness architecture (2026-08-17, current; supersedes the "Chronicle is primary, BXCanonical
is dead code" claim below)**: `FormalSystem/Metalogic/BXCanonical/` is the wired entry point —
`FormalSystem/Metalogic.lean`'s own module docstring names it so, and
`FormalSystem/Metalogic/StrongCompleteness.lean` imports
`FormalSystem.Metalogic.BXCanonical.CompletenessDedekind` directly. Three routes live under it:
**Chronicle** (`BXCanonical/Chronicle/`, Burgess 1982 chronicle construction) serves the dense
branch; **WeakCanonical/** (Kamp/Reynolds pipeline) serves the discrete branch; and
**`BXCanonical/CompletenessDedekind.lean`** (Reynolds 1992 §9 Theorem 7) serves the Dedekind/
real-line route with no case split. Per `scripts/check-module-invariants.sh` check C2, all four
flagship theorems are baselined: `BXCanonical.completeness_dense`, `.completeness_discrete`, and
`.Chronicle.countermodel_dense` are `[propext, Classical.choice, Quot.sound]`-clean (no
`sorryAx`); `BXCanonical.completeness`'s lone `sorryAx` traces to the single live structural
sorry check C3 finds, `WeakCanonical.countermodel_discrete` (see `## Sorry Inventory`) — not to
anything inside BXCanonical itself. The "BXCanonical is dead code" verdict below was the
2026-05-10 task-109 assessment; it did not anticipate `CompletenessDedekind.lean` and
`Completeness.lean`, added afterward, which are what make BXCanonical the flagship path today.

**Completeness programme: strong vs weak terminology and per-class targets** (2026-07-27,
settled; the in-tree authority is the module docstring of
`FormalSystem/Metalogic/StrongCompleteness.lean`):

- **Terminology.** "Strong completeness" is reserved, project-wide, for consequence from
  possibly-INFINITE premise sets: `Γ : Set Formula` with the finitary set-derivability relation
  `∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ`. Because `Context = List Formula`
  is finite, any finite-context consequence statement is inter-derivable with weak
  (single-formula) completeness through the deduction theorem
  (`Γ ⊨ φ ↔ ⊨ Γ.foldr imp φ`), and is therefore named **consequence completeness**, never
  strong. The former "main_strong_completeness" finite-context framing (still visible in
  `latex/subfiles/04-Metalogic.tex`) was misleading in exactly this way and is retired; the
  LaTeX restatement is owned by task 362.
- **For a finitary proof system, genuine strong completeness entails compactness** of the class
  consequence relation, so it is available exactly where that relation is compact. Per class:

  | Class | Weak completeness | Finite-context consequence | Genuine strong (`Set Formula`) |
  |---|---|---|---|
  | Base | open — task 169, but narrower than previously recorded: **exactly ONE** reachable sorry remains, `countermodel_discrete` at `WeakCanonical/Transfer.lean:1242`. Route now scoped: the tree's own route (i) (Base-MCS → Discrete-MCS transfer) is **REFUTED** by a `ℤ ×ₗ ℤ` witness; route (ii) (direct construction over the non-Archimedean discrete carrier `ℚ ×ₗ ℤ`) is recommended. Chain: task 421 → task 422 → task 169. | capstone task 362 | OPEN question — gated on the shift-set representation theorem, task 424 |
  | Dense | **substantively closed** — `completeness_dense` (`BXCanonical/Completeness.lean:255`) is machine-verified sorry-free, axioms exactly `propext, Classical.choice, Quot.sound`, pending an independent clean-build re-verification by a build-lock holder. Task 170 needs **no implementation agent**; its remaining action is that re-verification plus the status transition. | capstone task 362 | OPEN question — gated on the shift-set representation theorem, task 424 |
  | Discrete | DONE (pristine axiom set) | capstone task 362 | **IMPOSSIBLE** — non-compact |
  | Dedekind | in flight — task 408 | task 408 (`consequence_completeness_dedekind`) | **IMPOSSIBLE** — non-compact |

- **The Base/Dense strong-completeness GATING RULE**: task 424 (the shift-set representation
  theorem) is a cheap feasibility gate for the whole semantic-compactness route — the expensive
  ultraproduct work (ultraproduct carrier, Łoś lemma for `TruthAt`, compactness, per-class strong
  completeness) is **not authorized and deliberately not created as tasks** until task 424 lands
  sorry-free in **both** directions with `#print axioms` clean on each; if either direction is
  refuted, the route is cancelled rather than retried.
- **Why Discrete is weak-only**: `ValidDiscrete` requires `IsSuccArchimedean`/
  `IsPredArchimedean`, and `next φ = untl φ bot` is a genuine next-step operator on discrete
  orders, so `{F p} ∪ {¬Xⁿ p : n ∈ ℕ}` is finitely satisfiable over `ℤ` yet unsatisfiable over
  every Archimedean discrete carrier — compactness fails, hence no strong form.
- **Why Dedekind is weak-only**: Reynolds 1992 Theorem 7 is *weak* completeness for the
  real-line axiomatisation and the restriction is genuine — the Dedekind-class consequence
  relation is not compact. Task 408's terminus pair was renamed accordingly (headline
  `completeness_dedekind`, corollary `consequence_completeness_dedekind`; formerly
  "strong_completeness_dedekind").
- **Why Base/Dense are open rather than settled**: neither binder list imposes
  Archimedean-ness, so the counterexamples above do not apply, and Burgess-style strong
  completeness for the classical ℚ tense logic suggests plausibility — but whether the full
  task-frame consequence relation (S5 box over shift-closed `Omega`, ordered-abelian-group
  time) is compact is genuinely open. The set-based MCS layer (`SetConsistent` — correctly
  finitary, `SetMaximalConsistent`, `set_lindenbaum`, in `Metalogic/Core/MaximalConsistent.lean`)
  already exists; the missing substantive piece is a **model-existence theorem** (every
  `SetConsistent` set satisfiable in a class frame), which does NOT follow from the
  single-formula countermodel engines. Task 361 delivered the feasibility verdict, the per-class
  set-consequence/set-derivability definitions, and the sub-task decomposition (see its
  `design/` documents); the recommended route is semantic compactness by a bespoke ultraproduct
  over a shift-set representation of task models, gated on task 424 per the rule above.
  **Dense is the natural first strong-completeness target**: its weak engine
  (`completeness_dense`) is already green, so Dense strong completeness does not wait on the
  Base weak terminus.

---

## BX Axiom System

`FormalSystem/ProofSystem/Axioms.lean` defines 42 axiom constructors in
six layers (see `Axioms.lean:55-59` for the Burgess 1982/84, Xu 1988, and Venema 1993
references; Reynolds 1992 is cited inline at `Axioms.lean:309`, not in that block). Under
irreflexive semantics (strict `<` for G/H,
strict witness for U/S), the axiom set replaces BX1/BX1' (reflexive T) with
seriality axioms and removes BX8/BX8' (not sound under irreflexive Until/Since).

### Layer 1: Propositional (4)

| Axiom | File:Line | Statement | Role |
|-------|-----------|-----------|------|
| `prop_k` | Axioms.lean:71 | `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` | Intuitionistic K |
| `prop_s` | Axioms.lean:75 | `φ → (ψ → φ)` | Weakening |
| `ex_falso` | Axioms.lean:78 | `⊥ → φ` | Ex falso |
| `peirce` | Axioms.lean:81 | `((φ → ψ) → φ) → φ` | Classical |

### Layer 2: S5 Modal (5)

| Axiom | File:Line | Statement | Role |
|-------|-----------|-----------|------|
| `modal_t` | Axioms.lean:86 | `□φ → φ` | Reflexivity |
| `modal_4` | Axioms.lean:89 | `□φ → □□φ` | Transitivity |
| `modal_b` | Axioms.lean:92 | `φ → □◇φ` | Symmetry |
| `modal_5_collapse` | Axioms.lean:95 | `◇□φ → □φ` | S5 characteristic |
| `modal_k_dist` | Axioms.lean:98 | `□(φ → ψ) → (□φ → □ψ)` | Normal modality |

### Layer 3: BX Temporal (24)

| Axiom | File:Line | Statement (future direction) | Role |
|-------|-----------|------------------------------|------|
| `temp_k_dist` | Axioms.lean:107 | `G(φ → ψ) → (Gφ → Gψ)` | K for G |
| `temp_4` | Axioms.lean:112 | `Gφ → GGφ` | Transitivity; needed for `bx_le_trans` |
| BX1 `serial_future` | Axioms.lean:117 | `T → F(T)` | Seriality (replaces reflexive T) |
| BX1' `serial_past` | Axioms.lean:122 | `T → P(T)` | Mirror seriality |
| BX3 `right_mono_until` | Axioms.lean:139 | `G(φ→ψ) → ((χUφ)→(χUψ))` | Right monotonicity |
| BX3' `right_mono_since` | Axioms.lean:143 | mirror for S | |
| BX4 `connect_future` | Axioms.lean:150 | `φ → G(P(φ))` | Temporal connectedness |
| BX4' `connect_past` | Axioms.lean:155 | `φ → H(F(φ))` | Mirror |
| BX5 `self_accum_until` | Axioms.lean:161 | `(φUψ) → ((φ ∧ (φUψ))Uψ)` | **Key eventuality axiom** |
| BX5' `self_accum_since` | Axioms.lean:166 | mirror for S | |
| BX6 `absorb_until` | Axioms.lean:173 | `(φU(φ ∧ (φUψ))) → (φUψ)` | Prevents infinite deferral |
| BX6' `absorb_since` | Axioms.lean:177 | mirror for S | |
| BX7 `linear_until` | Axioms.lean:184 | four-formula linearity disjunction | Linearity of U witnesses |
| BX7' `linear_since` | Axioms.lean:194 | mirror for S | |
| BX10 `until_F` | Axioms.lean:211 | `(φUψ) → F(ψ)` | Eventuality extraction |
| BX10' `since_P` | Axioms.lean:216 | mirror for S | |
| BX11 `temp_linearity` | Axioms.lean:225 | F-witness linearity disjunction | Linear order on F witnesses |
| BX11' `temp_linearity_past` | Axioms.lean:234 | mirror for P | |
| BX12 `F_until_equiv` | Axioms.lean:243 | `F(φ) → (⊤Uφ)` | Bridges F to U |
| BX12' `P_since_equiv` | Axioms.lean:248 | `P(φ) → (⊤Sφ)` | Mirror |
| BX13 `enrichment_until` | Axioms.lean:160 | `p ∧ (φUψ) → (φU(ψ ∧ S(φ,p)))` | Burgess A3a enrichment |
| BX13' `enrichment_since` | Axioms.lean:165 | mirror for S | Burgess A3b |
| BX2H `left_mono_until_G` | Axioms.lean:140 | `G(φ→χ) → (φUψ) → (χUψ)` | Guard strengthening under G |
| BX2H' `left_mono_since_H` | Axioms.lean:146 | `H(φ→χ) → (φSψ) → (χSψ)` | Guard strengthening under H |

*Note: BX8/BX8' (until_step/since_step) removed -- not sound under irreflexive semantics.*
*Note: BX9/BX9' (until_elim/since_elim) and until_guard/since_guard removed -- not sound under open guard `(t,s)` semantics (task 113).*
*Note: BX14/BX14' (separation_until/separation_since) removed -- redundant under transitive frames. Xu 3.2.1 (BX5 self-accumulation) subsumes BX14's role in chronicle splitting (task 115).*
*Note: BX2/BX2' (left_mono_until/left_mono_since) removed in task 133. Under open-guard irreflexive semantics the pointwise conjunct in BX2 is redundant; BX2H/BX2H' (left_mono_until_G/left_mono_since_H, added in task 107 Phase 5b) subsume BX2/BX2' and are now the canonical left-monotonicity axioms.*

### Layer 4: Modal-Temporal Interaction (2 → 1 after task 124)

| Axiom | File:Line | Statement | Status |
|-------|-----------|-----------|--------|
| `modal_future` | Axioms.lean:328 | `□φ → □(Gφ)` | Primitive |
| `temp_future` | Axioms.lean:331 | `□φ → G(□φ)` | **Task 124: derive from MF+T+Modal4, remove as primitive** |

### Layer 5: Uniformity (5)

| Axiom | Statement | Role |
|-------|-----------|------|
| `discrete_symm_fwd` | `U(⊤,⊥) → S(⊤,⊥)` | Forward gap implies backward gap |
| `discrete_symm_bwd` | `S(⊤,⊥) → U(⊤,⊥)` | Backward gap implies forward gap |
| `discrete_propagate_fwd` | `U(⊤,⊥) → G(U(⊤,⊥))` | Gap propagates to all future points |
| `discrete_propagate_bwd` | `U(⊤,⊥) → H(U(⊤,⊥))` | Gap propagates to all past points |
| `discrete_box_necessity` | `U(⊤,⊥) → □(U(⊤,⊥))` | Discreteness propagates to all box-accessible worlds (task 142) |

*These encode the uniformity of discreteness in ordered abelian groups. Valid on all linear orders with AddCommGroup structure. The `discrete_box_necessity` axiom is the key to eliminating the mixed case in `completeness`: it ensures that if any world is discrete, all box-accessible worlds are discrete too.*

### Layer 6: Prior Axioms for Integers (2) — Task 119

| Axiom | Statement | Role |
|-------|-----------|------|
| `prior_UZ` | `F(φ) → U(φ, ¬φ)` | Nearest future φ-point is reachable (Reynolds 1992 §10, Venema 1993 axiom W) |
| `prior_SZ` | `P(φ) → S(φ, ¬φ)` | Nearest past φ-point is reachable (dual) |

*These are discrete-only axioms (`isBase = False`, `isDenseCompatible = False`, `isDiscreteCompatible = True`, `frameClass = .Discrete`). Valid on all discrete orders with `IsSuccArchimedean`. Soundness proofs are sorry-free (well-founded descent via `Nat.find` on succ/pred chain). Added by task 119.*

### Irreflexive semantics and the seriality switch

Under the irreflexive semantics switch (task 93), BX1/BX1' (`Gφ → φ` / `Hφ → φ`)
were replaced by seriality axioms (`T → F(T)` / `T → P(T)`). This means:

- `bx_le` is no longer reflexive (g_content(w) is NOT a subset of w)
- `g_content_set_consistent` uses seriality instead of BX1: if G(bot) in MCS,
  seriality gives F(T) = not G(neg T), and G(bot) implies G(neg T) by ex falso,
  contradiction
- BX8/BX8' (until_step/since_step) were removed entirely -- not sound under irreflexive semantics
- `φ → F(φ)` is NOT derivable -- this is the KEY insight for completeness:
  resolved defects do not re-enter as F-obligations

The critical architectural consequence: under irreflexive semantics, the
active defect count strictly decreases at each chain step, because resolved
formulas φ in M' do NOT generate F(φ) in M'. This was the argument that
unblocked the (now-archived) `RootScopedChain.lean` sorry sites at the time
(task-93/109 era); see `## Sorry Inventory` for the current, C3-verified sorry
count.

---

## Irreflexive Truth Semantics

All four temporal operators in TM use strict (irreflexive) ordering. The current
point is EXCLUDED for G and H (`<`), and Until/Since witnesses must be strictly
future/past (`t < s` / `s < t`) with open guards.

From `FormalSystem/Semantics/Truth.lean:128-137` (the definition is now named `TruthAt`, not
`truth_at`). **The Lean block below is a STALE quotation** — it has not been refreshed since two
landed changes: (a) the Burgess argument-order migration, so the `untl`/`snce` clauses now read
`TruthAt … s φ ∧ ∀ r, … TruthAt … r ψ` (event first, guard second), and (b) the demotion of G/H
from primitive `Formula` constructors to derived abbreviations `allFuture`/`allPast`
(`FormalSystem/Syntax/Formula.lean:151,161`), so `TruthAt` has no `all_past`/`all_future` cases
at all. The truth conditions stated in the bullets after the block remain correct; the Lean text
does not match the source and needs a content pass:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M Omega τ t φ → truth_at M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

- **G (`all_future`)**: `∀ s, t < s → ...` — strict future (excludes `t`).
- **H (`all_past`)**: `∀ s, s < t → ...` — strict past (excludes `t`).
- **U (`untl`)**: `∃ s, t < s ∧ ψ@s ∧ ∀ r, t < r < s → φ@r` — strict witness,
  open guard `(t, s)`.
- **S (`snce`)**: `∃ s, s < t ∧ ψ@s ∧ ∀ r, s < r < t → φ@r` — mirror.

Under irreflexive semantics, `Gφ → φ` is NOT valid (BX1 removed), and
`φ → F(φ)` is NOT derivable. Seriality axioms (`T → F(T)`, `T → P(T)`)
ensure the temporal order has no maximum/minimum elements.

---

## X/Y Operator Status

From `FormalSystem/Syntax/Formula.lean:430-436`:

```lean
/-- Next-step operator: X(phi) = U(phi, bot) (Burgess convention: event first, guard second).
    X(phi) at t means phi holds at t+1 (event=phi at immediate successor, guard=bot vacuous). -/
def next (φ : Formula) : Formula := Formula.untl φ Formula.bot

/-- Previous-step operator: Y(phi) = S(phi, bot) (Burgess convention: event first, guard second).
    Y(phi) at t means phi holds at t-1 (event=phi at immediate predecessor, guard=bot vacuous). -/
def prev (φ : Formula) : Formula := Formula.snce φ Formula.bot
```

Unfolding `Formula.next φ = Formula.untl φ Formula.bot` against the irreflexive
Until clause (`Truth.lean:134-135`):

```
truth_at (⊥ U φ) at t  ↔  ∃ s, t < s ∧ truth_at φ s ��� ∀ r, t < r → r < s �� truth_at ⊥ r
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ ∀ r, t < r → r < s → False
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ (∀ r, ¬(t < r ∧ r < s))
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ (t, s) = ∅
```

Under irreflexive semantics, `⊥ U φ` at `t` requires a strictly future witness
`s > t` with `φ(s)` and an empty open interval `(t, s)`. The behavior depends
on the order structure:

- **Discrete order** (e.g., `ℤ`): The interval `(t, s)` is empty iff `s = t + 1`.
  So `X(φ)` at `t` means `φ` holds at the immediate successor `t + 1`. This is
  a genuine next-step operator, matching the docstring's "discrete strict semantics."
  Similarly, `Y(φ)` at `t` means `φ` holds at `t - 1`.

- **Dense order** (e.g., `ℚ` or `ℝ`): The interval `(t, s)` is never empty for
  `s > t`. So `⊥ U φ` is unsatisfiable on dense orders, and `X(φ)` is always
  false. Similarly, `Y(φ)` is always false on dense orders.

Under the current irreflexive semantics, `X`/`Y` have genuine semantic content
on discrete orders (they are true next/previous-step operators). On dense orders,
they are vacuously false. **They are not currently used in proofs**, but they
are no longer trivially equivalent to their argument as they were under the
former reflexive semantics.

---

## Active Metalogic Paths

**(2026-08-17, current; supersedes the "Chronicle is sole active, BXCanonical is dead code" claim
below)** `FormalSystem/Metalogic/BXCanonical/` is the wired entry point (per
`FormalSystem/Metalogic.lean`'s module docstring and the direct import in
`FormalSystem/Metalogic/StrongCompleteness.lean`), with three routes underneath it: the
**Chronicle** path (`Metalogic/BXCanonical/Chronicle/`) for the dense branch, **WeakCanonical/**
(Kamp/Reynolds) for the discrete branch, and `BXCanonical/CompletenessDedekind.lean` for the
Dedekind/real-line route. Check C2 baselines all four flagship theorems as `sorryAx`-free except
`BXCanonical.completeness`, whose lone `sorryAx` traces to check C3's single live sorry,
`WeakCanonical.countermodel_discrete` — not to anything the task-109 assessment below flagged.

### Chronicle Construction (Tasks 107→117→119→121→122)

The Burgess 1982 chronicle construction builds a countermodel via controlled
PointInsertion. The construction lives in `Metalogic/BXCanonical/Chronicle/`
(6 files, ~9500 lines).

**Current state (2026-05-10)**: 2 sorry sites on critical path (down from 13+ at task 107 start).
- Task 107: Eliminated all Chronicle sorry sites via 9 implementation phases
- Task 117: Removed Cantor iso, built countermodel on limit domain, dense case sorry-free
- Task 119: Added Prior-UZ/SZ axioms, proved IsSuccArchimedean via pigeonhole (modulo finiteness)

**Chronicle module structure**:
- `ChronicleTypes.lean` (~700 lines) -- Chronicle structure, `ClosedUnderDerivation`, `BurgessR3Maximal` (**sorry-free**)
- `PointInsertion.lean` (~3555 lines) -- Lemma 2.4/2.6, g_content⊆B, splitting (**sorry-free**)
- `RRelation.lean` (~1580 lines) -- R-relation, Burgess 2.3 equiv, Zorn construction (**sorry-free**)
- `CounterexampleElimination.lean` (~3600 lines) -- C4/C5 elimination (**sorry-free**)
- `ChronicleConstruction.lean` (~1220 lines) -- Omega-chain, limit construction (**sorry-free**)
- `ChronicleToCountermodel.lean` (~1200 lines) -- BFMCS wiring, dense/discrete countermodels (**2 sorries: finiteness + discrete BFMCS**)

**Key insight (report 17)**: The hybrid Int-chain + enriched seed approach is definitively
dead (dead ends #7, #13, #23, #31). The chronicle construction is NOT a dead end -- all
gaps are engineering problems, not mathematical impossibilities (report 16).

---

## Canonical Model Construction (BXCanonical)

**Note (2026-08-17)**: the `File.lean:NNN-MMM`-style line citations throughout this section (in
the subsection headings and prose below) are as of 2026-04 and have not been re-verified against
the live tree by this pass — out of scope here. Treat them as approximate pointers into the named
file, not as exact current line ranges.

### BXPoint (Frame.lean:46-53)

```lean
structure BXPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas
```

A canonical frame point is a maximally consistent set (MCS) of formulas.

### Canonical Temporal Ordering (Frame.lean:56-62)

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

Equivalently: `w ≤ v ↔ ∀ φ, G(φ) ∈ w → φ ∈ v`.

- **Reflexivity** (`bx_le_refl`): NOT valid under irreflexive semantics (BX1 removed).
  Without BX1, `g_content w ⊆ w` fails. `bx_le_refl` is sorry'd (intentionally invalid).
- **Transitivity** (`bx_le_trans`): requires `Gφ → GGφ` = `temp_4`.

### Canonical Modal Equivalence (Frame.lean:65-68)

```lean
def bx_modal_equiv (w v : BXPoint) : Prop :=
  ∀ φ : Formula, Formula.box φ ∈ w.formulas ↔ Formula.box φ ∈ v.formulas
```

### Key Infrastructure Lemmas (Frame.lean:79+)

- `g_content_closed_derivation` (Frame.lean:79-94): if `L ⊆ g_content(S)` and
  `L ⊢ φ`, then `Gφ ∈ S`. Uses `generalized_temporal_k`.
- `h_content_closed_derivation` (Frame.lean:101-114): dual for H.
- `g_content_set_consistent` (Frame.lean:122-162): `g_content` of an MCS is
  consistent; uses seriality (`T → F(T)`) to contradict `G(⊥) ∈ S` via
  `G(⊥) → G(¬⊤)` and `F(⊤) = ¬G(¬⊤)`. Sorry-free.
- `bx_forward_witness` / `bx_backward_witness`: Lindenbaum extension producing
  G/H canonical witnesses.
- `bx_modal_witness` (Frame.lean): constructs the modal-direction witness.
  Sorry-free (closed by task 102).

### Truth Lemma (TruthLemma.lean:27-36)

Proved by formula induction. The core cases (`atom`, `bot`, `imp`, `box`, `G`, `H`,
`U` forward, `S` forward) are **sorry-free**. The `U` and `S` forward cases delegate
to `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution` in
`Frame.lean`, closed by tasks 98+102. Two auxiliary lemmas
(`until_backward_refl_mcs`, `since_backward_refl_mcs`) are sorry'd as
irreflexive-consequence artifacts -- they assumed reflexive Until/Since introduction
which is invalid under irreflexive semantics.

### Completeness Theorem (Completeness.lean:124-154)

```lean
theorem completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

Contrapositive proof flow:

1. Assume `valid φ` and `¬derivable φ`.
2. By `neg_consistent_of_not_derivable` (sorry-free): `{¬φ}` is consistent.
3. By `set_lindenbaum`: extend to an MCS `M` with `¬φ ∈ M`.
4. Build a canonical `TaskModel` from the BXPoint canonical frame.
5. By the truth lemma: `φ` is false at `M` in the model.
6. Contradiction with `valid φ`.

**Corrected 2026-08-17** (historical: step 4 previously routed through `dd_countermodel` in
`RootScopedChain.lean`, now archived — see `## Sorry Inventory`). Per
`FormalSystem/Metalogic/BXCanonical/Completeness.lean`'s own module docstring (`## Status`), the
current picture is: `completeness_dense` and `completeness_discrete` are `sorryAx`-free (axioms
exactly `propext, Classical.choice, Quot.sound`). The general Base-frame `completeness` still
carries a `sorryAx`, with a single source: `WeakCanonical.countermodel_discrete`
(`WeakCanonical/Transfer.lean`), used in its discrete branch — the sole remaining completeness
debt. Its dense branch (`countermodel_dense_enriched`) and mixed branch (`mcs_mixed_case_absurd`)
are `sorryAx`-free. The file imports
`FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` and
`FormalSystem.Metalogic.BXCanonical.Chronicle.MCSMixedCase` directly for the dense/mixed routes.

---

## Quasimodel/Filtration Infrastructure

Nine files (2,228 lines) under `BXCanonical/` implement a Hintikka-set
quasimodel with defect-discharge to close the Until/Since eventuality
obligations. Under irreflexive semantics, 9 of these sorries are
irreflexive-consequence artifacts (Construction 2, Realization 4,
SigmaOrdering 3); the remaining files are sorry-free.

### Quasimodel/ (Hintikka-set quasimodel construction)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SubformulaClosure.lean` | 114 | Finite subformula closure (Sigma-closure) | `subformulas`, `SubformulaClosure`, `ghEnrichment` |
| `HintikkaPoint.lean` | 144 | Hintikka point definition and sigma-signature | `HintikkaPoint`, `sigma_signature`, `sigma_signature_consistent`, `sigma_signature_maximal` |
| `EnrichedClosure.lean` | 158 | Fisher-Ladner enriched closure with G/H negation formulas | `enrichedGNegBigconj`, `enrichedHNegBigconj`, `enrichedClosure` |
| `Construction.lean` | 885 | BX axiom lemmas at MCS level with defect-discharge (2 sorries) | `hintikka_step`, `UntilDefect`, `defect_count`, `QuasimodelChain` |
| `Realization.lean` | 576 | Realization lifting from Hintikka chains to BXPoint chains (4 sorries) | `until_forward_seed`, `since_backward_seed`, `until_eventuality_resolution`, `since_eventuality_resolution` |
| `LocusControl.lean` | 47 | Delegation layer (primed variants) | `bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'` |

### Filtration/ (Sigma-restricted ordering)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SigmaOrdering.lean` | 167 | Sigma-restricted ordering on BXPoints (3 sorries) | `sigma_le`, `sigma_strict`, `sigma_equiv`, `bx_le_implies_sigma_le` |
| `DefectChain.lean` | 137 | Defect-discharge chain via well-founded recursion | `sigma_defect_count`, `until_defect`, `defect_step_phi` |

### CanonicalChain.lean (top-level bridge)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `CanonicalChain.lean` | 160 | MCS-level BX axiom lemmas and delegation bridges (sorry-free) | `psi_imp_until_mcs`, `psi_imp_since_mcs`, `F_imp_top_until_mcs` |

---

---

## Sorry Inventory

**(2026-08-17, current, generator of record: `scripts/check-module-invariants.sh` check C3 —
regenerate this section from C3's live output rather than hand-editing it.)** The live
(non-Boneyard) tree has exactly **one** structural sorry: it is in `theorem countermodel_discrete`
in `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`, owned by the Base weak-completeness
terminus (see the "Completeness programme" table in `## Overview`). C3 asserts this **by
enclosing declaration name, never by line number** — the sole sorry's line has already drifted
across prior edits to this file while the declaration stayed constant, so any `Transfer.lean:NNN`
citation elsewhere in this document should be read as informational, not load-bearing. C3's scope:
it greps all of `FormalSystem/` (both Boneyard directories excluded) for four structural sorry
shapes — a bare `sorry` on its own line, `:= sorry` at end of line, `exact sorry`, and `<;> sorry`
— so it counts unresolved goals, not `sorryAx`-tainted declarations reachable through a lemma
dependency; see the C2 baseline immediately below for the axiom-level view. The **23-sorry** and
**19-sorry** figures below are superseded task-109-era counts, retained as historical record, not
current state.

**C2 axiom baseline (what is provably clean)**: `BXCanonical.completeness_dense`,
`.completeness_discrete`, and `.Chronicle.countermodel_dense` all depend on exactly
`[propext, Classical.choice, Quot.sound]` — no `sorryAx`. `BXCanonical.completeness`'s only
`sorryAx` traces to the single C3 sorry above via `WeakCanonical.countermodel_discrete`, not to
anything inside BXCanonical.


---


---

## Burgess-Xu Until-Induction Technique

### Historical Context

The BX system is named after John P. Burgess and Ming Xu. Active references
(cited in the `Axioms.lean:46-49` comment block):

- **Burgess, J. P. (1982)**. "Axioms for tense logic. I. 'Since' and 'until'."
  *Notre Dame Journal of Formal Logic* 23(4), 367-374.
  [ResearchGate](https://www.researchgate.net/publication/38355634_Axioms_for_tense_logic_I_Since''_and_until'').
- **Xu, M. (1988)**. "On some U, S-tense logics."
  *Journal of Philosophical Logic* 17, 181-202. Simplifies Burgess's axiomatization.
- **Venema, Y. (1993)**. Temporal logic survey (cited in `Axioms.lean:48`).

See also the Stanford Encyclopedia of Philosophy:

- [Burgess-Xu Axiomatic System for Since and Until](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html) — supplementary entry.
- [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) — main article.

### Key Result

Burgess (1982), simplified by Xu (1988), gives a complete axiomatization of
the Since-Until tense logic over **all linear orderings**. The BX axioms
BX1-BX12 in `Axioms.lean` are modeled on this axiomatization, adapted for
irreflexive semantics (BX1/BX1' replaced by seriality, BX8/BX8' removed).

### Axiom Roles in the Until-Induction Proof

The proof of the Until case of the truth lemma proceeds by induction on the
Until-structure of formulas, using the following axioms:

1. **BX10 (`until_F`)**: `(φUψ) → Fψ` extracts an F-witness, giving some
   `v ≥ w` with `ψ ∈ v`.
2. **BX7 (`linear_until`)**: Linearity of Until witnesses — given two Until
   formulas holding simultaneously, their witnesses are comparable. Provides
   the linear-order structure on witnesses needed to choose a minimal / first
   witness.
3. **BX11 (`temp_linearity`)**: F-witness linearity — three-way disjunction
   giving comparability of F-witnesses.
4. **BX5 (`self_accum_until`)**: `(φUψ) → ((φ ∧ (φUψ))Uψ)` — the eventuality
   enriches its own guard, so at every intermediate point `u ∈ [w, v)` both
   `φ` and `φUψ` hold. This is the key guard-propagation axiom.
5. **BX6 (`absorb_until`)**: `(φU(φ ∧ (φUψ))) → (φUψ)` — prevents the
   self-accumulation from producing nested deferrals; the two-step resolution
   collapses.
6. **BX9 (`until_elim`)**: REMOVED (task 113). Was `(φUψ) → (φ ∨ ψ)`.
   Under open guard `(t,s)`, `t ∉ (t,s)` so `φ(t)` is not guaranteed.
   Not sound under open guard semantics.
7. **BX4 (`connect_future`)**: `φ → G(P(φ))` is used in the backward direction
   to propagate `¬(φUψ)` forward and derive a contradiction with the guard.
8. **BX1 (`serial_future`)**: `T → F(T)` (seriality). Replaces the former
   reflexive `Gφ → φ`. Consistency of `g_content` uses seriality to show
   `G(bot)` contradicts `F(T)`.

### Resolution: Option A (Quasimodel with Defect-Discharge)

Task 90 (research) identified two strategies for closing the 4 `bx_until_*` /
`bx_since_*` sorries:

- **Option A: Quasimodel with defect-discharge** -- Build a Hintikka-set
  quasimodel with sigma-restricted filtration ordering. Avoids Henkin closure
  machinery; uses well-founded recursion on defect count.
- **Option B: Henkin witness closure** -- Explicitly enrich the canonical frame
  with witness MCS points. Classical Burgess construction but adds machinery
  to the BXPoint type.

**Option A was chosen and implemented successfully** through tasks 92, 98,
and 102. The implementation added 2,289 lines of sorry-free infrastructure
across 9 files (see "Quasimodel/Filtration Infrastructure" and "How
Until/Since Were Closed" above). All 5 Frame.lean sorries are closed.

---

---

## Other Open Items

### Dense Completeness (task 68 — resolved; corrected 2026-08-17)

**Superseded.** The `dense_completeness_fc` declaration this entry describes no longer exists in
the live tree — it survives only in
`FormalSystem/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean` (archived). Per
check C2, the live dense-completeness theorem is
`BXCanonical.completeness_dense`, which carries exactly `[propext, Classical.choice, Quot.sound]`
— no `sorryAx`. If a distinct, still-open dense-completeness obligation exists under a different
name today, it is not `dense_completeness_fc` and is not evidenced by any check this pass ran; do
not equate the two. Original text, retained for history: `dense_completeness_fc` needs a separate
proof using a dense canonical model (e.g., over `ℚ`); cannot reduce to `completeness_over_Int`
since `Int` is not densely ordered; independent of the BX canonical construction.

### FMP Truth Preservation (task 82, 0 sorries in active tree)

- The sorries previously in `TruthPreservation.lean` (`mcs_all_future_closure`
  and `mcs_all_past_closure`) have been **archived to Boneyard**. The FMP module
  is currently sorry-free in the active source tree.
- Task 82's description may need reassessment: the original sorries are gone,
  so the task may already be complete or may need a new description.
- **Decidability track only** -- not a path to the completeness representation
  theorem.
- Independent of BXCanonical.

### Bi-Lasso Decision Layer (landed sorry-free; `fmp` open)

**Decidability track only** — like the entry above, and not a path to the completeness
representation theorem.

- **Status: landed.** `FormalSystem/Metalogic/Decidability/BiLasso/` is 19 modules, sorry-free,
  and registered in the build graph as of this commit: `Decidability.lean` imports the re-export
  `FormalSystem.Metalogic.Decidability.BiLasso`, so `lake build` compiles the layer. It was
  previously unreachable from every Lake target root and compile-checked only in isolation by
  check C6.
- **What it decides.** Truth of a formula at a state of a **given** `IntPresentation` — a finite
  graph on `Fin card` with a `Bool` valuation — by bounded enumeration of annotated bi-lassos.
  Entry point `check` with correctness theorem `check_correct` (`BiLasso/Check.lean`), plus a
  `Decidable` instance that computes. No efficiency claim: the enumeration bound is a closed
  arithmetic expression and it is astronomically large.
- **It does not decide the logic.** Nothing in the layer quantifies over frames.
  `cor:tm-decidability` stays open.
- **It performs no part of the finite-model step.** `exists_annot_of_truth`
  (`BiLasso/Extraction.lean`) takes a `WorldHistory P.toTaskFrame` as *input*: it compresses
  histories **within** a presentation, and does not produce a presentation from an arbitrary
  countermodel. Reading this directory as covering the semantic finite model property misreads
  that hypothesis.
- **What remains is exactly one theorem**, `fmp`:
  `∀ ψ, ¬ ValidDiscrete ψ → ∃ P ∈ cands ψ, ∃ w, SatAtState P w ψ.neg`, for a computable
  `cands : Formula → List IntPresentation`. Its crux is box-faithfulness — `box` truth is a
  global constant of its own model, so a source model's and a target presentation's box facts
  need not agree — and it is genuinely hard.
- **Given `fmp`, the assembly is live and machine-checked**: `validDiscrete_iff_checkFamily` and
  `decidableValidDiscreteFamily` in `BiLasso/Assembly.lean`, with the single-presentation forms
  `validDiscrete_iff_check`/`decidableValidDiscrete` and the hypothesis-free soundness direction
  `not_validDiscrete_of_satAtState`. That module takes `fmp` as a hypothesis and proves no part
  of it.
- **Axioms**: all five `Assembly.lean` declarations, and the layer's `Decidable` instance,
  measure `[propext, Classical.choice, Quot.sound]`. **No choice-freedom is claimed** — the
  instance computing and the instance being choice-free are different properties, and only the
  first holds (`wlem_of_spherical` rules out any choice-free finite-carrier route).
- Four sibling modules in the same directory — `Extend`, `Successor`, `Orbit`, `Agreement` —
  belong to the effective-periodic-extension work, not to this layer. They are deliberately
  outside the re-export and remain unreachable and manifested.

### Soundness (sorry-free)

- **Corrected 2026-08-17**: `FormalSystem/Metalogic/Soundness.lean` is confirmed sorry-free (no
  `sorry` tactic occurrences; its own module comment records `soundness`, `soundness_dense`, and
  `soundness_discrete` — all as theorems inside this one file, not separate files). The
  `DenseSoundness.lean` / `DiscreteSoundness.lean` files this entry originally named are archived,
  at `FormalSystem/Boneyard/SoundnessVariants/DenseSoundness.lean` and
  `FormalSystem/Boneyard/SoundnessVariants/DiscreteSoundness.lean` — not live siblings of
  `Soundness.lean` as the original wording implied.

### Examples / Pedagogical (corrected 2026-08-17)

**Superseded.** `FormalSystem/Examples/` contains **zero** occurrences of `sorry` in any form
today (`grep -rn sorry FormalSystem/Examples` returns nothing outside a `(sorry-free)` label in
`README.md`), and none of the four files this entry names — `Demo.lean`, `ModalProofs.lean`,
`ModalProofStrategies.lean`, `TemporalProofs.lean` — exists. The directory currently holds
`BimodalProofs.lean`, `TemporalStructures.lean`, and `README.md`, both `.lean` files documented
sorry-free by that README. Original text, retained for history: `Demo.lean`, `ModalProofs.lean`,
`ModalProofStrategies.lean`, `TemporalProofs.lean`, and others; expected and intentional
(exercises, demonstrations).

### Boneyard (corrected 2026-08-17)

**Superseded.** The C3 structural-sorry-shape grep
(`grep -rnE --include='*.lean' '(^[[:space:]]*sorry[[:space:]]*$)|(:=[[:space:]]*sorry[[:space:]]*$)|(\bexact sorry\b)|(<;> sorry)' FormalSystem/Boneyard`)
returns **104**, not ~14. C3 deliberately excludes both Boneyard directories from its own
assertion (see `## Sorry Inventory`), so this figure is informational, not a check-asserted
invariant, and is not re-verified automatically by any check. Archived dead code across
`Boneyard/` subdirectories remains expected and out of scope for closure.

---


---

## Representation Theorem Goal

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

This is the stated ROADMAP goal. The representation theorem must be **general**:
for any countable linear order D arising from a chronicle construction, produce
a TaskFrame model on an AddCommGroup D' that agrees on truth values. This
generality is essential — the same theorem must support:

- **D' = Rat** for the base logic (no density/discreteness axioms)
- **D' = Rat** for the logic extended with the density axiom F'⊤
- **D' = Int** for the logic extended with discreteness axioms G'⊥ ∧ H'⊥
- Any totally ordered abelian group D' appropriate to the frame class

The chronicle construction (Burgess 1982) produces a countable linear order
X ⊂ Q as its limit domain. X is naturally sparse (not necessarily dense or
discrete). The representation theorem embeds X into an appropriate D' and
constructs a TaskFrame D' model preserving truth values.

### Architecture: Natural Inclusion Replaces Cantor Isomorphism

There is ONE semantics (`truth_at`), ONE validity definition (`valid`), and
ONE TaskFrame/WorldHistory infrastructure — unchanged from the current code.

The chronicle construction (Burgess 1982) produces a limit domain X ⊂ ℚ.
X is already a subset of ℚ by construction (midpoints at (x+y)/2, successors
at x+1). The current code maps X into ℚ via a Cantor order-isomorphism
(`Order.iso_of_countable_dense`), which requires proving `DenselyOrdered X`
— the source of the sorry. The fix: replace the Cantor **isomorphism**
(bijection, requires density) with the **natural inclusion** X ⊂ ℚ
(injection, requires nothing). Extend `limit_f` from X to all of ℚ for
non-domain rationals.

**What changes**: Only `ChronicleToCountermodel.lean` (the bridge from
chronicle to countermodel). The Cantor iso pathway (~530 lines) is archived
to `Boneyard/DenseChronicle/` and replaced by a direct extension of `limit_f`
to all of ℚ (~200-300 new lines). The density case in
`CounterexampleElimination.lean` is archived alongside it (the sorry becomes
unreachable). Everything else — TaskFrame, WorldHistory, truth_at, valid,
ParametricRepresentation, RestrictedParametricTruthLemma, Soundness — is
untouched.

**What stays the same**: D = ℚ (as before). The existing parametric
infrastructure works unchanged. The FMCS/BFMCS are still over ℚ, with the
same shifted/rooted pattern using ℚ arithmetic (t − s, etc.).

### The Limit Domain X

Burgess 1982 (p. 372-373) builds X = ⋃ dom f_n by eliminating C4a and C5a
counterexamples one at a time, inserting rational points. The `.density`
counterexample kind in the formalization is a **separate** concern — it
inserts midpoints between ALL adjacent pairs regardless of formula content,
and is the ONLY code path requiring `SetConsistent g` (the sorry at CE:3570).

Without the `.density` case, the limit domain X is a general countable linear
order without endpoints. It may be discrete in some regions (where no C4a
counterexamples arise) and dense in others (where cascading C4a insertions
fill gaps). X is NOT guaranteed to be globally discrete or globally dense for
the base logic — its order structure depends on formula content.

This does not matter for the approach: X ⊂ ℚ regardless, and the natural
inclusion works for any countable sub-order of ℚ.

### Variant Flexibility

The same natural-inclusion approach works across all variants:

- **Base logic**: X ⊂ ℚ (general countable linear order), natural inclusion,
  extend `limit_f` to all of ℚ. D = ℚ.
- **Dense variant** (axiom F'⊤): add density counterexample elimination,
  X becomes globally dense. The Cantor iso X ≅ ℚ is now legitimate (and can
  be used as an alternative to inclusion). D = ℚ. The archived density code
  in `Boneyard/DenseChronicle/` is reactivated for this variant.
- **Discrete variant** (axioms G'⊥ ∧ H'⊥): the discrete axioms ensure X is
  globally discrete (X/Y operators require immediate successors). Then
  X ≅ ℤ via Mathlib's `orderIsoIntOfLinearSuccPredArch`. D = ℤ. This is a
  separate completeness theorem (`valid_discrete`) with its own construction.

### Why AddCommGroup Is Preserved (Not Weakened)

`AddCommGroup D` is **structurally load-bearing** in the TaskFrame semantics.
TaskFrame axioms use 0, +, −. WorldHistory.respects_task uses t − s. MF/TF
soundness requires time_shift + ShiftClosed. Only MF and TF (2 of 30+
axioms) need group structure for soundness; all other axioms are purely
order-theoretic. The `truth_at` definition itself uses zero group operations
— only `LinearOrder D`. We preserve this architecture entirely: D = ℚ
provides the group structure via the natural inclusion.

### Design Constraints

- The logic is NOT weakened: all axioms (including MF/TF) remain sound
- TaskFrame, WorldHistory, truth_at, valid — all UNCHANGED
- ONE semantics, ONE truth definition, ONE validity — no parallel layers
- No `bfmcs_truth_at`, no `SimpleFrame`, no `lo_valid`
- Archive, don't delete: density code goes to `Boneyard/DenseChronicle/`
  for future reuse in the dense variant

**Only the algebraic/canonical model approach is pursued for completeness.**
The representation theorem characterizes TM by showing that every consistent
formula has a model built from the logic's own proof-theoretic structure
(MCS ↔ worlds, truth lemma connecting membership and semantic truth). This
structural correspondence is the scientific contribution — it tells us what
TM *is*, not merely that it is complete.

**Decidability-based completeness is explicitly excluded as a path to the
representation theorem.** A decision procedure can establish
`valid(φ) → provable(φ)` as a bare fact, but it provides no canonical model
construction, no truth lemma, no structural correspondence between
proof-theoretic and semantic notions, and no template for extensions of the
logic. Decidability is of independent interest (see task 82, FMP track) and
may yield a follow-up result, but it does not serve the goal of frame class
characterization.

---

## Paper Alignment Programme (possible_worlds.tex; re-issued 2026-08-10)

The JPL paper (`PossibleWorlds/JPL/possible_worlds.tex`) is the single source of truth
for the basic semantic definitions; the Lean tree, `latex/` prose, and the `typst/` book
are all downstream and refactor to match it. Any conflict resolves in the paper's favour.
Cite the paper by `\label` and quote verbatim — **never by bare line number**, which has
gone stale repeatedly across this programme.

**This section was rewritten because its previous content was superseded twice over.** It
described a three-axiom frame with identity Nullity and "official validity =
maximal-history validity". Both are wrong: the frame now carries four axioms with Nullity
demoted to a derived lemma, and consequence quantifies over **total** histories, not
maximal ones. Totality and maximality are not the same predicate.

### The two load-bearing definitions

**`def:frame` carries FOUR axioms** — *Compositionality* (now a **biconditional**, which
asserts interpolation; this reverses the earlier settled decision to adopt the lax
inclusion-only law), *Seriality* (new), *Limit* (formerly "Limit Nullity"), and
*Spherical* (new — condition Sd1 from the ball-space literature, applied to the ball space
of segments). *Nullity* is demoted to a derived lemma (`lem:nullity`, choice-free from
Seriality + Limit); *Occurrence* is likewise derived (`thm:occurrence`, via Zorn, hence
AC). Supporting primitive machinery: fibers, cones, and segments, with the fibers counted
among the segments as the one-sided cases.

**Logical consequence quantifies over TOTAL world histories, i.e. possible worlds.** A
world history is a task-constrained `τ : X → W` on a nonempty convex `X ⊆ D`
(`def:world-history`); it is *total* — equivalently, a *possible world* — exactly when
`X = D`, and `H_F` is the set of total histories. `thm:extension` (every task-constrained
function on a nonempty subset of `D` extends to some total history) is what keeps the
totality restriction non-vacuous. Per the `app:gluing` footnote the **directed** case of
gluing rests on *Spherical* rather than on Compositionality alone — so the four-axiom
change and the totality change are **coupled, not independent**.

### Cluster status

The cluster's specifications were re-issued against these definitions; each task's own
description carries its `\label`-anchored quotes and an explicit survives/superseded
breakdown. Order: **420 → 414 → {415, 417} → 427**, with 419 independent and 427 last.

- **420** *(blocked)* — the four-axiom `TaskFrame`: adds Limit, Seriality, Spherical and
  the interpolation direction together, plus the segment/fiber machinery Spherical is
  stated over, the `Nonempty WorldState` field, and the `[Nontrivial D]` binder. Phases
  1-5 have landed and are green; its phase 6 phase-waits on 415's `bundleFlowFrame`.
- **414** *(not started; dep 420)* — refactor semantics to **total**-history validity:
  totality predicate + extension order on `WorldHistory`, with `TruthAt`/`valid`/
  satisfiability/consequence quantifying over total histories and **the Ω parameter
  removed entirely**. Its earlier research targeted Mathlib `IsMax` under the extension
  order; that machinery is partially reusable as the engine behind `thm:extension`, but
  the predicate in the semantics must be **totality**.
- **415** *(not started; dep 414, 420)* — completeness over the total-history semantics,
  internalized: canonical/chronicle constructions must deliver total-history countermodels
  outright, and `bundleFlowFrame` must now additionally discharge Seriality and Spherical,
  not just Limit. Rebases the targets of 169/170/408.
- **417** *(not started; dep 414, 420)* — semantic FMP, finite `WorldState` over `D = ℤ`,
  restated against the refactored `TruthAt`, plus decidable model checking there.
- **419** *(not started)* — machine-check the CO/Reynolds independence argument, and
  re-check the Q-flow countermodel sketch for conformance to the new `def:frame`
  (interpolation, Seriality, and Spherical all constrain admissible countermodels). Note
  `CO` and `TMP-CO` are `\aitem` axiom **keys** resolved by `\aref`, not `\label{}` names.
- **427** *(not started; dep all of the above)* — sync the typst book. It must be written
  from the **paper**, not from `latex/subfiles/02-Semantics.tex`, which is itself
  downstream and was stale on both counts.

Rebasing onto the 414 semantics as they land: **413** (TM conservativity bridge),
**169/170/408/361/362** (completeness programme; `cor:tm-completeness` is scoped to WEAK
completeness), **165/410/411/412** (tableau decidability). **424** (shift-set
representation) also touches `TruthAt` and sits outside the `paper-refactor` topic, so it
was not covered by the cluster re-issue — audit it before it runs. The CO axiom basis for
the Dedekind class landed separately and is archived.

**Cost note (accepted)**: the refactor temporarily regresses currently-green theorems
(restatement against the new semantics) and removes the Ω degree of freedom the old
completeness proofs exploited — the constructions must now earn full total-history
countermodels. This is the intended trade: uniformity and mathematical quality over
incremental cheapness.

**Drift warning**: the paper's definitions have moved through five waves in three days,
twice *during* an in-flight dispatch. Re-read `git log` on the paper and re-verify every
quoted definition before consuming any spec in this programme; treat a spec's pinned paper
SHA as a baseline to check, never as a guarantee.
