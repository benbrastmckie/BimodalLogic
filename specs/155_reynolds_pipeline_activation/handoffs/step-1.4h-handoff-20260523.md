# Step 1.4h Handoff: Interior Claim 1 Sorries

**Session**: sess_1779494931_55482d
**Date**: 2026-05-23

## What Was Done

### Sorry 2 (Direction 2 interior gap case) -- CLOSED

**Location**: ExpressivenessGeneral.lean, formerly at line ~2732, replaced with 170 lines.
**Goal**: False from r2_resp < rank_embed(d), r2_resp = Sum.inr g_resp (gap), x < c_inf < y.
**Proof**: Dedekind cut complement argument using complement_no_min and downward_closed.

### Sorry 1 (Direction 1 interior) -- BLOCKED

**Location**: ExpressivenessGeneral.lean, line ~2580.
**Goal**: False from rank_embed(d) < r2_resp, x < c_inf.
**Blocker**: pigeonhole h_cofinal_failure precondition fails when c_inf is carrier point.
**Recommended fix**: Prove cont_holds_cross fails at carrier-point c_inf, or use formula materialization.

## Immediate Next Action

Fix Sorry 1 at line 2580.
