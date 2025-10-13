<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<link rel="stylesheet" href="${ctx}/styles/login.css">


<div class="container">
  <div class="card">
    <h1 class="display">SIGNUP</h1>

    <div class="stack">
      <c:choose>
        <c:when test="${not empty sessionScope.flash_ok}">
          <div class="success">${sessionScope.flash_ok}</div>
          <c:remove var="flash_ok" scope="session"/>
        </c:when>
        <c:when test="${not empty sessionScope.flash_err}">
          <div class="error">${sessionScope.flash_err}</div>
          <c:remove var="flash_err" scope="session"/>
        </c:when>
        <c:when test="${not empty username}">
          <div class="success">Tạo tài khoản thành công.</div>
        </c:when>
        <c:otherwise>
          <div class="success">Đăng ký thành công.</div>
        </c:otherwise>
      </c:choose>

      <a class="btn" href="${ctx}/auth/login">Go Login</a>
    </div>
  </div>
</div>
