package controller;

import dal.ContactMessageDAO;
import model.ContactMessage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "ContactServlet", urlPatterns = {"/ContactServlet"})
public class ContactServlet extends HttpServlet {
    private ContactMessageDAO dao = new ContactMessageDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String message = request.getParameter("message");

        if (name == null || email == null || phone == null || message == null ||
            name.trim().isEmpty() || email.trim().isEmpty() || phone.trim().isEmpty() || message.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/jsp/contact.jsp?error=1#contact");
            return;
        }

        ContactMessage msg = new ContactMessage();
        msg.setName(name.trim());
        msg.setEmail(email.trim());
        msg.setPhone(phone.trim());
        msg.setMessage(message.trim());

        if (dao.addMessage(msg)) {
            response.sendRedirect(request.getContextPath() + "/jsp/contact.jsp?success=1#contact");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/contact.jsp?error=1#contact");
        }
    }
}