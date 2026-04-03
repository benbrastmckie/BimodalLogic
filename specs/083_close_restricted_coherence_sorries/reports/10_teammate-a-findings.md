# Teammate A Findings: IRR-Rules, Irreflexivity, and the Task Semantics Three-Place Relation

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Focus**: Irreflexivity in canonical model theory; interaction with the TM three-place task relation; Since/Until impact; concrete proposals for fully strict semantics
**Confidence**: HIGH (codebase analysis), MEDIUM-HIGH (literature synthesis), MEDIUM (proposal feasibility)

---

## 1. The Three-Place Task Relation: Codebase Analysis

### 1.1 Structure of `task_rel`

From `TaskFrame.lean:93-122`, the task frame is:

```
structure TaskFrame (D : Type*) [...] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

This is a genuine **three-place** relation `task_rel w d u` -- "world u is reachable from world w via a task of duration d." The duration parameter `d : D` (where D is a totally ordered abelian group, typically `Int`) plays the role of the "task" in the paper's `ExistsTask tau M1 M2`. The three-place structure is:

- **First place**: Source world state (w)
- **Second place**: Duration/task parameter (d : D) -- this IS the task, parameterized by temporal displacement
- **Third place**: Target world state (u)

### 1.2 The Canonical Task Relation

From `CanonicalConstruction.lean:157-160`:

```
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then ExistsTask M.val N.val
  else if d < 0 then ExistsTask N.val M.val
  else M = N  -- d = 0
```

Where `ExistsTask M N := g_content M <= N` (i.e., `{phi | G(phi) in M} <= N`).

**Critical observation**: The three-place structure here is **degenerate** in an important sense. The duration parameter `d` acts only as a *sign flag*:
- `d > 0`: forward accessibility (ExistsTask M N)
- `d = 0`: identity (M = N)
- `d < 0`: backward accessibility (ExistsTask N M)

The *magnitude* of d is irrelevant -- `task_rel M 1 N` and `task_rel M 1000 N` are identical propositions. This is because ExistsTask is a single binary relation (g_content inclusion) that does not vary with the actual displacement value.

### 1.3 How Truth Uses the Task Relation

From `Truth.lean:118-129`:

```
def truth_at M Omega tau t : Formula -> Prop
  | all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi  -- REFLEXIVE
  | all_past phi  => forall (s : D), s <= t -> truth_at M Omega tau s phi  -- REFLEXIVE
  | untl phi psi  => exists s, t <= s /\ psi(s) /\ forall r, t <= r -> r < s -> phi(r)  -- HALF-OPEN
  | snce phi psi  => exists s, s <= t /\ psi(s) /\ forall r, s < r -> r <= t -> phi(r)  -- HALF-OPEN
```

Truth evaluation does NOT directly reference `task_rel`. Instead, temporal operators quantify over the time parameter of a fixed world-history `tau`. The task relation enters indirectly via `WorldHistory.respects_task`, which requires that `task_rel (states s) (t - s) (states t)` for `s <= t`.

### 1.4 The `nullity_identity` Axiom and Irreflexivity

The `nullity_identity` axiom (`task_rel w 0 u <-> w = u`) is the crucial constraint. It says:
- Zero duration implies identity: if you do nothing (d=0), you stay put
- Identity implies zero duration: if source equals target, the duration must be zero

Under strict semantics, temporal operators would quantify over `s > t` (resp. `s < t`), meaning `respects_task` would only be tested at `d = t - s > 0`. The `d = 0` case would never arise from temporal quantification. This is exactly how the current canonical construction works (line 298-310): for `s <= t`, the duration `d = t - s >= 0`, and when `d = 0` we get `s = t` so states are identical.

**Key insight**: Under strict semantics, the `nullity_identity` axiom still holds (it's a frame axiom about `d = 0`, which strict operators simply never exercise). Irreflexivity in the temporal sense means the operators **skip** `d = 0`, not that `task_rel w 0 w` is false.

---

## 2. IRR-Rules and Irreflexivity in the Literature

### 2.1 The Fundamental Problem

Irreflexivity of an accessibility relation (`forall w, not(R w w)`) is **not modally definable** (Blackburn, de Rijke, Venema 2001). No modal formula (in the basic modal language) holds in exactly those frames where R is irreflexive. This is provable via bisimulation: one can find two bisimilar pointed models where one point is reflexive and the other is not.

This means the standard canonical model method fails: the canonical model for a logic intended for irreflexive frames will inevitably contain reflexive points (MCSs where `g_content(M) <= M`, i.e., `ExistsTask M M`), and no axiom can rule them out.

### 2.2 Gabbay's IRR Rule

Gabbay (1981) introduced a **non-standard inference rule** (not an axiom) to handle this:

**IRR Rule**: If `|- (p /\ H(not p)) -> A` where `p` does not occur in `A`, then `|- A`.

The intuition: "If we can derive A under the assumption that we are at an irreflexive point (witnessed by a fresh atom p that holds here but was never true in the past), then A is a theorem."

In canonical model construction, the IRR rule is used as follows:
1. When building an MCS M, if we need to show `not(R M M)` (irreflexivity),
2. We pick a fresh atom p not in any formula of g_content(M),
3. We add `p /\ H(not p)` to M (marking M as "the present moment, never visited before"),
4. The IRR rule ensures this extension is consistent,
5. Then `G(phi) in M` does NOT imply `phi in M` (because `phi` might be `not p`).

**Critical detail**: The IRR rule requires a **countably infinite supply of fresh atoms**. Since formulas are finite and sets of formulas relevant to any MCS are countable, fresh atoms always exist.

### 2.3 Bulldozing Technique

Bulldozing (Segerberg, later refined by Blackburn) is a model-theoretic alternative:

**Construction** (from Definition 3.37 in the tableau literature):
1. Identify reflexive worlds: `W_r = {w in W | R w w}`
2. Replace each reflexive world w with a pair (w,0) and (w,1)
3. Each copy sees the other but not itself
4. Copies inherit w's valuation
5. All other accessibility links are preserved

**Preservation**: Formulas true at non-reflexive worlds remain true. Formulas true at reflexive world w remain true at both copies (w,0) and (w,1).

**Limitation for TM**: Bulldozing is designed for binary accessibility relations. Adapting it to the three-place task relation requires careful treatment of the duration parameter (see Section 5).

### 2.4 Reynolds' IRR-Free Approach

Reynolds (1992, 1996) showed that for Until/Since over the reals and integers, completeness can be proved **without the IRR rule** by using a richer axiom system. The key insight: Since and Until provide enough expressive power to implicitly encode the irreflexivity information that the IRR rule would provide.

Specifically, the **unfold axioms** for strict Until:
```
phi U psi <-> psi \/ (phi /\ X(phi U psi))
```
where `X phi := bot U phi` (next-step on discrete orders), give a recursive characterization that bypasses the need for fresh atoms.

### 2.5 Venema's "Completeness via Completeness" (1993)

Venema showed that for strict Since/Until over discrete linear orders (including Z), the axiom system extends the Burgess-Xu reflexive system with discreteness axioms:
- `F^s(top) -> bot U^s top` (if there's a strict future, there's an immediate successor)
- `P^s(top) -> bot S^s top` (symmetric for past)

These axioms encode discreteness and, combined with the Since/Until axioms, provide enough structure to prove completeness without IRR.

---

## 3. Irreflexivity and the Three-Place Task Relation

### 3.1 Why the Three-Place Structure Helps

In standard binary modal logic, irreflexivity means `not(R w w)` -- a simple negation of a self-loop. The problem is that this is not modally definable.

In the TM three-place structure, "irreflexivity" has a richer meaning. The question is not merely "does M see itself?" but rather "at what duration does M see itself?" The `nullity_identity` axiom gives a precise answer: `task_rel M 0 M` always holds (and `task_rel M 0 N` implies `M = N`).

**The three-place structure resolves the irreflexivity problem by parameterization**:

Under strict semantics, temporal operators quantify over `d > 0` (future) and `d < 0` (past), never `d = 0`. The canonical task relation satisfies:
- `canonical_task_rel M d M` for `d > 0` iff `ExistsTask M M` iff `g_content(M) <= M`
- `canonical_task_rel M 0 M` always (by nullity_identity)

The reflexivity of `ExistsTask M M` (which holds by the T-axiom) is harmless under strict semantics because **the temporal operators never evaluate at d = 0**. The `nullity_identity` axiom at `d = 0` is a structural fact about identity, not a temporal accessibility claim.

This is the crucial insight: **we do not need irreflexivity of ExistsTask. We need the temporal operators to skip d = 0, which is purely a matter of the semantic definition (`<` vs `<=`), not a frame property.**

### 3.2 What Changes Under Strict Semantics

Under strict G (`forall s > t, phi(s)`), the truth lemma needs to establish:

**Forward direction** (MCS -> truth): If `G(phi) in fam.mcs(t)`, then for all `s > t`, `phi` is true at `(fam, s)`.

This works because `s > t` means `d = s - t > 0`, so `canonical_task_rel` requires `ExistsTask (mcs t) (mcs s)`, which gives `phi in mcs(s)` from `G(phi) in mcs(t)`. No d = 0 case arises.

**Backward direction** (truth -> MCS): If for all `s > t`, `phi in fam.mcs(s)`, then `G(phi) in fam.mcs(t)`.

This is the hard direction. Currently (reflexive), the T-axiom `G(phi) -> phi` gives `g_content(M) <= M` for free. Under strict semantics, `G(phi) -> phi` is invalid, so we cannot derive `g_content(M) <= M`. Instead, we need:

- The **4-axiom** `G(phi) -> G(G(phi))` still holds (transitivity of `<`)
- The **contrapositive**: if `G(phi) not in mcs(t)`, then `not G(phi) in mcs(t)`, and we need to find some `s > t` where `phi` fails
- This is exactly **canonical backward witness construction**: from `F(not phi) in mcs(t)`, find an MCS `W` with `not phi in W` and `ExistsTask (mcs t) W`

The existing `canonical_backward_F` theorem in `CanonicalFrame.lean` already handles this. The key question is whether the witness W can be placed at `t + 1` (for discrete orders) or at some arbitrary `s > t`.

### 3.3 The Task Parameter Provides Structure for Witness Placement

In the binary accessibility setting, when we construct a witness W for `F(psi) in M`, we only know `ExistsTask M W` (i.e., `g_content(M) <= W`). We have no information about *how far* W is from M.

In the three-place task setting, the duration parameter gives us explicit control:
- `canonical_task_rel M 1 W` means W is the immediate successor
- `canonical_task_rel M k W` for `k > 1` means W is k steps away

For the discrete case over Z, this is exactly what the `Succ` relation provides (SuccRelation.lean):
```
def Succ (u v : Set Formula) : Prop :=
  g_content u <= v /\ f_content u <= v \/ f_content v
```

The Succ relation is a **refinement** of ExistsTask that captures immediate succession. Under strict semantics with Since/Until, the definable `X phi = bot U phi` gives direct access to the successor, and the Succ relation becomes the canonical interpretation of X.

---

## 4. How Since/Until Change the Irreflexivity Picture

### 4.1 Definability of Next-Step Operators

Under fully strict semantics:
- `X phi := bot U phi` means "there exists a strictly future s with phi(s), and bot holds at all times strictly between now and s" -- since bot is never true, this means s is the *immediate* next time point
- `Y phi := bot S phi` means the immediate previous time point satisfies phi

These operators are definable ONLY under strict semantics. Under reflexive Until (`t <= s`), `bot U phi` reduces to `phi` (take `s = t` as witness, vacuous guard).

### 4.2 X-Based Axioms Bypass IRR Entirely

The standard unfold axiom for G uses reflexive semantics:
```
(current) until_unfold: phi U psi -> psi \/ (phi /\ G(phi U psi))
(current) until_intro:  psi \/ (phi /\ G(phi U psi)) -> phi U psi
```

Under strict semantics with X, the **discrete unfold** becomes:
```
phi U psi <-> psi \/ (phi /\ X(phi U psi))
```

This is enormously simpler because:
1. **No G quantifier**: Instead of "phi U psi at ALL future times", we need "phi U psi at the NEXT time step"
2. **Discrete induction**: The backward truth lemma becomes: from `phi U psi` at `t+1` and `phi` at `t`, derive `phi U psi` at `t` -- a single step of discrete induction
3. **No IRR rule needed**: The X operator encodes "immediate successor" directly, which on Z is unambiguous. The canonical model for X is the Succ relation, which already exists in the codebase
4. **No bulldozing needed**: Since we never need to prove `not(ExistsTask M M)`, there is no reflexive point to bulldoze

### 4.3 The Since/Until Axiom System Under Fully Strict Semantics

Based on the Burgess-Xu-Venema tradition, the axiom system for strict S/U over Z is:

**Core axioms** (adapted from Burgess-Xu supplement of SEP):
1. `G(phi -> psi) -> (chi U phi -> chi U psi)` (congruence)
2. `G(phi -> psi) -> (phi U chi -> psi U chi)` (congruence)
3. `phi /\ chi U psi -> chi U (psi /\ chi S phi)` (connectedness)
4. `phi U psi -> (phi /\ phi U psi) U psi` (expansion)
5. `phi U (phi /\ phi U psi) -> phi U psi` (contraction)
6. `(phi U psi) /\ (phi' U psi') -> (phi U (psi /\ phi' U psi')) \/ (phi' U (psi' /\ phi U psi))` (linearity)

**Strict extensions** (Venema 1993):
7. `F(top) -> bot U top` (discreteness: strict future implies immediate successor)
8. `P(top) -> bot S top` (discreteness: strict past implies immediate predecessor)

**Plus mirror axioms** (H for G, S for U) and the standard:
9. `phi -> G(P(phi))` and `phi -> H(F(phi))` (interaction axioms, replacing T-axioms)
10. Seriality: `F(top)` and `P(top)` (Z has no endpoints)

Note: The T-axioms `G(phi) -> phi` and `H(phi) -> phi` are **dropped**.

### 4.4 Impact on the Current Axiom System

The current axioms in `Axioms.lean` that must change:

| Current Axiom | Strict Replacement | Reason |
|---|---|---|
| `temp_t_future: G(phi) -> phi` | DROPPED | Invalid under strict semantics |
| `temp_t_past: H(phi) -> phi` | DROPPED | Invalid under strict semantics |
| `until_intro: psi \/ (phi /\ G(phi U psi)) -> phi U psi` | `psi \/ (phi /\ X(phi U psi)) -> phi U psi` | X replaces G for discrete unfold |
| `until_unfold: phi U psi -> psi \/ (phi /\ G(phi U psi))` | `phi U psi -> psi \/ (phi /\ X(phi U psi))` | X replaces G for discrete unfold |
| `until_induction` | Reformulate with X | Induction principle uses successor instead of all-future |
| `since_intro`, `since_unfold`, `since_induction` | Symmetric changes with Y | Y replaces H for discrete unfold |

New axioms to add:
- `phi -> G(P(phi))` (TA: present recoverable from future-past)
- `phi -> H(F(phi))` (TA_dual: present recoverable from past-future)
- `F(top) -> bot U top` (discreteness axiom, forward)
- `P(top) -> bot S top` (discreteness axiom, backward)
- `F(top)` and `P(top)` (seriality, may already be derivable from existing axioms)

---

## 5. Bulldozing for the Three-Place Task Relation

### 5.1 Can Bulldozing Be Adapted?

Standard bulldozing replaces reflexive world w with pair (w,0), (w,1). For the three-place task relation, the adaptation would be:

For each `M` with `ExistsTask M M`:
1. Create `(M, 0)` and `(M, 1)`
2. Define `canonical_task_rel' (M,i) d (N,j)`:
   - If `M = N` and `d = 0`: FALSE (irreflexive by construction)
   - If `M = N`, `i != j`, and `d = 1`: TRUE (copies see each other at distance 1)
   - Otherwise: inherit from original relation

**Problem**: This breaks `nullity_identity`. In the bulldozed model, `task_rel (M,0) 0 (M,1)` must be false (since `(M,0) != (M,1)`), which is correct. But we also need `task_rel (M,0) 0 (M,0)` to be equivalent to `(M,0) = (M,0)`, which is true. Wait -- `nullity_identity` says `task_rel w 0 u <-> w = u`. After bulldozing, `task_rel (M,0) 0 (M,0)` would need to be true (since `(M,0) = (M,0)`), which is fine.

The real issue is `forward_comp`. If `task_rel (M,0) 1 (M,1)` (copies see each other) and `task_rel (M,1) 1 (N,j)` for some N accessible from M at distance 2, we need `task_rel (M,0) 2 (N,j)`. This requires that the bulldozed relation composes correctly, which depends on the specific chain structure.

### 5.2 Why Bulldozing Is Unnecessary for TM

The critical realization from Section 3 is that **bulldozing is unnecessary** for the TM task semantics:

1. The three-place structure already separates "identity" (d = 0) from "temporal accessibility" (d > 0 or d < 0)
2. Under strict semantics, temporal operators only exercise `d != 0`
3. The canonical model can have `ExistsTask M M` (reflexive at the binary level) without any semantic consequence, because the truth evaluation never queries `d = 0` through temporal quantifiers
4. `nullity_identity` handles `d = 0` correctly: it means identity, nothing more

**This is the fundamental advantage of the three-place parameterization**: by making the duration explicit, the "reflexivity" that plagues binary accessibility relations becomes a non-issue. The irreflexivity that strict semantics requires is built into the semantic clauses (`<` instead of `<=`), not into the frame.

---

## 6. Concrete Proposals

### Proposal A: Semantic Switch with No Frame Changes (RECOMMENDED)

**Approach**: Change only the semantic definitions in `Truth.lean` from `<=` to `<` for G/H and from half-open to fully strict for U/S. Keep `canonical_task_rel` exactly as is. No IRR rule. No bulldozing.

**Why it works**: The canonical task relation already handles the duration parameterization correctly:
- `d > 0`: ExistsTask (forward accessibility) -- used by strict G
- `d = 0`: identity -- never queried by strict temporal operators
- `d < 0`: ExistsTask reverse -- used by strict H

The truth lemma proof changes:
- **Forward G**: `G(phi) in mcs(t)` and `s > t` gives `d = s - t > 0`, so `canonical_task_rel` requires `ExistsTask (mcs t) (mcs s)`, giving `phi in mcs(s)`. Same as current, just `s > t` instead of `s >= t`.
- **Backward G**: Need to show `G(phi) in mcs(t)` from `forall s > t, phi in mcs(s)`. This is the hard direction. Use: if `not G(phi) in mcs(t)`, then `F(not phi) in mcs(t)`, and by `canonical_backward_F`, there exists W with `ExistsTask (mcs t) W` and `not phi in W`. Place W at `t + 1` using the Succ construction.
- **Forward/Backward U/S**: Use X-based discrete induction, leveraging the Succ relation.

**Confidence**: HIGH. The three-place structure makes this the natural approach.

**Proof engineering complexity**: MEDIUM. The canonical frame and task relation need NO changes. The changes are in:
1. `Truth.lean` semantic definitions (small)
2. Axiom system (moderate -- drop T-axioms, reformulate U/S axioms)
3. Soundness proofs (moderate -- new axiom validities)
4. Truth lemma backward direction (significant -- new proof strategy using Succ/X)
5. Remove `CanonicalIrreflexivity.lean` content about reflexivity (it becomes irrelevant)

### Proposal B: Hybrid/IRR Rule Extension

**Approach**: Add the Gabbay IRR rule as a derivation rule to the proof system. Use fresh atoms in the canonical model construction to ensure irreflexivity.

**Why NOT recommended for TM**:
1. The IRR rule requires extending the proof system with a non-standard rule, complicating the Lean formalization significantly
2. Fresh atom management in a Lean 4 inductive type is complex
3. The three-place structure makes this unnecessary (Proposal A avoids the problem entirely)
4. Reynolds (1992) showed Since/Until alone provide enough expressiveness to avoid IRR

**Confidence**: LOW for necessity, HIGH for theoretical soundness.

### Proposal C: Bulldozing Post-Hoc

**Approach**: Build the canonical model with reflexive ExistsTask, then bulldoze to get an irreflexive model.

**Why NOT recommended**:
1. Bulldozing is designed for binary accessibility; adapting to three-place relations requires non-trivial construction
2. Compositionality (`forward_comp`) in the bulldozed model is difficult to verify
3. The three-place structure makes this unnecessary (see Proposal A)
4. Would require proving that truth is preserved through bulldozing, which is a major proof engineering effort

**Confidence**: LOW for practicality.

---

## 7. Summary of Key Findings

### Finding 1: The Three-Place Task Relation Resolves the Irreflexivity Problem
The duration parameter `d` in `task_rel w d u` separates identity (`d = 0`, governed by `nullity_identity`) from temporal accessibility (`d != 0`, governed by ExistsTask). Under strict semantics, temporal operators only query `d != 0`, so reflexivity of ExistsTask at the binary level is semantically harmless. **No IRR rule or bulldozing is needed.**

### Finding 2: The Canonical Task Relation Needs No Changes
`canonical_task_rel` already handles all three cases correctly. The `d = 0 -> M = N` case is identity (not temporal accessibility). The `d > 0` case uses ExistsTask. Switching to strict semantics only changes which cases the *semantic evaluation* exercises, not the frame definition.

### Finding 3: Since/Until with X/Y Bypass the Backward Truth Lemma Difficulty
Under strict semantics, `X phi = bot U phi` and `Y phi = bot S phi` are definable. The discrete unfold axiom `phi U psi <-> psi \/ (phi /\ X(phi U psi))` converts the infinite-quantifier backward truth lemma into single-step discrete induction, resolving the "G too strong" problem identified in report 09.

### Finding 4: The Existing Succ Relation Is the Canonical X
`SuccRelation.lean` already defines `Succ u v = g_content u <= v /\ f_content u <= v \/ f_content v`, which is exactly the canonical interpretation of the next-step operator X. Under strict semantics, `X phi` true at `mcs(t)` iff `phi in mcs(t+1)`, which is captured by the Succ chain.

### Finding 5: Reynolds' IRR-Free Approach Is the Right Model
Reynolds (1992, 1996) and Venema (1993) showed that Since/Until over discrete linear orders like Z can be axiomatized without the IRR rule. The expressive power of S/U (definability of X/Y via `bot U`/`bot S`) provides the successor structure that makes IRR unnecessary. This aligns perfectly with Proposal A.

### Finding 6: Algebraic Cost of Strict Semantics Is Acceptable
Dropping the T-axioms means G/H are no longer interior operators (just normal modal operators). This loses the S4.3.1 algebraic classification. However, for TM over Z, the algebraic structure provided by Since/Until and the discrete group structure of Z is far richer than what the interior operator property provides. The loss is theoretical elegance, not practical capability.

---

## 8. Confidence Assessment

| Claim | Confidence | Basis |
|---|---|---|
| Three-place structure eliminates need for IRR rule | HIGH | Direct analysis of `task_rel` parameterization and `nullity_identity` |
| Canonical task relation needs no changes | HIGH | Code inspection of `canonical_task_rel` shows d=0 case is identity |
| X/Y definable from strict U/S | HIGH | Standard result (Kamp 1968, Burgess 1982, Venema 1993) |
| Succ relation is canonical X | HIGH | Direct comparison of Succ definition with X semantics |
| Reynolds' approach applies to TM | MEDIUM-HIGH | TM is more complex (bimodal S5 + temporal), but core technique transfers |
| Backward truth lemma resolves via discrete induction | MEDIUM | Requires actual proof construction; theory is sound but engineering unverified |
| Bulldozing is unnecessary | HIGH | Follows from three-place structure analysis |
| 80-120 hour estimate for full migration | MEDIUM | Teammate C's estimate from report 09 seems accurate given scope |

---

## References

- Blackburn, de Rijke, Venema (2001). *Modal Logic*. Cambridge University Press. Ch. 4.4 (irreflexivity, bulldozing), Ch. 7 (derivation rules).
- Burgess, J. (1982). "Axioms for tense logic I: Since and Until." *NDJFL* 23(4).
- Gabbay, D. (1981). "An irreflexivity lemma with applications to axiomatizations of conditions on linear frames." In Monnich (ed.), *Aspects of Philosophical Logic*.
- Reynolds, M. (1992). "An axiomatization for Until and Since over the reals without the IRR rule." *Studia Logica* 51:165-193.
- Reynolds, M. (1996). "Axiomatizing U and S over integer time." In *Advances in Modal Logic* vol. 1.
- Venema, Y. (1993). "Completeness via Completeness: Since and Until." In de Rijke (ed.), *Diamonds and Defaults*, Synthese Library 229, Kluwer.
- Xu, M. (1988). "On some U,S-tense logics." *J. Phil. Logic* 17(2).
- SEP, "Temporal Logic" entry, Burgess-Xu supplement.

### Codebase References

- `TaskFrame.lean:93-122` -- three-place task relation definition
- `CanonicalConstruction.lean:157-160` -- canonical task relation
- `CanonicalIrreflexivity.lean:148-159` -- reflexivity proof (becomes irrelevant)
- `Truth.lean:118-129` -- truth evaluation (change site)
- `SuccRelation.lean:59-60` -- Succ relation (canonical X)
- `Axioms.lean:290,304` -- T-axioms (to be dropped)
- `Axioms.lean:459-523` -- U/S axioms (to be reformulated)
- `typst/chapters/06-notes.typ:110-267` -- design choice documentation
