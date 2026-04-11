<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8" />
<title>Quản Trị Nạp Tiền</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<!-- Header CSS lấy từ file chung -->
<link rel="stylesheet" href="<c:url value='/styles/style.css'/>">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
/* Chỉ style cho phần nội dung trang (không style header) */
:root {
	--bg: #f8f9fa;
	--surface: #ffffff;
	--text: #1f2937;
	--muted: #64748b;
	--border: #e5e7eb;
	--primary: #0ea5e9;
	--primary-600: #0284c7;
	--success: #10b981;
	--success-600: #059669;
	--danger: #ef4444;
	--danger-600: #dc2626;
	--chip-bg: #f1f5f9;
	--chip-text: #0f172a;
	--table-head-bg: #f8fafc;
	--table-head-text: #475569;
}

body:not(.light-mode) {
	--bg: #0e0e10;
	--surface: #151515;
	--text: #e5e7eb;
	--muted: #a1a1aa;
	--border: #2b2b2b;
	--primary: #38bdf8;
	--primary-600: #0ea5e9;
	--success: #22c55e;
	--success-600: #16a34a;
	--danger: #f87171;
	--danger-600: #ef4444;
	--chip-bg: #1f2937;
	--chip-text: #e5e7eb;
	--table-head-bg: #161616;
	--table-head-text: #cbd5e1;
}

* {
	box-sizing: border-box;
}

html, body {
	height: 100%;
}

body {
	background: var(--bg);
	color: var(--text);
	margin: 0;
	font-family: Arial, sans-serif;
}

/* Nội dung chính */
.container {
	max-width: 1200px;
	margin: 24px auto;
	padding: 0 16px;
}

h1 {
	margin: 16px 0 12px;
	color: var(--text);
}

/* Bộ lọc và hành động trang (đổi class để không trùng với header) */
.page-filters {
	display: flex;
	gap: 12px;
	flex-wrap: wrap;
	align-items: center;
	margin: 12px 0 16px;
}

.page-filters input, .page-filters select {
	padding: 8px 10px;
	border: 1px solid var(--border);
	border-radius: 8px;
	background: var(--surface);
	color: var(--text);
}

.page-filters button {
	background: var(--primary);
	color: #fff;
	border: none;
	padding: 9px 14px;
	border-radius: 8px;
	cursor: pointer;
}

.page-filters button:hover {
	background: var(--primary-600);
}

.page-actions {
	display: flex;
	gap: 10px;
	align-items: center;
	margin: 12px 0;
}

.page-bulk {
	display: flex;
	gap: 8px;
	align-items: center;
}

.page-bulk select, .page-bulk button {
	padding: 8px 10px;
	border-radius: 8px;
	border: 1px solid var(--border);
	background: var(--surface);
	color: var(--text);
}

.page-bulk button {
	background: #22c55e;
	border: none;
	color: #fff;
}

.page-bulk button:hover {
	background: #16a34a;
}

/* Thống kê */
.summary {
	display: flex;
	gap: 12px;
	flex-wrap: wrap;
	margin: 16px 0;
}

.chip {
	background: var(--chip-bg);
	color: var(--chip-text);
	padding: 8px 12px;
	border-radius: 10px;
	border: 1px solid var(--border);
}

/* Bảng */
.table-wrapper {
	overflow-x: auto;
}

.table {
	width: 100%;
	border-collapse: collapse;
	background: var(--surface);
}

.table th, .table td {
	padding: 10px 10px;
	border-bottom: 1px solid var(--border);
	text-align: left;
	vertical-align: middle;
	color: var(--text);
}

.table th {
	background: var(--table-head-bg);
	color: var(--table-head-text);
	font-weight: 600;
}

/* Trạng thái dạng pill */
.status {
	padding: 4px 10px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 600;
	display: inline-block;
	border: 1px solid transparent;
}

.s-pending {
	background: #fff7ed;
	color: #c2410c;
	border-color: #fed7aa;
}

.s-accept {
	background: #ecfdf5;
	color: #047857;
	border-color: #a7f3d0;
}

.s-discard {
	background: #fef2f2;
	color: #b91c1c;
	border-color: #fecaca;
}

body:not(.light-mode) .s-pending {
	background: #2b190e;
	color: #f59e0b;
	border-color: #92400e;
}

body:not(.light-mode) .s-accept {
	background: #052e1a;
	color: #22c55e;
	border-color: #166534;
}

body:not(.light-mode) .s-discard {
	background: #3b0d0d;
	color: #f87171;
	border-color: #7f1d1d;
}

/* Nút theo hàng */
.row-actions {
	display: inline-flex;
	gap: 8px;
}

.btn-accept, .btn-reject {
	border: none;
	padding: 7px 10px;
	border-radius: 6px;
	cursor: pointer;
	color: #fff;
}

.btn-accept {
	background: var(--success);
}

.btn-accept:hover {
	background: var(--success-600);
}

.btn-reject {
	background: var(--danger);
}

.btn-reject:hover {
	background: var(--danger-600);
}

.btn-accept[disabled], .btn-reject[disabled] {
	opacity: .6;
	cursor: not-allowed;
}

/* Thông báo */
.alert {
	max-width: 720px;
	margin: 0 auto 20px;
	padding: 12px 16px;
	border-radius: 8px;
	border: 1px solid transparent;
	display: flex;
	align-items: center;
	gap: 8px;
	justify-content: center;
	text-align: center;
}

.alert-success {
	color: #0f5132;
	background-color: #d1e7dd;
	border-color: #badbcc;
}

.alert-error {
	color: #842029;
	background-color: #f8d7da;
	border-color: #f5c2c7;
}

@media ( max-width : 768px) {
	.table-wrapper {
		margin: 0 -16px;
		padding: 0 16px;
	}
}
</style>
</head>
<body>
	<c:set var="ctx" value="${pageContext.request.contextPath}" />

	<!-- Header: dùng nguyên markup của bạn, CSS của header lấy từ styles/style.css -->
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

	<main class="container">
		<h1>Quản Trị Nạp Tiền</h1>

		<!-- Alerts từ PRG -->
		<c:if test="${not empty param.message}">
			<div class="alert alert-success">
				<span><c:out value="${param.message}" /></span>
			</div>
		</c:if>
		<c:if test="${not empty param.error}">
			<div class="alert alert-error">
				<span><c:out value="${param.error}" /></span>
			</div>
		</c:if>
		<c:if test="${not empty param.ok or not empty param.fail}">
			<div
				class="alert ${param.fail gt 0 ? 'alert-error' : 'alert-success'}">
				<c:if test="${param.ok gt 0}">
					<span><c:out value="${param.ok}" /> cập nhật thành công.</span>
				</c:if>
				<c:if test="${param.fail gt 0}">
					<span><c:out value="${param.fail}" /> bỏ qua (không còn
						pending).</span>
				</c:if>
			</div>
		</c:if>

		<!-- Bộ lọc -->
		<form class="page-filters" method="GET"
			action="<c:url value='/AdminTopUpServlet'/>">
			<input type="text" name="q" value="${param.q}"
				placeholder="Tìm id / userId..." /> <select name="status">
				<option value="">Tất cả</option>
				<option value="PENDING"
					${param.status == 'PENDING' ? 'selected' : ''}>Đang chờ</option>
				<option value="ACCEPT"
					${param.status == 'ACCEPT'  ? 'selected' : ''}>Thành công</option>
				<option value="DISCARD"
					${param.status == 'DISCARD' ? 'selected' : ''}>Từ chối</option>
			</select>
			<button type="submit">Lọc</button>
		</form>

		<!-- Đếm trạng thái -->
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



		<!-- Bảng dữ liệu -->
		<div class="table-wrapper">
			<table class="table">
				<thead>
					<tr>
						<th>Mã giao dịch</th>
						<th>User ID</th>
						<th>Số tiền</th>
						<th>Trạng thái</th>
						<th>Tạo lúc</th>
						<th>Cập nhật</th>
						<th>Hành động</th>
					</tr>
				</thead>
				<tbody>
					<c:choose>
						<c:when test="${empty topups}">
							<tr>
								<td colspan="8">Không có yêu cầu nào.</td>
							</tr>
						</c:when>
						<c:otherwise>
							<c:forEach var="t" items="${topups}">
								<tr>

									<td><c:out value="${t.id}" /></td>
									<td><c:out value="${t.userId}" /></td>
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
									<td><fmt:formatDate value="${t.createdAt}"
											pattern="yyyy-MM-dd HH:mm" /></td>
									<td><fmt:formatDate value="${t.updatedAt}"
											pattern="yyyy-MM-dd HH:mm" /></td>
									<td><c:choose>
											<c:when test="${t.status.name() == 'PENDING'}">
												<form class="row-actions" method="POST"
													action="<c:url value='/AdminTopUpServlet'/>">
													<input type="hidden" name="id" value="${t.id}" />
													<button type="submit" name="action" value="ACCEPT"
														class="btn-accept" title="Duyệt">Duyệt</button>
													<button type="submit" name="action" value="DISCARD"
														class="btn-reject" title="Từ chối">Từ chối</button>
												</form>
											</c:when>
											<c:otherwise>
												<button class="btn-accept" disabled>Duyệt</button>
												<button class="btn-reject" disabled>Từ chối</button>
											</c:otherwise>
										</c:choose></td>
								</tr>
							</c:forEach>
						</c:otherwise>
					</c:choose>
				</tbody>
			</table>
		</div>

		<!-- Form master gom IDs cho bulk -->
		<form id="bulk-master-form" method="POST"
			action="<c:url value='/AdminTopUpServlet'/>">
			<input type="hidden" name="action" value="BulkAction" />
		</form>
	</main>

	<script>
  // Theme toggle: giữ nguyên cơ chế class light-mode của app
  (function() {
    const toggle = document.getElementById("theme-toggle");
    if (!toggle) return;
    const body = document.body;
    const saved = localStorage.getItem("theme");
    if (saved === "light") body.classList.add("light-mode");
    toggle.addEventListener("click", () => {
      body.classList.toggle("light-mode");
      localStorage.setItem("theme", body.classList.contains("light-mode") ? "light" : "dark");
    });
  })();

  // Bulk: master checkbox chỉ tác động các checkbox chưa disabled (tức là pending)
  (function(){
    const master = document.getElementById("check-all");
    const checks = Array.from(document.querySelectorAll(".row-check"));
    if (master) {
      master.addEventListener("change", () => {
        checks.forEach(c => { if (!c.disabled) c.checked = master.checked; });
      });
    }
  })();
</script>

	<script>
        const input = document.getElementById("search-input");
        const suggestionsList = document.getElementById("suggestions");

        input.addEventListener("input", () => {
            const query = input.value.trim();
            suggestionsList.classList.remove("show");
            suggestionsList.innerHTML = ""; 
            if (query.length === 0) return;

            const url = "${ctx}/SearchServlet?action=suggest&query=" + encodeURIComponent(query);
            fetch(url)
                .then(res => {
                    if (!res.ok) throw new Error("Network error: " + res.status);
                    return res.json();
                })
                .then(data => {
                    console.log("Dữ liệu gợi ý:", data); 
                    suggestionsList.innerHTML = ""; 
                    if (Array.isArray(data) && data.length > 0) {
                        data.forEach(title => {
                            const li = document.createElement("li");
                            li.textContent = title || "Không có tiêu đề"; 
                            suggestionsList.appendChild(li);
                        });
                        suggestionsList.classList.add("show");
                    } else {
                        const li = document.createElement("li");
                        li.textContent = "Không có gợi ý";
                        suggestionsList.appendChild(li);
                        suggestionsList.classList.add("show");
                    }
                })
                .catch(error => {
                    console.error("Lỗi khi fetch gợi ý:", error);
                    suggestionsList.innerHTML = `<li>Lỗi: ${error.message}</li>`;
                    suggestionsList.classList.add("show");
                });
        });

        suggestionsList.addEventListener("click", e => {
            if (e.target.tagName === "LI") {
                input.value = e.target.textContent;
                suggestionsList.classList.remove("show");
                suggestionsList.innerHTML = "";
                document.getElementById("search-form").submit();
            }
        });
 </script>
</body>
</html>
