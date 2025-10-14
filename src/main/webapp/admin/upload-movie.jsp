<%@ page contentType="text/html;charset=UTF-8" %>
<html lang="vi">
<head>
    <title>Thêm phim</title>

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
            margin-bottom: 24px;
        }

        .form-container {
            background-color: #111;
            max-width: 480px;
            margin: 0 auto;
            padding: 24px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(255, 255, 255, 0.05);
        }

        label {
            display: block;
            margin-bottom: 6px;
            font-weight: 500;
        }

        input, select {
            width: 100%;
            padding: 10px;
            margin-bottom: 16px;
            border-radius: 6px;
            border: none;
            outline: none;
            background-color: #222;
            color: #fff;
        }

        /* === Genre Section === */
        .genre-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 8px;
            margin-bottom: 16px;
            background-color: #111;
            padding: 8px;
            border-radius: 6px;
        }

        .genre-option {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .genre-option input[type="checkbox"] {
            width: 18px;
            height: 18px;
            accent-color: #E50914;
        }

        .genre-option label {
            color: #fff;
            font-size: 15px;
            cursor: pointer;
        }

        button {
            width: 100%;
            background-color: #E50914;
            border: none;
            color: #fff;
            padding: 12px;
            border-radius: 6px;
            cursor: pointer;
            transition: 0.3s;
            font-size: 16px;
        }

        button:hover {
            background-color: #ff1a23;
        }

        /* === Small Back Button === */
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
        }

        .btn-back:hover {
            background-color: #E50914;
            transform: scale(1.05);
        }
    </style>
</head>
<body>

<button class="btn-back" type="button"
        onclick="window.location.href='<%=request.getContextPath()%>/admin/movie-controller?action=manage'">
    ⬅ Quay lại
</button>

<%
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    if ("true".equals(success)) {
%>
<script>alert("✅ Movie added successfully!");</script>
<%
    } else if ("true".equals(error)) {
%>
<script>alert("❌ Failed to add movie! Please check your input or database.");</script>
<%
    }
%>

<h2>🎬 Add New Movie</h2>

<div class="form-container">
    <form action="<%=request.getContextPath()%>/admin/movie-controller" method="post">

        <label for="movieTitle">Tên phim:</label>
        <input type="text" id="movieTitle" name="movieTitle" required>

        <label for="posterUrl">Poster :</label>
        <input type="text" id="posterUrl" name="posterUrl"
               placeholder="https://..." required>

        <label for="publishedBy">Phát hành bởi:</label>
        <input type="text" id="publishedBy" name="publishedBy" placeholder="Studio name">

        <label for="durationMinutes">Thời lượng:</label>
        <input type="text" id="durationMinutes" name="durationMinutes"
               placeholder="HH:MM:SS"
               pattern="^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$"
               required>

        <label for="director">Đạo diễn:</label>
        <input type="text" id="director" name="director" placeholder="Director name">

        <label>Genre:</label>
        <div class="genre-container">
            <div class="genre-option"><input type="checkbox" name="movieGenre" value="Action" id="action"><label for="action">Hành động</label></div>
            <div class="genre-option"><input type="checkbox" name="movieGenre" value="Romance" id="romance"><label for="romance">Lãng mạn</label></div>
            <div class="genre-option"><input type="checkbox" name="movieGenre" value="Horror" id="horror"><label for="horror">Kinh dị</label></div>
            <div class="genre-option"><input type="checkbox" name="movieGenre" value="Animation" id="animation"><label for="animation">Hoạt hình</label></div>
            <div class="genre-option"><input type="checkbox" name="movieGenre" value="Adventure" id="adventure"><label for="adventure">Phiêu lưu</label></div>
            <div class="genre-option"><input type="checkbox" name="movieGenre" value="Sci-Fi" id="scifi"><label for="scifi">Khoa học viễn tưởng</label></div>
            <div class="genre-option"><input type="checkbox" name="movieGenre" value="Comedy" id="comedy"><label for="comedy">Hài kịch</label></div>
            <div class="genre-option"><input type="checkbox" name="movieGenre" value="Drama" id="drama"><label for="drama">Kịch</label></div>
        </div>

        <label for="movieResolution">Độ phân giải:</label>
        <select id="movieResolution" name="movieResolution" required>
            <option value="360">360p</option>
            <option value="480">480p</option>
        </select>

        <label for="videoUrl">Link phim :</label>
        <input type="text" id="videoUrl" name="videoUrl"
               placeholder="https://drive.google.com/file/d/..." required>

        <button type="submit">Đăng tải</button>
    </form>
</div>
</body>
</html>
