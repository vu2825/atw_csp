<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="bussines.Movie" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title><c:out value="${movie != null ? movie.title : 'Không tìm thấy phim'}"/> - HCMUTE</title>

  <link rel="stylesheet" href="${ctx}/styles/style.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

  <style>
    .container { max-width:1200px; margin:30px auto; padding:0 20px; }
    .movie-detail { display:flex; gap:40px; align-items:flex-start; }
    .movie-poster { flex:0 0 300px; }
    .movie-poster-img { width:100%; height:450px; object-fit:cover; border-radius:12px; box-shadow:0 8px 25px rgba(0,0,0,.1); }
    .movie-poster-placeholder{ width:100%; height:450px; background:var(--border); border-radius:12px; display:flex; align-items:center; justify-content:center; color:var(--muted); font-size:4rem; box-shadow:0 8px 25px rgba(0,0,0,.1); }
    .movie-info{ flex:1; }
    .movie-title{ font-size:2.3rem; margin-bottom:16px; color:var(--text); font-weight:800; line-height:1.2; }

    .card { background:var(--card); border:1px solid var(--border); border-radius:14px; padding:18px; }
    .card + .card { margin-top:16px; }

    .movie-description { line-height:1.7; }
    .movie-description p { margin:8px 0; }
    .movie-description strong{ color:var(--accent); }

    .watchlist-section { margin:16px 0; }
    .watchlist-button { display:inline-flex; align-items:center; gap:10px; padding:12px 24px; background:var(--card); color:var(--text); border:2px solid var(--accent); border-radius:10px; font-size:1rem; font-weight:600; cursor:pointer; transition:all .3s; }
    .watchlist-button:hover { background:var(--accent); color:#fff; transform:translateY(-2px); box-shadow:0 5px 15px rgba(37,99,235,.2); }
    .watchlist-button.added { background:var(--accent); color:#fff; border-color:var(--accent); }

    .quality-title{ font-weight:700; margin-bottom:12px; }
    .quality-options{ display:flex; gap:12px; flex-wrap:wrap; }
    .quality-option{ padding:12px 18px; border:2px solid var(--border); border-radius:10px; cursor:pointer; background:var(--card); min-width:120px; transition:.2s; }
    .quality-option:hover{ border-color:var(--accent); transform:translateY(-2px); }
    .quality-option.selected{ border-color:var(--accent); background:var(--accent); color:#fff; }

    .watch-button{ display:inline-flex; align-items:center; gap:10px; padding:14px 28px; background:var(--accent); color:#fff; border:none; border-radius:10px; font-weight:700; cursor:pointer; box-shadow:0 6px 20px rgba(37,99,235,.3); }
    .premium-warning{ background:linear-gradient(135deg,#ffd700,#ffed4e); color:#000; padding:12px; border-radius:10px; border-left:4px solid #ff6b00; font-weight:600; }

    .rating-summary { margin-top:24px; display:grid; grid-template-columns:240px 1fr; gap:18px; }
    .rating-summary .avg-box { background:var(--card); border:1px solid var(--border); border-radius:14px; padding:16px; text-align:center; }
    .rating-summary .avg-score { font-size:42px; font-weight:800; line-height:1; }
    .rating-summary .avg-stars i.on { color:#fbbf24; }
    .rating-summary .avg-stars i.off{ color:#cbd5e1; }
    .rating-summary .dist { background:var(--card); border:1px solid var(--border); border-radius:14px; padding:12px 16px; }
    .rating-summary .dist-row { display:grid; grid-template-columns:48px 1fr 44px; gap:10px; align-items:center; margin:6px 0; }
    .rating-summary .bar { height:10px; background:#e5e7eb; border-radius:999px; overflow:hidden; }
    .rating-summary .bar-fill { height:100%; background:#60a5fa; }

    .comments { margin-top:24px; }
    .comment { display:grid; grid-template-columns:48px 1fr; gap:12px; padding:14px 16px; border-bottom:1px solid var(--border); }
    .avatar { width:48px; height:48px; border-radius:50%; display:flex; align-items:center; justify-content:center; background:#e5e7eb; color:#111827; font-weight:700; }
    .comment .meta { display:flex; gap:10px; align-items:center; font-size:14px; color:var(--muted); }
    .comment .meta .user{ color:var(--text); font-weight:700; }
    .comment .stars i.on { color:#fbbf24; }
    .comment .stars i.off{ color:#cbd5e1; }
    .comment .content{ margin-top:6px; white-space:pre-wrap; color:var(--text); }

    .navbar{ position:sticky; top:0; z-index:50; background:var(--card); border-bottom:1px solid var(--border); }
    .navbar .inner{ max-width:1300px; margin:0 auto; padding:12px 24px; display:grid; grid-template-columns:auto 1fr auto; align-items:center; gap:24px; }
    .brand{ display:flex; align-items:center; gap:10px; text-decoration:none; color:var(--accent); }
    .nav{ display:flex; justify-content:center; gap:46px; }
    .nav a{ color:var(--text); text-decoration:none; font-weight:600; }
    .actions{ display:flex; align-items:center; gap:12px; justify-self:end; }
    .search-form{ display:flex; align-items:center; gap:8px; background:var(--card); border:1px solid var(--border); border-radius:999px; padding:6px 12px; min-width:280px; }
    .search-input{ border:none; outline:none; background:transparent; font:14px/1.5 system-ui,-apple-system,Segoe UI,Roboto,sans-serif; color:var(--text); width:100%; }
    .search-btn{ border:none; background:transparent; cursor:pointer; }

    @media (max-width:820px){
      .movie-detail { flex-direction:column; }
      .rating-summary { grid-template-columns:1fr; }
    }
  </style>
</head>

<body>
  <header class="navbar">
    <div class="inner">
      <a class="brand" href="${ctx}/HomeServlet?action=TrangChu">
        <img src="${ctx}/images/Logo.png" alt="Logo" class="logo-img" />
        <span>HCMUTE</span>
      </a>

      <nav class="nav" aria-label="Chính">
        <a href="${ctx}/HomeServlet?action=TrangChu">Trang chủ</a>
        <a href="${ctx}/TheLoaiServlet">Thể loại</a>
        <a href="${ctx}/movies">List Phim</a>
      </nav>

      <div class="actions" aria-label="Tác vụ">
        <form id="search-form" action="${ctx}/SearchServlet" method="get" class="search-form" role="search">
          <input type="text" id="search-input" name="query" class="search-input" placeholder="Tìm phim..." autocomplete="off" />
          <button type="submit" class="search-btn"><i class="fa-solid fa-magnifying-glass"></i></button>
          <ul id="suggestions" class="suggestions-list"></ul>
        </form>

        <a class="action-link" href="${ctx}/watchlist" aria-label="Watchlist"><i class="fa-solid fa-bookmark"></i></a>
        <a class="action-link" href="${ctx}/HomeServlet?action=GioHang" aria-label="Giỏ hàng"><i class="fa-solid fa-cart-shopping"></i></a>
        <a class="action-link" href="${ctx}/HomeServlet?action=TaiKhoan" aria-label="Tài khoản"><i class="fa-solid fa-user"></i></a>
        <i id="theme-toggle" class="fa-solid fa-sun" aria-label="Đổi giao diện sáng/tối"></i>
      </div>
    </div>
  </header>

  <main class="container">
    <a href="${ctx}/movies" class="back-button card" style="display:inline-flex;gap:10px;align-items:center;margin-bottom:16px;">
      <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
    </a>

    <c:choose>
      <c:when test="${movie != null}">
        <div class="movie-detail">
          <div class="movie-poster">
            <c:choose>
              <c:when test="${not empty movie.poster}">
                <img src="${movie.poster}" alt="${movie.title}" class="movie-poster-img" onerror="this.style.display='none';">
              </c:when>
              <c:otherwise>
                <div class="movie-poster-placeholder"><i class="fa-solid fa-film"></i></div>
              </c:otherwise>
            </c:choose>
          </div>

          <div class="movie-info">
            <h1 class="movie-title"><c:out value="${movie.title}"/></h1>

            <div class="card movie-description">
              <p>Khám phá bộ phim đặc sắc <strong>"<c:out value='${movie.title}'/>"</strong> với hình ảnh sắc nét và âm thanh sống động.</p>
              <c:if test="${not empty movie.genre}">
                <p><strong> Thể Loại:</strong> <c:out value="${movie.genre}"/></p>
              </c:if>
              <p><strong>⏱️ Thời lượng:</strong> <c:out value="${empty movie.duration ? 'Đang cập nhật' : movie.duration}"/></p>
            </div>

            <c:if test="${not empty notPremium && notPremium}">
              <div class="card premium-warning">⭐ Nâng cấp tài khoản Premium để xem phim chất lượng cao 480P!</div>
            </c:if>

            <!-- Watchlist -->
            <div class="watchlist-section">
              <form id="watchlist-form" action="${ctx}/watchlist" method="post">
                <input type="hidden" name="action" value="${isInWatchlist ? 'remove' : 'add'}"/>
                <input type="hidden" name="videoId" value="${movie.id}"/>
                <button type="submit" class="watchlist-button ${isInWatchlist ? 'added' : ''}">
                  <i class="fa-solid ${isInWatchlist ? 'fa-check' : 'fa-bookmark'}"></i>
                  <span>${isInWatchlist ? 'Đã thêm vào Watchlist' : 'Thêm vào Watchlist'}</span>
                </button>
              </form>
            </div>

            <!-- Chọn chất lượng -->
            <div class="card">
              <div class="quality-title">🎥 Chọn chất lượng xem phim:</div>
              <div class="quality-options" 
                   data-watch360="${watchUrl360}" 
                   data-watch480="${watchUrl480}">
                <div class="quality-option selected" data-quality="360">
                  <div class="quality-name">HD 360P</div>
                  <div class="quality-desc">Chất lượng tiêu chuẩn</div>
                </div>
                <div class="quality-option" data-quality="480" 
                     title="${notPremium ? 'Cần tài khoản Premium để xem 480P' : 'Chất lượng cao'}">
                  <div class="quality-name">HD 480P</div>
                  <div class="quality-desc">${notPremium ? '🔒 Cần Premium' : 'Chất lượng cao'}</div>
                </div>
              </div>
            </div>

            <button id="watch-button" class="watch-button">
              <i class="fa-solid fa-play"></i> Xem Phim Ngay
            </button>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <div class="card" style="border-left:4px solid var(--danger);">
          <h3>Không tìm thấy phim</h3>
          <p>Phim với ID=${param.id} không tồn tại trong hệ thống.</p>
          <a href="${ctx}/movies" class="watch-button" style="background:transparent;color:var(--text);border:1px solid var(--border);">
            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
          </a>
        </div>
      </c:otherwise>
    </c:choose>

    <!-- Rating summary -->
    <c:if test="${not empty summary}">
      <section id="rating" class="rating-summary">
        <div class="avg-box">
          <div class="avg-score">
            <fmt:formatNumber value="${summary.avg}" type="number" maxFractionDigits="1"/>
          </div>
          <c:set var="avgRounded" value="${summary.avg + 0.4}"/>
          <div class="avg-stars" style="margin:6px 0">
            <c:forEach var="i" begin="1" end="5">
              <i class="fa-solid fa-star ${i <= avgRounded ? 'on' : 'off'}"></i>
            </c:forEach>
          </div>
          <div class="vote-count" style="font-size:14px;opacity:.8">
            <c:out value="${summary.count}"/> lượt đánh giá
          </div>
        </div>
      </section>
    </c:if>

    <!-- Comments -->
    <section id="comments" class="comments">
      <h3 style="margin:12px 0 8px 0;">Bình luận của người xem</h3>

      <c:choose>
        <c:when test="${empty reviews}">
          <div class="card" style="opacity:.8">Chưa có bình luận nào cho phim này.</div>
        </c:when>
        <c:otherwise>
          <div class="card" style="padding:0">
            <c:forEach var="cmt" items="${reviews}">
              <article class="comment">
                <div class="avatar">
                  <c:choose>
                    <c:when test="${not empty cmt.username}">
                      <c:out value="${fn:toUpperCase(fn:substring(cmt.username,0,1))}"/>
                    </c:when>
                    <c:otherwise>G</c:otherwise>
                  </c:choose>
                </div>
                <div class="body">
                  <div class="meta">
                    <strong class="user"><c:out value="${cmt.username}"/></strong>
                    <span class="stars">
                      <c:forEach var="i" begin="1" end="5">
                        <i class="fa-solid fa-star ${i <= cmt.rating ? 'on' : 'off'}"></i>
                      </c:forEach>
                    </span>
                    <span class="time">• <fmt:formatDate value="${cmt.created_at}" pattern="dd/MM/yyyy HH:mm"/></span>
                  </div>
                  <p class="content"><c:out value="${cmt.comment}"/></p>
                </div>
              </article>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>
    </section>
  </main>

  <script>
    // Chọn chất lượng + điều hướng bằng URL đã build sẵn từ servlet
    let selectedQuality = '360';
    const wrap = document.querySelector('.quality-options');
    document.querySelectorAll('.quality-option').forEach(opt=>{
      opt.addEventListener('click',()=>{
        document.querySelectorAll('.quality-option').forEach(o=>o.classList.remove('selected'));
        opt.classList.add('selected');
        selectedQuality = opt.dataset.quality;
      });
    });

    document.getElementById('watch-button')?.addEventListener('click', ()=>{
      const url360 = wrap?.dataset.watch360;
      const url480 = wrap?.dataset.watch480; // nếu non-premium, servlet đã ép về 360
      const target = (selectedQuality === '480') ? url480 : url360;
      if (!target) { alert('URL xem phim không hợp lệ'); return; }
      window.location.href = target;
    });

    // Theme toggle
    const toggle=document.getElementById("theme-toggle"),root=document.documentElement;
    const saved=localStorage.getItem("theme"); if(saved==="dark"){root.classList.add("dark");} else {root.classList.remove("dark");}
    const updateIcon=()=>{const d=root.classList.contains("dark"); toggle.classList.toggle("fa-sun",!d); toggle.classList.toggle("fa-moon",d);}; updateIcon();
    toggle?.addEventListener("click",()=>{root.classList.toggle("dark"); localStorage.setItem("theme",root.classList.contains("dark")?"dark":"light"); updateIcon();});

    // Search suggest (1 bản duy nhất)
    const input=document.getElementById("search-input"), suggestionsList=document.getElementById("suggestions");
    input?.addEventListener("input",()=>{
      const q=input.value.trim(); suggestionsList?.classList.remove("show"); if(!suggestionsList) return;
      suggestionsList.innerHTML=""; if(q.length===0) return;
      fetch('${ctx}/SearchServlet?action=suggest&query='+encodeURIComponent(q))
        .then(r=>{ if(!r.ok) throw new Error('Network error: '+r.status); return r.json(); })
        .then(data=>{
          suggestionsList.innerHTML="";
          if(Array.isArray(data)&&data.length>0){
            data.forEach(t=>{ const li=document.createElement("li"); li.textContent=t||"Không có tiêu đề"; suggestionsList.appendChild(li); });
          }else{
            const li=document.createElement("li"); li.textContent="Không có gợi ý"; suggestionsList.appendChild(li);
          }
          suggestionsList.classList.add("show");
        })
        .catch(err=>{ suggestionsList.innerHTML=`<li>Lỗi: ${err.message}</li>`; suggestionsList.classList.add("show"); });
    });
    suggestionsList?.addEventListener("click",e=>{
      if(e.target.tagName==="LI"){ input.value=e.target.textContent; suggestionsList.classList.remove("show"); suggestionsList.innerHTML=""; document.getElementById("search-form").submit(); }
    });
  </script>
</body>
</html>
