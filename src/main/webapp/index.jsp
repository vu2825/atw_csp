<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xem Phim Online</title>
    <link rel="stylesheet" href="styles/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
        <a href="${ctx}/HomeServlet?action=PhimBo">Phim bộ</a>
        <a href="${ctx}/HomeServlet?action=PhimLe">Phim lẻ</a>
        <a href="${ctx}/HomeServlet?action=QuocGia">Quốc gia</a>
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
        <a class="action-link" href="${ctx}/HomeServlet?action=watchlist" aria-label="Watchlist">
  			<i class="fa-solid fa-bookmark"></i>
		</a>

        <a class="action-link" href="${ctx}/Subscription.jsp" aria-label="Giỏ hàng">
          <i class="fa-solid fa-cart-shopping"></i>
        </a>
        <a class="action-link" href="${ctx}/HomeServlet?action=TaiKhoan" aria-label="Tài khoản">
          <i class="fa-solid fa-user"></i>
        </a>

        <i id="theme-toggle" class="fa-solid fa-sun" aria-label="Đổi giao diện sáng/tối"></i>
      </div>
    </div>
  </header>

<section class="feature">
    <div class="feature-content">
        <h1>${featuredMovie.title}</h1>
        <p>${featuredMovie.description}</p>
        <div class="feature-buttons">
            <a href="${featuredMovie.watchLink}" class="btn watch">▶ Watch Movie</a>
            <a href="${featuredMovie.infoLink}" class="btn info">More Info →</a>
        </div>
    </div>
    <img src="${featuredMovie.image}" alt="${featuredMovie.title}" class="feature-bg">
</section>

<!-- PHIM BỘ -->
<section class="movie-section">
    <h2>Phim Bộ</h2>
    <div class="movie-row">
        <c:forEach var="movie" items="${seriesMovies}">
            <div class="movie-card">
                <img src="${movie.image}" alt="${movie.title}">
                <a href="${movie.link}" class="add">+</a>
            </div>
        </c:forEach>
<!--        <div class="movie-card">
                <img src="${ctx}/images/Meo.jpg" alt="${movie.title}">
                <a href="${movie.link}" class="add"><i class="fa-solid fa-bookmark"></i></a>
            </div>
    </div>-->
</section>

<!-- PHIM LẺ -->
<section class="movie-section">
    <h2>Phim Lẻ</h2>
    <div class="movie-row">
        <c:forEach var="movie" items="${singleMovies}">
            <div class="movie-card">
                <img src="${movie.image}" alt="${movie.title}">
                <a href="${movie.link}" class="add">+</a>
            </div>
        </c:forEach>
    </div>
</section>

<!-- QUỐC GIA -->
<section class="movie-section">
    <h2>Quốc gia</h2>
    <div class="movie-row">
        <c:forEach var="movie" items="${countryMovies}">
            <div class="movie-card">
                <img src="${movie.image}" alt="${movie.title}">
                <a href="${movie.link}" class="add">+</a>
            </div>
        </c:forEach>
    </div>
</section>

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
