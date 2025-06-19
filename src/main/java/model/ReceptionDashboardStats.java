package model;


import java.util.List;

public class ReceptionDashboardStats {
    private int todayCheckIns;
    private int todayCheckOuts;
    private int availableRooms;
    private int occupiedRooms;
    private int dirtyRooms;
    private int maintenanceRooms;
    private int totalRooms;
    private double todayExpectedRevenue;
    private int pendingReservations;
    private List<ReservationSummary> upcomingCheckIns;
    private List<ReservationSummary> upcomingCheckOuts;
    private List<Activity> recentActivities;
    
    // Getters and Setters
    public int getTodayCheckIns() {
        return todayCheckIns;
    }
    
    public void setTodayCheckIns(int todayCheckIns) {
        this.todayCheckIns = todayCheckIns;
    }
    
    public int getTodayCheckOuts() {
        return todayCheckOuts;
    }
    
    public void setTodayCheckOuts(int todayCheckOuts) {
        this.todayCheckOuts = todayCheckOuts;
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
    
    public int getDirtyRooms() {
        return dirtyRooms;
    }
    
    public void setDirtyRooms(int dirtyRooms) {
        this.dirtyRooms = dirtyRooms;
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
    
    public double getTodayExpectedRevenue() {
        return todayExpectedRevenue;
    }
    
    public void setTodayExpectedRevenue(double todayExpectedRevenue) {
        this.todayExpectedRevenue = todayExpectedRevenue;
    }
    
    public int getPendingReservations() {
        return pendingReservations;
    }
    
    public void setPendingReservations(int pendingReservations) {
        this.pendingReservations = pendingReservations;
    }
    
    public List<ReservationSummary> getUpcomingCheckIns() {
        return upcomingCheckIns;
    }
    
    public void setUpcomingCheckIns(List<ReservationSummary> upcomingCheckIns) {
        this.upcomingCheckIns = upcomingCheckIns;
    }
    
    public List<ReservationSummary> getUpcomingCheckOuts() {
        return upcomingCheckOuts;
    }
    
    public void setUpcomingCheckOuts(List<ReservationSummary> upcomingCheckOuts) {
        this.upcomingCheckOuts = upcomingCheckOuts;
    }
    
    public List<Activity> getRecentActivities() {
        return recentActivities;
    }
    
    public void setRecentActivities(List<Activity> recentActivities) {
        this.recentActivities = recentActivities;
    }
}