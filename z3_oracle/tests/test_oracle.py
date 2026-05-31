"""
Integration tests for the oracle API (oracle.py).

Tests progressive deepening, known-valid and known-invalid formulas,
timeout handling, StructuredCountermodel JSON round-trip,
and the batch API.
"""

import json
import os
import time
import pytest

from bmlogic_oracle.oracle import find_countermodel, find_countermodels_batch
from bmlogic_oracle.countermodel import StructuredCountermodel


# ---------------------------------------------------------------------------
# Helper: formula constructors
# ---------------------------------------------------------------------------

def atom(name):
    return {"tag": "atom", "name": name}

def neg(f):
    return {"tag": "neg", "inner": f}

def imp(l, r):
    return {"tag": "imp", "left": l, "right": r}

def and_(l, r):
    return {"tag": "and", "left": l, "right": r}

def or_(l, r):
    return {"tag": "or", "left": l, "right": r}

def box(f):
    return {"tag": "box", "child": f}

def untl(event, guard):
    return {"tag": "untl", "event": event, "guard": guard}

def snce(event, guard):
    return {"tag": "snce", "event": event, "guard": guard}

def bot():
    return {"tag": "bot"}


# Known valid S5 formulas (axioms of bimodal TM)
VALID_FORMULAS = [
    # K axiom: box(p->q) -> (box(p) -> box(q))  [correct nesting!]
    ("K", imp(box(imp(atom("p"), atom("q"))), imp(box(atom("p")), box(atom("q"))))),
    # T axiom: box(p) -> p
    ("T", imp(box(atom("p")), atom("p"))),
    # 4 axiom: box(p) -> box(box(p))
    ("4", imp(box(atom("p")), box(box(atom("p"))))),
    # B axiom: p -> box(neg(box(neg(p)))) i.e., p -> box(dia(p))
    ("B", imp(atom("p"), box(neg(box(neg(atom("p"))))))),
    # 5 axiom: neg(box(p)) -> box(neg(box(p)))
    ("5", imp(neg(box(atom("p"))), box(neg(box(atom("p")))))),
    # box(p->p) is a theorem
    ("box-identity", box(imp(atom("p"), atom("p")))),
    # box(top) is a theorem (top = neg(bot))
    ("box-top", box(imp(atom("p"), atom("p")))),
    # propositional tautology: p -> (q -> p)
    ("prop_k", imp(atom("p"), imp(atom("q"), atom("p")))),
    # propositional tautology: (p -> (q -> r)) -> ((p -> q) -> (p -> r))
    ("prop_s", imp(imp(atom("p"), imp(atom("q"), atom("r"))),
                   imp(imp(atom("p"), atom("q")), imp(atom("p"), atom("r"))))),
    # Double negation: neg(neg(p)) -> p (via peirce/classical)
    ("peirce-instance", imp(imp(imp(atom("p"), atom("q")), atom("p")), atom("p"))),
]

# Known invalid formulas (from bmlogic-bench)
INVALID_FORMULAS = [
    # Simple propositional: (q->q) -> q (valid antecedent, doesn't force consequent)
    ("prop-invalid-1", imp(imp(atom("q"), atom("q")), atom("q"))),
    # S4 seriality: box(p) -> p is S5 valid, but box(p) alone is not
    ("box-p-alone", box(atom("p"))),
    # Until without reaching the event: U(bot, q) requires bot to hold, impossible
    # Actually U(bot, q) at t=0 means exists s>0 with bot at s: always false
    ("until-bot", untl(bot(), atom("q"))),
    # Since at t=0: S(p, q) at t=0 is always false (no past)
    ("since-at-t0", snce(atom("p"), atom("q"))),
]


# ---------------------------------------------------------------------------
# Tests: known valid formulas -> oracle returns None
# ---------------------------------------------------------------------------

class TestValidFormulas:
    @pytest.mark.parametrize("name,formula", VALID_FORMULAS)
    def test_valid_formula_returns_none(self, name, formula):
        """Valid formulas should not have a countermodel."""
        cm = find_countermodel(formula, max_N=3, max_M=3, timeout_ms=10000)
        assert cm is None, f"Unexpected countermodel for valid formula '{name}': {cm}"


# ---------------------------------------------------------------------------
# Tests: known invalid formulas -> oracle returns StructuredCountermodel
# ---------------------------------------------------------------------------

class TestInvalidFormulas:
    def test_prop_invalid_returns_countermodel(self):
        """(q->q)->q is invalid and should get a countermodel."""
        formula = imp(imp(atom("q"), atom("q")), atom("q"))
        cm = find_countermodel(formula, timeout_ms=5000)
        assert cm is not None, "Expected countermodel for (q->q)->q"
        assert isinstance(cm, StructuredCountermodel)

    def test_countermodel_is_structurally_valid(self):
        """The countermodel should satisfy all frame axioms."""
        formula = imp(imp(atom("q"), atom("q")), atom("q"))
        cm = find_countermodel(formula, timeout_ms=5000)
        assert cm is not None
        errors = cm.validate()
        assert not errors, f"Frame axiom violations: {errors}"

    def test_box_p_is_invalid(self):
        """box(p) is not a theorem."""
        cm = find_countermodel(box(atom("p")), timeout_ms=5000)
        assert cm is not None, "box(p) should be invalid"

    def test_until_bot_is_invalid(self):
        """Until(bot, q) is always false -- always invalid."""
        cm = find_countermodel(untl(bot(), atom("q")), max_N=2, max_M=3, timeout_ms=5000)
        assert cm is not None, "Until(bot, q) should be invalid"


# ---------------------------------------------------------------------------
# Tests: StructuredCountermodel validation and serialization
# ---------------------------------------------------------------------------

class TestStructuredCountermodel:
    def test_json_round_trip(self):
        """StructuredCountermodel should serialize/deserialize correctly."""
        formula = imp(imp(atom("q"), atom("q")), atom("q"))
        cm = find_countermodel(formula, timeout_ms=5000)
        assert cm is not None

        # JSON round-trip
        cm_json = cm.to_json()
        cm2 = StructuredCountermodel.from_json(cm_json)
        assert cm2.n_worlds == cm.n_worlds
        assert cm2.m_steps == cm.m_steps
        assert cm2.worlds == cm.worlds
        assert cm2.falsifying_history == cm.falsifying_history
        assert cm2.falsifying_time == cm.falsifying_time

    def test_histories_respect_task_rel(self):
        """All histories in the countermodel should respect the task relation."""
        formula = imp(imp(atom("q"), atom("q")), atom("q"))
        cm = find_countermodel(formula, timeout_ms=5000)
        assert cm is not None
        errors = cm.validate()
        assert not errors, f"Validation errors: {errors}"

    def test_countermodel_has_correct_dimensions(self):
        """The countermodel should have valid N, M values."""
        formula = imp(imp(atom("q"), atom("q")), atom("q"))
        cm = find_countermodel(formula, timeout_ms=5000)
        assert cm is not None
        assert cm.n_worlds >= 1
        assert cm.m_steps >= 1
        assert len(cm.worlds) == cm.n_worlds
        assert cm.falsifying_history < len(cm.histories)
        assert 0 <= cm.falsifying_time < cm.m_steps


# ---------------------------------------------------------------------------
# Tests: progressive deepening
# ---------------------------------------------------------------------------

class TestProgressiveDeepening:
    def test_progressive_deepening_tries_small_bounds_first(self):
        """Simple invalid formulas should be found at N=2, M=2."""
        formula = imp(imp(atom("q"), atom("q")), atom("q"))
        cm = find_countermodel(formula, max_N=2, max_M=2, timeout_ms=5000)
        assert cm is not None
        assert cm.n_worlds == 2
        assert cm.m_steps == 2

    def test_max_bounds_limit(self):
        """When max_N=2, max_M=2, only those bounds are tried."""
        formula = imp(imp(atom("q"), atom("q")), atom("q"))
        cm = find_countermodel(formula, max_N=2, max_M=2, timeout_ms=5000)
        assert cm is not None
        # Must be within bounds
        assert cm.n_worlds <= 2
        assert cm.m_steps <= 2


# ---------------------------------------------------------------------------
# Tests: timeout handling
# ---------------------------------------------------------------------------

class TestTimeout:
    def test_timeout_returns_none_not_error(self):
        """Very short timeout should return None, not raise an exception."""
        formula = box(atom("p"))  # Invalid but should work
        # 1ms timeout -- may not have enough time
        result = find_countermodel(formula, timeout_ms=1)
        # Either None or a result (both acceptable)
        assert result is None or isinstance(result, StructuredCountermodel)

    def test_valid_formula_returns_none_on_timeout(self):
        """Valid formulas return None (whether from validity or timeout)."""
        valid = box(imp(atom("p"), atom("p")))
        cm = find_countermodel(valid, timeout_ms=10000)
        assert cm is None


# ---------------------------------------------------------------------------
# Tests: batch API
# ---------------------------------------------------------------------------

class TestBatchAPI:
    def test_batch_returns_list(self):
        """Batch API returns a list of the same length as input."""
        formulas = [
            box(imp(atom("p"), atom("p"))),  # valid
            imp(imp(atom("q"), atom("q")), atom("q")),  # invalid
            box(atom("p")),  # invalid
        ]
        results = find_countermodels_batch(formulas, timeout_ms=5000)
        assert len(results) == len(formulas)

    def test_batch_valid_returns_none(self):
        """Valid formulas in batch return None."""
        formulas = [box(imp(atom("p"), atom("p")))]
        results = find_countermodels_batch(formulas, timeout_ms=5000)
        assert results[0] is None

    def test_batch_invalid_returns_countermodel(self):
        """Invalid formulas in batch return a countermodel."""
        formulas = [imp(imp(atom("q"), atom("q")), atom("q"))]
        results = find_countermodels_batch(formulas, timeout_ms=5000)
        assert results[0] is not None

    def test_batch_mixed(self):
        """Batch with mixed valid/invalid handles correctly."""
        formulas = [
            box(imp(atom("p"), atom("p"))),  # valid
            imp(imp(atom("q"), atom("q")), atom("q")),  # invalid
        ]
        results = find_countermodels_batch(formulas, timeout_ms=5000)
        assert results[0] is None
        assert results[1] is not None


# ---------------------------------------------------------------------------
# Tests: integration with bmlogic-bench
# ---------------------------------------------------------------------------

BENCH_PATH = os.path.join(
    os.path.dirname(__file__),
    "..", "..", "data", "bmlogic-bench.jsonl"
)


class TestBmlogicBenchIntegration:
    """Spot-check integration tests against bmlogic-bench data."""

    @pytest.fixture
    def bench_sample(self):
        """Load a sample of bmlogic-bench formulas."""
        if not os.path.exists(BENCH_PATH):
            pytest.skip(f"bmlogic-bench.jsonl not found at {BENCH_PATH}")
        valid_formulas = []
        invalid_formulas = []
        with open(BENCH_PATH) as f:
            for line in f:
                entry = json.loads(line)
                if entry["label"] == "valid" and len(valid_formulas) < 10:
                    valid_formulas.append(entry["formula_ast"])
                elif entry["label"] == "invalid" and len(invalid_formulas) < 10:
                    invalid_formulas.append(entry["formula_ast"])
                if len(valid_formulas) >= 10 and len(invalid_formulas) >= 10:
                    break
        return valid_formulas, invalid_formulas

    def test_sound_on_valid_formulas(self, bench_sample):
        """The oracle should NOT find countermodels for valid formulas."""
        valid_formulas, _ = bench_sample
        false_countermodels = []
        for formula_ast in valid_formulas:
            cm = find_countermodel(formula_ast, max_N=2, max_M=2, timeout_ms=5000)
            if cm is not None:
                # Verify it's genuinely a countermodel by checking frame validity
                errors = cm.validate()
                false_countermodels.append({
                    "formula": str(formula_ast)[:100],
                    "countermodel_frame_errors": errors,
                })
        assert not false_countermodels, (
            f"Soundness violation! Found {len(false_countermodels)} false countermodels:\n"
            + "\n".join(str(fc) for fc in false_countermodels)
        )

    def test_finds_countermodels_for_some_invalid(self, bench_sample):
        """The oracle should find countermodels for at least some invalid formulas."""
        _, invalid_formulas = bench_sample
        found = 0
        for formula_ast in invalid_formulas:
            cm = find_countermodel(formula_ast, max_N=3, max_M=3, timeout_ms=5000)
            if cm is not None:
                found += 1
        # Should find at least 50% of invalid formulas in the sample
        assert found >= len(invalid_formulas) * 0.5, (
            f"Found only {found}/{len(invalid_formulas)} countermodels "
            f"for invalid formulas in the benchmark sample"
        )
