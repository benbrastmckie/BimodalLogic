# Implementation Plan: Task #958 - Path B: Resolve Irreflexivity via Alternative Approach

- **Task**: 958 - prove_canonicalr_irreflexive_irr_rule
- **Status**: [PLANNED]
- **Effort**: 4-6 hours
- **Dependencies**: Phase 1 of implementation-004.md (closure lemmas, completed)
- **Research Inputs**: specs/958_prove_canonicalr_irreflexive_irr_rule/reports/research-007.md
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implementation-004.md (Path A: Direct F Proof) confirmed that there is NO formula
psi such that `derives psi` and `neg(psi) in M` under CanonicalR(M, M). The
contradiction mechanism for irreflexivity REQUIRES constructing a second MCS M'
and deriving a contradiction between M and M'.

This plan explores the remaining viable approaches identified in research-007.md.

## Why Path A Failed

For any theorem psi, psi is in every MCS M (by MCS closure). Therefore neg(psi)
is not in M (by MCS consistency). So no formula can simultaneously be:
1. A theorem (derivable from the empty context)
2. Have its negation in an MCS M

This is a fundamental logical impossibility, not a search failure. The proof is
documented in `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean`.

## The Core Mathematical Gap

The standard naming argument (Goldblatt, BdRV) requires global freshness: a
sentence letter p not appearing in ANY formula of M. This gives:
- atomFreeSubset(M, p) = M (everything is p-free)
- M subset M' (where M' extends the naming set)
- neg(atom(p)) in M subset M' (since atom(p) not-in M by freshness)
- atom(p) in M' (from naming set) -- CONTRADICTION

In our formalization, global freshness is impossible: for every string p, either
atom(p) or neg(atom(p)) is in M. So atomFreeSubset(M, p) is a PROPER subset of M,
and M is NOT guaranteed to be a subset of M'.

The conservative extension (F+ with fresh q = Sum.inr()) resolves atomFreeSubset
but not the final contradiction: atom_ext(q) in M'_ext prevents neg_ext(atom_ext(q))
from being in M'_ext.

## Candidate Approaches

### Approach 1: Semantic Bypass via Product Frame

**Concept**: Instead of proving CanonicalR is irreflexive, construct a product
model where irreflexivity holds by construction, then transfer the truth lemma.

**Key Steps**:
1. Build canonical model with CanonicalR (may be reflexive)
2. Define product states: (MCS, Indicator) pairs where Indicator distinguishes copies
3. Define product relation that is irreflexive (different indicators guarantee different states)
4. Prove truth lemma transfers through projection
5. Use the irreflexive product model for the completeness argument

**Pros**: Avoids the naming argument entirely. Clean mathematical approach.
**Cons**: Requires modifying existing TruthLemma and FMCS infrastructure (~2000 lines).
**Effort**: 300-500 lines, HIGH integration risk
**Research basis**: research-007.md Path 2

### Approach 2: Enlarged Proof System (Zanardo-Style)

**Concept**: Replace the IRR rule with infinitely many axiom schemas that
collectively enforce irreflexivity, avoiding the naming argument entirely.

**Key Steps**:
1. Define infinite family of axiom schemas for irreflexivity
2. Prove soundness of new schemas on irreflexive dense frames
3. Modify completeness proof to use schemas instead of IRR
4. Show canonical model irreflexivity follows from schema validity

**Pros**: Avoids naming argument and conservative extension entirely.
**Cons**: Fundamental redesign of proof system. All existing infrastructure affected.
**Effort**: 500+ lines, VERY HIGH risk
**Research basis**: research-007.md Alternative

### Approach 3: Direct Naming Set Inconsistency under CanonicalR(M, M)

**Concept**: Show that the naming set `atomFreeSubset(M, p) union {atom(p), H(neg(atom(p)))}`
becomes inconsistent when combined with the CanonicalR(M, M) assumption,
by proving that the GContent transfer gap can be bridged indirectly.

**Key Insight**: Under CanonicalR(M, M), if phi in GContent(M) mentions p, we know:
- G(phi) in M (definition of GContent)
- phi in M (by CanonicalR)
- phi NOT in atomFreeSubset(M, p) (mentions p)
- But phi might or might not be in M' (the naming set extension)

The question is: can we show that for EVERY phi in GContent(M), phi must be in
the naming set extension M', even if phi mentions p?

**Approach**: Use the fact that M' is an MCS containing atomFreeSubset(M, p).
For phi mentioning p with G(phi) in M: show that neg(phi) in M' leads to
contradiction with some known facts about M and M'.

**Analysis needed**: This is essentially the sorry at line 1245 of
CanonicalIrreflexivity.lean. Need deep investigation of whether the GContent
transfer can be proven by contradiction (assuming neg(phi) in M' and deriving
absurdity).

**Effort**: 100-300 lines if viable, UNKNOWN viability
**Research basis**: The original approach, with fresh analysis

### Approach 4: Choose p Avoiding GContent(M)

**Concept**: Show that for any MCS M, there exists a string p such that no
formula in GContent(M) mentions p. This would make atomFreeSubset(M, p) contain
all of GContent(M), resolving the transfer gap.

**Key Insight**: GContent(M) is a set of formulas. Each formula mentions finitely
many atoms. If the union of all atoms mentioned by GContent(M) is a PROPER subset
of String, then we can choose p outside this union.

**Analysis needed**: Can we prove that the atom set of GContent(M) is not all of String?
This depends on the specific axiom system and MCS structure.

**Effort**: 50-200 lines if viable, UNKNOWN viability
**Research basis**: New analysis

## Recommendation

**Priority order**: Approach 4 > Approach 3 > Approach 1 > Approach 2

- Approach 4 is the lightest-weight: if GContent(M) has a fresh atom, the existing
  naming_set_consistent proof + existing CanonicalIrreflexivity infrastructure works
  with minimal modification.
- Approach 3 directly attacks the sorry at line 1245 with fresh analysis.
- Approach 1 is a fallback that avoids the issue entirely.
- Approach 2 is a last resort requiring fundamental redesign.

## Pre-Implementation Research Needed

Before implementing, the following questions need answers:

1. **Approach 4 viability**: Is `{s | exists phi in GContent(M), s in phi.atoms}` always
   a proper subset of String? Or can it be all of String?

2. **Approach 3 viability**: If phi in GContent(M) mentions p and neg(phi) in M'
   (the naming set MCS), can we derive contradiction using:
   - G(phi) in M (known)
   - phi in M (from CanonicalR)
   - atomFreeSubset(M, p) subset M' (known)
   - atom(p) in M' (known)
   - H(neg(atom(p))) in M' (known)

3. **Approach 1 scope**: How much of TruthLemma/FMCS needs modification for
   product frame integration?

## Implementation Phases (To Be Detailed After Research)

### Phase 1: Approach 4 Investigation [NOT STARTED]
- Analyze whether GContent(M) mentions finitely many or cofinitely many atoms
- If finitely many: prove existence of fresh p for GContent(M)
- If viable: modify naming_set_consistent to use GContent-fresh p

### Phase 2: Approach 3 Investigation (if Phase 1 fails) [NOT STARTED]
- Deep analysis of the GContent transfer (sorry at line 1245)
- Try to prove: if phi in GContent(M) and neg(phi) in M', then contradiction

### Phase 3: Product Frame (if Phases 1-2 fail) [NOT STARTED]
- Design product frame construction
- Implement truth lemma transfer
- Integrate with existing completeness infrastructure

### Phase 4: Integration and Cleanup [NOT STARTED]
- Remove sorries from CanonicalIrreflexivity.lean
- Run full build verification
- Create implementation summary

## Artifacts & Outputs

- Modified or new Lean files (depending on approach)
- Updated `CanonicalIrreflexivity.lean` (sorries removed)
- `specs/958_prove_canonicalr_irreflexive_irr_rule/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

1. Phase 1 closure lemmas from implementation-004 are independently useful
2. DirectIrreflexivity.lean documentation is valuable regardless of approach
3. Each approach can be abandoned independently without affecting others
