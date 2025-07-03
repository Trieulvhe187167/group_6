<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Booking Detail</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f6f9;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 800px;
            margin: 40px auto;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }

        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }

        .section {
            margin-bottom: 25px;
        }

        .section h4 {
            margin-bottom: 10px;
            color: #555;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
        }

        .info-row {
            margin-bottom: 8px;
        }

        .info-label {
            font-weight: bold;
            color: #444;
            display: inline-block;
            width: 150px;
        }

        .back-button {
            display: block;
            width: 120px;
            margin: 30px auto 0;
            padding: 10px 15px;
            text-align: center;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            transition: background-color 0.2s ease-in-out;
        }

        .back-button:hover {
            background-color: #0056b3;
        }

        .badge {
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.85rem;
            color: white;
        }

        .badge.confirmed { background-color: #28a745; }
        .badge.pending { background-color: #ffc107; color: black; }
        .badge.cancelled { background-color: #dc3545; }
    </style>
</head>
<body>
<div class="container">
    <h2>Reservation Detail</h2>

    <div class="section">
        <h4>Customer Information</h4>
        <div class="info-row"><span class="info-label">Name:</span> ${booking.userFullName}</div>
        <div class="info-row"><span class="info-label">Email:</span> ${booking.userEmail}</div>
        <div class="info-row"><span class="info-label">Phone:</span> ${booking.customerPhone}</div>
    </div>

    <div class="section">
        <h4>Booking Information</h4>
        <div class="info-row"><span class="info-label">Booking ID:</span> #${booking.id}</div>
        <div class="info-row"><span class="info-label">Status:</span>
            <span class="badge ${booking.status.toLowerCase()}">${booking.status}</span>
        </div>
        <div class="info-row"><span class="info-label">Created At:</span> <fmt:formatDate value="${booking.createdAt}" pattern="MMM dd, yyyy HH:mm" /></div>
        <div class="info-row"><span class="info-label">Check-in:</span> <fmt:formatDate value="${booking.checkIn}" pattern="MMM dd, yyyy" /></div>
        <div class="info-row"><span class="info-label">Check-out:</span> <fmt:formatDate value="${booking.checkOut}" pattern="MMM dd, yyyy" /></div>
        <div class="info-row"><span class="info-label">Nights:</span> ${booking.nights}</div>
    </div>

    <div class="section">
        <h4>Room & Payment</h4>
        <div class="info-row"><span class="info-label">Room:</span> ${booking.roomNumber} - ${booking.roomTypeName}</div>
        <div class="info-row"><span class="info-label">Total Amount:</span> <fmt:formatNumber value="${booking.totalAmount}" type="currency" /></div>
        <div class="info-row"><span class="info-label">Payment Status:</span> ${booking.paymentStatus}</div>
    </div>

 

    <a href="${pageContext.request.contextPath}/customer/bookings" class="back-button">← Back</a>
</div>

</body>
</html>
