<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    // Debug logging
    System.out.println("=== CREDIT-CARD.JSP DEBUG ===");
    
    // Get reservation and payment info with null checking
    model.Reservation reservation = (model.Reservation) request.getAttribute("reservation");
    String paymentId = request.getAttribute("paymentId") != null ? request.getAttribute("paymentId").toString() : null;
    String method = (String) request.getAttribute("method");
    Double fullAmount = (Double) request.getAttribute("amount");
    String reservationIdsStr = (String) request.getAttribute("reservationIdsStr");
    String paymentIdsStr = (String) request.getAttribute("paymentIdsStr");
        java.util.List<model.Reservation> reservationList = (java.util.List<model.Reservation>) request.getAttribute("reservations");
    // Debug print
    System.out.println("Reservation: " + (reservation != null ? reservation.getId() : "NULL"));
    System.out.println("PaymentId: " + paymentId);
    System.out.println("Method: " + method);
    System.out.println("Amount: " + fullAmount);
    
    // Check if required data is missing
    if (reservation == null || paymentId == null || fullAmount == null) {
        System.out.println("ERROR: Missing required data in credit-card.jsp");
        // Log what's missing
        if (reservation == null) System.out.println("- Reservation is NULL");
        if (paymentId == null) System.out.println("- PaymentId is NULL");
        if (fullAmount == null) System.out.println("- Amount is NULL");
        
        // Redirect with error message
        response.sendRedirect(request.getContextPath() + "/SearchAvailableRoomsServlet?error=payment_data_missing");
        return;
    }
    
    // Calculate deposit amount (10%)
    double depositAmount = fullAmount * 0.1;
    
    // Format amounts
    java.text.DecimalFormat formatter = new java.text.DecimalFormat("#,###");
    String formattedFullAmount = formatter.format(fullAmount);
    String formattedDepositAmount = formatter.format(depositAmount);
    String formattedRemainingAmount = formatter.format(fullAmount - depositAmount);
    
    // Get customer email safely
    String customerEmail = "";
    try {
        if (reservation.getCustomerEmail() != null) {
            customerEmail = reservation.getCustomerEmail();
        } else if (reservation.getUserEmail() != null) {
            customerEmail = reservation.getUserEmail();
        }
    } catch (Exception e) {
        System.out.println("Error getting customer email: " + e.getMessage());
    }
    
    System.out.println("Customer Email: " + customerEmail);
    System.out.println("=== END CREDIT-CARD.JSP DEBUG ===");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Credit Card Payment - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .payment-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            max-width: 500px;
            width: 100%;
            overflow: hidden;
        }
        
        .payment-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 2rem;
            text-align: center;
            color: white;
        }
        
        .payment-header h3 {
            margin: 0;
            font-weight: 300;
        }
        
        .payment-body {
            padding: 2rem;
        }
        
        .deposit-notice {
            background: #e8f5e9;
            border: 2px solid #4caf50;
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 2rem;
        }
        
        .deposit-notice h5 {
            color: #2e7d32;
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
        }
        
        .deposit-notice ul {
            margin: 0.5rem 0;
            padding-left: 1.5rem;
        }
        
        .deposit-notice li {
            margin-bottom: 0.25rem;
        }
        
        .amount-breakdown {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 2rem;
        }
        
        .amount-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
            padding: 0.5rem 0;
        }
        
        .amount-row:last-child {
            border-top: 2px solid #dee2e6;
            padding-top: 1rem;
            margin-bottom: 0;
        }
        
        .amount-highlight {
            background: #fff3cd;
            padding: 0.25rem 0.75rem;
            border-radius: 5px;
            font-weight: bold;
            color: #856404;
        }
        
        .credit-card-preview {
            background: linear-gradient(135deg, #434343 0%, #000000 100%);
            color: white;
            padding: 1.5rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
            min-height: 200px;
        }
        
        .credit-card-preview:before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: shine 3s infinite;
        }
        
        @keyframes shine {
            0%, 100% { transform: rotate(0deg); }
            50% { transform: rotate(180deg); }
        }
        
        .card-number-display {
            font-size: 1.5rem;
            letter-spacing: 2px;
            margin: 2rem 0;
            font-family: 'Courier New', monospace;
        }
        
        .card-details {
            display: flex;
            justify-content: space-between;
            margin-top: 2rem;
        }
        
        .card-holder {
            text-transform: uppercase;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            font-weight: 600;
            color: #333;
            margin-bottom: 0.5rem;
        }
        
        .form-control {
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            font-size: 1rem;
            transition: all 0.3s;
        }
        
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .form-row {
            display: flex;
            gap: 1rem;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .accepted-cards {
            display: flex;
            gap: 0.5rem;
            margin-top: 0.5rem;
            font-size: 1.5rem;
        }
        
        .security-badges {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin: 2rem 0;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 10px;
        }
        
        .security-badges img {
            height: 30px;
            opacity: 0.7;
        }
        
        .payment-buttons {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }
        
        .btn-pay {
            flex: 1;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 1rem;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-pay:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-cancel {
            flex: 1;
            background: #f8f9fa;
            color: #666;
            border: 2px solid #e0e0e0;
            padding: 1rem;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-cancel:hover {
            background: #e9ecef;
        }
        
        @media (max-width: 768px) {
            .payment-container {
                margin: 1rem;
            }
            
            .credit-card-preview {
                font-size: 0.9rem;
            }
            
            .card-number-display {
                font-size: 1.2rem;
            }
        }
    </style>
</head>
<body>
    <div class="payment-container">
        <!-- Header -->
        <div class="payment-header">
            <h3><i class="fas fa-credit-card me-2"></i>Credit Card Payment</h3>
            <p class="mb-0">Secure payment processing</p>
        </div>
        
        <div class="payment-body">
            <!-- Deposit Notice -->
            <div class="deposit-notice">
                <h5><i class="fas fa-info-circle me-2"></i>10% Deposit Payment</h5>
                <ul>
                    <li>You only need to pay <strong>10% deposit</strong> now to secure your reservation</li>
                    <li>Deposit amount: <strong><%= formattedDepositAmount %>₫</strong></li>
                    <li>This deposit will be <strong>fully refunded</strong> at check-out</li>
                    <li>Remaining balance can be paid during your stay</li>
                </ul>
            </div>
                    
               <% if (reservationList != null && reservationList.size() > 1) { %>
            <table class="table table-bordered mt-3">
                <thead>
                    <tr>
                        <th>Room</th>
                        <th>Check-in</th>
                        <th>Check-out</th>
                        <th>Amount</th>
                    </tr>
                </thead>
                <tbody>
                <% for (model.Reservation r : reservationList) { %>
                    <tr>
                        <td><%= r.getRoomNumber() %> (<%= r.getRoomTypeName() %>)</td>
                        <td><%= r.getCheckIn() %></td>
                        <td><%= r.getCheckOut() %></td>
                        <td><%= formatter.format(r.getTotalAmount()) %>₫</td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
            <!-- Amount Breakdown -->
            <div class="amount-breakdown">
                <div class="amount-row">
                    <span>Total Booking Amount:</span>
                    <span><%= formattedFullAmount %>₫</span>
                </div>
                <div class="amount-row">
                    <span>Deposit Required (10%):</span>
                    <span class="amount-highlight"><%= formattedDepositAmount %>₫</span>
                </div>
                <div class="amount-row">
                    <span>Remaining Balance:</span>
                    <span><%= formattedRemainingAmount %>₫</span>
                </div>
                <div class="amount-row">
                    <strong>Amount to Pay Now:</strong>
                    <strong class="text-success"><%= formattedDepositAmount %>₫</strong>
                </div>
            </div>
            
            <!-- Credit Card Preview -->
            <div class="credit-card-preview">
                <div style="text-align: right;">
                    <i class="fab fa-cc-visa fa-2x"></i>
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
                <c:if test="${not empty reservationIdsStr}">
                    <input type="hidden" name="reservationIds" value="<%= reservationIdsStr %>">
                </c:if>
                <c:if test="${not empty paymentIdsStr}">
                    <input type="hidden" name="paymentIds" value="<%= paymentIdsStr %>">
                </c:if>
                <input type="hidden" name="method" value="<%= method %>">
                <input type="hidden" name="depositAmount" value="<%= depositAmount %>">
                
                <div class="form-group">
                    <label>Card Number</label>
                    <input type="text" class="form-control" id="cardNumber" name="cardNumber" 
                           placeholder="1234 5678 9012 3456" maxlength="19" required>
                    <div class="accepted-cards">
                        <i class="fab fa-cc-visa"></i>
                        <i class="fab fa-cc-mastercard"></i>
                        <i class="fab fa-cc-amex"></i>
                        <i class="fab fa-cc-discover"></i>
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
                           value="<%= customerEmail %>" required>
                </div>
                
                <div class="form-group">
                    <label>
                        <input type="checkbox" required> 
                        I agree to pay the 10% deposit amount and understand it will be refunded at check-out
                    </label>
                </div>
                
                <!-- Security Badges -->
                <div class="security-badges">
                    <img src="${pageContext.request.contextPath}/assets/images/verified-visa.png" alt="Verified by Visa">
                    <img src="${pageContext.request.contextPath}/assets/images/mastercard-secure.png" alt="Mastercard SecureCode">
                    <img src="${pageContext.request.contextPath}/assets/images/ssl-secure.png" alt="SSL Secure">
                </div>
                
                <!-- Alert for deposit information -->
                <div class="alert alert-info">
                    <i class="fas fa-shield-alt me-2"></i>
                    <strong>Secure Payment:</strong> Your deposit of <%= formattedDepositAmount %>₫ will be fully refunded when you check out.
                </div>
                
                <!-- Payment Buttons -->
                <div class="payment-buttons">
                    <button type="button" class="btn-cancel" onclick="cancelPayment()">
                        <i class="fas fa-times me-2"></i>Cancel
                    </button>
                    <button type="submit" class="btn-pay">
                        <i class="fas fa-lock me-2"></i>Pay Deposit <%= formattedDepositAmount %>₫
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
            
            // Update preview
            if (value.length > 0) {
                let preview = value.substring(0, 4) + ' •••• •••• ' + value.substring(value.length - 4);
                document.getElementById('cardNumberDisplay').textContent = preview;
            } else {
                document.getElementById('cardNumberDisplay').textContent = '•••• •••• •••• ••••';
            }
        });
        
        // Update cardholder name preview
        document.getElementById('cardHolder').addEventListener('input', function(e) {
            let value = e.target.value.toUpperCase();
            document.getElementById('cardHolderDisplay').textContent = value || 'YOUR NAME';
        });
        
        // Format expiry date
        document.getElementById('cardExpiry').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            e.target.value = value;
            document.getElementById('cardExpiryDisplay').textContent = value || 'MM/YY';
        });
        
        // Only allow numbers for CVV
        document.getElementById('cardCVV').addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/\D/g, '');
        });
        
        // Form validation
        document.getElementById('paymentForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Basic validation
            const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
            if (cardNumber.length < 13 || cardNumber.length > 19) {
                alert('Please enter a valid card number');
                return;
            }
            
            const expiry = document.getElementById('cardExpiry').value;
            if (!/^\d{2}\/\d{2}$/.test(expiry)) {
                alert('Please enter expiry date in MM/YY format');
                return;
            }
            
            const cvv = document.getElementById('cardCVV').value;
            if (cvv.length < 3 || cvv.length > 4) {
                alert('Please enter a valid CVV');
                return;
            }
            
            // Show loading
            const submitBtn = e.target.querySelector('.btn-pay');
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
            submitBtn.disabled = true;
            
            // Submit form
            e.target.submit();
        });
        
        function cancelPayment() {
            if (confirm('Are you sure you want to cancel this payment?')) {
                window.location.href = '${pageContext.request.contextPath}/SearchAvailableRoomsServlet';
            }
        }
        
        // Auto-focus first input
        document.getElementById('cardNumber').focus();
    </script>
</body>
</html>