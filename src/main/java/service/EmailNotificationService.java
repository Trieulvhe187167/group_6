package service;

import util.MailUtil;
import model.*;
import dal.*;
import jakarta.mail.MessagingException;
import java.text.SimpleDateFormat;
import java.text.DecimalFormat;
//import java.sql.Date;
import java.util.List;
import java.util.Date;
public class EmailNotificationService {
    
    private final SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    private final DecimalFormat priceFormat = new DecimalFormat("#,###");
    
    public void sendBookingConfirmation(Reservation reservation, Room room, RoomType roomType) {
        try {
            String subject = "Booking Confirmation - Luxury Hotel #" + reservation.getId();
            String content = buildBookingConfirmationContent(reservation, room, roomType);
            MailUtil.sendEmail(reservation.getCustomerEmail(), subject, content);
        } catch (MessagingException e) {
            e.printStackTrace();
            // Log error but don't throw exception
        }
    }
    
    public void sendCheckInReminder(Reservation reservation) {
        try {
            String subject = "Check-in Reminder - Luxury Hotel";
            String content = buildCheckInReminderContent(reservation);
            MailUtil.sendEmail(reservation.getCustomerEmail(), subject, content);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
    
    public void sendCheckOutReminder(Reservation reservation) {
        try {
            String subject = "Check-out Reminder - Luxury Hotel";
            String content = buildCheckOutReminderContent(reservation);
            MailUtil.sendEmail(reservation.getCustomerEmail(), subject, content);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
    
    public void sendCancellationConfirmation(Reservation reservation) {
        try {
            String subject = "Booking Cancellation - Luxury Hotel #" + reservation.getId();
            String content = buildCancellationContent(reservation);
            MailUtil.sendEmail(reservation.getCustomerEmail(), subject, content);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
    
    public void sendPaymentConfirmation(Reservation reservation, Payment payment) {
        try {
            String subject = "Payment Confirmation - Luxury Hotel #" + reservation.getId();
            String content = buildPaymentConfirmationContent(reservation, payment);
            MailUtil.sendEmail(reservation.getCustomerEmail(), subject, content);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
       
    public void sendGroupBookingPendingEmail(List<Reservation> reservations) {
        if (reservations == null || reservations.isEmpty()) return;

        Reservation first = reservations.get(0);
        try {
            String subject = "Luxury Hotel - Booking Pending";
            String content = buildGroupBookingPendingContent(reservations);
            MailUtil.sendEmail(first.getCustomerEmail(), subject, content);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
    public void sendGroupPaymentConfirmation(List<Reservation> reservations, double totalDeposit,
                                              String method, String transactionId) {
        if (reservations == null || reservations.isEmpty()) {
            return;
        }

        Reservation first = reservations.get(0);
        try {
            String subject = "Payment Confirmation - Luxury Hotel";
            String content = buildGroupPaymentConfirmationContent(reservations, totalDeposit, method, transactionId);
            MailUtil.sendEmail(first.getCustomerEmail(), subject, content);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
    private String buildBookingConfirmationContent(Reservation reservation, Room room, RoomType roomType) {
        StringBuilder content = new StringBuilder();
        
         String name = reservation.getCustomerName();
        if (name == null || name.isEmpty()) {
            name = "Valued Customer";
        }
        content.append("Dear ").append(name).append(",\n\n");
        content.append("Thank you for choosing Luxury Hotel! Your booking has been confirmed.\n\n");
        
        content.append("BOOKING DETAILS\n");
        content.append("================\n");
        content.append("Booking ID: #").append(reservation.getId()).append("\n");
        content.append("Room Type: ").append(roomType.getName()).append("\n");
        content.append("Room Number: ").append(room.getRoomNumber()).append("\n");
        content.append("Check-in: ").append(dateFormat.format(reservation.getCheckIn())).append(" (14:00)\n");
          content.append("Check-out: ").append(dateFormat.format(reservation.getCheckOut())).append(" (11:00 - 13:00)\n");
        content.append("Total Amount: ").append(priceFormat.format(reservation.getTotalAmount())).append("đ\n\n");
        
        content.append("HOTEL INFORMATION\n");
        content.append("================\n");
        content.append("Luxury Hotel\n");
        content.append("Hoa Lac, District 1\n");
        content.append("Ha Noi City, Vietnam\n");
        content.append("Phone: +84 33 3333 xxxx\n");
        content.append("Email: luxuryhotel999@gmail.com\n\n");
        
        content.append("IMPORTANT NOTES\n");
        content.append("================\n");
        content.append("- Please bring a valid ID and this confirmation\n");
          content.append("- Check-in time: 14:00, Check-out time: 11:00 - 13:00\n");
        content.append("- Free cancellation up to 3 days before arrival\n");
        content.append("- For assistance, contact our 24/7 reception\n\n");
        
        content.append("We look forward to welcoming you!\n\n");
        content.append("Best regards,\n");
        content.append("Luxury Hotel Team");
        
        return content.toString();
    }
    
    private String buildCheckInReminderContent(Reservation reservation) {
        StringBuilder content = new StringBuilder();
        
          String name1 = reservation.getCustomerName();
        if (name1 == null || name1.isEmpty()) {
            name1 = "Valued Customer";
        }
        content.append("Dear ").append(name1).append(",\n\n");
        content.append("This is a friendly reminder that your check-in at Luxury Hotel is tomorrow!\n\n");
        
        content.append("CHECK-IN DETAILS\n");
        content.append("================\n");
        content.append("Booking ID: #").append(reservation.getId()).append("\n");
        content.append("Check-in Date: ").append(dateFormat.format(reservation.getCheckIn())).append("\n");
        content.append("Check-in Time: From 14:00\n");
        content.append("Room Number: ").append(reservation.getRoomNumber()).append("\n\n");
        
        content.append("WHAT TO BRING\n");
        content.append("================\n");
        content.append("- Valid identification (Passport/ID Card)\n");
        content.append("- Credit card for incidentals\n");
        content.append("- This booking confirmation\n\n");
        
        content.append("HOTEL LOCATION\n");
        content.append("================\n");
        content.append("Hoa Lac, District 1\n");
        content.append("Ha Noi City, Vietnam\n\n");
        
        content.append("If you need to modify your reservation or have any questions,\n");
        content.append("please contact us at +84 28 3823 xxxx.\n\n");
        
        content.append("We look forward to your arrival!\n\n");
        content.append("Best regards,\n");
        content.append("Luxury Hotel Team");
        
        return content.toString();
    }
    
    private String buildCheckOutReminderContent(Reservation reservation) {
        StringBuilder content = new StringBuilder();
        
        String name1 = reservation.getCustomerName();
        if (name1 == null || name1.isEmpty()) {
            name1 = "Valued Customer";
        }
        content.append("Dear ").append(name1).append(",\n\n");
        content.append("We hope you've enjoyed your stay at Luxury Hotel.\n");
        content.append("This is a reminder that your check-out is scheduled for today.\n\n");
        
        content.append("CHECK-OUT DETAILS\n");
        content.append("================\n");
        content.append("Booking ID: #").append(reservation.getId()).append("\n");
        content.append("Check-out Date: ").append(dateFormat.format(reservation.getCheckOut())).append("\n");
        content.append("Check-out Time: Between 11:00 and 13:00\n");
        content.append("Room Number: ").append(reservation.getRoomNumber()).append("\n\n");
        
        content.append("LATE CHECK-OUT\n");
        content.append("================\n");
        content.append("If you need a late check-out, please contact reception.\n");
        content.append("Additional charges may apply.\n\n");
        
        content.append("Thank you for staying with us!\n");
        content.append("We hope to welcome you again soon.\n\n");
        
        content.append("Best regards,\n");
        content.append("Luxury Hotel Team");
        
        return content.toString();
    }
    
    private String buildCancellationContent(Reservation reservation) {
        StringBuilder content = new StringBuilder();
        
        String name1 = reservation.getCustomerName();
        if (name1 == null || name1.isEmpty()) {
            name1 = "Valued Customer";
        }
        content.append("Dear ").append(name1).append(",\n\n");
        content.append("Your booking at Luxury Hotel has been cancelled.\n\n");
        
        content.append("CANCELLATION DETAILS\n");
        content.append("====================\n");
        content.append("Booking ID: #").append(reservation.getId()).append("\n");
        content.append("Original Check-in: ").append(dateFormat.format(reservation.getCheckIn())).append("\n");
        content.append("Original Check-out: ").append(dateFormat.format(reservation.getCheckOut())).append("\n");
        content.append("Cancellation Date: ").append(dateFormat.format(new Date(System.currentTimeMillis()))).append("\n\n");
        
        content.append("REFUND INFORMATION\n");
        content.append("==================\n");
        content.append("According to our cancellation policy:\n");
        content.append("- Free cancellation up to 3 days before arrival\n");
        content.append("- 50% charge for late cancellations\n\n");
        
        content.append("If you have made a payment, the refund will be processed\n");
        content.append("within 5-7 business days to your original payment method.\n\n");
        
        content.append("We hope to have the opportunity to welcome you in the future.\n\n");
        
        content.append("Best regards,\n");
        content.append("Luxury Hotel Team");
        
        return content.toString();
    }
    
    private String buildPaymentConfirmationContent(Reservation reservation, Payment payment) {
        StringBuilder content = new StringBuilder();
        
        String name1 = reservation.getCustomerName();
        if (name1 == null || name1.isEmpty()) {
            name1 = "Valued Customer";
        }
        content.append("Dear ").append(name1).append(",\n\n");
        content.append("We have successfully received your payment. Thank you!\n\n");
        
        content.append("PAYMENT DETAILS\n");
        content.append("===============\n");
        content.append("Booking ID: #").append(reservation.getId()).append("\n");
        content.append("Transaction ID: ").append(payment.getTransactionId()).append("\n");
        content.append("Amount Paid: ").append(priceFormat.format(payment.getAmount())).append("đ\n");
        content.append("Payment Method: ").append(payment.getMethodDisplayName()).append("\n");
        content.append("Payment Date: ").append(dateFormat.format(new Date(System.currentTimeMillis()))).append("\n\n");
        
        content.append("Your booking is now fully confirmed.\n");
        content.append("We look forward to welcoming you on ").append(dateFormat.format(reservation.getCheckIn())).append(".\n\n");
        
        content.append("Best regards,\n");
        content.append("Luxury Hotel Team");
        
        return content.toString();
    }
    
      private String buildGroupPaymentConfirmationContent(List<Reservation> reservations,
                                                        double totalDeposit,
                                                        String method,
                                                        String transactionId) {
        StringBuilder content = new StringBuilder();
        Reservation first = reservations.get(0);
          String name2 = first.getCustomerName();
        if (name2 == null || name2.isEmpty()) {
            name2 = "Valued Customer";
        }

       content.append("Dear ").append(name2).append(",\n\n");
        content.append("We have successfully received your deposit payment for your booking.\n\n");

        content.append("BOOKING DETAILS\n");
        content.append("===============\n");
        for (Reservation r : reservations) {
              String typeName = r.getRoomTypeName();
            if (typeName == null) typeName = "";
            content.append("- Reservation #").append(r.getId())
                   .append(" - Room ").append(r.getRoomNumber())
                   .append(" (").append(typeName).append(") ")
                   .append(dateFormat.format(r.getCheckIn()))
                   .append(" to ").append(dateFormat.format(r.getCheckOut()))
                   .append(" - ")
                    .append(priceFormat.format(r.getTotalAmount())).append("đ\n");
        }

        content.append("\nPAYMENT INFO\n");
        content.append("============\n");
        content.append("Transaction ID: ").append(transactionId).append("\n");
        content.append("Amount Paid: ").append(priceFormat.format(totalDeposit)).append("đ\n");
        content.append("Payment Method: ").append(getMethodDisplayName(method)).append("\n");
        content.append("Payment Date: ").append(dateFormat.format(new Date(System.currentTimeMillis()))).append("\n\n");

        content.append("Thank you for your trust. We look forward to welcoming you on ")
               .append(dateFormat.format(first.getCheckIn())).append(".\n\n");

        content.append("Best regards,\n");
        content.append("Luxury Hotel Team");

        return content.toString();
    }
 private String buildGroupBookingPendingContent(List<Reservation> reservations) {
        StringBuilder content = new StringBuilder();
        Reservation first = reservations.get(0);
        String name = first.getCustomerName();
        if (name == null || name.isEmpty()) {
            name = "Valued Customer";
        }

        content.append("Dear ").append(name).append(",\n\n");
        content.append("Your booking has been Pending can you payment 10% to confirmed!\n\n");

        content.append("Booking Details:\n");
        for (Reservation r : reservations) {
            String typeName = r.getRoomTypeName();
            if (typeName == null) typeName = "";
            content.append("- Booking ID: #").append(r.getId()).append(" - Room ")
                   .append(r.getRoomNumber()).append(" (")
                   .append(typeName).append(")\n")
                   .append("  Check-in: ").append(dateFormat.format(r.getCheckIn()))
                   .append("\n  Check-out: ").append(dateFormat.format(r.getCheckOut()))
                   .append("\n  Total Amount: ")
                   .append(priceFormat.format(r.getTotalAmount())).append(" VND\n");
        }

        content.append("\nWe look forward to welcoming you!\n\n");
        content.append("Best regards,\n");
        content.append("Luxury Hotel Team");

        return content.toString();
    }
    private String getMethodDisplayName(String method) {
        if (method == null) return "";
        switch (method) {
            case "CREDIT_CARD": return "Credit Card";
            case "BANK_TRANSFER": return "Bank Transfer";
            case "CASH": return "Cash";
            case "VNPay": return "VNPay";
            case "MoMo": return "MoMo";
            default: return method;
        }
    }
}