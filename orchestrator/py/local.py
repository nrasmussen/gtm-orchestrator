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

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    local_data_dir = os.environ.get("LOCAL_DATA_DIR", DEFAULT_DATA_DIR)
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print("DRY_RUN: local file operation", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    action = payload.get("action", "save-transcript")
    print(f"INFO: local action={action}", file=sys.stderr)

    if action == "save-transcript":
        transcript = payload.get("transcript", "")
        filename = payload.get("filename", "")
        if not filename:
            ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
            filename = f"transcript_{ts}.txt"

        output_dir = payload.get("output_dir", os.path.join(local_data_dir, "transcripts"))
        Path(output_dir).mkdir(parents=True, exist_ok=True)

        output_path = os.path.join(output_dir, filename)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(transcript)

        print(f"INFO: transcript saved to {output_path}", file=sys.stderr)
        print(json.dumps({"path": output_path, "status": "saved"}))

    elif action == "load-skills":
        skills_dir = payload.get("skills_dir", os.path.join(local_data_dir, "skills"))

        if not os.path.isdir(skills_dir):
            print(f"ERROR: skills directory not found: {skills_dir}", file=sys.stderr)
            sys.exit(1)

        skills = []
        for filepath in sorted(glob.glob(os.path.join(skills_dir, "*.json"))):
            with open(filepath, encoding="utf-8") as f:
                try:
                    skills.append(json.load(f))
                except json.JSONDecodeError as e:
                    print(f"WARNING: could not parse {filepath}: {e}", file=sys.stderr)

        print(json.dumps({"skills": skills, "count": len(skills)}))
        print(f"INFO: skills loaded from {skills_dir}", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
