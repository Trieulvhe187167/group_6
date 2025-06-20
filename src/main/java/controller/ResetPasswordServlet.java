package controller;

import dal.PasswordResetDAO;
import util.HashUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        PasswordResetDAO dao = new PasswordResetDAO();

        if (dao.isValidToken(token)) {
            request.setAttribute("token", token);
            request.getRequestDispatcher("jsp/resetPassword.jsp").forward(request, response);
        } else {
            response.sendRedirect("jsp/forgotPassword.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        String newPassword = request.getParameter("password");

        PasswordResetDAO dao = new PasswordResetDAO();

        if (dao.isValidToken(token)) {
            String hashed = HashUtil.hashPassword(newPassword);
            boolean success = dao.updatePassword(token, hashed);
            dao.deleteToken(token);

            if (success) {
                request.setAttribute("msg", "Your password has been reset successfully!");
                request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
                return;
            }
        }

        request.setAttribute("msg", "The reset link is invalid or has expired.");
        request.getRequestDispatcher("jsp/resetPassword.jsp").forward(request, response);
    }
}
