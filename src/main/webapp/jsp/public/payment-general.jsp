<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.Reservation" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <title>LuxuryHotel - Payment Processing</title>
    
    <!-- Favicons -->
    <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
    
    <!-- CSS -->
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    
    <style>
        body {
            background: #f8f9fa;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
        }
        
        .payment-processing {
            background: white;
            padding: 60px;
            border-radius: 10px;
            box-shadow: 0 0 30px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 100%;
        }
        
        .payment-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 30px;
            background: #ff6b6b;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: pulse 2s infinite;
        }
        
        .payment-icon i {
            font-size: 50px;
            color: white;
        }
        
        @keyframes pulse {
            0% {
                transform: scale(1);
                opacity: 1;
            }
            50% {
                transform: scale(1.1);
                opacity: 0.8;
            }
            100% {
                transform: scale(1);
                opacity: 1;
            }
        }
        
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #ff6b6b;
            border-radius: 50%;
            width: 60px;
            height: 60px;
            animation: spin 1s linear infinite;
            margin: 0 auto 30px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        h2 {
            color: #333;
            margin-bottom: 20px;
            font-weight: 600;
        }
        
        .payment-details {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 30px 0;
            text-align: left;
        }
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            color: #666;
        }
        
        .detail-row:last-child {
            margin-bottom: 0;
            padding-top: 10px;
            border-top: 1px solid #dee2e6;
            font-weight: 600;
            color: #333;
            font-size: 18px;
        }
        
        .status-message {
            color: #666;
            margin-bottom: 30px;
            font-size: 16px;
        }
        
        .action-buttons {
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            margin: 0 10px;
        }
        
        .btn-primary {
            background: #ff6b6b;
            color: white;
        }
        
        .btn-primary:hover {
            background: #e85555;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
        }
        
        .redirect-notice {
            margin-top: 20px;
            color: #999;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <%
        Reservation reservation = (Reservation) request.getAttribute("reservation");
        Integer paymentId = (Integer) request.getAttribute("paymentId");
        String method = (String) request.getAttribute("method");
        Double amount = (Double) request.getAttribute("amount");
        String reservationIdsStr = (String) request.getAttribute("reservationIdsStr");
        String paymentIdsStr = (String) request.getAttribute("paymentIdsStr");
        DecimalFormat df = new DecimalFormat("#,###");
        String formattedAmount = df.format(amount);
        
        // For cash payment, skip processing
        boolean isCashPayment = "CASH".equals(method);
    %>
    
    <div class="payment-processing">
        <% if (isCashPayment) { %>
            <!-- Cash Payment -->
            <div class="payment-icon">
                <i class="fa fa-money"></i>
            </div>
            
            <h2>Cash Payment Selected</h2>
            
            <div class="status-message">
                Your booking has been confirmed. Please pay at the hotel reception during check-in.
            </div>
            
            <div class="payment-details">
                <div class="detail-row">
                    <span>Booking ID:</span>
                    <strong>#<%= reservation.getId() %></strong>
                </div>
                <div class="detail-row">
                    <span>Room:</span>
                    <strong><%= reservation.getRoomNumber() %></strong>
                </div>
                <div class="detail-row">
                    <span>Check-in Date:</span>
                    <strong><%= reservation.getCheckIn() %></strong>
                </div>
                <div class="detail-row">
                    <span>Total Amount Due:</span>
                    <strong><%= formattedAmount %>₫</strong>
                </div>
            </div>
            
            <form action="${pageContext.request.contextPath}/PaymentGateway" method="POST" id="cashForm">
                <input type="hidden" name="action" value="processPayment">
                <input type="hidden" name="paymentId" value="<%= paymentId %>">
                <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                 <c:if test="${not empty reservationIdsStr}">
                    <input type="hidden" name="reservationIds" value="<%= reservationIdsStr %>">
                </c:if>
                <c:if test="${not empty paymentIdsStr}">
                    <input type="hidden" name="paymentIds" value="<%= paymentIdsStr %>">
                </c:if>
                <input type="hidden" name="method" value="<%= method %>">
            </form>
            
            <div class="action-buttons">
                <button type="submit" form="cashForm" class="btn btn-primary">
                    <i class="fa fa-check"></i> Confirm Booking
                </button>
            </div>
            
        <% } else { %>
            <!-- Other Payment Methods -->
            <div class="spinner"></div>
            
            <h2>Processing Payment...</h2>
            
            <div class="status-message">
                Please wait while we process your payment. Do not close this window.
            </div>
            
            <div class="payment-details">
                <div class="detail-row">
                    <span>Payment Method:</span>
                    <strong><%= method %></strong>
                </div>
                <div class="detail-row">
                    <span>Booking ID:</span>
                    <strong>#<%= reservation.getId() %></strong>
                </div>
                <div class="detail-row">
                    <span>Amount:</span>
                    <strong><%= formattedAmount %>₫</strong>
                </div>
            </div>
            
            <div class="redirect-notice">
                <i class="fa fa-info-circle"></i> 
                Redirecting to payment gateway...
            </div>
            
            <!-- Auto-submit form for payment processing -->
            <form action="${pageContext.request.contextPath}/PaymentGateway" method="POST" id="autoForm">
                <input type="hidden" name="action" value="processPayment">
                <input type="hidden" name="paymentId" value="<%= paymentId %>">
                <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                <c:if test="${not empty reservationIdsStr}">
                    <input type="hidden" name="reservationIds" value="<%= reservationIdsStr %>">
                </c:if>
                <c:if test="${not empty paymentIdsStr}">
                    <input type="hidden" name="paymentIds" value="<%= paymentIdsStr %>">
                </c:if>
                <input type="hidden" name="method" value="<%= method %>">
            </form>
            
            <script>
                // Auto-submit after 2 seconds for demo
                setTimeout(function() {
                    document.getElementById('autoForm').submit();
                }, 2000);
            </script>
        <% } %>
    </div>
</body>
</html>