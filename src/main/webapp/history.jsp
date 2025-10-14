<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Lịch sử xem phim</title>

  <!-- CSS nền dự án (chỉnh 'styles' vs 'Styles' theo thư mục thực tế) -->
  <link rel="stylesheet" href="<c:url value='/styles/test.css'/>" />

  <!-- Font Awesome -->
  <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

  <!-- Giữ theme đã lưu -->
  <script>
    (function(){
      var saved = localStorage.getItem('theme');
      if (saved === 'dark') document.documentElement.classList.add('dark');
    })();
  </script>
</head>

<body>
  <c:set var="ctx" value="${pageContext.request.contextPath}"/>

  <!-- ====== NAVBAR ====== -->
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

        <!-- Watchlist -->
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

  <!-- ====== MAIN ====== -->
  <main class="container">
    <h1>Lịch sử xem phim</h1>

    <div class="sub">
      <c:choose>
        <c:when test="${not empty history}">
          ${fn:length(history)} video đã xem
        </c:when>
        <c:otherwise>Bạn chưa xem phim nào</c:otherwise>
      </c:choose>
    </div>

    <!-- Toolbar sắp xếp -->
    <c:if test="${not empty history}">
      <div class="toolbar">
        <strong>Lịch sử xem</strong>
        <select id="sortSelect" aria-label="Sắp xếp">
          <option value="recent">Mới nhất</option>
          <option value="az">Tên A → Z</option>
          <option value="za">Tên Z → A</option>
        </select>
      </div>
    </c:if>

    <!-- Nếu rỗng -->
    <c:if test="${empty history}">
      <div class="empty">Chưa có lịch sử xem phim. Hãy xem một bộ phim nhé!</div>
    </c:if>

    <!-- Danh sách phim đã xem -->
    <c:if test="${not empty history}">
      <section class="grid" id="historyGrid" aria-label="Danh sách phim đã xem">
        <c:forEach var="h" items="${history}">
          <article class="card">
            <!-- Link xem lại dùng videoId -->
            <a class="poster-link" href="${ctx}/watch?id=${h.videoId}" title="Xem lại">
              <!-- Hướng A: tạm dùng videoUrl làm ảnh nếu có; nếu không có thì hiển thị placeholder -->
              <c:choose>
                <c:when test="${not empty h.videoUrl}">
                  <img class="poster" src="${h.videoUrl}" alt="${h.title}" />
                </c:when>
                <c:otherwise>
                  <div class="no-poster">Không có ảnh</div>
                </c:otherwise>
              </c:choose>
            </a>

            <div class="meta">
              <a class="poster-link" href="${ctx}/watch?id=${h.videoId}" title="Xem lại">
                <p class="title">${h.title}</p>
              </a>

              <!-- Không có year/genre ở backend hiện tại; hiển thị duration nếu có -->
              <c:if test="${not empty h.duration}">
                <div class="year">${h.duration}</div>
              </c:if>

              <div class="progress">Đã xem: ${h.progressSeconds} giây</div>

              <div class="time">
                <i class="fa-regular fa-clock"></i>
                <span>Lần cuối: ${h.lastWatchedAtDisplay}</span>
              </div>

              <div class="actions-row">
                <a class="btn primary" href="${ctx}/watch?id=${h.videoId}">
                  <i class="fa-solid fa-play"></i> Xem lại
                </a>
                <form method="post" action="${ctx}/history">
                  <input type="hidden" name="action" value="remove"/>
                  <!-- Xóa theo id bản ghi history -->
                  <input type="hidden" name="id" value="${h.id}"/>
                  <button class="btn danger" type="submit">
                    <i class="fa-solid fa-trash"></i> Xóa
                  </button>
                </form>
              </div>
            </div>
          </article>
        </c:forEach>
      </section>
    </c:if>
  </main>

  <!-- ====== JS: Theme + Sort ====== -->
  <script>
    // === Đổi theme ===
    (function () {
      const toggle = document.getElementById('theme-toggle');
      const root = document.documentElement;
      if (root.classList.contains('dark')) {
        toggle?.classList.remove('fa-sun');
        toggle?.classList.add('fa-moon');
      }
      toggle?.addEventListener('click', () => {
        const isDark = root.classList.toggle('dark');
        toggle.classList.toggle('fa-sun', !isDark);
        toggle.classList.toggle('fa-moon', isDark);
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
      });
    })();

    // === Sắp xếp lịch sử ===
    (function(){
      const sortSelect = document.getElementById('sortSelect');
      const grid = document.getElementById('historyGrid');
      if (!sortSelect || !grid) return;

      sortSelect.addEventListener('change', () => {
        const cards = Array.from(grid.querySelectorAll('.card'));
        const type = sortSelect.value;

        if (type === 'az') {
          cards.sort((a, b) =>
            a.querySelector('.title').textContent
              .localeCompare(b.querySelector('.title').textContent, 'vi', { sensitivity: 'base' })
          );
        } else if (type === 'za') {
          cards.sort((a, b) =>
            b.querySelector('.title').textContent
              .localeCompare(a.querySelector('.title').textContent, 'vi', { sensitivity: 'base' })
          );
        } else {
          // recent: reload để giữ thứ tự theo SQL (ORDER BY last_watched_at DESC)
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
