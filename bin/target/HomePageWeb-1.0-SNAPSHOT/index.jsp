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
<header class="navbar">
    <div class="logo">
        <img src="images/Logo.png" alt="Logo" class="logo-img">
    </div>

    <nav>
        <a href="HomeServlet?action=TrangChu">Trang chủ</a>
        <a href="HomeServlet?action=TheLoai">Thể loại</a>
        <a href="HomeServlet?action=PhimBo">Phim bộ</a>
        <a href="HomeServlet?action=PhimLe">Phim lẻ</a>
        <a href="HomeServlet?action=QuocGia">Quốc gia</a>
    </nav>

    <div class="nav-icons">
        <i id="search-icon" class="fa-solid fa-magnifying-glass"></i>
        <i class="fa-solid fa-bell"></i>
        <i class="fa-solid fa-bookmark"></i>
        <a href="HomeServlet?action=GioHang">
            <i class="fa-solid fa-cart-shopping"></i>
        </a>
        <a href="HomeServlet?action=TaiKhoan">
            <i class="fa-solid fa-user"></i>
        </a>
        <i id="theme-toggle" class="fa-solid fa-sun"></i>
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
    </div>
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
