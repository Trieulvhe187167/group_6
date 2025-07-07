<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <title>LuxuryHotel - Payment Failed</title>
    
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
        
        .error-container {
            background: white;
            padding: 60px;
            border-radius: 10px;
            box-shadow: 0 0 30px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 100%;
        }
        
        .error-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 30px;
            background: #dc3545;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: shake 0.5s;
        }
        
        .error-icon i {
            font-size: 50px;
            color: white;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-10px); }
            20%, 40%, 60%, 80% { transform: translateX(10px); }
        }
        
        h2 {
            color: #dc3545;
            margin-bottom: 20px;
            font-weight: 600;
        }
        
        .error-message {
            color: #666;
            margin-bottom: 30px;
            font-size: 16px;
            line-height: 1.6;
        }
        
        .error-details {
            background: #fff5f5;
            border: 1px solid #f5c6cb;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 30px;
            color: #721c24;
            text-align: left;
        }
        
        .error-details h4 {
            margin-bottom: 10px;
            font-size: 16px;
        }
        
        .error-details ul {
            margin: 0;
            padding-left: 20px;
        }
        
        .error-details li {
            margin-bottom: 5px;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
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
        
        .support-info {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid #dee2e6;
            color: #666;
            font-size: 14px;
        }
        
        .support-info i {
            color: #ff6b6b;
            margin-right: 5px;
        }
    </style>
</head>
<body>
    <%
        String error = (String) request.getAttribute("error");
        Integer reservationId = (Integer) request.getAttribute("reservationId");
    %>
    
    <div class="error-container">
        <div class="error-icon">
            <i class="fa fa-times"></i>
        </div>
        
        <h2>Payment Failed</h2>
        
        <div class="error-message">
            <% if (error != null && !error.isEmpty()) { %>
                <%= error %>
            <% } else { %>
                We're sorry, but your payment could not be processed at this time.
            <% } %>
        </div>
        
        <div class="error-details">
            <h4>Common reasons for payment failure:</h4>
            <ul>
                <li>Insufficient funds in your account</li>
                <li>Incorrect card information entered</li>
                <li>Card expired or not activated</li>
                <li>Transaction limit exceeded</li>
                <li>Technical issues with payment gateway</li>
            </ul>
        </div>
        
        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/SearchAvailableRoomsServlet" class="btn btn-secondary">
                <i class="fa fa-arrow-left"></i> Back to Rooms
            </a>
            <% if (reservationId != null) { %>
                <a href="${pageContext.request.contextPath}/RetryPayment?reservationId=<%= reservationId %>" class="btn btn-primary">
                    <i class="fa fa-refresh"></i> Try Again
                </a>
            <% } %>
        </div>
        
        <div class="support-info">
            <p><i class="fa fa-phone"></i> Need help? Call us at <strong>1900-1234</strong></p>
            <p><i class="fa fa-envelope"></i> Or email: <strong>support@luxuryhotel.com</strong></p>
        </div>
    </div>
</body>
</html>