package dal;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Payment;
import model.Reservation;

public class PaymentDAO {
    
    // Get monthly revenue
    public double getMonthlyRevenue(int month, int year) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND MONTH(p.CreatedAt) = ? " +
                    "AND YEAR(p.CreatedAt) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, month);
            ps.setInt(2, year);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get yearly revenue
    public double getYearlyRevenue(int year) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND YEAR(p.CreatedAt) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, year);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get daily revenue
    public double getDailyRevenue(Date date) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND CAST(p.CreatedAt AS DATE) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, date);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get revenue by payment method
    public double getRevenueByMethod(String method, int month, int year) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND p.Method = ? " +
                    "AND MONTH(p.CreatedAt) = ? " +
                    "AND YEAR(p.CreatedAt) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, method);
            ps.setInt(2, month);
            ps.setInt(3, year);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get revenue by date range
    public double getRevenueByDateRange(Date startDate, Date endDate) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND CAST(p.CreatedAt AS DATE) BETWEEN ? AND ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, startDate);
            ps.setDate(2, endDate);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
     // Get monthly revenue data for an entire year
    public double[] getMonthlyRevenueByYear(int year) {
        double[] revenues = new double[12];
        String sql = "SELECT MONTH(CreatedAt) AS Month, SUM(Amount) AS Revenue " +
                     "FROM Payments " +
                     "WHERE Status = 'SUCCESS' AND YEAR(CreatedAt) = ? " +
                     "GROUP BY MONTH(CreatedAt)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, year);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int month = rs.getInt("Month");
                revenues[month - 1] = rs.getDouble("Revenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return revenues;
    }
    // Get payment count by status
    public int getPaymentCountByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Payments WHERE Status = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
     // Get payments by reservation
    public List<Payment> getPaymentsByReservation(int reservationId) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM Payments WHERE ReservationId = ? ORDER BY CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Payment payment = new Payment();
                payment.setId(rs.getInt("Id"));
                payment.setReservationId(rs.getInt("ReservationId"));
                payment.setAmount(rs.getDouble("Amount"));
                payment.setMethod(rs.getString("Method"));
                payment.setStatus(rs.getString("Status"));
                payment.setTransactionId(rs.getString("TransactionId"));
                payment.setCreatedAt(rs.getTimestamp("CreatedAt"));
                payments.add(payment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return payments;
    }
    
    // Create new payment
    public boolean createPayment(Payment payment) {
        String sql = "INSERT INTO Payments (ReservationId, Amount, Method, Status, TransactionId, CreatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, payment.getReservationId());
            ps.setDouble(2, payment.getAmount());
            ps.setString(3, payment.getMethod());
            ps.setString(4, payment.getStatus());
            ps.setString(5, payment.getTransactionId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update payment status
    public boolean updatePaymentStatus(int paymentId, String newStatus, String transactionId) {
        String sql = "UPDATE Payments SET Status = ?, TransactionId = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newStatus);
            ps.setString(2, transactionId);
            ps.setInt(3, paymentId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get pending payments
    public List<Payment> getPendingPayments() {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, r.UserId, u.FullName, rm.RoomNumber " +
                    "FROM Payments p " +
                    "INNER JOIN Reservations r ON p.ReservationId = r.Id " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE p.Status = 'PENDING' " +
                    "ORDER BY p.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Payment payment = new Payment();
                payment.setId(rs.getInt("Id"));
                payment.setReservationId(rs.getInt("ReservationId"));
                payment.setAmount(rs.getDouble("Amount"));
                payment.setMethod(rs.getString("Method"));
                payment.setStatus(rs.getString("Status"));
                payment.setTransactionId(rs.getString("TransactionId"));
                payment.setCreatedAt(rs.getTimestamp("CreatedAt"));
                payment.setCustomerName(rs.getString("FullName"));
                payment.setRoomNumber(rs.getString("RoomNumber"));
                payments.add(payment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return payments;
    }
    
    // Get total revenue for a date range
    public double getTotalRevenue(Date startDate, Date endDate) {
        String sql = "SELECT ISNULL(SUM(Amount), 0) as TotalRevenue " +
                    "FROM Payments " +
                    "WHERE Status = 'SUCCESS' " +
                    "AND CAST(CreatedAt AS DATE) BETWEEN ? AND ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, startDate);
            ps.setDate(2, endDate);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    public String getReservationPaymentStatus(int reservationId) {
        String sql = "SELECT Status FROM Payments WHERE ReservationId = ? ORDER BY CreatedAt DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("Status");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "PENDING";
    }
    
    public double getReservationPaidAmount(int reservationId) {
        String sql = "SELECT COALESCE(SUM(Amount), 0) as TotalPaid FROM Payments WHERE ReservationId = ? AND Status = 'SUCCESS'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalPaid");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
public int createPaymentAndGetId(Payment payment) {
    String sql = "INSERT INTO Payments (ReservationId, Amount, Method, Status, TransactionId, CreatedAt) " +
                "VALUES (?, ?, ?, ?, ?, GETDATE())";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        
        ps.setInt(1, payment.getReservationId());
        ps.setDouble(2, payment.getAmount());
        ps.setString(3, payment.getMethod());
        ps.setString(4, payment.getStatus());
        ps.setString(5, payment.getTransactionId());
        
        int affectedRows = ps.executeUpdate();
        
        if (affectedRows > 0) {
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return 0;
    }
}

public Payment getLatestPaymentByReservation(int reservationId) {
    String sql = "SELECT TOP 1 * FROM Payments WHERE ReservationId = ? ORDER BY CreatedAt DESC";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, reservationId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToPayment(rs);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
    Payment payment = new Payment();
    payment.setId(rs.getInt("Id"));
    payment.setReservationId(rs.getInt("ReservationId"));
    payment.setAmount(rs.getDouble("Amount"));
    payment.setMethod(rs.getString("Method"));
    payment.setStatus(rs.getString("Status"));
    payment.setTransactionId(rs.getString("TransactionId"));
    payment.setCreatedAt(rs.getTimestamp("CreatedAt"));
    return payment;
}
public Payment getPaymentById(int paymentId) {
    String sql = "SELECT * FROM Payments WHERE Id = ?";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, paymentId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            Payment payment = new Payment();
            payment.setId(rs.getInt("Id"));
            payment.setReservationId(rs.getInt("ReservationId"));
            payment.setAmount(rs.getDouble("Amount"));
            payment.setMethod(rs.getString("Method"));
            payment.setStatus(rs.getString("Status"));
            payment.setTransactionId(rs.getString("TransactionId"));
            payment.setPaymentType(rs.getString("PaymentType"));
            payment.setCreatedAt(rs.getTimestamp("CreatedAt"));
            return payment;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

public boolean updatePayment(Payment payment) {
    String sql = "UPDATE Payments SET Amount = ?, Status = ?, TransactionId = ?, " +
                "PaymentType = ? WHERE Id = ?";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setDouble(1, payment.getAmount());
        ps.setString(2, payment.getStatus());
        ps.setString(3, payment.getTransactionId());
        ps.setString(4, payment.getPaymentType());
        ps.setInt(5, payment.getId());
        
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

public int createDepositPayment(int reservationId, double amount, String method, String transactionId) {
    String sql = "INSERT INTO Payments (ReservationId, Amount, Method, Status, " +
                "TransactionId, PaymentType, CreatedAt) " +
                "VALUES (?, ?, ?, 'SUCCESS', ?, 'DEPOSIT', GETDATE())";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        
        ps.setInt(1, reservationId);
        ps.setDouble(2, amount);
        ps.setString(3, method);
        ps.setString(4, transactionId);
        
        int affectedRows = ps.executeUpdate();
        
        if (affectedRows > 0) {
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0;
}

public boolean createRefundPayment(int reservationId, double amount, String method) {
    String sql = "INSERT INTO Payments (ReservationId, Amount, Method, Status, " +
                "TransactionId, PaymentType, CreatedAt) " +
                "VALUES (?, ?, ?, 'SUCCESS', ?, 'REFUND', GETDATE())";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, reservationId);
        ps.setDouble(2, amount);
        ps.setString(3, method);
        ps.setString(4, "REFUND-" + reservationId + "-" + System.currentTimeMillis());
        
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

public double getTotalDepositPaid(int reservationId) {
    String sql = "SELECT COALESCE(SUM(Amount), 0) as TotalDeposit " +
                "FROM Payments WHERE ReservationId = ? AND PaymentType = 'DEPOSIT' " +
                "AND Status = 'SUCCESS'";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, reservationId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getDouble("TotalDeposit");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0.0;
}

// Add these methods to ReservationDAO.java

public boolean updateReservationDeposit(int reservationId, double depositAmount, String depositStatus) {
    String sql = "UPDATE Reservations SET DepositAmount = ?, DepositPaidDate = ?, " +
                "DepositStatus = ? WHERE Id = ?";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setDouble(1, depositAmount);
        ps.setDate(2, new java.sql.Date(System.currentTimeMillis()));
        ps.setString(3, depositStatus);
        ps.setInt(4, reservationId);
        
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

public Reservation getReservationWithDeposit(int reservationId) {
    String sql = "SELECT r.*, u.FullName as CustomerName, rm.RoomNumber, " +
                "rt.Name as RoomTypeName, r.DepositAmount, r.DepositPaidDate, " +
                "r.DepositStatus FROM Reservations r " +
                "INNER JOIN Users u ON r.UserId = u.Id " +
                "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                "LEFT JOIN RoomTypes rt ON ISNULL(r.RoomTypeId, rm.RoomTypeId) = rt.Id " +
                "WHERE r.Id = ?";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, reservationId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            Reservation reservation = new Reservation();
            reservation.setId(rs.getInt("Id"));
            reservation.setUserId(rs.getInt("UserId"));
            reservation.setRoomId(rs.getInt("RoomId"));
            reservation.setCheckIn(rs.getDate("CheckIn"));
            reservation.setCheckOut(rs.getDate("CheckOut"));
            reservation.setStatus(rs.getString("Status"));
            reservation.setTotalAmount(rs.getDouble("TotalAmount"));
            reservation.setCustomerName(rs.getString("CustomerName"));
            reservation.setRoomNumber(rs.getString("RoomNumber"));
            reservation.setRoomTypeName(rs.getString("RoomTypeName"));
            reservation.setDepositAmount(rs.getDouble("DepositAmount"));
            reservation.setDepositPaidDate(rs.getDate("DepositPaidDate"));
            reservation.setDepositStatus(rs.getString("DepositStatus"));
            return reservation;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}
public Payment getPaymentByReservationId(int reservationId) {
    String sql = "SELECT TOP 1 * FROM Payments " +
                "WHERE ReservationId = ? " +
                "ORDER BY CreatedAt DESC";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, reservationId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToPayment(rs);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

// Add these methods to PaymentDAO.java

public List<Payment> getFilteredPayments(String status, String method, String paymentType, 
                                        String fromDate, String toDate, String search) {
    List<Payment> payments = new ArrayList<>();
    StringBuilder sql = new StringBuilder();
    sql.append("SELECT p.*, u.FullName as CustomerName, rm.RoomNumber, r.Status as ReservationStatus ");
    sql.append("FROM Payments p ");
    sql.append("INNER JOIN Reservations r ON p.ReservationId = r.Id ");
    sql.append("INNER JOIN Users u ON r.UserId = u.Id ");
    sql.append("LEFT JOIN Rooms rm ON r.RoomId = rm.Id ");
    sql.append("WHERE 1=1 ");
    
    List<Object> params = new ArrayList<>();
    
    if (status != null && !status.isEmpty()) {
        sql.append("AND p.Status = ? ");
        params.add(status);
    }
    
    if (method != null && !method.isEmpty()) {
        sql.append("AND p.Method = ? ");
        params.add(method);
    }
    
    if (paymentType != null && !paymentType.isEmpty()) {
        sql.append("AND p.PaymentType = ? ");
        params.add(paymentType);
    }
    
    if (fromDate != null && !fromDate.isEmpty()) {
        sql.append("AND CAST(p.CreatedAt AS DATE) >= ? ");
        params.add(fromDate);
    }
    
    if (toDate != null && !toDate.isEmpty()) {
        sql.append("AND CAST(p.CreatedAt AS DATE) <= ? ");
        params.add(toDate);
    }
    
    if (search != null && !search.isEmpty()) {
        sql.append("AND (CAST(p.ReservationId AS VARCHAR) LIKE ? OR u.FullName LIKE ?) ");
        params.add("%" + search + "%");
        params.add("%" + search + "%");
    }
    
    sql.append("ORDER BY p.CreatedAt DESC");
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql.toString())) {
        
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Payment payment = new Payment();
            payment.setId(rs.getInt("Id"));
            payment.setReservationId(rs.getInt("ReservationId"));
            payment.setAmount(rs.getDouble("Amount"));
            payment.setMethod(rs.getString("Method"));
            payment.setStatus(rs.getString("Status"));
            payment.setTransactionId(rs.getString("TransactionId"));
            payment.setPaymentType(rs.getString("PaymentType"));
            payment.setCreatedAt(rs.getTimestamp("CreatedAt"));
            payment.setCustomerName(rs.getString("CustomerName"));
            payment.setRoomNumber(rs.getString("RoomNumber"));
            payment.setReservationStatus(rs.getString("ReservationStatus"));
            payments.add(payment);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return payments;
}

public int getPaymentCountByType(String paymentType) {
    String sql = "SELECT COUNT(*) FROM Payments WHERE PaymentType = ?";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, paymentType);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0;
}

public int getPaymentCountByMethodGroup(String methodGroup) {
    String sql = "";
    if ("CARD".equals(methodGroup)) {
        sql = "SELECT COUNT(*) FROM Payments WHERE Method IN ('CREDIT_CARD', 'DEBIT_CARD', 'VNPay', 'MoMo')";
    } else {
        sql = "SELECT COUNT(*) FROM Payments WHERE Method IN ('CASH', 'BANK_TRANSFER')";
    }
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0;
}

public boolean isDepositPaid(int reservationId) {
    String sql = "SELECT COUNT(*) FROM Payments WHERE ReservationId = ? AND PaymentType = 'DEPOSIT' AND Status = 'SUCCESS'";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, reservationId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

public boolean updateDepositStatus(int reservationId, String status) {
    String sql = "UPDATE Reservations SET DepositStatus = ? WHERE Id = ?";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, status);
        ps.setInt(2, reservationId);
        
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}
public List<Payment> getPaymentsByUserId(int userId) {
    List<Payment> payments = new ArrayList<>();
    String sql = "SELECT p.*, r.Status as ReservationStatus FROM Payments p JOIN Reservations r ON p.ReservationId = r.Id WHERE r.UserId = ? ORDER BY p.CreatedAt DESC";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Payment payment = mapResultSetToPayment(rs);
            payment.setReservationStatus(rs.getString("ReservationStatus"));
            payments.add(payment);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return payments;
}
}