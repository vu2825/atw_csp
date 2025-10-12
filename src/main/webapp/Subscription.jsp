<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Gói Xem Phim - Chọn Kế Hoạch Của Bạn</title>
<link rel="stylesheet" href="styles/style.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* CSS cho Navbar - Giống trang chủ, light theme mặc định */
body {
	font-family: Arial, sans-serif;
	background-color: #f8f9fa; /* Nền sáng nhạt cho light theme */
	color: #333;
	margin: 0;
	padding: 0; /* Không padding để navbar sát top */
}

.navbar {
	background: #f8f9fa;
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 10px 20px;
	width: 100%;
	box-sizing: border-box;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* Bóng nhẹ */
}

.logo {
	flex: 0 0 auto;
}

.logo-img {
	height: 40px;
	width: auto;
}

nav {
	display: flex;
	justify-content: center;
	flex: 1;
	gap: 20px;
}

nav a {
	text-decoration: none;
	color: #333;
	font-weight: 500;
	padding: 8px 12px;
	border-radius: 4px;
	transition: background-color 0.3s;
}

nav a:hover {
	background-color: #e9ecef;
	color: #007bff;
}

.nav-icons {
	display: flex;
	align-items: center;
	gap: 15px;
	flex: 0 0 auto;
}

.nav-icons i {
	font-size: 18px;
	color: #666;
	cursor: pointer;
	transition: color 0.3s;
}

.nav-icons i:hover {
	color: #007bff;
}

.nav-icons a {
	text-decoration: none;
	color: inherit;
}

/* Nội dung pricing - Cách navbar */
h1 {
	text-align: center;
	color: #495057;
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
	<header class="navbar">
		<div class="logo">
			<img src="images/Logo.png" alt="Logo" class="logo-img">
		</div>

		<nav>
			<a href="HomeServlet?action=TrangChu">Trang chủ</a> <a
				href="HomeServlet?action=TheLoai">Thể loại</a> <a
				href="HomeServlet?action=PhimBo">Phim bộ</a> <a
				href="HomeServlet?action=PhimLe">Phim lẻ</a> <a
				href="HomeServlet?action=QuocGia">Quốc gia</a>
		</nav>

		<div class="nav-icons">
			<i id="search-icon" class="fa-solid fa-magnifying-glass"></i> <i
				class="fa-solid fa-bell"></i> <i class="fa-solid fa-bookmark"></i> <a
				href="HomeServlet?action=GioHang"> <i
				class="fa-solid fa-cart-shopping"></i>
			</a> <a href="HomeServlet?action=TaiKhoan"> <i
				class="fa-solid fa-user"></i>
			</a> <i id="theme-toggle" class="fa-solid fa-sun"></i>
		</div>
	</header>

	<main>
		<h1>Chọn Gói Xem Phim Của Bạn</h1>
		<p
			style="text-align: center; color: #6c757d; margin-bottom: 40px; padding: 0 20px;">Khuyến
			mãi đặc biệt - Tiết kiệm ngay hôm nay với giá giảm!</p>

		<%-- Hiển thị thông báo thành công NẾU có --%>
		<c:if test="${not empty message}">
			<div class="alert alert-success">
				<i class="fa-solid fa-circle-check"></i>
				<c:out value="${message}" />
			</div>
		</c:if>

		<%-- Hiển thị thông báo lỗi NẾU có --%>
		<c:if test="${not empty error}">
			<div class="alert alert-error">
				<i class="fa-solid fa-triangle-exclamation"></i>
				<c:out value="${error}" />
			</div>
		</c:if>


		<div class="plans-container">
			<!-- Gói 1 Tháng -->
			<form action="RegisterSubcription" method="POST">
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
			<form action="RegisterSubcription" method="POST">
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
			<form action="RegisterSubcription" method="POST">
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
        const body = document.body;

        const savedTheme = localStorage.getItem("theme");
        if (savedTheme === "light") {
            body.classList.add("light-mode");
            toggle.classList.replace("fa-sun", "fa-moon");
        }

        toggle.addEventListener("click", () => {
            body.classList.toggle("light-mode");
            const isLight = body.classList.contains("light-mode");
            toggle.classList.toggle("fa-sun", !isLight);
            toggle.classList.toggle("fa-moon", isLight);
            localStorage.setItem("theme", isLight ? "light" : "dark");
        });
    </script>
</body>
</html>
