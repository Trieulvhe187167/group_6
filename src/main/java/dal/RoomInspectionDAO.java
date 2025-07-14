package dal;

import model.*;
import java.sql.*;
import java.util.*;
import java.math.BigDecimal;

public class RoomInspectionDAO extends DBContext {
    
    // Get pending inspections for room inspector
    public List<Reservation> getPendingInspections() throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, rm.RoomNumber, rt.Name as RoomTypeName, " +
                    "u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone " +
                    "FROM Reservations r " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "LEFT JOIN RoomInspections ri ON r.Id = ri.ReservationId " +
                    "WHERE r.Status = 'CONFIRMED' " +
                    "AND r.CheckOut <= DATEADD(day, 1, GETDATE()) " +
                    "AND (ri.Id IS NULL OR ri.Status != 'COMPLETED') " +
                    "ORDER BY r.CheckOut";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Reservation res = mapResultSetToReservation(rs);
                reservations.add(res);
            }
        }
        return reservations;
    }
    
    // Get inspection by ID with all details
    public RoomInspection getInspectionById(int id) throws SQLException {
        RoomInspection inspection = null;
        String sql = "SELECT ri.*, " +
                    "r.CheckIn, r.CheckOut, r.TotalAmount, r.RoomId, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, " +
                    "u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, " +
                    "inspector.FullName as InspectorName, " +
                    "approver.FullName as ApproverName " +
                    "FROM RoomInspections ri " +
                    "INNER JOIN Reservations r ON ri.ReservationId = r.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Users inspector ON ri.InspectorId = inspector.Id " +
                    "LEFT JOIN Users approver ON ri.ApprovedBy = approver.Id " +
                    "WHERE ri.Id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    inspection = mapRoomInspection(rs);
                    
                    // Load inspection items
                    inspection.setInspectionItems(getInspectionItems(id));
                    
                    // Load room damages
                    inspection.setRoomDamages(getRoomDamages(id));
                    
                    // Calculate totals
                    calculateTotals(inspection);
                }
            }
        }
        return inspection;
    }
    
    // Start new inspection
    public int startInspection(RoomInspection inspection) throws SQLException {
        String sql = "INSERT INTO RoomInspections (ReservationId, InspectorId, InspectionTime, " +
                    "RoomCondition, CleanlinessScore, Notes, Status) " +
                    "VALUES (?, ?, GETDATE(), ?, ?, ?, 'PENDING')";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, inspection.getReservationId());
            stmt.setInt(2, inspection.getInspectorId());
            stmt.setString(3, inspection.getRoomCondition());
            stmt.setInt(4, inspection.getCleanlinessScore());
            stmt.setString(5, inspection.getNotes());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating inspection failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating inspection failed, no ID obtained.");
                }
            }
        }
    }
    
    // Add inspection item
    public int addInspectionItem(InspectionItem item) throws SQLException {
        String sql = "INSERT INTO InspectionItems (InspectionId, ItemName, ItemCategory, " +
                    "Quantity, UnitPrice, Notes) VALUES (?, ?, ?, ?, ?, ?)";
         
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, item.getInspectionId());
            stmt.setString(2, item.getItemName());
            stmt.setString(3, item.getItemCategory());
            stmt.setInt(4, item.getQuantity());
            stmt.setBigDecimal(5, item.getUnitPrice());
            stmt.setString(6, item.getNotes());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Adding item failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Adding item failed, no ID obtained.");
                }
            }
        }
    }
    
    // Add room damage
    public int addRoomDamage(RoomDamage damage) throws SQLException {
        String sql = "INSERT INTO RoomDamages (InspectionId, DamageType, Description, " +
                    "EstimatedCost, PhotoUrl, Severity) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, damage.getInspectionId());
            stmt.setString(2, damage.getDamageType());
            stmt.setString(3, damage.getDescription());
            stmt.setBigDecimal(4, damage.getEstimatedCost());
            stmt.setString(5, damage.getPhotoUrl());
            stmt.setString(6, damage.getSeverity());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Adding damage failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Adding damage failed, no ID obtained.");
                }
            }
        }
    }
    
    // Get room amenities
    public List<RoomAmenity> getRoomAmenities(int roomId) throws SQLException {
        List<RoomAmenity> amenities = new ArrayList<>();
        String sql = "SELECT * FROM RoomAmenities WHERE RoomId = ? AND IsChargeable = 1 " +
                    "ORDER BY Name";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, roomId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    RoomAmenity amenity = new RoomAmenity();
                    amenity.setId(rs.getInt("Id"));
                    amenity.setName(rs.getString("Name"));
                    amenity.setDescription(rs.getString("Description"));
                    // Convert to double since setUnitPrice expects double, not BigDecimal
                    amenity.setUnitPrice(rs.getDouble("UnitPrice"));
                    amenity.setIsChargeable(rs.getBoolean("IsChargeable"));
                    amenities.add(amenity);
                }
            }
        }
        return amenities;
    }
    
   
    
    // Complete inspection
    public void completeInspection(int inspectionId, int approvedBy) throws SQLException {
        String sql = "UPDATE RoomInspections SET Status = 'COMPLETED', " +
                    "ApprovedBy = ?, ApprovedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, approvedBy);
            stmt.setInt(2, inspectionId);
            stmt.executeUpdate();
        }
    }
    
    // Get inspector's inspections
  public List<RoomInspection> getInspectorInspections(int inspectorId, String status) throws SQLException {
    List<RoomInspection> inspections = new ArrayList<>();
    String sql = "SELECT ri.*, " +
                "r.CheckIn, r.CheckOut, r.RoomId, " +
                "rm.RoomNumber, " +
                "u.FullName as CustomerName, " +
                "ISNULL((SELECT SUM(TotalPrice) FROM InspectionItems WHERE InspectionId = ri.Id), 0) as ItemCharges, " +
                "ISNULL((SELECT SUM(EstimatedCost) FROM RoomDamages WHERE InspectionId = ri.Id), 0) as DamageCharges " +
                "FROM RoomInspections ri " +
                "INNER JOIN Reservations r ON ri.ReservationId = r.Id " +
                "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                "INNER JOIN Users u ON r.UserId = u.Id " +
                "WHERE ri.InspectorId = ? ";
    
    if (status != null && !status.isEmpty()) {
        sql += "AND ri.Status = ? ";
    }
    
    sql += "ORDER BY ri.InspectionTime DESC";
    
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, inspectorId);
        if (status != null && !status.isEmpty()) {
            stmt.setString(2, status);
        }
        
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                RoomInspection inspection = new RoomInspection();
                
                // Basic info
                inspection.setId(rs.getInt("Id"));
                inspection.setReservationId(rs.getInt("ReservationId"));
                inspection.setInspectorId(inspectorId);
                inspection.setInspectionTime(rs.getTimestamp("InspectionTime"));
                inspection.setRoomCondition(rs.getString("RoomCondition"));
                inspection.setCleanlinessScore(rs.getInt("CleanlinessScore"));
                inspection.setNotes(rs.getString("Notes"));
                inspection.setStatus(rs.getString("Status"));
                
                // Calculate totals
                double itemCharges = rs.getDouble("ItemCharges");
                double damageCharges = rs.getDouble("DamageCharges");
                inspection.setTotalCharges(BigDecimal.valueOf(itemCharges + damageCharges));
                
                // Reservation info
                Reservation res = new Reservation();
                res.setId(rs.getInt("ReservationId"));
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                res.setRoomId(rs.getInt("RoomId"));
                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setCustomerName(rs.getString("CustomerName"));
                inspection.setReservation(res);
                
                inspections.add(inspection);
            }
        }
    }
    return inspections;
}
    
  
    // Update inspection notes
    public void updateInspectionNotes(int inspectionId, String notes) throws SQLException {
    // Fixed: Removed SET UpdatedAt = GETDATE() as column might not exist
    String sql = "UPDATE RoomInspections SET Notes = ? WHERE Id = ?";
    
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setString(1, notes);
        stmt.setInt(2, inspectionId);
        stmt.executeUpdate();
    }
}
    
    // Delete inspection item
    public void deleteInspectionItem(int itemId) throws SQLException {
        String sql = "DELETE FROM InspectionItems WHERE Id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, itemId);
            stmt.executeUpdate();
        }
    }
    
    // Delete room damage
    public void deleteRoomDamage(int damageId) throws SQLException {
        String sql = "DELETE FROM RoomDamages WHERE Id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, damageId);
            stmt.executeUpdate();
        }
    }
    
    // Get today's inspections count
    public int getTodayInspectionsCount() {
        String sql = "SELECT COUNT(*) FROM RoomInspections " +
                    "WHERE CAST(InspectionTime AS DATE) = CAST(GETDATE() AS DATE)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get total revenue from inspections
    public double getTotalInspectionRevenue() {
        String sql = "SELECT ISNULL(SUM(ItemCharges + DamageCharges), 0) as TotalRevenue FROM (" +
                    "SELECT " +
                    "ISNULL((SELECT SUM(TotalPrice) FROM InspectionItems WHERE InspectionId = ri.Id), 0) as ItemCharges, " +
                    "ISNULL((SELECT SUM(EstimatedCost) FROM RoomDamages WHERE InspectionId = ri.Id), 0) as DamageCharges " +
                    "FROM RoomInspections ri WHERE ri.Status = 'COMPLETED'" +
                    ") as InspectionTotals";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
   
    
    // Helper method to map RoomInspection
    private RoomInspection mapRoomInspection(ResultSet rs) throws SQLException {
        RoomInspection inspection = new RoomInspection();
        inspection.setId(rs.getInt("Id"));
        inspection.setReservationId(rs.getInt("ReservationId"));
        inspection.setInspectorId(rs.getInt("InspectorId"));
        inspection.setInspectionTime(rs.getTimestamp("InspectionTime"));
        inspection.setRoomCondition(rs.getString("RoomCondition"));
        inspection.setCleanlinessScore(rs.getInt("CleanlinessScore"));
        inspection.setNotes(rs.getString("Notes"));
        inspection.setPhotoUrls(rs.getString("PhotoUrls"));
        inspection.setStatus(rs.getString("Status"));
        
        Object approvedBy = rs.getObject("ApprovedBy");
        if (approvedBy != null) {
            inspection.setApprovedBy((Integer) approvedBy);
        }
        inspection.setApprovedAt(rs.getTimestamp("ApprovedAt"));
        
        // Map reservation details
        Reservation res = new Reservation();
        res.setId(rs.getInt("ReservationId"));
        res.setCheckIn(rs.getDate("CheckIn"));
        res.setCheckOut(rs.getDate("CheckOut"));
        res.setTotalAmount(rs.getDouble("TotalAmount"));
        res.setRoomId(rs.getInt("RoomId"));
        res.setRoomNumber(rs.getString("RoomNumber"));
        res.setRoomTypeName(rs.getString("RoomTypeName"));
        res.setCustomerName(rs.getString("CustomerName"));
        res.setCustomerEmail(rs.getString("CustomerEmail"));
        res.setCustomerPhone(rs.getString("CustomerPhone"));
        
        inspection.setReservation(res);
        
        // Map inspector
        User inspector = new User();
        inspector.setFullName(rs.getString("InspectorName"));
        inspection.setInspector(inspector);
        
        // Map approver if exists
        try {
            String approverName = rs.getString("ApproverName");
            if (approverName != null) {
                User approver = new User();
                approver.setFullName(approverName);
                inspection.setApprover(approver);
            }
        } catch (SQLException e) {
            // Approver may not exist
        }
        
        return inspection;
    }
    
    private List<InspectionItem> getInspectionItems(int inspectionId) throws SQLException {
        List<InspectionItem> items = new ArrayList<>();
        String sql = "SELECT * FROM InspectionItems WHERE InspectionId = ? ORDER BY ItemName";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, inspectionId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    InspectionItem item = new InspectionItem();
                    item.setId(rs.getInt("Id"));
                    item.setInspectionId(rs.getInt("InspectionId"));
                    item.setItemName(rs.getString("ItemName"));
                    item.setItemCategory(rs.getString("ItemCategory"));
                    item.setQuantity(rs.getInt("Quantity"));
                    // Convert from database numeric to BigDecimal
                    item.setUnitPrice(BigDecimal.valueOf(rs.getDouble("UnitPrice")));
                    item.setTotalPrice(BigDecimal.valueOf(rs.getDouble("TotalPrice")));
                    item.setNotes(rs.getString("Notes"));
                    items.add(item);
                }
            }
        }
        return items;
    }
    
    private List<RoomDamage> getRoomDamages(int inspectionId) throws SQLException {
        List<RoomDamage> damages = new ArrayList<>();
        String sql = "SELECT * FROM RoomDamages WHERE InspectionId = ? ORDER BY Severity DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, inspectionId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    RoomDamage damage = new RoomDamage();
                    damage.setId(rs.getInt("Id"));
                    damage.setInspectionId(rs.getInt("InspectionId"));
                    damage.setDamageType(rs.getString("DamageType"));
                    damage.setDescription(rs.getString("Description"));
                    // Convert from database numeric to BigDecimal
                    damage.setEstimatedCost(BigDecimal.valueOf(rs.getDouble("EstimatedCost")));
                    damage.setPhotoUrl(rs.getString("PhotoUrl"));
                    damage.setSeverity(rs.getString("Severity"));
                    damages.add(damage);
                }
            }
        }
        return damages;
    }
    
    private void calculateTotals(RoomInspection inspection) {
        BigDecimal itemTotal = BigDecimal.ZERO;
        BigDecimal damageTotal = BigDecimal.ZERO;
        
        if (inspection.getInspectionItems() != null) {
            for (InspectionItem item : inspection.getInspectionItems()) {
                if (item.getTotalPrice() != null) {
                    itemTotal = itemTotal.add(item.getTotalPrice());
                }
            }
        }
        
        if (inspection.getRoomDamages() != null) {
            for (RoomDamage damage : inspection.getRoomDamages()) {
                if (damage.getEstimatedCost() != null) {
                    damageTotal = damageTotal.add(damage.getEstimatedCost());
                }
            }
        }
        
        inspection.setTotalItemCharges(itemTotal);
        inspection.setTotalDamageCharges(damageTotal);
        inspection.setTotalCharges(itemTotal.add(damageTotal));
    }
    
    // Add this method to RoomInspectionDAO.java

public RoomInspection getInspectionByReservationId(int reservationId) throws SQLException {
    // Fixed: Use TOP 1 for SQL Server and correct column names
    String sql = "SELECT TOP 1 ri.*, " +
                 "u.FullName as InspectorName, " +
                 "usr.FullName as CustomerName, " +  // Join with Users to get customer name
                 "r.CheckIn, r.CheckOut, r.TotalAmount, " +
                 "rm.RoomNumber, rt.Name as RoomTypeName, " +  // Use rt.Name instead of rt.TypeName
                 "(SELECT COALESCE(SUM(Quantity * UnitPrice), 0) FROM InspectionItems " +
                 " WHERE InspectionId = ri.Id) as ItemCharges, " +
                 "(SELECT COALESCE(SUM(EstimatedCost), 0) FROM RoomDamages " +
                 " WHERE InspectionId = ri.Id) as DamageCharges " +
                 "FROM RoomInspections ri " +
                 "JOIN Users u ON ri.InspectorId = u.Id " +
                 "JOIN Reservations r ON ri.ReservationId = r.Id " +
                 "JOIN Users usr ON r.UserId = usr.Id " +  // Join to get customer info
                 "JOIN Rooms rm ON r.RoomId = rm.Id " +
                 "JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                 "WHERE ri.ReservationId = ? " +
                 "ORDER BY ri.InspectionTime DESC";
    
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, reservationId);
        
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                RoomInspection inspection = new RoomInspection();
                inspection.setId(rs.getInt("Id"));
                inspection.setReservationId(rs.getInt("ReservationId"));
                inspection.setInspectorId(rs.getInt("InspectorId"));
                inspection.setInspectionTime(rs.getTimestamp("InspectionTime"));
                inspection.setRoomCondition(rs.getString("RoomCondition"));
                inspection.setCleanlinessScore(rs.getInt("CleanlinessScore"));
                inspection.setNotes(rs.getString("Notes"));
                inspection.setStatus(rs.getString("Status"));
                
                // Set inspector info
                User inspector = new User();
                inspector.setFullName(rs.getString("InspectorName"));
                inspection.setInspector(inspector);
                
                // Set charges - handle as BigDecimal
                inspection.setTotalItemCharges(BigDecimal.valueOf(rs.getDouble("ItemCharges")));
                inspection.setTotalDamageCharges(BigDecimal.valueOf(rs.getDouble("DamageCharges")));
                inspection.setTotalCharges(inspection.getTotalItemCharges().add(inspection.getTotalDamageCharges()));
                
                // Set reservation info
                Reservation reservation = new Reservation();
                reservation.setId(rs.getInt("ReservationId"));
                reservation.setCustomerName(rs.getString("CustomerName"));
                reservation.setCheckIn(rs.getDate("CheckIn"));
                reservation.setCheckOut(rs.getDate("CheckOut"));
                reservation.setTotalAmount(rs.getDouble("TotalAmount"));
                reservation.setRoomNumber(rs.getString("RoomNumber"));
                reservation.setRoomTypeName(rs.getString("RoomTypeName"));
                inspection.setReservation(reservation);
                
                return inspection;
            }
        }
    }
    return null;
}


// Also add this method to update inspection status
public boolean updateInspectionStatus(int inspectionId, String status) throws SQLException {
    // Only update Status, not UpdatedAt (column might not exist)
    String sql = "UPDATE RoomInspections SET Status = ? WHERE Id = ?";
    
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setString(1, status);
        stmt.setInt(2, inspectionId);
        
        return stmt.executeUpdate() > 0;
    }
}
private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
    Reservation reservation = new Reservation();
    reservation.setId(rs.getInt("Id"));
    reservation.setUserId(rs.getInt("UserId"));
    
    // Handle nullable fields safely
    try {
        Object groupBookingId = rs.getObject("GroupBookingId");
        if (groupBookingId != null) {
            reservation.setGroupBookingId((Integer) groupBookingId);
        }
    } catch (SQLException e) {
        // Column might not exist in this query
    }
    
    try {
        Object createdBy = rs.getObject("CreatedBy");
        if (createdBy != null) {
            reservation.setCreatedBy((Integer) createdBy);
        }
    } catch (SQLException e) {
        // Column might not exist in this query
    }
    
    // RoomId might be null for pending inspections
    try {
        Object roomId = rs.getObject("RoomId");
        if (roomId != null) {
            reservation.setRoomId((Integer) roomId);
        }
    } catch (SQLException e) {
        // Handle if column doesn't exist
    }
    
    // Handle RoomTypeId if it exists in the query
    try {
        Object roomTypeId = rs.getObject("RoomTypeId");
        if (roomTypeId != null) {
            reservation.setRoomTypeId((Integer) roomTypeId);
        }
    } catch (SQLException e) {
        // Column might not exist in this query - this is OK
    }
    
    reservation.setCheckIn(rs.getDate("CheckIn"));
    reservation.setCheckOut(rs.getDate("CheckOut"));
    reservation.setStatus(rs.getString("Status"));
    reservation.setTotalAmount(rs.getDouble("TotalAmount"));
    
    // Set display fields - these should always exist in our queries
    reservation.setCustomerName(rs.getString("CustomerName"));
    reservation.setCustomerEmail(rs.getString("CustomerEmail"));
    reservation.setCustomerPhone(rs.getString("CustomerPhone"));
    reservation.setRoomNumber(rs.getString("RoomNumber"));
    reservation.setRoomTypeName(rs.getString("RoomTypeName"));
    
    // Handle optional fields
    try {
        reservation.setNotes(rs.getString("Notes"));
    } catch (SQLException e) {
        // Notes might not be in all queries
    }
    
    try {
        reservation.setSpecialRequests(rs.getString("SpecialRequests"));
    } catch (SQLException e) {
        // SpecialRequests might not be in all queries
    }
    
    try {
        reservation.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
    } catch (SQLException e) {
        // NumberOfCustomers might not be in all queries
        reservation.setNumberOfCustomers(1); // Default value
    }
    
    // Calculate nights if dates are available
    if (reservation.getCheckIn() != null && reservation.getCheckOut() != null) {
        reservation.calculateNights();
    }
    
    return reservation;
}
}