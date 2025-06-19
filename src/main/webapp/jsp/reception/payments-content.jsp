<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h2>Payment Management</h2>
            <p class="text-muted">Process payments and manage financial transactions</p>
        </div>
        <div class="col-md-6 text-right">
            <button class="btn btn-primary" data-toggle="modal" data-target="#newPaymentModal">
                <i class="fas fa-credit-card"></i> New Payment
            </button>
            <button class="btn btn-success" onclick="exportPayments()">
                <i class="fas fa-file-excel"></i> Export
            </button>
            <button class="btn btn-info" onclick="refreshPayments()">
                <i class="fas fa-sync"></i> Refresh
            </button>
        </div>
    </div>

    <!-- Quick Payment Processing -->
    <div class="table-container mb-4">
        <h5 class="mb-3">Quick Payment Processing</h5>
        <form id="quickPaymentForm">
            <div class="row">
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Booking ID or Room Number <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="searchPayment" 
                               placeholder="Enter booking ID or room number" required>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>Payment Method <span class="text-danger">*</span></label>
                        <select class="form-control" id="quickPaymentMethod" required>
                            <option value="">Select method</option>
                            <option value="CASH">Cash</option>
                            <option value="CREDIT_CARD">Credit Card</option>
                            <option value="DEBIT_CARD">Debit Card</option>
                            <option value="BANK_TRANSFER">Bank Transfer</option>
                            <option value="DIGITAL_WALLET">Digital Wallet</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>Amount (₫) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="quickAmount" 
                               min="1" step="1000" required>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Notes</label>
                        <input type="text" class="form-control" id="quickNotes" 
                               placeholder="Payment notes...">
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>&nbsp;</label>
                        <button type="submit" class="btn btn-success btn-block">
                            <i class="fas fa-credit-card"></i> Process
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <!-- Payment Statistics -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-money-bill-wave stat-icon text-success"></i>
                <div class="stat-number">
                    <fmt:formatNumber value="${paymentStats.todayTotal}" pattern="#,##0"/>₫
                </div>
                <div class="stat-label">Today's Payments</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-clock stat-icon text-warning"></i>
                <div class="stat-number">${paymentStats.pendingCount}</div>
                <div class="stat-label">Pending Payments</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-undo stat-icon text-danger"></i>
                <div class="stat-number">${paymentStats.refundsCount}</div>
                <div class="stat-label">Refunds Today</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-credit-card stat-icon text-info"></i>
                <div class="stat-number">${paymentStats.cardPayments}%</div>
                <div class="stat-label">Card Payments</div>
            </div>
        </div>
    </div>

    <!-- Filter Section -->
    <div class="table-container mb-4">
        <h5 class="mb-3">Filter Payments</h5>
        <form id="filterForm" class="row">
            <div class="col-md-2">
                <div class="form-group">
                    <label>Status</label>
                    <select class="form-control" name="status" id="statusFilter">
                        <option value="">All Status</option>
                        <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                        <option value="FAILED" ${param.status == 'FAILED' ? 'selected' : ''}>Failed</option>
                        <option value="REFUNDED" ${param.status == 'REFUNDED' ? 'selected' : ''}>Refunded</option>
                    </select>
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>Payment Method</label>
                    <select class="form-control" name="method" id="methodFilter">
                        <option value="">All Methods</option>
                        <option value="CASH" ${param.method == 'CASH' ? 'selected' : ''}>Cash</option>
                        <option value="CREDIT_CARD" ${param.method == 'CREDIT_CARD' ? 'selected' : ''}>Credit Card</option>
                        <option value="DEBIT_CARD" ${param.method == 'DEBIT_CARD' ? 'selected' : ''}>Debit Card</option>
                        <option value="BANK_TRANSFER" ${param.method == 'BANK_TRANSFER' ? 'selected' : ''}>Bank Transfer</option>
                    </select>
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>From Date</label>
                    <input type="date" class="form-control" name="fromDate" id="fromDate" 
                           value="${param.fromDate}">
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>To Date</label>
                    <input type="date" class="form-control" name="toDate" id="toDate" 
                           value="${param.toDate}">
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>Search</label>
                    <input type="text" class="form-control" name="search" id="searchInput" 
                           placeholder="Booking ID, guest name..." value="${param.search}">
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>&nbsp;</label>
                    <div>
                        <button type="submit" class="btn btn-primary btn-sm">
                            <i class="fas fa-filter"></i> Filter
                        </button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="clearFilters()">
                            <i class="fas fa-times"></i> Clear
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <!-- Payments Table -->
    <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5>Payment Transactions</h5>
            <small class="text-muted">
                Total Amount: <strong class="text-success">
                    <fmt:formatNumber value="${totalAmount}" pattern="#,##0"/>₫
                </strong>
            </small>
        </div>

        <div class="table-responsive">
            <table class="table table-hover" id="paymentsTable">
                <thead>
                    <tr>
                        <th>Payment ID</th>
                        <th>Booking ID</th>
                        <th>Guest</th>
                        <th>Room</th>
                        <th>Amount</th>
                        <th>Method</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty payments}">
                            <c:forEach var="payment" items="${payments}">
                                <tr>
                                    <td>
                                        <strong>#${payment.id}</strong>
                                        <c:if test="${payment.transactionId != null}">
                                            <br><small class="text-muted">TXN: ${payment.transactionId}</small>
                                        </c:if>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/receptionist/reservations?id=${payment.reservationId}" 
                                           class="text-primary">#${payment.reservationId}</a>
                                    </td>
                                    <td>
                                        <strong>${payment.guestName}</strong>
                                        <br><small class="text-muted">${payment.guestPhone}</small>
                                    </td>
                                    <td>
                                        <span class="badge badge-info">Room ${payment.roomNumber}</span>
                                    </td>
                                    <td>
                                        <strong class="text-primary">
                                            <fmt:formatNumber value="${payment.amount}" pattern="#,##0"/>₫
                                        </strong>
                                        <c:if test="${payment.refundAmount > 0}">
                                            <br><small class="text-danger">
                                                Refunded: <fmt:formatNumber value="${payment.refundAmount}" pattern="#,##0"/>₫
                                            </small>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${payment.method eq 'CASH'}">
                                                <i class="fas fa-money-bill-wave text-success"></i> Cash
                                            </c:when>
                                            <c:when test="${payment.method eq 'CREDIT_CARD'}">
                                                <i class="fas fa-credit-card text-primary"></i> Credit Card
                                            </c:when>
                                            <c:when test="${payment.method eq 'DEBIT_CARD'}">
                                                <i class="fas fa-credit-card text-info"></i> Debit Card
                                            </c:when>
                                            <c:when test="${payment.method eq 'BANK_TRANSFER'}">
                                                <i class="fas fa-university text-warning"></i> Transfer
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-wallet text-secondary"></i> ${payment.method}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${payment.status eq 'PENDING'}">
                                                <span class="badge badge-warning">Pending</span>
                                            </c:when>
                                            <c:when test="${payment.status eq 'COMPLETED'}">
                                                <span class="badge badge-success">Completed</span>
                                            </c:when>
                                            <c:when test="${payment.status eq 'FAILED'}">
                                                <span class="badge badge-danger">Failed</span>
                                            </c:when>
                                            <c:when test="${payment.status eq 'REFUNDED'}">
                                                <span class="badge badge-info">Refunded</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-secondary">${payment.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${payment.createdAt}" pattern="dd/MM/yyyy"/>
                                        <br><small class="text-muted">
                                            <fmt:formatDate value="${payment.createdAt}" pattern="HH:mm"/>
                                        </small>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <button class="btn btn-sm btn-info" onclick="viewPaymentDetails(${payment.id})" 
                                                    title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <c:if test="${payment.status eq 'COMPLETED'}">
                                                <button class="btn btn-sm btn-primary" onclick="printReceipt(${payment.id})" 
                                                        title="Print Receipt">
                                                    <i class="fas fa-print"></i>
                                                </button>
                                                <button class="btn btn-sm btn-warning" onclick="processRefund(${payment.id})" 
                                                        title="Refund">
                                                    <i class="fas fa-undo"></i>
                                                </button>
                                            </c:if>
                                            <c:if test="${payment.status eq 'PENDING'}">
                                                <button class="btn btn-sm btn-success" onclick="confirmPayment(${payment.id})" 
                                                        title="Confirm">
                                                    <i class="fas fa-check"></i>
                                                </button>
                                                <button class="btn btn-sm btn-danger" onclick="cancelPayment(${payment.id})" 
                                                        title="Cancel">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9" class="text-center text-muted py-4">
                                    <i class="fas fa-credit-card fa-3x mb-3"></i>
                                    <br>No payment transactions found
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- New Payment Modal -->
<div class="modal fade" id="newPaymentModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Process New Payment</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="newPaymentForm">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Search Reservation <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="text" class="form-control" id="reservationSearch" 
                                           placeholder="Enter booking ID or guest name" required>
                                    <div class="input-group-append">
                                        <button type="button" class="btn btn-outline-secondary" onclick="searchReservation()">
                                            <i class="fas fa-search"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            
                            <div id="reservationInfo" style="display: none;">
                                <div class="alert alert-info">
                                    <h6>Reservation Details</h6>
                                    <p class="mb-1"><strong>Guest:</strong> <span id="resGuestName"></span></p>
                                    <p class="mb-1"><strong>Room:</strong> <span id="resRoomNumber"></span></p>
                                    <p class="mb-1"><strong>Total Amount:</strong> <span id="resTotalAmount"></span></p>
                                    <p class="mb-0"><strong>Amount Paid:</strong> <span id="resAmountPaid"></span></p>
                                </div>
                                <input type="hidden" id="selectedReservationId">
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Payment Method <span class="text-danger">*</span></label>
                                <select class="form-control" id="paymentMethod" required>
                                    <option value="">Select payment method</option>
                                    <option value="CASH">Cash</option>
                                    <option value="CREDIT_CARD">Credit Card</option>
                                    <option value="DEBIT_CARD">Debit Card</option>
                                    <option value="BANK_TRANSFER">Bank Transfer</option>
                                    <option value="DIGITAL_WALLET">Digital Wallet</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label>Payment Amount (₫) <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" id="paymentAmount" 
                                       min="1" step="1000" required>
                            </div>
                            
                            <div class="form-group">
                                <label>Transaction ID</label>
                                <input type="text" class="form-control" id="transactionId" 
                                       placeholder="For card/transfer payments">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Payment Notes</label>
                        <textarea class="form-control" id="paymentNotes" rows="2" 
                                  placeholder="Any additional notes..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-credit-card"></i> Process Payment
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Payment Details Modal -->
<div class="modal fade" id="paymentDetailsModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Payment Details</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" id="paymentDetailsContent">
                <!-- Payment details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="printCurrentReceipt()">
                    <i class="fas fa-print"></i> Print Receipt
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Refund Modal -->
<div class="modal fade" id="refundModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Process Refund</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="refundForm">
                <div class="modal-body">
                    <input type="hidden" id="refundPaymentId">
                    
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle"></i>
                        <strong>Warning:</strong> This action cannot be undone.
                    </div>
                    
                    <div class="form-group">
                        <label>Original Payment Amount</label>
                        <input type="text" class="form-control" id="refundOriginalAmount" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>Refund Amount (₫) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="refundAmount" 
                               min="1" step="1000" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Refund Reason <span class="text-danger">*</span></label>
                        <select class="form-control" id="refundReason" required>
                            <option value="">Select reason</option>
                            <option value="GUEST_REQUEST">Guest Request</option>
                            <option value="OVERBOOKING">Overbooking</option>
                            <option value="SERVICE_ISSUE">Service Issue</option>
                            <option value="CANCELLATION">Cancellation</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Refund Notes</label>
                        <textarea class="form-control" id="refundNotes" rows="3" 
                                  placeholder="Detailed reason for refund..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning">
                        <i class="fas fa-undo"></i> Process Refund
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let currentPaymentId = null;

$(document).ready(function() {
    $('#quickPaymentForm').submit(function(e) {
        e.preventDefault();
        processQuickPayment();
    });
    
    $('#newPaymentForm').submit(function(e) {
        e.preventDefault();
        processNewPayment();
    });
    
    $('#refundForm').submit(function(e) {
        e.preventDefault();
        processRefund();
    });
    
    $('#filterForm').submit(function(e) {
        e.preventDefault();
        filterPayments();
    });
});

function processQuickPayment() {
    const paymentData = {
        searchTerm: $('#searchPayment').val(),
        paymentMethod: $('#quickPaymentMethod').val(),
        amount: $('#quickAmount').val(),
        notes: $('#quickNotes').val()
    };
    
    if (!paymentData.searchTerm || !paymentData.paymentMethod || !paymentData.amount) {
        alert('Please fill in all required fields');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            action: 'quickPayment',
            ...paymentData
        }),
        success: function(response) {
            if (response.success) {
                alert('Payment processed successfully!');
                $('#quickPaymentForm')[0].reset();
                location.reload();
            } else {
                alert('Error processing payment: ' + (response.message || 'Unknown error'));
            }
        },
        error: function() {
            alert('Error processing payment. Please try again.');
        }
    });
}

function searchReservation() {
    const searchTerm = $('#reservationSearch').val();
    if (!searchTerm) {
        alert('Please enter booking ID or guest name');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
        data: {
            action: 'searchReservation',
            searchTerm: searchTerm
        },
        success: function(reservation) {
            if (reservation && reservation.id) {
                $('#selectedReservationId').val(reservation.id);
                $('#resGuestName').text(reservation.guestName);
                $('#resRoomNumber').text(reservation.roomNumber);
                $('#resTotalAmount').text(formatCurrency(reservation.totalAmount));
                $('#resAmountPaid').text(formatCurrency(reservation.amountPaid || 0));
                $('#paymentAmount').val(reservation.totalAmount - (reservation.amountPaid || 0));
                $('#reservationInfo').show();
            } else {
                alert('No reservation found with that criteria');
                $('#reservationInfo').hide();
            }
        },
        error: function() {
            alert('Error searching reservation');
        }
    });
}

function processNewPayment() {
    if (!$('#selectedReservationId').val()) {
        alert('Please search and select a reservation first');
        return;
    }
    
    const paymentData = {
        reservationId: $('#selectedReservationId').val(),
        paymentMethod: $('#paymentMethod').val(),
        amount: $('#paymentAmount').val(),
        transactionId: $('#transactionId').val(),
        notes: $('#paymentNotes').val()
    };
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            action: 'processPayment',
            ...paymentData
        }),
        success: function(response) {
            if (response.success) {
                alert('Payment processed successfully!');
                $('#newPaymentModal').modal('hide');
                $('#newPaymentForm')[0].reset();
                $('#reservationInfo').hide();
                location.reload();
            } else {
                alert('Error processing payment: ' + (response.message || 'Unknown error'));
            }
        },
        error: function() {
            alert('Error processing payment. Please try again.');
        }
    });
}

function viewPaymentDetails(paymentId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
        data: {
            action: 'getPaymentDetails',
            paymentId: paymentId
        },
        success: function(payment) {
            let html = `
                <div class="row">
                    <div class="col-md-6">
                        <h6>Payment Information</h6>
                        <table class="table table-sm">
                            <tr><th>Payment ID:</th><td>#${payment.id}</td></tr>
                            <tr><th>Amount:</th><td><strong>${formatCurrency(payment.amount)}</strong></td></tr>
                            <tr><th>Method:</th><td>${payment.method}</td></tr>
                            <tr><th>Status:</th><td><span class="badge badge-success">${payment.status}</span></td></tr>
                            <tr><th>Date:</th><td>${formatDateTime(payment.createdAt)}</td></tr>
                            ${payment.transactionId ? '<tr><th>Transaction ID:</th><td>' + payment.transactionId + '</td></tr>' : ''}
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h6>Reservation Information</h6>
                        <table class="table table-sm">
                            <tr><th>Booking ID:</th><td>#${payment.reservationId}</td></tr>
                            <tr><th>Guest:</th><td>${payment.guestName}</td></tr>
                            <tr><th>Room:</th><td>${payment.roomNumber}</td></tr>
                            <tr><th>Phone:</th><td>${payment.guestPhone}</td></tr>
                        </table>
                        
                        <h6>Staff Information</h6>
                        <table class="table table-sm">
                            <tr><th>Processed By:</th><td>${payment.processedBy}</td></tr>
                        </table>
                    </div>
                </div>
            `;
            
            if (payment.notes) {
                html += `
                    <div class="mt-3">
                        <h6>Notes</h6>
                        <div class="alert alert-info">${payment.notes}</div>
                    </div>
                `;
            }
            
            currentPaymentId = paymentId;
            $('#paymentDetailsContent').html(html);
            $('#paymentDetailsModal').modal('show');
        },
        error: function() {
            alert('Error loading payment details');
        }
    });
}

function printReceipt(paymentId) {
    window.open(`${pageContext.request.contextPath}/receptionist/payments?action=printReceipt&id=${paymentId}`, '_blank');
}

function printCurrentReceipt() {
    if (currentPaymentId) {
        printReceipt(currentPaymentId);
    }
}

function processRefund(paymentId) {
    if (paymentId) {
        // Load payment details for refund
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/payments',
            type: 'POST',
            data: {
                action: 'getPaymentDetails',
                paymentId: paymentId
            },
            success: function(payment) {
                $('#refundPaymentId').val(payment.id);
                $('#refundOriginalAmount').val(formatCurrency(payment.amount));
                $('#refundAmount').val(payment.amount);
                $('#refundModal').modal('show');
            }
        });
    } else {
        // Process refund from form
        const refundData = {
            paymentId: $('#refundPaymentId').val(),
            amount: $('#refundAmount').val(),
            reason: $('#refundReason').val(),
            notes: $('#refundNotes').val()
        };
        
        if (confirm('Are you sure you want to process this refund?')) {
            $.ajax({
                url: '${pageContext.request.contextPath}/receptionist/payments',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({
                    action: 'processRefund',
                    ...refundData
                }),
                success: function(response) {
                    if (response.success) {
                        alert('Refund processed successfully!');
                        $('#refundModal').modal('hide');
                        location.reload();
                    } else {
                        alert('Error processing refund: ' + (response.message || 'Unknown error'));
                    }
                },
                error: function() {
                    alert('Error processing refund. Please try again.');
                }
            });
        }
    }
}

function confirmPayment(paymentId) {
    if (confirm('Confirm this payment?')) {
        updatePaymentStatus(paymentId, 'COMPLETED');
    }
}

function cancelPayment(paymentId) {
    if (confirm('Cancel this payment?')) {
        updatePaymentStatus(paymentId, 'CANCELLED');
    }
}

function updatePaymentStatus(paymentId, status) {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
        data: {
            action: 'updatePaymentStatus',
            paymentId: paymentId,
            status: status
        },
        success: function(response) {
            if (response.success) {
                alert('Payment status updated successfully!');
                location.reload();
            } else {
                alert('Error updating payment status');
            }
        },
        error: function() {
            alert('Error updating payment status');
        }
    });
}

function filterPayments() {
    const params = new URLSearchParams();
    
    const status = $('#statusFilter').val();
    const method = $('#methodFilter').val();
    const fromDate = $('#fromDate').val();
    const toDate = $('#toDate').val();
    const search = $('#searchInput').val();
    
    if (status) params.append('status', status);
    if (method) params.append('method', method);
    if (fromDate) params.append('fromDate', fromDate);
    if (toDate) params.append('toDate', toDate);
    if (search) params.append('search', search);
    
    const url = '${pageContext.request.contextPath}/receptionist/payments' + 
                (params.toString() ? '?' + params.toString() : '');
    window.location.href = url;
}

function clearFilters() {
    window.location.href = '${pageContext.request.contextPath}/receptionist/payments';
}

function exportPayments() {
    const params = new URLSearchParams(window.location.search);
    params.append('action', 'export');
    window.location.href = '${pageContext.request.contextPath}/receptionist/payments?' + params.toString();
}

function refreshPayments() {
    location.reload();
}

function formatCurrency(amount) {
    if (amount === null || amount === undefined) return '0₫';
    return new Intl.NumberFormat('vi-VN').format(amount) + '₫';
}

function formatDateTime(dateTime) {
    if (!dateTime) return '-';
    const date = new Date(dateTime);
    return date.toLocaleString('vi-VN');
}
</script>