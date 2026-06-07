-- 마법진 global rune registry: every distinct glyph ever cast, and who cast it
-- FIRST (the world-first discoverer). This is what makes ownership real and
-- shareable — your legendary sigil is verifiably yours.
--
-- glyph = canonical sorted lit-cell index list, e.g. "6,8,12,16,18".
create table if not exists public.magic_runes (
  glyph       text        primary key check (char_length(glyph) between 1 and 200),
  name        text        not null,
  element     text        not null,
  power       int         not null,
  rarity      text        not null,
  first_voter text        not null,
  first_at    timestamptz not null default now(),
  cast_count  int         not null default 1
);

alter table public.magic_runes enable row level security;

-- registry is public to read (leaderboard / "Nth discoverer" lookups)
grant select on public.magic_runes to anon, authenticated;
drop policy if exists magic_runes_select on public.magic_runes;
create policy magic_runes_select on public.magic_runes
  for select to anon, authenticated using (true);

-- Writes go ONLY through claim_rune() (security definer) so anon can't forge
-- first_voter or tamper with another rune's record. The function owns the
-- atomic insert-or-bump and decides world-first (cast_count = 1 ⇒ just inserted).
create or replace function public.claim_rune(
  p_glyph text, p_name text, p_element text, p_power int, p_rarity text, p_voter text
) returns table(is_first boolean, first_voter text, cast_count int, total_runes bigint)
language plpgsql security definer set search_path = '' as $$
declare v_count int; v_first text; v_total bigint;
begin
  if p_glyph is null or char_length(p_glyph) not between 1 and 200
     or p_voter is null or char_length(p_voter) not between 8 and 64 then
    raise exception 'bad input';
  end if;

  insert into public.magic_runes(glyph, name, element, power, rarity, first_voter)
    values (p_glyph, left(coalesce(p_name,'?'),80), left(coalesce(p_element,'?'),16),
            greatest(0, least(coalesce(p_power,0), 9999)), left(coalesce(p_rarity,'?'),16), p_voter)
  on conflict (glyph) do update set cast_count = public.magic_runes.cast_count + 1
  returning public.magic_runes.cast_count, public.magic_runes.first_voter
    into v_count, v_first;

  select count(*) into v_total from public.magic_runes;
  return query select (v_count = 1), v_first, v_count, v_total;
end $$;

grant execute on function public.claim_rune(text,text,text,int,text,text) to anon, authenticated;
