<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
    
<head>
  <meta charset="UTF-8">
  <title>Login</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/styles/login.css">

</head>
<body>
  <div class="container">
    <div class="card">
      <h1 class="display">Welcome</h1>

      <div class="tabs">
        <a class="active" href="${ctx}/auth/login">LOGIN</a>
        <a href="${ctx}/auth/signup">SIGNUP</a>
      </div>

      <!-- Flash / message (đã được servlet đưa từ session -> request) -->
      <c:if test="${not empty msg}">
        <div class="success">${msg}</div>
      </c:if>
      <c:if test="${not empty error}">
        <div class="error">${error}</div>
      </c:if>

      <form method="post" action="${ctx}/auth/login" autocomplete="off" class="form">
        <input class="input"
               name="username"
               placeholder="Username or Email"
               required
               value="${param.username != null ? param.username : ''}">
        <input class="input"
               type="password"
               name="password"
               placeholder="Password"
               required>
        <button class="btn" type="submit">LOGIN</button>
      </form>

      <div class="helper">
            <a href="${ctx}/auth/forgot" class="forgot-link">Forgot Password?</a>
      </div>

    </div>
    <div class="panel-img">
      <img src="${ctx}/images/anh_1.png" alt="hero" style="width:100%;display:block">
    </div>
  </div>
</body>
</html>
