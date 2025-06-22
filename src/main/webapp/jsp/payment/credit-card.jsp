<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.Reservation" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <title>LuxuryHotel - Secure Payment</title>
    
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
        .payment-container {
            max-width: 800px;
            margin: 50px auto;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 0 30px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .payment-header {
            background: #ff6b6b;
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .payment-header h2 {
            margin: 0;
            font-size: 28px;
            font-weight: 600;
        }
        
        .payment-header p {
            margin: 10px 0 0;
            opacity: 0.9;
        }
        
        .payment-body {
            padding: 40px;
        }
        
        .order-summary {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        
        .order-summary h4 {
            margin-bottom: 20px;
            color: #333;
        }
        
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            color: #666;
        }
        
        .summary-total {
            display: flex;
            justify-content: space-between;
            font-size: 20px;
            font-weight: 600;
            color: #333;
            padding-top: 15px;
            border-top: 2px solid #dee2e6;
            margin-top: 15px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #333;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 15px;
            transition: border-color 0.3s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #ff6b6b;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .card-preview {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 30px;
            position: relative;
            min-height: 200px;
        }
        
        .card-number-display {
            font-size: 22px;
            letter-spacing: 3px;
            margin: 30px 0;
        }
        
        .card-details {
            display: flex;
            justify-content: space-between;
            margin-top: 40px;
        }
        
        .card-holder {
            text-transform: uppercase;
            font-size: 14px;
        }
        
        .security-badges {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin: 20px 0;
        }
        
        .security-badges img {
            height: 30px;
        }
        
        .payment-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn-pay {
            flex: 1;
            padding: 15px;
            background: #ff6b6b;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .btn-pay:hover {
            background: #e85555;
        }
        
        .btn-cancel {
            flex: 1;
            padding: 15px;
            background: #6c757d;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .btn-cancel:hover {
            background: #5a6268;
        }
        
        .secure-notice {
            background: #e8f5e9;
            border-left: 4px solid #4caf50;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .secure-notice i {
            color: #4caf50;
            margin-right: 8px;
        }
        
        .loading-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }
        
        .loading-content {
            background: white;
            padding: 40px;
            border-radius: 10px;
            text-align: center;
        }
        
        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #ff6b6b;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .accepted-cards {
            display: flex;
            gap: 10px;
            margin-top: 10px;
        }
        
        .accepted-cards i {
            font-size: 30px;
            color: #666;
        }
    </style>
</head>
<body>
    <%
        Reservation reservation = (Reservation) request.getAttribute("reservation");
        Integer paymentId = (Integer) request.getAttribute("paymentId");
        String method = (String) request.getAttribute("method");
        Double amount = (Double) request.getAttribute("amount");
        
        DecimalFormat df = new DecimalFormat("#,###");
        String formattedAmount = df.format(amount);
    %>
    
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-content">
            <div class="spinner"></div>
            <h3>Processing Payment...</h3>
            <p>Please do not close this window</p>
        </div>
    </div>
    
    <div class="payment-container">
        <!-- Header -->
        <div class="payment-header">
            <h2><i class="fa fa-lock"></i> Secure Payment</h2>
            <p>Complete your booking payment</p>
        </div>
        
        <!-- Body -->
        <div class="payment-body">
            <!-- Security Notice -->
            <div class="secure-notice">
                <i class="fa fa-shield"></i>
                <strong>Secure Payment:</strong> Your payment information is encrypted and secure. We never store your card details.
            </div>
            
            <!-- Order Summary -->
            <div class="order-summary">
                <h4>Order Summary</h4>
                <div class="summary-row">
                    <span>Booking ID:</span>
                    <strong>#<%= reservation.getId() %></strong>
                </div>
                <div class="summary-row">
                    <span>Room:</span>
                    <strong><%= reservation.getRoomNumber() %> - <%= reservation.getRoomTypeName() %></strong>
                </div>
                <div class="summary-row">
                    <span>Check-in:</span>
                    <strong><%= reservation.getCheckIn() %></strong>
                </div>
                <div class="summary-row">
                    <span>Check-out:</span>
                    <strong><%= reservation.getCheckOut() %></strong>
                </div>
                <div class="summary-row">
                    <span>Nights:</span>
                    <strong><%= reservation.calculateNights() %></strong>
                </div>
                <div class="summary-total">
                    <span>Total Amount:</span>
                    <span><%= formattedAmount %>₫</span>
                </div>
            </div>
            
            <!-- Card Preview -->
            <div class="card-preview">
                <div style="text-align: right; margin-bottom: 20px;">
                    <img src="${pageContext.request.contextPath}/assets/images/chip.png" alt="Chip" style="height: 40px;">
                </div>
                <div class="card-number-display" id="cardNumberDisplay">
                    •••• •••• •••• ••••
                </div>
                <div class="card-details">
                    <div>
                        <div style="font-size: 10px; opacity: 0.7;">CARD HOLDER</div>
                        <div class="card-holder" id="cardHolderDisplay">YOUR NAME</div>
                    </div>
                    <div>
                        <div style="font-size: 10px; opacity: 0.7;">EXPIRES</div>
                        <div id="cardExpiryDisplay">MM/YY</div>
                    </div>
                </div>
            </div>
            
            <!-- Payment Form -->
            <form id="paymentForm" action="${pageContext.request.contextPath}/PaymentGateway" method="POST">
                <input type="hidden" name="action" value="processPayment">
                <input type="hidden" name="paymentId" value="<%= paymentId %>">
                <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                <input type="hidden" name="method" value="<%= method %>">
                
                <div class="form-group">
                    <label>Card Number</label>
                    <input type="text" class="form-control" id="cardNumber" name="cardNumber" 
                           placeholder="1234 5678 9012 3456" maxlength="19" required>
                    <div class="accepted-cards">
                        <i class="fa fa-cc-visa"></i>
                        <i class="fa fa-cc-mastercard"></i>
                        <i class="fa fa-cc-amex"></i>
                        <i class="fa fa-cc-discover"></i>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Cardholder Name</label>
                    <input type="text" class="form-control" id="cardHolder" name="cardHolder" 
                           placeholder="John Doe" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Expiry Date</label>
                        <input type="text" class="form-control" id="cardExpiry" name="cardExpiry" 
                               placeholder="MM/YY" maxlength="5" required>
                    </div>
                    <div class="form-group">
                        <label>CVV</label>
                        <input type="text" class="form-control" id="cardCVV" name="cardCVV" 
                               placeholder="123" maxlength="4" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Email (for receipt)</label>
                    <input type="email" class="form-control" name="email" 
                           value="<%= reservation.getCustomerEmail() %>" required>
                </div>
                
                <div class="form-group">
                    <label>
                        <input type="checkbox" required> 
                        I agree to the <a href="#" style="color: #ff6b6b;">terms and conditions</a>
                    </label>
                </div>
                
                <!-- Security Badges -->
                <div class="security-badges">
                    <img src="${pageContext.request.contextPath}/assets/images/verified-visa.png" alt="Verified by Visa">
                    <img src="${pageContext.request.contextPath}/assets/images/mastercard-secure.png" alt="Mastercard SecureCode">
                    <img src="${pageContext.request.contextPath}/assets/images/ssl-secure.png" alt="SSL Secure">
                </div>
                
                <!-- Payment Buttons -->
                <div class="payment-buttons">
                    <button type="button" class="btn-cancel" onclick="cancelPayment()">
                        <i class="fa fa-times"></i> Cancel
                    </button>
                    <button type="submit" class="btn-pay">
                        <i class="fa fa-lock"></i> Pay <%= formattedAmount %>₫
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- JavaScript -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script>
        // Format card number with spaces
        document.getElementById('cardNumber').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s/g, '');
            let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
            e.target.value = formattedValue;
            
            // Update card preview
            if (value.length >= 4) {
                let display = '';
                for (let i = 0; i < value.length; i++) {
                    if (i < value.length - 4) {
                        display += '•';
                    } else {
                        display += value[i];
                    }
                    if ((i + 1) % 4 === 0 && i < value.length - 1) {
                        display += ' ';
                    }
                }
                document.getElementById('cardNumberDisplay').textContent = display;
            }
        });
        
        // Update cardholder name preview
        document.getElementById('cardHolder').addEventListener('input', function(e) {
            const display = document.getElementById('cardHolderDisplay');
            display.textContent = e.target.value.toUpperCase() || 'YOUR NAME';
        });
        
        // Format expiry date
        document.getElementById('cardExpiry').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.slice(0, 2) + '/' + value.slice(2, 4);
            }
            e.target.value = value;
            
            // Update card preview
            document.getElementById('cardExpiryDisplay').textContent = value || 'MM/YY';
        });
        
        // Allow only numbers for CVV
        document.getElementById('cardCVV').addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/\D/g, '');
        });
        
        // Form submission
        document.getElementById('paymentForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Basic validation
            const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
            if (cardNumber.length < 13 || cardNumber.length > 19) {
                alert('Please enter a valid card number');
                return;
            }
            
            const expiry = document.getElementById('cardExpiry').value;
            const [month, year] = expiry.split('/');
            if (!month || !year || month < 1 || month > 12) {
                alert('Please enter a valid expiry date');
                return;
            }
            
            const cvv = document.getElementById('cardCVV').value;
            if (cvv.length < 3 || cvv.length > 4) {
                alert('Please enter a valid CVV');
                return;
            }
            
            // Show loading overlay
            document.getElementById('loadingOverlay').style.display = 'flex';
            
            // Submit form
            this.submit();
        });
        
        function cancelPayment() {
            if (confirm('Are you sure you want to cancel this payment?')) {
                window.location.href = '${pageContext.request.contextPath}/RoomListServlet';
            }
        }
        
        // Auto-focus first input
        document.getElementById('cardNumber').focus();
    </script>
</body>
</html>