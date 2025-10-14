<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="bussines.User_login" %>
<%
    User_login user = (User_login) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Xem: ${movie.title} - ${selectedQuality}P</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            background-color: #141414;
            color: white;
            text-align: center;
            margin: 0;
        }

        .header {
            padding: 1rem 2rem;
            text-align: right;
            background-color: #181818;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .video-info {
            text-align: left;
        }

        .movie-title {
            font-size: 1.5rem;
            margin: 0;
        }

        .quality-badge {
            background: #e50914;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            margin-left: 10px;
        }

        .video-container {
            position: relative;
            width: 80%;
            max-width: 960px;
            margin: 2rem auto;
            display: inline-block;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            background-color: #000;
        }

        #movie-frame {
            width: 100%;
            height: 500px;
            border: none;
            display: block;
        }

        .btn {
            display: inline-block;
            padding: 0.8rem 1.5rem;
            background-color: #e50914;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            margin: 10px;
        }

        .control-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 960px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .back-btn {
            background: #333;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 5px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .back-btn:hover {
            background: #444;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
            color: white;
        }

        .premium-badge {
            color: gold;
            margin-left: 5px;
        }
    </style>
</head>
<body>

    <div class="header">
        <div class="video-info">
            <h1 class="movie-title">${movie.title} 
                <span class="quality-badge">${selectedQuality}P</span>
            </h1>
        </div>
        <div class="user-info">
            <span>Xin chào, <strong>${user.username}</strong>
                <c:if test="${user.premium}">
                    <span class="premium-badge">⭐ Premium</span>
                </c:if>
            </span>
            <a href="<%= ctx %>/auth/logout" class="btn">
                Đăng xuất
            </a>
        </div>
    </div>

    <div class="control-bar">
        <a href="movie-detail?id=${movie.id}" class="back-btn">
            <i class="fa-solid fa-arrow-left"></i>
            Quay lại chi tiết
        </a>
        <a href="movies" class="back-btn">
            <i class="fa-solid fa-list"></i>
            Danh sách phim
        </a>
    </div>
    
    <div class="video-container">
        <iframe id="movie-frame" src="${movie.src}" 
                allow="autoplay; encrypted-media" 
                allowfullscreen>
        </iframe>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🎬 Video player ready');
            console.log('📺 Chất lượng: ${selectedQuality}P');
            console.log('🎞️ Phim: ${movie.title}');
            
            const frame = document.getElementById('movie-frame');
            
            frame.addEventListener('load', function() {
                console.log('✅ Video loaded successfully');
            });
        });

        document.addEventListener('keydown', function(e) {
            switch(e.key) {
                case 'Escape':
                    window.location.href = 'movie-detail?id=${movie.id}';
                    break;
                case ' ':
                    e.preventDefault();
                    break;
            }
        });
    </script>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</body>
</html>