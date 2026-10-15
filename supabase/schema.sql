-- 隨手記帳：資料表與安全規則
-- 在 Supabase 後台 → SQL Editor 貼上整段後按 Run。重複執行也不會出錯。

-- 每位使用者的資料存成幾個 JSON 文件：
--   meta        → 帳戶、分類、預算、週期帳目、匯率等設定
--   m-YYYY-MM   → 那個月的所有記錄
create table if not exists public.ledger_docs (
  user_id    uuid        not null default auth.uid() references auth.users (id) on delete cascade,
  doc_id     text        not null check (doc_id ~ '^(meta|m-[0-9]{4}-[0-9]{2})$'),
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, doc_id)
);

-- 單一文件上限約 1 MB，避免異常資料塞爆資料庫
alter table public.ledger_docs drop constraint if exists ledger_docs_size;
alter table public.ledger_docs add constraint ledger_docs_size check (pg_column_size(data) < 1000000);

-- Row Level Security：每個人只能讀寫自己的資料
alter table public.ledger_docs enable row level security;

drop policy if exists "ledger_docs select own" on public.ledger_docs;
drop policy if exists "ledger_docs insert own" on public.ledger_docs;
drop policy if exists "ledger_docs update own" on public.ledger_docs;
drop policy if exists "ledger_docs delete own" on public.ledger_docs;

create policy "ledger_docs select own" on public.ledger_docs
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "ledger_docs insert own" on public.ledger_docs
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "ledger_docs update own" on public.ledger_docs
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "ledger_docs delete own" on public.ledger_docs
  for delete to authenticated using ((select auth.uid()) = user_id);

-- 即時同步：手機記一筆，電腦上的畫面會自動更新
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'ledger_docs'
  ) then
    alter publication supabase_realtime add table public.ledger_docs;
  end if;
end $$;
