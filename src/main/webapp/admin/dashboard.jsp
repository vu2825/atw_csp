<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="types.DashboardStats" %>
<%
    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
%>

<html>
<head>
    <title>Admin Dashboard</title>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #000;
            color: #fff;
            margin: 0;
            display: flex;
        }

        .container {
            display: flex;
            width: 100%;
        }

        .sidebar {
            background-color: #111;
            width: 220px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 20px;
            height: 100vh;
        }

        .sidebar h3 {
            margin-bottom: 10px;
            color: #E50914;
        }

        .sidebar a {
            color: #fff;
            text-decoration: none;
            font-weight: 500;
            transition: 0.2s;
        }

        .sidebar a:hover {
            color: #E50914;
            transform: translateX(5px);
        }

        .main {
            flex: 1;
            padding: 40px;
        }

        .card-grid {
            display: grid;
            grid-template-columns: repeat(2, 250px);
            gap: 20px;
        }

        .card {
            background-color: #222;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 0 10px rgba(255, 255, 255, 0.05);
            transition: 0.3s;
        }

        .card:hover {
            background-color: #333;
            transform: translateY(-3px);
        }

        .card h4 {
            margin-bottom: 10px;
        }

        .card p {
            font-size: 20px;
            margin: 0;
        }
    </style>
</head>

<body>
<div class="container">
    <!-- Sidebar -->
    <div class="sidebar">
        <h3>Admin Dashboard</h3>
        <a href="<%=request.getContextPath()%>">Trang chủ</a>
        <a href="<%=request.getContextPath()%>/admin/movie-controller?action=manage">Quản lí phim</a>
        <a href="<%=request.getContextPath()%>/admin/user-controller">Quản lí người dùng</a>
        <a href="<%=request.getContextPath()%>/admin/comment-controller">Quản lí comment</a>
    </div>

    <!-- Main content -->
    <div class="main">
        <h2>Xin chào, Admin!</h2>

        <div class="card-grid">
            <div class="card">
                <h4>Tổng số người dùng</h4>
                <p><b><%= stats.getTotalUsers() %></b></p>
            </div>
            <div class="card">
                <h4>Tổng số phim</h4>
                <p><b><%= stats.getTotalVideos() %></b></p>
            </div>
        </div>
    </div>
</div>
</body>
</html>
