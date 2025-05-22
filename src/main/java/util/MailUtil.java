/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;


/**
 *
 * @author ASUS
 */
public class MailUtil {
    public static boolean sendMail(String toEmail, String subject, String content) {
        final String fromEmail = "your-mailtrap-username@example.com"; // Địa chỉ mail gửi
        final String password = "your-mailtrap-password"; // Password mail
        final String host = "smtp.mailtrap.io";
        final int port = 587; // Hoặc 2525 tùy cấu hình mailtrap

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true"); 
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", String.valueOf(port));

        Session session = Session.getInstance(props,
            new jakarta.mail.Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(fromEmail, password);
                }
            });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail, "Hotel Support"));
            message.setRecipients(
                    Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(content);

            Transport.send(message);
            return true;
        } catch (Exception e) {
            e.printStackTrace(); // In lỗi gửi mail nếu cần debug
            return false;
        }
    }
}
