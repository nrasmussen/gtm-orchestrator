#!/usr/bin/env python3
"""test_dispatch.py — unit tests for orchestrator/dispatch.py.

Covers the contract:
  * empty stdin still produces a valid JSON payload for the handler
  * non-JSON stdin is wrapped under "raw_text"
  * argv action overrides stdin payload "action"
  * missing handler exits non-zero
  * extra argv args are forwarded to the handler

Tests run by piping into a small shim handler that echoes the parsed
payload to stderr; we capture stderr and assert on it.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import textwrap
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
DISPATCH = os.path.join(ROOT, "orchestrator", "dispatch.py")


SHIM = textwrap.dedent(
    """\
    #!/usr/bin/env python3
    import json, sys
    raw = sys.stdin.buffer.read()
    try:
        payload = json.loads(raw.decode('utf-8')) if raw.strip() else {}
    except Exception as e:
        payload = {"_parse_error": str(e), "_raw": raw.decode('utf-8', errors='replace')}
    payload["_argv"] = sys.argv[1:]
    sys.stderr.write(json.dumps(payload))
    sys.exit(0)
    """
)


class DispatchTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmpdir = tempfile.mkdtemp(prefix="gtm-dispatch-test-")
        py_dir = os.path.join(self.tmpdir, "py")
        os.makedirs(py_dir)
        self.shim_path = os.path.join(py_dir, "shim.py")
        with open(self.shim_path, "w") as f:
            f.write(SHIM)
        os.chmod(self.shim_path, 0o755)

        # Write a thin dispatch wrapper that points at our tmp handlers dir.
        self.dispatch_copy = os.path.join(self.tmpdir, "dispatch.py")
        with open(DISPATCH, "r") as src:
            content = src.read()
        content = content.replace(
            'HERE = os.path.dirname(os.path.abspath(__file__))',
            f'HERE = {json.dumps(self.tmpdir)}',
        )
        with open(self.dispatch_copy, "w") as f:
            f.write(content)

    def _run(self, argv: list, stdin_bytes: bytes) -> tuple:
        proc = subprocess.run(
            [sys.executable, self.dispatch_copy] + argv,
            input=stdin_bytes,
            capture_output=True,
        )
        try:
            payload = json.loads(proc.stderr.decode("utf-8")) if proc.stderr else None
        except json.JSONDecodeError:
            payload = None
        return proc.returncode, payload, proc.stderr

    def test_empty_stdin_with_action(self):
        rc, payload, _ = self._run(["shim", "do-thing"], b"")
        self.assertEqual(rc, 0)
        self.assertEqual(payload.get("action"), "do-thing")

    def test_argv_action_overrides_stdin_action(self):
        stdin = json.dumps({"action": "from-stdin", "x": 1}).encode()
        rc, payload, _ = self._run(["shim", "from-argv"], stdin)
        self.assertEqual(rc, 0)
        self.assertEqual(payload.get("action"), "from-argv")
        self.assertEqual(payload.get("x"), 1)

    def test_no_argv_action_keeps_stdin_action(self):
        stdin = json.dumps({"action": "from-stdin"}).encode()
        rc, payload, _ = self._run(["shim"], stdin)
        self.assertEqual(rc, 0)
        self.assertEqual(payload.get("action"), "from-stdin")

    def test_non_json_stdin_wrapped(self):
        rc, payload, _ = self._run(["shim", "act"], b"this is not json")
        self.assertEqual(rc, 0)
        self.assertEqual(payload.get("raw_text"), "this is not json")
        self.assertEqual(payload.get("action"), "act")

    def test_missing_handler_exits_nonzero(self):
        rc, _, stderr = self._run(["does-not-exist", "act"], b"")
        self.assertNotEqual(rc, 0)
        self.assertIn(b"handler not found", stderr)

    def test_extra_argv_forwarded(self):
        rc, payload, _ = self._run(["shim", "act", "extra1", "extra2"], b"{}")
        self.assertEqual(rc, 0)
        self.assertEqual(payload.get("_argv"), ["extra1", "extra2"])

    def test_no_argv_at_all_returns_usage(self):
        rc, _, stderr = self._run([], b"")
        self.assertNotEqual(rc, 0)
        self.assertIn(b"Usage", stderr)


if __name__ == "__main__":
    unittest.main()
