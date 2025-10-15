<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Lịch Sử Nạp Tiền</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<!-- Styles nội bộ ứng dụng -->
<link rel="stylesheet" href="styles/style.css">
<style>
body {
	font-family: Arial, sans-serif;
	background: #f8f9fa;
	color: #333;
	margin: 0;
}

.container {
	max-width: 1080px;
	margin: 24px auto;
	padding: 0 16px;
}

h1 {
	margin: 16px 0 8px;
	color: #334155;
}

.table {
	width: 100%;
	border-collapse: collapse;
	background: #fff;
}

.table th, .table td {
	padding: 12px 10px;
	border-bottom: 1px solid #e5e7eb;
	text-align: left;
}

.table th {
	background: #f8fafc;
	color: #475569;
	font-weight: 600;
}

.status {
	padding: 4px 10px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 600;
	display: inline-block;
}

.s-pending {
	background: #fff7ed;
	color: #c2410c;
	border: 1px solid #fed7aa;
}

.s-accept {
	background: #ecfdf5;
	color: #047857;
	border: 1px solid #a7f3d0;
}

.s-discard {
	background: #fef2f2;
	color: #b91c1c;
	border: 1px solid #fecaca;
}

.summary {
	display: flex;
	gap: 12px;
	flex-wrap: wrap;
	margin-top: 16px;
}

.chip {
	background: #f1f5f9;
	color: #0f172a;
	padding: 8px 12px;
	border-radius: 8px;
	border: 1px solid #e2e8f0;
}

.empty {
	padding: 16px;
	background: #f8fafc;
	border: 1px dashed #e2e8f0;
	border-radius: 8px;
	color: #64748b;
}

/* ==== Topup form ==== */
.topup-box {
	max-width: 720px;
	margin: 16px auto 24px;
	padding: 16px;
	background: #ffffff;
	border: 1px solid #e5e7eb;
	border-radius: 10px;
}

.topup-form {
	display: flex;
	gap: 12px;
	align-items: center;
	flex-wrap: wrap;
}

.topup-label {
	font-weight: 600;
	color: #334155;
}

.topup-input-group {
	position: relative;
	flex: 1 1 280px;
	min-width: 260px;
}

.topup-input-group .prefix {
	position: absolute;
	top: 50%;
	left: 12px;
	transform: translateY(-50%);
	color: #64748b;
	pointer-events: none;
}

.amount-input {
	width: 100%;
	padding: 10px 12px 10px 28px; /* chừa chỗ cho $ */
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	font-size: 14px;
	color: #0f172a;
	background: #fff;
	outline: none;
	transition: border-color .2s, box-shadow .2s;
}

.amount-input:focus {
	border-color: #93c5fd;
	box-shadow: 0 0 0 3px rgba(59, 130, 246, .2);
}

.topup-submit {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	background: #007bff;
	color: #fff;
	border: none;
	padding: 10px 15px;
	margin: 0 30px;
	border-radius: 8px;
	font-weight: 600;
	cursor: pointer;
	transition: transform .15s ease, box-shadow .2s ease, background .2s
		ease;
}

.topup-submit:hover {
	background: #0056b3;
	transform: translateY(-1px);
	box-shadow: 0 6px 16px rgba(0, 123, 255, .25);
}

/* Dark mode hòa tông với nền tối của app */
body:not(.light-mode) .topup-box {
	background: #151515;
	border-color: #2b2b2b;
}

body:not(.light-mode) .topup-label {
	color: #e2e8f0;
}

body:not(.light-mode) .amount-input {
	background: #0f0f0f;
	color: #e5e7eb;
	border-color: #2b2b2b;
}

body:not(.light-mode) .amount-input:focus {
	border-color: #60a5fa;
	box-shadow: 0 0 0 3px rgba(37, 99, 235, .35);
}

.logo-img {
	width: 40px;
}

/* Responsive */
@media ( max-width : 768px) {
	.topup-form {
		flex-direction: column;
		align-items: stretch;
	}
	.topup-submit {
		justify-content: center;
	}
}

.hidden {
	display: none;
}
</style>
</head>
<body>
	<c:set var="ctx" value="${pageContext.request.contextPath}" />
	<!-- Header inline, không include -->
	<header class="navbar">
		<div class="inner">
			<a class="brand" href="${ctx}/"> <img
				src="${ctx}/images/Logo.png" alt="Logo" class="logo-img" /> <span>HCMUTE</span>
			</a>

			<nav class="nav" aria-label="Chính">
				<a href="${ctx}/HomeServlet?action=TrangChu">Trang chủ</a> <a
					href="${ctx}/TheLoaiServlet">Thể loại</a> <a
					href="${ctx}/HomeServlet?action=PhimBo">List Phim</a>
			</nav>

			<div class="actions" aria-label="Tác vụ">
				<form id="search-form"
					action="${pageContext.request.contextPath}/SearchServlet"
					method="get" class="search-form" role="search">
					<input type="text" id="search-input" name="query"
						class="search-input" placeholder="Tìm phim..." autocomplete="off" />
					<button type="submit" class="search-btn">
						<i class="fa-solid fa-magnifying-glass"></i>
					</button>
					<ul id="suggestions" class="suggestions-list"></ul>
				</form>
				<i class="fa-solid fa-bell" aria-label="Thông báo"></i> <a
					class="action-link" href="${ctx}/WatchlistServlet"
					aria-label="Watchlist"> <i class="fa-solid fa-bookmark"></i>
				</a> <a class="action-link" href="${ctx}/Subscription.jsp"
					aria-label="Giỏ hàng"> <i class="fa-solid fa-cart-shopping"></i>
				</a> <a class="action-link" href="${ctx}/HomeServlet?action=TaiKhoan"
					aria-label="Tài khoản"> <i class="fa-solid fa-user"></i>
				</a> <i id="theme-toggle" class="fa-solid fa-sun"
					aria-label="Đổi giao diện sáng/tối"></i>
			</div>
		</div>
	</header>

	<section class="topup-box">
		<form action="TopUpRequest" method="POST" class="topup-form">
			<input name="action" value="AddCredit" class="hidden" /> <label
				for="amount" class="topup-label">Yêu cầu nạp tiền</label>
			<div class="topup-input-group">
				<span class="prefix">$</span> <input id="amount" name="amount"
					type="number" min="1" step="0.01" placeholder="Nhập số tiền..."
					required class="amount-input" />
			</div>
			<button type="submit" class="topup-submit">
				<i class="fa-solid fa-circle-plus" aria-hidden="true"></i> <span>Tạo
					yêu cầu</span>
			</button>
		</form>
	</section>

	<main class="container">
		<h1>Lịch Sử Nạp Tiền</h1>

		<!-- Bộ đếm trạng thái -->
		<c:set var="countPending" value="0" scope="page" />
		<c:set var="countAccept" value="0" scope="page" />
		<c:set var="countDiscard" value="0" scope="page" />

		<c:choose>
			<c:when test="${empty topups}">
				<div class="empty">Chưa có lịch sử nạp tiền nào.</div>
			</c:when>
			<c:otherwise>
				<table class="table">
					<thead>
						<tr>
							<th>Mã giao dịch</th>
							<th>Số tiền</th>
							<th>Trạng thái</th>
							<th>Tạo lúc</th>
							<th>Cập nhật lúc</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="t" items="${topups}">
							<c:if test="${t.status.name() == 'PENDING'}">
								<c:set var="countPending" value="${countPending + 1}" />
							</c:if>
							<c:if test="${t.status.name() == 'ACCEPT'}">
								<c:set var="countAccept" value="${countAccept + 1}" />
							</c:if>
							<c:if test="${t.status.name() == 'DISCARD'}">
								<c:set var="countDiscard" value="${countDiscard + 1}" />
							</c:if>

							<tr>
								<td><c:out value="${t.id}" /></td>
								<td><fmt:formatNumber value="${t.amount}" type="currency"
										currencySymbol="$" groupingUsed="true" /></td>
								<td><c:choose>
										<c:when test="${t.status.name() == 'PENDING'}">
											<span class="status s-pending">Đang chờ</span>
										</c:when>
										<c:when test="${t.status.name() == 'ACCEPT'}">
											<span class="status s-accept">Thành công</span>
										</c:when>
										<c:otherwise>
											<span class="status s-discard">Từ chối</span>
										</c:otherwise>
									</c:choose></td>
								<td><fmt:formatDate value="${t.created_at}"
										pattern="yyyy-MM-dd HH:mm" /></td>
								<td><fmt:formatDate value="${t.updated_at}"
										pattern="yyyy-MM-dd HH:mm" /></td>
							</tr>
						</c:forEach>


					</tbody>
				</table>

				<!-- Tổng hợp trạng thái -->
				<section class="summary" aria-label="Tổng hợp trạng thái">
					<div class="chip">
						Đang chờ: <strong>${countPending}</strong>
					</div>
					<div class="chip">
						Thành công: <strong>${countAccept}</strong>
					</div>
					<div class="chip">
						Từ chối: <strong>${countDiscard}</strong>
					</div>
					<div class="chip">
						Tổng: <strong>${countPending + countAccept + countDiscard}</strong>
					</div>
				</section>
			</c:otherwise>
		</c:choose>
	</main>

	<script>
  // Theme toggle giữ nguyên hành vi
  (function() {
    const toggle = document.getElementById("theme-toggle");
    if (!toggle) return;
    const body = document.body;
    const saved = localStorage.getItem("theme");
    if (saved === "light") { body.classList.add("light-mode"); toggle.classList.replace("fa-sun","fa-moon"); }
    toggle.addEventListener("click", () => {
      body.classList.toggle("light-mode");
      const isLight = body.classList.contains("light-mode");
      toggle.classList.toggle("fa-sun", !isLight);
      toggle.classList.toggle("fa-moon", isLight);
      localStorage.setItem("theme", isLight ? "light" : "dark");
    });
  })();
</script>

</body>
</html>