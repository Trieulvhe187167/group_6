package service;

import dal.CustomerDAO;
import model.Customer;
import util.MailUtil;
import jakarta.mail.MessagingException;
import java.util.List;
import java.text.DecimalFormat;

public class GuestMarketingService {
    
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final DecimalFormat priceFormat = new DecimalFormat("#,###");
    
    /**
     * Send targeted marketing emails to eligible guest customers
     */
    public void sendUpgradeOffers() {
        List<Customer> eligibleGuests = customerDAO.getEligibleGuestCustomers();
        
        for (Customer guest : eligibleGuests) {
            try {
                if (guest.getTotalSpent() > 20000000) {
                    sendVIPUpgradeOffer(guest);
                } else if (guest.getBookingCount() >= 3) {
                    sendFrequentGuestOffer(guest);
                } else {
                    sendStandardUpgradeOffer(guest);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private void sendVIPUpgradeOffer(Customer guest) throws MessagingException {
        String subject = "Exclusive VIP Membership Invitation - Luxury Hotel";
        
        String content = String.format(
            "Dear %s,\n\n" +
            "As one of our most valued guests with a total spending of %s₫, " +
            "we're delighted to invite you to join our exclusive VIP membership program.\n\n" +
            "VIP BENEFITS:\n" +
            "✓ 25%% discount on all room bookings\n" +
            "✓ Complimentary room upgrades (guaranteed)\n" +
            "✓ Free airport transfers\n" +
            "✓ Access to Executive Lounge\n" +
            "✓ Personal concierge service\n" +
            "✓ Priority reservations at our restaurants\n\n" +
            "Complete your registration now and receive 5,000 bonus points!\n\n" +
            "Click here to activate your VIP membership:\n" +
            "http://localhost:8080/hotel/complete-registration?token=%s&type=vip\n\n" +
            "This exclusive offer is valid for 7 days only.\n\n" +
            "We look forward to welcoming you as our VIP member!\n\n" +
            "Best regards,\n" +
            "Luxury Hotel VIP Team",
            guest.getFullName(),
            priceFormat.format(guest.getTotalSpent()),
            generateUpgradeToken(guest.getId())
        );
        
        MailUtil.sendEmail(guest.getEmail(), subject, content);
    }
    
    private void sendFrequentGuestOffer(Customer guest) throws MessagingException {
        String subject = "Special Offer for Our Frequent Guest - Luxury Hotel";
        
        String content = String.format(
            "Dear %s,\n\n" +
            "Thank you for choosing Luxury Hotel for your %d stays with us!\n\n" +
            "As a frequent guest, we'd like to offer you special membership benefits:\n\n" +
            "GOLD MEMBERSHIP BENEFITS:\n" +
            "✓ 15%% discount on all bookings\n" +
            "✓ Free room upgrades (subject to availability)\n" +
            "✓ Late check-out until 2 PM\n" +
            "✓ Welcome drink on arrival\n" +
            "✓ Double loyalty points\n\n" +
            "Complete your registration and get 2,000 bonus points:\n" +
            "http://localhost:8080/hotel/complete-registration?token=%s&type=gold\n\n" +
            "Join today and save on your next stay!\n\n" +
            "Best regards,\n" +
            "Luxury Hotel Team",
            guest.getFullName(),
            guest.getBookingCount(),
            generateUpgradeToken(guest.getId())
        );
        
        MailUtil.sendEmail(guest.getEmail(), subject, content);
    }
    
    private void sendStandardUpgradeOffer(Customer guest) throws MessagingException {
        String subject = "Unlock Member Benefits - Luxury Hotel";
        
        String content = String.format(
            "Dear %s,\n\n" +
            "Thank you for staying with Luxury Hotel!\n\n" +
            "Did you know that as a member, you can enjoy:\n\n" +
            "MEMBER BENEFITS:\n" +
            "✓ 10%% discount on all bookings\n" +
            "✓ Earn points for free nights\n" +
            "✓ Early check-in (subject to availability)\n" +
            "✓ Exclusive member-only rates\n" +
            "✓ Birthday special offers\n\n" +
            "Complete your free registration in just 2 minutes:\n" +
            "http://localhost:8080/hotel/complete-registration?token=%s\n\n" +
            "Plus, get 1,000 welcome points when you join today!\n\n" +
            "We hope to see you again soon!\n\n" +
            "Best regards,\n" +
            "Luxury Hotel Team",
            guest.getFullName(),
            generateUpgradeToken(guest.getId())
        );
        
        MailUtil.sendEmail(guest.getEmail(), subject, content);
    }
    
    /**
     * Send re-engagement email to inactive guests
     */
    public void sendReEngagementCampaign() {
        String sql = "SELECT * FROM vw_Customers WHERE IsGuest = 1 " +
                    "AND DATEDIFF(day, LastVisit, GETDATE()) > 90";
        
        // Implementation for re-engagement campaign
    }
    
    private String generateUpgradeToken(int userId) {
        return java.util.Base64.getEncoder().encodeToString(
            (userId + ":" + System.currentTimeMillis() + ":upgrade").getBytes()
        );
    }
}