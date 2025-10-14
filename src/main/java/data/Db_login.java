package data;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.naming.NamingException;

public class Db_login {
    private static DataSource ds;
    static {
        try {
            ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/loginDB");
        } catch (NamingException e) {
            throw new RuntimeException("JNDI not found: jdbc/loginDB", e);
        }
    }
    public static Connection getConnection() throws SQLException {
        return ds.getConnection();
    }
}
