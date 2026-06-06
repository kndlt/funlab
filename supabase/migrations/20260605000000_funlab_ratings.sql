-- funlab_ratings — explicit play-test signal: one score (1-10) + one note per
-- (game, voter). The browser writes here directly via the Data API using the
-- publishable (anon) key; RLS below is the only gate, so keep it tight.
--
-- Boundary key is `game_slug` (same slug used by the static path
-- games/<slug>/ and any future play-event table / Durable Object room).

create table if not exists public.funlab_ratings (
  id         uuid        primary key default gen_random_uuid(),
  game_slug  text        not null check (char_length(game_slug) between 1 and 64),
  score      smallint    check (score between 1 and 10),
  note       text        check (char_length(note) <= 500),
  voter_id   text        not null check (char_length(voter_id) between 8 and 64),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- one rating per voter per game (upsert target); fast per-game reads
create unique index if not exists funlab_ratings_game_voter_uniq
  on public.funlab_ratings (game_slug, voter_id);
create index if not exists funlab_ratings_game_created_idx
  on public.funlab_ratings (game_slug, created_at desc);

-- keep updated_at honest on upsert
create or replace function public.funlab_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists funlab_ratings_touch on public.funlab_ratings;
create trigger funlab_ratings_touch
  before update on public.funlab_ratings
  for each row execute function public.funlab_touch_updated_at();

-- ── access ──────────────────────────────────────────────────────────────
-- RLS on: the table is born locked, policies below are the only way in.
alter table public.funlab_ratings enable row level security;

grant select, insert, update on public.funlab_ratings to anon, authenticated;

-- anyone may submit a rating (validated)
drop policy if exists funlab_ratings_insert on public.funlab_ratings;
create policy funlab_ratings_insert on public.funlab_ratings
  for insert to anon, authenticated
  with check (
    score is not null and score between 1 and 10
    and char_length(voter_id) between 8 and 64
  );

-- anyone may change a rating (upsert). NOTE: voter_id is client-supplied with
-- no server-side identity, so this is intentionally open — acceptable for a
-- low-stakes public play-test. Tighten with real auth if it ever matters.
drop policy if exists funlab_ratings_update on public.funlab_ratings;
create policy funlab_ratings_update on public.funlab_ratings
  for update to anon, authenticated
  using (true)
  with check (score is null or score between 1 and 10);

-- raw rows are public (notes/voter_id are non-sensitive in a shared play-test)
drop policy if exists funlab_ratings_select on public.funlab_ratings;
create policy funlab_ratings_select on public.funlab_ratings
  for select to anon, authenticated
  using (true);

-- ── aggregate view for the portal (avg + count per game) ─────────────────
-- security_invoker so it respects the caller's RLS on the base table.
create or replace view public.funlab_rating_summary
  with (security_invoker = on) as
  select game_slug,
         count(*)::int                       as n,
         round(avg(score)::numeric, 1)::float as avg_score,
         max(updated_at)                      as last_at
  from public.funlab_ratings
  where score is not null
  group by game_slug;

grant select on public.funlab_rating_summary to anon, authenticated;
