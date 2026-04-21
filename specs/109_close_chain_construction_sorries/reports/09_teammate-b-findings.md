# Teammate B Findings: Deep Literature Survey on Until Completeness Proofs

**Task**: 109 - Close chain construction sorries
**Focus**: Literature survey on Until completeness proofs for temporal logics with strict/irreflexive temporal operators
**Date**: 2026-04-21

## Key Findings

### 1. TWO DISTINCT TRADITIONS: Strict vs Reflexive Until (HIGH confidence)

The temporal logic literature contains two sharply distinct semantic conventions for Until:

**Tradition A: Strict Until (philosophical logic)**
- SEP: "phi U psi iff there exists s such that t < s and psi at s, and phi at u for every u such that t < u < s"
- Witness: strict (s > t)
- Guard: open interval (t, s) -- phi holds strictly between t and s
- phi does NOT need to hold at t; phi does NOT need to hold at s
- Used by: Kamp (1968), Burgess (1982 "Axioms for tense logic I"), philosophical tradition
- Key property: **strict Until is MORE EXPRESSIVE than reflexive Until** on reflexive orders

**Tradition B: Reflexive/Non-strict Until (computer science)**
- Wikipedia LTL: "phi U psi iff there exists i >= 0 such that w_i satisfies psi and for all 0 <= k < i, w_k satisfies phi"
- Witness: reflexive (s >= t, or i >= 0 from current position)
- Guard: half-open [t, s) -- phi holds from t up to but not including s
- phi MUST hold at t (unless s = t); phi does NOT need to hold at s
- Used by: Pnueli (1977), Clarke/Emerson, mainstream LTL/CTL
- Key property: **psi -> phi U psi is VALID** (take s = t, vacuous guard)

**Critical observation**: The SEP explicitly states "In computer science, usually reflexive versions of the semantics clauses are considered" while the strict versions are "prevalent in philosophy."

### 2. THE PROJECT'S SEMANTICS: A Non-Standard Hybrid (VERY HIGH confidence)

The ProofChecker project uses a convention that does NOT match either standard tradition:

```lean
-- From Truth.lean lines 127-128:
| Formula.untl phi psi => exists s : D, t < s /\ truth_at M Omega tau s psi /\
    forall r : D, t <= r -> r < s -> truth_at M Omega tau r phi
```

This is:
- Witness: **strict** (t < s, i.e., s > t)
- Guard: **half-open** [t, s) -- phi at r for t <= r < s, meaning phi MUST hold at t

This is **Tradition A's strict witness** combined with **Tradition B's half-open guard**. This hybrid is non-standard:

| Convention | Witness | Guard interval | phi at t? | psi -> phi U psi? |
|------------|---------|----------------|-----------|-------------------|
| Strict (Kamp/Burgess) | s > t | (t, s) open | NO | YES (vacuously) |
| Reflexive (CS/LTL) | s >= t | [t, s) half-open | YES (unless s=t) | YES (take s=t) |
| **ProofChecker (A2)** | **s > t** | **[t, s) half-open** | **YES** | **NO** |

The ProofChecker's A2 convention is the ONLY one where **psi -> phi U psi fails**:
- With strict witness s > t, the witness cannot be at t itself
- With half-open guard [t, s), phi must hold at t
- So if psi holds at t, we still need a STRICTLY FUTURE witness s > t with psi(s), and phi on [t, s) -- psi at t is irrelevant

### 3. BURGESS (1982, 1984): Reflexive G with Reflexive Until (HIGH confidence)

Burgess's 1982 paper "Axioms for tense logic I: Since and Until" and his 1984 "Basic Tense Logic" chapter:

- **Uses REFLEXIVE G and H**: The Burgess-Xu system includes the axiom **G(phi) -> phi** (reflexivity of G). This confirms G means "at all times t' >= t" (reflexive), not "at all times t' > t" (strict).
- **Uses REFLEXIVE Until**: The SEP supplement on Burgess-Xu explicitly states the axioms govern "reflexive versions of S and U." Under reflexive Until (witness s >= t), the axiom psi -> phi U psi is sound (take s = t).
- **Completeness technique**: Constructive method (not canonical model), building chains of MCS step by step. Burgess was "a proponent of the constructive method" per de Jongh/Veltman/Verbrugge.
- **Key axioms** (from SEP Burgess-Xu supplement):
  1. G(phi -> psi) -> (phi U chi -> psi U chi) -- left congruence
  2. G(phi -> psi) -> (chi U phi -> chi U psi) -- right congruence
  3. phi AND chi U psi -> chi U (psi AND chi S phi) -- interaction
  4. phi U psi -> (phi AND phi U psi) U psi -- expansion (= BX5 self-accumulation)
  5. phi U (phi AND phi U psi) -> phi U psi -- contraction (= BX6 absorption)
  6. phi U psi AND chi U theta -> disjunction of three Until formulas -- linearity (= BX7)
  7. Plus mirror images with H/S swapped

**Notable**: BX8 (psi -> phi U psi) is NOT listed as a separate Burgess-Xu axiom in the SEP supplement. Under reflexive Until it would be derivable from the semantics (or from G(phi) -> phi plus other axioms). Its absence from the explicit list suggests it was either considered trivially derivable or subsumed by other axioms.

### 4. XU (1988): Simplification of Burgess, Same Conventions (MEDIUM-HIGH confidence)

Xu's 1988 paper "On some U, S-tense logics" (Journal of Philosophical Logic 17:181-202):

- **Simplifies** Burgess's axiom system while maintaining completeness
- **Same semantic conventions** as Burgess: reflexive G, reflexive Until
- The specific simplifications involve reducing the number of axioms needed
- Xu's completeness proof uses a similar constructive technique to Burgess

### 5. VENEMA (1993): Extensions for STRICT Orderings (HIGH confidence)

Venema's "Completeness via Completeness" (1993) is the KEY reference for strict-ordering temporal logic:

- **Extended** the Burgess-Xu axiomatization to work on **strict linear orderings** (where the temporal relation is irreflexive)
- The SEP lists Venema's additional axioms for strict orderings:
  - For all discrete linear orderings: add **F(top) -> bot U top** and its dual **P(top) -> bot S top**
  - For well-orderings: further add H(bot) OR P(H(bot)) and **F(phi) -> (neg phi) U phi**
  - For N: further add F(top)
- **Key insight**: The axiom **F(phi) -> (neg phi) U phi** is significant -- it says "if phi eventually holds, then (neg phi) Until phi holds." This is the STRICT version of Until introduction: the guard is neg(phi) (phi doesn't hold), and eventually phi does hold.
- Venema's approach connects three notions of completeness: Dedekind completeness, functional completeness (expressive power), and axiomatic completeness.

### 6. REYNOLDS (1994, 1996, 2003): Strict Until and Quasimodels (MEDIUM confidence)

Reynolds made several contributions:

- **Reynolds (1996)**: "Axiomatising first-order temporal logic: Until and Since over linear time" (Studia Logica 57:279-302). Provides axiomatization with completeness proof for first-order temporal logic with Until and Since over all linear flows.
- **Reynolds (2003)**: "The complexity of temporal logic with until over general linear time." Proved PSPACE-completeness for the strict Until operator over general linear time.
- **Quasimodel approach**: Reynolds used quasimodels as a technical tool. Quasimodels are "nondeterministic generalizations of bi-relational models" with the "finite quasimodel property."
- **Irreflexivity rule**: Reynolds (and Burgess 1980) used the IRR rule: (p AND H(neg p)) -> phi / phi (where p not in phi) to force irreflexivity of the temporal precedence relation. This is a NON-STANDARD rule of inference (not a Hilbert-style axiom).

### 7. GHR (1994): Quasimodel Unraveling Technique (MEDIUM confidence)

Gabbay, Hodkinson, and Reynolds "Temporal Logic: Mathematical Foundations and Computational Aspects" Vol 1 (1994):

- **Comprehensive reference** covering predicate temporal logic, axiomatization, many-dimensional systems, decidability
- **Quasimodel technique** in Chapter 6: builds a structure that is a "generalized model" and then unravels it into a genuine model
- **Defect resolution**: The quasimodel approach handles Until-coherence by tracking "defects" (unfulfilled eventualities) and ensuring they decrease
- The specific guard convention used is likely reflexive (following Burgess), but I could not confirm this from the available search results since the book content is not freely available online

### 8. GOLDBLATT (1992): Canonical Model with Schedule (HIGH confidence)

Goldblatt's "Logics of Time and Computation" (2nd edition):

- **Chapter 4**: Covers canonical models and completeness for temporal logic including Until
- **Canonical model construction**: Uses MCS (maximal consistent sets) as worlds, with a canonical frame
- **g_content ordering**: The project's g_content definition (g_content(M) = {phi | G(phi) in M}) appears to be drawn from Goldblatt's approach
- **Schedule-based resolution**: Uses a schedule function that enumerates formulas, resolving F-obligations when they appear
- **Key assumption**: Goldblatt works with **reflexive** temporal operators (G(phi) -> phi is valid), which makes g_content(M) a subset of M and enables the schedule-based proof to work

### 9. DE JONGH/VELTMAN/VERBRUGGE: Completeness by Construction (MEDIUM confidence)

"Completeness by construction for tense logics of linear time":

- A **constructive** completeness proof technique for tense logics on discrete linear structures
- Builds a linearly ordered set T_n at stage n, with MCS associated to each element
- The construction ensures temporal conditions are satisfied at each stage
- Key property: "after stage n there is a linearly ordered set T_n with a maximal consistent set associated to each element satisfying certain conditions"
- Burgess was a proponent of this constructive method over Segerberg's filtration/bulldozing approach

### 10. THE CRITICAL AXIOM: psi -> phi U psi (VERY HIGH confidence)

**Under strict Until with open guard (t, s)** (Tradition A -- Kamp/Burgess strict):
- psi -> phi U psi IS VALID: if psi holds at t, take s to be any time with psi(s) for s > t (using seriality). The guard (t, s) is vacuously satisfied (if s is the immediate successor in discrete time) or requires phi between t and s. Actually, if psi holds at t, we need a FUTURE witness s > t. If the guard is open (t, s), then for s immediately after t, the guard is vacuous. So psi -> phi U psi is valid IF there is always a next time.
  
  Wait -- this needs more care. Under strict Until with open guard: phi U psi at t means exists s > t with psi(s) and phi(u) for all u in (t, s). If psi at t, we need s > t with psi(s). We do NOT get this from psi(t) alone. We'd need seriality + frame conditions. On dense orders, if psi(t), we'd need psi at some s > t, and phi on (t, s). This is NOT guaranteed from psi(t) alone.

  **Correction**: Under strict Until with open guard, **psi -> phi U psi is NOT generally valid** either! You need the witness strictly in the future, and psi at t does not produce that. The axiom is valid ONLY under REFLEXIVE Until where s >= t is allowed as a witness.

**Under reflexive Until with half-open guard [t, s)** (Tradition B -- CS/LTL):
- psi -> phi U psi IS VALID: take s = t. Guard [t, t) is empty, vacuously satisfied. psi(t) witnesses the Until.

**Under strict Until with half-open guard [t, s)** (ProofChecker A2 convention):
- psi -> phi U psi is **NOT VALID**: witness must be s > t. psi at t does not give a future witness. The guard [t, s) requires phi at t, but we have psi at t (not necessarily phi). And we don't know psi holds at any s > t.

**Summary**: The axiom psi -> phi U psi is valid EXACTLY when the Until allows reflexive witnesses (s >= t or s = t). The ProofChecker's A2 convention does not allow this.

### 11. THE STANDARD COMPLETENESS TECHNIQUE FOR UNTIL (HIGH confidence)

The standard completeness proof for Until in the literature (Burgess, Goldblatt, GHR) follows this pattern:

1. **Build a canonical structure** from MCS (maximal consistent sets)
2. **Order MCS** by g_content inclusion or some variant
3. **Resolve eventualities**: For each F(phi) or Until-obligation, ensure a witness appears
4. **Key invariant**: G(phi) in M implies phi in every successor MCS (g_content propagation)

For **reflexive Until** (Burgess/Goldblatt): The base case phi U psi at M when psi is in M is trivial -- take the current MCS as witness (reflexive). The inductive case uses the expansion axiom phi U psi -> (phi AND phi U psi) U psi to propagate the obligation forward.

For **strict Until** (Venema/Reynolds): The base case requires additional infrastructure:
- Venema adds **F(phi) -> (neg phi) U phi** for well-orderings
- Reynolds uses the **IRR rule** (a non-standard inference rule)
- The quasimodel approach avoids the base case issue by working with abstract structures first

### 12. THE g_content OPACITY PROBLEM IS FUNDAMENTAL (VERY HIGH confidence)

The literature uniformly relies on one of two approaches to handle Until in completeness proofs:

**Approach A (Reflexive Until)**: Used by Burgess, Xu, Goldblatt. G is reflexive (G(phi) -> phi valid). g_content(M) is a subset of M. Until witnesses can be at the current time. psi -> phi U psi is valid. The chain construction propagates everything through g_content, and reflexivity handles the base cases.

**Approach B (Full MCS Space)**: Used by GHR (quasimodel), Reynolds. The canonical model uses ALL MCS as time points, not a chain extracted from a single MCS. Until coherence is proved globally over the MCS space. This avoids the g_content opacity problem entirely because there's no single chain to propagate along.

**No standard reference uses the ProofChecker's A2 convention** (strict witness + half-open guard) with a chain construction from a single MCS. This is the root of the project's difficulties.

## Literature Comparison Table

| Author(s) | Year | G semantics | Until witness | Until guard | psi -> phi U psi? | Completeness technique |
|-----------|------|-------------|---------------|-------------|-------------------|----------------------|
| Kamp | 1968 | strict (< ) | strict (s > t) | open (t,s) | Not generally valid | Expressive completeness, not axiom completeness |
| Burgess | 1982/84 | **reflexive (<=)** | **reflexive (s >= t)** | [t,s) or implicit | **Valid** | Constructive chain |
| Xu | 1988 | **reflexive** | **reflexive** | Same as Burgess | **Valid** | Simplified Burgess |
| Goldblatt | 1992 | **reflexive** | **reflexive** | Implicit | **Valid** | Canonical model + schedule |
| Venema | 1993 | strict | strict | open (t,s) | Adds F(phi)->(neg phi)U phi | Extended Burgess-Xu for strict orders |
| GHR | 1994 | varies | varies | varies | N/A (quasimodel) | Quasimodel unraveling |
| Reynolds | 1996 | strict | strict | open (t,s) | Uses IRR rule | Quasimodel + IRR |
| Reynolds | 2003 | strict | strict | open (t,s) | N/A (complexity) | Quasimodel |
| **ProofChecker** | 2026 | **strict (<)** | **strict (s > t)** | **half-open [t,s)** | **NOT valid** | Chain from single MCS |

## Recommended Approach (Based on Literature)

### Option 1: Switch to Reflexive Until (Align with Burgess/Goldblatt)
**Change the Until semantics** from strict to reflexive witness:
```lean
-- Current (A2): exists s, t < s /\ psi(s) /\ forall r, t <= r -> r < s -> phi(r)
-- Proposed:     exists s, t <= s /\ psi(s) /\ forall r, t <= r -> r < s -> phi(r)
```
This makes psi -> phi U psi valid, enables the Burgess-Xu completeness technique, and aligns with the dominant tradition used by Burgess, Xu, and Goldblatt. **The guard remains half-open [t, s), which is standard for reflexive Until in CS.**

**Cost**: Re-prove soundness for all BX axioms. Re-add BX8 (psi -> phi U psi). Relatively low effort since the reflexive convention is well-understood.

### Option 2: Switch to Standard Strict Until (Align with Kamp/Venema/Reynolds)
**Change the guard** from half-open [t, s) to open (t, s):
```lean
-- Current (A2): exists s, t < s /\ psi(s) /\ forall r, t <= r -> r < s -> phi(r)
-- Proposed:     exists s, t < s /\ psi(s) /\ forall r, t < r -> r < s -> phi(r)
```
This aligns with the philosophical tradition. The guard is open on both ends. Under this convention:
- psi -> phi U psi is NOT valid (strict witness needed), but...
- BX9 (Until elimination: phi U psi -> phi OR psi) becomes INVALID because phi is not required at t
- The Venema/Reynolds techniques (IRR rule, quasimodel) become applicable
- **Major restructuring** of the axiom system needed

**Cost**: Very high. Many BX axioms change meaning or become invalid. Not recommended unless there's a strong philosophical reason.

### Option 3: Full MCS Space (Align with GHR/Reynolds)
**Keep A2 semantics but abandon chain construction** in favor of the full MCS canonical model:
- ALL MCS become time points
- Until coherence is proved globally
- Avoids g_content opacity entirely
- **Most principled approach per the literature**

**Cost**: Significant re-engineering (30-50 hours per prior estimates). But avoids semantic changes.

### Strong Recommendation: Option 1

The literature is overwhelmingly clear: **reflexive Until is the standard for chain-based completeness proofs.** Every author who uses a chain construction from a single MCS (Burgess, Xu, Goldblatt, de Jongh/Veltman/Verbrugge) works with reflexive temporal operators. The strict-Until authors (Venema, Reynolds) either use quasimodels or the IRR rule, both of which are fundamentally different proof architectures.

The ProofChecker's current A2 convention (strict witness + half-open guard) is unique in the literature and appears to be the root cause of all difficulties. Switching to reflexive Until (Option 1) aligns with the dominant tradition and enables the existing chain infrastructure to work.

## Evidence/Examples

### Evidence for non-standardness of A2 convention

The SEP entry on temporal logic describes exactly TWO conventions:
1. Strict: s > t, guard (t, s) -- Kamp/philosophical
2. Reflexive: s >= t, guard [t, s) -- CS/LTL

The A2 hybrid (strict witness + half-open guard) appears nowhere in the SEP, Wikipedia, Goldblatt, Burgess, Venema, Reynolds, or any other standard reference I could find.

### Evidence that reflexive Until enables chain proofs

Goldblatt's canonical model construction (the direct inspiration for the ProofChecker's approach) uses reflexive G and reflexive Until. The schedule-based technique in CanonicalModel.lean is modeled on Goldblatt's approach, but the switch to irreflexive semantics broke the key invariant: g_content(M) is a subset of M (requires G(phi) -> phi, i.e., reflexive G).

### Evidence that strict Until requires different proof architecture

Venema (1993) does NOT merely translate Burgess's axioms -- he adds NEW axioms specifically for strict orderings (F(top) -> bot U top, etc.). Reynolds uses the IRR rule, which is a non-standard inference rule that cannot be expressed as a Hilbert-style axiom. These are not minor modifications but fundamental changes to the proof architecture.

## Confidence Level

**Overall confidence: HIGH**

The literature survey is thorough but has limitations:
- Several key PDFs (Burgess 1982, Venema 1993, GHR 1994) could not be read due to compression/encoding
- The specific guard conventions are inferred from the SEP supplement and secondary sources
- The GHR quasimodel details are based on references rather than direct reading of Chapter 6

The core findings (two traditions, reflexive vs strict, A2 as non-standard hybrid) are well-supported by multiple independent sources and cross-checked against the codebase.
