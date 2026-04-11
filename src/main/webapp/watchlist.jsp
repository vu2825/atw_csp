<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Watchlist</title>

  <link rel="stylesheet" href="<c:url value='/styles/test.css'/>" />

  <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

  <script>
    (function () {
      var saved = localStorage.getItem('theme');
      if (saved === 'dark') document.documentElement.classList.add('dark');
    })();
  </script>
</head>

<body>
  <c:set var="ctx" value="${pageContext.request.contextPath}"/>

  <button id="theme-toggle" class="theme-fab" aria-label="Đổi giao diện sáng/tối" title="Đổi giao diện">
    <i class="fa-solid fa-sun"></i>
  </button>

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

    <c:if test="${empty watchlist}">
      <div class="empty">Chưa có phim nào trong watchlist.</div>
    </c:if>

    <!-- Lưới phim -->
    <c:if test="${not empty watchlist}">
      <section id="movieGrid" class="grid">
        <c:forEach var="m" items="${watchlist}">
          <!-- Lấy id phim (hỗ trợ cả m.id hoặc m.vid) -->
          <c:set var="mid" value="${empty m.id ? m.vid : m.id}"/>
          <!-- Lấy ảnh poster (ưu tiên m.src, sau đó m.poster_url) -->
          <c:set var="poster" value="${empty m.src ? m.poster_url : m.src}"/>
          <!-- Lấy năm phát hành (hỗ trợ m.year / m.vyear) -->
          <c:set var="y" value="${empty m.year ? m.vyear : m.year}"/>

          <article class="card">
            <c:choose>
              <c:when test="${not empty poster}">
                <a class="poster-link" href="${ctx}/watch?videoId=${mid}" title="${m.title}">
                  <img class="poster" src="${poster}" alt="${m.title}" />
                </a>
              </c:when>
              <c:otherwise>
                <div class="no-poster">Không có ảnh</div>
              </c:otherwise>
            </c:choose>

            <div class="meta">
              <p class="title">${m.title}</p>
              <c:if test="${not empty y}">
                <span class="year">${y}</span>
              </c:if>

              <div class="actions-row">
                <form action="${ctx}/watchlist" method="post">
                  <input type="hidden" name="action" value="remove"/>
                  <input type="hidden" name="videoId" value="${mid}"/>
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

  <!-- JS: toggle theme + sắp xếp client-side -->
  <script>
    // Helper đặt icon theo trạng thái hiện tại
    function setFabIcon(btn){
      btn.innerHTML = document.documentElement.classList.contains('dark')
        ? '<i class="fa-solid fa-sun"></i>'     // đang Dark -> hiện Sun
        : '<i class="fa-solid fa-moon"></i>';   // đang Light -> hiện Moon
    }

    // Toggle theme
    (function(){
      var btn = document.getElementById('theme-toggle');
      if(!btn) return;
      setFabIcon(btn); // đồng bộ icon khi load

      btn.addEventListener('click', function () {
        var html = document.documentElement;
        var willDark = !html.classList.contains('dark');
        html.classList.toggle('dark', willDark);
        localStorage.setItem('theme', willDark ? 'dark' : 'light');
        setFabIcon(btn);
      });
    })();

    // Sort A-Z / Z-A (client-side)
    (function () {
      var select = document.getElementById('sortSelect');
      var grid = document.getElementById('movieGrid');
      if (!select || !grid) return;

      var originalOrder = Array.from(grid.children);
      select.addEventListener('change', function () {
        var val = this.value;
        if (val === 'newest') {
          grid.innerHTML = '';
          originalOrder.forEach(function (el) { grid.appendChild(el); });
          return;
        }
        var cards = Array.from(grid.children);
        cards.sort(function (a, b) {
          var ta = a.querySelector('.title')?.textContent.trim().toLowerCase() || '';
          var tb = b.querySelector('.title')?.textContent.trim().toLowerCase() || '';
          if (val === 'az') return ta.localeCompare(tb, 'vi');
          if (val === 'za') return tb.localeCompare(ta, 'vi');
          return 0;
        });
        grid.innerHTML = '';
        cards.forEach(function (el) { grid.appendChild(el); });
      });
    })();
  </script>
</body>
</html>
