package dal;


import model.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceDAO {
    
    // Get all active services
    public List<Service> getAllActiveServices() {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT * FROM Services WHERE Status = 'ACTIVE' ORDER BY Category, Name";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                services.add(mapResultSetToService(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return services;
    }
    
    // Get services by category
    public List<Service> getServicesByCategory(String category) {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT * FROM Services WHERE Category = ? AND Status = 'ACTIVE' ORDER BY Name";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                services.add(mapResultSetToService(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return services;
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
        }
        return null;
    }
    
    // Add service to reservation
    public boolean addServiceToReservation(ReservationService reservationService) {
        String sql = "INSERT INTO ReservationServices (ReservationId, ServiceId, Quantity, UnitPrice, TotalPrice, Status, CreatedAt, CreatedBy) " +
                    "VALUES (?, ?, ?, ?, ?, 'PENDING', GETDATE(), ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            // Get service details to calculate price
            Service service = getServiceById(reservationService.getServiceId());
            if (service == null) {
                return false;
            }
            
            double totalPrice = service.getPrice() * reservationService.getQuantity();
            
            ps.setInt(1, reservationService.getReservationId());
            ps.setInt(2, reservationService.getServiceId());
            ps.setInt(3, reservationService.getQuantity());
            ps.setDouble(4, service.getPrice());
            ps.setDouble(5, totalPrice);
            ps.setInt(6, reservationService.getCreatedBy());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get recent service orders
    public List<ServiceOrder> getRecentServiceOrders(int limit) {
        List<ServiceOrder> orders = new ArrayList<>();
        String sql = "SELECT TOP (?) rs.*, s.Name as ServiceName, s.Category, " +
                    "r.Id as ReservationId, rm.RoomNumber, u.FullName as GuestName, " +
                    "staff.FullName as CreatedByName " +
                    "FROM ReservationServices rs " +
                    "INNER JOIN Services s ON rs.ServiceId = s.Id " +
                    "INNER JOIN Reservations r ON rs.ReservationId = r.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "LEFT JOIN Users staff ON rs.CreatedBy = staff.Id " +
                    "ORDER BY rs.CreatedAt DESC";
        
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
                order.setUnitPrice(rs.getDouble("UnitPrice"));
                order.setTotalAmount(rs.getDouble("TotalPrice"));
                order.setStatus(rs.getString("Status"));
                order.setRoomNumber(rs.getString("RoomNumber"));
                order.setGuestName(rs.getString("GuestName"));
                order.setCreatedAt(rs.getTimestamp("CreatedAt"));
                order.setCreatedByName(rs.getString("CreatedByName"));
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
    
    // Get reservation service total
    public double getReservationServiceTotal(int reservationId) {
        String sql = "SELECT ISNULL(SUM(TotalPrice), 0) FROM ReservationServices " +
                    "WHERE ReservationId = ? AND Status != 'CANCELLED'";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Update service order status
    public boolean updateServiceOrderStatus(int orderId, String status) {
        String sql = "UPDATE ReservationServices SET Status = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
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
    
    // Create new service
    public boolean createService(Service service) {
        String sql = "INSERT INTO Services (Name, Description, Category, Price, Status, CreatedAt, CreatedBy) " +
                    "VALUES (?, ?, ?, ?, 'ACTIVE', GETDATE(), ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, service.getName());
            ps.setString(2, service.getDescription());
            ps.setString(3, service.getCategory());
            ps.setDouble(4, service.getPrice());
            ps.setInt(5, service.getCreatedBy());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update service
    public boolean updateService(Service service) {
        String sql = "UPDATE Services SET Name = ?, Description = ?, Category = ?, Price = ?, " +
                    "Status = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, service.getName());
            ps.setString(2, service.getDescription());
            ps.setString(3, service.getCategory());
            ps.setDouble(4, service.getPrice());
            ps.setString(5, service.getStatus());
            ps.setInt(6, service.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get service orders by reservation
    public List<ServiceOrder> getServiceOrdersByReservation(int reservationId) {
        List<ServiceOrder> orders = new ArrayList<>();
        String sql = "SELECT rs.*, s.Name as ServiceName, s.Category " +
                    "FROM ReservationServices rs " +
                    "INNER JOIN Services s ON rs.ServiceId = s.Id " +
                    "WHERE rs.ReservationId = ? " +
                    "ORDER BY rs.CreatedAt DESC";
        
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
                order.setCategory(rs.getString("Category"));
                order.setQuantity(rs.getInt("Quantity"));
                order.setUnitPrice(rs.getDouble("UnitPrice"));
                order.setTotalAmount(rs.getDouble("TotalPrice"));
                order.setStatus(rs.getString("Status"));
                order.setCreatedAt(rs.getTimestamp("CreatedAt"));
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
    
    private Service mapResultSetToService(ResultSet rs) throws SQLException {
        Service service = new Service();
        service.setId(rs.getInt("Id"));
        service.setName(rs.getString("Name"));
        service.setDescription(rs.getString("Description"));
        service.setCategory(rs.getString("Category"));
        service.setPrice(rs.getDouble("Price"));
        service.setStatus(rs.getString("Status"));
        service.setCreatedAt(rs.getTimestamp("CreatedAt"));
        service.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        service.setCreatedBy(rs.getInt("CreatedBy"));
        return service;
    }
}