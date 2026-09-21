# ScheduleBasedBFMCS -- Archived Dead Code

Archived: Task 130 (2026-05-20)
Source: BXCanonical/RootScopedChain.lean

## Why Archived

Schedule-based BFMCS construction using `shifted_bx_fmcs` from CanonicalModel.lean.
3 sorries in restricted temporal/until/since coherence. The Lindenbaum-based
chain step cannot preserve F-obligations across steps: F(phi) may be permanently
lost without phi ever appearing.

Superseded by Burgess 1982 chronicle construction (Chronicle/) which builds
the FMCS directly via point insertion, avoiding the F-obligation loss problem.

## Sorry Summary

| Definition | Sorry Reason |
|-----------|-------------|
| bx_bfmcs_restricted_tc | F/P-resolution: Lindenbaum step loses F-obligations |
| bx_bfmcs_restricted_buc | Until coherence: same root cause |
| bx_bfmcs_restricted_fuc | Since coherence: same root cause |

## Proved Content (may have reuse value)

- bx_bfmcs: BFMCS construction (proved, no sorry)
- fwd_chain_F_not_return: F-obligation monotonicity (proved)
- bwd_chain_P_not_return: P-obligation monotonicity (proved)
- dd_countermodel: Countermodel wiring (carries sorry from upstream)

## Task Cross-References

- Task 107: Defect-directed chain archived to Boneyard/DefectDirectedChain/
- Task 130: This archival (schedule-based pipeline)
- Completeness.lean: Routes through Chronicle/ instead
