package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
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

    private boolean isValidUsername(String username) {
        return username != null &&
               username.length() >= 3 &&
               !username.contains(" ") &&
               username.matches("^[a-zA-Z0-9_]+$");
    }

    private boolean isValidFullName(String fullName) {
        return fullName != null &&
               fullName.trim().length() >= 2 &&
               fullName.matches("^[a-zA-ZÀ-ỹĐđ\\s]+$") &&
               !fullName.matches("^\\s+$");
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

        request.setAttribute("username", username);
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);

        if (username == null || fullName == null || email == null ||
            password == null || phone == null) {
            request.setAttribute("errorMsg", "Please fill in all fields.");
            request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
            return;
        }

        username = username.trim();
        fullName = fullName.trim();
        email = email.trim();
        phone = phone.trim();

        if (username.isEmpty() || fullName.isEmpty() || email.isEmpty() ||
            password.isEmpty() || phone.isEmpty()) {
            request.setAttribute("errorMsg", "Fields cannot be empty or contain only spaces.");
            request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
            return;
        }

        if (!isValidUsername(username)) {
            request.setAttribute("errorMsg", "Username must be at least 3 characters, no spaces, only letters, numbers, and underscores.");
            request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
            return;
        }

        if (!isValidFullName(fullName)) {
            request.setAttribute("errorMsg", "Full name is invalid. Please enter your real name.");
            request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
            return;
        }

        if (!isValidEmail(email)) {
            request.setAttribute("errorMsg", "Invalid email address.");
            request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
            return;
        }


        if (!isValidPhone(phone)) {
            request.setAttribute("errorMsg", "Phone number must be exactly 10 digits.");
            request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
            return;
        }

        if (!isStrongPassword(password)) {
            request.setAttribute("errorMsg", "Password must be at least 8 characters, include uppercase, lowercase, number, and special character.");
            request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
            return;
        }

        try {
            String hashedPassword = hashPassword(password);
            String role = "CUSTOMER";

            try (Connection conn = DBContext.getConnection()) {
                // Kiểm tra username đã tồn tại chưa

              

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

                        request.setAttribute("errorMsg", "Username already exists. Please choose another one.");
                        request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
                        return;
                    }
                }

                String checkEmailSql = "SELECT COUNT(*) FROM Users WHERE Email = ?";
                try (PreparedStatement checkPs = conn.prepareStatement(checkEmailSql)) {
                    checkPs.setString(1, email);
                    ResultSet rs = checkPs.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        request.setAttribute("errorMsg", "Email is already in use. Please use a different email.");
                        request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
                        return;
                    }
                }

                String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, username);
                    ps.setString(2, hashedPassword);
                    ps.setString(3, fullName);
                    ps.setString(4, email);
                    ps.setString(5, phone);
                    ps.setString(6, role);

                    int rowsInserted = ps.executeUpdate();
                    if (rowsInserted > 0) {

                        // ✅ Chuyển hướng về trang đăng nhập với param thông báo thành công
                        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp?success=1");
                    } else {
                        request.setAttribute("errorMsg", "Registration failed. Please try again.");
                        request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
                    }
                }

            } catch (SQLException e) {

                e.printStackTrace();
                request.setAttribute("errorMsg", "Database error. Please try again later.");
                request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);

            }

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("errorMsg", "Unexpected error occurred. Please try again.");
            request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("jsp/Register.jsp");
    }
}

