<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Watchlist</title>

  <!-- CSS dự án -->
  <link rel="stylesheet" href="<c:url value='/styles/test.css'/>" />

  <!-- Font Awesome -->
  <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

  <!-- Giữ theme đã lưu trước khi render -->
  <script>
    (function(){
      var saved = localStorage.getItem('theme');
      if (saved === 'dark') document.documentElement.classList.add('dark');
    })();
  </script>
</head>

<body>
  <c:set var="ctx" value="${pageContext.request.contextPath}"/>

  <!-- ===== NAVBAR ===== -->
  <header class="navbar">
    <div class="inner">
      <a class="brand" href="${ctx}/">
        <img src="${ctx}/images/Logo.png" alt="Logo" class="logo-img" />
        <span>HCMUTE</span>
      </a>

      <nav class="nav" aria-label="Chính">
        <a href="${ctx}/HomeServlet?action=TrangChu">Trang chủ</a>
        <a href="${ctx}/HomeServlet?action=TheLoai">Thể loại</a>
        <a href="${ctx}/HomeServlet?action=PhimBo">List Phim</a>
      </nav>

      <div class="actions" aria-label="Tác vụ">
        <form action="${ctx}/HomeServlet" method="get" class="search-form" role="search" aria-label="Tìm phim">
          <input type="hidden" name="action" value="TimKiem">
          <input type="text" name="query" class="search-input" placeholder="Tìm phim..." />
          <button type="submit" class="search-btn" aria-label="Tìm kiếm">
            <i class="fa-solid fa-magnifying-glass"></i>
          </button>
        </form>

        <i class="fa-solid fa-bell" aria-label="Thông báo"></i>

        <!-- Đi qua servlet /watchlist -->
        <a class="action-link" href="${ctx}/watchlist" aria-label="Watchlist">
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

  <!-- ===== NỘI DUNG CHÍNH ===== -->
  <main class="container">
    <h1>Watchlist của bạn</h1>

    <div class="sub">
      <c:choose>
        <c:when test="${not empty watchlist}">
          ${fn:length(watchlist)} phim
        </c:when>
        <c:otherwise>Chưa có phim nào</c:otherwise>
      </c:choose>
    </div>

    <c:if test="${not empty watchlist}">
      <div class="toolbar">
        <strong>Watchlist</strong>
        <select id="sortSelect" aria-label="Sắp xếp">
          <option value="newest">Sắp xếp: Mới thêm</option>
          <option value="az">Tên A → Z</option>
          <option value="za">Tên Z → A</option>
        </select>
      </div>
    </c:if>

    <!-- Trạng thái rỗng -->
    <c:if test="${empty watchlist}">
      <div class="empty">Chưa có phim nào trong watchlist.</div>
    </c:if>

    <!-- Lưới phim -->
    <c:if test="${not empty watchlist}">
      <section id="movieGrid" class="grid">
        <c:forEach var="m" items="${watchlist}">
          <article class="card">
            <c:choose>
              <c:when test="${not empty m.src}">
                <img class="poster" src="${m.src}" alt="${m.title}" />
              </c:when>
              <c:otherwise>
                <div class="no-poster">Không có ảnh</div>
              </c:otherwise>
            </c:choose>

            <div class="meta">
              <p class="title">${m.title}</p>
              <p class="year">Năm: ${m.year}</p>

              <form action="${ctx}/watchlist" method="post">
                <input type="hidden" name="action" value="remove"/>
                <input type="hidden" name="videoId" value="${m.id}"/>
                <button class="btn danger" type="submit">Xóa</button>
              </form>
            </div>
          </article>
        </c:forEach>
      </section>
    </c:if>
  </main>

  <!-- ===== SCRIPT: Theme + Sắp xếp ===== -->
  <script>
    // Toggle theme
    (function () {
      const toggle = document.getElementById('theme-toggle');
      const root = document.documentElement;

      function syncIcon() {
        if (root.classList.contains('dark')) {
          toggle.classList.remove('fa-sun'); toggle.classList.add('fa-moon');
        } else {
          toggle.classList.remove('fa-moon'); toggle.classList.add('fa-sun');
        }
      }
      syncIcon();

      toggle?.addEventListener('click', () => {
        const isDark = root.classList.toggle('dark');
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
        syncIcon();
      });
    })();

    // Sắp xếp client-side
    (function (){
      const sortSelect = document.getElementById('sortSelect');
      const grid = document.getElementById('movieGrid');
      if (!sortSelect || !grid) return;

      sortSelect.addEventListener('change', () => {
        const cards = Array.from(grid.querySelectorAll('.card'));
        const type = sortSelect.value;

        if (type === 'az') {
          cards.sort((a, b) =>
            a.querySelector('.title').textContent
              .localeCompare(b.querySelector('.title').textContent, 'vi', {sensitivity:'base'})
          );
        } else if (type === 'za') {
          cards.sort((a, b) =>
            b.querySelector('.title').textContent
              .localeCompare(a.querySelector('.title').textContent, 'vi', {sensitivity:'base'})
          );
        } else {
          // newest: reload để giữ thứ tự theo SQL (added_at DESC)
          location.reload();
          return;
        }

        grid.innerHTML = '';
        cards.forEach(card => grid.appendChild(card));
      });
    })();
  </script>
</body>
</html>
