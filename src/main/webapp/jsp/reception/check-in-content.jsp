<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- Add SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
    .check-in-header {
        background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
        color: white;
        padding: 2rem;
        border-radius: 10px;
        margin-bottom: 2rem;
    }
    
    .room-card {
        background: white;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        transition: all 0.3s ease;
        text-align: center;
        cursor: pointer;
        position: relative;
        overflow: hidden;
    }
    
    .room-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 5px 20px rgba(0,0,0,0.15);
    }
    
    .room-card.selected {
        border: 2px solid #17a2b8;
        background: rgba(23, 162, 184, 0.05);
    }
    
    .room-number {
        font-size: 24px;
        font-weight: bold;
        color: #17a2b8;
        margin-bottom: 10px;
    }
    
    .step-indicator {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2rem;
        position: relative;
    }
    
    .step-indicator::before {
        content: '';
        position: absolute;
        top: 20px;
        left: 0;
        right: 0;
        height: 2px;
        background: #e9ecef;
        z-index: -1;
    }
    
    .step {
        text-align: center;
        position: relative;
        background: white;
        padding: 0 15px;
    }
    
    .step-circle {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #e9ecef;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        margin-bottom: 0.5rem;
        transition: all 0.3s ease;
    }
    
    .step.active .step-circle {
        background: #17a2b8;
        color: white;
        transform: scale(1.1);
    }
    
    .step.completed .step-circle {
        background: #28a745;
        color: white;
    }
    
    .guest-info-box {
        background: #f8f9fa;
        border-radius: 10px;
        padding: 1.5rem;
        margin-bottom: 1rem;
    }
    
    .id-verification {
        padding: 1rem;
        background: #e7f3ff;
        border-radius: 8px;
        border: 2px dashed #007bff;
    }
    
    .quick-action-btn {
        padding: 0.8rem 1.5rem;
        font-size: 1rem;
        border-radius: 8px;
        transition: all 0.3s ease;
        border: none;
        font-weight: 500;
    }
    
    .quick-action-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(0,0,0,0.2);
    }
</style>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h2><i class="fas fa-sign-in-alt text-info mr-2"></i>Check-In Management</h2>
            <p class="text-muted">Process guest arrivals and room assignments</p>
        </div>
    </div>
    
    <!-- Quick Stats -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card border-info">
                <div class="card-body text-center">
                    <i class="fas fa-calendar-check fa-2x text-info mb-2"></i>
                    <h3 class="mb-1">${todayCheckIns.size()}</h3>
                    <p class="text-muted mb-0">Expected Today</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-success">
                <div class="card-body text-center">
                    <i class="fas fa-check-circle fa-2x text-success mb-2"></i>
                    <h3 class="mb-1">
                        <c:set var="checkedInCount" value="0" />
                        <c:forEach var="res" items="${todayCheckIns}">
                            <c:if test="${res.checkedIn}">
                                <c:set var="checkedInCount" value="${checkedInCount + 1}" />
                            </c:if>
                        </c:forEach>
                        ${checkedInCount}
                    </h3>
                    <p class="text-muted mb-0">Completed</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-warning">
                <div class="card-body text-center">
                    <i class="fas fa-clock fa-2x text-warning mb-2"></i>
                    <h3 class="mb-1">${todayCheckIns.size() - checkedInCount}</h3>
                    <p class="text-muted mb-0">Pending</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-primary">
                <div class="card-body text-center">
                    <i class="fas fa-bed fa-2x text-primary mb-2"></i>
                    <h3 class="mb-1">${availableRooms}</h3>
                    <p class="text-muted mb-0">Rooms Ready</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Search -->
    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title mb-3">Quick Check-In Search</h5>
            <div class="row">
                <div class="col-md-8">
                    <div class="input-group input-group-lg">
                        <div class="input-group-prepend">
                            <span class="input-group-text bg-info text-white">
                                <i class="fas fa-search"></i>
                            </span>
                        </div>
                        <input type="text" class="form-control" id="searchInput" 
                               placeholder="Enter Booking ID, Guest Name, Phone Number, or scan QR code...">
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary" type="button" onclick="scanQRCode()">
                                <i class="fas fa-qrcode"></i> Scan QR
                            </button>
                            <button class="btn btn-info" type="button" onclick="searchReservation()">
                                <i class="fas fa-search"></i> Search
                            </button>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <button class="btn btn-success btn-lg btn-block" onclick="showWalkInForm()">
                        <i class="fas fa-user-plus"></i> Walk-in Guest
                    </button>
                </div>
            </div>
            
            <!-- Search Results -->
            <div id="searchResults" class="mt-4" style="display: none;">
                <h6>Search Results:</h6>
                <div id="resultsContainer">
                    <!-- Results will be loaded here -->
                </div>
                <button class="btn btn-sm btn-secondary mt-2" onclick="clearSearch()">
                    <i class="fas fa-times"></i> Clear Search
                </button>
            </div>
        </div>
    </div>
    
    <!-- Today's Check-ins -->
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0">
                <i class="fas fa-list"></i> Today's Check-ins
                <span class="badge badge-info ml-2">${todayCheckIns.size()}</span>
            </h5>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${not empty todayCheckIns}">
                    <div class="row">
                        <c:forEach var="reservation" items="${todayCheckIns}">
                            <div class="col-md-6 mb-3">
                                <div class="card border-left-info">
                                    <div class="card-body">
                                        <div class="row align-items-center">
                                            <div class="col-8">
                                                <h6 class="font-weight-bold text-primary mb-1">
                                                    ${reservation.customerName}
                                                </h6>
                                                <p class="text-xs mb-1">
                                                    <i class="fas fa-door-open mr-1"></i>
                                                    Room ${reservation.roomNumber} - ${reservation.roomTypeName}
                                                </p>
                                                <p class="text-xs mb-0">
                                                    <i class="fas fa-hashtag mr-1"></i>
                                                    Booking #${reservation.id}
                                                </p>
                                            </div>
                                            <div class="col-4 text-right">
                                                <div class="h5 mb-0 font-weight-bold text-gray-800">
                                                    <fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0"/>₫
                                                    <span class="text-muted">/ Total</span>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${reservation.checkedIn}">
                                                        <button class="btn btn-secondary" disabled>
                                                            <i class="fas fa-check"></i> Already Checked In
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="quick-action-btn btn btn-info" 
                                                                onclick="startCheckIn(${reservation.id})">
                                                            <i class="fas fa-user-check"></i> Process Check-In
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
                        <img src="${pageContext.request.contextPath}/assets/images/no-checkins.svg" 
                             alt="No check-ins" style="width: 200px; opacity: 0.6;">
                        <h5 class="mt-3 text-muted">No check-ins scheduled for today</h5>
                        <p class="text-muted">You can process walk-in guests or search for other reservations</p>
                        <button class="btn btn-primary mt-3" onclick="showWalkInForm()">
                            <i class="fas fa-user-plus"></i> Add Walk-in Guest
                        </button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Check-In Modal -->
<div class="modal fade" id="checkInModal" tabindex="-1" data-backdrop="static">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title">
                    <i class="fas fa-user-check"></i> Process Check-In
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="checkInForm">
                <input type="hidden" name="action" value="processCheckIn">
                <input type="hidden" name="reservationId" id="modalReservationId">
                
                <div class="modal-body">
                    <!-- Step Indicator -->
                    <div class="step-indicator mb-4">
                        <div class="step active" id="step1">
                            <div class="step-circle">1</div>
                            <div>Guest Verification</div>
                        </div>
                        <div class="step" id="step2">
                            <div class="step-circle">2</div>
                            <div>Room Assignment</div>
                        </div>
                        <div class="step" id="step3">
                            <div class="step-circle">3</div>
                            <div>Payment & Keys</div>
                        </div>
                    </div>
                    
                    <!-- Step 1: Guest Verification -->
                    <div id="step1Content" class="step-content">
                        <div class="row">
                            <div class="col-md-6">
                                <h6 class="mb-3"><i class="fas fa-user"></i> Guest Information</h6>
                                <div class="guest-info-box">
                                    <p class="mb-2"><strong>Name:</strong> <span id="modalGuestName"></span></p>
                                    <p class="mb-2"><strong>Phone:</strong> <span id="modalGuestPhone"></span></p>
                                    <p class="mb-2"><strong>Email:</strong> <span id="modalGuestEmail"></span></p>
                                    <p class="mb-0"><strong>Booking ID:</strong> #<span id="modalBookingId"></span></p>
                                </div>
                                
                                <div class="id-verification mt-3">
                                    <h6 class="mb-3"><i class="fas fa-id-card"></i> ID Verification</h6>
                                    <div class="form-group">
                                        <label>ID Type <span class="text-danger">*</span></label>
                                        <select class="form-control" name="idType" required>
                                            <option value="">Select ID Type</option>
                                            <option value="PASSPORT">Passport</option>
                                            <option value="NATIONAL_ID">National ID Card</option>
                                            <option value="DRIVER_LICENSE">Driver's License</option>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label>ID Number <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" name="idNumber" required>
                                    </div>
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="idVerified" 
                                               name="idVerified" value="Y" required>
                                        <label class="custom-control-label" for="idVerified">
                                            I have verified the guest's identity
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <h6 class="mb-3"><i class="fas fa-bed"></i> Reservation Details</h6>
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <tr>
                                            <td>Room:</td>
                                            <td><strong><span id="modalRoomNumber"></span></strong></td>
                                        </tr>
                                        <tr>
                                            <td>Room Type:</td>
                                            <td><span id="modalRoomType"></span></td>
                                        </tr>
                                        <tr>
                                            <td>Check-in:</td>
                                            <td><span id="modalCheckIn"></span></td>
                                        </tr>
                                        <tr>
                                            <td>Check-out:</td>
                                            <td><span id="modalCheckOut"></span></td>
                                        </tr>
                                        <tr>
                                            <td>Nights:</td>
                                            <td><span id="modalNights"></span></td>
                                        </tr>
                                        <tr>
                                            <td>Total Amount:</td>
                                            <td><strong class="text-primary"><span id="modalTotalAmount"></span></strong></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Step 2: Room Assignment -->
                    <div id="step2Content" class="step-content" style="display: none;">
                        <div class="row">
                            <div class="col-md-6">
                                <h6 class="mb-3"><i class="fas fa-key"></i> Room Assignment</h6>
                                <div class="room-card mb-3">
                                    <div class="room-number" id="assignedRoomNumber"></div>
                                    <div id="assignedRoomType"></div>
                                    <div class="mt-2">
                                        <span class="badge badge-light">Floor <span id="roomFloor"></span></span>
                                        <span class="badge badge-light ml-2">
                                            <i class="fas fa-check-circle"></i> Clean & Ready
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label>Number of Key Cards <span class="text-danger">*</span></label>
                                    <select class="form-control" name="keyCards" required>
                                        <option value="">Select number of key cards</option>
                                        <option value="1">1 Key Card</option>
                                        <option value="2" selected>2 Key Cards</option>
                                        <option value="3">3 Key Cards</option>
                                        <option value="4">4 Key Cards</option>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <label>Additional Guests</label>
                                    <input type="number" class="form-control" name="additionalGuests" 
                                           min="0" max="3" value="0">
                                    <small class="text-muted">Max capacity: <span id="maxCapacity">2</span> guests</small>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <h6 class="mb-3"><i class="fas fa-bed"></i> Room Features</h6>
                                <div class="room-features">
                                    <div class="custom-control custom-checkbox mb-2">
                                        <input type="checkbox" class="custom-control-input" 
                                               id="hasView" checked disabled>
                                        <label class="custom-control-label" for="hasView">City view</label>
                                    </div>
                                    <div class="custom-control custom-checkbox mb-2">
                                        <input type="checkbox" class="custom-control-input" 
                                               id="hasBalcony" checked disabled>
                                        <label class="custom-control-label" for="hasBalcony">Balcony</label>
                                    </div>
                                    <div class="custom-control custom-checkbox mb-2">
                                        <input type="checkbox" class="custom-control-input" 
                                               id="nearElevator" disabled>
                                        <label class="custom-control-label" for="nearElevator">Near elevator</label>
                                    </div>
                                </div>
                                
                                <div class="form-group mt-3">
                                    <label>Special Requests / Notes</label>
                                    <textarea class="form-control" name="specialRequests" rows="3" 
                                              placeholder="Any special requests or notes..."></textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Step 3: Payment & Keys -->
                    <div id="step3Content" class="step-content" style="display: none;">
                        <div class="row">
                            <div class="col-md-6">
                                <h6 class="mb-3"><i class="fas fa-money-check-alt"></i> Payment Summary</h6>
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <tr>
                                            <td>Room Charges:</td>
                                            <td class="text-right">
                                                <span id="paymentRoomCharges"></span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Security Deposit:</td>
                                            <td class="text-right">
                                                <input type="number" class="form-control form-control-sm text-right" 
                                                       name="securityDeposit" id="securityDeposit" 
                                                       value="500000" min="0" step="10000">
                                            </td>
                                        </tr>
                                        <tr class="font-weight-bold">
                                            <td>Total Due at Check-in:</td>
                                            <td class="text-right">
                                                <span id="totalDueAtCheckin" class="text-primary"></span>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                
                                <div class="form-group mt-3">
                                    <label>Key Card Numbers <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="keyCardNumbers" 
                                           placeholder="e.g., 101-A, 101-B" required>
                                    <small class="text-muted">Enter the key card numbers separated by commas</small>
                                </div>
                                
                                <div class="form-group">
                                    <label>Check-in Notes (Optional)</label>
                                    <textarea class="form-control" name="checkInNotes" rows="3" 
                                              placeholder="Any special notes or observations..."></textarea>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <h6 class="mb-3"><i class="fas fa-check-circle"></i> Final Checklist</h6>
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" class="custom-control-input" id="check1" required>
                                    <label class="custom-control-label" for="check1">
                                        Guest identity verified
                                    </label>
                                </div>
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" class="custom-control-input" id="check2" required>
                                    <label class="custom-control-label" for="check2">
                                        Payment/deposit received
                                    </label>
                                </div>
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" class="custom-control-input" id="check3" required>
                                    <label class="custom-control-label" for="check3">
                                        Key cards programmed and delivered
                                    </label>
                                </div>
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" class="custom-control-input" id="check4" required>
                                    <label class="custom-control-label" for="check4">
                                        Hotel policies explained
                                    </label>
                                </div>
                                <div class="custom-control custom-checkbox mb-2">
                                    <input type="checkbox" class="custom-control-input" id="check5" required>
                                    <label class="custom-control-label" for="check5">
                                        Welcome package provided
                                    </label>
                                </div>
                                
                                <div class="alert alert-success mt-3">
                                    <i class="fas fa-check-circle"></i> 
                                    Room ready for guest arrival!
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" id="btnPrevious" 
                            onclick="previousStep()" style="display: none;">
                        <i class="fas fa-arrow-left"></i> Previous
                    </button>
                    <button type="button" class="btn btn-info" id="btnNext" onclick="nextStep()">
                        Next <i class="fas fa-arrow-right"></i>
                    </button>
                    <button type="button" class="btn btn-success" id="btnComplete" 
                            style="display: none;" onclick="processCheckIn()">
                        <i class="fas fa-check-circle"></i> Complete Check-In
                    </button>
                    <button type="button" class="btn btn-outline-secondary" data-dismiss="modal">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Walk-in Guest Modal -->
<div class="modal fade" id="walkInModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">
                    <i class="fas fa-user-plus"></i> Walk-in Guest Registration
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="walkInForm">
                <div class="modal-body">
                    <!-- Walk-in form content here -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Create Booking
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let currentStep = 1;
let currentReservationData = null;

$(document).ready(function() {
    // Initialize tooltips
    $('[data-toggle="tooltip"]').tooltip();
    
    // Auto-search on enter key
    $('#searchInput').keypress(function(e) {
        if (e.which == 13) {
            searchReservation();
        }
    });
    
    // Update total due when security deposit changes
    $('#securityDeposit').on('input', function() {
        updateTotalDue();
    });
    
    // Form submission handler
    $('#checkInForm').on('submit', function(e) {
        e.preventDefault();
        
        if (!validateCurrentStep()) {
            return false;
        }
        
        processCheckIn();
        return false; // Extra prevention of default submit
    });
});

function searchReservation() {
    const query = $('#searchInput').val().trim();
    if (!query) {
        alert('Please enter a search term');
        return;
    }
    
    $('#searchResults').show();
    $('#resultsContainer').html('<div class="text-center py-4"><i class="fas fa-spinner fa-spin fa-2x"></i></div>');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/check-in',
        method: 'POST',
        data: {
            action: 'searchReservation',
            query: query
        },
        success: function(results) {
            displaySearchResults(results);
        },
        error: function() {
            $('#resultsContainer').html('<div class="alert alert-danger">Error searching reservations</div>');
        }
    });
}

function displaySearchResults(results) {
    if (!results || results.length === 0) {
        $('#resultsContainer').html('<div class="alert alert-warning">No reservations found</div>');
        return;
    }
    
    let html = '<div class="list-group">';
    results.forEach(function(res) {
        let statusBadge = res.checkedIn ? 
            '<span class="badge badge-success">Checked In</span>' : 
            '<span class="badge badge-warning">Pending</span>';
            
        html += '<div class="list-group-item list-group-item-action">';
        html += '<div class="d-flex justify-content-between align-items-center">';
        html += '<div>';
        html += '<h6 class="mb-1">' + res.customerName + '</h6>';
        html += '<p class="mb-1">Booking #' + res.id + ' | Room ' + res.roomNumber + '</p>';
        html += '<small>Check-in: ' + formatDate(res.checkIn) + '</small>';
        html += '</div>';
        html += '<div>';
        html += statusBadge;
        if (!res.checkedIn) {
            html += '<button class="btn btn-info btn-sm ml-2" onclick="startCheckIn(' + res.id + ')">';
            html += '<i class="fas fa-user-check"></i> Check In';
            html += '</button>';
        }
        html += '</div>';
        html += '</div>';
        html += '</div>';
    });
    html += '</div>';
    
    $('#resultsContainer').html(html);
}

function clearSearch() {
    $('#searchInput').val('');
    $('#searchResults').hide();
}

function startCheckIn(reservationId) {
    // Get reservation details
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/check-in',
        method: 'POST',
        data: {
            action: 'getReservationDetails',
            reservationId: reservationId
        },
        success: function(reservation) {
            currentReservationData = reservation;
            populateCheckInModal(reservation);
            $('#checkInModal').modal('show');
            currentStep = 1;
            showStep(1);
        },
        error: function() {
            alert('Error loading reservation details');
        }
    });
}

function populateCheckInModal(reservation) {
    // Guest info
    $('#modalReservationId').val(reservation.id);
    $('#modalGuestName').text(reservation.customerName);
    $('#modalGuestPhone').text(reservation.customerPhone);
    $('#modalGuestEmail').text(reservation.customerEmail);
    $('#modalBookingId').text(reservation.id);
    
    // Room info
    $('#modalRoomNumber').text(reservation.roomNumber);
    $('#modalRoomType').text(reservation.roomTypeName);
    $('#modalCheckIn').text(formatDate(reservation.checkIn));
    $('#modalCheckOut').text(formatDate(reservation.checkOut));
    $('#modalNights').text(reservation.nights);
    $('#modalTotalAmount').text(formatCurrency(reservation.totalAmount));
    
    // Step 2
    $('#assignedRoomNumber').text(reservation.roomNumber);
    $('#assignedRoomType').text(reservation.roomTypeName);
    $('#roomFloor').text(Math.floor(reservation.roomNumber / 100));
    $('#maxCapacity').text(reservation.maxOccupancy || 2);
    
    // Step 3
    $('#paymentRoomCharges').text(formatCurrency(reservation.totalAmount));
    updateTotalDue();
}

function showStep(step) {
    // Hide all steps
    $('.step-content').hide();
    $('.step').removeClass('active completed');
    
    // Show current step
    $('#step' + step + 'Content').show();
    
    // Update step indicators
    for (let i = 1; i <= step; i++) {
        if (i < step) {
            $('#step' + i).addClass('completed');
        } else {
            $('#step' + i).addClass('active');
        }
    }
    
    // Update buttons
    $('#btnPrevious').toggle(step > 1);
    $('#btnNext').toggle(step < 3);
    $('#btnComplete').toggle(step === 3);
}

function nextStep() {
    if (validateCurrentStep()) {
        currentStep++;
        showStep(currentStep);
    }
}

function previousStep() {
    if (currentStep > 1) {
        currentStep--;
        showStep(currentStep);
    }
}

function validateCurrentStep() {
    if (currentStep === 1) {
        // Validate ID verification
        if (!$('#idVerified').is(':checked')) {
            alert('Please verify guest identity');
            return false;
        }
        if (!$('select[name="idType"]').val() || !$('input[name="idNumber"]').val()) {
            alert('Please enter ID information');
            return false;
        }
    } else if (currentStep === 2) {
        // Validate key cards
        if (!$('select[name="keyCards"]').val()) {
            alert('Please select number of key cards');
            return false;
        }
    } else if (currentStep === 3) {
        // Validate key card numbers
        if (!$('input[name="keyCardNumbers"]').val()) {
            alert('Please enter key card numbers');
            return false;
        }
        
        // Validate all checkboxes
        let allChecked = true;
        $('#step3Content input[type="checkbox"]').each(function() {
            if (!$(this).is(':checked')) {
                allChecked = false;
            }
        });
        if (!allChecked) {
            alert('Please complete all checklist items');
            return false;
        }
    }
    return true;
}

function updateTotalDue() {
    const roomCharges = currentReservationData ? currentReservationData.totalAmount : 0;
    const securityDeposit = parseFloat($('#securityDeposit').val()) || 0;
    const total = securityDeposit; // Room charges may be paid separately
    $('#totalDueAtCheckin').text(formatCurrency(total));
}

function processCheckIn() {
    // Show loading
    const btn = $('#btnComplete');
    const originalText = btn.html();
    btn.html('<i class="fas fa-spinner fa-spin"></i> Processing...').prop('disabled', true);
    
    // Submit form data
    const formData = $('#checkInForm').serialize();
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/check-in',
        method: 'POST',
        data: formData,
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                $('#checkInModal').modal('hide');
                // Show success message with SweetAlert2
                Swal.fire({
                    icon: 'success',
                    title: 'Check-in Successful!',
                    text: 'Guest has been checked into room ' + currentReservationData.roomNumber,
                    showConfirmButton: false,
                    timer: 2000
                }).then(() => {
                    // Reload page
                    location.reload();
                });
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Check-in Failed',
                    text: response.message || 'Failed to process check-in'
                });
                btn.html(originalText).prop('disabled', false);
            }
        },
        error: function(xhr, status, error) {
            console.error('Check-in error:', error);
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: 'Error processing check-in. Please try again.'
            });
            btn.html(originalText).prop('disabled', false);
        }
    });
}

function scanQRCode() {
    Swal.fire({
        icon: 'info',
        title: 'QR Scanner',
        text: 'QR code scanner would open here (feature not yet implemented)'
    });
}

function showWalkInForm() {
    $('#walkInModal').modal('show');
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(amount);
}
</script>