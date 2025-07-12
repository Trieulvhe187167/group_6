package controller;

import dal.UserDAO;
import service.VerificationService;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import util.UserUtils;

@WebServlet(name="UpdateProfileServlet", urlPatterns={"/customer/update-profile"})
public class UpdateProfileServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final VerificationService verificationService = new VerificationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        session.removeAttribute("success");
        session.removeAttribute("error");
        User user = (User) session.getAttribute("user");
        if (user == null || !"CUSTOMER".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
          User existing = userDAO.getCustomerByIdWithDetails(user.getId());
          
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String country = request.getParameter("country");

         String error = validateInput(fullName, email, phone, gender, address, city);
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("customer", existing);
            dal.ReservationDAO rDao = new dal.ReservationDAO();
            dal.PaymentDAO pDao = new dal.PaymentDAO();
            dal.FeedbackDAO fDao = new dal.FeedbackDAO();
            request.setAttribute("reservations", rDao.getReservationsByUserId(user.getId()));
            request.setAttribute("payments", pDao.getPaymentsByUserId(user.getId()));
            request.setAttribute("feedbacks", fDao.getFeedbacksByUser(user.getId()));
             User form = new User();
            form.setFullName(fullName);
            form.setEmail(email);
            form.setPhone(phone);
            form.setGender(gender);
            form.setAddress(address);
            form.setCity(city);
            form.setCountry(country);
            if (dateOfBirthStr != null && !dateOfBirthStr.isEmpty()) {
                try {
                   form.setDateOfBirth(Date.valueOf(dateOfBirthStr));
                } catch (IllegalArgumentException ignore) {
                }
            }
             request.setAttribute("formData", form);
            request.getRequestDispatcher("/jsp/customer/profile.jsp").forward(request, response);
            return;
        }


        boolean updatedBasic = false;
        boolean updatedDetails = false;

        if (fullName != null && !fullName.equals(existing.getFullName())) {
            existing.setFullName(fullName.trim());
            updatedBasic = true;
        }
        if (phone != null && !phone.equals(existing.getPhone())) {
            existing.setPhone(phone.trim());
            updatedBasic = true;
        }

        // handle details
        if (address != null && !address.equals(existing.getAddress())) {
            existing.setAddress(address.trim());
            updatedDetails = true;
        }
        if (city != null && !city.equals(existing.getCity())) {
            existing.setCity(city.trim());
            updatedDetails = true;
        }
        if (country != null && !country.equals(existing.getCountry())) {
            existing.setCountry(country.trim());
            updatedDetails = true;
        }
        if (gender != null && !gender.isEmpty() && !gender.equals(existing.getGender())) {
            existing.setGender(gender.trim());
            updatedDetails = true;
        } else if ((gender == null || gender.isEmpty()) && existing.getGender() != null) {
            existing.setGender(null);
            updatedDetails = true;
        }
        if (dateOfBirthStr != null && !dateOfBirthStr.isEmpty()) {
            try {
                Date dob = Date.valueOf(dateOfBirthStr);
                if (existing.getDateOfBirth() == null || !dob.equals(existing.getDateOfBirth())) {
                    existing.setDateOfBirth(dob);
                    updatedDetails = true;
                }
            } catch (IllegalArgumentException e) {
                // ignore invalid date
            }
        } else if (existing.getDateOfBirth() != null) {
            existing.setDateOfBirth(null);
            updatedDetails = true;
        }

        // email change with verification
        if (!email.equals(existing.getEmail())) {
            if (userDAO.isEmailExists(email, existing.getId())) {
                session.setAttribute("error", "Email already exists.");
            } else {
                boolean sent = verificationService.requestEmailChange(existing.getId(), email, existing.getId(), "User requested email change");
                if (sent) {
                    session.setAttribute("success", "Verification email sent. Please check your inbox.");
                } else {
                    session.setAttribute("error", "Failed to send verification email.");
                }
            }
        }

        if (updatedBasic) {
            existing.setEmail(existing.getEmail()); // keep old email
            existing.setRole("CUSTOMER");
            userDAO.updateUser(existing);
        }
        if (updatedDetails) {
            if (!userDAO.hasCustomerDetails(existing.getId())) {
                userDAO.createCustomerDetailsIfNotExists(existing.getId());
            }
            userDAO.updateCustomerDetails(existing);
        }

        if (session.getAttribute("error")==null) {
            session.setAttribute("success", "Profile updated successfully.");
        }
        response.sendRedirect(request.getContextPath() + "/customer/profile");
    }

    private void loadProfileData(HttpServletRequest request, int userId) {
        UserDAO uDao = new UserDAO();
        dal.ReservationDAO rDao = new dal.ReservationDAO();
        dal.PaymentDAO pDao = new dal.PaymentDAO();
        dal.FeedbackDAO fDao = new dal.FeedbackDAO();
        User customer = uDao.getCustomerByIdWithDetails(userId);
         request.setAttribute("customer", customer); // data from DB for overview
        request.setAttribute("formData", customer); // default form values
        request.setAttribute("reservations", rDao.getReservationsByUserId(userId));
        request.setAttribute("payments", pDao.getPaymentsByUserId(userId));
        request.setAttribute("feedbacks", fDao.getFeedbacksByUser(userId));
    }

        private String validateInput(String fullName, String email, String phone, String gender, String address, String city) {
        if (fullName == null || fullName.trim().isEmpty() || fullName.length() > 30) {
            return "Full name is required.";
        }
         if (email == null || email.isEmpty() || !UserUtils.isValidEmail(email)) {
            return "Invalid email address.";
        }
      if (phone == null || phone.isEmpty() || !UserUtils.isValidPhone(phone)) {
            return "Phone number must start with 0 and be exactly 10 digits.";
        }
        if (gender != null && !gender.isEmpty() && !gender.matches("MALE|FEMALE|OTHER")) {
            return "Gender must be MALE, FEMALE or OTHER.";
        }
          if (address != null && address.length() > 30) {
            return "Address must be less than 30 characters.";
        }
        if (city != null && city.length() > 30) {
            return "City must be less than 30 characters.";
        }
        return null;
    }
}