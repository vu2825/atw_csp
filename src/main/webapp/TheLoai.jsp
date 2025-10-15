<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thể loại phim</title>
    <link rel="stylesheet" href="styles/style.css">
    <link rel="stylesheet" href="styles/movie_card.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}" />


<header class="navbar">
    <div class="inner">
        <a class="brand" href="${ctx}/HomeServlet?action=TrangChu">
            <img src="${ctx}/images/Logo.png" alt="Logo" class="logo-img" />
            <span>HCMUTE</span>
        </a>

        <nav class="nav">
            <a href="${ctx}/HomeServlet?action=TrangChu">Trang chủ</a>
            <a href="${ctx}/HomeServlet?action=TheLoai">Thể loại</a>
            <a href="${ctx}/HomeServlet?action=ListPhim">List Phim</a>
        </nav>

        <div class="actions" aria-label="Tác vụ">
             <form id="search-form" action="${pageContext.request.contextPath}/SearchServlet" method="get" class="search-form" role="search">
             <input type="text" id="search-input" name="query" class="search-input" placeholder="Tìm phim..." autocomplete="off" />
             <button type="submit" class="search-btn"><i class="fa-solid fa-magnifying-glass"></i></button>
             <ul id="suggestions" class="suggestions-list"></ul>
             </form>

            <a class="action-link" href="${ctx}/watchlist" aria-label="Watchlist">
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


<section class="genre-filter">
    <form method="get" action="${ctx}/TheLoaiServlet">
        <label>Chọn thể loại:</label>
        <select name="genre" onchange="this.form.submit()">
            <option value="">-- Tất cả --</option>
            <c:forEach var="g" items="${genres}">
                <option value="${g}" ${selectedGenre == g ? 'selected' : ''}>${g}</option>
            </c:forEach>
        </select>
    </form>
</section>


<section class="movie-list">
    <c:if test="${empty videos}">
        <p style="text-align:center; color:#ccc;">Không có phim nào được tìm thấy.</p>
    </c:if>

    <div class="movie-grid">
        <c:forEach var="v" items="${videos}">
            <div class="movie-card">
                <img src="${v.posterUrl}" alt="${v.title}" class="movie-img">
                <div class="movie-card-content">
                    <h3>${v.title}</h3>
                    <p>${v.genre}</p>
                    <a href="${ctx}/movie-detail?id=${v.id}" class="btn">Xem ngay</a>
                </div>
            </div>
        </c:forEach>
    </div>
</section>
        
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
