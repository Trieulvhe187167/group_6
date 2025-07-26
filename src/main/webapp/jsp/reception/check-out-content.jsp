<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
      .late-highlight {
        box-shadow: 0 0 0 0.25rem rgba(255,193,7,.5);
    }
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
                       <h3 class="mb-1">${completedCheckOuts}</h3>
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
                    <button class="btn btn-warning btn-lg btn-block d-flex align-items-center justify-content-center" onclick="showLateCheckouts()" title="Jump to late check-outs">
                        <i class="fas fa-exclamation-triangle mr-1"></i> Late Check-outs <span class="badge badge-light ml-2">${lateCheckouts}</span>
                    </button>
                </div>
            </div>
        </div>
    </div>
  <!-- Search Results -->
    <div id="searchResults" class="mt-4" style="display: none;">
        <h6>Search Results:</h6>
        <div id="resultsContainer">
            <!-- Results will be loaded here -->
        </div>
        <button class="btn btn-sm btn-secondary mt-2" onclick="clearSearch()">
            <i class="fas fa-times fa-fw"></i> Clear Search
        </button>
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
                                  <div class="checkout-card card ${reservation.isLate ? 'border-warning late-checkout' : ''} ${reservation.checkedOut ? 'border-success' : 'border-0'}">
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
                                                <c:when test="${reservation.late}">
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
                <button type="button" class="close" data-bs-dismiss="modal">
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
                                    <h6 class="mb-0"><i class="fas fa-user"></i> Customer Information</h6>
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
                       
                                     <hr class="bg-white">
                                <div class="charge-item">
                                    <span>Subtotal:</span>
                                    <span id="subtotal">0₫</span>
                                </div>
                      
                                <div class="charge-item" id="refundRow" style="display: none;">
                                    <span>Security Deposit Refund:</span>
                                    <span id="refundAmount">0₫</span>
                                </div>
                                  <div class="charge-item" id="depositRow" style="display: none;">
                                    <span>Deposit Paid:</span>
                                    <span id="depositPaid">0₫</span>
                                </div>
                                <hr class="bg-white">
                                <div class="text-center">
                                    <p class="mb-1">Final Amount</p>
                                    <div class="bill-total" id="finalAmount" style="color: #e67700">0₫</div>
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
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>

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
// Complete checkout JavaScript functions

    let currentReservationData = null;
    let inspectionData = null;

function onJQueryReady(callback) {
        if (window.jQuery) {
            jQuery(callback);
        } else {
            const interval = setInterval(function () {
                if (window.jQuery) {
                    clearInterval(interval);
                    jQuery(callback);
                }
            }, 50);
        }
    }

    onJQueryReady(function () {
        // Auto-search on enter key
        $('#searchInput').keypress(function (e) {
                   if (e.which === 13) {
                searchCheckOut();
            }
        });

        // Handle check-out form submission
        $('#checkOutForm').on('submit', function (e) {
            e.preventDefault();
            processCheckOut();
        });
    });

    function searchCheckOut() {
        const query = $('#searchInput').val().trim();
        if (!query) {
            alert('Please enter a search term');
            return;
        }
   $('#searchResults').show();
        $('#resultsContainer').html('<div class="text-center py-4"><i class="fas fa-spinner fa-spin fa-2x"></i></div>');
        
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-out',
            method: 'POST',
            data: {
                action: 'searchCheckOut',
                query: query
            },
            success: function (results) {
                displaySearchResults(results);
            },
            error: function () {
                alert('Error searching reservations');
            }
        });
    }

    function requestInspection(reservationId) {
        if (confirm('Request room inspection for this reservation?')) {
            $.ajax({
                url: '${pageContext.request.contextPath}/inspector/inspection',
                method: 'POST',
                data: {
                    action: 'requestInspection',
                    reservationId: reservationId
                },
                success: function (response) {
                    if (response.success) {
                        alert('Inspection request sent successfully!');
                        location.reload();
                    } else {
                        alert('Error: ' + response.message);
                    }
                },
                error: function () {
                    alert('Error requesting inspection');
                }
            });
        }
    }

    function startCheckOut(reservationId) {
        // Show loading
        $('#checkOutModal').modal('show');

        var loadingHtml = '<div class="text-center py-3">';
        loadingHtml += '<i class="fas fa-spinner fa-spin fa-2x text-info"></i>';
        loadingHtml += '<p class="mt-2 mb-0">Loading checkout details...</p>';
        loadingHtml += '</div>';
        $('#inspectionSummary').html(loadingHtml);

        // Get checkout details including inspection data
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-out',
            method: 'POST',
            data: {
                action: 'getCheckOutDetails',
                reservationId: reservationId
            },
            success: function (data) {
                currentReservationData = data.reservation;
                inspectionData = data.inspection;

                populateCheckOutModal(data);
                calculateFinalBill(data);
            },
            error: function (xhr, status, error) {
                console.error('Error loading checkout details:', error);
                alert('Error loading checkout details. Please try again.');
                $('#checkOutModal').modal('hide');
            }
        });
    }

    function populateCheckOutModal(data) {
        const reservation = data.reservation;
        const inspection = data.inspection;
        const checkIn = data.checkIn;
        const serviceOrders = data.serviceOrders || [];

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
            var noInspectionHtml = '<div class="alert alert-warning mb-0">';
            noInspectionHtml += '<i class="fas fa-exclamation-triangle"></i> ';
            noInspectionHtml += 'No inspection data available';
            noInspectionHtml += '</div>';
            $('#inspectionSummary').html(noInspectionHtml);

            // Hide charge sections if no inspection
            $('#minibarSection').hide();
            $('#servicesSection').hide();
            $('#damagesSection').hide();
        }
// Load confirmed service orders
        loadServiceOrders(serviceOrders);
        // Security deposit
        const securityDeposit = data.securityDeposit || 0;
        $('#securityDeposit').text(formatCurrency(securityDeposit));

        // Amount already paid
        const amountPaid = data.amountPaid || 0;
         const depositPaid = data.depositPaid || 0;
        const otherPaid = Math.max(0, amountPaid - depositPaid);

        if (otherPaid > 0) {
            $('#amountPaidRow').show();
            $('#amountPaid').text(formatCurrency(otherPaid));
        } else {
            $('#amountPaidRow').hide();
            $('#amountPaid').text(formatCurrency(0));
        }
    }

    function displayInspectionSummary(inspection) {
        let conditionClass = '';
        switch (inspection.roomCondition) {
            case 'EXCELLENT':
                conditionClass = 'status-excellent';
                break;
            case 'GOOD':
                conditionClass = 'status-good';
                break;
            case 'FAIR':
                conditionClass = 'status-fair';
                break;
            case 'POOR':
            case 'DAMAGED':
                conditionClass = 'status-poor';
                break;
        }

        let html = '<div class="mb-2">';
        html += '<strong>Inspector:</strong> ' + (inspection.inspectorName || 'Unknown');
        html += '</div>';
        html += '<div class="mb-2">';
        html += '<strong>Inspection Time:</strong><br>';
        html += formatDateTime(inspection.inspectionTime);
        html += '</div>';
        html += '<div class="mb-2">';
        html += '<strong>Room Condition:</strong><br>';
        html += '<span class="room-status-indicator ' + conditionClass + '">';
        html += inspection.roomCondition;
        html += '</span>';
        html += '</div>';
        html += '<div class="mb-2">';
        html += '<strong>Cleanliness:</strong> ' + inspection.cleanlinessScore + '/10';
        html += '</div>';

        if (inspection.notes) {
            html += '<div class="mt-3">';
            html += '<strong>Notes:</strong><br>';
            html += '<small>' + inspection.notes + '</small>';
            html += '</div>';
        }

        $('#inspectionSummary').html(html);
    }

    function loadInspectionCharges(inspection) {
        // Reset sections
        $('#minibarSection').hide();
        $('#servicesSection').hide();
        $('#damagesSection').hide();

        // Minibar & Amenity items
        if (inspection.inspectionItems && inspection.inspectionItems.length > 0) {
            const minibarItems = inspection.inspectionItems.filter(item =>
                item.itemCategory === 'MINIBAR' || item.itemCategory === 'AMENITY'
            );

            if (minibarItems.length > 0) {
                $('#minibarSection').show();
                let minibarHtml = '';
                let minibarTotal = 0;
  // Group items with same name and price
                const grouped = {};
                minibarItems.forEach(function (item) {
                      const key = item.itemName + '|' + item.unitPrice;
                    if (grouped[key]) {
                        grouped[key].quantity += item.quantity;
                        grouped[key].totalPrice += item.totalPrice;
                    } else {
                        grouped[key] = {
                            itemName: item.itemName,
                            unitPrice: item.unitPrice,
                            quantity: item.quantity,
                            totalPrice: item.totalPrice
                        };
                    }
                });

                Object.values(grouped).forEach(function (item) {
                    minibarHtml += '<div class="minibar-item">';
                    minibarHtml += '<div>';
                    minibarHtml += '<strong>' + item.itemName + '</strong>';
                    minibarHtml += '<span class="text-muted ml-2">x' + item.quantity + '</span>';
                    minibarHtml += '</div>';
                    minibarHtml += '<div>';
                    minibarHtml += '<span class="text-muted">' + formatCurrency(item.unitPrice) + ' × ' + item.quantity + ' = </span>';
                    minibarHtml += '<strong>' + formatCurrency(item.totalPrice) + '</strong>';
                    minibarHtml += '</div>';
                    minibarHtml += '</div>';
                    minibarTotal += item.totalPrice;
                });

                $('#minibarItems').html(minibarHtml);
                $('#minibarTotal').text(formatCurrency(minibarTotal));
            }
        }

        // Service items
        if (inspection.inspectionItems) {
            const serviceItems = inspection.inspectionItems.filter(item => item.itemCategory === 'SERVICE');

            if (serviceItems.length > 0) {
                $('#servicesSection').show();
                let serviceHtml = '';
                let serviceTotal = 0;

                serviceItems.forEach(function (item) {
                    serviceHtml += '<div class="charge-item">';
                    serviceHtml += '<span>' + item.itemName + '</span>';
                    serviceHtml += '<span>' + formatCurrency(item.totalPrice) + '</span>';
                    serviceHtml += '</div>';
                    serviceTotal += item.totalPrice;
                });

                $('#serviceItems').html(serviceHtml);
                $('#servicesTotal').text(formatCurrency(serviceTotal));
            }
        }

        // Damages
        if (inspection.roomDamages && inspection.roomDamages.length > 0) {
            $('#damagesSection').show();
            let damageHtml = '';
            let damageTotal = 0;

            inspection.roomDamages.forEach(function (damage) {
                let severityClass = 'severity-' + damage.severity.toLowerCase();
                damageHtml += '<div class="damage-item">';
                damageHtml += '<div class="d-flex justify-content-between align-items-start">';
                damageHtml += '<div>';
                damageHtml += '<strong>' + damage.damageType + '</strong>';
                damageHtml += '<span class="damage-severity ' + severityClass + ' ml-2">' + damage.severity + '</span>';
                damageHtml += '<p class="mb-1 mt-1">' + damage.description + '</p>';
                damageHtml += '</div>';
                damageHtml += '<div class="text-danger font-weight-bold">';
                damageHtml += formatCurrency(damage.estimatedCost);
                damageHtml += '</div>';
                damageHtml += '</div>';
                damageHtml += '</div>';
                damageTotal += damage.estimatedCost;
            });

            $('#damageItems').html(damageHtml);
            $('#damagesTotal').text(formatCurrency(damageTotal));
        }
    }
   function loadServiceOrders(orders) {
       $('#servicesSection').show();
        if (orders && orders.length > 0) {
           
            let serviceHtml = '';
            let serviceTotal = 0;

            orders.forEach(function (order) {
                serviceHtml += '<div class="charge-item">';
                serviceHtml += '<span>' + order.serviceName + ' <span class="text-muted ml-2">x' + order.quantity + '</span></span>';
                serviceHtml += '<span>' + formatCurrency(order.totalAmount) + '</span>';
                serviceHtml += '</div>';
                serviceTotal += order.totalAmount;
            });

            $('#serviceItems').html(serviceHtml);
            $('#servicesTotal').text(formatCurrency(serviceTotal));
        } else {
           $('#serviceItems').html('<div class="text-muted">No additional services booked</div>');
            $('#servicesTotal').text(formatCurrency(0));
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
      
        const depositPaid = data.depositPaid || 0;

        // Calculate refund/final amount
        let finalAmount = subtotal - depositPaid;
        let refundAmount = 0;

        if (securityDeposit > 0 && damageCharges < securityDeposit) {
            refundAmount = securityDeposit - damageCharges;
            finalAmount = finalAmount - refundAmount;
        }

        // Update summary
        $('#summaryRoom').text(formatCurrency(roomCharges));
        $('#summaryAdditional').text(formatCurrency(additionalCharges));
        $('#subtotal').text(formatCurrency(subtotal));
        
           if (depositPaid > 0) {
            $('#depositRow').show();
            $('#depositPaid').text(formatCurrency(depositPaid));
        } else {
            $('#depositRow').hide();
        }

        if (refundAmount > 0) {
            $('#refundRow').show();
            $('#refundAmount').text(formatCurrency(refundAmount));
        } else {
            $('#refundRow').hide();
        }

        $('#finalAmount').text(formatCurrency(Math.max(0, finalAmount)));

        // Update button based on amount
        if (finalAmount <= 0) {
            $('#btnCompleteCheckout').html('<i class="fas fa-check-circle"></i> Complete Check-Out (No Payment Due)');
        } else {
            var buttonText = '<i class="fas fa-check-circle"></i> Complete Check-Out (';
            buttonText += formatCurrency(finalAmount) + ' Due)';
            $('#btnCompleteCheckout').html(buttonText);
        }
    }

    function processCheckOut() {
        // Validate payment method
        const paymentMethod = $('input[name="paymentMethod"]:checked').val();
        if (!paymentMethod && parseFloat($('#finalAmount').text().replace(/[^0-9.-]+/g, "")) > 0) {
            alert('Please select a payment method');
            return;
        }

        // Confirm check-out
        const finalAmount = $('#finalAmount').text();
        var confirmMessage = 'Confirm check-out?\n\n';
        confirmMessage += 'Final Amount: ' + finalAmount + '\n';
        confirmMessage += 'Payment Method: ' + (paymentMethod || 'No payment required');

        if (!confirm(confirmMessage)) {
            return;
        }

        // Show loading
        $('#btnCompleteCheckout').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Processing...');

        // Submit form data
        const formData = $('#checkOutForm').serialize();

        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-out',
            method: 'POST',
            data: formData,
            success: function (response) {
                if (response.success) {
                    alert('Check-out completed successfully!');
                    $('#checkOutModal').modal('hide');
                    // Redirect to check-out page to refresh list
                    window.location.href = '${pageContext.request.contextPath}/receptionist/check-out';
                } else {
                    alert('Error: ' + (response.message || 'Failed to process check-out'));
                    $('#btnCompleteCheckout').prop('disabled', false).html('<i class="fas fa-check-circle"></i> Complete Check-Out');
                }
            },
            error: function (xhr, status, error) {
                console.error('Check-out error:', error);
                alert('Error processing check-out. Please try again.');
                $('#btnCompleteCheckout').prop('disabled', false).html('<i class="fas fa-check-circle"></i> Complete Check-Out');
            }
        });
    }

    function printInvoice() {
        // Create a new window for printing
        const printWindow = window.open('', '_blank');

        // Generate invoice HTML
        const invoiceHtml = generateInvoiceHTML();

        // Write to print window
        printWindow.document.write(invoiceHtml);
        printWindow.document.close();

        // Print after loading
        printWindow.onload = function () {
            printWindow.print();
        };
    }

    function generateInvoiceHTML() {
        const finalAmount = $('#finalAmount').text();
        const refundAmount = $('#refundAmount').text();
        const subtotal = $('#subtotal').text();
        const guestName = $('#guestName').text();
        const bookingId = $('#bookingId').text();
        const roomNumber = $('#modalRoomNumber').text();
        const checkInDate = $('#checkInDate').text();
        const checkOutDate = $('#checkOutDate').text();
        const billNights = $('#billNights').text();
        const roomCharges = $('#roomCharges').text();
   

        let html = '<!DOCTYPE html><html><head>';
        html += '<title>Invoice - Booking #' + bookingId + '</title>';
        html += '<style>';
        html += 'body { font-family: Arial, sans-serif; margin: 20px; }';
        html += '.header { text-align: center; margin-bottom: 30px; }';
        html += '.invoice-details { margin-bottom: 30px; }';
        html += '.invoice-table { width: 100%; border-collapse: collapse; }';
        html += '.invoice-table th, .invoice-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }';
        html += '.invoice-table th { background-color: #f2f2f2; }';
        html += '.total-row { font-weight: bold; background-color: #f9f9f9; }';
        html += '.footer { margin-top: 50px; text-align: center; }';
        html += '</style></head><body>';

        // Header
        html += '<div class="header">';
        html += '<h1>Hotel Invoice</h1>';
        html += '<p>Invoice Date: ' + new Date().toLocaleDateString() + '</p>';
        html += '</div>';

        // Invoice details
        html += '<div class="invoice-details">';
        html += '<p><strong>Guest Name:</strong> ' + guestName + '</p>';
        html += '<p><strong>Booking ID:</strong> #' + bookingId + '</p>';
        html += '<p><strong>Room:</strong> ' + roomNumber + '</p>';
        html += '<p><strong>Check-in:</strong> ' + checkInDate + '</p>';
        html += '<p><strong>Check-out:</strong> ' + checkOutDate + '</p>';
        html += '</div>';

        // Invoice table
        html += '<table class="invoice-table">';
        html += '<thead><tr><th>Description</th><th style="text-align: right;">Amount</th></tr></thead>';
        html += '<tbody>';

        // Room charges
        html += '<tr>';
        html += '<td>Room Charges (' + billNights + ' nights)</td>';
        html += '<td style="text-align: right;">' + roomCharges + '</td>';
        html += '</tr>';

        // Minibar charges if visible
        if ($('#minibarSection').is(':visible')) {
            html += '<tr>';
            html += '<td>Minibar & Amenities</td>';
            html += '<td style="text-align: right;">' + $('#minibarTotal').text() + '</td>';
            html += '</tr>';
        }

        // Service charges if visible
        if ($('#servicesSection').is(':visible')) {
            html += '<tr>';
            html += '<td>Additional Services</td>';
            html += '<td style="text-align: right;">' + $('#servicesTotal').text() + '</td>';
            html += '</tr>';
        }

        // Damage charges if visible
        if ($('#damagesSection').is(':visible')) {
            html += '<tr>';
            html += '<td>Room Damages</td>';
            html += '<td style="text-align: right;">' + $('#damagesTotal').text() + '</td>';
            html += '</tr>';
        }

        // Subtotal
        html += '<tr class="total-row">';
        html += '<td>Subtotal</td>';
        html += '<td style="text-align: right;">' + subtotal + '</td>';
        html += '</tr>';

 
   if ($('#depositRow').is(':visible')) {
            html += '<tr>';
            html += '<td>Deposit Paid</td>';
            html += '<td style="text-align: right;">-' + $('#depositPaid').text() + '</td>';
            html += '</tr>';
        }

        // Refund if visible
        if ($('#refundRow').is(':visible')) {
            html += '<tr>';
            html += '<td>Security Deposit Refund</td>';
            html += '<td style="text-align: right;">-' + refundAmount + '</td>';
            html += '</tr>';
        }

        // Final amount
        html += '<tr class="total-row">';
        html += '<td>Final Amount</td>';
        html += '<td style="text-align: right;">' + finalAmount + '</td>';
        html += '</tr>';

        html += '</tbody></table>';

        // Footer
        html += '<div class="footer">';
        html += '<p>Thank you for staying with us!</p>';
        html += '<p>For any questions, please contact reception.</p>';
        html += '</div>';

        html += '</body></html>';

        return html;
    }

// Helper functions
    function formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {year: 'numeric', month: 'short', day: 'numeric'});
    }

    function formatDateTime(dateTimeString) {
        const date = new Date(dateTimeString);
        return date.toLocaleString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    function formatCurrency(amount) {
        return new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND'
        }).format(amount);
    }

    function displaySearchResults(results) {
        let html = '';

        if (results.length === 0) {
            html = '<div class="text-center py-5">';
            html += '<i class="fas fa-search fa-3x text-muted mb-3"></i>';
            html += '<h5 class="text-muted">No results found</h5>';
            html += '<p class="text-muted">Try searching with different keywords</p>';
            html += '</div>';
        } else {
            results.forEach(function (res) {
                html += '<div class="checkout-card mb-3">';
                html += '<div class="card-body">';
                html += '<div class="row align-items-center">';
                html += '<div class="col-md-7">';
                html += '<h5>Room ' + res.roomNumber + ' - ' + res.customerName + '</h5>';
                html += '<p class="mb-1">';
                html += '<i class="fas fa-calendar"></i> ';
                html += formatDate(res.checkIn) + ' → ' + formatDate(res.checkOut);
                html += '</p>';
                html += '<p class="mb-0">';
                html += '<i class="fas fa-hashtag"></i> Booking #' + res.id;
                html += '</p>';
                html += '</div>';
                html += '<div class="col-md-5 text-center">';
                html += '<button class="btn btn-danger btn-lg" onclick="startCheckOut(' + res.id + ')">';
                html += '<i class="fas fa-sign-out-alt"></i> Process Check-Out';
                html += '</button>';
                html += '</div>';
                html += '</div>';
                html += '</div>';
                html += '</div>';
            });
        }

        $('#resultsContainer').html(html);
    }
      function clearSearch() {
        $('#searchInput').val('');
        $('#searchResults').hide();
    }
     // Payment method selection helper
    function selectPaymentMethod(method) {
        $('.payment-method-btn').removeClass('selected');
        $('input[name="paymentMethod"][value="' + method + '"]').prop('checked', true)
                .closest('.payment-method-btn').addClass('selected');
    }
</script>

