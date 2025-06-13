<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Reservation" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Booking Management</title>
    <!-- CSS giữ nguyên từ giao diện cũ -->
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        /* Có thể tùy chỉnh thêm nếu cần */
        .table th, .table td {
            vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4 text-center">Danh sách đặt phòng</h2>

    <table class="table table-bordered table-striped">
        <thead class="table-dark">
            <tr>
                <th>ID</th>
                <th>User ID</th>
                <th>Room ID</th>
                <th>Check-In</th>
                <th>Check-Out</th>
                <th>Status</th>
                <th>Total Amount (VND)</th>
                <th>Created At</th>
            </tr>
        </thead>
        <tbody>
        <%
            List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
            if (reservations != null && !reservations.isEmpty()) {
                for (Reservation r : reservations) {
        %>
            <tr>
                <td><%= r.getId() %></td>
                <td><%= r.getUserId() %></td>
                <td><%= r.getRoomId() %></td>
                <td><%= r.getCheckIn() %></td>
                <td><%= r.getCheckOut() %></td>
                <td>
                    <% if ("CONFIRMED".equalsIgnoreCase(r.getStatus())) { %>
                        <span class="badge bg-success">Confirmed</span>
                    <% } else if ("PENDING".equalsIgnoreCase(r.getStatus())) { %>
                        <span class="badge bg-warning text-dark">Pending</span>
                    <% } else { %>
                        <span class="badge bg-secondary"><%= r.getStatus() %></span>
                    <% } %>
                </td>
                <td><%= String.format("%,.0f", r.getTotalAmount()) %></td>
                <td><%= r.getCreatedAt() %></td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="8" class="text-center">Không có dữ liệu đặt phòng.</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
</div>

<!-- JS giữ nguyên từ giao diện cũ -->
<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.bundle.min.js"></script>
</body>
</html>
