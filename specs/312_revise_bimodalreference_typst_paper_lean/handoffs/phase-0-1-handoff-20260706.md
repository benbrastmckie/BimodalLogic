# Phase 0+1 Handoff (task 312)

- Phase 0 (scope decisions + completeness wiring) and Phase 1 (SYNC-MAP inventory) COMPLETE.
- Deliverable: Theories/Bimodal/typst/SYNC-MAP.md (decisions + claim table + regenerated counts).
- Key facts for downstream phases:
  - Primary completeness: `BXCanonical.completeness` (Metalogic/BXCanonical/Completeness.lean:135), NOT sorry-free; variants completeness_dense (:234), completeness_discrete (:276).
  - 42 Axiom constructors in 8 layers (Axioms.lean); Base=37, Discrete=3, Dense=2; 7 inference rules unchanged.
  - Sorries (genuine, comment-stripped): Algebraic 3, BXCanonical 4, Bundle 12, WeakCanonical 24 (22 excl. Kamp/Boneyard); total 43 (41 excl. nested Boneyard). Soundness x3 + Theorems/ (P1-P6) sorry-free.
  - Primitives: {atom, bot, imp, box, untl, snce}; G/H/F/P derived (all_future, all_past, some_future, some_past).
  - TaskFrame fields: nullity_identity, forward_comp, converse (paper: Nullity/Reflection/Compositionality, possible_worlds.tex:902-907).
  - Paper TM core (tex:1087-1105): MP, MN, TD rules + MK, MT, M5, MF, TK, T4, TB, TA, TL axioms. Lean map: TB=serial_future, TA=connect_future, TL=temp_linearity; TK/T4/TF derived (temp_k_dist_derived, temp_4_derived TemporalDerived.lean; temp_future_derived Combinators.lean:661).
- Next: Phase 2 (04-metalogic rewrite), Phase 3 (03-proof-theory), Phase 4 (01-syntax + 02-semantics).
