// 把 Supabase 專案的網址和 anon（public）金鑰貼在這裡。
// 位置：Supabase 後台 → Project Settings → API（或 Data API）。
// anon key 本來就是公開給網頁用的，資料安全靠資料庫的 Row Level Security 規則（見 supabase/schema.sql）。
// 千萬不要把 service_role（secret）金鑰貼在這裡。
window.LEDGER_CONFIG = {
  supabaseUrl: 'https://hfojhqypmakjolqhtjny.supabase.co',
  supabaseAnonKey: 'sb_publishable_ahNhnnZeNw9R9jPuB2l4lQ_O2udnzfp',
};
