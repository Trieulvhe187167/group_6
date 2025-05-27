package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.sql.*;
import java.util.regex.Pattern;
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

        String fullName = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");

        try (PrintWriter out = response.getWriter()) {

            if (!isStrongPassword(password)) {
                out.println("<script>alert('Password must be strong (8+ characters, uppercase, lowercase, digit, special char).');history.back();</script>");
                return;
            }

            if (!isValidEmail(email)) {
                out.println("<script>alert('Invalid email format.');history.back();</script>");
                return;
            }

            if (!isValidPhone(phone)) {
                out.println("<script>alert('Phone number must be 10 digits.');history.back();</script>");
                return;
            }

            String hashedPassword = hashPassword(password);
            String username = email; // dùng email làm username
            String role = "GUEST";

            try (Connection conn = DBContext.getConnection()) {
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
                        out.println("<script>alert('Registration successful!');window.location='login.jsp';</script>");
                    } else {
                        out.println("<script>alert('Registration failed.');history.back();</script>");
                    }
                }
            }

        } catch (SQLIntegrityConstraintViolationException e) {
            response.getWriter().println("<script>alert('Username or email already exists.');history.back();</script>");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('Error occurred: " + e.getMessage() + "');history.back();</script>");
        }
    }
}
