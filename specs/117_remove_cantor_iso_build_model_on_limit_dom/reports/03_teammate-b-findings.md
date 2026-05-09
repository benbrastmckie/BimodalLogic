# Teammate B Findings: CE Refactoring and Archival Plan (Round 3)

**Task**: 117 — Concrete file-by-file refactoring plan for removing density/Cantor iso
**Date**: 2026-05-08
**Focus**: What to archive, what to modify, what to add — line-by-line

## Key Findings

### 1. The Density Case Is Self-Contained (CE:3535-3783)

The `.density` branch in `eliminate_potential_counterexample` spans CE:3535-3783 (248 lines). It is the FINAL case in the match and is entirely self-contained — no other branch references density logic. The sorry at CE:3570 (`SetConsistent (χ.g pc.x pc.y)`) is contained entirely within this branch.

### 2. The `density_witness` Field Has 17 Occurrences — All Boilerplate

The `density_witness` field in `EliminationResult` (CE:638-640) appears 17 times in the file. In the non-density branches (c4_forward, c4_backward, c5_forward, c5_backward), every occurrence is a trivial absurdity discharge:
```lean
density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
```
Only the `.density` branch (CE:3697-3699 and CE:3766-3776) provides actual witnesses. Removing the field means removing 15 boilerplate lines and the 2 actual witness constructions.

### 3. The `eliminate_density_counterexample` Helper (CE:520-561) Is Unused

The standalone `eliminate_density_counterexample` function (CE:530-561, 31 lines) is defined but **never called** — the density logic in `eliminate_potential_counterexample` is inlined. This helper can be archived as-is.

### 4. `limit_dom_dense` (ChronicleConstruction:746-776) Uses `density_witness`

`limit_dom_dense` is the ONLY consumer of `density_witness` (via `omega_chain_elim_result`). It constructs a `⟨x, y, bot, bot, .density⟩` counterexample and reads the witness. Without `.density` in the enum, `limit_dom_dense` becomes unprovable — but it should be ARCHIVED, not deleted (it is mathematically correct when density elimination is active).

### 5. Limit C2' Currently Relies on Density

The comment at ChronicleConstruction:961-966 says: "The limit domain is dense (limit_dom_dense), so there are no adjacent pairs. C2' is vacuously true at the limit." The proofs `no_adjacent_in_dense` (CC:982-987) and related infrastructure assume density.

**Without density**: The limit domain IS discrete — adjacent pairs exist. C2' at the limit requires `BurgessR3Maximal (limit_f x) (limit_g x y) (limit_f y)` for adjacent pairs. The `limit_g` definition (CC:884-887) gives `limit_g(x,y) = {φ | ∀ z ∈ limit_dom, x < z → z < y → φ ∈ limit_f(z)}`. For adjacent pairs, this is `Set.univ`. So C2' requires `BurgessR3Maximal (limit_f x) Set.univ (limit_f y)`, which needs `Set.univ` to be CUD (yes — trivially) and maximal among CUD sets B with `r(f(x), B, f(y))` (yes — `Set.univ` is the largest set). **This should work but needs a new proof.**

### 6. ChronicleToCountermodel.lean — Massive Archival, Modest Replacement

Almost all of ChronicleToCountermodel.lean (lines 96-709, ~613 lines) is Cantor-iso-specific. The replacement (ℤ embedding) would be ~200-300 lines.

---

## File-by-File Refactoring Plan

### CounterexampleElimination.lean (3783 lines)

| Lines | Action | Description |
|-------|--------|-------------|
| 1-519 | KEEP | C5/C5' structures, helpers, C5/C5' elimination functions — all non-density |
| 520-561 | ARCHIVE | `eliminate_density_counterexample` helper — unused but correct |
| 562-569 | KEEP | Section header comment (update to remove density mention) |
| 570-575 | MODIFY | `PotentialCounterexampleKind`: remove `| density` variant |
| 576 | KEEP | `deriving DecidableEq, Countable` |
| 578-592 | KEEP | `PotentialCounterexample` struct — unchanged (x, y, ξ, η, kind) |
| 606-649 | MODIFY | `EliminationResult`: remove `density_witness` field (CE:638-640, 3 lines) |
| 650-667 | KEEP | `c5_forward_resolved_no_new`, `c5_backward_resolved_no_new` |
| 668-1855 | KEEP | C5 walk structures, recursive walks — all non-density |
| 1856-3534 | MODIFY | `eliminate_potential_counterexample`: remove 15 `density_witness := fun h => ...` boilerplate lines throughout the c4/c5 branches |
| 3535-3783 | ARCHIVE | The entire `.density =>` branch (248 lines) — contains the sorry |

**Net change**: Remove `| density` from enum (1 line), remove `density_witness` field (3 lines), remove 15 boilerplate discharges across other branches, archive 248+31 density lines. ~267 lines archived, ~19 lines removed from remaining code.

### ChronicleToCountermodel.lean (709 lines)

| Lines | Action | Description |
|-------|--------|-------------|
| 1-9 | MODIFY | Imports: remove `Mathlib.Order.CountableDenseLinearOrder`, remove `Mathlib.Data.Rat.Encodable`. Add `Mathlib.Data.Int.Order` (or equivalent for ℤ) |
| 10-80 | MODIFY | Module doc: update to describe ℤ embedding instead of Cantor iso |
| 82-84 | KEEP | `LimitDomSubtype` definition — still needed for the embedding source |
| 87-95 | KEEP | `Countable (LimitDomSubtype)` instance |
| 96-106 | ARCHIVE | `limitDomSubtype_denselyOrdered` — DenselyOrdered instance |
| 107-143 | KEEP | `limit_dom_no_max`, `limit_dom_no_min` — needed for NoMaxOrder/NoMinOrder on LimitDomSubtype |
| 145-172 | KEEP | `NoMaxOrder`, `NoMinOrder`, `Nonempty` instances on LimitDomSubtype |
| 174-192 | ARCHIVE | Cantor iso section: `cantor_iso` definition and docstring |
| 194-230 | ARCHIVE | `cantor_f`, `cantor_zero`, `cantor_f_at_zero`, `cantor_f_is_mcs` |
| 231-320 | ARCHIVE | `cantor_fmcs`, `shifted_cantor_fmcs`, `rooted_cantor_fmcs`, `rooted_cantor_fmcs_at_s`, box stability |
| 321-420 | ARCHIVE | `cantor_bfmcs` — the BFMCS construction via Cantor iso |
| 421-590 | ARCHIVE | `cantor_bfmcs_restricted_tc/buc/fuc` — coherence proofs via Cantor iso |
| 591-668 | ARCHIVE | `cantor_bfmcs_restricted_fuc` continued |
| 669-708 | MODIFY | `dd_countermodel_chronicle` — rewrite to use ℤ embedding instead of Cantor iso |

**Archive total**: ~540 lines (lines 96-668 minus keepers)
**Keep total**: ~80 lines (LimitDomSubtype, Countable, NoMax/NoMin, Nonempty)
**New code needed**: ~200-300 lines for ℤ embedding + FMCS/BFMCS on ℤ + coherence proofs

**New code outline**:
1. `discrete_iso : LimitDomSubtype A h_mcs ≃o ℤ` — order isomorphism (requires NoMax, NoMin, Countable, discrete; uses Mathlib's characterization of countable discrete unbounded linear orders)
2. `int_f : ℤ → Set Formula` — `fun n => limit_f(discrete_iso.symm n).val`
3. `int_fmcs : FMCS ℤ` — forward_G/backward_H from limit_forward_G/backward_H via iso
4. `int_bfmcs : BFMCS ℤ` — bundled families with modal coherence
5. `int_bfmcs_restricted_tc/buc/fuc` — coherence proofs via iso (structurally identical to Cantor versions but using discrete_iso instead of cantor_iso)
6. `dd_countermodel_chronicle` — existential witness with D = ℤ

### ChronicleConstruction.lean (~1050 lines)

| Lines | Action | Description |
|-------|--------|-------------|
| 1-719 | KEEP | Everything before "Limit Domain Density" section — omega chain, limit_f, limit_c0, C5/C5' satisfaction |
| 720-776 | ARCHIVE | `limit_dom_dense` + "Limit Domain Density" section header (56 lines) — correct but depends on density case |
| 777-960 | KEEP | C4 satisfaction in the limit, limit_f properties |
| 961-991 | MODIFY | "Limit C2' (Vacuously True)" section — rewrite. Currently says "dense, so no adjacent pairs." Without density: adjacent pairs exist, prove C2' holds because `BurgessR3Maximal f(x) Set.univ f(y)` is trivially true (Set.univ is maximal CUD, r(f(x), Set.univ, f(y)) holds since Set.univ contains all consequences). |
| 992-end | KEEP | g_content/h_content duality, remaining infrastructure |

**Archive total**: ~56 lines (`limit_dom_dense` section)
**Modify total**: ~30 lines (rewrite C2' section)

### Completeness.lean (222 lines)

| Lines | Action | Description |
|-------|--------|-------------|
| 1-127 | KEEP | `neg_consistent_of_not_derivable`, setup |
| 128-151 | KEEP | `bx_completeness` — unchanged! It calls `dd_countermodel_chronicle` which now returns D=ℤ instead of D=Rat. The existential `∃ D ...` is parametric, so the caller doesn't care which D. |
| 152-222 | MODIFY | Comments about sorry traces (update to remove Cantor iso references) |

**Net change**: Comment updates only. The theorem statement and proof are UNCHANGED.

### Boneyard Archival Structure

**Proposed directory**: `Theories/Bimodal/Boneyard/DenseChronicle/`

**Contents**:
1. `DenseCounterexampleElimination.lean` — the `.density` branch of `eliminate_potential_counterexample` + `eliminate_density_counterexample` helper. Should include the `PotentialCounterexampleKind` with `.density` and the `density_witness` field so the archived code is self-contained.
2. `DenseLimitDomain.lean` — `limit_dom_dense`, `limitDomSubtype_denselyOrdered`, `no_adjacent_in_dense` + vacuous C2'.
3. `CantorIsoCountermodel.lean` — `cantor_iso`, `cantor_f`, `cantor_fmcs`, `cantor_bfmcs`, `cantor_bfmcs_restricted_tc/buc/fuc`, and the old `dd_countermodel_chronicle` using D=Rat.

**Build status**: These files should NOT build cleanly (they'll have import issues since the enum/struct changed). Add `sorry` stubs or comment headers noting "Archived from base logic; to be restored for dense variant (task 68)." The archived code is reference material for future dense-variant work.

### Import Changes

**ChronicleToCountermodel.lean** — remove:
- `import Mathlib.Order.CountableDenseLinearOrder` (was for `Order.iso_of_countable_dense`)
- `import Mathlib.Data.Rat.Encodable` (was for Rat countability in Cantor iso)
- `import Mathlib.Algebra.Order.Archimedean.Basic` (check if still needed)

**ChronicleToCountermodel.lean** — add:
- Something for the ℤ order iso. Mathlib may not have a ready-made `Order.iso_of_countable_discrete` theorem. The classical result is: a countable linear order that is discrete, has no endpoints, and is nonempty is order-isomorphic to ℤ. This may need to be proved or found in Mathlib.

**Key Mathlib search needed**: Does Mathlib have an order isomorphism `α ≃o ℤ` for countable discrete unbounded linear orders? If not, this is the main new theorem to prove (~50-100 lines).

### ℤ Order Isomorphism: The Main New Theorem

The classical result: Every countable discrete linear order without endpoints is order-isomorphic to ℤ.

Proof sketch:
1. Pick any element x₀ ∈ X (nonempty)
2. X is discrete, so x₀ has an immediate successor succ(x₀), succ has a successor succ²(x₀), etc.
3. Similarly, x₀ has an immediate predecessor pred(x₀), pred²(x₀), etc.
4. Define φ : ℤ → X by φ(0) = x₀, φ(n+1) = succ(φ(n)), φ(n-1) = pred(φ(n))
5. φ is an order isomorphism by construction (monotone, injective, surjective)

Surjectivity requires showing every element is reachable from x₀ by finitely many successor/predecessor steps. This follows from: X is countable and has no accumulation points (discrete), so every element is finitely many steps from x₀.

**Wait — this is NOT necessarily true.** A countable discrete linear order without endpoints is NOT necessarily order-isomorphic to ℤ. Example: ℤ + ℤ (two copies of the integers, separated by a gap). This is countable, discrete, no endpoints, but not order-isomorphic to ℤ.

**Critical question**: Is the chronicle's limit domain X always connected (i.e., isomorphic to ℤ rather than ℤ+ℤ or similar)?

Looking at Burgess: the construction starts from {0} and adds points via midpoints and successors/predecessors. Every new point is within finite distance of an existing point. So the resulting order IS connected — you can always reach any point from 0 by a finite chain of successor/predecessor steps through the domain.

**Proof**: By induction on the stage n at which a point enters the domain. At stage 0: dom = {0}. At each subsequent stage, the new point z is inserted either as a midpoint (z = (x+y)/2 for existing x, y) or successor (z = x+1 or z after x). In either case, z is adjacent to existing domain points. So every point in the limit domain is connected to 0 by a finite path through the domain.

This connectivity property needs to be proved in Lean. It's specific to the chronicle construction, not a general property of countable discrete linear orders.

**Alternative approach**: Instead of proving X ≅ ℤ abstractly, define the isomorphism CONSTRUCTIVELY by induction on the chronicle stages. At each stage, maintain a partial isomorphism between the current finite domain and a finite subset of ℤ. Extend it when new points are inserted.

This might be simpler than proving the abstract characterization theorem.

## Confidence Level

**HIGH** on the archival plan — the density code is cleanly separable.

**MEDIUM** on the ℤ isomorphism — the abstract theorem (countable discrete connected unbounded ≅ ℤ) needs either a Mathlib lookup or a ~100 line proof. The connectivity of the chronicle's limit domain needs to be established.

**HIGH** on the claim that `Completeness.lean` doesn't change — the existential in `dd_countermodel_chronicle` is parametric over D.
