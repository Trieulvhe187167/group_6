package model;

import java.util.List;

public class DashboardStats {
    private int totalCustomers;
    private int availableRooms;
    private int occupiedRooms;
    private int maintenanceRooms;
    private int totalRooms;
    private int todayCheckIns;
    private double monthlyRevenue;
    private double yearlyRevenue;
    private List<ReservationSummary> recentReservations;
    
    // Constructors
    public DashboardStats() {}
    
    // Getters and Setters
    public int getTotalCustomers() {
        return totalCustomers;
    }
    
    public void setTotalCustomers(int totalCustomers) {
        this.totalCustomers = totalCustomers;
    }
    
    public int getAvailableRooms() {
        return availableRooms;
    }
    
    public void setAvailableRooms(int availableRooms) {
        this.availableRooms = availableRooms;
    }
    
    public int getOccupiedRooms() {
        return occupiedRooms;
    }
    
    public void setOccupiedRooms(int occupiedRooms) {
        this.occupiedRooms = occupiedRooms;
    }
    
    public int getMaintenanceRooms() {
        return maintenanceRooms;
    }
    
    public void setMaintenanceRooms(int maintenanceRooms) {
        this.maintenanceRooms = maintenanceRooms;
    }
    
    public int getTotalRooms() {
        return totalRooms;
    }
    
    public void setTotalRooms(int totalRooms) {
        this.totalRooms = totalRooms;
    }
    
    public int getTodayCheckIns() {
        return todayCheckIns;
    }
    
    public void setTodayCheckIns(int todayCheckIns) {
        this.todayCheckIns = todayCheckIns;
    }
    
    public double getMonthlyRevenue() {
        return monthlyRevenue;
    }
    
    public void setMonthlyRevenue(double monthlyRevenue) {
        this.monthlyRevenue = monthlyRevenue;
    }
    
    public double getYearlyRevenue() {
        return yearlyRevenue;
    }
    
    public void setYearlyRevenue(double yearlyRevenue) {
        this.yearlyRevenue = yearlyRevenue;
    }
    
    public List<ReservationSummary> getRecentReservations() {
        return recentReservations;
    }
    
    public void setRecentReservations(List<ReservationSummary> recentReservations) {
        this.recentReservations = recentReservations;
    }
}