<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    // Simple setup - use provided QR image URL
    String transferContent = "";
    String accountNumber = "1024520080";
    String accountHolder = "LE VAN TRIEU";
    String bankName = "Vietcombank";
    String bankCode = "VCB"; // Vietcombank short code
    String qrUrl = "";
        String reservationIdsStr = (String) request.getAttribute("reservationIdsStr");
    String paymentIdsStr = (String) request.getAttribute("paymentIdsStr");
    java.util.List<model.Reservation> reservationList =
        (java.util.List<model.Reservation>) request.getAttribute("reservationList");
        try {
        Object paymentIdObj = request.getAttribute("paymentId");
        Object reservationObj = request.getAttribute("reservation");
        Object amountObj = request.getAttribute("amount");
      
        if (paymentIdObj != null && reservationObj != null && amountObj != null) {
            model.Reservation res = (model.Reservation) reservationObj;
            double fullAmount = (Double) amountObj;
            double depositAmount = fullAmount * 0.1; // 10% deposit
            
            String customerName = res.getCustomerName() != null ?
                res.getCustomerName() : "CUSTOMER";
            
              // Simple transfer content: Reservation ID(s) + Customer Name + DEPOSIT
            if (reservationList != null && reservationList.size() > 1) {
                StringBuilder ids = new StringBuilder();
                for (int i = 0; i < reservationList.size(); i++) {
                    if (i > 0) ids.append("-");
                    ids.append(reservationList.get(i).getId());
                }
                transferContent = ids.toString() + " " + customerName + " DEPOSIT";
            } else {
                transferContent = res.getId() + " " + customerName + " DEPOSIT";
            }
            
            // Set attributes
            request.setAttribute("accountNumber", accountNumber);
            request.setAttribute("accountHolder", accountHolder);
             request.setAttribute("bankName", bankName);
                request.setAttribute("bankCode", bankCode);
            request.setAttribute("transferContent", transferContent);
            request.setAttribute("depositAmount", depositAmount);
            request.setAttribute("fullAmount", fullAmount);
            
            qrUrl = "https://img.vietqr.io/image/" + bankCode + "-" + accountNumber + "-compact2.png"
                    + "?amount=" + Math.round(depositAmount)
                    + "&addInfo=" + java.net.URLEncoder.encode(transferContent, "UTF-8")
                    + "&accountName=" + java.net.URLEncoder.encode(accountHolder, "UTF-8");
            request.setAttribute("qrUrl", qrUrl);
        }
    } catch (Exception e) {
        System.out.println("Setup error: " + e.getMessage());
        e.printStackTrace();
    }
        if (request.getAttribute("qrUrl") == null) {
        request.setAttribute("qrUrl", qrUrl);
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

            .deposit-notice {
                background: #e8f5e9;
                border: 2px solid #4caf50;
                border-radius: 10px;
                padding: 1.5rem;
                margin-bottom: 2rem;
            }

            .deposit-notice h5 {
                color: #2e7d32;
                margin-bottom: 1rem;
            }

            .deposit-notice ul {
                margin-bottom: 0;
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
            }

            .amount-highlight {
                background: #fff3cd;
                padding: 0.25rem 0.5rem;
                border-radius: 5px;
                font-weight: bold;
                color: #856404;
            }

            .bank-detail {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 1rem;
                margin-bottom: 0.5rem;
                background: white;
                border-radius: 8px;
                transition: all 0.3s;
            }

            .bank-detail:hover {
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }

            .bank-label {
                font-weight: 600;
                color: #666;
                font-size: 0.9rem;
            }

            .bank-value {
                font-size: 1.1rem;
                color: #333;
                font-weight: 500;
                display: flex;
                align-items: center;
                gap: 1rem;
            }

            .copy-btn {
                cursor: pointer;
                color: #667eea;
                padding: 0.25rem 0.5rem;
                border: 1px solid #667eea;
                border-radius: 5px;
                font-size: 0.85rem;
                transition: all 0.3s;
            }

            .copy-btn:hover {
                background: #667eea;
                color: white;
            }

            .instruction-card {
                background: #f0f7ff;
                border-radius: 10px;
                padding: 1.5rem;
                margin-top: 2rem;
            }

            .instruction-list {
                margin: 1rem 0 0 0;
                padding-left: 1.5rem;
            }

            .instruction-list li {
                margin-bottom: 0.75rem;
                line-height: 1.6;
            }

            .qr-section {
                text-align: center;
                padding: 2rem;
                background: #f8f9fa;
                border-radius: 10px;
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
                max-width: 500px;
                max-height: 500px;
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
                    <!-- Deposit Notice -->
                    <div class="deposit-notice">
                        <h5><i class="fas fa-info-circle me-2"></i>Deposit Payment Required</h5>
                        <ul class="mb-3">
                            <li><strong>You only need to pay 10% deposit now</strong> to secure your reservation</li>
                            <li>The deposit amount will be <strong>fully refunded</strong> when you check out</li>
                            <li>The remaining 90% can be paid at check-in or during your stay</li>
                        </ul>
                        <div class="alert alert-warning mb-0">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            <strong>Important:</strong> Your deposit (<fmt:formatNumber value="${depositAmount}" pattern="#,###"/> VND) will be returned to you at check-out
                        </div>
                    </div>

                    <!-- Reservation Info -->
                    <div class="section">
                        <h5 class="mb-3"><i class="fas fa-info-circle me-2"></i>Reservation Details</h5>
                           <c:choose>
                        <c:when test="${not empty reservationList && fn:length(reservationList) > 1}">
                             <div class="info-row">
                                <span>Reservation IDs:</span>
                                <span>#${fn:replace(reservationIdsStr, ',', ', #')}</span>
                            </div>
                            <div class="info-row">
                                <span>Customer:</span>
                                <span><c:out value="${reservation.customerName}"/></span>
                            </div>
                            <table class="table table-bordered mt-2">
                                <thead>
                                    <tr>
                                           <th>Reservation ID</th>
                                        <th>Room</th>
                                        <th>Check-in</th>
                                        <th>Check-out</th>
                                        <th>Amount</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${reservationList}">
                                        <tr>
                                               <td>#${r.id}</td>
                                            <td>${r.roomNumber} (${r.roomTypeName})</td>
                                            <td><fmt:formatDate value="${r.checkIn}" pattern="dd/MM/yyyy"/></td>
                                            <td><fmt:formatDate value="${r.checkOut}" pattern="dd/MM/yyyy"/></td>
                                            <td><fmt:formatNumber value="${r.totalAmount}" pattern="#,###"/> VND</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
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
                        </c:otherwise>
                    </c:choose>
                        <div class="info-row">
                            <span>Total Booking Amount:</span>
                            <span><fmt:formatNumber value="${fullAmount}" pattern="#,###"/> VND</span>
                        </div>
                        <div class="info-row">
                            <span>Deposit Required (10%):</span>
                            <span class="amount-highlight"><fmt:formatNumber value="${depositAmount}" pattern="#,###"/> VND</span>
                        </div>
                        <div class="info-row">
                            <span>Remaining Balance:</span>
                            <span><fmt:formatNumber value="${fullAmount - depositAmount}" pattern="#,###"/> VND</span>
                        </div>
                    </div>
<!-- QR Code Section -->
                    <div class="section">
                        <h5 class="mb-3"><i class="fas fa-qrcode me-2"></i>Quick Transfer via QR Code</h5>

                        <div class="qr-section">
                            <div id="qr-loading">
                                <div class="spinner-border text-primary mb-3" role="status">
                                    <span class="status">Loading...</span>
                                </div>
                                <p class="text-muted">Loading QR code...</p>
                            </div>

                            <div id="qr-container" style="display: none;">
                                <div class="qr">
                                  <img id="qr-image" alt="QR Code for bank transfer"
                                         src="<c:out value='${qrUrl}'/>"
                                         onerror="handleQRError()" onload="handleQRLoad()">
                                </div>
                            </div>
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
                            <strong>Deposit Amount:</strong> <fmt:formatNumber value="${depositAmount}" pattern="#,###"/> VND<br>
                            <strong>Content:</strong> <%= transferContent %><br>
                            <small class="text-muted">Make sure your QR code includes the correct amount and transfer content above.</small>
                        </div>

                        <!-- Manual Transfer Instructions -->
                        <div class="alert alert-warning">
                            <i class="fas fa-hand-point-right me-2"></i>
                            <strong>No QR Code?</strong> No problem! Use the bank details above for manual transfer.
                        </div>
                    </div>

                    <!-- Bank Details -->
                    <div class="section">
                        <h5 class="mb-3"><i class="fas fa-building-columns me-2"></i>Bank Account Details</h5>

                        <div class="bank-detail">
                            <span class="bank-label">Bank Name:</span>
                            <span class="bank-value">
                                <strong><%= bankName %> (VCB)</strong>
                                <span class="copy-btn" onclick="copyText('<%= bankName %>')">
                                    <i class="fas fa-copy"></i> Copy
                                </span>
                            </span>
                        </div>

                        <div class="bank-detail">
                            <span class="bank-label">Account Number:</span>
                            <span class="bank-value">
                                <strong><%= accountNumber %></strong>
                                <span class="copy-btn" onclick="copyText('<%= accountNumber %>')">
                                    <i class="fas fa-copy"></i> Copy
                                </span>
                            </span>
                        </div>

                        <div class="bank-detail">
                            <span class="bank-label">Account Holder:</span>
                            <span class="bank-value">
                                <strong><%= accountHolder %></strong>
                                <span class="copy-btn" onclick="copyText('<%= accountHolder %>')">
                                    <i class="fas fa-copy"></i> Copy
                                </span>
                            </span>
                        </div>

                        <div class="bank-detail">
                            <span class="bank-label">Transfer Content:</span>
                            <span class="bank-value">
                                <strong><%= transferContent %></strong>
                                <span class="copy-btn" onclick="copyText('<%= transferContent %>')">
                                    <i class="fas fa-copy"></i> Copy
                                </span>
                            </span>
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
                            <li>Enter the deposit amount: <strong><fmt:formatNumber value="${depositAmount}" pattern="#,###"/> VND</strong></li>
                            <li>Complete the transfer and save your transaction receipt</li>
                            <li>Your reservation will be automatically confirmed after payment is received</li>
                        </ol>

                        <div class="alert alert-success mt-3 mb-0">
                            <i class="fas fa-check-circle me-2"></i>
                            <strong>Deposit Refund Policy:</strong> Your 10% deposit will be fully refunded at check-out. 
                            You can pay the remaining balance at any time during your stay.
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="text-center mt-4">
                        <button class="btn btn-success btn-lg me-3" onclick="confirmPayment()">
                            <i class="fas fa-check me-2"></i>I've Made the Transfer
                        </button>
                        <button class="btn btn-outline-secondary btn-lg" onclick="cancelPayment()">
                            <i class="fas fa-times me-2"></i>Cancel
                        </button>
                    </div>
                </div>
            </div>
        </div>

       
        <script>
                       const qrUrl = '<%= qrUrl %>';
                            document.addEventListener('DOMContentLoaded', function () {
                            
                                const qrImage = document.getElementById('qr-image');
                               
                                qrImage.src = qrUrl;
                                    });

                            function retryQR() {
                                document.getElementById('qr-error').style.display = 'none';
                                document.getElementById('qr-loading').style.display = 'block';
                                document.getElementById('qr-image').src = qrUrl + '&ts=' + Date.now();
                            }

                            function handleQRLoad() {
                                document.getElementById('qr-loading').style.display = 'none';
                                document.getElementById('qr-container').style.display = 'block';
                            }

                            function handleQRError() {
                                document.getElementById('qr-loading').style.display = 'none';
                                document.getElementById('qr-error').style.display = 'block';
                            }

                         
                            function copyText(text) {
                                navigator.clipboard.writeText(text).then(function () {
                                    // Show success message
                                    const btn = event.target.closest('.copy-btn');
                                    const originalHtml = btn.innerHTML;
                                    btn.innerHTML = '<i class="fas fa-check"></i> Copied!';
                                    btn.style.background = '#4caf50';
                                    btn.style.color = 'white';

                                    setTimeout(() => {
                                        btn.innerHTML = originalHtml;
                                        btn.style.background = '';
                                        btn.style.color = '';
                                    }, 2000);
                                }).catch(function () {
                                    alert('Failed to copy text. Please copy manually.');
                                });
                            }

                            function confirmPayment() {
                                if (confirm('Have you completed the bank transfer of the deposit amount?')) {
                                    // Submit form to process payment
                                    const form = document.createElement('form');
                                    form.method = 'POST';
                                    form.action = '${pageContext.request.contextPath}/PaymentGateway';

                                    const fields = {
                                        'action': 'processPayment',
                                        'paymentId': '<%= request.getAttribute("paymentId") %>',
                                        'reservationId': '<%= request.getAttribute("reservation") != null ? ((model.Reservation)request.getAttribute("reservation")).getId() : "" %>',
                                        'method': 'BANK_TRANSFER',
                                      'status': 'PENDING',
                                        'transactionId': 'BANK-TRANSFER-' + Date.now(),
                                        'reservationIds': '<%= reservationIdsStr != null ? reservationIdsStr : "" %>',
                                        'paymentIds': '<%= paymentIdsStr != null ? paymentIdsStr : "" %>'
                                    };

                                    for (const [key, value] of Object.entries(fields)) {
                                        const input = document.createElement('input');
                                        input.type = 'hidden';
                                        input.name = key;
                                        input.value = value;
                                        form.appendChild(input);
                                    }

                                    document.body.appendChild(form);
                                    form.submit();
                                    alert('Thank you for your payment, we will check and send you a notification via email');
                                }
                            }

                            function cancelPayment() {
                                if (confirm('Are you sure you want to cancel this payment?')) {
                                    window.location.href = '${pageContext.request.contextPath}/SearchAvailableRoomsServlet';
                                }
                            }
        </script>
    </body>
</html>