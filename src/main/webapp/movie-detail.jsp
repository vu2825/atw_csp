<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="bussines.Movie" %>
<%@ page import="bussines.User_login" %>
<%
    Movie movie = (Movie) request.getAttribute("movie");
    String movieId = request.getParameter("id");
    String ctx = request.getContextPath();
    User_login user = (User_login) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= movie != null ? movie.getTitle() : "Không tìm thấy phim" %> - HCMUTE</title>
    <link rel="stylesheet" href="<%= ctx %>/styles/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .movie-detail {
            display: flex;
            gap: 40px;
            align-items: flex-start;
        }

        .movie-poster {
            flex: 0 0 300px;
        }

        .movie-poster-img {
            width: 100%;
            height: 450px;
            object-fit: cover;
            border-radius: 12px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .movie-poster-placeholder {
            width: 100%;
            height: 450px;
            background: var(--border);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--muted);
            font-size: 4rem;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .movie-info {
            flex: 1;
        }

        .movie-title {
            font-size: 2.5rem;
            margin-bottom: 25px;
            color: var(--text);
            font-weight: 800;
            line-height: 1.2;
        }

        .movie-description {
            margin-bottom: 30px;
            line-height: 1.7;
            color: var(--text);
            background: var(--card);
            padding: 25px;
            border-radius: 12px;
            border: 1px solid var(--border);
        }

        .movie-description p {
            margin-bottom: 15px;
        }

        .movie-description strong {
            color: var(--accent);
        }

        .quality-selector {
            margin-bottom: 35px;
        }

        .quality-title {
            font-size: 1.3rem;
            margin-bottom: 20px;
            color: var(--text);
            font-weight: 700;
        }

        .quality-options {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }

        .quality-option {
            padding: 15px 25px;
            border: 2px solid var(--border);
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            background: var(--card);
            min-width: 140px;
        }

        .quality-option:hover {
            border-color: var(--accent);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(37, 99, 235, 0.1);
        }

        .quality-option.selected {
            border-color: var(--accent);
            background: var(--accent);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(37, 99, 235, 0.2);
        }

        .quality-name {
            font-weight: bold;
            font-size: 1.1rem;
            margin-bottom: 5px;
        }

        .quality-desc {
            font-size: 0.85rem;
            opacity: 0.8;
        }

        .watch-button {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            padding: 18px 45px;
            background: var(--accent);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-size: 1.3rem;
            font-weight: 700;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.3);
        }

        .watch-button:hover {
            background: color-mix(in srgb, var(--accent) 85%, black);
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(37, 99, 235, 0.4);
        }

        .back-button {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 24px;
            background: var(--card);
            color: var(--text);
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 25px;
            transition: all 0.3s ease;
            border: 1px solid var(--border);
            font-weight: 600;
        }

        .back-button:hover {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
            transform: translateY(-2px);
        }

        .error-state {
            text-align: center;
            padding: 80px 40px;
            color: var(--danger);
            background: color-mix(in srgb, var(--danger) 10%, transparent);
            border-radius: 16px;
            margin: 30px 0;
            border: 1px solid color-mix(in srgb, var(--danger) 20%, transparent);
        }

        .error-state i {
            font-size: 4rem;
            margin-bottom: 20px;
            color: var(--danger);
        }

        .error-state h3 {
            font-size: 1.8rem;
            margin-bottom: 15px;
            color: var(--danger);
        }

        .error-state p {
            margin-bottom: 25px;
            font-size: 1.1rem;
        }

        /* Premium warning */
        .premium-warning {
            background: linear-gradient(135deg, #ffd700, #ffed4e);
            color: #000;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #ff6b00;
            font-weight: 600;
        }

        /* Additional movie info sections */
        .movie-additional-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
            padding-top: 30px;
            border-top: 1px solid var(--border);
        }

        .info-item {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .info-label {
            font-size: 0.9rem;
            color: var(--muted);
            font-weight: 600;
        }

        .info-value {
            font-size: 1.1rem;
            color: var(--text);
            font-weight: 500;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .movie-detail {
                flex-direction: column;
                gap: 30px;
            }
            
            .movie-poster {
                flex: none;
                width: 100%;
                max-width: 400px;
                margin: 0 auto;
            }
            
            .movie-poster-img, .movie-poster-placeholder {
                height: 350px;
            }
            
            .movie-title {
                font-size: 2rem;
                text-align: center;
            }
            
            .quality-options {
                justify-content: center;
            }
            
            .watch-button {
                width: 100%;
                justify-content: center;
            }
        }

        @media (max-width: 480px) {
            .movie-title {
                font-size: 1.7rem;
            }
            
            .movie-poster-img, .movie-poster-placeholder {
                height: 280px;
                font-size: 3rem;
            }
            
            .quality-option {
                min-width: 120px;
                padding: 12px 20px;
            }
            
            .watch-button {
                padding: 15px 30px;
                font-size: 1.2rem;
            }
            
            .container {
                padding: 0 15px;
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
                <a href="${ctx}/TheLoaiServlet">Thể loại</a>
                <a href="${ctx}/HomeServlet?action=PhimBo">List Phim</a>
            </nav>

            <div class="actions" aria-label="Tác vụ">
             <form id="search-form" action="${pageContext.request.contextPath}/SearchServlet" method="get" class="search-form" role="search">
             <input type="text" id="search-input" name="query" class="search-input" placeholder="Tìm phim..." autocomplete="off" />
             <button type="submit" class="search-btn"><i class="fa-solid fa-magnifying-glass"></i></button>
             <ul id="suggestions" class="suggestions-list"></ul>
             </form>

                <i class="fa-solid fa-bell" aria-label="Thông báo"></i>
                <a class="action-link" href="<%= ctx %>/WatchlistServlet" aria-label="Watchlist">
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
        <a href="<%= ctx %>/movies" class="back-button">
            <i class="fa-solid fa-arrow-left"></i>
            Quay lại danh sách
        </a>

        <% if (movie != null) { %>
            <div class="movie-detail">
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
                    <h1 class="movie-title"><%= movie.getTitle() %></h1>

                    <div class="movie-description">
                        <p>Khám phá bộ phim đặc sắc <strong>"<%= movie.getTitle() %>"</strong> với chất lượng hình ảnh sắc nét và âm thanh sống động.</p>
                        
                        <% if (movie.getGenre() != null && !movie.getGenre().isEmpty()) { %>
                            <p><strong>🎬 Đạo diễn:</strong> <%= movie.getGenre() %></p>
                        <% } %>
                        
                        <% if (movie.getDuration() != null && !movie.getDuration().isEmpty()) { %>
                            <p><strong>⏱️ Thời lượng:</strong> <%= movie.getDuration() %></p>
                        <% } else { %>
                            <p><strong>⏱️ Thời lượng:</strong> Đang cập nhật</p>
                        <% } %>
                    </div>

                    <!-- Premium Warning -->
                    <% if (user != null && !user.isPremium()) { %>
                        <div class="premium-warning">
                            ⭐ Nâng cấp tài khoản Premium để xem phim chất lượng cao 480P!
                        </div>
                    <% } %>

                    <!-- Chọn chất lượng -->
                    <div class="quality-selector">
                        <div class="quality-title">🎥 Chọn chất lượng xem phim:</div>
                        <div class="quality-options">
                            <div class="quality-option selected" data-quality="360">
                                <div class="quality-name">HD 360P</div>
                                <div class="quality-desc">Chất lượng tiêu chuẩn</div>
                            </div>
                            <div class="quality-option <%= (user != null && user.isPremium()) ? "" : "disabled" %>" 
                                 data-quality="480"
                                 <% if (user != null && !user.isPremium()) { %> 
                                 title="Cần tài khoản Premium để xem chất lượng 480P"
                                 <% } %>>
                                <div class="quality-name">HD 480P</div>
                                <div class="quality-desc">
                                    <% if (user != null && user.isPremium()) { %>
                                        Chất lượng cao
                                    <% } else { %>
                                        🔒 Cần Premium
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Nút xem phim -->
                    <button id="watch-button" class="watch-button" onclick="watchMovie()">
                        <i class="fa-solid fa-play"></i> Xem Phim Ngay
                    </button>
                </div>
            </div>
        <% } else { %>
            <div class="error-state">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <h3>Không tìm thấy phim</h3>
                <p>Phim với ID=<%= movieId %> không tồn tại trong hệ thống.</p>
                <a href="<%= ctx %>/movies" class="back-button">
                    <i class="fa-solid fa-arrow-left"></i>
                    Quay lại danh sách
                </a>
            </div>
        <% } %>
    </main>

    <script>
        let selectedQuality = '360';

        document.querySelectorAll('.quality-option:not(.disabled)').forEach(option => {
            option.addEventListener('click', function() {
                if (this.classList.contains('disabled')) {
                    alert('🔒 Cần nâng cấp tài khoản Premium để xem chất lượng 480P!');
                    return;
                }
                
                document.querySelectorAll('.quality-option').forEach(opt => {
                    opt.classList.remove('selected');
                });
                this.classList.add('selected');
                selectedQuality = this.dataset.quality;
            });
        });

        function watchMovie() {
            const movieId = <%= movie != null ? movie.getId() : "null" %>;
            if (movieId) {
                // Kiểm tra nếu chọn 480P nhưng không phải premium
                if (selectedQuality === '480' && <%= user != null ? !user.isPremium() : "true" %>) {
                    alert('🔒 Cần nâng cấp tài khoản Premium để xem chất lượng 480P!');
                    return;
                }
                
                window.location.href = '<%= ctx %>/watch?id=' + movieId + '&quality=' + selectedQuality;
            } else {
                alert('Lỗi: Không tìm thấy ID phim');
            }
        }

        document.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                watchMovie();
            }
        });

        // Theme toggle
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

        // Active navigation
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