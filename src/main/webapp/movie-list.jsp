<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="bussines.Movie" %>
<%@ page import="bussines.User_login" %>
<%
    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
    String error = (String) request.getAttribute("error");
    String ctx = request.getContextPath();
    User_login user = (User_login) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Phim - HCMUTE</title>
    <link rel="stylesheet" href="<%= ctx %>/styles/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .page-title {
            font-size: 2.2rem;
            margin-bottom: 30px;
            color: var(--text);
            text-align: center;
            font-weight: 700;
        }

        .movies-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 30px;
            padding: 20px 0;
        }

        .movie-card {
            background: var(--card);
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s ease;
            cursor: pointer;
            border: 1px solid var(--border);
            box-shadow: 0 6px 20px rgba(0,0,0,0.1);
            height: fit-content;
        }

        .movie-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        }

        .movie-poster {
            width: 100%;
            height: 380px;
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, var(--border) 0%, var(--accent) 100%);
        }

        .movie-poster-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }

        .movie-card:hover .movie-poster-img {
            transform: scale(1.08);
        }

        .movie-poster-placeholder {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 3.5rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .movie-info {
            padding: 20px;
            min-height: 120px;
            display: flex;
            flex-direction: column;
        }

        .movie-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 15px;
            color: var(--text);
            line-height: 1.4;
            height: 3em;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }

        .movie-details {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-bottom: 15px;
        }

        .movie-detail-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--muted);
            font-size: 0.85rem;
        }

        .movie-detail-item i {
            color: var(--accent);
            width: 16px;
            text-align: center;
            font-size: 0.8rem;
        }

        .movie-director {
            color: var(--accent);
            font-weight: 500;
            font-size: 0.85rem;
        }

        .movie-meta {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: auto;
            padding-top: 15px;
            border-top: 1px solid var(--border);
        }

        .watch-btn {
            background: var(--accent);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 6px;
            width: 100%;
            justify-content: center;
        }

        .watch-btn:hover {
            background: color-mix(in srgb, var(--accent) 80%, black);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
        }

        .empty-state, .error-state {
            text-align: center;
            padding: 80px 20px;
            color: var(--muted);
        }

        .empty-state i, .error-state i {
            font-size: 4rem;
            margin-bottom: 20px;
            color: var(--border);
        }

        .empty-state h3, .error-state h3 {
            font-size: 1.5rem;
            margin-bottom: 10px;
            color: var(--text);
        }

        .error-state {
            color: var(--danger);
            background: color-mix(in srgb, var(--danger) 10%, transparent);
            border-radius: 12px;
            border: 1px solid color-mix(in srgb, var(--danger) 20%, transparent);
        }

        .empty-state a {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--accent);
            text-decoration: none;
            font-weight: 600;
            padding: 12px 24px;
            border: 2px solid var(--accent);
            border-radius: 8px;
            transition: all 0.3s ease;
            margin-top: 15px;
        }

        .empty-state a:hover {
            background: var(--accent);
            color: white;
            transform: translateY(-2px);
        }

        /* Grid layout improvements */
        .movies-grid {
            justify-items: center;
        }

        .movie-card {
            width: 100%;
            max-width: 320px;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .movies-grid {
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 25px;
            }
            
            .movie-poster {
                height: 350px;
            }
        }

        @media (max-width: 768px) {
            .movies-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 20px;
            }
            
            .movie-poster {
                height: 320px;
            }
            
            .page-title {
                font-size: 1.8rem;
            }
            
            .container {
                padding: 0 15px;
            }
        }

        @media (max-width: 480px) {
            .movies-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .movie-poster {
                height: 280px;
            }
            
            .movie-info {
                padding: 15px;
            }
            
            .movie-title {
                font-size: 1rem;
                height: 2.8em;
            }
            
            .movie-card {
                max-width: 100%;
            }
        }
    </style>
</head>
<body>
    <!-- HEADER - GIỐNG INDEX -->
    <header class="navbar">
        <div class="inner">
            <a class="brand" href="<%= ctx %>/HomeServlet?action=TrangChu">
                <img src="<%= ctx %>/images/Logo.png" alt="Logo" class="logo-img" />
                <span>HCMUTE</span>
            </a>

            <nav class="nav" aria-label="Chính">
                <a href="<%= ctx %>/HomeServlet?action=TrangChu">Trang chủ</a>
                <a href="<%= ctx %>/HomeServlet?action=TheLoai">Thể loại</a>
                <a href="<%= ctx %>/HomeServlet?action=ListPhim">List Phim</a>
            </nav>

            <div class="actions" aria-label="Tác vụ">
            <form id="search-form" action="${ctx}/SearchServlet" method="get" class="search-form" role="search">
          <input type="text" id="search-input" name="query" class="search-input" placeholder="Tìm phim..." autocomplete="off" />
          <button type="submit" class="search-btn"><i class="fa-solid fa-magnifying-glass"></i></button>
          <ul id="suggestions" class="suggestions-list"></ul>
        </form>

                <a class="action-link" href="<%= ctx %>/watchlist" aria-label="Watchlist">
                    <i class="fa-solid fa-bookmark"></i>
                </a>

                <a class="action-link" href="<%= ctx %>/HomeServlet?action=GioHang" aria-label="Giỏ hàng">
                    <i class="fa-solid fa-cart-shopping"></i>
                </a>
                <a class="action-link" href="<%= ctx %>/HomeServlet?action=TaiKhoan" aria-label="Tài khoản">
                    <i class="fa-solid fa-user"></i>
                </a>

                <i id="theme-toggle" class="fa-solid fa-sun" aria-label="Đổi giao diện sáng/tối"></i>
            </div>
        </div>
    </header>

    <main class="container">
        <h1 class="page-title">🎬 Danh Sách Phim</h1>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="error-state">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <h3>Đã xảy ra lỗi</h3>
                <p><%= error %></p>
                <small>Vui lòng kiểm tra console để biết chi tiết lỗi.</small>
            </div>
        <% } %>

        <% if (movies != null && !movies.isEmpty()) { %>
            <div class="movies-grid">
                <% for (Movie movie : movies) { %>
                    <div class="movie-card" onclick="location.href='<%= ctx %>/movie-detail?id=<%= movie.getId() %>'">
                        <div class="movie-poster">
                            <% if (movie.getPoster() != null && !movie.getPoster().isEmpty()) { %>
                                <img src="<%= movie.getPoster() %>" 
                                     alt="<%= movie.getTitle() %>" 
                                     class="movie-poster-img"
                                     onerror="this.style.display='none';">
                            <% } %>
                            <% if (movie.getPoster() == null || movie.getPoster().isEmpty()) { %>
                                <div class="movie-poster-placeholder">
                                    <i class="fa-solid fa-film"></i>
                                </div>
                            <% } %>
                        </div>
                        <div class="movie-info">
                            <div class="movie-title">
                                <%= movie.getTitle() != null ? movie.getTitle() : "Không có tiêu đề" %>
                            </div>
                            
                            <div class="movie-details">
                                <% if (movie.getGenre() != null && !movie.getGenre().isEmpty()) { %>
                                    <div class="movie-detail-item">
                                        <i class="fa-solid fa-user-tie"></i>
                                        <span class="movie-genre">Thể loại: <%= movie.getGenre() %></span>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="movie-meta">
                                <button class="watch-btn" onclick="event.stopPropagation(); location.href='<%= ctx %>/movie-detail?id=<%= movie.getId() %>'">
                                 Chi tiết
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <i class="fa-solid fa-film"></i>
                <h3>Không có phim nào</h3>
                <p>Hiện chưa có phim nào trong hệ thống hoặc không thể kết nối database.</p>
                <% if (user != null && user.isAdmin()) { %>
                    <a href="<%= ctx %>/admin/movie-controller">
                        <i class="fa-solid fa-plus"></i> Thêm phim mới
                    </a>
                <% } %>
            </div>
        <% } %>
    </main>

    <script>
        // Theme toggle script
        const toggle = document.getElementById("theme-toggle");
        const root = document.documentElement; 

        const saved = localStorage.getItem("theme");
        if (saved === "dark") {
            root.classList.add("dark");
        } else {
            root.classList.remove("dark"); 
        }

        const updateIcon = () => {
            const isDark = root.classList.contains("dark");
            toggle.classList.toggle("fa-sun", !isDark); 
            toggle.classList.toggle("fa-moon", isDark); 
        };
        updateIcon();

        toggle.addEventListener("click", () => {
            root.classList.toggle("dark");
            const isDark = root.classList.contains("dark");
            localStorage.setItem("theme", isDark ? "dark" : "light");
            updateIcon();
        });

        // Active state cho navigation
        document.addEventListener('DOMContentLoaded', function() {
            const currentPage = window.location.pathname;
            const navLinks = document.querySelectorAll('.nav a');
            
            navLinks.forEach(link => {
                if (link.href === window.location.href) {
                    link.classList.add('active');
                } else {
                    link.classList.remove('active');
                }
            });
        });

        // Đảm bảo tất cả card có cùng chiều cao
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.movie-card');
            let maxHeight = 0;
            
            // Reset height trước
            cards.forEach(card => {
                card.style.height = 'auto';
            });
            
            // Tìm chiều cao lớn nhất
            cards.forEach(card => {
                const height = card.offsetHeight;
                if (height > maxHeight) {
                    maxHeight = height;
                }
            });
            
            // Áp dụng chiều cao cho tất cả cards
            cards.forEach(card => {
                card.style.height = maxHeight + 'px';
            });
        });
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