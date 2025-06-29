package util;

import model.User;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.regex.Pattern;

/**
 * Utility class for User-related operations
 */
public class UserUtils {
    
    // Validation patterns
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{3,20}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0\\d{9}$");
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$");
    
    // Date formatters
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy");
    private static final SimpleDateFormat DATETIME_FORMAT = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    private static final SimpleDateFormat TIME_FORMAT = new SimpleDateFormat("HH:mm");
    
    // Private constructor to prevent instantiation
    private UserUtils() {}
    
    /**
     * Hash password using SHA-256
     */
    public static String hashPassword(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty");
        }
        
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
    
    /**
     * Validate username format
     */
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username).matches();
    }
    
    /**
     * Validate email format
     */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }
    
    /**
     * Validate phone format (Vietnam)
     */
    public static boolean isValidPhone(String phone) {
        return phone == null || phone.isEmpty() || PHONE_PATTERN.matcher(phone).matches();
    }
    
    /**
     * Validate password strength
     */
    public static boolean isValidPassword(String password) {
        return password != null && PASSWORD_PATTERN.matcher(password).matches();
    }
    
    /**
     * Validate user for creation
     */
    public static String validateNewUser(User user) {
        if (user == null) return "User data is required";
        
        // Username validation
        if (!isValidUsername(user.getUsername())) {
            return "Username must be 3-20 characters and contain only letters, numbers, and underscores";
        }
        
        // Password validation (only for new users)
        if (user.getPassword() == null || user.getPassword().isEmpty()) {
            return "Password is required";
        }
        if (!isValidPassword(user.getPassword())) {
            return "Password must be at least 8 characters with uppercase, lowercase, digit, and special character";
        }
        
        // Email validation
        if (!isValidEmail(user.getEmail())) {
            return "Please enter a valid email address";
        }
        
        // Phone validation
        if (!isValidPhone(user.getPhone())) {
            return "Phone number must start with 0 and be exactly 10 digits";
        }
        
        // Full name validation
        if (user.getFullName() == null || user.getFullName().trim().isEmpty()) {
            return "Full name is required";
        }
        
        // Role validation
        if (user.getRole() == null || user.getRole().trim().isEmpty()) {
            return "Role is required";
        }
        
        // Age validation for customers
        if (user.isCustomer() && user.getDateOfBirth() != null && !isAdult(user.getDateOfBirth())) {
            return "Customer must be at least 18 years old";
        }
        
        return null; // No validation errors
    }
    
    /**
     * Validate user for update
     */
    public static String validateUpdateUser(User user) {
        if (user == null) return "User data is required";
        
        // Email validation
        if (!isValidEmail(user.getEmail())) {
            return "Please enter a valid email address";
        }
        
        // Phone validation
        if (!isValidPhone(user.getPhone())) {
            return "Phone number must start with 0 and be exactly 10 digits";
        }
        
        // Full name validation
        if (user.getFullName() == null || user.getFullName().trim().isEmpty()) {
            return "Full name is required";
        }
        
        // Age validation for customers
        if (user.isCustomer() && user.getDateOfBirth() != null && !isAdult(user.getDateOfBirth())) {
            return "Customer must be at least 18 years old";
        }
        
        return null; // No validation errors
    }
    
    /**
     * Check if a date of birth represents an adult (18+)
     */
    public static boolean isAdult(Date dateOfBirth) {
        if (dateOfBirth == null) return true; // Assume adult if no DOB provided
        
        long ageInMillis = System.currentTimeMillis() - dateOfBirth.getTime();
        long ageInYears = ageInMillis / (365L * 24 * 60 * 60 * 1000);
        return ageInYears >= 18;
    }
    
    /**
     * Calculate age from date of birth
     */
    public static int calculateAge(Date dateOfBirth) {
        if (dateOfBirth == null) return 0;
        
        long ageInMillis = System.currentTimeMillis() - dateOfBirth.getTime();
        return (int) (ageInMillis / (365L * 24 * 60 * 60 * 1000));
    }
    
    /**
     * Calculate years of service from hire date
     */
    public static int calculateYearsOfService(Date hireDate) {
        if (hireDate == null) return 0;
        
        long serviceInMillis = System.currentTimeMillis() - hireDate.getTime();
        return (int) (serviceInMillis / (365L * 24 * 60 * 60 * 1000));
    }
    
    /**
     * Format date to string
     */
    public static String formatDate(Date date) {
        if (date == null) return "";
        return DATE_FORMAT.format(date);
    }
    
    /**
     * Format datetime to string
     */
    public static String formatDateTime(Date date) {
        if (date == null) return "";
        return DATETIME_FORMAT.format(date);
    }
    
    /**
     * Format time to string
     */
    public static String formatTime(Date date) {
        if (date == null) return "";
        return TIME_FORMAT.format(date);
    }
    
    /**
     * Format currency (VND)
     */
    public static String formatCurrency(double amount) {
        return String.format("%,.0f₫", amount);
    }
    
    /**
     * Generate random password
     */
    public static String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%^&+=!";
        StringBuilder password = new StringBuilder();
        java.util.Random random = new java.util.Random();
        
        // Ensure at least one of each required type
        password.append(chars.charAt(random.nextInt(26))); // Uppercase
        password.append(chars.charAt(26 + random.nextInt(26))); // Lowercase
        password.append(chars.charAt(52 + random.nextInt(10))); // Digit
        password.append(chars.charAt(62 + random.nextInt(9))); // Special
        
        // Fill the rest randomly
        for (int i = 4; i < 12; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        // Shuffle the password
        return shuffleString(password.toString());
    }
    
    /**
     * Shuffle a string
     */
    private static String shuffleString(String input) {
        char[] chars = input.toCharArray();
        java.util.Random random = new java.util.Random();
        
        for (int i = chars.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = chars[i];
            chars[i] = chars[j];
            chars[j] = temp;
        }
        
        return new String(chars);
    }
    
    /**
     * Get membership level based on loyalty points
     */
    public static String calculateMembershipLevel(int loyaltyPoints) {
        if (loyaltyPoints >= 10000) return "PLATINUM";
        else if (loyaltyPoints >= 5000) return "GOLD";
        else if (loyaltyPoints >= 1000) return "SILVER";
        else return "BRONZE";
    }
    
    /**
     * Check if user should be VIP
     */
    public static boolean shouldBeVIP(User user) {
        if (user == null || !user.isCustomer()) return false;
        
        return user.isVIP() || 
               "PLATINUM".equals(user.getMembershipLevel()) || 
               user.getTotalSpent() > 50000000 || 
               user.getTotalBookings() >= 10;
    }
    
    /**
     * Generate avatar text from name
     */
    public static String getAvatarText(String fullName) {
        if (fullName == null || fullName.trim().isEmpty()) return "U";
        
        String[] parts = fullName.trim().split("\\s+");
        if (parts.length >= 2) {
            // Return first letter of first name and last name
            return parts[0].substring(0, 1).toUpperCase() + 
                   parts[parts.length - 1].substring(0, 1).toUpperCase();
        } else {
            // Return first two letters of single name
            return fullName.length() >= 2 ? 
                   fullName.substring(0, 2).toUpperCase() : 
                   fullName.substring(0, 1).toUpperCase();
        }
    }
    
    /**
     * Mask email for privacy
     */
    public static String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        
        String[] parts = email.split("@");
        String name = parts[0];
        String domain = parts[1];
        
        if (name.length() <= 3) {
            return name.charAt(0) + "***@" + domain;
        } else {
            return name.substring(0, 3) + "***@" + domain;
        }
    }
    
    /**
     * Mask phone number for privacy
     */
    public static String maskPhone(String phone) {
        if (phone == null || phone.length() < 10) return phone;
        
        return phone.substring(0, 4) + "****" + phone.substring(phone.length() - 2);
    }
    
    /**
     * Check if user profile is complete
     */
    public static boolean isProfileComplete(User user) {
        if (user == null) return false;
        
        // Basic fields
        if (user.getFullName() == null || user.getFullName().trim().isEmpty() ||
            user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            return false;
        }
        
        // Role-specific requirements
        if (user.isCustomer()) {
            return user.getIdType() != null && 
                   user.getIdNumber() != null && !user.getIdNumber().trim().isEmpty();
        } else if (user.isEmployee()) {
            return user.getDepartment() != null && !user.getDepartment().trim().isEmpty();
        }
        
        return true;
    }
}