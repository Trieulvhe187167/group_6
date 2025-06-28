<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .checkout-card {
        border-radius: 15px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
        overflow: hidden;
    }
    
    .checkout-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 5px 20px rgba(0,0,0,0.15);
    }
    
    .inspection-status {
        padding: 0.5rem 1rem;
        border-radius: 8px;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
    
    .inspection-pending {
        background-color: #fff3cd;
        color: #856404;
    }
    
    .inspection-completed {
        background-color: #d4edda;
        color: #155724;
    }
    
    .inspection-approved {
        background-color: #cce5ff;
        color: #004085;
    }
    
    .charge-section {
        background: #f8f9fa;
        border-radius: 10px;
        padding: 1.5rem;
        margin-bottom: 1rem;
    }
    
    .charge-item {
        display: flex;
        justify-content: space-between;
        padding: 0.75rem 0;
        border-bottom: 1px solid #e9ecef;
    }
    
    .charge-item:last-child {
        border-bottom: none;
    }
    
    .minibar-item {
        background: white;
        border: 1px solid #e9ecef;
        border-radius: 8px;
        padding: 0.75rem;
        margin-bottom: 0.5rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .damage-item {
        background: #fff5f5;
        border: 1px solid #fed7d7;
        border-radius: 8px;
        padding: 1rem;
        margin-bottom: 0.75rem;
    }
    
    .damage-severity {
        font-size: 0.875rem;
        padding: 0.25rem 0.75rem;
        border-radius: 12px;
        font-weight: 500;
    }
    
    .severity-minor {
        background: #e7f5ff;
        color: #1971c2;
    }
    
    .severity-moderate {
        background: #fff3bf;
        color: #e67700;
    }
    
    .severity-major {
        background: #ffe3e3;
        color: #c92a2a;
    }
    
    .severity-severe {
        background: #c92a2a;
        color: white;
    }
    
    .bill-summary {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 15px;
        padding: 2rem;
        position: sticky;
        top: 20px;
    }
    
    .bill-total {
        font-size: 2rem;
        font-weight: bold;
        margin: 1rem 0;
    }
    
    .payment-method-btn {
        border: 2px solid #dee2e6;
        background: white;
        padding: 1rem;
        border-radius: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        text-align: center;
    }
    
    .payment-method-btn:hover {
        border-color: #007bff;
        background: #f0f8ff;
    }
    
    .payment-method-btn.selected {
        border-color: #007bff;
        background: #007bff;
        color: white;
    }
    
    .room-status-indicator {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.5rem 1rem;
        border-radius: 20px;
        font-size: 0.875rem;
        font-weight: 500;
    }
    
    .status-excellent {
        background: #d3f9d8;
        color: #2b8a3e;
    }
    
    .status-good {
        background: #d0ebff;
        color: #1864ab;
    }
    
    .status-fair {
        background: #ffec99;
        color: #e67700;
    }
    
    .status-poor {
        background: #ffe3e3;
        color: #c92a2a;
    }
</style>
<!-- Print Styles -->
<style media="print">
    body * {
        visibility: hidden;
    }
    #checkOutModal, #checkOutModal * {
        visibility: visible;
    }
    #checkOutModal {
        position: absolute;
        left: 0;
        top: 0;
    }
    .modal-footer, .btn {
        display: none !important;
    }
</style>
<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h2><i class="fas fa-sign-out-alt text-danger mr-2"></i>Check-Out Management</h2>
            <p class="text-muted">Process guest departures and final billing</p>
        </div>
    </div>
    
    <!-- Quick Stats -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card border-danger">
                <div class="card-body text-center">
                    <i class="fas fa-calendar-times fa-2x text-danger mb-2"></i>
                    <h3 class="mb-1">${todayCheckOuts.size()}</h3>
                    <p class="text-muted mb-0">Expected Today</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-success">
                <div class="card-body text-center">
                    <i class="fas fa-check-double fa-2x text-success mb-2"></i>
                    <h3 class="mb-1">
                        <c:set var="completedCount" value="0" />
                        <c:forEach var="res" items="${todayCheckOuts}">
                            <c:if test="${res.checkedOut}">
                                <c:set var="completedCount" value="${completedCount + 1}" />
                            </c:if>
                        </c:forEach>
                        ${completedCount}
                    </h3>
                    <p class="text-muted mb-0">Completed</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-warning">
                <div class="card-body text-center">
                    <i class="fas fa-clock fa-2x text-warning mb-2"></i>
                    <h3 class="mb-1">${lateCheckouts}</h3>
                    <p class="text-muted mb-0">Late Check-outs</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-info">
                <div class="card-body text-center">
                    <i class="fas fa-clipboard-check fa-2x text-info mb-2"></i>
                    <h3 class="mb-1">${pendingInspections}</h3>
                    <p class="text-muted mb-0">Pending Inspections</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Search -->
    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title mb-3">Quick Check-Out Search</h5>
            <div class="row">
                <div class="col-md-9">
                    <div class="input-group input-group-lg">
                        <div class="input-group-prepend">
                            <span class="input-group-text bg-danger text-white">
                                <i class="fas fa-search"></i>
                            </span>
                        </div>
                        <input type="text" class="form-control" id="searchInput" 
                               placeholder="Enter Room Number, Booking ID, or Guest Name...">
                        <div class="input-group-append">
                            <button class="btn btn-danger" type="button" onclick="searchCheckOut()">
                                Search
                            </button>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <button class="btn btn-warning btn-lg btn-block" onclick="showLateCheckouts()">
                        <i class="fas fa-exclamation-triangle"></i> Late Check-outs
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Today's Expected Check-Outs -->
    <div class="card">
        <div class="card-body">
            <h5 class="card-title mb-4">
                <i class="fas fa-calendar-times"></i> Today's Expected Check-Outs
                <span class="badge badge-danger ml-2">${todayCheckOuts.size()}</span>
            </h5>

            <c:choose>
                <c:when test="${not empty todayCheckOuts}">
                    <div class="row">
                        <c:forEach var="reservation" items="${todayCheckOuts}">
                            <div class="col-lg-6 mb-4">
                                <div class="checkout-card card ${reservation.isLate ? 'border-warning' : ''} ${reservation.checkedOut ? 'border-success' : 'border-0'}">
                                    <div class="card-header ${reservation.checkedOut ? 'bg-success text-white' : (reservation.isLate ? 'bg-warning' : 'bg-light')}">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <h6 class="mb-0">
                                                <i class="fas fa-user mr-2"></i>${reservation.customerName}
                                            </h6>
                                            <c:choose>
                                                <c:when test="${reservation.checkedOut}">
                                                    <span class="badge badge-light">
                                                        <i class="fas fa-check-double"></i> Completed
                                                    </span>
                                                </c:when>
                                                <c:when test="${reservation.isLate}">
                                                    <span class="badge badge-light">
                                                        <i class="fas fa-clock"></i> Late
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-danger">Due Today</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-7">
                                                <p class="mb-2">
                                                    <i class="fas fa-door-open text-muted mr-2"></i>
                                                    Room <strong>${reservation.roomNumber}</strong> - ${reservation.roomTypeName}
                                                </p>
                                                <p class="mb-2">
                                                    <i class="fas fa-calendar-alt text-muted mr-2"></i>
                                                    <fmt:formatDate value="${reservation.checkIn}" pattern="dd/MM"/> - 
                                                    <fmt:formatDate value="${reservation.checkOut}" pattern="dd/MM/yyyy"/>
                                                    (${reservation.nights} nights)
                                                </p>
                                                <p class="mb-2">
                                                    <i class="fas fa-hashtag text-muted mr-2"></i>
                                                    Booking #${reservation.id}
                                                </p>
                                                
                                                <!-- Inspection Status -->
                                                <div class="mt-3">
                                                    <c:choose>
                                                        <c:when test="${reservation.inspectionStatus == 'COMPLETED'}">
                                                            <span class="inspection-status inspection-completed">
                                                                <i class="fas fa-check-circle"></i>
                                                                Inspection Completed
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${reservation.inspectionStatus == 'APPROVED'}">
                                                            <span class="inspection-status inspection-approved">
                                                                <i class="fas fa-clipboard-check"></i>
                                                                Inspection Approved
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="inspection-status inspection-pending">
                                                                <i class="fas fa-hourglass-half"></i>
                                                                Awaiting Inspection
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="col-md-5 text-center">
                                                <p class="text-muted mb-1">Estimated Total</p>
                                                <h4 class="text-primary mb-3">
                                                    <fmt:formatNumber value="${reservation.totalAmount + reservation.additionalCharges}" 
                                                                     pattern="#,##0"/>₫
                                                </h4>
                                                <c:choose>
                                                    <c:when test="${reservation.checkedOut}">
                                                        <button class="btn btn-secondary btn-block" disabled>
                                                            <i class="fas fa-check"></i> Checked Out
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${reservation.inspectionStatus != 'APPROVED' && reservation.inspectionStatus != 'COMPLETED'}">
                                                        <button class="btn btn-warning btn-block" 
                                                                onclick="requestInspection(${reservation.id})">
                                                            <i class="fas fa-clipboard-list"></i> Request Inspection
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="btn btn-danger btn-block btn-lg" 
                                                                onclick="startCheckOut(${reservation.id})">
                                                            <i class="fas fa-sign-out-alt"></i> Process Check-Out
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <img src="${pageContext.request.contextPath}/assets/images/no-checkouts.svg" 
                             alt="No check-outs" style="width: 200px; opacity: 0.6;">
                        <h5 class="mt-3 text-muted">No check-outs scheduled for today</h5>
                        <p class="text-muted">Use the search above to find other reservations</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Check-Out Modal -->
<div class="modal fade" id="checkOutModal" tabindex="-1" data-backdrop="static">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">
                    <i class="fas fa-receipt"></i> Process Check-Out - Room <span id="modalRoomNumber"></span>
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="checkOutForm" action="${pageContext.request.contextPath}/receptionist/check-out" method="POST">
                <input type="hidden" name="action" value="processCheckOut">
                <input type="hidden" name="reservationId" id="modalReservationId">
                
                <div class="modal-body">
                    <div class="row">
                        <!-- Left Column: Guest & Inspection Info -->
                        <div class="col-md-4">
                            <!-- Guest Information -->
                            <div class="card mb-3">
                                <div class="card-header bg-light">
                                    <h6 class="mb-0"><i class="fas fa-user"></i> Guest Information</h6>
                                </div>
                                <div class="card-body">
                                    <p class="mb-2"><strong>Name:</strong> <span id="guestName"></span></p>
                                    <p class="mb-2"><strong>Email:</strong> <span id="guestEmail"></span></p>
                                    <p class="mb-2"><strong>Phone:</strong> <span id="guestPhone"></span></p>
                                    <p class="mb-0"><strong>Booking ID:</strong> #<span id="bookingId"></span></p>
                                </div>
                            </div>
                            
                            <!-- Stay Details -->
                            <div class="card mb-3">
                                <div class="card-header bg-light">
                                    <h6 class="mb-0"><i class="fas fa-calendar"></i> Stay Details</h6>
                                </div>
                                <div class="card-body">
                                    <p class="mb-2"><strong>Check-in:</strong> <span id="checkInDate"></span></p>
                                    <p class="mb-2"><strong>Check-out:</strong> <span id="checkOutDate"></span></p>
                                    <p class="mb-2"><strong>Duration:</strong> <span id="stayDuration"></span> nights</p>
                                    <p class="mb-0"><strong>Room Type:</strong> <span id="roomType"></span></p>
                                </div>
                            </div>
                            
                            <!-- Inspection Summary -->
                            <div class="card" id="inspectionSummaryCard">
                                <div class="card-header bg-info text-white">
                                    <h6 class="mb-0"><i class="fas fa-clipboard-check"></i> Room Inspection</h6>
                                </div>
                                <div class="card-body" id="inspectionSummary">
                                    <div class="text-center py-3">
                                        <i class="fas fa-spinner fa-spin fa-2x text-info"></i>
                                        <p class="mt-2 mb-0">Loading inspection data...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Right Column: Bill Details -->
                        <div class="col-md-8">
                            <h5 class="mb-3"><i class="fas fa-file-invoice-dollar"></i> Final Bill Details</h5>
                            
                            <!-- Room Charges -->
                            <div class="charge-section">
                                <h6 class="mb-3">Room Charges</h6>
                                <div class="charge-item">
                                    <span>Room Rate (<span id="billNights"></span> nights)</span>
                                    <span class="font-weight-bold" id="roomCharges">0₫</span>
                                </div>
                            </div>
                            
                            <!-- Minibar & Amenities (from inspection) -->
                            <div class="charge-section" id="minibarSection" style="display: none;">
                                <h6 class="mb-3">Minibar & Amenities</h6>
                                <div id="minibarItems">
                                    <!-- Items will be loaded from inspection -->
                                </div>
                                <div class="charge-item font-weight-bold">
                                    <span>Subtotal</span>
                                    <span id="minibarTotal">0₫</span>
                                </div>
                            </div>
                            
                            <!-- Additional Services -->
                            <div class="charge-section" id="servicesSection" style="display: none;">
                                <h6 class="mb-3">Additional Services</h6>
                                <div id="serviceItems">
                                    <!-- Services will be loaded -->
                                </div>
                                <div class="charge-item font-weight-bold">
                                    <span>Subtotal</span>
                                    <span id="servicesTotal">0₫</span>
                                </div>
                            </div>
                            
                            <!-- Damages (if any, from inspection) -->
                            <div class="charge-section bg-light" id="damagesSection" style="display: none;">
                                <h6 class="mb-3 text-danger">
                                    <i class="fas fa-exclamation-triangle"></i> Damages & Penalties
                                </h6>
                                <div id="damageItems">
                                    <!-- Damages will be loaded from inspection -->
                                </div>
                                <div class="charge-item font-weight-bold text-danger">
                                    <span>Damage Charges</span>
                                    <span id="damagesTotal">0₫</span>
                                </div>
                            </div>
                            
                            <!-- Bill Summary -->
                            <div class="bill-summary mt-4">
                                <h5 class="mb-3">Bill Summary</h5>
                                <div class="charge-item">
                                    <span>Room Charges:</span>
                                    <span id="summaryRoom">0₫</span>
                                </div>
                                <div class="charge-item">
                                    <span>Additional Charges:</span>
                                    <span id="summaryAdditional">0₫</span>
                                </div>
                                <div class="charge-item">
                                    <span>Security Deposit:</span>
                                    <span id="securityDeposit">0₫</span>
                                </div>
                                <hr class="bg-white">
                                <div class="charge-item">
                                    <span>Subtotal:</span>
                                    <span id="subtotal">0₫</span>
                                </div>
                                <div class="charge-item">
                                    <span>Amount Paid:</span>
                                    <span id="amountPaid">0₫</span>
                                </div>
                                <div class="charge-item" id="refundRow" style="display: none;">
                                    <span>Deposit Refund:</span>
                                    <span class="text-success" id="refundAmount">0₫</span>
                                </div>
                                <hr class="bg-white">
                                <div class="text-center">
                                    <p class="mb-1">Final Amount</p>
                                    <div class="bill-total" id="finalAmount">0₫</div>
                                </div>
                            </div>
                            
                            <!-- Payment Method -->
                            <div class="mt-4">
                                <h6>Payment Method</h6>
                                <div class="row">
                                    <div class="col-md-3">
                                        <div class="payment-method-btn" onclick="selectPaymentMethod('CASH')">
                                            <input type="radio" name="paymentMethod" value="CASH" id="pmCash" hidden>
                                            <i class="fas fa-money-bill-wave fa-2x mb-2"></i>
                                            <div>Cash</div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="payment-method-btn" onclick="selectPaymentMethod('CREDIT_CARD')">
                                            <input type="radio" name="paymentMethod" value="CREDIT_CARD" id="pmCard" hidden>
                                            <i class="fas fa-credit-card fa-2x mb-2"></i>
                                            <div>Credit Card</div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="payment-method-btn" onclick="selectPaymentMethod('DEBIT_CARD')">
                                            <input type="radio" name="paymentMethod" value="DEBIT_CARD" id="pmDebit" hidden>
                                            <i class="fas fa-credit-card fa-2x mb-2"></i>
                                            <div>Debit Card</div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="payment-method-btn" onclick="selectPaymentMethod('BANK_TRANSFER')">
                                            <input type="radio" name="paymentMethod" value="BANK_TRANSFER" id="pmTransfer" hidden>
                                            <i class="fas fa-university fa-2x mb-2"></i>
                                            <div>Bank Transfer</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Check-out Notes -->
                            <div class="form-group mt-4">
                                <label>Check-out Notes (Optional)</label>
                                <textarea class="form-control" name="checkOutNotes" rows="3" 
                                          placeholder="Any special notes or comments..."></textarea>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-info" onclick="printInvoice()">
                        <i class="fas fa-print"></i> Print Invoice
                    </button>
                    <button type="submit" class="btn btn-danger btn-lg" id="btnCompleteCheckout">
                        <i class="fas fa-check-circle"></i> Complete Check-Out
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let currentReservationData = null;
let inspectionData = null;

$(document).ready(function() {
    // Auto-search on enter key
    $('#searchInput').keypress(function(e) {
        if (e.which == 13) {
            searchCheckOut();
        }
    });
});

function searchCheckOut() {
    const query = $('#searchInput').val().trim();
    if (!query) {
        alert('Please enter a search term');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/check-out',
        method: 'POST',
        data: {
            action: 'searchCheckOut',
            query: query
        },
        success: function(results) {
            displaySearchResults(results);
        },
        error: function() {
            alert('Error searching reservations');
        }
    });
}

function requestInspection(reservationId) {
    if (confirm('Request room inspection for this reservation?')) {
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/inspection',
            method: 'POST',
            data: {
                action: 'requestInspection',
                reservationId: reservationId
            },
            success: function(response) {
                if (response.success) {
                    alert('Inspection request sent successfully!');
                    location.reload();
                } else {
                    alert('Error: ' + response.message);
                }
            },
            error: function() {
                alert('Error requesting inspection');
            }
        });
    }
}

function startCheckOut(reservationId) {
    // Show loading
    $('#checkOutModal').modal('show');
    $('#inspectionSummary').html(`
        <div class="text-center py-3">
            <i class="fas fa-spinner fa-spin fa-2x text-info"></i>
            <p class="mt-2 mb-0">Loading checkout details...</p>
        </div>
    `);
    
    // Get checkout details including inspection data
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/check-out',
        method: 'POST',
        data: {
            action: 'getCheckOutDetails',
            reservationId: reservationId
        },
        success: function(data) {
            currentReservationData = data.reservation;
            inspectionData = data.inspection;
            
            populateCheckOutModal(data);
            calculateFinalBill(data);
        },
        error: function() {
            alert('Error loading checkout details');
            $('#checkOutModal').modal('hide');
        }
    });
}

function populateCheckOutModal(data) {
    const reservation = data.reservation;
    const inspection = data.inspection;
    const checkIn = data.checkIn;
    
    // Guest information
    $('#modalReservationId').val(reservation.id);
    $('#modalRoomNumber').text(reservation.roomNumber);
    $('#guestName').text(reservation.customerName);
    $('#guestEmail').text(reservation.customerEmail);
    $('#guestPhone').text(reservation.customerPhone);
    $('#bookingId').text(reservation.id);
    
    // Stay details
    $('#checkInDate').text(formatDate(reservation.checkIn));
    $('#checkOutDate').text(formatDate(reservation.checkOut));
    $('#stayDuration').text(reservation.nights);
    $('#roomType').text(reservation.roomTypeName);
    $('#billNights').text(reservation.nights);
    
    // Room charges
    $('#roomCharges').text(formatCurrency(reservation.totalAmount));
    
    // Inspection summary
    if (inspection) {
        displayInspectionSummary(inspection);
        loadInspectionCharges(inspection);
    } else {
        $('#inspectionSummary').html(`
            <div class="alert alert-warning mb-0">
                <i class="fas fa-exclamation-triangle"></i> 
                No inspection data available
            </div>
        `);
    }
    
    // Security deposit
    const securityDeposit = checkIn ? checkIn.securityDeposit : 0;
    $('#securityDeposit').text(formatCurrency(securityDeposit));
    
    // Amount already paid
    const amountPaid = data.amountPaid || 0;
    $('#amountPaid').text(formatCurrency(amountPaid));
}

function displayInspectionSummary(inspection) {
    let conditionClass = '';
    switch(inspection.roomCondition) {
        case 'EXCELLENT': conditionClass = 'status-excellent'; break;
        case 'GOOD': conditionClass = 'status-good'; break;
        case 'FAIR': conditionClass = 'status-fair'; break;
        case 'POOR': 
        case 'DAMAGED': conditionClass = 'status-poor'; break;
    }
    
    let html = `
        <div class="mb-2">
            <strong>Inspector:</strong> ${inspection.inspectorName}
        </div>
        <div class="mb-2">
            <strong>Inspection Time:</strong><br>
            ${formatDateTime(inspection.inspectionTime)}
        </div>
        <div class="mb-2">
            <strong>Room Condition:</strong><br>
            <span class="room-status-indicator ${conditionClass}">
                ${inspection.roomCondition}
            </span>
        </div>
        <div class="mb-2">
            <strong>Cleanliness:</strong> ${inspection.cleanlinessScore}/10
        </div>
    `;
    
    if (inspection.notes) {
        html += `
            <div class="mt-3">
                <strong>Notes:</strong><br>
                <small>${inspection.notes}</small>
            </div>
        `;
    }
    
    $('#inspectionSummary').html(html);
}

function loadInspectionCharges(inspection) {
    // Minibar items
    if (inspection.inspectionItems && inspection.inspectionItems.length > 0) {
        const minibarItems = inspection.inspectionItems.filter(item => 
            item.itemCategory === 'MINIBAR' || item.itemCategory === 'AMENITY'
        );
        
        if (minibarItems.length > 0) {
            $('#minibarSection').show();
            let minibarHtml = '';
            let minibarTotal = 0;
            
            minibarItems.forEach(item => {
                minibarHtml += `
                    <div class="minibar-item">
                        <div>
                            <strong>${item.itemName}</strong>
                            <span class="text-muted ml-2">x${item.quantity}</span>
                        </div>
                        <div>
                            <span class="text-muted">${formatCurrency(item.unitPrice)} × ${item.quantity} = </span>
                            <strong>${formatCurrency(item.totalPrice)}</strong>
                        </div>
                    </div>
                `;
                minibarTotal += item.totalPrice;
            });
            
            $('#minibarItems').html(minibarHtml);
            $('#minibarTotal').text(formatCurrency(minibarTotal));
        }
    }
    
    // Service items
    const serviceItems = inspection.inspectionItems ? 
        inspection.inspectionItems.filter(item => item.itemCategory === 'SERVICE') : [];
    
    if (serviceItems.length > 0) {
        $('#servicesSection').show();
        let serviceHtml = '';
        let serviceTotal = 0;
        
        serviceItems.forEach(item => {
            serviceHtml += `
                <div class="charge-item">
                    <span>${item.itemName}</span>
                    <span>${formatCurrency(item.totalPrice)}</span>
                </div>
            `;
            serviceTotal += item.totalPrice;
        });
        
        $('#serviceItems').html(serviceHtml);
        $('#servicesTotal').text(formatCurrency(serviceTotal));
    }
    
    // Damages
    if (inspection.roomDamages && inspection.roomDamages.length > 0) {
        $('#damagesSection').show();
        let damageHtml = '';
        let damageTotal = 0;
        
        inspection.roomDamages.forEach(damage => {
            let severityClass = 'severity-' + damage.severity.toLowerCase();
            damageHtml += `
                <div class="damage-item">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <strong>${damage.damageType}</strong>
                            <span class="damage-severity ${severityClass} ml-2">${damage.severity}</span>
                            <p class="mb-1 mt-1">${damage.description}</p>
                        </div>
                        <div class="text-danger font-weight-bold">
                            ${formatCurrency(damage.estimatedCost)}
                        </div>
                    </div>
                </div>
            `;
            damageTotal += damage.estimatedCost;
        });
        
        $('#damageItems').html(damageHtml);
        $('#damagesTotal').text(formatCurrency(damageTotal));
    }
}

function calculateFinalBill(data) {
    const roomCharges = data.reservation.totalAmount || 0;
    const charges = data.charges || {};
    
    const minibarCharges = charges.minibar || 0;
    const serviceCharges = charges.services || 0;
    const damageCharges = charges.damages || 0;
    const additionalCharges = minibarCharges + serviceCharges + damageCharges;
    
    const subtotal = roomCharges + additionalCharges;
    const securityDeposit = data.securityDeposit || 0;
    const amountPaid = data.amountPaid || 0;
    
    // Calculate refund/final amount
    let finalAmount = subtotal - amountPaid;
    let refundAmount = 0;
    
    if (damageCharges < securityDeposit) {
        refundAmount = securityDeposit - damageCharges;
        finalAmount = finalAmount - refundAmount;
    }
    
    // Update summary
    $('#summaryRoom').text(formatCurrency(roomCharges));
    $('#summaryAdditional').text(formatCurrency(additionalCharges));
    $('#subtotal').text(formatCurrency(subtotal));
    
    if (refundAmount > 0) {
        $('#refundRow').show();
        $('#refundAmount').text(formatCurrency(refundAmount));
    }
    
    $('#finalAmount').text(formatCurrency(Math.max(0, finalAmount)));
    
    // Update button based on amount
    if (finalAmount <= 0) {
        $('#btnCompleteCheckout').html('<i class="fas fa-check-circle"></i> Complete Check-Out (No Payment Due)');
    }
}

function selectPaymentMethod(method) {
    $('.payment-method-btn').removeClass('selected');
    $(`input[value="${method}"]`).prop('checked', true).closest('.payment-method-btn').addClass('selected');
}

function printInvoice() {
    window.print();
}

function showLateCheckouts() {
    // Filter and show only late checkouts
    alert('Showing late checkouts...');
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
}

function formatDateTime(dateString) {
    if (!dateString) return 'N/A';
    
    try {
        const date = new Date(dateString);
        // Check if date is valid
        if (isNaN(date.getTime())) {
            return 'Invalid Date';
        }
        // Use Vietnamese locale with specific format
        return date.toLocaleString('vi-VN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
    } catch (error) {
        console.error('Error formatting date:', error);
        return 'Error';
    }
}
function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(amount);
}

// Form submission
$('#checkOutForm').submit(function(e) {
    e.preventDefault();
    
    // Validate payment method
    if (!$('input[name="paymentMethod"]:checked').val()) {
        alert('Please select a payment method');
        return;
    }
    
    // Confirm checkout
    if (!confirm('Confirm checkout and payment?')) {
        return;
    }
    
    // Show loading
    const btn = $('#btnCompleteCheckout');
    const originalText = btn.html();
    btn.html('<i class="fas fa-spinner fa-spin"></i> Processing...').prop('disabled', true);
    
    // Submit form
    $.ajax({
        url: $(this).attr('action'),
        method: 'POST',
        data: $(this).serialize(),
        success: function(response) {
            if (response.success) {
                $('#checkOutModal').modal('hide');
                // Show success message
                Swal.fire({
                    icon: 'success',
                    title: 'Check-out Successful!',
                    text: 'Guest has been checked out successfully',
                    showConfirmButton: false,
                    timer: 2000
                }).then(() => {
                    // Redirect to invoice or reload
                    location.reload();
                });
            } else {
                alert('Error: ' + response.message);
                btn.html(originalText).prop('disabled', false);
            }
        },
        error: function() {
            alert('Error processing checkout');
            btn.html(originalText).prop('disabled', false);
        }
    });
});
// Function to calculate final amount considering deposit
function calculateFinalAmountWithDeposit() {
    const roomCharges = parseFloat($('#roomCharges').text().replace(/[₫,]/g, '')) || 0;
    const serviceCharges = parseFloat($('#serviceCharges').text().replace(/[₫,]/g, '')) || 0;
    const amenityCharges = parseFloat($('#amenityCharges').text().replace(/[₫,]/g, '')) || 0;
    const damageCharges = parseFloat($('#damageCharges').val()) || 0;
    const depositPaid = parseFloat($('#depositPaid').val()) || 0;
    
    // Total charges
    const totalCharges = roomCharges + serviceCharges + amenityCharges + damageCharges;
    
    // Amount already paid (deposit)
    const amountPaid = depositPaid;
    
    // Final amount to pay (can be negative if deposit covers all charges)
    const finalAmount = totalCharges - amountPaid;
    
    // Update display
    $('#totalCharges').text(formatCurrency(totalCharges));
    $('#depositAmount').text(formatCurrency(depositPaid));
    
    if (finalAmount < 0) {
        // Customer gets refund
        $('#finalAmount').html(`<span class="text-success">Refund: ${formatCurrency(Math.abs(finalAmount))}</span>`);
        $('#refundAmount').val(Math.abs(finalAmount));
        $('#paymentMethodSection').hide();
        $('#refundSection').show();
    } else if (finalAmount > 0) {
        // Customer needs to pay more
        $('#finalAmount').html(`<span class="text-danger">To Pay: ${formatCurrency(finalAmount)}</span>`);
        $('#refundAmount').val(0);
        $('#paymentMethodSection').show();
        $('#refundSection').hide();
    } else {
        // Exact amount - no payment needed
        $('#finalAmount').html(`<span class="text-info">No Payment Required</span>`);
        $('#refundAmount').val(0);
        $('#paymentMethodSection').hide();
        $('#refundSection').hide();
    }
    
    return finalAmount;
}

// Function to process check-out with deposit handling
function processCheckOutWithDeposit() {
    const reservationId = $('#reservationSelect').val();
    
    if (!reservationId) {
        showAlert('error', 'Please select a reservation to check out');
        return;
    }
    
    // Get all values
    const roomCondition = $('input[name="roomCondition"]:checked').val();
    const damageCharges = parseFloat($('#damageCharges').val()) || 0;
    const damageDescription = $('#damageDescription').val();
    const checkOutNotes = $('#checkOutNotes').val();
    const paymentMethod = $('input[name="paymentMethod"]:checked').val();
    const refundAmount = parseFloat($('#refundAmount').val()) || 0;
    const finalAmount = calculateFinalAmountWithDeposit();
    
    // Validate room condition
    if (!roomCondition) {
        showAlert('error', 'Please select room condition');
        return;
    }
    
    // If customer needs to pay and no payment method selected
    if (finalAmount > 0 && !paymentMethod) {
        showAlert('error', 'Please select a payment method');
        return;
    }
    
    // Prepare data
    const checkOutData = {
        reservationId: reservationId,
        roomCondition: roomCondition,
        damageCharges: damageCharges,
        damageDescription: damageDescription,
        checkOutNotes: checkOutNotes,
        paymentMethod: paymentMethod || 'NONE',
        finalAmount: Math.abs(finalAmount),
        isRefund: finalAmount < 0,
        refundAmount: refundAmount
    };
    
    // Confirm action
    let confirmMessage = 'Are you sure you want to complete check-out?';
    if (finalAmount < 0) {
        confirmMessage += `\n\nRefund Amount: ${formatCurrency(Math.abs(finalAmount))}`;
    } else if (finalAmount > 0) {
        confirmMessage += `\n\nAmount to Collect: ${formatCurrency(finalAmount)}`;
    }
    
    if (confirm(confirmMessage)) {
        // Show loading
        showLoading('Processing check-out with deposit handling...');
        
        // Send AJAX request
        $.ajax({
            url: 'check-out',
            type: 'POST',
            data: JSON.stringify(checkOutData),
            contentType: 'application/json',
            success: function(response) {
                hideLoading();
                if (response.success) {
                    showAlert('success', 'Check-out completed successfully!');
                    
                    // If there's a refund, show refund receipt
                    if (finalAmount < 0) {
                        showRefundReceipt(reservationId, Math.abs(finalAmount));
                    }
                    
                    // Reset form after 2 seconds
                    setTimeout(() => {
                        resetCheckOutForm();
                        loadReservations();
                    }, 2000);
                } else {
                    showAlert('error', response.message || 'Failed to process check-out');
                }
            },
            error: function(xhr, status, error) {
                hideLoading();
                showAlert('error', 'Error processing check-out: ' + error);
            }
        });
    }
}

// Function to show refund receipt
function showRefundReceipt(reservationId, refundAmount) {
    // Sử dụng locale vi-VN cho date
    const currentDateTime = new Date().toLocaleString('vi-VN');
    
    const modal = `
        <div class="modal fade" id="refundReceiptModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title">
                            <i class="fas fa-receipt"></i> Deposit Refund Receipt
                        </h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="text-center mb-4">
                            <i class="fas fa-check-circle text-success" style="font-size: 4rem;"></i>
                            <h4 class="mt-3">Refund Processed</h4>
                        </div>
                        
                        <div class="receipt-details">
                            <div class="row mb-2">
                                <div class="col-6">Reservation ID:</div>
                                <div class="col-6"><strong>#${reservationId}</strong></div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-6">Refund Amount:</div>
                                <div class="col-6"><strong class="text-success">${formatCurrency(refundAmount)}</strong></div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-6">Date:</div>
                                <div class="col-6">${currentDateTime}</div>
                            </div>
                        </div>
                        
                        <div class="alert alert-info mt-3">
                            <i class="fas fa-info-circle"></i>
                            The deposit refund will be processed within 3-5 business days.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" onclick="printRefundReceipt()">
                            <i class="fas fa-print"></i> Print Receipt
                        </button>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    $('body').append(modal);
    $('#refundReceiptModal').modal('show');
    
    $('#refundReceiptModal').on('hidden.bs.modal', function() {
        $(this).remove();
    });
}
</script>

