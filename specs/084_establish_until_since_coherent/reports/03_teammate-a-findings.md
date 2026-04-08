# Teammate A Findings: X-vs-G Mismatch Origin and Reflexive Semantics Implications

## Key Findings

1. **X is a derived operator, not primitive**: `X(phi) = bot U phi` (SuccRelation.lean:119). It was never a primitive formula constructor. The `x_content(M) = {phi | (bot U phi) in M}` extractor operates on Until formulas with bot as the left operand.

2. **Under BX reflexive semantics, X collapses to identity**: The documentation at SuccRelation.lean:564 states the critical insight: "Under reflexive Until, X(alpha) = (bot U alpha) is equivalent to alpha in any MCS (by BX8 and BX9)." BX8 gives `psi -> (phi U psi)` (reflexive intro), and BX9 gives `(phi U psi) -> (phi or psi)`. When phi = bot, BX9 gives `(bot U alpha) -> (bot or alpha) = alpha`, and BX8 gives `alpha -> (bot U alpha)`. So `X(alpha) <-> alpha` in any MCS.

3. **The X-vs-G mismatch is a legacy of the pre-BX axiom system**: The old (strict) axiom system had `until_unfold: (phi U psi) -> X(psi or (phi and (phi U psi)))`, which produced an X-wrapped formula. Chain constructions needed to propagate this through successors, but X gives x_content-level information (one step ahead) while G gives g_content-level information (all future steps). The mismatch: x_content seeds go one step, g_content seeds propagate indefinitely.

4. **The transition to reflexive semantics was incomplete**: The BX refactoring replaced axioms but left downstream consumers using the old X-based patterns. Evidence: `until_unfold_in_mcs` (SuccRelation.lean:514-520) still produces `(bot U (psi or (phi and (phi U psi))))` -- i.e., X-wrapped output -- with a sorry saying "BX: until_unfold removed, derive from BX5 self-accumulation." The old pattern persists even though X is now trivial.

5. **X and Y are incompatible with density**: `x_content(M)` requires X-K distribution (`(bot U (phi -> psi)) -> ((bot U phi) -> (bot U psi))`) and X-Det determinism (`neg(bot U phi) -> (bot U neg(phi))`). Both are marked with `sorry /- x_det removed in BX -/` and `sorry /- x_k_dist removed in BX -/` (TemporalContent.lean:274,306,351,415). These axioms are unsound on dense orders because `bot U phi` semantically means "phi holds at the current or some future time with bot holding until then" -- on dense orders, "bot holding" on any non-trivial interval is impossible, so `bot U phi` reduces to just `phi` at the current time. The X-K and X-Det axioms are discrete-only.

6. **The `until_since_coherent` sorry has a clear path under BX**: The three sorry sites (Completeness.lean:322,356,450) need `B.until_since_coherent` which requires showing forward_until and backward_until for all families. Under BX with reflexive semantics, the critical tools are:
   - BX5 (self-accumulation): `(phi U psi) -> ((phi and (phi U psi)) U psi)` -- enriches the guard
   - BX6 (absorption): `(phi U (phi and (phi U psi))) -> (phi U psi)` -- prevents infinite deferral
   - BX7 (linearity): constrains witnesses to be linearly ordered
   - BX8 (reflexive intro): `psi -> (phi U psi)` -- the current time is a valid witness
   - BX9 (elimination): `(phi U psi) -> (phi or psi)` -- gives immediate disjunction

## Technical Analysis

### Where X Appears in Active Code

| File | Line | Usage | Status |
|------|------|-------|--------|
| `TemporalContent.lean` | 119 | `x_content` definition | Active, used by deterministic chain |
| `TemporalContent.lean` | 274 | `x_k_dist` sorry | Active but sorry-blocked |
| `TemporalContent.lean` | 306 | `y_k_dist` sorry | Active but sorry-blocked |
| `TemporalContent.lean` | 351 | `x_det` sorry | Active but sorry-blocked |
| `TemporalContent.lean` | 415 | `y_det` sorry | Active but sorry-blocked |
| `SuccRelation.lean` | 514-520 | `until_unfold_in_mcs` | Active, sorry-blocked |
| `SuccRelation.lean` | 525-531 | `since_unfold_in_mcs` | Active, sorry-blocked |

### Where X Appears in Boneyard (Deprecated)

The `Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean` and `DeterministicFMCS.lean` files heavily use x_content for deterministic chain construction (`chain(n+1) = x_content(chain(n))`). These are deprecated and in Boneyard, but their approach (x_content iteration) is fundamentally discrete-only.

### The Core Mismatch Explained

Under the OLD strict semantics:
- `until_unfold` gave: `(phi U psi) -> X(psi or (phi and (phi U psi)))`
- X = "next strict time step" (only meaningful for discrete orders)
- To propagate Until through a chain: need `X(formula) in chain(n)` implies `formula in chain(n+1)`
- This works via x_content: `chain(n+1) = x_content(chain(n))`
- But for G-propagation (infinite future): no connection between X (one step) and G (all steps)

Under the NEW reflexive BX semantics:
- X(alpha) is TRIVIALLY equivalent to alpha (BX8 + BX9)
- `until_unfold` should NOT produce X-wrapped output
- Instead, BX5 (self-accumulation) + BX9 (elimination) directly give: `(phi U psi) -> (psi or (phi and (phi U psi)))`
- This is a CURRENT-TIME disjunction, not a next-step obligation
- The chain construction should use this current-time disjunction + BX5/BX6/BX7 for eventuality resolution

### Impact on Until/Since Coherence

The `until_since_coherent` definition (TemporalCoherence.lean:466-479) requires:
- **forward_until**: `(phi U psi) in fam.mcs t -> exists s >= t, psi in fam.mcs s and phi in fam.mcs r for all r in [t,s)`
- **backward_until**: Given witness s with psi and guard phi, conclude `(phi U psi) in fam.mcs t`

The X-vs-G mismatch blocks forward_until because:
1. `(phi U psi) in MCS(t)` gives (via old until_unfold) `X(stuff) in MCS(t)`
2. X-stuff means `stuff in x_content(MCS(t))` = `stuff in MCS(t+1)` (for deterministic chains)
3. But we need to find an s where psi holds, which may be arbitrarily far ahead
4. G-propagation (g_content) could carry the obligation forward indefinitely
5. X-propagation (x_content) only carries it ONE step

Under BX, the fix is to NOT use X at all:
1. `(phi U psi) in MCS(t)` gives (via BX9) `(phi or psi) in MCS(t)`
2. If psi, done (witness s = t, reflexive semantics)
3. If phi, use BX5 self-accumulation: `(phi U psi) -> ((phi and (phi U psi)) U psi)`
4. By BX10: `(phi U psi) -> F(psi)`, so a witness exists somewhere
5. The dovetailed chain's fair scheduling finds it

### `or_until_in_mcs` Already Solves the Backward Direction

SuccRelation.lean:578-594 proves `or_until_in_mcs`: `(psi or (phi and (phi U psi))) in M -> (phi U psi) in M`. This is the backward introduction for Until under reflexive semantics, already proved sorry-free using BX8 and conjunction elimination.

### The Dovetailed Chain Path

The dovetailed chain (DovetailedChain.lean) currently has 6 sorries, all from the X-vs-G mismatch (line 36-48). Its `forward_step` (line 611-626) says: "until_unfold gives: X(psi or (top and (top U psi))) in chain(n)" -- this is the old X-based reasoning. Under BX, this should instead use BX9 for a current-time disjunction.

The Completeness.lean file has three completeness paths, all blocked at `until_since_coherent`:
1. `bundle_validity_implies_provability` (line 322) -- SuccChain path
2. `restricted_bundle_validity_implies_provability` (line 356) -- restricted SuccChain
3. `dovetailed_bundle_validity_implies_provability` (line 450) -- dovetailed chain

## Recommended Changes

1. **Replace `until_unfold_in_mcs` with BX-native version** (HIGH priority):
   - Current: produces `(bot U (psi or (phi and (phi U psi))))` (X-wrapped)
   - Should be: `(psi or (phi and (phi U psi)))` directly (via BX5 + BX9)
   - BX5 gives: `(phi U psi) -> ((phi and (phi U psi)) U psi)`
   - BX9 gives: `((phi and (phi U psi)) U psi) -> ((phi and (phi U psi)) or psi)`
   - Chain: `(phi U psi) -> (psi or (phi and (phi U psi)))` -- no X needed

2. **Remove x_content/y_content from active completeness paths** (HIGH priority):
   - x_content_mcs relies on X-K and X-Det which are sorry-blocked
   - The deterministic chain (`chain(n+1) = x_content(chain(n))`) is fundamentally a discrete construction
   - Under BX reflexive semantics, the successor relation should use g_content + BX5/BX6/BX7 for Until propagation

3. **Rewrite forward_Until using BX5/BX6 absorption** (HIGH priority):
   - BX5 (self-accumulation) + BX6 (absorption) together prevent infinite deferral
   - This is the key that replaces the old Until-induction axiom
   - The proof pattern: by BX5, if phi U psi persists, the guard accumulates; by BX6, it cannot accumulate forever

4. **Keep x_content/y_content only for discrete extensions** (LOW priority):
   - If discrete completeness is needed separately, x_content can stay in discrete-specific code
   - But the main completeness path should not depend on it

## Confidence Levels

| Finding | Confidence |
|---------|-----------|
| X collapses to identity under BX | **HIGH** -- directly from BX8 + BX9, documented in codebase |
| Transition to reflexive semantics was incomplete | **HIGH** -- multiple `sorry /- removed in BX -/` markers confirm this |
| X/Y incompatible with density | **HIGH** -- X-K/X-Det require discrete structure |
| BX5+BX6 replace Until-induction | **MEDIUM** -- this is the standard Burgess/Xu approach, but the specific proof technique for until_since_coherent under BX has not been fully worked out in the codebase |
| Removing X eliminates the mismatch | **HIGH** -- if X(alpha) = alpha under BX, the mismatch between X-level and G-level disappears |
| Dovetailed chain can be fixed by removing X | **MEDIUM** -- the fix is clear in principle, but the fair-scheduling mechanism still needs to be verified against the new BX axioms |
