/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;


import model.InspectionItem;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ASUS
 */
public class InspectionDAO {
      public int getOrCreateInspection(int reservationId, int inspectorId) throws SQLException {
        String selectSql = "SELECT Id FROM RoomInspections WHERE ReservationId = ? AND Status = 'PENDING'";
        String insertSql = "INSERT INTO RoomInspections (ReservationId, InspectorId, InspectionTime, RoomCondition, CleanlinessScore, Notes, Status) " +
                           "VALUES (?, ?, GETDATE(), 'UNKNOWN', 0, NULL, 'PENDING')";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {

            selectStmt.setInt(1, reservationId);
            ResultSet rs = selectStmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("Id");
            }

            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                insertStmt.setInt(1, reservationId);
                insertStmt.setInt(2, inspectorId);
                insertStmt.executeUpdate();

                ResultSet generatedKeys = insertStmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating inspection failed, no ID obtained.");
                }
            }
        }
    }

    public boolean insertInspectionItem(int inspectionId, String itemName, String category,
                                        int quantity, BigDecimal unitPrice, String notes) throws SQLException {
        String sql = "INSERT INTO InspectionItems (InspectionId, ItemName, ItemCategory, Quantity, UnitPrice, Notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, inspectionId);
            stmt.setString(2, itemName);
            stmt.setString(3, category);
            stmt.setInt(4, quantity);
            stmt.setBigDecimal(5, unitPrice);
            stmt.setString(6, notes);

            int rows = stmt.executeUpdate();
            return rows > 0;
        }
    }

    public List<InspectionItem> getInspectionItems(int inspectionId) throws SQLException {
        String sql = "SELECT * FROM InspectionItems WHERE InspectionId = ?";
        List<InspectionItem> list = new ArrayList<>();

        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, inspectionId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                InspectionItem item = new InspectionItem();
                item.setId(rs.getInt("Id"));
                item.setInspectionId(rs.getInt("InspectionId"));
                item.setItemName(rs.getString("ItemName"));
                item.setItemCategory(rs.getString("ItemCategory"));
                item.setQuantity(rs.getInt("Quantity"));
                item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                item.setNotes(rs.getString("Notes"));

                list.add(item);
            }
        }

        return list;
    }
}
