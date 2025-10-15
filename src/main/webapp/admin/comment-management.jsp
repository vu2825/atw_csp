<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <title>Quản lý Bình luận</title>
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
            table-layout: fixed;
        }

        thead th {
            background: #141414;
            color: #ddd;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.6px;
            padding: 14px 10px;
            border-bottom: 1px solid #222;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            text-align: left;
        }

        tbody td {
            padding: 10px;
            border-bottom: 1px solid #1f1f1f;
            color: #e6e6e6;
            vertical-align: top;
            overflow-wrap: break-word;
            word-break: break-word;
            text-align: left;
        }

        tbody tr:nth-child(even) { background-color: #101010; }
        tbody tr:hover { background-color: #171717; }

        /* Nút xóa */
        .delete-btn {
            background: #E50914;
            color: #fff;
            padding: 6px 10px;
            text-decoration: none;
            border-radius: 6px;
            font-size: 12px;
            transition: 0.3s;
            display: inline-block;
            border: none;
        }
        .delete-btn:hover { background: #ff1a23; transform: translateY(-1px); }

        /* Nút xem */
        .view-btn {
            background: #1e90ff;
            color: #fff;
            padding: 6px 10px;
            text-decoration: none;
            border-radius: 6px;
            font-size: 12px;
            transition: 0.3s;
            display: inline-block;
        }
        .view-btn:hover {
            background: #3aa0ff;
            transform: translateY(-1px);
        }

        /* Sao */
        .star { color: #555; }
        .star.active { color: #f39c12; }

        /* Small Back Button */
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
            width: auto;
            display: inline-block;
            text-decoration: none;
        }
        .btn-back:hover { background-color: #E50914; transform: scale(1.05); }

        /* Set kích thước cột + canh lề chuẩn trong bảng */
        th.col-id,    td.col-id    { width: 60px;  text-align: center; }
        th.col-user,  td.col-user  { width: 140px; text-align: left;   }
        th.col-video, td.col-video { width: 120px; text-align: center; }
        th.col-rating,td.col-rating{ width: 120px; text-align: center; }
        th.col-comment,td.col-comment { width: auto; text-align: left; }
        th.col-date,  td.col-date  { width: 160px; text-align: center; white-space: nowrap; }
        th.col-actions,td.col-actions{ width: 100px; text-align: center; }
    </style>
</head>
<body>

<a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-back">⬅ Quay lại</a>
<div class="header-spacer"></div>

<div class="content-wrap">
    <h2>Quản lý bình luận & đánh giá</h2>

    <!-- SORT đơn giản -->
    <form method="get" action="${pageContext.request.contextPath}/admin/comment-controller" style="margin:0 0 12px 0;">
        <label style="font-size:13px;color:#ccc;margin-right:6px;">Sắp xếp:</label>
        <select name="sort" onchange="this.form.submit()" style="background:#141414;color:#e6e6e6;border:1px solid #222;padding:6px 8px;border-radius:6px;">
            <option value="" <c:if test="${empty sort}">selected</c:if>>Mới nhất</option>
            <option value="rating_desc" <c:if test="${sort == 'rating_desc'}">selected</c:if>>Rating ↓ (Cao → Thấp)</option>
            <option value="rating_asc"  <c:if test="${sort == 'rating_asc'}">selected</c:if>>Rating ↑ (Thấp → Cao)</option>
        </select>
        <noscript>
            <button type="submit" style="background:#E50914;color:#fff;border:none;border-radius:6px;padding:6px 10px;margin-left:6px;cursor:pointer;">Apply</button>
        </noscript>
    </form>

    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th class="col-id">ID</th>
                <th class="col-user">User ID</th>
                <th class="col-video">Video</th>
                <th class="col-rating">Rating</th>
                <th class="col-comment">Comment</th>
                <th class="col-date">Created At</th>
                <th class="col-actions">Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="comment" items="${commentList}">
                <tr>
                    <td class="col-id">${comment.id}</td>
                    <td class="col-user">${comment.userId}</td>
                    <td class="col-video">
                        <a href="${pageContext.request.contextPath}/movie-detail?id=${comment.videoId}" class="view-btn">
                            Xem
                        </a>
                    </td>
                    <td class="col-rating">
                        <c:forEach begin="1" end="5" var="i">
                            <span class="star ${i <= comment.rating ? 'active' : ''}">★</span>
                        </c:forEach>
                    </td>
                    <td class="col-comment">${comment.comment}</td>
                    <td class="col-date">
                        <fmt:formatDate value="${comment.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </td>
                    <td class="col-actions">
                        <a href="${pageContext.request.contextPath}/admin/comment-controller?action=delete&id=${comment.id}"
                           class="delete-btn"
                           onclick="return confirm('Xóa vĩnh viễn comment #${comment.id}?');">
                            Xóa
                        </a>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>
