<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Lịch sử xem phim</title>

  <!-- CSS nền dự án (đảm bảo test.css đã có block light/dark và .theme-fab như watchlist) -->
  <link rel="stylesheet" href="<c:url value='/styles/test.css'/>" />

  <!-- Font Awesome -->
  <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

  <!-- Áp dụng theme đã lưu TRƯỚC khi render để tránh nháy -->
  <script>
    (function(){
      var saved = localStorage.getItem('theme');
      if (saved === 'dark') document.documentElement.classList.add('dark');
    })();
  </script>
</head>

<body>
  <c:set var="ctx" value="${pageContext.request.contextPath}"/>

  <!-- Nút đổi theme nổi (giống watchlist.jsp) -->
  <button id="theme-toggle" class="theme-fab" aria-label="Đổi giao diện sáng/tối" title="Đổi giao diện">
    <i class="fa-solid fa-sun"></i>
  </button>

  <!-- KHÔNG có topbar. Vào thẳng nội dung -->
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

    <c:if test="${empty history}">
      <div class="empty">Chưa có lịch sử xem phim. Hãy xem một bộ phim nhé!</div>
    </c:if>

    <c:if test="${not empty history}">
      <section class="grid" id="historyGrid" aria-label="Danh sách phim đã xem">
        <c:forEach var="h" items="${history}">
          <article class="card">
            <a class="poster-link" href="${ctx}/watch?id=${h.videoId}" title="Xem lại">
              <c:choose>
                <c:when test="${not empty h.posterUrl}">
                  <img class="poster" src="${h.posterUrl}" alt="${h.title}" />
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

              <c:if test="${not empty h.duration}">
                <div class="year">${h.duration}</div>
              </c:if>

              <div class="progress">Đã xem: ${h.progressSeconds} giây</div>

              <div class="time">
                <i class="fa-regular fa-clock"></i>
                <span>Lần cuối: ${h.lastWatchedAtDisplay}</span>
              </div>

              <div class="actions-row">
                <form method="post" action="${ctx}/history">
                  <input type="hidden" name="action" value="remove"/>
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

  <!-- JS: toggle theme (y chang watchlist) + sắp xếp -->
  <script>
    // Đồng bộ icon theo trạng thái hiện tại
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

    // JS sắp xếp (giữ nguyên logic)
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
          location.reload(); // giữ thứ tự từ SQL
          return;
        }

        grid.innerHTML = '';
        cards.forEach(card => grid.appendChild(card));
      });
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
