package dal;

import model.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceDAO {
    
    // Get all active services
    public List<Service> getAllActiveServices() {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT * FROM Services ORDER BY Name";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                services.add(mapResultSetToService(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting services: " + e.getMessage());
        }
        return services;
    }
    
    // Get services by category
    public List<Service> getServicesByCategory(String category) {
        List<Service> allServices = getAllActiveServices();
        List<Service> filteredServices = new ArrayList<>();
        
        for (Service service : allServices) {
            if (category.equals(service.getCategory())) {
                filteredServices.add(service);
            }
        }
        
        return filteredServices;
    }
    
    // Get service by ID
    public Service getServiceById(int serviceId) {
        String sql = "SELECT * FROM Services WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, serviceId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToService(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting service by ID: " + e.getMessage());
        }
        return null;
    }
    
    // Add service to reservation
    public boolean addServiceToReservation(ReservationService reservationService) {
        String sql = "INSERT INTO ReservationServices (ReservationId, ServiceId, Quantity) VALUES (?, ?, ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationService.getReservationId());
            ps.setInt(2, reservationService.getServiceId());
            ps.setInt(3, reservationService.getQuantity());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error adding service to reservation: " + e.getMessage());
        }
        return false;
    }
    
    // GET SERVICE ORDERS BY RESERVATION - METHOD MỚI
    public List<ServiceOrder> getServiceOrdersByReservation(int reservationId) {
        List<ServiceOrder> orders = new ArrayList<>();
        
        // Query phức tạp hơn để lấy đầy đủ thông tin
        String sql = "SELECT rs.Id, rs.ReservationId, rs.ServiceId, rs.Quantity, " +
                    "s.Name as ServiceName, s.Price, s.Description, " +
                    "CASE " +
                    "  WHEN s.Name LIKE '%Airport%' OR s.Name LIKE '%Shuttle%' OR s.Name LIKE '%Car%' THEN 'TRANSPORT' " +
                    "  WHEN s.Name LIKE '%Spa%' OR s.Name LIKE '%Massage%' THEN 'SPA' " +
                    "  WHEN s.Name LIKE '%Breakfast%' OR s.Name LIKE '%Dinner%' OR s.Name LIKE '%Room Service%' THEN 'DINING' " +
                    "  WHEN s.Name LIKE '%Laundry%' THEN 'LAUNDRY' " +
                    "  ELSE 'OTHER' " +
                    "END as Category, " +
                    "r.RoomId, rm.RoomNumber, " +
                    "u.FullName as CustomerName " +
                    "FROM ReservationServices rs " +
                    "INNER JOIN Services s ON rs.ServiceId = s.Id " +
                    "INNER JOIN Reservations r ON rs.ReservationId = r.Id " +
                    "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "WHERE rs.ReservationId = ? " +
                    "ORDER BY rs.Id DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ServiceOrder order = new ServiceOrder();
                order.setId(rs.getInt("Id"));
                order.setReservationId(rs.getInt("ReservationId"));
                order.setServiceId(rs.getInt("ServiceId"));
                order.setServiceName(rs.getString("ServiceName"));
                order.setQuantity(rs.getInt("Quantity"));
                order.setUnitPrice(rs.getDouble("Price"));
                order.setTotalAmount(rs.getDouble("Price") * rs.getInt("Quantity"));
                order.setRoomNumber(rs.getString("RoomNumber"));
                order.setCustomerName(rs.getString("CustomerName"));
                order.setStatus("CONFIRMED"); // Default status
                
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting service orders by reservation: " + e.getMessage());
        }
        return orders;
    }
    
    // Get recent service orders
    public List<ServiceOrder> getRecentServiceOrders(int limit) {
        List<ServiceOrder> orders = new ArrayList<>();
        
        String sql = "SELECT TOP (?) rs.Id, rs.ReservationId, rs.ServiceId, rs.Quantity, " +
                    "s.Name as ServiceName, s.Price, " +
                    "CASE " +
                    "  WHEN s.Name LIKE '%Airport%' OR s.Name LIKE '%Shuttle%' OR s.Name LIKE '%Car%' THEN 'TRANSPORT' " +
                    "  WHEN s.Name LIKE '%Spa%' OR s.Name LIKE '%Massage%' THEN 'SPA' " +
                    "  WHEN s.Name LIKE '%Breakfast%' OR s.Name LIKE '%Dinner%' OR s.Name LIKE '%Room Service%' THEN 'DINING' " +
                    "  WHEN s.Name LIKE '%Laundry%' THEN 'LAUNDRY' " +
                    "  ELSE 'OTHER' " +
                    "END as Category, " +
                    "r.Id as ReservationId, rm.RoomNumber, u.FullName as CustomerName " +
                    "FROM ReservationServices rs " +
                    "INNER JOIN Services s ON rs.ServiceId = s.Id " +
                    "INNER JOIN Reservations r ON rs.ReservationId = r.Id " +
                    "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "ORDER BY rs.Id DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ServiceOrder order = new ServiceOrder();
                order.setId(rs.getInt("Id"));
                order.setReservationId(rs.getInt("ReservationId"));
                order.setServiceId(rs.getInt("ServiceId"));
                order.setServiceName(rs.getString("ServiceName"));
                order.setCategory(rs.getString("Category"));
                order.setQuantity(rs.getInt("Quantity"));
                order.setUnitPrice(rs.getDouble("Price"));
                order.setTotalAmount(rs.getDouble("Price") * rs.getInt("Quantity"));
                order.setRoomNumber(rs.getString("RoomNumber"));
                order.setCustomerName(rs.getString("CustomerName"));
                order.setStatus("CONFIRMED");
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
    
    // Get reservation service total
    public double getReservationServiceTotal(int reservationId) {
        String sql = "SELECT ISNULL(SUM(s.Price * rs.Quantity), 0) as TotalAmount " +
                    "FROM ReservationServices rs " +
                    "INNER JOIN Services s ON rs.ServiceId = s.Id " +
                    "WHERE rs.ReservationId = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalAmount");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Update service order status (if you have status column)
    public boolean updateServiceOrderStatus(int orderId, String status) {
        // First check if Status column exists
        if (!checkColumnExists("ReservationServices", "Status")) {
            System.out.println("Status column does not exist in ReservationServices table");
            return false;
        }
        
        String sql = "UPDATE ReservationServices SET Status = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, orderId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Delete service from reservation
    public boolean deleteServiceFromReservation(int reservationServiceId) {
        String sql = "DELETE FROM ReservationServices WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationServiceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get all services for a specific category and reservation
    public List<ServiceOrder> getServicesByReservationAndCategory(int reservationId, String category) {
        List<ServiceOrder> allOrders = getServiceOrdersByReservation(reservationId);
        List<ServiceOrder> filteredOrders = new ArrayList<>();
        
        for (ServiceOrder order : allOrders) {
            if (category.equals(order.getCategory())) {
                filteredOrders.add(order);
            }
        }
        
        return filteredOrders;
    }
    
    // Calculate total service amount for a reservation
    public double calculateTotalServiceAmount(int reservationId) {
        double total = 0;
        List<ServiceOrder> orders = getServiceOrdersByReservation(reservationId);
        
        for (ServiceOrder order : orders) {
            total += order.getTotalAmount();
        }
        
        return total;
    }
    
    // Create new service
    public boolean createService(Service service) {
        String sql = "INSERT INTO Services (Name, Description, Price) VALUES (?, ?, ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, service.getName());
            ps.setString(2, service.getDescription());
            ps.setDouble(3, service.getPrice());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update service
    public boolean updateService(Service service) {
        String sql = "UPDATE Services SET Name = ?, Description = ?, Price = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, service.getName());
            ps.setString(2, service.getDescription());
            ps.setDouble(3, service.getPrice());
            ps.setInt(4, service.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Delete service (be careful with foreign keys)
    public boolean deleteService(int serviceId) {
        // Check if service is being used
        if (isServiceInUse(serviceId)) {
            System.out.println("Cannot delete service - it is being used in reservations");
            return false;
        }
        
        String sql = "DELETE FROM Services WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, serviceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Check if service is being used in any reservation
    private boolean isServiceInUse(int serviceId) {
        String sql = "SELECT COUNT(*) FROM ReservationServices WHERE ServiceId = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, serviceId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Helper method to check if column exists
    private boolean checkColumnExists(String tableName, String columnName) {
        String sql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = ? AND COLUMN_NAME = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Map ResultSet to Service
    private Service mapResultSetToService(ResultSet rs) throws SQLException {
        Service service = new Service();
        service.setId(rs.getInt("Id"));
        service.setName(rs.getString("Name"));
        service.setDescription(rs.getString("Description"));
        service.setPrice(rs.getDouble("Price"));
        
        // Set default status if column doesn't exist
        try {
            service.setStatus(rs.getString("Status"));
        } catch (SQLException e) {
            service.setStatus("active");
        }
        
        // Auto-categorize based on name
        String name = service.getName().toLowerCase();
        if (name.contains("airport") || name.contains("shuttle") || name.contains("car")) {
            service.setCategory("TRANSPORT");
        } else if (name.contains("spa") || name.contains("massage")) {
            service.setCategory("SPA");
        } else if (name.contains("breakfast") || name.contains("dinner") || 
                   name.contains("room service") || name.contains("mini bar")) {
            service.setCategory("DINING");
        } else if (name.contains("laundry")) {
            service.setCategory("LAUNDRY");
        } else if (name.contains("flower") || name.contains("birthday") || 
                   name.contains("honeymoon")) {
            service.setCategory("SPECIAL");
        } else {
            service.setCategory("OTHER");
        }
        
        service.setCreatedAt(rs.getTimestamp("CreatedAt"));
        
        return service;
    }
    
    // Debug method
    public void debugDatabaseStructure() {
        System.out.println("\n=== DEBUGGING SERVICE TABLES ===");
        
        // Check Services table
        System.out.println("\n1. Services Table Structure:");
        debugTableStructure("Services");
        
        // Check ReservationServices table
        System.out.println("\n2. ReservationServices Table Structure:");
        debugTableStructure("ReservationServices");
        
        // Show sample data
        System.out.println("\n3. Sample Services Data:");
        String sql = "SELECT TOP 5 * FROM Services";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            int count = 0;
            while (rs.next()) {
                count++;
                System.out.println(count + ". " + rs.getString("Name") + 
                                 " - Price: " + rs.getDouble("Price") + "₫");
            }
            if (count == 0) {
                System.out.println("No services found in database!");
            }
            
        } catch (SQLException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
    
    private void debugTableStructure(String tableName) {
        String sql = "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE " +
                    "FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = ? " +
                    "ORDER BY ORDINAL_POSITION";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, tableName);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                System.out.println("- " + rs.getString("COLUMN_NAME") + 
                                 " (" + rs.getString("DATA_TYPE") + ")" +
                                 (rs.getString("IS_NULLABLE").equals("NO") ? " NOT NULL" : ""));
            }
            
        } catch (SQLException e) {
            System.err.println("Error checking table structure: " + e.getMessage());
        }
    }
}