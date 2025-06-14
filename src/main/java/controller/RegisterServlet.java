package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.sql.*;
import dal.DBContext;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private boolean isStrongPassword(String password) {
        return password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$");
    }

    private boolean isValidEmail(String email) {
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    }

    private boolean isValidPhone(String phone) {
        return phone != null && phone.matches("^\\d{10}$");
    }
    
    // Thêm method kiểm tra username hợp lệ
    private boolean isValidUsername(String username) {
        // Username phải có ít nhất 3 ký tự, không chứa khoảng trắng
        return username != null && 
               username.length() >= 3 && 
               !username.contains(" ") && 
               username.matches("^[a-zA-Z0-9_]+$");
    }
    
    // Thêm method kiểm tra tên đầy đủ
    private boolean isValidFullName(String fullName) {
        // Tên phải có ít nhất 2 ký tự không phải khoảng trắng
        // Cho phép khoảng trắng giữa các từ
        return fullName != null && 
               fullName.trim().length() >= 2 && 
               fullName.matches("^[a-zA-ZÀ-ỹĐđ\\s]+$") && // Cho phép tiếng Việt có dấu
               !fullName.matches("^\\s+$"); // Không chỉ toàn khoảng trắng
    }

    private String hashPassword(String password) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hashBytes = md.digest(password.getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : hashBytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // Lấy parameters
        String username = request.getParameter("username");
        String fullName = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");

        try (PrintWriter out = response.getWriter()) {
            
            // Kiểm tra null trước
            if (username == null || fullName == null || email == null || 
                password == null || phone == null) {
                out.println("<script>alert('Vui lòng điền đầy đủ thông tin.');history.back();</script>");
return;
            }

            // Trim các giá trị
            username = username.trim();
            fullName = fullName.trim();
            email = email.trim();
            phone = phone.trim();
            // Không trim password vì có thể người dùng cố ý có space

            // Kiểm tra empty sau khi trim
            if (username.isEmpty() || fullName.isEmpty() || email.isEmpty() || 
                password.isEmpty() || phone.isEmpty()) {
                out.println("<script>alert('Vui lòng không để trống hoặc chỉ nhập khoảng trắng.');history.back();</script>");
                return;
            }

            // Validate username
            if (!isValidUsername(username)) {
                out.println("<script>alert('Username phải có ít nhất 3 ký tự, không chứa khoảng trắng và chỉ chứa chữ cái, số, dấu gạch dưới.');history.back();</script>");
                return;
            }

            // Validate full name
            if (!isValidFullName(fullName)) {
                out.println("<script>alert('Tên không hợp lệ. Vui lòng nhập tên thật của bạn.');history.back();</script>");
                return;
            }

            // Validate email
            if (!isValidEmail(email)) {
                out.println("<script>alert('Email không hợp lệ.');history.back();</script>");
                return;
            }

            // Validate phone
            if (!isValidPhone(phone)) {
                out.println("<script>alert('Số điện thoại phải có đúng 10 chữ số.');history.back();</script>");
                return;
            }

            // Validate password
            if (!isStrongPassword(password)) {
                out.println("<script>alert('Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.');history.back();</script>");
                return;
            }

            // Kiểm tra thêm các trường chỉ chứa khoảng trắng hoặc ký tự đặc biệt
            if (username.matches("^[\\s\\W]+$") || fullName.matches("^[\\s\\W]+$")) {
                out.println("<script>alert('Thông tin không hợp lệ. Vui lòng nhập dữ liệu chính xác.');history.back();</script>");
                return;
            }

            String hashedPassword = hashPassword(password);
            String role = "GUEST";

            try (Connection conn = DBContext.getConnection()) {
                // Kiểm tra username đã tồn tại chưa
                String checkUserSql = "SELECT COUNT(*) FROM Users WHERE Username = ?";
                try (PreparedStatement checkPs = conn.prepareStatement(checkUserSql)) {
                    checkPs.setString(1, username);
                    ResultSet rs = checkPs.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
out.println("<script>alert('Username đã tồn tại. Vui lòng chọn username khác.');history.back();</script>");
                        return;
                    }
                }

                // Kiểm tra email đã tồn tại chưa
                String checkEmailSql = "SELECT COUNT(*) FROM Users WHERE Email = ?";
                try (PreparedStatement checkPs = conn.prepareStatement(checkEmailSql)) {
                    checkPs.setString(1, email);
                    ResultSet rs = checkPs.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        out.println("<script>alert('Email đã được sử dụng. Vui lòng sử dụng email khác.');history.back();</script>");
                        return;
                    }
                }

                // Insert user mới
                String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role) " +
                             "VALUES (?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, username);
                    ps.setString(2, hashedPassword);
                    ps.setString(3, fullName);
                    ps.setString(4, email);
                    ps.setString(5, phone);
                    ps.setString(6, role);

                    int rowsInserted = ps.executeUpdate();

                    if (rowsInserted > 0) {
                        out.println("<script>alert('Đăng ký thành công!');window.location='Login.jsp';</script>");
                    } else {
                        out.println("<script>alert('Đăng ký thất bại. Vui lòng thử lại.');history.back();</script>");
                    }
                }

            } catch (SQLException e) {
                if (e.getMessage().contains("UNIQUE") || e.getMessage().contains("duplicate")) {
                    out.println("<script>alert('Username hoặc email đã tồn tại.');history.back();</script>");
                } else {
                    e.printStackTrace();
                    out.println("<script>alert('Lỗi cơ sở dữ liệu. Vui lòng thử lại sau.');history.back();</script>");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.');history.back();</script>");
        }
    }
    
    // Thêm method GET để xử lý khi người dùng truy cập trực tiếp
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Register.jsp");
    }
}
