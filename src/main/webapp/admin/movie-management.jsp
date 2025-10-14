<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="bussines.Movie" %>
<%
    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
    String ctx = request.getContextPath();
%>

<html>
<head>
    <title>Quản lý Phim</title>
    <style>
        body {
            font-family: 'Poppins', 'Roboto', 'Open Sans', sans-serif;
            background-color: #000;
            color: #fff;
            margin: 0;
            padding: 24px;
            position: relative;
        }

        h2 {
            color: #E50914;
            text-align: center;
            margin: 0 0 24px 0;
            font-weight: 600;
            letter-spacing: 0.3px;
        }

        .header-spacer { height: 36px; }

        .content-wrap {
            max-width: 1300px;
            margin: 0 auto;
        }

        /* Success message */
        .success-message {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 16px;
            text-align: center;
            font-weight: 600;
        }

        /* Filter form */
        .filter-form {
            background:#111;
            border:1px solid #222;
            border-radius:10px;
            padding:12px 14px;
            margin:0 0 16px 0;
            display:flex;
            flex-wrap:wrap;
            gap:10px;
            align-items:center;
            justify-content:space-between;
        }
        .filter-left, .filter-right {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
        }
        .filter-form select, .filter-form input[type="text"] {
            background:#141414;
            color:#e6e6e6;
            border:1px solid #222;
            padding:6px 8px;
            border-radius:6px;
        }
        .filter-form button, .filter-form a.reset-btn {
            background:#E50914;
            color:#fff;
            border:none;
            border-radius:6px;
            padding:8px 12px;
            cursor:pointer;
            text-decoration:none;
            font-size: 14px;
        }
        .filter-form a.reset-btn {
            background:#333;
        }

        /* Action buttons */
        .action-buttons {
            display: flex;
            gap: 10px;
            margin-bottom: 16px;
        }
        .action-btn {
            background: #E50914;
            color: #fff;
            padding: 10px 16px;
            text-decoration: none;
            border-radius: 6px;
            font-size: 14px;
            transition: 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .action-btn:hover {
            background: #ff1a23;
            transform: translateY(-1px);
        }
        .action-btn.secondary {
            background: #333;
        }
        .action-btn.secondary:hover {
            background: #444;
        }

        /* Table */
        .table-wrap {
            background-color: #111;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 0 10px rgba(255, 255, 255, 0.05);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: #111;
        }
        thead th {
            background: #141414;
            color: #ddd;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.6px;
            padding: 12px 14px;
            border-bottom: 1px solid #222;
        }
        tbody td {
            padding: 12px 14px;
            border-bottom: 1px solid #1f1f1f;
            color: #e6e6e6;
            vertical-align: middle;
        }
        tbody tr:nth-child(even) { background-color: #101010; }
        tbody tr:hover { background-color: #171717; }

        /* Column alignments */
        .col-id      { width: 80px;  text-align: center; }
        .col-title   { width: 35%; text-align: left; }
        .col-director { width: 30%; text-align: left; }
        .col-duration { width: 120px; text-align: center; }
        .col-quality { width: 100px; text-align: center; }
        .col-action  { width: 150px; text-align: center; }

        .truncate {
            max-width: 100%;
            display: inline-block;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            vertical-align: bottom;
        }

        .tag {
            display: inline-block;
            min-width: 60px;
            text-align: center;
            padding: 4px 8px;
            border-radius: 16px;
            font-size: 12px;
            font-weight: 600;
        }
        .tag-both { background-color: #7c2d12; color: #fed7aa; }

        .btn {
            padding: 6px 12px;
            text-decoration: none;
            border-radius: 6px;
            font-size: 12px;
            transition: 0.3s;
            display: inline-block;
            margin: 2px;
        }
        .btn-delete {
            background: #E50914;
            color: #fff;
        }
        .btn-delete:hover {
            background: #ff1a23;
        }
        .btn-view {
            background: #10b981;
            color: #fff;
        }
        .btn-view:hover {
            background: #059669;
        }

        .btn-back {
            position: fixed;
            top: 16px;
            left: 16px;
            background-color: #333;
            color: #fff;
            border: none;
            padding: 6px 12px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            transition: 0.3s;
            box-shadow: 0 0 6px rgba(0, 0, 0, 0.5);
            text-decoration: none;
        }
        .btn-back:hover {
            background-color: #E50914;
            transform: scale(1.05);
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #aaa;
        }
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 16px;
            color: #333;
        }     
    </style>
</head>
<body>

<a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-back">⬅ Quay lại</a>
<div class="header-spacer"></div>

<div class="content-wrap">
    <h2>🎬 Quản lý Phim</h2>

    <!-- Success Message -->
    <c:if test="${not empty successMessage}">
        <div class="success-message">
            ${successMessage}
        </div>
    </c:if>

    <!-- Action Buttons -->
    <div class="action-buttons">
        <a href="<%= ctx %>/admin/movie-controller" class="action-btn">
            <i class="fa-solid fa-plus"></i> Thêm phim mới
        </a>
    </div>

    <!-- FORM FILTER -->
    <form method="get" action="${pageContext.request.contextPath}/admin/movie-controller" class="filter-form">
        <!-- QUAN TRỌNG: Thêm hidden field này -->
        <input type="hidden" name="action" value="manage">
        
        <div class="filter-left">
            <div>
                <label style="font-size:13px;color:#ccc;margin:0 6px 0 0px;">Sắp xếp:</label>
                <select name="sort">
                    <option value="" ${empty param.sort ? 'selected' : ''}>Mới nhất</option>
                    <option value="oldest" ${param.sort == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                    <option value="title_asc" ${param.sort == 'title_asc' ? 'selected' : ''}>A-Z</option>
                    <option value="title_desc" ${param.sort == 'title_desc' ? 'selected' : ''}>Z-A</option>
                </select>
            </div>

            <div>
                <input type="text" name="q" placeholder="Tìm theo tên phim, đạo diễn..."
                       value="${fn:escapeXml(param.q)}"
                       style="min-width:250px;"/>
            </div>

            <button type="submit">Lọc</button>
            <!-- QUAN TRỌNG: Reset link phải có action=manage -->
            <a href="${pageContext.request.contextPath}/admin/movie-controller?action=manage" class="reset-btn">Reset</a>
        </div>

        <div class="filter-right" style="font-size:13px;color:#aaa;">
            Tổng: <strong>${fn:length(movies)}</strong> phim
        </div>
    </form>

    <!-- TABLE -->
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th class="col-id">ID</th>
                <th class="col-title">Tên phim</th>
                <th class="col-director">Đạo diễn</th>
                <th class="col-duration">Thời lượng</th>
                <th class="col-quality">Chất lượng</th>
                <th class="col-action">Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty movies}">
                    <tr>
                        <td colspan="6" class="empty-state">
                            <i class="fa-solid fa-film"></i>
                            <div>Không có phim nào trong hệ thống.</div>
                            <a href="<%= ctx %>/admin/movie-controller" class="action-btn" style="margin-top: 12px;">
                                <i class="fa-solid fa-plus"></i> Thêm phim đầu tiên
                            </a>
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="movie" items="${movies}">
                        <tr>
                            <td class="col-id">${movie.id}</td>
                            <td class="col-title">
                                <span class="truncate" title="${movie.title}">${movie.title}</span>
                            </td>
                            <td class="col-director">
                                <span class="truncate" title="${movie.genre}">${movie.genre}</span>
                            </td>
                            <td class="col-duration">
                                <c:choose>
                                    <c:when test="${not empty movie.duration}">
                                        ${movie.duration}
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: #666;">--:--</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="col-quality">
                                <span class="tag tag-both">360P/480P</span>
                            </td>
                            <td class="col-action">
                                <a href="<%= ctx %>/movie-detail?id=${movie.id}" class="btn btn-view" target="_blank">
                                    <i class="fa-solid fa-eye"></i> Xem
                                </a>
                                <!-- ĐÃ BỎ NÚT SỬA -->
                                <a href="<%= ctx %>/admin/movie-controller?action=delete&id=${movie.id}" 
                                   class="btn btn-delete"
                                   onclick="return confirm('Bạn có chắc chắn muốn xoá phim \"${movie.title}\"?');">
                                    <i class="fa-solid fa-trash"></i> Xoá
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</div>

<!-- Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</body>
</html>