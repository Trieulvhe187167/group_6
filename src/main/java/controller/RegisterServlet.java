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

        String username = request.getParameter("username");
        String fullName = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");

        // Giữ lại dữ liệu để hiển thị lại khi lỗi
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
            String role = "GUEST";

            try (Connection conn = DBContext.getConnection()) {
                String checkUserSql = "SELECT COUNT(*) FROM Users WHERE Username = ?";
                try (PreparedStatement checkPs = conn.prepareStatement(checkUserSql)) {
                    checkPs.setString(1, username);
                    ResultSet rs = checkPs.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
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
                        response.sendRedirect("jsp/login.jsp");
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
