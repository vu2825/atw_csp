<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Quên mật khẩu (Đơn giản)</title>
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; background:#0b1220; color:#fff; }
    .card { max-width: 420px; margin: 48px auto; background:#0f1b2e; padding:24px; border-radius:14px; }
    .field { margin-bottom:14px; }
    .field label { display:block; margin-bottom:6px; color:#b3b9c9; }
    .field input { width:100%; padding:10px 12px; border-radius:10px; border:1px solid #24314a; background:#0b1220; color:#fff; }
    .btn { width:100%; padding:12px; border:0; border-radius:12px; background:#3b82f6; color:#fff; font-weight:600; cursor:pointer; }
    .err { background:#3b1f2a; color:#ff9fb0; padding:10px 12px; border-radius:10px; margin-bottom:12px; }
    .hint { color:#b3b9c9; font-size:14px; margin-top:8px; }
    a { color:#90b4ff; text-decoration:none; }
  </style>
</head>
<body>
  <div class="card">
    <h2>Đặt lại mật khẩu</h2>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
      <div class="err"><%= error %></div>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/auth/forgot">
      <div class="field">
        <label>Username</label>
        <input name="username" value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>" required />
      </div>
      <div class="field">
        <label>Mật khẩu mới</label>
        <input type="password" name="newPassword" required />
      </div>
      <div class="field">
        <label>Xác nhận mật khẩu mới</label>
        <input type="password" name="confirmPassword" required />
      </div>
      <button class="btn" type="submit">Đổi mật khẩu</button>
      <div class="hint">
        <a href="<%= request.getContextPath() %>/auth/login">Quay lại đăng nhập</a>
      </div>
    </form>
  </div>
</body>
</html>
