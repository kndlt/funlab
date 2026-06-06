-- Let a voter clear (remove) their rating. The clear button deletes the whole
-- row (score + note) for (game_slug, voter_id).
--
-- voter_id is client-supplied with no server-side identity, so this policy is
-- open (`using (true)`) like funlab_ratings_update — acceptable for a low-stakes
-- public play-test. In practice the client only ever deletes its own row
-- (WHERE game_slug = X AND voter_id = <its own id>). Tighten with real auth if
-- it ever matters.
grant delete on public.funlab_ratings to anon, authenticated;

drop policy if exists funlab_ratings_delete on public.funlab_ratings;
create policy funlab_ratings_delete on public.funlab_ratings
  for delete to anon, authenticated
  using (true);
