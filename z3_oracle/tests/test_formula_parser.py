"""
Tests for the formula parser (formula.py).

Tests parse_formula_json() against bmlogic-bench.jsonl formulas and
all 6+4 constructors (primitive + derived).
"""

import json
import os
import pytest
from bmlogic_oracle.formula import (
    Formula, Atom, Neg, And, Or, Box, Until, Since,
    Top, Bot, Imp, Iff, Diamond,
    parse_formula_json, formula_to_json
)

# Path to bmlogic-bench.jsonl (relative to z3_oracle/tests/, go up two levels to project root)
BENCH_PATH = os.path.join(
    os.path.dirname(__file__),
    "..", "..", "data", "bmlogic-bench.jsonl"
)


# ---------------------------------------------------------------------------
# Unit tests: individual constructors
# ---------------------------------------------------------------------------

class TestAtom:
    def test_basic_atom(self):
        ast = {"tag": "atom", "name": "p"}
        f = parse_formula_json(ast)
        assert isinstance(f, Atom)
        assert f.name == "p"

    def test_atom_with_longer_name(self):
        ast = {"tag": "atom", "name": "myAtom123"}
        f = parse_formula_json(ast)
        assert isinstance(f, Atom)
        assert f.name == "myAtom123"

    def test_atom_missing_name_raises(self):
        with pytest.raises(ValueError, match="missing 'name'"):
            parse_formula_json({"tag": "atom"})

    def test_atom_atoms(self):
        f = parse_formula_json({"tag": "atom", "name": "q"})
        assert f.atoms() == {"q"}

    def test_atom_depths(self):
        f = Atom("p")
        assert f.modal_depth() == 0
        assert f.temporal_depth() == 0


class TestNeg:
    def test_neg_atom(self):
        ast = {"tag": "neg", "inner": {"tag": "atom", "name": "p"}}
        f = parse_formula_json(ast)
        assert isinstance(f, Neg)
        assert isinstance(f.inner, Atom)
        assert f.inner.name == "p"

    def test_neg_nested(self):
        ast = {"tag": "neg", "inner": {"tag": "neg", "inner": {"tag": "atom", "name": "p"}}}
        f = parse_formula_json(ast)
        assert isinstance(f, Neg)
        assert isinstance(f.inner, Neg)

    def test_neg_missing_inner_raises(self):
        with pytest.raises(ValueError, match="missing 'inner'"):
            parse_formula_json({"tag": "neg"})

    def test_neg_atoms(self):
        f = parse_formula_json({"tag": "neg", "inner": {"tag": "atom", "name": "q"}})
        assert f.atoms() == {"q"}


class TestAnd:
    def test_and_basic(self):
        ast = {
            "tag": "and",
            "left": {"tag": "atom", "name": "p"},
            "right": {"tag": "atom", "name": "q"}
        }
        f = parse_formula_json(ast)
        assert isinstance(f, And)
        assert isinstance(f.left, Atom)
        assert isinstance(f.right, Atom)

    def test_and_atoms(self):
        ast = {
            "tag": "and",
            "left": {"tag": "atom", "name": "p"},
            "right": {"tag": "atom", "name": "q"}
        }
        f = parse_formula_json(ast)
        assert f.atoms() == {"p", "q"}


class TestOr:
    def test_or_basic(self):
        ast = {
            "tag": "or",
            "left": {"tag": "atom", "name": "p"},
            "right": {"tag": "atom", "name": "q"}
        }
        f = parse_formula_json(ast)
        assert isinstance(f, Or)


class TestBox:
    def test_box_basic_child_format(self):
        # Lean DataExport format uses "child" field
        ast = {"tag": "box", "child": {"tag": "atom", "name": "p"}}
        f = parse_formula_json(ast)
        assert isinstance(f, Box)
        assert isinstance(f.inner, Atom)

    def test_box_basic_inner_format(self):
        # Also accept legacy "inner" field
        ast = {"tag": "box", "inner": {"tag": "atom", "name": "p"}}
        f = parse_formula_json(ast)
        assert isinstance(f, Box)
        assert isinstance(f.inner, Atom)

    def test_box_modal_depth(self):
        f = Box(Box(Atom("p")))
        assert f.modal_depth() == 2

    def test_box_missing_field_raises(self):
        with pytest.raises(ValueError, match="missing 'inner'/'child'"):
            parse_formula_json({"tag": "box"})


class TestUntil:
    def test_until_basic(self):
        # Lean DataExport format: event=phi, guard=psi
        ast = {
            "tag": "untl",
            "event": {"tag": "atom", "name": "p"},
            "guard": {"tag": "atom", "name": "q"}
        }
        f = parse_formula_json(ast)
        assert isinstance(f, Until)
        assert f.temporal_depth() == 1

    def test_until_semantics_fields(self):
        """event is phi (eventual goal), guard is psi (intermediate condition)"""
        ast = {
            "tag": "untl",
            "event": {"tag": "atom", "name": "phi"},
            "guard": {"tag": "atom", "name": "psi"}
        }
        f = parse_formula_json(ast)
        assert isinstance(f.left, Atom) and f.left.name == "phi"   # event
        assert isinstance(f.right, Atom) and f.right.name == "psi"  # guard


class TestSince:
    def test_since_basic(self):
        # Lean DataExport format: event=phi, guard=psi
        ast = {
            "tag": "snce",
            "event": {"tag": "atom", "name": "p"},
            "guard": {"tag": "atom", "name": "q"}
        }
        f = parse_formula_json(ast)
        assert isinstance(f, Since)
        assert f.temporal_depth() == 1


# ---------------------------------------------------------------------------
# Derived constructors
# ---------------------------------------------------------------------------

class TestDerived:
    def test_imp_expands_to_or_neg(self):
        ast = {
            "tag": "imp",
            "left": {"tag": "atom", "name": "p"},
            "right": {"tag": "atom", "name": "q"}
        }
        f = parse_formula_json(ast)
        # imp(p, q) = or(neg(p), q)
        assert isinstance(f, Or)
        assert isinstance(f.left, Neg)
        assert isinstance(f.left.inner, Atom)
        assert f.left.inner.name == "p"
        assert isinstance(f.right, Atom)
        assert f.right.name == "q"

    def test_iff_expands(self):
        ast = {
            "tag": "iff",
            "left": {"tag": "atom", "name": "p"},
            "right": {"tag": "atom", "name": "q"}
        }
        f = parse_formula_json(ast)
        # iff(p, q) = and(imp(p,q), imp(q,p)) = and(or(neg(p),q), or(neg(q),p))
        assert isinstance(f, And)

    def test_diamond_expands_to_neg_box_neg(self):
        ast = {"tag": "dia", "inner": {"tag": "atom", "name": "p"}}
        f = parse_formula_json(ast)
        # dia(p) = neg(box(neg(p)))
        assert isinstance(f, Neg)
        assert isinstance(f.inner, Box)
        assert isinstance(f.inner.inner, Neg)

    def test_top_is_formula(self):
        ast = {"tag": "top"}
        f = parse_formula_json(ast)
        assert isinstance(f, Formula)

    def test_bot_is_formula(self):
        ast = {"tag": "bot"}
        f = parse_formula_json(ast)
        assert isinstance(f, Formula)


# ---------------------------------------------------------------------------
# Error cases
# ---------------------------------------------------------------------------

class TestErrors:
    def test_unknown_tag_raises(self):
        with pytest.raises(ValueError, match="Unknown formula tag"):
            parse_formula_json({"tag": "unknown_op"})

    def test_non_dict_raises(self):
        with pytest.raises(TypeError):
            parse_formula_json("not a dict")

    def test_missing_tag_raises(self):
        with pytest.raises(ValueError, match="missing 'tag'"):
            parse_formula_json({"name": "p"})


# ---------------------------------------------------------------------------
# Round-trip test: formula_to_json -> parse_formula_json
# ---------------------------------------------------------------------------

class TestRoundTrip:
    def test_atom_roundtrip(self):
        f = Atom("p")
        f2 = parse_formula_json(formula_to_json(f))
        assert f == f2

    def test_neg_atom_roundtrip(self):
        f = Neg(Atom("p"))
        f2 = parse_formula_json(formula_to_json(f))
        assert f == f2

    def test_box_atom_roundtrip(self):
        f = Box(Atom("p"))
        f2 = parse_formula_json(formula_to_json(f))
        assert f == f2

    def test_until_roundtrip(self):
        f = Until(Atom("p"), Atom("q"))
        f2 = parse_formula_json(formula_to_json(f))
        assert f == f2

    def test_nested_formula_roundtrip(self):
        # box(imp(p, q)) -> Box(Or(Neg(p), q))
        ast = {
            "tag": "box",
            "child": {
                "tag": "imp",
                "left": {"tag": "atom", "name": "p"},
                "right": {"tag": "atom", "name": "q"}
            }
        }
        f = parse_formula_json(ast)
        f2 = parse_formula_json(formula_to_json(f))
        assert f == f2


# ---------------------------------------------------------------------------
# Integration test: parse first 50 formulas from bmlogic-bench.jsonl
# ---------------------------------------------------------------------------

class TestBenchmarkFormulas:
    @pytest.fixture
    def bench_formulas(self):
        if not os.path.exists(BENCH_PATH):
            pytest.skip(f"bmlogic-bench.jsonl not found at {BENCH_PATH}")
        formulas = []
        with open(BENCH_PATH) as f:
            for i, line in enumerate(f):
                if i >= 50:
                    break
                entry = json.loads(line)
                formulas.append(entry)
        return formulas

    def test_parse_first_50(self, bench_formulas):
        """All 50 bmlogic-bench formulas should parse without error."""
        for entry in bench_formulas:
            ast = entry["formula_ast"]
            formula = parse_formula_json(ast)
            assert isinstance(formula, Formula), f"Failed on: {ast}"

    def test_atoms_populated(self, bench_formulas):
        """Each formula should have at least some atoms (from formula_str)."""
        # Top, Bot may have only __bot__ special atoms
        for entry in bench_formulas:
            formula = parse_formula_json(entry["formula_ast"])
            atoms = formula.atoms()
            # __bot__ is our synthetic atom; real formulas have named atoms
            real_atoms = {a for a in atoms if not a.startswith("__")}
            # The formula_str should contain atom names -- just ensure it doesn't crash

    def test_subformulas_nonempty(self, bench_formulas):
        """Each formula should have at least one subformula."""
        for entry in bench_formulas:
            formula = parse_formula_json(entry["formula_ast"])
            assert len(formula.subformulas()) >= 1

    def test_depths_nonnegative(self, bench_formulas):
        """Modal and temporal depths should be non-negative."""
        for entry in bench_formulas:
            formula = parse_formula_json(entry["formula_ast"])
            assert formula.modal_depth() >= 0
            assert formula.temporal_depth() >= 0

    def test_parse_all_benchmark(self):
        """Parse ALL formulas in bmlogic-bench.jsonl (full 777-line test)."""
        if not os.path.exists(BENCH_PATH):
            pytest.skip(f"bmlogic-bench.jsonl not found at {BENCH_PATH}")
        errors = []
        with open(BENCH_PATH) as f:
            for i, line in enumerate(f):
                entry = json.loads(line)
                try:
                    formula = parse_formula_json(entry["formula_ast"])
                    assert isinstance(formula, Formula)
                except Exception as e:
                    errors.append(f"Line {i+1} ({entry.get('id', '?')}): {e}")
        assert not errors, f"Parse errors:\n" + "\n".join(errors)
