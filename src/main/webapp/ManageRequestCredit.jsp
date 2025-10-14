<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8" />
<title>Quản Trị Nạp Tiền</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
<link rel="stylesheet" href="<c:url value='/styles/style.css'/>" />
<style>
body {
	font-family: Arial, sans-serif;
	background: #f8f9fa;
	color: #333;
	margin: 0;
}


.nav-icons {
	display: flex;
	gap: 15px;
	align-items: center;
}

.container {
	max-width: 1200px;
	margin: 24px auto;
	padding: 0 16px;
}

h1 {
	margin: 16px 0 8px;
	color: #334155;
}

.filters {
	display: flex;
	gap: 12px;
	flex-wrap: wrap;
	align-items: center;
	margin: 12px 0 16px;
}

.filters input, .filters select {
	padding: 8px 10px;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
}

.filters button {
	background: #0ea5e9;
	color: #fff;
	border: none;
	padding: 9px 14px;
	border-radius: 8px;
	cursor: pointer;
}

.filters button:hover {
	background: #0284c7;
}

.actions {
	display: flex;
	gap: 10px;
	align-items: center;
	margin: 12px 0;
}

.bulk {
	display: flex;
	gap: 8px;
	align-items: center;
}

.bulk select, .bulk button {
	padding: 8px 10px;
	border-radius: 8px;
	border: 1px solid #e2e8f0;
}

.bulk button {
	background: #22c55e;
	color: #fff;
	border: none;
}

.bulk button:hover {
	background: #16a34a;
}

.table {
	width: 100%;
	border-collapse: collapse;
	background: #fff;
}

.table th, .table td {
	padding: 10px 10px;
	border-bottom: 1px solid #e5e7eb;
	text-align: left;
	vertical-align: middle;
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

.row-actions {
	display: flex;
	gap: 8px;
}

.btn-accept {
	background: #10b981;
	color: #fff;
	border: none;
	padding: 7px 10px;
	border-radius: 6px;
	cursor: pointer;
}

.btn-reject {
	background: #ef4444;
	color: #fff;
	border: none;
	padding: 7px 10px;
	border-radius: 6px;
	cursor: pointer;
}

.btn-accept:hover {
	background: #059669;
}

.btn-reject:hover {
	background: #dc2626;
}

.note-input {
	width: 100%;
	max-width: 240px;
	padding: 7px 8px;
	border: 1px solid #e2e8f0;
	border-radius: 6px;
}

.summary {
	display: flex;
	gap: 12px;
	flex-wrap: wrap;
	margin: 16px 0;
}

.chip {
	background: #f1f5f9;
	color: #0f172a;
	padding: 8px 12px;
	border-radius: 8px;
	border: 1px solid #e2e8f0;
}

body:not(.light-mode) .table {
	background: #111;
}

body:not(.light-mode) .table th {
	background: #161616;
	color: #cbd5e1;
}

body:not(.light-mode) .table td {
	border-bottom-color: #242424;
	color: #e5e7eb;
}

body:not(.light-mode) .filters input, body:not(.light-mode) .filters select
	{
	background: #0f0f0f;
	color: #e5e7eb;
	border-color: #2b2b2b;
}

body:not(.light-mode) .note-input {
	background: #0f0f0f;
	color: #e5e7eb;
	border-color: #2b2b2b;
}
</style>
</head>
<body>
	<c:set var="ctx" value="${pageContext.request.contextPath}" />
	<header class="navbar">
		<div class="inner">
			<a class="brand" href="${ctx}/"> <img
				src="${ctx}/images/Logo.png" alt="Logo" class="logo-img" /> <span>HCMUTE</span>
			</a>

			<nav class="nav" aria-label="Chính">
				<a href="${ctx}/HomeServlet?action=TrangChu">Trang chủ</a> <a
					href="${ctx}/HomeServlet?action=TheLoai">Thể loại</a> <a
					href="${ctx}/HomeServlet?action=PhimBo">Phim bộ</a> <a
					href="${ctx}/HomeServlet?action=PhimLe">Phim lẻ</a> <a
					href="${ctx}/HomeServlet?action=QuocGia">Quốc gia</a>
			</nav>

			<div class="actions" aria-label="Tác vụ">
				<form action="${ctx}/HomeServlet" method="get" class="search-form"
					role="search" aria-label="Tìm phim">
					<input type="hidden" name="action" value="TimKiem"> <input
						type="text" name="query" class="search-input"
						placeholder="Tìm phim..." />
					<button type="submit" class="search-btn" aria-label="Tìm kiếm">
						<i class="fa-solid fa-magnifying-glass"></i>
					</button>
				</form>

				<i class="fa-solid fa-bell" aria-label="Thông báo"></i> <a
					class="action-link" href="${ctx}/HomeServlet?action=watchlist"
					aria-label="Watchlist"> <i class="fa-solid fa-bookmark"></i>
				</a> <a class="action-link" href="${ctx}/HomeServlet?action=GioHang"
					aria-label="Giỏ hàng"> <i class="fa-solid fa-cart-shopping"></i>
				</a> <a class="action-link" href="${ctx}/HomeServlet?action=TaiKhoan"
					aria-label="Tài khoản"> <i class="fa-solid fa-user"></i>
				</a> <i id="theme-toggle" class="fa-solid fa-sun"
					aria-label="Đổi giao diện sáng/tối"></i>
			</div>
		</div>
	</header>

	<main class="container">
		<h1>Quản Trị Nạp Tiền</h1>

		<!-- Filters -->
		<form class="filters" method="GET"
			action="<c:url value='/admin/topups'/>">
			<input type="text" name="q" value="${param.q}"
				placeholder="Tìm mã GD / user..." /> <select name="status">
				<option value="">Tất cả</option>
				<option value="PENDING"
					${param.status == 'PENDING' ? 'selected' : ''}>Đang chờ</option>
				<option value="ACCEPT"
					${param.status == 'ACCEPT'  ? 'selected' : ''}>Thành công</option>
				<option value="DISCARD"
					${param.status == 'DISCARD' ? 'selected' : ''}>Từ chối</option>
			</select>
			<button type="submit">
				<i class="fa-solid fa-filter"></i> Lọc
			</button>
		</form>

		<!-- Summary counters -->
		<c:set var="countPending" value="0" scope="page" />
		<c:set var="countAccept" value="0" scope="page" />
		<c:set var="countDiscard" value="0" scope="page" />

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
		</c:forEach>

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

		<!-- Bulk actions -->
		<form class="actions" method="POST"
			action="<c:url value='/AdminTopUpServlet'/>">
			<input type="hidden" name="action" value="BulkAction" />
			<div class="bulk">
				<label>Thao tác hàng loạt:</label> <select name="bulkType" required>
					<option value="ACCEPT">Duyệt</option>
					<option value="DISCARD">Từ chối</option>
				</select>
				<button type="submit">
					<i class="fa-solid fa-check-double"></i> Thực hiện
				</button>
			</div>
		</form>

		<!-- Table -->
		<table class="table">
			<thead>
				<tr>
					<th><input type="checkbox" id="check-all" /></th>
					<th>Mã giao dịch</th>
					<th>Người dùng</th>
					<th>Số tiền</th>
					<th>Trạng thái</th>
					<th>Ghi chú</th>
					<th>Tạo lúc</th>
					<th>Cập nhật</th>
					<th>Hành động</th>
				</tr>
			</thead>
			<tbody>
				<c:choose>
					<c:when test="${empty topups}">
						<tr>
							<td colspan="9">Không có yêu cầu nào.</td>
						</tr>
					</c:when>
					<c:otherwise>
						<c:forEach var="t" items="${topups}">
							<tr>
								<td>
									<form method="POST"
										action="<c:url value='/AdminTopUpServlet'/>"
										id="bulk-form-${t.id}">
										<input type="checkbox" name="ids" value="${t.id}"
											class="row-check" form="bulk-master-form" />
									</form>
								</td>
								<td><c:out value="${t.id}" /></td>
								<td><c:out value="${t.user.username}" /> <br /> <small><c:out
											value="${t.user.email}" /></small></td>
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
								<td>
									<form class="row-actions" method="POST"
										action="<c:url value='/AdminTopUpServlet'/>">
										<input type="hidden" name="id" value="${t.id}" /> <input
											type="text" name="note" placeholder="Ghi chú..."
											class="note-input" />
										<button type="submit" name="action" value="ACCEPT"
											class="btn-accept">
											<i class="fa-solid fa-check"></i>
										</button>
										<button type="submit" name="action" value="DISCARD"
											class="btn-reject">
											<i class="fa-solid fa-xmark"></i>
										</button>
									</form>
								</td>
								<td><fmt:formatDate value="${t.created_at}"
										pattern="yyyy-MM-dd HH:mm" /></td>
								<td><fmt:formatDate value="${t.updated_at}"
										pattern="yyyy-MM-dd HH:mm" /></td>
								<td><a
									href="<c:url value='/admin/topups/detail?id=${t.id}'/>">Chi
										tiết</a></td>
							</tr>
						</c:forEach>
					</c:otherwise>
				</c:choose>
			</tbody>
		</table>

		<!-- Master hidden form to carry selected IDs for bulk -->
		<form id="bulk-master-form" method="POST"
			action="<c:url value='/AdminTopUpServlet'/>">
			<input type="hidden" name="action" value="BulkAction" />
		</form>

		<!-- Pagination (tuỳ chọn) -->
		<c:if test="${pageCount > 1}">
			<div class="pagination"
				style="margin: 16px 0; display: flex; gap: 8px;">
				<c:forEach var="p" begin="1" end="${pageCount}">
					<a
						href="<c:url value='/admin/topups?status=${param.status}&q=${param.q}&page=${p}'/>"
						style="padding:6px 10px; border:1px solid #e2e8f0; border-radius:6px; background:${p==page?'#0ea5e9':'#fff'}; color:${p==page?'#fff':'#000'};">
						${p} </a>
				</c:forEach>
			</div>
		</c:if>
	</main>

	<script>
  // Theme toggle đồng bộ với trang user
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

  // Bulk check/uncheck
  (function(){
    const master = document.getElementById("check-all");
    const checks = Array.from(document.querySelectorAll(".row-check"));
    if (master) {
      master.addEventListener("change", () => {
        checks.forEach(c => c.checked = master.checked);
      });
    }
  })();
</script>
</body>
</html>
