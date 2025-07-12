package controller;

import dal.UserDAO;
import dal.ReservationDAO;
import dal.PaymentDAO;
import dal.FeedbackDAO;
import model.User;
import model.Reservation;
import model.Payment;
import model.Feedback;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerProfileServlet", urlPatterns = {"/customer/profile"})
public class CustomerProfileServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"CUSTOMER".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

         User customer = userDAO.getCustomerByIdWithDetails(user.getId());
        List<Reservation> reservations = reservationDAO.getReservationsByUserId(user.getId());
        List<Payment> payments = paymentDAO.getPaymentsByUserId(user.getId());
        List<Feedback> feedbacks = feedbackDAO.getFeedbacksByUser(user.getId());

        request.setAttribute("customer", customer);
         request.setAttribute("formData", customer); // for form fields
        request.setAttribute("reservations", reservations);
        request.setAttribute("payments", payments);
        request.setAttribute("feedbacks", feedbacks);

        request.getRequestDispatcher("/jsp/customer/profile.jsp").forward(request, response);
    }
}