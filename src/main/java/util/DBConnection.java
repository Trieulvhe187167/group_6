package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:sqlserver://ZIG:1433;databaseName=HotelManagement;encrypt=false";
    private static final String USER = "sa";  // Thay bằng user SQL Server của bạn
    private static final String PASSWORD = "123";  // Thay bằng password của bạn

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Cannot load SQLServer driver", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}