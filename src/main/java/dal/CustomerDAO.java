package dal;

import model.Customer;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {

    
    // Lấy tất cả khách (role = 'GUEST')
    public List<Customer> getAllCustomers() throws SQLException {
        String sql = "SELECT * FROM dbo.Users WHERE Role = 'GUEST'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Customer> list = new ArrayList<>();
            while (rs.next()) {
                Customer c = new Customer(
                    rs.getInt("Id"),
                    rs.getString("Username"),
                    rs.getString("PasswordHash"),
                    rs.getString("FullName"),
                    rs.getString("Email"),
                    rs.getString("Phone"),
                    rs.getString("Role")
                );
                list.add(c);
            }
            return list;
        }
    }

    // Tạo mới khách
    public void createCustomer(Customer c) throws SQLException {
        String sql = "INSERT INTO dbo.Users "
                   + "(Username, PasswordHash, FullName, Email, Phone, Role) "
                   + "VALUES (?, ?, ?, ?, ?, 'GUEST')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getUsername());
            ps.setString(2, c.getPasswordHash());
            ps.setString(3, c.getFullName());
            ps.setString(4, c.getEmail());
            ps.setString(5, c.getPhone());
            ps.executeUpdate();
        }
    }

    // Cập nhật thông tin khách
    public void updateCustomer(Customer c) throws SQLException {
        String sql = "UPDATE dbo.Users SET "
                   + "FullName = ?, Email = ?, Phone = ? "
                   + "WHERE Id = ? AND Role = 'GUEST'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getFullName());
            ps.setString(2, c.getEmail());
            ps.setString(3, c.getPhone());
            ps.setInt(4, c.getId());
            ps.executeUpdate();
        }
    }

    // Xóa khách (thực chất chỉ đổi Role hoặc xóa hẳn)
    public void deleteCustomer(int id) throws SQLException {
        String sql = "DELETE FROM dbo.Users WHERE Id = ? AND Role = 'GUEST'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // Lấy khách theo Id
    public Customer getCustomerById(int id) throws SQLException {
        String sql = "SELECT * FROM dbo.Users WHERE Id = ? AND Role = 'GUEST'";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                        rs.getInt("Id"),
                        rs.getString("Username"),
                        rs.getString("PasswordHash"),
                        rs.getString("FullName"),
                        rs.getString("Email"),
                        rs.getString("Phone"),
                        rs.getString("Role")
                    );
                }
            }
        }
        return null;
    }
}