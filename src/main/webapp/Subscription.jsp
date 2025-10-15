<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Gói Xem Phim - Chọn Kế Hoạch Của Bạn</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* CSS cho Navbar - Giống trang chủ, light theme mặc định */
/* ===============================
   THEME (Default = LIGHT)
   =============================== */
:root {
  --bg:#f6f7fb;
  --text:#111827;
  --muted:#6b7280;

  --card:#ffffff;
  --border:#e5e7eb;

  --accent:#2563eb;
  --danger:#ef4444;

  --icon:#c9cdd3;        /* xám nhạt cho icon */
  --icon-hover:#2563eb;  /* màu hover */

  --search-bg:#f1f2f4;   /* nền ô tìm kiếm */
  --search-border:#eceff3;
}

:root.dark {
  --bg:#0b0b0b;
  --text:#e5e7eb;
  --muted:#9aa1ad;

  --card:#111827;
  --border:#1f2937;

  --accent:#2563eb;
  --danger:#ef4444;

  --icon:#a5acb8;
  --icon-hover:#93b4ff;

  --search-bg:#1f2430;
  --search-border:#2a2f3a;
}

/* ===============================
   BASE
   =============================== */
*{ box-sizing:border-box; margin:0; padding:0; }
html, body { min-height: 100%; }

body{
  background:var(--bg);
  color:var(--text);
  font:15px/1.5 "Segoe UI", Roboto, system-ui, -apple-system, sans-serif;
  transition: background .25s ease, color .25s ease;
}

/* ===============================
   NAVBAR (TOPBAR)
   =============================== */
.navbar{
  position: sticky;
  top: 0;
  z-index: 50;
  background: var(--card);
  border-bottom: 1px solid var(--border);
}
.navbar .inner{
  max-width: 1300px;
  margin: 0 auto;
  padding: 12px 24px;
  display: grid;
  grid-template-columns: auto 1fr auto; /* logo | nav | actions */
  align-items: center;
  gap: 24px;
}

/* === BRAND === */
.brand{
  display: flex;
  align-items: center;
  gap: 10px;
  text-decoration: none;
  color: var(--accent);
}
.brand img{
  height: clamp(48px, 5vw, 56px);
  width: auto;
  display: block;
}
.brand span{
  font-weight: 800;
  font-size: 18px;
  letter-spacing: .3px;
  color: var(--accent);
}

/* === NAV (menu giữa) === */
.nav{
  display: flex;
  justify-content: center;
  gap: 46px;
}
.nav a{
  color: var(--text);
  text-decoration: none;
  font-weight: 600;
  font-size: 16px;
  transition: color .2s ease;
}
.nav a:hover{ color: var(--accent); }
.nav a.active{ color: var(--accent); }

/* === ACTIONS (phần phải) === */
.actions{
  display: flex;
  align-items: center;
  justify-self: end;
  gap: 18px;
}
.actions i,
.actions a{
  color: var(--icon);
  font-size: 18px;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
  transition: color .15s ease, transform .15s ease;
}
.actions i:hover,
.actions a:hover i{
  color: var(--icon-hover);
  transform: translateY(-1px);
}

/* === SEARCH FORM === */
.search-form{
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--search-bg);
  border: 1px solid var(--search-border);
  border-radius: 999px;
  padding: 8px 14px;
  min-width: 340px;
}
.search-input{
  border: none;
  outline: none;
  background: transparent;
  font: 14px/1.5 system-ui,-apple-system,Segoe UI,Roboto,sans-serif;
  color: var(--text);
  width: 100%;
}
.search-input::placeholder{ color: var(--icon); }
.search-btn{
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 16px;
  color: var(--icon);
  display: flex;
  align-items: center;
  justify-content: center;
}
.search-btn:hover{ color: var(--icon-hover); }

/* Nội dung pricing - Cách navbar */
h1 {
	text-align: center;
	color: var(--text);
	margin: 40px 0 20px 0;
}

.plans-container {
	display: flex;
	justify-content: center;
	gap: 30px;
	flex-wrap: wrap;
	align-items: stretch;
	padding: 0 20px 20px;
	max-width: 1200px;
	margin: 0 auto;
}

.plan-card {
	background-color: #ffffff;
	border: 1px solid #dee2e6;
	border-radius: 8px;
	padding: 30px;
	width: 250px;
	text-align: center;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	transition: box-shadow 0.3s ease;
	display: flex;
	flex-direction: column;
	flex: 1;
	min-width: 250px;
	max-width: 300px;
}

.plan-card:hover {
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.plan-name {
	font-size: 20px;
	font-weight: bold;
	color: #007bff;
	margin-bottom: 10px;
}

.plan-price {
	position: relative;
	display: inline-block;
	margin: 10px 0;
}

.original-price {
	text-decoration: line-through;
	color: #6c757d;
	font-size: 18px;
	margin-right: 10px;
}

.sale-price {
	font-size: 24px;
	font-weight: bold;
	color: #28a745;
}

.plan-duration {
	color: #6c757d;
	font-size: 14px;
	margin-bottom: 20px;
}

.save-badge {
	background-color: #ffc107;
	color: #212529;
	font-size: 12px;
	padding: 4px 8px;
	border-radius: 12px;
	margin-bottom: 10px;
	display: inline-block;
}

.feature {
	list-style-type: none;
	padding: 0;
	margin: 20px 0;
	color: #6c757d;
	flex-grow: 1;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.feature li {
	padding: 8px 0;
	border-bottom: 1px solid #f8f9fa;
}

.feature li:last-child {
	border-bottom: none;
}

.buy-button {
	background-color: #007bff;
	color: white;
	border: none;
	padding: 12px 24px;
	border-radius: 5px;
	cursor: pointer;
	font-size: 16px;
	width: 100%;
	margin-top: auto;
}

.buy-button:hover {
	background-color: #0056b3;
}

/* Responsive */
@media ( max-width : 768px) {
	.navbar {
		flex-direction: column;
		gap: 10px;
		padding: 10px;
	}
	nav {
		order: 3;
		flex-wrap: wrap;
		justify-content: center;
	}
	.nav-icons {
		order: 2;
	}
	.plans-container {
		flex-direction: column;
		align-items: center;
		padding: 0 10px 20px;
	}
	.plan-card {
		width: 90%;
		max-width: 300px;
	}
}

/* Theme adjustments cho light/dark mode */
body.light-mode .navbar {
	background: #ffffff;
}

body.light-mode nav a {
	color: #495057;
}

body.light-mode .nav-icons i {
	color: #495057;
}

body.light-mode {
	background-color: #f8f9fa;
	color: #333;
}

body.light-mode .plan-card {
	background-color: #ffffff;
}

.hidden {
	display: none;
}

/* Alert (thông báo) */
.alert {
	max-width: 720px; /* Giới hạn độ rộng để dễ đọc */
	margin: 0 auto 20px; /* Căn giữa khối và thêm khoảng cách dưới */
	padding: 12px 16px;
	border-radius: 8px;
	border: 1px solid transparent;
	text-align: center; /* Căn giữa chữ/icon */
	display: flex; /* Căn giữa cả nội dung */
	align-items: center; /* Căn giữa theo trục dọc */
	justify-content: center; /* Căn giữa theo trục ngang */
	gap: 8px;
}

/* Thành công (xanh) - theo palette alert-success Bootstrap */
.alert-success {
	color: #0f5132;
	background-color: #d1e7dd;
	border-color: #badbcc;
}

/* Lỗi (đỏ) - theo palette alert-danger Bootstrap */
.alert-error {
	color: #842029;
	background-color: #f8d7da;
	border-color: #f5c2c7;
}

/* Tùy chọn: cỡ icon hài hòa */
.alert i {
	font-size: 18px;
}
</style>
</head>
<body>
	   <c:set var="ctx" value="${pageContext.request.contextPath}"/>
 <header class="navbar">
    <div class="inner">
      <a class="brand" href="${ctx}/">
        <img src="${ctx}/images/Logo.png" alt="Logo" class="logo-img" />
        <span>HCMUTE</span>
      </a>

      <nav class="nav" aria-label="Chính">
        <a href="${ctx}/HomeServlet?action=TrangChu">Trang chủ</a>
        <a href="${ctx}/HomeServlet?action=TheLoai">Thể loại</a>
        <a href="${ctx}/HomeServlet?action=ListPhim">List Phim</a>
      </nav>

      <div class="actions" aria-label="Tác vụ">
        <form action="${ctx}/HomeServlet" method="get" class="search-form" role="search" aria-label="Tìm phim">
          <input type="hidden" name="action" value="TimKiem">
          <input type="text" name="query" class="search-input" placeholder="Tìm phim..." />
          <button type="submit" class="search-btn" aria-label="Tìm kiếm">
            <i class="fa-solid fa-magnifying-glass"></i>
          </button>
        </form>


        <a class="action-link" href="${ctx}/HomeServlet?action=watchlist" aria-label="Watchlist">
  			<i class="fa-solid fa-bookmark"></i>
		</a>

        <a class="action-link" href="${ctx}/HomeServlet?action=GioHang" aria-label="Giỏ hàng">
          <i class="fa-solid fa-cart-shopping"></i>
        </a>
        <a class="action-link" href="${ctx}/HomeServlet?action=TaiKhoan" aria-label="Tài khoản">
          <i class="fa-solid fa-user"></i>
        </a>

        <i id="theme-toggle" class="fa-solid fa-sun" aria-label="Đổi giao diện sáng/tối"></i>
      </div>
    </div>
  </header>

	<main>
		<h1>Chọn Gói Xem Phim Của Bạn</h1>
		<p
			style="text-align: center; color: #6c757d; margin-bottom: 40px; padding: 0 20px;">Khuyến
			mãi đặc biệt - Tiết kiệm ngay hôm nay với giá giảm!</p>

		<%-- Hiển thị thông báo thành công NẾU có --%>
		<c:if test="${not empty messageUser}">
			<div class="alert alert-success">
				<i class="fa-solid fa-circle-check"></i>
				<c:out value="${messageUser}" />
			</div>
		</c:if>

		<%-- Hiển thị thông báo lỗi NẾU có --%>
		<c:if test="${not empty errorUser}">
			<div class="alert alert-error">
				<i class="fa-solid fa-triangle-exclamation"></i>
				<c:out value="${errorUser}" />
			</div>
		</c:if>


		<div class="plans-container">
			<!-- Gói 1 Tháng -->
			<form action="RegisterSubscription" method="POST">
				<input class="hidden" name="plan" value="oneMonth" />
				<div class="plan-card">
					<div class="save-badge">Tiết kiệm 20%</div>
					<div class="plan-name">Gói 1 Tháng</div>
					<div class="plan-price">
						<span class="original-price">$12.99</span> <span
							class="sale-price">$9.99</span>
					</div>
					<div class="plan-duration">Hạn sử dụng: 1 tháng</div>
					<ul class="feature">
						<li>• Xem phim không giới hạn</li>
						<li>• Chất lượng HD</li>
						<li>• 2 thiết bị đồng thời</li>
						<li>• Không quảng cáo</li>
					</ul>
					<button class="buy-button">Đăng Ký Ngay</button>
				</div>
			</form>

			<!-- Gói 6 Tháng -->
			<form action="RegisterSubscription" method="POST">
				<input class="hidden" name="plan" value="sixMonth" />
				<div class="plan-card">
					<div class="save-badge">Tiết kiệm 25%</div>
					<div class="plan-name">Gói 6 Tháng</div>
					<div class="plan-price">
						<span class="original-price">$59.94</span> <span
							class="sale-price">$49.99</span>
					</div>
					<div class="plan-duration">Hạn sử dụng: 6 tháng</div>
					<ul class="feature">
						<li>• Xem phim không giới hạn</li>
						<li>• Chất lượng HD & 4K</li>
						<li>• 3 thiết bị đồng thời</li>
						<li>• Không quảng cáo</li>
						<li>• Tải xuống offline</li>
					</ul>
					<button class="buy-button">Đăng Ký Ngay</button>
				</div>
			</form>


			<!-- Gói 1 Năm -->
			<form action="RegisterSubscription" method="POST">
				<input class="hidden" name="plan" value="twelveMonth" />
				<div class="plan-card">
					<div class="save-badge">Tiết kiệm 30%</div>
					<div class="plan-name">Gói 1 Năm</div>
					<div class="plan-price">
						<span class="original-price">$119.88</span> <span
							class="sale-price">$99.99</span>
					</div>
					<div class="plan-duration">Hạn sử dụng: 12 tháng</div>
					<ul class="feature">
						<li>• Xem phim không giới hạn</li>
						<li>• Chất lượng 4K Ultra HD</li>
						<li>• 4 thiết bị đồng thời</li>
						<li>• Không quảng cáo</li>
						<li>• Tải xuống offline</li>
						<li>• Hỗ trợ ưu tiên</li>
					</ul>
					<button class="buy-button">Đăng Ký Ngay</button>
				</div>
			</form>

		</div>
	</main>

	<script>
        const toggle = document.getElementById("theme-toggle");
  const root = document.documentElement; 

  // Mặc định: LIGHT (không có .dark)
  const saved = localStorage.getItem("theme");
  if (saved === "dark") {
    root.classList.add("dark");
  } else {
    root.classList.remove("dark"); 
  }

  // Cập nhật icon
  const updateIcon = () => {
    const isDark = root.classList.contains("dark");
    toggle.classList.toggle("fa-sun", !isDark); 
    toggle.classList.toggle("fa-moon", isDark); 
  };
  updateIcon();

  // Toggle
  toggle.addEventListener("click", () => {
    root.classList.toggle("dark");
    const isDark = root.classList.contains("dark");
    localStorage.setItem("theme", isDark ? "dark" : "light");
    updateIcon();
  });
    </script>
</body>
</html>
