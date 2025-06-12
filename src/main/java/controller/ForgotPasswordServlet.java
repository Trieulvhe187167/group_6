package controller;

import dal.PasswordResetDAO;
import jakarta.mail.MessagingException;
import model.User;
import util.MailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");

        PasswordResetDAO dao = new PasswordResetDAO();
        User user = dao.findUserByEmail(email);

        if (user != null) {
            try {
                String token = dao.createResetToken(user.getId());

                // ✅ Tạo link chính xác đến servlet reset-password
                String contextPath = request.getContextPath(); // Ví dụ: /HotelManagementSystemApplication
                String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                        + contextPath + "/reset-password?token=" + token;

                String subject = "Change your password";
                String content = "Hello " + user.getFullName() + ",\n\n"
                        + "You have requested a password reset. Click the link below to change your password.:\n"
                        + resetLink + "\n\n"
                        + "Link will expire in 1 hour.\n\n"
                        + "If you did not request this, please ignore this email..";

                MailUtil.sendEmail(email, subject, content);
                request.setAttribute("msg", "Mail sended!");
            } catch (MessagingException ex) {
                Logger.getLogger(ForgotPasswordServlet.class.getName()).log(Level.SEVERE, null, ex);
                request.setAttribute("msg", "Email sending failed. Please try again later..");
            }
        } else {
            request.setAttribute("msg", "Email not found in system!");
        }

        request.getRequestDispatcher("jsp/forgotPassword.jsp").forward(request, response);
    }
}
