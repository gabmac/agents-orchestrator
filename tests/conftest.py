"""Pytest configuration for Hy tests.

Pytest's built-in ``FSCollector`` only inspects ``.py`` files. This
conftest teaches pytest to collect ``.hy`` files by:

1. Compiling the ``.hy`` source to a cached ``.py`` file.
2. Returning a ``HyModule`` whose ``path`` is the original ``.hy`` path
   (so pytest's path-based arg matching still works), but whose
   ``_getobj`` imports from the cached ``.py`` file.

The compilation cache lives in ``tests/.hy_pytest_cache/`` keyed by a
sha1 of the source.
"""

from __future__ import annotations

import ast
import hashlib
import importlib.util
import sys
from pathlib import Path

import pytest

# Make the project's source tree importable. The repo keeps modules under
# ``src/`` (e.g. ``src/diplomat``) but installs the package as
# ``finance_manager_hy`` via hatch. We don't rely on that mapping here; we
# just expose ``src`` on ``sys.path`` so tests can ``import diplomat``.
_SRC_ROOT = Path(__file__).resolve().parent.parent / "src"
if str(_SRC_ROOT) not in sys.path:
  sys.path.insert(0, str(_SRC_ROOT))

import hy  # ruff: ignore[unused-import]  - registers the Hy importer
import hy.compiler
import hy.reader

CACHE_DIR = Path(__file__).parent / ".hy_pytest_cache"


def _compile_to_py(hy_path: Path) -> Path:
  """Compile ``hy_path`` to a cached ``.py`` file and return its path."""
  CACHE_DIR.mkdir(exist_ok=True)
  src = hy_path.read_text(encoding="utf-8")
  digest = hashlib.sha256(src.encode("utf-8")).hexdigest()
  cached = CACHE_DIR / f"{hy_path.stem}_{digest}.py"
  if not cached.exists():
    tokens = hy.reader.read_many(src)
    ast_module = hy.compiler.hy_compile(tokens, "__main__", ast.Module)
    cached.write_text(ast.unparse(ast_module), encoding="utf-8")
  return cached


class HyModule(pytest.Module):
  """A Module whose public path is the original ``.hy`` file but whose
  code is loaded from the cached ``.py`` artifact."""

  @classmethod
  def from_parent(cls, parent, *, hy_path: Path, py_path: Path):
    node = super().from_parent(parent, path=hy_path)
    node._py_path = py_path
    return node

  def _getobj(self):
    spec = importlib.util.spec_from_file_location(f"_hy_test_{self.path.stem}", self._py_path)
    if spec is None or spec.loader is None:
      raise ImportError(f"Cannot import compiled test {self._py_path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def pytest_collect_file(parent, file_path):
  if file_path.suffix != ".hy":
    return None
  hy_path = Path(file_path)
  py_path = _compile_to_py(hy_path)
  return HyModule.from_parent(parent, hy_path=hy_path, py_path=py_path)
