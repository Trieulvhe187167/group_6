package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;
import java.io.InputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

public class SecureMailUtil {

    private static String SMTP_HOST;
    private static String SMTP_PORT;
    private static String USERNAME;
    private static String PASSWORD;
    
    static {
        // Load email configuration from properties file
        try (InputStream input = SecureMailUtil.class.getClassLoader()
                .getResourceAsStream("email.properties")) {
            
            Properties prop = new Properties();
            if (input != null) {
                prop.load(input);
                SMTP_HOST = prop.getProperty("email.smtp.host");
                SMTP_PORT = prop.getProperty("email.smtp.port");
                USERNAME = prop.getProperty("email.username");
                PASSWORD = prop.getProperty("email.password");
            }
        } catch (IOException e) {
            e.printStackTrace();
            // Fallback to default values
            SMTP_HOST = "smtp.gmail.com";
            SMTP_PORT = "587";
        }
    }

    public static void sendEmail(String to, String subject, String content) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.trust", SMTP_HOST); // Trust the SMTP server
        props.put("mail.smtp.ssl.protocols", "TLSv1.2"); // Use TLS 1.2

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
            
            // Support HTML content
            if (content.contains("<html>")) {
                message.setContent(content, "text/html; charset=UTF-8");
            } else {
                message.setText(content);
            }

            Transport.send(message);
            System.out.println("Email sent successfully to: " + to);
            
        } catch (Exception e) {
            System.err.println("Failed to send email to: " + to);
            throw new MessagingException("Email sending failed", e);
        }
    }
    
    // Overloaded method for sending HTML emails
    public static void sendHtmlEmail(String to, String subject, String htmlContent) throws MessagingException, UnsupportedEncodingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(USERNAME, "Luxury Hotel"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setContent(htmlContent, "text/html; charset=UTF-8");

        Transport.send(message);
    }
}