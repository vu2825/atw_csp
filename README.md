# WEB

Recommended local workflow: Docker

1. Bootstrap the database: `bash scripts/ensure-db.sh`
2. Start or rebuild the app stack: `docker compose up --build -d`
3. Open `http://localhost:8080/auth/signup`
4. Optional entry points: `http://localhost:8080/` or `http://localhost:8080/auth/login`

If MySQL was recreated and signup/login shows DB connection errors, rerun `bash scripts/ensure-db.sh` and restart the stack with `docker compose up --build -d`.

VSCode / Jetty local run still exists

1. Open the repo in VSCode.
2. Bootstrap the database first: `bash scripts/ensure-db.sh`
3. Build once with `./mvnw clean package -DskipTests` on Git Bash or `mvnw.cmd clean package -DskipTests` on PowerShell/cmd.
4. Start Jetty with `./mvnw jetty:run` on Git Bash or `mvnw.cmd jetty:run` on PowerShell/cmd.
5. Open `http://localhost:8080/HomePageWeb/`.

Notes

- `bash scripts/ensure-db.sh` starts the `mysql` compose service, ensures the `thanh_toan` schema exists, and reapplies `docker/mysql/init/01-init.sql`.
- Docker runs the WAR as `ROOT.war`, so the working browser path is `http://localhost:8080/auth/signup` instead of `/HomePageWeb/...`.
- Jetty still uses the existing local `jdbc/loginDB` JNDI setup for repo-based runs.

Database test data generator

- Run with Maven: `./mvnw exec:java -Dexec.mainClass=tooling.DatabaseTestDataGenerator -Dexec.args="--videos 5 --ratings 10 --watchlist 3 --history 3 --seed 123 --userId 2 --jdbcUrl jdbc:mysql://localhost:3306/thanh_toan?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false --dbUser user1 --dbPassword user1123@"`
- Supported args: `--videos`, `--ratings`, `--watchlist`, `--history`, `--seed`, `--userId`, `--jdbcUrl`, `--dbUser`, `--dbPassword`
- Defaults: `seed=42`, `userId=2`, DB settings from `WEB_RATING_DB_URL`, `WEB_RATING_DB_USER`, `WEB_RATING_DB_PASSWORD` or the local defaults in `tooling.DatabaseTestDataGenerator`
- Scope is limited to `videos`, `rating_reviews`, `watchlist`, and `history`; it does not write `topup_requests`, `users_subscription`, wallet fields, or auth-sensitive user data.
