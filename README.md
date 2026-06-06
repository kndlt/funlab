# funlab — a grand research on "game"

Distill the **essence** of proven games into one line each → build a tiny **no-asset** prototype of each → bundle them in one portal → **play-test and score** which essences are genuinely fun (naked, before any art).

> The question isn't "is the polished thing fun" — it's **"is the bare essence fun?"** Polish is amplification, not salvation.

## Two signals

Each game carries an **essence/nerve** — a one-line hypothesis about *why* it might grip someone. To test that hypothesis empirically we collect two layers of signal:

- **Explicit** — the player's 1–10 score + one-line note. What they *say*.
- **Implicit** — gameplay telemetry: sessions, time-on-game, runs, scores, where they drop off, do they come back. What they *do*.

The long arc: funlab becomes a **discovery engine** — stream real play data per game and let behavior, not just stars, reveal which essence actually has a grip. Every layer is keyed by the game's `slug` (static path → ratings row → play-event → future Durable Object room), so a new game plugs into the whole pipeline by dropping one folder.

## Run

It's a static site — no build step.

```
open index.html        # macOS
# or serve the folder with any static server, or host on GitHub Pages
```

Open `index.html`, click into each mini-game, play it, hit the browser **back** button (or the in-page back link) to return, and rate it **1–10** with a one-line note. Scores are saved to a shared Supabase table (keyed by game `slug` + an anonymous per-browser voter id), so everyone's play-test scores aggregate together — each card shows the community average. If the DB is unreachable it falls back to `localStorage`.

## Structure

```
index.html             # the portal: lists games, holds your scores
games/
  <slug>/
    index.html         # one self-contained game (no libraries, no assets)
  magic/index.html     # ★ 마법진  — discover unique magic → own it → show it off
  snake/index.html     #   스네이크 — eat and grow, don't bite yourself
  reigns/index.html    #   왕의 선택 — swipe left/right, keep the kingdom alive
  ...                  #   15 games across the nerve space
LICENSE                # MIT
```

Each game lives in its own folder so it can grow its own assets later, but
today each is a single self-contained HTML file (no libraries, no assets) —
a "monorepo of independent games" with zero tooling. The `slug` (folder name)
is the boundary key threaded through every layer.

## Batch 1 — nerve coverage

This first batch is biased toward **power / possession / discovery** nerves (the "마법진" hypothesis):

| game | essence (one line) | nerve |
|---|---|---|
| 마법진 ★ | 남들은 없는 마법을 **발견**해 **소유**하고, 그걸 보여준다 | discovery ⊗ 소유 ⊗ power ⊗ flex |
| 머지 | 같은 둘을 합쳐 더 큰 하나로 | mastery ⊗ order |
| 한 번 더? | 뒤집을수록 배수가 쌓인다 — 챙길까, 한 번 더 갈까 | risk ⊗ tension ⊗ power-combo |
| 점점 강해짐 | 숫자가 오르고, 더 빨리 오르게 하는 걸 산다 | accumulation ⊗ growth |
| 조합 발견 | 둘을 합쳐 새로운 걸 발견하고, 다 모은다 | discovery ⊗ collection |

## Batch 2 — broadening the nerve space

Reflex, memory, flow, raw skill, and pure puzzles — nerves batch 1 barely touched:

| game | essence (one line) | nerve |
|---|---|---|
| 사이먼 / 짝맞추기 | 순서를·짝을 **기억**한다 | memory ⊗ sequence / pairs |
| 반응속도 / 두더지 | 초록인 **순간** 친다 / 튀어나오면 친다 | reflex ⊗ speed / aim |
| 플래피 / 점프 러너 | 흐름을 타고 틈을 통과·점프 | flow ⊗ nerve / timing |
| 벽돌깨기 / 타자 | 패들로 깬다 / 빠르고 정확하게 친다 | skill ⊗ aim / speed |
| 슬라이드·라이트아웃·미로 | 순서·논리·길을 **푼다** | puzzle (order / logic / spatial) |
| 보석 맞추기 | 셋을 맞춰 **연쇄**로 터뜨린다 | mastery ⊗ cascade |

## Batch 3 — new genres

Cards, AI opponents, aiming, and arcade survival — whole genres batch 1–2 didn't touch:

| game | essence (one line) | nerve |
|---|---|---|
| 블랙잭 | 21에 가깝게 — 버스트 직전의 욕심 | risk ⊗ count |
| 사목 / 오델로 | AI 상대로 **잇고 / 뒤집어** 이긴다 | strategy ⊗ foresight / flip |
| 스도쿠 / 노노그램 / 행맨 | 논리·그림·단어를 **추리**한다 | deduction (logic / image / word) |
| 포격 | 각도·힘·바람을 읽어 **맞힌다** | aim ⊗ physics |
| 소행성·인베이더·개구리·퐁 | 돌고·막고·건너고·받아쳐 **살아남는다** | arcade (survival / defense / crossing / reflex) |
| 슬롯머신 | 돌리고 멈춘다 — 변동 보상의 중독 | luck ⊗ jackpot |

Strategy games (사목/오델로) run real alpha-beta minimax AI; sudoku puzzles are
generated with a verified unique solution. Catalog is now **39 games**.

More batches to come — each adds a few essences across the nerve space.

## License

MIT — see [LICENSE](LICENSE).
