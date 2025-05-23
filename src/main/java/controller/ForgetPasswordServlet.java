/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.UUID;

import dal.UserDAO;
import model.User;
import util.MailUtil;

@WebServlet(name="ForgetPasswordServlet", urlPatterns={"/ForgetPasswordServlet"})
public class ForgetPasswordServlet extends HttpServlet {
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ForgetPasswordServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ForgetPasswordServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        //processRequest(request, response);
        String email = request.getParameter("email");
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByEmail(email);

        if (user == null) {
            request.setAttribute("error", "Email không tồn tại!");
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            return;
        }

        // Tạo token reset ngẫu nhiên
        String token = UUID.randomUUID().toString();

        // Cập nhật token vào DB
        boolean updated = userDAO.updateResetToken(user.getId(), token);

        if (updated) {
            // Gửi mail với đường link reset
            String link = "http://localhost:8080/YourProject/reset-password?token=" + token;
            String subject = "Khôi phục mật khẩu";
            String content = "Click vào liên kết sau để đặt lại mật khẩu:\n" + link;

            boolean sent = MailUtil.sendMail(email, subject, content);

            if (sent) {
                request.setAttribute("message", "Email đã được gửi! Hãy kiểm tra hộp thư.");
            } else {
                request.setAttribute("error", "Gửi email thất bại.");
            }
        } else {
            request.setAttribute("error", "Lỗi khi tạo token.");
        }

        request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
