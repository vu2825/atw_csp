<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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

        /* Ensure user comments preserve newlines and wrap long words */
        .comment .content,
        .content {
            white-space: pre-wrap; /* preserve newlines and sequences of spaces */
            word-break: break-word; /* wrap long words/URLs */
        }

    /* Stars for ratings/comments */
        .fa-star {
            color: rgba(255,255,255,0.22); /* default muted star */
            transition: color 150ms ease, transform 120ms ease;
            display: inline-block;
            vertical-align: middle;
        }

        /* 'on' class is applied server-side for filled stars */
        .fa-star.on {
            color: #f5c518; /* warm gold/yellow (Netflix-like) */
            text-shadow: 0 1px 0 rgba(0,0,0,0.4);
        }

        /* Slight pop on hover for interactive contexts (e.g., rating form) */
        label:hover .fa-star,
        .fa-star:hover {
            transform: translateY(-2px) scale(1.06);
            color: #ffd65a;
        }

        /* Improve contrast for 'off' stars when near text */
        .fa-star.off {
            color: rgba(255,255,255,0.18);
        }

        /* Rating distribution bars */
        .bar { overflow: hidden; border-radius: 999px; background: rgba(255,255,255,.12); }
        .bar .bar-fill {
            height: 100%;
            background: linear-gradient(90deg,#f5c518,#ffd65a);
            width: calc(var(--pct) * 1%);
            transition: width 260ms ease;
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

<section id="review-form" style="margin:24px auto;max-width:960px;text-align:left">
    <h3>Đánh giá & Bình luận</h3>

    <c:if test="${empty user}">
        <div style="padding:12px;border:1px solid #444;border-radius:8px">
            Bạn cần <a href="<%= ctx %>/auth/login" style="color:#f33">đăng nhập</a> để bình luận.
        </div>
    </c:if>

    <c:if test="${not empty user}">
        <form method="post" action="<%= ctx %>/review" style="display:grid;gap:12px">
            <!-- Ẩn thông tin phim -->
            <input type="hidden" name="videoId" value="${movie.id}" />
            <!-- redirect back to watch page so user stays on the player after posting -->
            <input type="hidden" name="redirect" value="watch?id=${movie.id}" />

            <label>Chấm sao (1–5):</label>
            <div>
                <c:forEach var="i" begin="1" end="5">
                    <label style="margin-right:8px">
                        <input type="radio" name="rating" value="${i}" required> ${i}★
                    </label>
                </c:forEach>
            </div>

            <label>Nội dung bình luận:</label>
            <textarea name="comment" rows="4" maxlength="1000"
                      placeholder="Viết cảm nhận của bạn..." required
                      style="width:100%;padding:10px;border-radius:8px;border:1px solid #333;background:#111;color:#fff"></textarea>

            <button type="submit" class="btn">Gửi đánh giá</button>
        </form>
    </c:if>
</section>

<!-- BEGIN: Viewer Rating & Comments (same as movie-detail.jsp) -->
<section id="rating" class="rating-summary" style="margin:24px auto;max-width:960px;text-align:left">
    <c:if test="${not empty rating}">
        <div style="display:grid;grid-template-columns:220px 1fr;gap:16px;align-items:center">
            <div class="avg-box" style="text-align:center">
                <div class="avg-score" style="font-size:48px;font-weight:700;line-height:1">
                    <fmt:formatNumber value="${rating.avg}" type="number" maxFractionDigits="1"/>
                </div>
                <div class="avg-stars" style="margin:6px 0">
                    <c:forEach var="i" begin="1" end="5">
                        <i class="fa-solid fa-star ${i <= rating.avg ? 'on' : 'off'}"></i>
                    </c:forEach>
                </div>
                <div class="vote-count" style="font-size:14px;opacity:.8">
                    <c:out value="${rating.count}"/> lượt đánh giá
                </div>
            </div>
        </div>
    </c:if>
</section>

<section id="comments" class="comments" style="margin:0 auto 24px;max-width:960px;text-align:left">
    <h3>Bình luận của người xem</h3>
    <c:choose>
        <c:when test="${empty comments}">
            <div class="empty" style="opacity:.7;padding:12px 0">Chưa có bình luận nào cho phim này.</div>
        </c:when>
        <c:otherwise>
            <c:forEach var="cmt" items="${comments}">
                <article class="comment" style="display:grid;grid-template-columns:48px 1fr;gap:12px;padding:12px 0;border-bottom:1px solid rgba(255,255,255,.08)">
                    <div class="avatar" style="width:48px;height:48px;border-radius:50%;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,.08);font-weight:700">
                <span>
                  <c:choose>
                      <c:when test="${not empty cmt.username}"><c:out value="${fn:toUpperCase(fn:substring(cmt.username,0,1))}"/></c:when>
                      <c:otherwise>G</c:otherwise>
                  </c:choose>
                </span>
                    </div>
                    <div class="body">
                        <div class="meta" style="display:flex;gap:8px;align-items:center;font-size:14px;opacity:.9">
                <strong class="user"><c:out value="${cmt.username}"/></strong>
                            <span class="stars">
            <c:forEach var="i" begin="1" end="5">
            <i class="fa-solid fa-star ${i <= cmt.rating ? 'on' : 'off'}"></i>
            </c:forEach>
                  </span>
                <span class="time">•
            <fmt:formatDate value="${cmt.created_at}" pattern="dd/MM/yyyy HH:mm"/>
          </span>
                        </div>
                        <p class="content" style="white-space:pre-wrap;margin-top:6px"><c:out value="${cmt.comment}"/></p>
                    </div>
                </article>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</section>
<!-- END: Viewer Rating & Comments -->



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
        // If user is typing in an input/textarea or contentEditable, don't hijack the space key
        const active = document.activeElement;
        const typingElements = ['INPUT', 'TEXTAREA'];
        if (active && (typingElements.includes(active.tagName) || active.isContentEditable)) {
            return; // allow normal typing behavior
        }

        switch (e.key) {
            case 'Escape':
                window.location.href = 'movie-detail?id=${movie.id}';
                break;
            case ' ':
                // prevent scrolling / unintended behavior when not typing
                e.preventDefault();
                break;
        }
    });
</script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</body>
</html>