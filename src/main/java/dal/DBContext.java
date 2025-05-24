/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
/**
 *
 * @author ASUS
 */
public class DBContext {
    private static final String URL = "jdbc:sqlserver://ZIG:1433;databaseName=HotelManagement;encrypt=false";
    private static final String USER = "sa";  // Thay bằng user SQL Server của bạn
    private static final String PASSWORD = "123";  // Thay bằng password của bạn

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); // Load driver
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Không tìm thấy Driver SQL Server!", e);
        }
    }

    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            if (conn != null) {
                System.out.println("✅ Kết nối thành công!");
            }
        } catch (SQLException e) {
            System.err.println("⛔ Lỗi kết nối: " + e.getMessage());
        }
    }
}
