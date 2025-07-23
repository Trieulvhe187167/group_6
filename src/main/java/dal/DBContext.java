package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {
    // Cách 1: tắt SSL



    private static final String DEFAULT_URL = "jdbc:sqlserver://ZIG:1433;"
            + "databaseName=HotelManagement;encrypt=false;";




  
    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASSWORD = "123";
    private static final String DEFAULT_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    
    public static Connection getConnection() throws SQLException {
              String url = System.getProperty("DB_URL", DEFAULT_URL);
        String user = System.getProperty("DB_USER", DEFAULT_USER);
        String password = System.getProperty("DB_PASSWORD", DEFAULT_PASSWORD);
        String driver = System.getProperty("DB_DRIVER", DEFAULT_DRIVER);

        try {
             Class.forName(driver);
            return DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException e) {
           throw new SQLException("Không tìm thấy Driver!", e);
        }
    }

    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            if (conn != null) {
                System.out.println("Kết nối thành công!");
            }
        } catch (SQLException e) {
            System.err.println("Lỗi kết nối: " + e.getMessage());
        }
    }
}
