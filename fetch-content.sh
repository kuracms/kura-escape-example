#!/usr/bin/env bash
# Pulls the latest published rooms from kura and writes them into data/rooms.json
# so the Hugo build can read .Site.Data.rooms.

set -euo pipefail

KURA_BASE="${KURA_BASE_URL:-https://kuracms.com}"
KURA_PROJECT="${KURA_PROJECT:-escape}"
KURA_TOKEN="${KURA_TOKEN:?KURA_TOKEN must be set}"

mkdir -p data

curl -fsSL \
	-H "Authorization: Bearer ${KURA_TOKEN}" \
	"${KURA_BASE}/api/v1/${KURA_PROJECT}/room?limit=50" \
	>data/rooms-raw.json

# Hugo's .Site.Data wants the JSON to be a single object/array at the top
# level of the file. The kura API wraps in {data:[...], meta:{...}} so we
# strip down to just the data array.
python3 -c "
import json, sys
with open('data/rooms-raw.json') as f:
    body = json.load(f)
rooms = [r for r in body['data'] if r.get('published')]
rooms.sort(key=lambda r: r.get('difficulty', ''))
with open('data/rooms.json', 'w') as f:
    json.dump(rooms, f, indent=2)
print(f'Wrote {len(rooms)} rooms')
"

rm -f data/rooms-raw.json

curl -fsSL \
	-H "Authorization: Bearer ${KURA_TOKEN}" \
	"${KURA_BASE}/api/v1/${KURA_PROJECT}/page?limit=10" \
	>data/pages-raw.json

python3 -c "
import json
with open('data/pages-raw.json') as f:
    body = json.load(f)
pages = [p for p in body['data'] if p.get('published')]
out = {p['slug']: p for p in pages}
with open('data/pages.json', 'w') as f:
    json.dump(out, f, indent=2)
print(f'Wrote {len(out)} pages')
"

rm -f data/pages-raw.json
