<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <title>Quản lý Người dùng</title>
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
            max-width: 1100px;
            margin: 0 auto;
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
        }
        .filter-form a.reset-btn {
            background:#333;
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
        .col-user    { width: auto; text-align: left; }
        .col-email   { width: 28%; text-align: left; }
        .col-wallet  { width: 140px; text-align: right; font-variant-numeric: tabular-nums; }
        .col-flag    { width: 120px; text-align: center; }
        .col-action  { width: 120px; text-align: center; }

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
            min-width: 70px;
            text-align: center;
            padding: 4px 8px;
            border-radius: 16px;
            font-size: 12px;
            font-weight: 600;
        }
        .tag-yes { background-color: #0f5132; color: #d1fae5; }
        .tag-no  { background-color: #5c2b29; color: #ffdad4; }

        .delete-btn {
            background: #E50914;
            color: #fff;
            padding: 8px 12px;
            text-decoration: none;
            border-radius: 6px;
            font-size: 13px;
            transition: 0.3s;
            display: inline-block;
            border: none;
        }
        .delete-btn:hover {
            background: #ff1a23;
            transform: translateY(-1px);
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
    </style>
</head>
<body>

<a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-back">⬅ Quay lại</a>
<div class="header-spacer"></div>

<div class="content-wrap">
    <h2>Quản lý người dùng</h2>

    <!-- FORM FILTER -->
    <form method="get" action="${pageContext.request.contextPath}/admin/user-controller" class="filter-form">
        <div class="filter-left">
            <div>
                <label style="font-size:13px;color:#ccc;margin-right:6px;">Role:</label>
                <select name="role">
                    <option value="" ${empty role ? 'selected' : ''}>All</option>
                    <option value="premium" ${role == 'premium' ? 'selected' : ''}>Premium</option>
                </select>
            </div>

            <div>
                <label style="font-size:13px;color:#ccc;margin:0 6px 0 10px;">Sort:</label>
                <select name="sort">
                    <option value="" ${empty sort ? 'selected' : ''}>Mặc định (ID ↓)</option>
                    <option value="wallet_asc" ${sort == 'wallet_asc' ? 'selected' : ''}>Wallet ↑</option>
                    <option value="wallet_desc" ${sort == 'wallet_desc' ? 'selected' : ''}>Wallet ↓</option>
                </select>
            </div>

            <div>
                <input type="text" name="q" placeholder="Tìm username/email"
                       value="${fn:escapeXml(q)}"
                       style="min-width:220px;"/>
            </div>

            <button type="submit">Apply</button>
            <a href="${pageContext.request.contextPath}/admin/user-controller" class="reset-btn">Reset</a>
        </div>

        <div class="filter-right" style="font-size:13px;color:#aaa;">
            Tổng: <strong>${fn:length(userList)}</strong>
        </div>
    </form>

    <!-- TABLE -->
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th class="col-id">ID</th>
                <th class="col-user">Username</th>
                <th class="col-email">Email</th>
                <th class="col-wallet">Wallet</th>
                <th class="col-flag">Premium</th>
                <th class="col-action">Action</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty userList}">
                    <tr>
                        <td colspan="6" style="text-align:center;color:#aaa;padding:18px;">
                            Không có dữ liệu phù hợp.
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="user" items="${userList}">
                        <tr>
                            <td class="col-id">${user.id}</td>
                            <td class="col-user">
                                <span class="truncate" title="${user.username}">${user.username}</span>
                            </td>
                            <td class="col-email">
                                <span class="truncate" title="${user.email}">${user.email}</span>
                            </td>
                            <td class="col-wallet">
                                <fmt:formatNumber value="${user.wallet}" type="number" groupingUsed="true" minFractionDigits="0" maxFractionDigits="2"/>
                            </td>
                            <td class="col-flag">
                                <span class="tag ${user.isPremium ? 'tag-yes' : 'tag-no'}">
                                    ${user.isPremium ? 'YES' : 'NO'}
                                </span>
                            </td>
                            <td class="col-action">
                                <a href="${pageContext.request.contextPath}/admin/user-controller?action=delete&id=${user.id}"
                                   class="delete-btn"
                                   onclick="return confirm('Bạn có chắc chắn muốn xoá user #${user.id}?');">
                                    Xoá
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

</body>
</html>
