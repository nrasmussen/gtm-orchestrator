#!/usr/bin/env python3
# local.py — local file operations for transcripts and skills
# Actions: save-transcript, load-skills

import glob
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

DEFAULT_DATA_DIR = os.path.join(os.path.expanduser("~"), ".orchestrator", "data")


def _parse_frontmatter(text: str) -> dict:
    """Return the YAML-ish frontmatter as a flat dict. Handles only `key: value` lines."""
    if not text.startswith("---"):
        return {}
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}
    out = {}
    for line in parts[1].strip().splitlines():
        if ":" not in line:
            continue
        k, v = line.split(":", 1)
        out[k.strip()] = v.strip().strip('"').strip("'")
    return out


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    local_data_dir = os.environ.get("LOCAL_DATA_DIR", DEFAULT_DATA_DIR)
    skills_dir_env = os.environ.get("LOCAL_SKILLS_DIR", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print("DRY_RUN: local file operation", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    action = payload.get("action", "save-transcript")
    print(f"INFO: local action={action}", file=sys.stderr)

    if action == "save-transcript":
        transcript = payload.get("transcript", payload.get("raw_text", raw or ""))
        filename = payload.get("filename", "")
        if not filename:
            ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
            filename = f"transcript_{ts}.md"
        # Strip directory components — payload comes from upstream Claude/hook
        # output and must not write outside output_dir.
        filename = os.path.basename(filename)
        if not filename or filename in (".", ".."):
            print("ERROR: invalid filename after sanitization", file=sys.stderr)
            sys.exit(1)

        output_dir = payload.get("output_dir", os.path.join(local_data_dir, "transcripts"))
        Path(output_dir).mkdir(parents=True, exist_ok=True)

        output_path = os.path.join(output_dir, filename)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(transcript if isinstance(transcript, str) else json.dumps(transcript, indent=2))

        print(f"INFO: transcript saved to {output_path}", file=sys.stderr)
        print(json.dumps({"path": output_path, "status": "saved"}))

    elif action == "load-skills":
        skills_dir = (
            payload.get("skills_dir")
            or skills_dir_env
            or os.path.join(local_data_dir, "skills")
        )

        if not os.path.isdir(skills_dir):
            print(f"ERROR: skills directory not found: {skills_dir}", file=sys.stderr)
            sys.exit(1)

        skills = []
        for filepath in sorted(glob.glob(os.path.join(skills_dir, "**", "SKILL.md"), recursive=True)):
            try:
                with open(filepath, encoding="utf-8") as f:
                    text = f.read()
                meta = _parse_frontmatter(text)
                skills.append({
                    "name": meta.get("name", Path(filepath).parent.name),
                    "description": meta.get("description", ""),
                    "path": filepath,
                })
            except OSError as e:
                print(f"WARNING: could not read {filepath}: {e}", file=sys.stderr)

        print(json.dumps({"skills": skills, "count": len(skills)}))
        print(f"INFO: loaded {len(skills)} skills from {skills_dir}", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
