// funlab Worker — static assets are served by the ASSETS binding; this script
// only handles /api/* (run_worker_first in wrangler.jsonc).
//
// Today it does one job: gate free-text comments behind Cloudflare Turnstile.
// Scores stay anonymous and write directly browser -> Supabase (RLS-gated).
// A comment goes browser -> POST /api/note -> we verify the Turnstile token
// (secret stays server-side) -> only then write the note to the rating row.
//
// This is the first server in funlab's loop; Durable Objects for real-time
// play land here later on the same slug boundary.

export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    if (url.pathname === '/api/note' && req.method === 'POST') return handleNote(req, env);
    if (url.pathname.startsWith('/api/')) return json({ error: 'not found' }, 404);
    // serve the static asset; force revalidation on HTML so rapid iteration
    // (the games are actively edited) shows up on reload instead of a stale cache.
    const res = await env.ASSETS.fetch(req);
    const ct = res.headers.get('content-type') || '';
    if (ct.includes('text/html')) {
      const h = new Headers(res.headers);
      h.set('Cache-Control', 'no-cache, must-revalidate');
      return new Response(res.body, { status: res.status, headers: h });
    }
    return res;
  },
};

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { 'Content-Type': 'application/json' } });
}

// POST /api/note  { game_slug, voter_id, note, token }
// Writes `note` onto the existing (game_slug, voter_id) row — the row must
// already exist (created by a score), so PATCH is enough. No row -> no-op.
async function handleNote(req, env) {
  let body;
  try { body = await req.json(); } catch { return json({ error: 'bad json' }, 400); }
  const { game_slug, voter_id, note, token } = body || {};
  if (typeof game_slug !== 'string' || game_slug.length < 1 || game_slug.length > 64) return json({ error: 'bad game_slug' }, 400);
  if (typeof voter_id !== 'string' || voter_id.length < 8 || voter_id.length > 64) return json({ error: 'bad voter_id' }, 400);
  if (typeof note !== 'string' || note.length > 500) return json({ error: 'bad note' }, 400);

  const ok = await verifyTurnstile(token, env, req);
  if (!ok) return json({ error: 'turnstile failed' }, 403);

  const q = `${env.SUPABASE_URL}/rest/v1/funlab_ratings`
    + `?game_slug=eq.${encodeURIComponent(game_slug)}`
    + `&voter_id=eq.${encodeURIComponent(voter_id)}`;
  const res = await fetch(q, {
    method: 'PATCH',
    headers: {
      apikey: env.SUPABASE_KEY,
      Authorization: `Bearer ${env.SUPABASE_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal',
    },
    body: JSON.stringify({ note: note || null }),
  });
  if (!res.ok) return json({ error: 'db', status: res.status, detail: await res.text() }, 502);
  return json({ ok: true });
}

async function verifyTurnstile(token, env, req) {
  if (!token || !env.TURNSTILE_SECRET) return false;
  const form = new FormData();
  form.append('secret', env.TURNSTILE_SECRET);
  form.append('response', token);
  const ip = req.headers.get('CF-Connecting-IP');
  if (ip) form.append('remoteip', ip);
  try {
    const r = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', { method: 'POST', body: form });
    const data = await r.json();
    return data.success === true;
  } catch {
    return false;
  }
}
