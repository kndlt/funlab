# funlab — a grand research on "game"

Distill the **essence** of proven games into one line each → build a tiny **no-asset** prototype of each → bundle them in one portal → **play-test and score** which essences are genuinely fun (naked, before any art).

> The question isn't "is the polished thing fun" — it's **"is the bare essence fun?"** Polish is amplification, not salvation.

## Run

It's a static site — no build step.

```
open index.html        # macOS
# or serve the folder with any static server, or host on GitHub Pages
```

Open `index.html`, click into each mini-game (opens in a new tab), play it, come back, and rate it **1–10** (saved in your browser's localStorage) with a one-line note.

## Structure

```
index.html        # the portal: lists games, holds your scores
games/
  magic.html      # ★ 마법진  — discover unique magic → own it → show it off
  merge.html      #   머지     — 2048: combine two into a bigger one
  luck.html       #   한 번 더? — press-your-luck: stack the multiplier or bank it
  idle.html       #   점점 강해짐 — Cookie-Clicker: numbers go up, buy more up
  alchemy.html    #   조합 발견 — Little Alchemy: combine to discover, collect all
LICENSE           # MIT
```

Each game is a single self-contained HTML file (no libraries, no assets) — so it's a "monorepo of independent games" with zero tooling.

## Batch 1 — nerve coverage

This first batch is biased toward **power / possession / discovery** nerves (the "마법진" hypothesis):

| game | essence (one line) | nerve |
|---|---|---|
| 마법진 ★ | 남들은 없는 마법을 **발견**해 **소유**하고, 그걸 보여준다 | discovery ⊗ 소유 ⊗ power ⊗ flex |
| 머지 | 같은 둘을 합쳐 더 큰 하나로 | mastery ⊗ order |
| 한 번 더? | 뒤집을수록 배수가 쌓인다 — 챙길까, 한 번 더 갈까 | risk ⊗ tension ⊗ power-combo |
| 점점 강해짐 | 숫자가 오르고, 더 빨리 오르게 하는 걸 산다 | accumulation ⊗ growth |
| 조합 발견 | 둘을 합쳐 새로운 걸 발견하고, 다 모은다 | discovery ⊗ collection |

More batches to come — each adds a few essences across the nerve space.

## License

MIT — see [LICENSE](LICENSE).
