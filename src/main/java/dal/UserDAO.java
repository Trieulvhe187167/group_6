package dal;

import model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User login(String username, String password) {
        String sql = "SELECT * FROM Users WHERE Username = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("PasswordHash");
                String inputHash = hashPassword(password);

                // Debug (tạm thời): In ra để kiểm tra giá trị hash
                System.out.println("Stored Hash: " + storedHash);
                System.out.println("Input  Hash: " + inputHash);

                if (storedHash != null && storedHash.equalsIgnoreCase(inputHash)) {
                    User user = new User();
                    user.setId(rs.getInt("Id"));
                    user.setUsername(username);
                    user.setFullName(rs.getString("FullName"));
                    user.setEmail(rs.getString("Email"));
                    user.setPhone(rs.getString("Phone"));
                    user.setRole(rs.getString("Role"));
                    user.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    user.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    return user;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Hàm mã hóa SHA-256
    private String hashPassword(String password) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hashBytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : hashBytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    public List<User> getFilteredUsers(String search, String role, String sort, int page, int pageSize) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM Users WHERE 1=1";

        if (search != null && !search.isEmpty()) {
            sql += " AND (FullName LIKE ? OR Email LIKE ?)";
        }
        if (role != null && !role.isEmpty()) {
            sql += " AND Role = ?";
        }
        if (sort != null && !sort.isEmpty()) {
            sql += " ORDER BY " + sort;
        } else {
            sql += " ORDER BY Id";
        }
        sql += " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = 1;
            if (search != null && !search.isEmpty()) {
                ps.setString(idx++, "%" + search + "%");
                ps.setString(idx++, "%" + search + "%");
            }
            if (role != null && !role.isEmpty()) {
                ps.setString(idx++, role);
            }
            ps.setInt(idx++, (page - 1) * pageSize);
            ps.setInt(idx, pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
//                list.add(new User(
//                    rs.getInt("Id"),
//                    rs.getString("Username"),
//                    rs.getString("FullName"),
//                    rs.getString("Email"),
//                    rs.getString("Phone"),
//                    rs.getString("Role")
//                ));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countFilteredUsers(String search, String role) {
        String sql = "SELECT COUNT(*) FROM Users WHERE 1=1";
        if (search != null && !search.isEmpty()) {
            sql += " AND (FullName LIKE ? OR Email LIKE ?)";
        }
        if (role != null && !role.isEmpty()) {
            sql += " AND Role = ?";
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = 1;
            if (search != null && !search.isEmpty()) {
                ps.setString(idx++, "%" + search + "%");
                ps.setString(idx++, "%" + search + "%");
            }
            if (role != null && !role.isEmpty()) {
                ps.setString(idx++, role);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void rejectUser(int id) {
        String sql = "UPDATE Users SET Role = 'REJECTED' WHERE Id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<User> getAllUsers() {
        List<User> userList = new ArrayList<>();
        String sql = "SELECT * FROM Users";

        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("Id"));
                user.setUsername(rs.getString("Username"));
                user.setPassword(rs.getString("PasswordHash"));
                user.setFullName(rs.getString("FullName"));
                user.setEmail(rs.getString("Email"));
                user.setPhone(rs.getString("Phone"));
                user.setRole(rs.getString("Role"));
                user.setCreatedAt(rs.getTimestamp("CreatedAt"));
                user.setUpdatedAt(rs.getTimestamp("UpdatedAt"));

                userList.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return userList;
    }

    public boolean createUser(User user) {
        String sql = "INSERT INTO users (username, passwordhash, fullname, email, phone, role, createdat, updatedat) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getFullName());
            stmt.setString(4, user.getEmail());
            stmt.setString(5, user.getPhone());
            stmt.setString(6, user.getRole());

            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Xóa user theo ID
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

}
