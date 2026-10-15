# 隨手記帳

可以用 email 登入連結或 Google 帳號登入的記帳網站。資料存在 Supabase，網站放在 GitHub Pages。

```
ledger-app/
├── index.html            整個 app（介面與程式）
├── config.js             填入你的 Supabase 網址與金鑰
└── supabase/schema.sql   建立資料表與安全規則
```

整個設定大約 20–30 分鐘，照順序做：

## 1. 建立 Supabase 專案

1. 到 https://supabase.com 註冊並登入，按 **New project**。名稱隨意（例如 `ledger`），區域選離你近的（例如 Tokyo 或 Singapore），設一個資料庫密碼並自己保存好。
2. 專案建好後，左側選 **SQL Editor**，把 `supabase/schema.sql` 的內容全部貼上，按 **Run**。看到 `Success` 就好。
3. 左側 **Project Settings → API**（新版介面在 **Data API** / **API Keys**），複製：
   - **Project URL**（像 `https://abcdxyz.supabase.co`）
   - **anon public** 金鑰（很長的一串）
4. 打開 `config.js`，把這兩個值貼進去取代 `YOUR_PROJECT_REF…` 和 `YOUR_ANON_KEY`。

> anon 金鑰本來就是公開給網頁用的；每個人只能讀寫自己的資料，是靠第 2 步建立的 Row Level Security 規則保證的。**不要**把 `service_role` / secret 金鑰放進任何檔案。

## 2. 把網站放上 GitHub Pages

1. 到 https://github.com 登入，右上角 **+ → New repository**，名稱例如 `ledger-app`，選 **Public**（免費帳號的 Pages 需要公開 repo；資料不在 repo 裡，只有程式碼公開），按 **Create repository**。
2. 在新 repo 頁面點 **uploading an existing file**，把 `index.html`、`config.js` 拖進去，按 **Commit changes**。
3. repo 的 **Settings → Pages**：Source 選 **Deploy from a branch**，Branch 選 `main`、資料夾 `/ (root)`，按 **Save**。
4. 等一兩分鐘，頁面上方會出現網址，例如 `https://你的帳號.github.io/ledger-app/`。記下這個網址，下一步要用。

之後要更新網站，一樣在 repo 裡上傳新的 `index.html` 覆蓋即可。

## 3. 設定登入轉址

Supabase 後台 → **Authentication → URL Configuration**：

- **Site URL**：填第 2 步的網址，例如 `https://你的帳號.github.io/ledger-app/`
- **Redirect URLs**：按 **Add URL** 加入同一個網址

沒設定的話，點信裡的登入連結會跳到錯的地方。

## 4. Email 登入連結

Supabase 預設就開著 Email 登入，不用額外設定。要注意：

- **內建寄信服務有限制**：只能寄給你這個 Supabase 組織的成員（也就是你自己），而且每小時只能寄很少封。自己用沒問題；要讓**別人**也能用 email 註冊，需要設定自己的寄信服務：**Authentication → Emails → SMTP Settings**，可以用 Resend、Brevo 等有免費額度的服務。
- 想把信件內容改成中文：**Authentication → Emails → Templates → Magic Link**。

## 5. Google 登入

1. 到 https://console.cloud.google.com ，建立一個專案。
2. **APIs & Services → OAuth consent screen**：User type 選 **External**，填 app 名稱與你的 email，儲存。
3. **APIs & Services → Credentials → Create Credentials → OAuth client ID**：
   - Application type：**Web application**
   - Authorized JavaScript origins：`https://你的帳號.github.io`
   - Authorized redirect URIs：`https://你的專案代號.supabase.co/auth/v1/callback`（Supabase 的 Google 設定頁上也會顯示這個網址，可直接複製）
4. 建好後複製 **Client ID** 和 **Client secret**。
5. 回到 Supabase → **Authentication → Sign In / Providers → Google**，打開開關，貼上 Client ID 和 Client secret，儲存。

> Google 的 OAuth 同意畫面在「Testing」狀態時，只有你加進 Test users 的帳號能登入；要開放給所有人，需在同意畫面按 **Publish app**。

## 6. 從舊版搬資料

1. 打開舊的 Claude 版記帳 app → 設定 → 備份與同步 → **匯出完整備份 (JSON)**。
2. 在新網站登入後 → 設定 → 備份與同步 → 選擇剛剛的 JSON 檔 → **合併匯入**。

## 疑難排解

| 狀況 | 原因與處理 |
| --- | --- |
| 打開網站看到「還沒設定 Supabase」 | `config.js` 沒填或沒上傳到 GitHub |
| 點信裡連結後回到登入畫面、顯示連結無效 | 連結已用過或超過一小時；重新寄一次。也檢查第 3 步的網址是否完全一致（包含最後的 `/`） |
| 寄送失敗：rate limit / not authorized | 內建寄信服務的限制，見第 4 步 |
| Google 登入出現 redirect_uri_mismatch | 第 5 步的 Authorized redirect URIs 填錯 |
| 右上角一直顯示「連線中」 | 第 1 步的 SQL 沒執行成功，或 `config.js` 的網址/金鑰貼錯 |
