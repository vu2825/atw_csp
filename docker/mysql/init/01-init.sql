USE thanh_toan;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fullname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    avatar VARCHAR(500) DEFAULT NULL,
    wallet DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    isAdmin TINYINT(1) NOT NULL DEFAULT 0,
    is_admin TINYINT(1) GENERATED ALWAYS AS (isAdmin) STORED,
    isPremium TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_users_email (email),
    UNIQUE KEY uq_users_username (username)
);

CREATE TABLE IF NOT EXISTS videos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(255) DEFAULT NULL,
    poster_url VARCHAR(500) DEFAULT NULL,
    url_video_360P VARCHAR(500) DEFAULT NULL,
    url_video_480P VARCHAR(500) DEFAULT NULL,
    duration TIME DEFAULT NULL,
    director VARCHAR(255) DEFAULT NULL,
    published_by VARCHAR(255) DEFAULT NULL,
    published_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS watchlist (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    video_id INT NOT NULL,
    added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_watchlist_user_video (user_id, video_id),
    CONSTRAINT fk_watchlist_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_watchlist_video FOREIGN KEY (video_id) REFERENCES videos(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    video_id INT NOT NULL,
    progress_seconds INT NOT NULL DEFAULT 0,
    last_watched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_history_user_video (user_id, video_id),
    CONSTRAINT fk_history_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_history_video FOREIGN KEY (video_id) REFERENCES videos(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rating_reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rating INT NOT NULL,
    comment TEXT NOT NULL,
    user_id INT NOT NULL,
    video_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_rating_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_rating_reviews_video FOREIGN KEY (video_id) REFERENCES videos(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS topup_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_topup_requests_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS users_subscription (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plan VARCHAR(50) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    started_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_subscription_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

DROP VIEW IF EXISTS topup_request;
CREATE VIEW topup_request AS
SELECT id, user_id, amount, status, created_at, updated_at
FROM topup_requests;

INSERT INTO users (id, fullname, email, username, password, avatar, wallet, isAdmin, isPremium)
VALUES
    (1, 'Local Admin', 'admin@example.com', 'admin', 'admin123', 'https://i.pravatar.cc/150?img=12', 500.00, 1, 1),
    (2, 'Demo User', 'user@example.com', 'demo', 'demo123', 'https://i.pravatar.cc/150?img=5', 120.00, 0, 0)
ON DUPLICATE KEY UPDATE
    fullname = VALUES(fullname),
    password = VALUES(password),
    wallet = VALUES(wallet),
    isAdmin = VALUES(isAdmin),
    isPremium = VALUES(isPremium);

INSERT INTO videos (id, title, genre, poster_url, url_video_360P, url_video_480P, duration, director, published_by, published_at, created_at)
VALUES
    (
        1,
        'Big Buck Bunny',
        'Animation, Family',
        'https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        '00:09:56',
        'Blender Foundation',
        'Local Studio',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    genre = VALUES(genre),
    poster_url = VALUES(poster_url),
    url_video_360P = VALUES(url_video_360P),
    url_video_480P = VALUES(url_video_480P),
    duration = VALUES(duration),
    director = VALUES(director),
    published_by = VALUES(published_by),
    published_at = VALUES(published_at);

INSERT INTO watchlist (user_id, video_id, added_at)
VALUES (2, 1, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE added_at = VALUES(added_at);

INSERT INTO history (user_id, video_id, progress_seconds, last_watched_at)
VALUES (2, 1, 120, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE
    progress_seconds = VALUES(progress_seconds),
    last_watched_at = VALUES(last_watched_at);

INSERT INTO rating_reviews (id, rating, comment, user_id, video_id, created_at, updated_at)
VALUES (1, 5, 'Seed review for local development.', 2, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE
    rating = VALUES(rating),
    comment = VALUES(comment),
    updated_at = VALUES(updated_at);

INSERT INTO topup_requests (id, user_id, amount, status, created_at, updated_at)
VALUES (1, 2, 50.00, 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE
    amount = VALUES(amount),
    status = VALUES(status),
    updated_at = VALUES(updated_at);

INSERT INTO users_subscription (id, user_id, plan, price, started_at, expires_at, status)
VALUES (1, 1, 'twelveMonth', 99.99, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 12 MONTH), 'active')
ON DUPLICATE KEY UPDATE
    plan = VALUES(plan),
    price = VALUES(price),
    expires_at = VALUES(expires_at),
    status = VALUES(status);
