<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<c:if test="${empty sessionScope.user}">
    <c:redirect url="${ctx}/auth/login" />
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý tài khoản</title>
    <link rel="stylesheet" href="${ctx}/styles/profile.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<div class="account-container">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <h2>Quản lý tài khoản</h2>
        <ul class="menu">
            <li class="active">
                <a href="#">
                <i class="fa-solid fa-user"></i> Tài khoản</li>
                </a>
            <li>
                <a href="${ctx}/viTien.jsp">
                <i class="fa-solid fa-plus"></i> Ví tiền</li>
                </a>
            <li>
                <a href="${pageContext.request.contextPath}/history">
                    <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử xem phim
                </a>
            </li>
        </ul>
    </aside>

    <!-- NỘI DUNG CHÍNH -->
    <main class="main-content">
        <h1>Tài khoản</h1>
        <p class="desc">Cập nhật thông tin tài khoản</p>

        <form action="${ctx}/ProfileServlet" method="post" enctype="multipart/form-data" class="profile-form">
            <div class="form-left">
                <input type="hidden" name="id" value="${sessionScope.user.id}">
                <label>Họ và tên</label>
                <input type="text" name="fullname" value="${sessionScope.user.fullname}">
                
                <label>Username</label>
                <input type="text" name="username" value="${sessionScope.user.username}">
                
                <label>Email</label>
                <input type="email" name="email" value="${sessionScope.user.email}">
                
                <label>Phân loại</label>
                <input type="text" name="premium"
                       value="${sessionScope.user.premium ? 'Premium' : 'Miễn phí'}"
                       readonly>

                <div class="form-actions">
                    <button type="submit" class="btn btn-update">Cập nhật</button>
                    <a href="${ctx}/HomeServlet" class="btn btn-home">Trang chủ</a>
                </div>
                
                <p class="change-pass">
                    <a href="#" id="openPopup">Đổi mật khẩu</a>
                </p>

            </div>

            <div class="form-right">
        <label for="avatarInput" class="avatar-wrapper">
        <c:choose>
        <c:when test="${not empty sessionScope.user.avatar}">
          <img id="avatarPreview" 
               src="${ctx}/profile_images/${sessionScope.user.avatar}" 
               alt="Avatar" class="avatar">
        </c:when>
        <c:otherwise>
          <img id="avatarPreview" 
               src="${ctx}/profile_images/default-avatar.jpg" 
               alt="Avatar" class="avatar">
        </c:otherwise>
        </c:choose>
        </label>

        <!-- Input ẩn để chọn ảnh -->
        <input type="file" id="avatarInput" name="avatarFile" accept="image/*" style="display:none;">

        <span class="avatar-note">
            <i class="fa-solid fa-images"></i>
            <label for="avatarInput" class="clickable-text">Ảnh có sẵn</label>
        </span>
    </div>
        </form>
                       
        <form action="${ctx}/ProfileServlet" method="post" class="change-pass-form">
            <div id="popupOverlay" class="popup-overlay">
                <div class="popup-box">
                    <h2>Đổi mật khẩu</h2>

                    <input type="hidden" name="action" value="changePassword">

                    <label>Mật khẩu hiện tại</label>
                    <input type="password" name="currentPassword" required>

                    <label>Mật khẩu mới</label>
                    <input type="password" name="newPassword" required>

                    <label>Xác nhận mật khẩu mới</label>
                    <input type="password" name="confirmPassword" required>

                    <div class="popup-actions">
                        <button type="submit" class="btn-update">Cập nhật</button>
                        <button type="button" class="btn-cancel" id="closePopup">Hủy</button>
                    </div>
                </div>
            </div>
        </form>

    </main>
</div>
<!--  Hiện ảnh sau khi update  -->
    <script>
    document.getElementById('avatarInput').addEventListener('change', function (event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function (e) {
                document.getElementById('avatarPreview').src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    });
    </script>
   
    <script>
        const popup = document.getElementById("popupOverlay");
        const openBtn = document.getElementById("openPopup");
        const closeBtn = document.getElementById("closePopup");

        openBtn.addEventListener("click", (e) => {
            e.preventDefault();
            popup.style.display = "flex";
        });

        closeBtn.addEventListener("click", () => {
            popup.style.display = "none";
        });

        popup.addEventListener("click", (e) => {
            if (e.target === popup) {
                popup.style.display = "none";
            }
        });
    </script>

</body>
</html>
