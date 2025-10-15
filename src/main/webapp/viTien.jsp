<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="dao.UserDao_update" %>
<%@ page import="bussines.User_login" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<c:if test="${empty sessionScope.user}">
    <c:redirect url="${ctx}/auth/login" />
</c:if>

<%
    // ✅ Lấy user hiện tại từ session
    User_login user = (User_login) session.getAttribute("user");
    double walletBalance = 0.0;

    if (user != null) {
        try {
            // ✅ Gọi DAO để lấy số dư mới nhất từ DB theo ID
            UserDao_update dao = new UserDao_update();
            walletBalance = dao.getWalletById(user.getId());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Ví tiền của bạn</title>
    <link rel="stylesheet" href="${ctx}/styles/profile.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        body {
            font-family: "Inter", sans-serif;
            background: #0b0f19;
            color: #fff;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .wallet-container {
            background: #111827;
            padding: 40px;
            width: 450px;
            border-radius: 14px;
            box-shadow: 0 0 25px rgba(0,0,0,0.3);
            text-align: center;
        }

        .wallet-container h2 {
            color: #facc15;
            margin-bottom: 20px;
        }

        .wallet-info {
            color: #cbd5e1;
            font-size: 16px;
            margin-bottom: 30px;
        }

        .wallet-balance {
            font-size: 28px;
            font-weight: 700;
            color: #facc15;
            margin-bottom: 25px;
        }

        .btn {
            display: inline-block;
            border: none;
            border-radius: 8px;
            padding: 10px 22px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.2s ease;
            margin: 5px;
            text-decoration: none;
        }

        .btn-topup {
            background: #3b82f6;
            color: #fff;
        }
        .btn-topup:hover {
            background: #2563eb;
        }

        .btn-back {
            background: #64748b;
            color: #fff;
        }
        .btn-back:hover {
            background: #475569;
        }

        .topup-icon {
            margin-right: 8px;
        }
    </style>
</head>

<body>
    <div class="wallet-container">
        <h2>💰 Ví tiền của bạn</h2>

        <p class="wallet-info">
            Xin chào, <strong><%= user != null ? user.getFullname() : "Người dùng" %></strong>
        </p>

        <p class="wallet-balance">
            Số dư hiện tại:
            <span><%= String.format("%.2f", walletBalance) %> VND</span>
        </p>

        <!-- Nút nạp tiền -->
        <form action="${ctx}/TopUpRequest" method="get" style="display:inline;">
            <button type="submit" class="btn btn-topup">
                <i class="fa-solid fa-plus topup-icon"></i> Nạp thêm tiền
            </button>
        </form>

        <!-- Nút quay lại hồ sơ -->
        <a href="${ctx}/ProfileServlet" class="btn btn-back">
            <i class="fa-solid fa-arrow-left"></i> Quay lại hồ sơ
        </a>
    </div>
</body>
</html>
