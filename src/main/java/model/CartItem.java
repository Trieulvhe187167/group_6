package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class CartItem implements Serializable {
    private int roomTypeId;
    private String roomTypeName;
    private BigDecimal price;
    private String checkIn;
    private String checkOut;
    private int quantity;
    private List<Integer> roomIds = new ArrayList<>();
    private long holdUntil;
    private int adults;
    private int children;
    private int capacity;

    public CartItem(int roomTypeId, String roomTypeName, BigDecimal price, String checkIn,
                    String checkOut, int quantity, List<Integer> roomIds, long holdUntil,
                    int adults, int children, int capacity) {
        this.roomTypeId = roomTypeId;
        this.roomTypeName = roomTypeName;
        this.price = price;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.quantity = quantity;
        if (roomIds != null) {
            this.roomIds.addAll(roomIds);
        }
        this.holdUntil = holdUntil;
        this.adults = adults;
        this.children = children;
        this.capacity = capacity;
    }

    public CartItem() {}

    public int getRoomTypeId() {
        return roomTypeId;
    }

    public void setRoomTypeId(int roomTypeId) {
        this.roomTypeId = roomTypeId;
    }

    public String getRoomTypeName() {
        return roomTypeName;
    }

    public void setRoomTypeName(String roomTypeName) {
        this.roomTypeName = roomTypeName;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(String checkIn) {
        this.checkIn = checkIn;
    }

    public String getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(String checkOut) {
        this.checkOut = checkOut;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public List<Integer> getRoomIds() {
        return roomIds;
    }

    public void setRoomIds(List<Integer> roomIds) {
        this.roomIds = roomIds;
    }

    public long getHoldUntil() {
        return holdUntil;
    }

    public void setHoldUntil(long holdUntil) {
        this.holdUntil = holdUntil;
    }

    public int getAdults() {
        return adults;
    }

    public void setAdults(int adults) {
        this.adults = adults;
    }

    public int getChildren() {
        return children;
    }

    public void setChildren(int children) {
        this.children = children;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }
}