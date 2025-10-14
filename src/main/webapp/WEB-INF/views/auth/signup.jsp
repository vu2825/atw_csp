<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Signup</title>
  <link rel="stylesheet" href="${ctx}/styles/login.css">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800;900&display=swap" rel="stylesheet">
</head>
<body>
  <div class="container">
    <div class="card">
      <h1 class="display">Welcome</h1>

      <div class="tabs">
        <a href="${ctx}/auth/login">LOGIN</a>
        <a class="active" href="${ctx}/auth/signup">SIGNUP</a>
      </div>

      <c:if test="${not empty error}">
        <div class="error">${error}</div>
      </c:if>

      <form method="post" action="${ctx}/auth/signup" autocomplete="off" class="form">
        <input class="input" name="fullname" placeholder="Full Name" required>
        <input class="input" name="email" type="email" placeholder="Email" required>
        <input class="input" name="username" placeholder="Username" required>
        <input class="input" name="password" type="password" placeholder="Password" required>
        <button class="btn" type="submit">Confirm</button>
      </form>
    </div>

    <div class="panel-img">
      <img src="${ctx}/images/anh_1.png" alt="" style="width:100%;display:block">
    </div>
  </div>
</body>
</html>
