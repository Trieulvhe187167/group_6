package util;

/**
 * Simple utility class to represent JSON API responses
 */
public class JsonResponse {
    private boolean success;
    private String message;
    private Object data;

    /**
     * Constructor for simple success/failure response with message
     * 
     * @param success whether the operation was successful
     * @param message response message
     */
    public JsonResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    /**
     * Constructor for response with data payload
     * 
     * @param success whether the operation was successful
     * @param message response message
     * @param data additional data payload
     */
    public JsonResponse(boolean success, String message, Object data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }

    // Getters and setters
    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }
} 