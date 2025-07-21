package model;

import java.sql.Timestamp;

public class ContactMessage {
    private int id;
    private String name;
    private String email;
    private String phone;
    private String message;
    private Timestamp createdAt;
    private Integer feedbackId;

    public ContactMessage() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getFeedbackId() {
        return feedbackId;
    }
    public void setFeedbackId(Integer feedbackId) {
        this.feedbackId = feedbackId;
    }
}
