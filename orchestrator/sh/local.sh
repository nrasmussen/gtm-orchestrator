#!/usr/bin/env bash
# local.sh — local file operations for transcripts and skills
# Actions: save-transcript, load-skills
set -euo pipefail

PAYLOAD="$(cat)"

LOCAL_DATA_DIR="${LOCAL_DATA_DIR:-${HOME}/.orchestrator/data}"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: local file operation" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','save-transcript'))")"
echo "INFO: local action=$ACTION" >&2

case "$ACTION" in
  save-transcript)
    TRANSCRIPT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript',''))")"
    FILENAME="$(echo "$PAYLOAD" | python3 -c "
import sys, json, datetime
d = json.load(sys.stdin)
name = d.get('filename', '')
if not name:
    name = 'transcript_' + datetime.datetime.utcnow().strftime('%Y%m%dT%H%M%SZ') + '.txt'
print(name)
")"
    OUTPUT_DIR="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('output_dir','$LOCAL_DATA_DIR/transcripts'))")"

    mkdir -p "$OUTPUT_DIR"
    OUTPUT_PATH="$OUTPUT_DIR/$FILENAME"
    printf '%s' "$TRANSCRIPT" > "$OUTPUT_PATH"
    echo "INFO: transcript saved to $OUTPUT_PATH" >&2
    python3 -c "import json; print(json.dumps({'path': '$OUTPUT_PATH', 'status': 'saved'}))"
    ;;
  load-skills)
    SKILLS_DIR="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('skills_dir','$LOCAL_DATA_DIR/skills'))")"

    if [[ ! -d "$SKILLS_DIR" ]]; then
      echo "ERROR: skills directory not found: $SKILLS_DIR" >&2
      exit 1
    fi

    python3 -c "
import json, os, glob
skills_dir = '''$SKILLS_DIR'''
skills = []
for filepath in sorted(glob.glob(os.path.join(skills_dir, '*.md'))):
    with open(filepath) as f:
        try:
            skills.append(json.load(f))
        except json.JSONDecodeError as e:
            import sys
            print(f'WARNING: could not parse {filepath}: {e}', file=sys.stderr)
print(json.dumps({'skills': skills, 'count': len(skills)}))
"
    echo "INFO: skills loaded from $SKILLS_DIR" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
