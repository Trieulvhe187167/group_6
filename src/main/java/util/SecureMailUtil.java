package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;
import java.io.UnsupportedEncodingException;

public class SecureMailUtil {

    // 🔥 THÊM TRỰC TIẾP THÔNG TIN EMAIL
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String USERNAME = "luxuryhotel999@gmail.com"; // Email của bạn
    private static final String PASSWORD = "pzpz xjld nsdg hfsf";     // App password
    
    public static void sendEmail(String to, String subject, String content) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.trust", SMTP_HOST);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, "Luxury Hotel"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            
            // 🔥 FIX: Kiểm tra HTML một cách chính xác hơn
            if (content.toLowerCase().contains("<!doctype html>") || 
                content.toLowerCase().contains("<html") || 
                content.contains("text/html")) {
                // Gửi dưới dạng HTML
                message.setContent(content, "text/html; charset=UTF-8");
                System.out.println("Sending email as HTML to: " + to);
            } else {
                // Gửi dưới dạng plain text
                message.setText(content);
                System.out.println("Sending email as plain text to: " + to);
            }

            Transport.send(message);
            System.out.println("Email sent successfully to: " + to);
            
        } catch (Exception e) {
            System.err.println("Failed to send email to: " + to);
            e.printStackTrace();
            throw new MessagingException("Email sending failed", e);
        }
    }
    
    public static void sendHtmlEmail(String to, String subject, String htmlContent) 
            throws MessagingException, UnsupportedEncodingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.trust", SMTP_HOST);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, "Luxury Hotel"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            
            // 🔥 LUÔN GỬI DƯỚI DẠNG HTML KHI GỌI sendHtmlEmail
            message.setContent(htmlContent, "text/html; charset=UTF-8");
            
            Transport.send(message);
            System.out.println("HTML Email sent successfully to: " + to);
            
        } catch (Exception e) {
            System.err.println("Failed to send HTML email to: " + to);
            e.printStackTrace();
            throw new MessagingException("HTML Email sending failed", e);
        }
    }
}