# Weekly Paper Planner — Deploy lên Vercel

Đây là app tĩnh (1 file `index.html`, tự chứa toàn bộ CSS/JS, dữ liệu lưu bằng `localStorage` trong trình duyệt). Không cần build, không cần backend.

## Cách 1: Deploy nhanh bằng Vercel CLI (khuyên dùng)

1. Cài Vercel CLI (nếu chưa có):
   ```
   npm install -g vercel
   ```

2. Vào thư mục này rồi chạy:
   ```
   cd planner-deploy
   vercel
   ```
   - Lần đầu sẽ hỏi đăng nhập (mở trình duyệt để login bằng GitHub/Google/Email).
   - Các câu hỏi tiếp theo cứ Enter mặc định là được (nó tự nhận đây là static site).

3. Sau khi deploy xong, để lên bản chính thức (production URL cố định):
   ```
   vercel --prod
   ```

Xong! Bạn sẽ có link dạng `https://ten-du-an.vercel.app`.

## Cách 2: Deploy qua giao diện web (không cần cài gì)

1. Vào https://vercel.com → đăng nhập.
2. Bấm **Add New → Project**.
3. Chọn tab **Deploy without Git** (hoặc kéo thả cả thư mục `planner-deploy` vào ô upload).
4. Bấm **Deploy**.

## Cách 3: Deploy qua GitHub (tiện cho update sau này)

1. Tạo repo mới trên GitHub, push toàn bộ nội dung thư mục `planner-deploy` lên.
2. Vào vercel.com → **Add New → Project** → **Import Git Repository** → chọn repo vừa tạo.
3. Vercel tự nhận diện static site, không cần cấu hình gì thêm → **Deploy**.
4. Từ giờ mỗi lần bạn `git push`, Vercel tự động deploy lại bản mới.

## Lưu ý quan trọng

- App vẫn lưu dữ liệu trong `localStorage` trên từng máy để dùng offline được. Nếu bạn đăng nhập, dữ liệu sẽ **tự động đồng bộ hai chiều** lên Supabase mỗi khi có thay đổi.
- Nên vẫn dùng nút **Export** thỉnh thoảng để backup file JSON, phòng trường hợp lỗi mạng.

---

## Bật đồng bộ nhiều thiết bị (đăng nhập bằng Google)

App đã được tích hợp sẵn code đồng bộ qua Supabase + đăng nhập Google. Bạn chỉ cần cấu hình phần backend, không cần sửa code nữa.

### Bước 1: Tạo project Supabase
1. Vào https://supabase.com → **New project** (miễn phí).
2. Vào **Project Settings → API**, copy 2 giá trị:
   - **Project URL**
   - **anon public key**

### Bước 2: Tạo bảng dữ liệu
1. Vào **SQL Editor** trong Supabase Dashboard.
2. Mở file `supabase-setup.sql` (đi kèm trong thư mục này), copy toàn bộ nội dung, dán vào SQL Editor, bấm **Run**.
   - File này tạo bảng `planner_data` và bật Row Level Security để mỗi người chỉ thấy dữ liệu của chính mình.

### Bước 3: Bật đăng nhập Google
1. Vào Google Cloud Console (https://console.cloud.google.com) → tạo **OAuth 2.0 Client ID** (loại Web application).
2. Trong **Authorized redirect URIs**, thêm URL dạng:
   ```
   https://<project-ref>.supabase.co/auth/v1/callback
   ```
   (Supabase sẽ cho bạn URL chính xác ở bước tiếp theo.)
3. Vào Supabase Dashboard → **Authentication → Providers → Google** → bật lên, dán **Client ID** và **Client Secret** từ Google Cloud Console vào.
4. Vào **Authentication → URL Configuration**, thêm domain Vercel của bạn (ví dụ `https://ten-app.vercel.app`) vào **Redirect URLs**.

### Bước 4: Điền config vào app
1. Mở file `index.html`, tìm đoạn:
   ```js
   const SUPABASE_URL = 'https://YOUR-PROJECT.supabase.co';
   const SUPABASE_ANON_KEY = 'YOUR-ANON-KEY';
   ```
2. Thay bằng Project URL và anon key đã copy ở Bước 1.
3. Deploy lại lên Vercel (`vercel --prod` hoặc `git push` nếu dùng Git).

### Cách hoạt động
- Nút **"Đăng nhập bằng Google"** ở góc phải header sẽ mở popup đăng nhập Google.
- Sau khi đăng nhập, mỗi thay đổi trong app (thêm task, tick habit...) sẽ tự động đẩy lên Supabase sau ~1 giây.
- Đăng nhập trên thiết bị khác bằng cùng tài khoản Google → app sẽ hỏi bạn muốn dùng dữ liệu trên mây hay giữ dữ liệu trên máy đó, tránh ghi đè nhầm.
- Nếu chưa điền `SUPABASE_URL`/`SUPABASE_ANON_KEY`, nút đăng nhập sẽ tự động bị vô hiệu và ghi "Đồng bộ chưa cấu hình" — app vẫn chạy bình thường ở chế độ chỉ lưu local.
