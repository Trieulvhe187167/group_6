package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.security.MessageDigest;
import java.sql.*;
import dal.DBContext;
import util.MailUtil;
import util.OTPUtil;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private static final String REGISTER_VIEW = "jsp/Register.jsp";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
       
if ("verify".equals(action)) {
    handleVerification(request, response);
} else if ("resend".equals(action)) {
    resendOTP(request, response); 
} else if ("restart".equals(action)) {
    restartRegistration(request, response);
    
} else {
    handleRegistration(request, response);
}
    }

    private void handleRegistration(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String fullName = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");

        HttpSession session = request.getSession();
        request.setAttribute("username", username);
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);

        // Kiểm tra định dạng
        if (!isValid(username, fullName, email, password, phone, request)) {
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            // Check trùng username/email
            if (isExist(conn, "Username", username)) {
                request.setAttribute("errorMsg", "Username already exists.");
                request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
                return;
            }
            if (isExist(conn, "Email", email)) {
                request.setAttribute("errorMsg", "Email is already in use.");
                request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
                return;
            }

            // Gửi mã OTP và lưu thông tin tạm
            String otp = OTPUtil.generateOTP();
            session.setAttribute("otp", otp);
            session.setAttribute("username", username);
            session.setAttribute("fullName", fullName);
            session.setAttribute("email", email);
            session.setAttribute("password", password); // lưu plain để login tự động
            session.setAttribute("phone", phone);

            MailUtil.sendEmail(email, "Email Verification", "Your verification code is: " + otp);
            session.setAttribute("otpStep", true); // bật trạng thái hiển thị form nhập mã OTP
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "Unexpected error. Please try again.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
        }
    }

    private void handleVerification(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String inputOtp = request.getParameter("code");
        HttpSession session = request.getSession();
        String sessionOtp = (String) session.getAttribute("otp");

        if (!OTPUtil.isValidOTP(inputOtp) || !inputOtp.equals(sessionOtp)) {
            
            request.setAttribute("error", "Invalid OTP code.");
            request.setAttribute("otpStep", true);
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role) VALUES (?, ?, ?, ?, ?, 'CUSTOMER')";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, (String) session.getAttribute("username"));
                ps.setString(2, hashPassword((String) session.getAttribute("password")));
                ps.setString(3, (String) session.getAttribute("fullName"));
                ps.setString(4, (String) session.getAttribute("email"));
                ps.setString(5, (String) session.getAttribute("phone"));
                ps.executeUpdate();
            }

            // Chuyển đến login và tự động điền thông tin
            String username = (String) session.getAttribute("username");
            String password = (String) session.getAttribute("password");
            session.invalidate();
            response.sendRedirect("jsp/login.jsp?username=" + username 
                    + "&password=" + password 
                    + "&success=1&loginSuccess=1");


        } catch (Exception e) {
            e.printStackTrace();
           request.setAttribute("error", "Failed to create account. Try again.");
           request.setAttribute("otpStep", true);
           request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
        }
    }
private void restartRegistration(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    HttpSession session = request.getSession();

    // Lưu thông tin nhập trước đó vào request
    request.setAttribute("username", session.getAttribute("username"));
    request.setAttribute("fullName", session.getAttribute("fullName"));
    request.setAttribute("email", session.getAttribute("email"));
    request.setAttribute("phone", session.getAttribute("phone"));

    // Xoá dữ liệu tạm thời trong session (bao gồm OTP và password)
    session.removeAttribute("otpStep");
    session.removeAttribute("username");
    session.removeAttribute("fullName");
    session.removeAttribute("email");
    session.removeAttribute("password");
    session.removeAttribute("phone");

    request.setAttribute("info", "You can continue your registration.");
    request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
}

    private boolean isExist(Connection conn, String field, String value) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE " + field + " = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            return ps.executeQuery().next();
        }
    }

    private boolean isValid(String username, String fullName, String email, String password, String phone, HttpServletRequest req) {
        if (username == null || username.trim().length() < 3 || !username.matches("^[a-zA-Z0-9_]+$")) {
            req.setAttribute("errorMsg", "Invalid username.");
            return false;
        }
        if (fullName == null || !fullName.matches("^[a-zA-ZÀ-ỹĐđ\\s]{2,}$")) {
            req.setAttribute("errorMsg", "Invalid full name.");
            return false;
        }
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            req.setAttribute("errorMsg", "Invalid email.");
            return false;
        }
        if (phone == null || !phone.matches("^\\d{10}$")) {
            req.setAttribute("errorMsg", "Phone must be 10 digits.");
            return false;
        }
        if (password == null || !password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$")) {
            req.setAttribute("errorMsg", "Weak password.");
            return false;
        }
        return true;
    }

    private String hashPassword(String password) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hashBytes = md.digest(password.getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : hashBytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }
private void resendOTP(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    HttpSession session = request.getSession();
    String email = (String) session.getAttribute("email");

    if (email == null) {
        response.sendRedirect("jsp/Register.jsp");
        return;
    }

    String otp = OTPUtil.generateOTP();
    session.setAttribute("otp", otp);
    try {
        MailUtil.sendEmail(email, "Resent Email Verification", "Your new OTP is: " + otp);
        request.setAttribute("info", "A new OTP has been sent to your email.");
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Failed to resend OTP.");
    }

    session.setAttribute("otpStep", true);
    request.getRequestDispatcher("jsp/Register.jsp").forward(request, response);
}

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect("jsp/Register.jsp");
    }
}
