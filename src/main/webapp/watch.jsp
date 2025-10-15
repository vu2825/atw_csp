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
    <link rel="stylesheet" href="<%= ctx %>/styles/watch.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
            <!-- ĐÃ XÓA NÚT ĐĂNG XUẤT -->
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
</body>
</html>