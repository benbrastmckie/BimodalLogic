# Teammate B Findings: Is Fully Strict G/H/S/U the Mathematically Ideal Semantics?

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Role**: Teammate B (semantic ideality analysis)
**Builds on**: Report 10 (team research on fully strict semantics)

## Key Findings

1. **The philosophical literature overwhelmingly uses strict temporal operators.** Prior's original G and H exclude the present moment. Kamp's 1968 Since and Until are strict. The SEP calls strict versions "prevalent in philosophy." Reflexive versions are a computer science convention adopted for engineering convenience, not mathematical naturalness. **(HIGH confidence)**

2. **The Burgess-Xu axiom system was designed for reflexive S/U, but the Venema (1993) and Reynolds (1994/1996) extensions to strict S/U over discrete orders are well-established and clean.** The key addition is the discreteness axiom `F^s T -> bot U^s T` (and dual), which is exactly the `disc_next` axiom from report 10. **(HIGH confidence)**

3. **F phi = top U phi holds under BOTH strict and reflexive semantics, but with different readings.** Under reflexive: both sides mean "phi at some time >= t". Under strict: both sides mean "phi at some time > t". The equivalence is preserved; what changes is the temporal scope. **(HIGH confidence)**

4. **The T-axiom (G phi -> phi) is NOT a deep mathematical principle -- it is an artifact of reflexive semantics.** Under strict semantics, G phi means "phi at all strictly future times" and says nothing about the present. Losing G phi -> phi is mathematically correct and philosophically natural. The present is NOT the future. **(HIGH confidence)**

5. **Option C (fully strict) is the mathematically ideal choice for this project.** It aligns with the philosophical tradition, resolves the backward truth lemma blocker, and the three-place task relation with `nullity_identity` makes it natural -- d=0 is identity, d>0 is strict future, d<0 is strict past. **(HIGH confidence)**

6. **The `always` operator requires no definitional change under strict semantics.** The current definition `always phi = H phi AND phi AND G phi` already has the three-part structure that correctly separates past, present, and future. Under reflexive semantics, the middle conjunct `phi` is redundant (implied by either G phi or H phi via T-axiom). Under strict semantics, it becomes genuinely necessary, making the definition MORE honest. **(HIGH confidence)**

7. **Strict semantics generalizes better to dense orders (Q, R).** On dense orders, the density axiom `GG phi -> G phi` becomes a genuine frame condition rather than a trivial consequence. The strict approach is the only one where density is non-trivially meaningful. **(MEDIUM-HIGH confidence)**

8. **The CS convention (reflexive G, reflexive U with F phi = top U phi) is a different logic from what this project formalizes.** Pnueli-style LTL uses reflexive G where `G phi = phi AND X(G phi)`, meaning G includes the present. But that logic does not have a past direction and does not combine with S5 modality. For a bimodal tense logic in the Prior-Burgess-Kamp tradition, strict is standard. **(HIGH confidence)**

## Literature Survey: Strict vs Reflexive

### Prior (1957, 1967) -- STRICT

Prior's original tense operators F ("it is going to be the case") and P ("it has been the case") are strict -- they refer to times strictly after/before the present. His G and H are defined as duals: G = ~F~ and H = ~P~. Under strict interpretation, G phi means "at all strictly future times, phi" and H phi means "at all strictly past times, phi". The IEP article on Prior confirms: "Future statements refer strictly to times after the present, and past statements to times before it."

### Kamp (1968) -- STRICT

Kamp's doctoral dissertation introduced Since and Until using strict semantics. The SEP states: "These are the 'strict' versions of S and U, prevalent in philosophy." Kamp's expressive completeness theorem -- that every first-order definable temporal property on continuous strict linear orderings is expressible via S and U -- is proved for the STRICT versions. The reflexive versions are definable from the strict versions (`phi U psi` reflexive = `psi OR (phi U^s psi)`) but not vice versa in general, making strict versions strictly more expressive.

### Burgess (1982) and Xu (1988) -- REFLEXIVE

Burgess and Xu provided the first complete axiomatization for Since/Until, but chose REFLEXIVE versions. This was a deliberate technical choice to simplify the completeness proof -- reflexive operators avoid the irreflexivity problem in canonical model construction. The SEP supplement confirms the Burgess-Xu system covers "the reflexive versions of S and U." The first axiom listed is `G phi -> phi`, which is valid only under reflexive semantics.

### Venema (1993) -- STRICT (extending Burgess-Xu)

Venema's "Completeness via Completeness" extended the Burgess-Xu system to strict operators. For discrete linear orderings, the key addition is `F^s T -> bot U^s T` (and dual `P^s T -> bot S^s T`). These discreteness axioms assert that if there is a strictly future time, then the next-step operator X = bot U^s (meaning "at the immediate next time") is well-defined. This is sound on discrete orders where every point has an immediate successor.

### Reynolds (1992, 1994, 1996) -- STRICT

Reynolds provided axiomatizations for strict S and U over the integers (1994/1996) and over the reals without the IRR rule (1992). His integer axiomatization uses the next-time operator X, confirming that strict + discrete naturally leads to X-based reasoning.

### Gabbay, Hodkinson, Reynolds (1994) -- STRICT

The monograph "Temporal Logic: Mathematical Foundations and Computational Aspects" treats temporal logic systematically using strict operators, providing completeness proofs for various frame classes.

### Goldblatt (1992) -- STRICT

"Logics of Time and Computation" presents temporal logic with strict operators as the standard framework. The seriality axiom `G phi -> F phi` (if phi holds at all strictly future times, phi holds at some strictly future time) and the density axiom `GG phi -> G phi` are presented as frame conditions for NoMaxOrder and DenselyOrdered respectively -- both statements that are trivially satisfied or vacuous under reflexive semantics.

### Blackburn, de Rijke, Venema (2001) -- STRICT for basic tense, both discussed

The standard graduate textbook "Modal Logic" presents basic tense logic Kt with strict operators (Section 1.4). Chapter 4.4 discusses the irreflexivity problem. Chapter 7 treats Since/Until. The textbook discusses both strict and reflexive variants but takes strict as the default for tense logic.

### Pnueli (1977) / Computer Science LTL -- REFLEXIVE (different tradition)

In computer science, LTL uses reflexive G: `G phi = phi AND X(G phi)`. The "always" operator includes the current state. Until is also reflexive: `phi U psi` is satisfied if psi holds at the current or a future position. This convention was adopted for practical verification -- you want `G safe` to mean "safe now and forever", not "safe after now". However, CS-LTL is a future-only logic without past operators and without modal necessity. It is a fundamentally different system from bimodal tense logic.

### Summary Table

| Author(s) | Year | Strict/Reflexive | Operators | Domain |
|-----------|------|-----------------|-----------|--------|
| Prior | 1957-67 | **Strict** | G, H, F, P | General |
| Kamp | 1968 | **Strict** | S, U | Continuous linear orders |
| Burgess-Xu | 1982/88 | Reflexive | S, U, G, H | All linear orders |
| Reynolds | 1992 | **Strict** | S, U | Reals (no IRR) |
| Venema | 1993 | **Strict** | S, U | Discrete + general |
| Reynolds | 1994/96 | **Strict** | S, U, X, Y | Integers |
| Gabbay-Hodkinson-Reynolds | 1994 | **Strict** | S, U, G, H | Various |
| Goldblatt | 1992 | **Strict** | G, H | Various |
| Blackburn-de Rijke-Venema | 2001 | **Strict** (default) | Various | Various |
| Pnueli / CS-LTL | 1977+ | Reflexive | G, X, U (future-only) | omega-sequences |

**Verdict**: Strict is the standard in philosophical logic, the Prior tradition, and the advanced mathematical logic literature. Reflexive is a CS convention and a simplification used by Burgess-Xu to avoid technical difficulties in completeness proofs.

## Mathematical Quality Analysis

### Option A: Half-Open (Current State -- Reflexive G/H, Half-Open U/S)

**Current semantic definitions** (from Truth.lean):
- `all_future phi`: `forall s, t <= s -> truth_at ... s phi` (reflexive, includes present)
- `all_past phi`: `forall s, s <= t -> truth_at ... s phi` (reflexive, includes present)
- `untl phi psi`: `exists s, t <= s AND psi(s) AND forall r, t <= r -> r < s -> phi(r)` (reflexive start, strict end)
- `snce phi psi`: `exists s, s <= t AND psi(s) AND forall r, s < r -> r <= t -> phi(r)` (strict start, reflexive end)

**Internal consistency**: POOR. G and H are reflexive but U and S have a half-open guard interval. This means:
- `phi U psi` at t: witness s >= t, psi(s), phi on [t, s). So phi does NOT need to hold at the witness time s, but DOES need to hold at the present time t (if s > t).
- But G phi includes the present (phi(t)), creating an asymmetry: G(phi U psi) requires phi U psi at all times >= t including t itself, while phi U psi at t only requires phi on [t, s).

**F phi = top U phi**: Under these semantics, `top U phi` means "exists s >= t with phi(s)" which equals F phi = "exists s >= t with phi(s)". So the equivalence HOLDS.

**G phi -> phi**: HOLDS (by reflexivity of <=).

**The blocker**: The backward truth lemma for Until requires showing `phi U psi in mcs(t)` from semantic truth. The G-based unfold `phi U psi -> psi OR (phi AND G(phi U psi))` requires phi U psi at ALL future times >= t, which is too strong for induction.

**Alignment with literature**: Does not correspond to any standard system. Burgess-Xu's reflexive system uses fully reflexive U/S (not half-open). The half-open guard is a hybrid that fits neither tradition cleanly.

**Grade**: D. Internally inconsistent, non-standard, and blocked.

### Option B: Strict U/S Only (Reflexive G/H, Strict U/S)

**Hypothetical semantics**:
- `all_future phi`: `forall s, t <= s -> phi(s)` (reflexive)
- `untl phi psi`: `exists s, t < s AND psi(s) AND forall r, t < r -> r < s -> phi(r)` (fully strict)

**Internal consistency**: MIXED. G and H include the present, but U and S exclude it. This creates a semantic gap:
- `phi U psi` talks about strictly future times only
- G phi talks about present-and-future
- So `G(phi U psi)` means "at all times >= t, there exists a strictly future witness for phi U psi"

**F phi = top U phi**: Under strict U, `top U^s phi` means "exists s > t with phi(s)" which is strict-F. But G is reflexive, so F = ~G~ means "exists s >= t with ~phi(s) is false" = "exists s >= t with phi(s)". So `F phi != top U^s phi` -- the F derived from reflexive G includes the present, but `top U^s phi` does not. **THE EQUIVALENCE BREAKS.**

**G phi -> phi**: HOLDS (reflexive).

**Alignment with literature**: No standard system uses this combination.

**Grade**: F. The F-U equivalence breaking is a fatal flaw. This is worse than the current state.

### Option C: Fully Strict (Strict G/H/S/U)

**Proposed semantics**:
- `all_future phi`: `forall s, t < s -> phi(s)` (strict)
- `all_past phi`: `forall s, s < t -> phi(s)` (strict)
- `untl phi psi`: `exists s, t < s AND psi(s) AND forall r, t < r -> r < s -> phi(r)` (fully strict)
- `snce phi psi`: `exists s, s < t AND psi(s) AND forall r, s < r -> r < t -> phi(r)` (fully strict)

**Internal consistency**: EXCELLENT. All temporal operators uniformly use strict ordering. The present moment is never included in any temporal quantification. This is clean and uniform.

**F phi = top U phi**: Under strict semantics, F phi = ~G~phi = "exists s > t with phi(s)". And `top U^s phi` = "exists s > t with phi(s) and top on (t,s)". Since top is trivially true, `top U^s phi` = "exists s > t with phi(s)" = F phi. **THE EQUIVALENCE HOLDS.**

Similarly, P phi = top S phi holds.

**G phi -> phi**: DOES NOT HOLD. G phi means "phi at all s > t" which says nothing about t itself. This is mathematically correct: the present is not the future.

**The `always` operator**: `always phi = H phi AND phi AND G phi` becomes genuinely three-part:
- H phi: phi at all strictly past times
- phi: phi at the present
- G phi: phi at all strictly future times
The middle conjunct is no longer redundant. This is MORE honest than the reflexive version where `phi` is implied by either H phi or G phi alone.

**X and Y operators**: On discrete orders, X phi = bot U phi (next-time) and Y phi = bot S phi (previous-time) become definable. The unfold axiom becomes `phi U psi <-> X(psi OR (phi AND phi U psi))`, enabling clean induction on witness distance.

**The backward truth lemma**: As analyzed in report 10, the X-based discrete unfold enables backward induction on witness distance k = s - t, cleanly resolving the blocker.

**Alignment with literature**: Exactly matches Prior, Kamp, Venema (1993), Reynolds (1996), Goldblatt (1992), Blackburn-de Rijke-Venema (2001). This is the standard in mathematical temporal logic.

**Interaction with S5 modal component**: The S5 axioms (T: box phi -> phi, 4: box phi -> box box phi, B: phi -> box diamond phi) are purely modal and UNAFFECTED by the temporal semantics choice. Box quantifies over possible worlds/histories at the SAME time, independent of temporal ordering. The modal-temporal bridge axioms (MF: box phi -> box F phi, TF: box phi -> F box phi) remain valid because box phi holds at all histories, so for any s > t, box phi holds at s (via time-shift preservation), giving F(box phi).

**Grade**: A. Internally consistent, standard, elegant, resolves the blocker.

## Product and Long-Term Implications

### The Three-Place Task Relation Favors Strict Semantics

The task frame's `task_rel w d u` with `nullity_identity: task_rel w 0 u <-> w = u` creates a natural partition:
- d = 0: pure identity (present)
- d > 0: forward temporal (future)
- d < 0: backward temporal (past)

Under strict semantics, temporal operators quantify over d > 0 (or d < 0), NEVER d = 0. The identity case is structurally separated. This is exactly the semantic content of strict operators: the future is d > 0, not d >= 0.

Under reflexive semantics, temporal operators would need to include d = 0, which means "the present state is its own future/past state" -- semantically awkward and at odds with the physical intuition that tasks of zero duration are pure identity (no change).

**Verdict**: The three-place task relation was DESIGNED for strict semantics, even if the current implementation uses reflexive.

### "Best of Both Worlds"

Under strict semantics, one can cleanly express "phi holds now and forever" as:
- `phi AND G phi` (equivalently, `weak_future phi` which is already defined in Formula.lean)
- `always phi = H phi AND phi AND G phi` for the full omnitemporality

The derived operators `weak_future` and `weak_past` (already defined at lines 335 and 344 of Formula.lean) provide the reflexive reading when needed. Nothing is lost -- strictly more is expressible.

### Dense Orders (Q, R)

Under strict semantics over dense orders:
- The density axiom `GG phi -> G phi` becomes a genuine frame condition (not trivially valid)
- The discreteness axiom `F T -> bot U T` is NOT valid (no immediate successor)
- X and Y operators are NOT definable (no "next time" on dense orders)
- The axiom system drops the discrete axioms and adds the density axiom

This generalization is CLEANER under strict semantics. Under reflexive semantics, `GG phi -> G phi` is trivially derivable (G phi -> phi -> G phi by T-axiom and 4-axiom), so adding it as a "density" axiom is meaningless -- it tells you nothing about the frame.

Under strict semantics, the density axiom has genuine semantic content: for any s > t, there exists r with t < r < s. This is how density SHOULD work in a formal system.

### Decidability and FMP

The finite model property for tense logic Kt (with strict operators) is well-established via filtration (Goldblatt 1992, Blackburn-de Rijke-Venema 2001). Adding S5 modality preserves FMP. Adding Since/Until on discrete orders with the X-based axiom system also preserves decidability (the subformula closure is finite).

The strict/reflexive choice does NOT affect decidability. Both versions have the same decidability properties for the same frame classes. The key is that strict operators on discrete orders can simulate reflexive ones via `phi OR G phi`, so any formula in the reflexive language can be translated to the strict language.

### Reference Formalization Quality

If someone reads this ProofChecker formalization as a reference:
- **Strict semantics**: They will find it aligns with the standard mathematical logic literature (Prior, Kamp, Venema, Reynolds, Goldblatt, Blackburn et al.). The definitions will match what they learned in a graduate modal logic course.
- **Reflexive semantics**: They will find it uses a non-standard convention that requires explanation. "Why does G include the present?" is a question they will ask.
- **Half-open (current state)**: They will find it inconsistent and confusing. This is the worst option for a reference.

## Recommended Approach

**Option C: Fully Strict G/H/S/U** is the clear winner on every dimension.

### Detailed Justification

1. **Mathematical tradition**: Strict operators are standard in the Prior-Kamp tradition that this project belongs to. The project formalizes bimodal logic TM combining S5 with tense logic -- this is squarely in the philosophical logic tradition where strict is the norm.

2. **Internal consistency**: All temporal operators use the same ordering convention (strict <). No asymmetries, no special cases.

3. **Expressiveness**: Strict is strictly more expressive than reflexive. The reflexive reading is recoverable as `phi AND G phi`. The reverse is not true -- strict operators cannot be defined from reflexive ones without additional axioms.

4. **Resolves the blocker**: The X-based discrete unfold axiom enables backward induction on witness distance, directly resolving the Phase 4 truth lemma blocker that has produced 15 pages of failed attempts.

5. **Natural fit with task frames**: The `nullity_identity` axiom (d=0 is identity) makes strict operators the natural semantic choice -- temporal operators quantify over d != 0.

6. **Generalizes cleanly**: The density axiom becomes meaningful, the seriality axioms become genuine frame conditions, and extension to dense orders is straightforward.

7. **Reference quality**: Anyone reading the formalization will find standard definitions matching the literature.

### The Only Cost

The T-axiom removal cascade affects 85 occurrences across 17 files. This is significant engineering effort (report 10 estimates 8-12 hours for the derived theorems cleanup in Phase 7). However:

- The `always` definition does NOT change
- The `weak_future`/`weak_past` derived operators ALREADY exist for the reflexive reading
- Most T-axiom uses are in proof terms that extract "phi now" from "G phi" -- these become "phi now" from "always phi" via `always_to_present`, which continues to work
- The Perpetuity module already has `always_to_present`, `always_to_past`, `always_to_future` decompositions that remain valid

The cost is real but bounded, and the mathematical quality improvement is permanent.

## Confidence Levels

| Finding | Confidence |
|---------|-----------|
| 1. Literature uses strict | HIGH |
| 2. Venema/Reynolds extensions are clean | HIGH |
| 3. F=top U preserved under strict | HIGH |
| 4. T-axiom is an artifact, not a principle | HIGH |
| 5. Option C is ideal | HIGH |
| 6. `always` definition needs no change | HIGH |
| 7. Strict generalizes better to dense orders | MEDIUM-HIGH |
| 8. CS-LTL is a different tradition | HIGH |

## Appendix: Search Queries and Sources

### Web Searches
- "Burgess 1982 Since and Until axioms tense logic strict reflexive"
- "Venema 1993 Completeness via Completeness strict temporal logic"
- "Reynolds 1996 axiomatizing U and S over integer time"
- "Prior tense logic strict reflexive future operator semantics"
- "Kamp 1968 tense logic thesis strict reflexive since until"
- "LTL computer science strict next-time semantics G p includes present"
- "Pnueli 1977 LTL always operator includes current state"
- "G phi implies phi temporal logic T-axiom significance"

### Key Sources
- Stanford Encyclopedia of Philosophy, "Temporal Logic" (main article + Burgess-Xu supplement)
- Internet Encyclopedia of Philosophy, "A.N. Prior's Logic"
- Wikipedia, "Linear Temporal Logic"
- Venema (1993), "Completeness via Completeness", Diamonds and Defaults, Synthese Library 229
- Venema, Chapter 10 "Temporal Logic" survey (UvA staff page)

### Codebase Files Examined
- `Theories/Bimodal/Semantics/Truth.lean` (lines 118-129: current semantic definitions)
- `Theories/Bimodal/ProofSystem/Axioms.lean` (full file: current axiom system, 34 axioms)
- `Theories/Bimodal/Semantics/TaskFrame.lean` (lines 93-122: task_rel, nullity_identity)
- `Theories/Bimodal/Syntax/Formula.lean` (lines 326-398: always, weak_future, weak_past, some_future, some_past)
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` (lines 532-577: always decomposition theorems)
- T-axiom usage: 85 occurrences across 17 files (via grep)
