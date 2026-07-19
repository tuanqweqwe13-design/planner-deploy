-- Chạy toàn bộ file này trong Supabase Dashboard → SQL Editor → New query → Run

-- Bảng lưu dữ liệu kế hoạch, mỗi người dùng 1 dòng (dạng JSON)
create table if not exists planner_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

-- Bật Row Level Security để mỗi người chỉ đọc/ghi được dữ liệu của chính mình
alter table planner_data enable row level security;

drop policy if exists "Users can view own data" on planner_data;
create policy "Users can view own data"
  on planner_data for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own data" on planner_data;
create policy "Users can insert own data"
  on planner_data for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own data" on planner_data;
create policy "Users can update own data"
  on planner_data for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
