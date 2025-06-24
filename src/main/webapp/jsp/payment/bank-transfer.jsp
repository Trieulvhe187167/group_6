<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    // Simple setup - use provided QR image URL
    String transferContent = "";
    String accountNumber = "1024520090";
    String accountHolder = "LE VAN TRIEU";
    
    try {
        Object paymentIdObj = request.getAttribute("paymentId");
        Object reservationObj = request.getAttribute("reservation");
        Object amountObj = request.getAttribute("amount");
        
        if (paymentIdObj != null && reservationObj != null && amountObj != null) {
            model.Reservation res = (model.Reservation) reservationObj;
            String customerName = res.getCustomerName() != null ? res.getCustomerName() : "CUSTOMER";
            
            // Simple transfer content: Reservation ID + Customer Name
            transferContent = res.getId() + " " + customerName;
            
            // Set attributes
            request.setAttribute("accountNumber", accountNumber);
            request.setAttribute("accountHolder", accountHolder);
            request.setAttribute("transferContent", transferContent);
        }
    } catch (Exception e) {
        System.out.println("Setup error: " + e.getMessage());
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Transfer Payment - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .payment-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
            margin: 2rem auto;
            max-width: 800px;
        }
        
        .payment-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .payment-header h2 {
            margin: 0;
            font-weight: 300;
        }
        
        .payment-body {
            padding: 2rem;
        }
        
        .section {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border-left: 4px solid #667eea;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.75rem;
            padding: 0.5rem 0;
            border-bottom: 1px solid #dee2e6;
        }
        
        .info-row:last-child {
            border-bottom: none;
            border-top: 2px solid #667eea;
            padding-top: 1rem;
            margin-top: 1rem;
            font-weight: 600;
            color: #667eea;
        }
        
        .amount-display {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1.5rem;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .amount-display h4 {
            margin: 0;
            font-weight: 300;
        }
        
        .amount-display .amount {
            font-size: 2.5rem;
            font-weight: 600;
            margin-top: 0.5rem;
        }
        
        .bank-detail {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding: 1rem;
            background: white;
            border-radius: 8px;
            border: 1px solid #dee2e6;
            transition: all 0.3s ease;
        }
        
        .bank-detail:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transform: translateY(-1px);
        }
        
        .bank-label {
            font-weight: 600;
            color: #495057;
            flex: 1;
        }
        
        .bank-value {
            font-family: 'Courier New', monospace;
            font-weight: 600;
            color: #212529;
            flex: 2;
            text-align: right;
            margin-right: 1rem;
            word-break: break-all;
        }
        
        .copy-btn {
            background: #667eea;
            border: none;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.3s ease;
            min-width: 80px;
        }
        
        .copy-btn:hover {
            background: #5a6fd8;
            transform: translateY(-1px);
        }
        
        .qr-section {
            text-align: center;
            background: #f8f9fa;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
            border: 2px dashed #dee2e6;
        }
        
        .qr-image {
            border: 3px solid #667eea;
            border-radius: 15px;
            padding: 15px;
            background: white;
            display: inline-block;
            margin: 1rem 0;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .instruction-card {
            background: #e3f2fd;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border-left: 4px solid #2196f3;
        }
        
        .instruction-card h5 {
            color: #1976d2;
            margin-bottom: 1rem;
        }
        
        .instruction-list {
            margin: 0;
            padding-left: 1.2rem;
        }
        
        .instruction-list li {
            margin-bottom: 0.7rem;
            color: #424242;
            line-height: 1.5;
        }
        
        .confirm-section {
            background: #fff3cd;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border-left: 4px solid #ffc107;
        }
        
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 0.75rem 2rem;
            border-radius: 25px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: #6c757d;
            border: none;
            padding: 0.75rem 2rem;
            border-radius: 25px;
            font-weight: 600;
        }
        
        .countdown {
            font-size: 1.3rem;
            font-weight: 700;
            color: #dc3545;
        }
        
        .alert-info {
            border-left: 4px solid #17a2b8;
        }
        
        .qr-placeholder {
            border: 2px dashed #dee2e6;
            border-radius: 15px;
            padding: 3rem 2rem;
            background: #f8f9fa;
            min-height: 300px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        
       .qr img {
    padding: 20px;
    background: white;
    border-radius: 20px;
    box-shadow: 0 8px 25px rgba(0,0,0,0.15);
    transition: all 0.3s ease;
}

.qr img {
    max-width: 500px;
    max-height: 5000px;
    border-radius: 10px;
}
        
        @media (max-width: 768px) {
            .payment-container {
                margin: 1rem;
            }
            
            .bank-detail {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .bank-value {
                text-align: left;
                margin: 0.5rem 0;
            }
            
            .copy-btn {
                align-self: flex-end;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="payment-container">
            <!-- Header -->
            <div class="payment-header">
                <h2><i class="fas fa-university me-2"></i>Bank Transfer Payment</h2>
                <p class="mb-0">Secure bank transfer for your reservation</p>
            </div>
            
            <div class="payment-body">
                <!-- Reservation Info -->
                <div class="section">
                    <h5 class="mb-3"><i class="fas fa-info-circle me-2"></i>Reservation Details</h5>
                    <div class="info-row">
                        <span>Reservation ID:</span>
                        <span><strong>#<c:out value="${reservation.id}"/></strong></span>
                    </div>
                    <div class="info-row">
                        <span>Customer:</span>
                        <span><c:out value="${reservation.customerName}"/></span>
                    </div>
                    <div class="info-row">
                        <span>Room:</span>
                        <span><c:out value="${reservation.roomNumber}"/> (<c:out value="${reservation.roomTypeName}"/>)</span>
                    </div>
                    <c:if test="${not empty reservation.checkIn}">
                    <div class="info-row">
                        <span>Check-in:</span>
                        <span><fmt:formatDate value="${reservation.checkIn}" pattern="dd/MM/yyyy"/></span>
                    </div>
                    </c:if>
                    <c:if test="${not empty reservation.checkOut}">
                    <div class="info-row">
                        <span>Check-out:</span>
                        <span><fmt:formatDate value="${reservation.checkOut}" pattern="dd/MM/yyyy"/></span>
                    </div>
                    </c:if>
                    <div class="info-row">
                        <span>Total Amount:</span>
                        <span><fmt:formatNumber value="${amount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                    </div>
                </div>
                
                <!-- Amount Display -->
                <div class="amount-display">
                    <h4>Amount to Transfer</h4>
                    <div class="amount">
                        <fmt:formatNumber value="${amount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                    </div>
                </div>
                
                <!-- Bank Details -->
                <div class="section">
                    <h5 class="mb-3"><i class="fas fa-building-columns me-2"></i>Bank Account Details</h5>
                    
                    <div class="bank-detail">
                        <div class="bank-label">Bank Name:</div>
                        <div class="bank-value">Vietcombank (VCB)</div>
                        <button type="button" class="copy-btn" onclick="copyToClipboard('Vietcombank')">
                            <i class="fas fa-copy me-1"></i>Copy
                        </button>
                    </div>
                    
                    <div class="bank-detail">
                        <div class="bank-label">Account Number:</div>
                        <div class="bank-value">1024520090</div>
                        <button type="button" class="copy-btn" onclick="copyToClipboard('1024520090')">
                            <i class="fas fa-copy me-1"></i>Copy
                        </button>
                    </div>
                    
                    <div class="bank-detail">
                        <div class="bank-label">Account Holder:</div>
                        <div class="bank-value">LE VAN TRIEU</div>
                        <button type="button" class="copy-btn" onclick="copyToClipboard('LE VAN TRIEU')">
                            <i class="fas fa-copy me-1"></i>Copy
                        </button>
                    </div>
                    
                    <div class="bank-detail">
                        <div class="bank-label">Transfer Content:</div>
                        <div class="bank-value"><%= transferContent %></div>
                        <button type="button" class="copy-btn" onclick="copyToClipboard('<%= transferContent %>')">
                            <i class="fas fa-copy me-1"></i>Copy
                        </button>
                    </div>
                    
                    <div class="bank-detail">
                        <div class="bank-label">Amount:</div>
                        <div class="bank-value"><fmt:formatNumber value="${amount}" pattern="#,###"/> VND</div>
                        <button type="button" class="copy-btn" onclick="copyToClipboard('<fmt:formatNumber value="${amount}" pattern="#,###"/>')">
                            <i class="fas fa-copy me-1"></i>Copy
                        </button>
                    </div>
                </div>
                
                <!-- QR Code Section -->
                <div class="qr-section">
                    <h5 class="mb-3"><i class="fas fa-qrcode me-2"></i>QR Code</h5>
                    
                    <!-- QR Code Display -->
                    <div id="qr-display" class="qr">
                       <img src="${pageContext.request.contextPath}/assets/images/uploads/qr.jpg" >
                         
                   
                        
            
                        
                       
                    </div>
                    
                    <!-- QR Status Messages -->
                    <div id="qr-success" style="display: none;" class="alert alert-success">
                        <i class="fas fa-check-circle me-2"></i>
                        <strong>QR Code loaded successfully!</strong> Customers can scan this code to transfer money.
                    </div>
                    
                    <div id="qr-error" style="display: none;" class="alert alert-danger">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <strong>Failed to load QR code.</strong> Please check the URL or try a different image.
                        <div class="mt-2">
                            <button class="btn btn-sm btn-outline-primary" onclick="retryQR()">
                                <i class="fas fa-refresh me-1"></i>Retry
                            </button>
                        </div>
                    </div>
                    
                    <!-- Transfer Information -->
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        <strong>Transfer Information:</strong><br>
                        <strong>Amount:</strong> <fmt:formatNumber value="${amount}" pattern="#,###"/> VND<br>
                        <strong>Content:</strong> <%= transferContent %><br>
                        <small class="text-muted">Make sure your QR code includes the correct amount and transfer content above.</small>
                    </div>
                    
                    <!-- Manual Transfer Instructions -->
                    <div class="alert alert-warning">
                        <i class="fas fa-hand-point-right me-2"></i>
                        <strong>No QR Code?</strong> No problem! Use the bank details above for manual transfer.
                    </div>
                </div>
                
                <!-- Instructions -->
                <div class="instruction-card">
                    <h5><i class="fas fa-list-check me-2"></i>Transfer Instructions</h5>
                    <ol class="instruction-list">
                        <li>Open your mobile banking app or internet banking</li>
                        <li>Select <strong>"Transfer to another bank"</strong> or <strong>"Interbank Transfer"</strong></li>
                        <li>Enter the bank account details provided above or scan the QR code</li>
                        <li><strong>Important:</strong> Use the exact transfer content: <code><%= transferContent %></code></li>
                        <li>Enter the amount: <strong><fmt:formatNumber value="${amount}" pattern="#,###"/> VND</strong></li>
                        <li>Complete the transfer and save your transaction receipt</li>
                        <li>Your reservation will be automatically confirmed after payment is received</li>
                    </ol>
                    
                    <div class="alert alert-success mt-3 mb-0">
                        <i class="fas fa-info-circle me-2"></i>
                        <strong>Note:</strong> After completing the transfer, your reservation status will be updated automatically. 
                        Please keep your transaction receipt for records.
                    </div>
                </div>
                
                <!-- Payment Information Summary -->
                <div class="section">
                    <h5><i class="fas fa-receipt me-2"></i>Payment Summary</h5>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="info-row">
                                <span>Transfer Amount:</span>
                                <span><strong><fmt:formatNumber value="${amount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong></span>
                            </div>
                            <div class="info-row">
                                <span>Transfer Content:</span>
                                <span><code><%= transferContent %></code></span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-row">
                                <span>Bank:</span>
                                <span>Vietcombank (VCB)</span>
                            </div>
                            <div class="info-row">
                                <span>Account:</span>
                                <span><%= accountNumber %></span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Action Buttons -->
                <div class="d-flex justify-content-between flex-wrap gap-2">
                    <button type="button" class="btn btn-secondary" onclick="history.back()">
                        <i class="fas fa-arrow-left me-2"></i>Back to Payment Options
                    </button>
                    
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-primary" onclick="copyTransferInfo()">
                            <i class="fas fa-copy me-2"></i>Copy Transfer Info
                        </button>
                        
                        <a href="BookingManagement" class="btn btn-primary">
                            <i class="fas fa-list me-2"></i>View My Reservations
                        </a>
                    </div>
                </div>
                
               
            </div>
        </div>
    </div>
    
    <!-- Toast Container -->
    <div class="toast-container"></div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Copy to clipboard
        function copyToClipboard(text) {
            if (navigator.clipboard) {
                navigator.clipboard.writeText(text).then(function() {
                    showToast('Copied to clipboard!', 'success');
                }).catch(function(err) {
                    showToast('Failed to copy. Please copy manually.', 'error');
                });
            } else {
                // Fallback
                var textArea = document.createElement('textarea');
                textArea.value = text;
                document.body.appendChild(textArea);
                textArea.select();
                try {
                    document.execCommand('copy');
                    showToast('Copied to clipboard!', 'success');
                } catch (err) {
                    showToast('Failed to copy. Please copy manually.', 'error');
                }
                document.body.removeChild(textArea);
            }
        }
        
        // Toast notification
        function showToast(message, type) {
            var toast = document.createElement('div');
            var alertClass = (type === 'success') ? 'success' : 'danger';
            var iconClass = (type === 'success') ? 'check' : 'exclamation-triangle';
            
            toast.className = 'alert alert-' + alertClass + ' alert-dismissible fade show';
            toast.style.cssText = 'min-width: 300px; margin-bottom: 1rem;';
            toast.innerHTML = '<i class="fas fa-' + iconClass + ' me-2"></i>' + message +
                '<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>';
            
            document.querySelector('.toast-container').appendChild(toast);
            
            setTimeout(function() {
                if (toast.parentNode) {
                    toast.remove();
                }
            }, 3000);
        }
        
        // QR Code Management Functions
        function showQRInput() {
            document.getElementById('qr-input-section').style.display = 'block';
            document.getElementById('qr-url-input').focus();
        }
        
        function cancelQRInput() {
            document.getElementById('qr-input-section').style.display = 'none';
            document.getElementById('qr-url-input').value = '';
            document.getElementById('qr-preview').style.display = 'none';
        }
        
        function previewQR() {
            var url = document.getElementById('qr-url-input').value.trim();
            if (url && isValidURL(url)) {
                var preview = document.getElementById('qr-preview');
                var previewImg = document.getElementById('qr-preview-img');
                
                previewImg.onload = function() {
                    preview.style.display = 'block';
                };
                previewImg.onerror = function() {
                    showToast('Invalid image URL', 'error');
                    preview.style.display = 'none';
                };
                previewImg.src = url;
            }
        }
        
        function loadQR() {
            var url = document.getElementById('qr-url-input').value.trim();
            
            if (!url) {
                showToast('Please enter a QR code URL', 'error');
                return;
            }
            
            if (!isValidURL(url)) {
                showToast('Please enter a valid URL', 'error');
                return;
            }
            
            // Load the QR image
            var qrImage = document.getElementById('qr-image');
            qrImage.src = url;
            
            // Hide input section
            cancelQRInput();
            
            showToast('Loading QR code...', 'info');
        }
        
        function handleQRSuccess() {
            // Show custom QR display
            document.getElementById('default-qr').style.display = 'none';
            document.getElementById('custom-qr').style.display = 'block';
            
            // Show success message
            document.getElementById('qr-success').style.display = 'block';
            document.getElementById('qr-error').style.display = 'none';
            
            showToast('QR code loaded successfully!', 'success');
        }
        
        function handleQRError() {
            // Show error message
            document.getElementById('qr-error').style.display = 'block';
            document.getElementById('qr-success').style.display = 'none';
            
            showToast('Failed to load QR code', 'error');
        }
        
        function changeQR() {
            showQRInput();
        }
        
        function removeQR() {
            // Reset to default state
            document.getElementById('default-qr').style.display = 'block';
            document.getElementById('custom-qr').style.display = 'none';
            document.getElementById('qr-success').style.display = 'none';
            document.getElementById('qr-error').style.display = 'none';
            
            // Clear image
            document.getElementById('qr-image').src = '';
            
            showToast('QR code removed', 'info');
        }
        
        function retryQR() {
            var currentSrc = document.getElementById('qr-image').src;
            if (currentSrc) {
                // Force reload by adding timestamp
                document.getElementById('qr-image').src = currentSrc + '?t=' + new Date().getTime();
            } else {
                showQRInput();
            }
        }
        
        function isValidURL(string) {
            try {
                new URL(string);
                return true;
            } catch (_) {
                return false;
            }
        }
        
        // Auto-detect paste and preview
        document.addEventListener('DOMContentLoaded', function() {
            var input = document.getElementById('qr-url-input');
            if (input) {
                input.addEventListener('input', function() {
                    setTimeout(previewQR, 500); // Delay to allow full paste
                });
            }
        });
        
        // Copy transfer information
        function copyTransferInfo() {
            var transferInfo = 
                'Bank: Vietcombank (VCB)\n' +
                'Account: <%= accountNumber %>\n' +
                'Account Holder: <%= accountHolder %>\n' +
                'Amount: <fmt:formatNumber value="${amount}" pattern="#,###"/> VND\n' +
                'Content: <%= transferContent %>';
            
            copyToClipboard(transferInfo);
        }
        
        // Enable/disable confirm button
        document.addEventListener('DOMContentLoaded', function() {
            // Remove confirm button functionality since we removed the form
            console.log('Bank transfer page loaded');
        });
        
        // Countdown timer (simplified)
        var timeLeft = 15 * 60;
        
        function updateCountdown() {
            var minutes = Math.floor(timeLeft / 60);
            var seconds = timeLeft % 60;
            
            var minutesStr = minutes < 10 ? '0' + minutes : minutes;
            var secondsStr = seconds < 10 ? '0' + seconds : seconds;
            
            var countdownEl = document.getElementById('countdown');
            if (countdownEl) {
                countdownEl.textContent = minutesStr + ':' + secondsStr;
                
                if (timeLeft <= 0) {
                    countdownEl.textContent = 'EXPIRED';
                    countdownEl.style.color = '#dc3545';
                    return;
                }
                
                if (timeLeft <= 60) {
                    countdownEl.style.color = '#dc3545';
                    countdownEl.style.fontSize = '1.4rem';
                }
            }
            
            timeLeft--;
        }
        
        updateCountdown();
        setInterval(updateCountdown, 1000);
    </script>
</body>
</html>