<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- Add SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
.stat-card {
    background: white;
    border-radius: 10px;
    padding: 20px;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    transition: transform 0.3s;
}

.stat-card:hover {
    transform: translateY(-5px);
}

.stat-icon {
    font-size: 2.5rem;
    margin-bottom: 10px;
    opacity: 0.8;
}

.stat-number {
    font-size: 2rem;
    font-weight: bold;
    color: #2c3e50;
}

.stat-label {
    color: #7f8c8d;
    font-size: 0.9rem;
}

.payment-type-badge {
    padding: 4px 10px;
    border-radius: 15px;
    font-size: 0.85rem;
    font-weight: 500;
}

.type-deposit { background: #e3f2fd; color: #1565c0; }
.type-full { background: #e8f5e9; color: #2e7d32; }
.type-remaining { background: #fff3e0; color: #e65100; }
.type-refund { background: #ffebee; color: #c62828; }
</style>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h2>Payment Management</h2>
            <p class="text-muted">Process payments and manage financial transactions</p>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-money-bill-wave stat-icon text-success"></i>
                <div class="stat-number">
                    <fmt:formatNumber value="${paymentStats.todayTotal}" pattern="#,##0"/>₫
                </div>
                <div class="stat-label">Today's Revenue</div>
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
                <i class="fas fa-piggy-bank stat-icon text-info"></i>
                <div class="stat-number">${paymentStats.depositCount}</div>
                <div class="stat-label">Deposits Today</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-undo stat-icon text-danger"></i>
                <div class="stat-number">${paymentStats.refundsCount}</div>
                <div class="stat-label">Refunds Today</div>
            </div>
        </div>
    </div>

   

    <!-- Filter Section -->
    <div class="card mb-4">
        <div class="card-header">
            <h5 class="mb-0">Filter Payments</h5>
        </div>
        <div class="card-body">
            <form id="filterForm" class="row">
                <div class="col-md-2">
                    <div class="form-group">
                        <label>Status</label>
                        <select class="form-control" name="status" id="statusFilter">
                            <option value="">All Status</option>
                            <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                            <option value="SUCCESS" ${param.status == 'SUCCESS' ? 'selected' : ''}>Success</option>
                            <option value="FAILED" ${param.status == 'FAILED' ? 'selected' : ''}>Failed</option>
                            <option value="REFUNDED" ${param.status == 'REFUNDED' ? 'selected' : ''}>Refunded</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>Payment Type</label>
                        <select class="form-control" name="paymentType" id="paymentTypeFilter">
                            <option value="">All Types</option>
                            <option value="DEPOSIT" ${param.paymentType == 'DEPOSIT' ? 'selected' : ''}>Deposit</option>
                            <option value="FULL_PAYMENT" ${param.paymentType == 'FULL_PAYMENT' ? 'selected' : ''}>Full Payment</option>
                            <option value="REMAINING_BALANCE" ${param.paymentType == 'REMAINING_BALANCE' ? 'selected' : ''}>Remaining Balance</option>
                            <option value="REFUND" ${param.paymentType == 'REFUND' ? 'selected' : ''}>Refund</option>
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
                            <option value="BANK_TRANSFER" ${param.method == 'BANK_TRANSFER' ? 'selected' : ''}>Bank Transfer</option>
                            <option value="VNPay" ${param.method == 'VNPay' ? 'selected' : ''}>VNPay</option>
                            <option value="MoMo" ${param.method == 'MoMo' ? 'selected' : ''}>MoMo</option>
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
                        <label>&nbsp;</label>
                        <div>
                        
                            <button type="button" class="btn btn-secondary btn-sm" onclick="clearFilters()">
                                <i class="fas fa-times"></i> Clear
                            </button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Payments Table -->
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Payment Transactions</h5>
            <small class="text-muted">
                Total: <strong class="text-success">
                    <fmt:formatNumber value="${totalAmount}" pattern="#,##0"/>₫
                </strong>
            </small>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover" id="paymentsTable">
                    <thead>
                        <tr>
                            <th>Payment ID</th>
                            <th>Booking ID</th>
                            <th>Customer</th>
                            <th>Room</th>
                            <th>Type</th>
                            <th>Amount</th>
                            <th>Method</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="payment" items="${payments}">
                            <tr>
                                <td>#${payment.id}</td>
                                <td>
                                    <a href="#" onclick="viewReservation(${payment.reservationId})">
                                        #${payment.reservationId}
                                    </a>
                                </td>
                                <td>${payment.customerName}</td>
                                <td>${payment.roomNumber}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${payment.paymentType == 'DEPOSIT'}">
                                            <span class="payment-type-badge type-deposit">Deposit</span>
                                        </c:when>
                                        <c:when test="${payment.paymentType == 'FULL_PAYMENT'}">
                                            <span class="payment-type-badge type-full">Full Payment</span>
                                        </c:when>
                                        <c:when test="${payment.paymentType == 'REMAINING_BALANCE'}">
                                            <span class="payment-type-badge type-remaining">Balance</span>
                                        </c:when>
                                        <c:when test="${payment.paymentType == 'REFUND'}">
                                            <span class="payment-type-badge type-refund">Refund</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">${payment.paymentType}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="${payment.paymentType == 'REFUND' ? 'text-danger' : 'text-success'}">
                                    <c:if test="${payment.paymentType == 'REFUND'}">-</c:if>
                                    <fmt:formatNumber value="${payment.amount}" pattern="#,##0"/>₫
                                </td>
                                <td>${payment.methodDisplayName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${payment.status == 'SUCCESS'}">
                                            <span class="badge badge-success" style="color: green">Success</span>
                                        </c:when>
                                        <c:when test="${payment.status == 'PENDING'}">
                                            <span class="badge badge-warning"style="color: orange">Pending</span>
                                        </c:when>
                                        <c:when test="${payment.status == 'FAILED'}">
                                            <span class="badge badge-danger"style="color: red">Failed</span>
                                        </c:when>
                                        <c:when test="${payment.status == 'REFUNDED'}">
                                            <span class="badge badge-info"style="color: black">Refunded</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">${payment.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td data-order="${payment.createdAt.time}">
                                    <fmt:formatDate value="${payment.createdAt}" pattern="dd/MM/yyyy"/>
                                    <br><small class="text-muted">
                                        <fmt:formatDate value="${payment.createdAt}" pattern="HH:mm"/>
                                    </small>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm" role="group">
                                        <button class="btn btn-info" onclick="viewPaymentDetails(${payment.id})" 
                                                title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <c:if test="${payment.status eq 'SUCCESS' && payment.paymentType ne 'REFUND'}">
                                          
                                            <button class="btn btn-warning" onclick="showRefundModal(${payment.id})" 
                                                    title="Process Refund">
                                                <i class="fas fa-undo"></i>
                                            </button>
                                        </c:if>
                                        <c:if test="${payment.status eq 'PENDING'}">
                                        <button type="button" class="btn btn-success" onclick="confirmPayment(${payment.id})"
                                                    title="Confirm Payment">
                                                <i class="fas fa-check"></i>
                                            </button>
                                            <button type="button" class="btn btn-danger" onclick="cancelPayment(${payment.id})"
                                                    title="Cancel Payment">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- New Payment Modal -->
<div class="modal fade" id="newPaymentModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Record New Payment</h5>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="newPaymentForm">
                <div class="modal-body">
                    <!-- Search Reservation -->
                    <div class="form-group">
                        <label>Search Reservation <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="reservationSearch" 
                                   placeholder="Enter booking ID, room number, or customer name">
                            <div class="input-group-append">
                                <button type="button" class="btn btn-primary" onclick="searchReservationForPayment()">
                                    <i class="fas fa-search"></i> Search
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Reservation Info -->
                    <div id="reservationInfo" style="display: none;">
                        <div class="card mb-3">
                            <div class="card-body">
                                <h6>Reservation Details</h6>
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong>Customer:</strong> <span id="resCustomerName"></span></p>
                                        <p><strong>Room:</strong> <span id="resRoomNumber"></span></p>
                                        <p><strong>Check-in:</strong> <span id="resCheckIn"></span></p>
                                    </div>
                                    <div class="col-md-6">
                                        <p><strong>Total Amount:</strong> <span id="resTotalAmount"></span></p>
                                        <p><strong>Amount Paid:</strong> <span id="resAmountPaid"></span></p>
                                        <p><strong>Balance:</strong> <span id="resBalance" class="text-danger"></span></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <input type="hidden" id="selectedReservationId">
                        
                        <!-- Payment Details -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Payment Type <span class="text-danger">*</span></label>
                                    <select class="form-control" id="paymentType" required>
                                        <option value="">Select payment type</option>
                                        <option value="DEPOSIT">Deposit (10%)</option>
                                        <option value="FULL_PAYMENT">Full Payment</option>
                                        <option value="REMAINING_BALANCE">Remaining Balance</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Amount <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="paymentAmount" 
                                           min="0" step="1000" required>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Payment Method <span class="text-danger">*</span></label>
                                    <select class="form-control" id="paymentMethod" required>
                                        <option value="">Select method</option>
                                        <option value="CASH">Cash</option>
                                        <option value="CREDIT_CARD">Credit Card</option>
                                        <option value="BANK_TRANSFER">Bank Transfer</option>
                                        <option value="VNPay">VNPay</option>
                                        <option value="MoMo">MoMo</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Transaction ID</label>
                                    <input type="text" class="form-control" id="transactionId" 
                                           placeholder="Optional">
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Notes</label>
                            <textarea class="form-control" id="paymentNotes" rows="2"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary" id="btnSubmitPayment" disabled>
                        <i class="fas fa-check"></i> Record Payment
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Refund Modal -->
<div class="modal fade" id="refundModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-warning">
                <h5 class="modal-title">Process Refund</h5>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="refundForm">
                <div class="modal-body">
                    <input type="hidden" id="refundPaymentId">
                    
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle"></i>
                        You are about to process a refund. This action cannot be undone.
                    </div>
                    
                    <div class="form-group">
                        <label>Original Amount</label>
                        <input type="text" class="form-control" id="originalAmount" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>Refund Amount <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="refundAmount" 
                               min="0" step="1000" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Refund Method <span class="text-danger">*</span></label>
                        <select class="form-control" id="refundMethod" required>
                            <option value="">Select method</option>
                            <option value="CASH">Cash</option>
                            <option value="BANK_TRANSFER">Bank Transfer</option>
                            <option value="ORIGINAL_METHOD">Original Payment Method</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Refund Reason <span class="text-danger">*</span></label>
                        <textarea class="form-control" id="refundReason" rows="3" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" id="btnProcessRefund" class="btn btn-warning">
                        <i class="fas fa-undo"></i> Process Refund
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let currentPaymentId = null;
let selectedReservation = null;

document.addEventListener('DOMContentLoaded', function() {
    // Initialize DataTable
    $('#paymentsTable').DataTable({
        order: [[8, 'desc']], // Sort by date column
       pageLength: 10
    });
     // Reset refund form when modal is hidden
    $('#refundModal').on('hidden.bs.modal', function() {
        $('#refundForm')[0].reset();
        currentPaymentId = null;
    });

    
    $('#btnProcessRefund').click(function(e) {
        e.preventDefault();
        processRefund();
    });
    
    $('#filterForm').submit(function(e) {
        e.preventDefault();
        filterPayments();
    });
    
      // Auto-filter when any filter field changes
    $('#statusFilter, #paymentTypeFilter, #methodFilter, #fromDate, #toDate').change(function() {
        filterPayments();
    });
    // Payment type change
    $('#paymentType').change(function() {
        calculatePaymentAmount();
    });
});



function searchReservationForPayment() {
    const query = $('#reservationSearch').val();
    if (!query) {
        Swal.fire('Error', 'Please enter search criteria', 'error');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
        data: {
            action: 'searchReservation',
            query: query
        },
        success: function(results) {
            if (results && results.length > 0) {
                // Show first result
                selectedReservation = results[0];
                displayReservationInfo(selectedReservation);
            } else {
                Swal.fire('Not Found', 'No active reservation found', 'warning');
            }
        },
        error: function() {
            Swal.fire('Error', 'Error searching reservation', 'error');
        }
    });
}

function displayReservationInfo(reservation) {
    $('#resCustomerName').text(reservation.customerName);
    $('#resRoomNumber').text(reservation.roomNumber);
    $('#resCheckIn').text(formatDate(reservation.checkIn));
    $('#resTotalAmount').text(formatCurrency(reservation.totalAmount));
    $('#resAmountPaid').text(formatCurrency(reservation.amountPaid || 0));
    $('#resBalance').text(formatCurrency(reservation.balance || reservation.totalAmount));
    
    $('#selectedReservationId').val(reservation.id);
    $('#reservationInfo').show();
    $('#btnSubmitPayment').prop('disabled', false);
    
    // Set deposit amount if deposit payment type
    if (!reservation.depositPaid) {
        $('#paymentType').val('DEPOSIT');
        calculatePaymentAmount();
    }
}

function calculatePaymentAmount() {
    if (!selectedReservation) return;
    
    const paymentType = $('#paymentType').val();
    let amount = 0;
    
    switch(paymentType) {
        case 'DEPOSIT':
            amount = selectedReservation.totalAmount * 0.1; // 10% deposit
            break;
        case 'FULL_PAYMENT':
            amount = selectedReservation.totalAmount;
            break;
        case 'REMAINING_BALANCE':
            amount = selectedReservation.balance || 0;
            break;
    }
    
    $('#paymentAmount').val(Math.round(amount));
}

function processNewPayment() {
    const paymentData = {
        reservationId: $('#selectedReservationId').val(),
        paymentType: $('#paymentType').val(),
        amount: $('#paymentAmount').val(),
        paymentMethod: $('#paymentMethod').val(),
        transactionId: $('#transactionId').val(),
        notes: $('#paymentNotes').val()
    };
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
        data: {
            action: 'recordPayment',
            ...paymentData
        },
        success: function(response) {
            if (response.success) {
                Swal.fire('Success', 'Payment recorded successfully!', 'success');
                $('#newPaymentModal').modal('hide');
                $('#newPaymentForm')[0].reset();
                $('#reservationInfo').hide();
                setTimeout(() => location.reload(), 1500);
            } else {
                Swal.fire('Error', response.message || 'Failed to record payment', 'error');
            }
        },
        error: function() {
            Swal.fire('Error', 'Error recording payment', 'error');
        }
    });
}

function showRefundModal(paymentId) {
    currentPaymentId = paymentId;
    
    // Get payment details
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
        data: {
            action: 'getPaymentDetails',
            paymentId: paymentId
        },
        success: function(payment) {
            $('#refundPaymentId').val(payment.id);
             $('#refundForm').data('original-amount', payment.amount);
            $('#originalAmount').val(formatCurrency(payment.amount));
            $('#refundAmount').val(payment.amount);
            $('#refundMethod').val('ORIGINAL_METHOD');
            $('#refundReason').val('');
            $('#refundModal').modal('show');
        },
        error: function() {
            Swal.fire('Error', 'Error loading payment details', 'error');
        }
    });
}

function processRefund() {
    // Retrieve the raw original amount stored on the form
    const originalAmount = parseFloat($('#refundForm').data('original-amount'));
    const refundAmount = parseFloat($('#refundAmount').val());

    if (isNaN(refundAmount) || refundAmount <= 0 || refundAmount > originalAmount) {
        Swal.fire('Error', 'Invalid refund amount', 'error');
        return;
    }

    const refundData = {
        paymentId: $('#refundPaymentId').val(),
        refundAmount: refundAmount,
        refundMethod: $('#refundMethod').val(),
        refundReason: $('#refundReason').val()
    };
    
    Swal.fire({
        title: 'Confirm Refund',
        text: 'Are you sure you want to process this refund?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ffc107',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Yes, process refund'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: '${pageContext.request.contextPath}/receptionist/payments',
                type: 'POST',
                       dataType: 'json',
                data: {
                    action: 'processRefund',
                    ...refundData
                },
                success: function(response) {
                    if (response.success) {
                        $('#refundModal').modal('hide');
                       Swal.fire('Success', 'Refund processed successfully!', 'success')
                            .then(() => location.reload());
                    } else {
                        Swal.fire('Error', response.message || 'Failed to process refund', 'error');
                    }
                },
                error: function() {
                    Swal.fire('Error', 'Error processing refund', 'error');
                }
            });
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
            let typeLabel = '';
            switch(payment.paymentType) {
                case 'DEPOSIT': typeLabel = '<span class="payment-type-badge type-deposit">Deposit</span>'; break;
                case 'FULL_PAYMENT': typeLabel = '<span class="payment-type-badge type-full">Full Payment</span>'; break;
                case 'REMAINING_BALANCE': typeLabel = '<span class="payment-type-badge type-remaining">Balance</span>'; break;
                case 'REFUND': typeLabel = '<span class="payment-type-badge type-refund">Refund</span>'; break;
            }
            
            let html = '<div class="row">';
            html += '<div class="col-md-6">';
            html += '<h6>Payment Information</h6>';
            html += '<p><strong>Payment ID:</strong> #' + payment.id + '</p>';
            html += '<p><strong>Type:</strong> ' + typeLabel + '</p>';
            html += '<p><strong>Amount:</strong> ' + formatCurrency(payment.amount) + '</p>';
            html += '<p><strong>Method:</strong> ' + payment.methodDisplayName + '</p>';
            html += '<p><strong>Status:</strong> <span class="badge badge-' + 
                    (payment.status === 'SUCCESS' ? 'success' : 'warning') + '">' + 
                    payment.status + '</span></p>';
            html += '<p><strong>Date:</strong> ' + formatDateTime(payment.createdAt) + '</p>';
            if (payment.transactionId) {
                html += '<p><strong>Transaction ID:</strong> ' + payment.transactionId + '</p>';
            }
            html += '</div>';
            
            html += '<div class="col-md-6">';
            html += '<h6>Reservation Information</h6>';
            html += '<p><strong>Booking ID:</strong> #' + payment.reservationId + '</p>';
            html += '<p><strong>Customer:</strong> ' + payment.customerName + '</p>';
            html += '<p><strong>Room:</strong> ' + payment.roomNumber + '</p>';
            html += '</div>';
            html += '</div>';
            
            Swal.fire({
                title: 'Payment Details',
                html: html,
                width: '800px',
                confirmButtonText: 'Close'
            });
        },
        error: function() {
            Swal.fire('Error', 'Error loading payment details', 'error');
        }
    });
}

function confirmPayment(paymentId) {
    Swal.fire({
        title: 'Confirm Payment',
        text: 'Are you sure you want to confirm this payment?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Yes, confirm'
    }).then((result) => {
        if (result.isConfirmed) {
            updatePaymentStatus(paymentId, 'SUCCESS');
        }
    });
}

function cancelPayment(paymentId) {
    Swal.fire({
        title: 'Cancel Payment',
        text: 'Are you sure you want to cancel this payment?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Yes, cancel'
    }).then((result) => {
        if (result.isConfirmed) {
            updatePaymentStatus(paymentId, 'FAILED');
        }
    });
}

function updatePaymentStatus(paymentId, status) {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/payments',
        type: 'POST',
                dataType: 'json',
        data: {
            action: 'updatePaymentStatus',
            paymentId: paymentId,
            status: status
        },
        success: function(response) {
            if (response.success) {
                Swal.fire('Success', 'Payment status updated successfully!', 'success');
                setTimeout(() => location.reload(), 1500);
            } else {
                Swal.fire('Error', response.message || 'Failed to update payment status', 'error');
            }
        },
        error: function() {
            Swal.fire('Error', 'Error updating payment status', 'error');
        }
    });
}

function printReceipt(paymentId) {
    window.open('${pageContext.request.contextPath}/receptionist/payments?action=printReceipt&paymentId=' + paymentId, 
                '_blank', 'width=800,height=600');
}

function viewReservation(reservationId) {
    window.location.href = '${pageContext.request.contextPath}/receptionist/reservations?id=' + reservationId;
}

function filterPayments() {
    const params = new URLSearchParams();
    
    const status = $('#statusFilter').val();
    const paymentType = $('#paymentTypeFilter').val();
    const method = $('#methodFilter').val();
    const fromDate = $('#fromDate').val();
    const toDate = $('#toDate').val();
    
    if (status) params.append('status', status);
    if (paymentType) params.append('paymentType', paymentType);
    if (method) params.append('method', method);
    if (fromDate) params.append('fromDate', fromDate);
    if (toDate) params.append('toDate', toDate);
    
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

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
}

function formatDateTime(dateTime) {
    if (!dateTime) return '-';
    const date = new Date(dateTime);
    return date.toLocaleString('vi-VN');
}
</script>   