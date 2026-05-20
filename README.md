# kura-escape-example

An example [Hugo](https://gohugo.io) site reading from a [kura](https://kuracms.com) content backend. Live at `escape.kuracms.com`.

A small Tokyo escape-room operator with five rooms. The site is **statically built**: Hugo pulls the latest published rooms from the kura API at build time, generates flat HTML and CSS, and Cloudflare serves those files. There is no database lookup happening per request.

This is the "static site" story for kura - useful when you want zero-runtime sites for landing pages, brochure sites, or marketing copy that changes weekly.

## How it works

1. `fetch-content.sh` calls `GET /api/v1/escape/room` on kura and writes the response into `data/rooms.json`.
2. `hugo --minify` reads `data/rooms.json` via `.Site.Data.rooms` and emits a single static page with all the rooms baked in.
3. `wrangler deploy` uploads the `public/` directory to Cloudflare's edge.

For a real production setup, a `publish` action in kura would post to a Cloudflare Pages "Deploy Hook" URL, which triggers a fresh build from the kura API. The build takes ~30 seconds and is then live worldwide.

## Build locally

```
export KURA_TOKEN=<your-project-token>
./fetch-content.sh
hugo server
```

## Deploy

```
./fetch-content.sh && hugo --minify && npx wrangler deploy
```

## License

MIT.
