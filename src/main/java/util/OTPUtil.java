package util;

import java.security.SecureRandom;

public class OTPUtil {
    
    private static final SecureRandom random = new SecureRandom();
    private static final int OTP_LENGTH = 6;
    
    /**
     * Generate a 6-digit OTP
     */
    public static String generateOTP() {
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10));
        }
        return otp.toString();
    }
    
    /**
     * Generate OTP with custom length
     */
    public static String generateOTP(int length) {
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < length; i++) {
            otp.append(random.nextInt(10));
        }
        return otp.toString();
    }
    
    /**
     * Generate alphanumeric OTP
     */
    public static String generateAlphanumericOTP() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(chars.charAt(random.nextInt(chars.length())));
        }
        return otp.toString();
    }
    
    /**
     * Validate OTP format
     */
    public static boolean isValidOTP(String otp) {
        if (otp == null || otp.length() != OTP_LENGTH) {
            return false;
        }
        return otp.matches("\\d{" + OTP_LENGTH + "}");
    }
}