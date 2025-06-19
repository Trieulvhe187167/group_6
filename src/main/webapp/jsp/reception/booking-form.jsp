<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.booking-section {
    background: white;
    padding: 25px;
    border-radius: 10px;
    margin-bottom: 20px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.booking-section h5 {
    color: #17a2b8;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #e9ecef;
}

.room-selection-card {
    border: 2px solid #e9ecef;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 10px;
    cursor: pointer;
    transition: all 0.3s;
    background: white;
}

.room-selection-card:hover {
    border-color: #17a2b8;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    transform: translateY(-1px);
}

.room-selection-card.selected {
    border-color: #17a2b8;
    background: rgba(23, 162, 184, 0.1);
}

.price-display {
    font-size: 18px;
    font-weight: bold;
    color: #17a2b8;
}

.total-summary {
    background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
    color: white;
    padding: 20px;
    border-radius: 8px;
    margin-top: 20px;
}

.guest-type-selector {
    display: flex;
    margin-bottom: 20px;
}

.guest-type-selector .btn {
    flex: 1;
    margin-right: 10px;
}

.guest-type-selector .btn:last-child {
    margin-right: 0;
}
</style>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h2>Create New Booking</h2>
            <p class="text-muted">Process walk-in guests and create new reservations</p>
        </div>
        <div class="col-md-6 text-right">
            <a href="${pageContext.request.contextPath}/reception-dashboard" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
    </div>
    
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="fas fa-exclamation-triangle mr-2"></i>
            ${error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="fas fa-check-circle mr-2"></i>
            ${success}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <form method="post" action="${pageContext.request.contextPath}/receptionist/booking" id="bookingForm">
        <input type="hidden" name="action" value="createBooking">
        
        <div class="row">
            <div class="col-lg-8">
                <!-- Guest Information -->
                <div class="booking-section">
                    <h5><i class="fas fa-user"></i> Guest Information</h5>
                    
                    <div class="guest-type-selector">
                        <button type="button" class="btn btn-outline-primary active" id="existingGuestBtn" onclick="setGuestType('existing')">
                            <i class="fas fa-users"></i> Existing Customer
                        </button>
                        <button type="button" class="btn btn-outline-primary" id="newGuestBtn" onclick="setGuestType('new')">
                            <i class="fas fa-user-plus"></i> New Customer
                        </button>
                    </div>
                    
                    <input type="hidden" name="guestType" id="guestType" value="existing">
                    
                    <!-- Existing Guest Selection -->
                    <div id="existingGuestSection">
                        <div class="form-group">
                            <label>Select Guest <span class="text-danger">*</span></label>
                            <select name="guestId" class="form-control" id="guestSelect" required>
                                <option value="">-- Select Guest --</option>
                                <c:forEach var="guest" items="${guests}">
                                    <option value="${guest.id}" data-phone="${guest.phone}" data-email="${guest.email}">
                                        ${guest.fullName} - ${guest.phone}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <div id="selectedGuestInfo" style="display: none;">
                            <div class="alert alert-info">
                                <div class="row">
                                    <div class="col-md-6">
                                        <strong>Name:</strong> <span id="guestInfoName"></span><br>
                                        <strong>Phone:</strong> <span id="guestInfoPhone"></span>
                                    </div>
                                    <div class="col-md-6">
                                        <strong>Email:</strong> <span id="guestInfoEmail"></span><br>
                                        <strong>Total Bookings:</strong> <span id="guestInfoBookings"></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- New Guest Form -->
                    <div id="newGuestSection" style="display: none;">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Full Name <span class="text-danger">*</span></label>
                                    <input type="text" name="newGuestName" class="form-control" id="newGuestName"
                                           placeholder="Enter guest's full name">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Phone Number <span class="text-danger">*</span></label>
                                    <input type="tel" name="newGuestPhone" class="form-control" id="newGuestPhone"
                                           placeholder="Enter phone number" pattern="0[0-9]{9}">
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Email Address <span class="text-danger">*</span></label>
                            <input type="email" name="newGuestEmail" class="form-control" id="newGuestEmail"
                                   placeholder="Enter email address">
                        </div>
                    </div>
                </div>
                
                <!-- Booking Details -->
                <div class="booking-section">
                    <h5><i class="fas fa-calendar-alt"></i> Booking Details</h5>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Check-in Date <span class="text-danger">*</span></label>
                                <input type="date" name="checkIn" class="form-control" id="checkIn" 
                                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Check-out Date <span class="text-danger">*</span></label>
                                <input type="date" name="checkOut" class="form-control" id="checkOut" required>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Filter by Room Type</label>
                        <select id="roomTypeFilter" class="form-control">
                            <option value="">All Room Types</option>
                            <c:forEach var="roomType" items="${roomTypes}">
                                <option value="${roomType.id}">
                                    ${roomType.name} - <fmt:formatNumber value="${roomType.basePrice}" pattern="#,##0"/>₫/night
                                    (Capacity: ${roomType.capacity})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <button type="button" class="btn btn-primary btn-lg" onclick="checkAvailability()">
                        <i class="fas fa-search"></i> Check Room Availability
                    </button>
                </div>
                
                <!-- Available Rooms -->
                <div class="booking-section">
                    <h5><i class="fas fa-bed"></i> Available Rooms</h5>
                    <div id="availableRooms">
                        <div class="text-center py-4">
                            <i class="fas fa-calendar-day fa-3x text-muted mb-3"></i>
                            <p class="text-muted">Please select dates and check availability to see available rooms</p>
                        </div>
                    </div>
                    <input type="hidden" name="roomId" id="selectedRoom" required>
                </div>
                
                <!-- Additional Information -->
                <div class="booking-section">
                    <h5><i class="fas fa-clipboard"></i> Additional Information</h5>
                    
                    <div class="form-group">
                        <label>Special Requests / Notes</label>
                        <textarea name="notes" class="form-control" rows="3" id="bookingNotes"
                                  placeholder="Any special requests, preferences, or notes about this booking..."></textarea>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-4">
                <!-- Booking Summary -->
                <div class="table-container sticky-top" style="top: 20px;">
                    <h5><i class="fas fa-receipt"></i> Booking Summary</h5>
                    
                    <div id="bookingSummary">
                        <div class="text-center py-4">
                            <i class="fas fa-hand-point-left fa-2x text-muted mb-3"></i>
                            <p class="text-muted">Select a room to see booking summary</p>
                        </div>
                    </div>
                    
                    <div class="mt-4">
                        <button type="submit" class="btn btn-success btn-lg btn-block" disabled id="submitBtn">
                            <i class="fas fa-check-circle"></i> Confirm Booking
                        </button>
                        
                        <a href="${pageContext.request.contextPath}/reception-dashboard" 
                           class="btn btn-secondary btn-lg btn-block mt-2">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<script>
$(document).ready(function() {
    // Set minimum checkout date when checkin changes
    $('#checkIn').change(function() {
        var checkIn = new Date($(this).val());
        checkIn.setDate(checkIn.getDate() + 1);
        var minCheckOut = checkIn.toISOString().split('T')[0];
        $('#checkOut').attr('min', minCheckOut);
        
        // Clear checkout if it's before new minimum
        if ($('#checkOut').val() && $('#checkOut').val() <= $(this).val()) {
            $('#checkOut').val('');
        }
        
        clearRoomSelection();
    });
    
    $('#checkOut').change(function() {
        clearRoomSelection();
    });
    
    $('#roomTypeFilter').change(function() {
        if ($('#checkIn').val() && $('#checkOut').val()) {
            checkAvailability();
        }
    });
    
    // Show guest info when selecting existing guest
    $('#guestSelect').change(function() {
        var selectedOption = $(this).find('option:selected');
        if (selectedOption.val()) {
            $('#guestInfoName').text(selectedOption.text().split(' - ')[0]);
            $('#guestInfoPhone').text(selectedOption.data('phone'));
            $('#guestInfoEmail').text(selectedOption.data('email'));
            $('#guestInfoBookings').text('N/A'); // This could be populated if available
            $('#selectedGuestInfo').show();
        } else {
            $('#selectedGuestInfo').hide();
        }
    });
    
    // Form validation
    $('#bookingForm').submit(function(e) {
        if (!validateForm()) {
            e.preventDefault();
        }
    });
});

function setGuestType(type) {
    $('#guestType').val(type);
    
    if (type === 'existing') {
        $('#existingGuestBtn').addClass('active');
        $('#newGuestBtn').removeClass('active');
        $('#existingGuestSection').show();
        $('#newGuestSection').hide();
        
        // Set validation
        $('#guestSelect').prop('required', true);
        $('#newGuestName, #newGuestEmail, #newGuestPhone').prop('required', false);
    } else {
        $('#newGuestBtn').addClass('active');
        $('#existingGuestBtn').removeClass('active');
        $('#newGuestSection').show();
        $('#existingGuestSection').hide();
        $('#selectedGuestInfo').hide();
        
        // Set validation
        $('#guestSelect').prop('required', false);
        $('#newGuestName, #newGuestEmail, #newGuestPhone').prop('required', true);
    }
}

function checkAvailability() {
    var checkIn = $('#checkIn').val();
    var checkOut = $('#checkOut').val();
    var roomTypeId = $('#roomTypeFilter').val();
    
    if (!checkIn || !checkOut) {
        alert('Please select check-in and check-out dates');
        return;
    }
    
    if (new Date(checkOut) <= new Date(checkIn)) {
        alert('Check-out date must be after check-in date');
        return;
    }
    
    // Show loading
    $('#availableRooms').html('<div class="text-center py-4"><i class="fas fa-spinner fa-spin fa-2x text-primary"></i><p class="mt-2">Checking availability...</p></div>');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/booking',
        method: 'GET',
        data: {
            action: 'checkAvailability',
            checkIn: checkIn,
            checkOut: checkOut,
            roomTypeId: roomTypeId
        },
        success: function(rooms) {
            displayAvailableRooms(rooms);
        },
        error: function() {
            $('#availableRooms').html('<div class="alert alert-danger"><i class="fas fa-exclamation-triangle mr-2"></i>Error checking availability. Please try again.</div>');
        }
    });
}

function displayAvailableRooms(rooms) {
    var html = '';
    
    if (rooms.length === 0) {
        html = '<div class="text-center py-4">' +
               '<i class="fas fa-bed fa-3x text-muted mb-3"></i>' +
               '<p class="text-danger font-weight-bold">No rooms available for selected dates</p>' +
               '<p class="text-muted">Please try different dates or contact management for assistance</p>' +
               '</div>';
    } else {
        rooms.forEach(function(room) {
            html += '<div class="room-selection-card" onclick="selectRoom(' + room.id + ', \'' + 
                    room.roomNumber + '\', ' + room.price + ', \'' + room.roomType + '\')">';
            html += '<div class="row align-items-center">';
            html += '<div class="col-md-8">';
            html += '<h6 class="mb-1">Room ' + room.roomNumber + '</h6>';
            html += '<p class="mb-1 text-muted">Type: ' + room.roomType + '</p>';
            html += '<small class="text-muted">Perfect for your stay</small>';
            html += '</div>';
            html += '<div class="col-md-4 text-right">';
            html += '<div class="price-display">' + formatCurrency(room.price) + '₫</div>';
            html += '<small class="text-muted">per night</small>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
        });
    }
    
    $('#availableRooms').html(html);
}

function selectRoom(roomId, roomNumber, price, roomType) {
    // Remove previous selection
    $('.room-selection-card').removeClass('selected');
    
    // Add selection to clicked room
    event.currentTarget.classList.add('selected');
    
    // Set hidden field
    $('#selectedRoom').val(roomId);
    
    // Calculate and show summary
    updateBookingSummary(roomNumber, roomType, price);
    
    // Enable submit button
    $('#submitBtn').prop('disabled', false);
}

function updateBookingSummary(roomNumber, roomType, pricePerNight) {
    var checkIn = new Date($('#checkIn').val());
    var checkOut = new Date($('#checkOut').val());
    var nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
    var subtotal = nights * pricePerNight;
    var tax = subtotal * 0.1; // 10% tax
    var total = subtotal + tax;
    
    var html = '<div class="booking-summary-content">';
    html += '<div class="row mb-2">';
    html += '<div class="col-8"><strong>Room ' + roomNumber + '</strong></div>';
    html += '<div class="col-4 text-right">' + formatCurrency(pricePerNight) + '₫</div>';
    html += '</div>';
    html += '<div class="row mb-2">';
    html += '<div class="col-8 text-muted">' + roomType + '</div>';
    html += '<div class="col-4 text-right text-muted">× ' + nights + ' nights</div>';
    html += '</div>';
    html += '<hr>';
    html += '<div class="row mb-2">';
    html += '<div class="col-8">Subtotal</div>';
    html += '<div class="col-4 text-right">' + formatCurrency(subtotal) + '₫</div>';
    html += '</div>';
    html += '<div class="row mb-2">';
    html += '<div class="col-8">Tax (10%)</div>';
    html += '<div class="col-4 text-right">' + formatCurrency(tax) + '₫</div>';
    html += '</div>';
    html += '</div>';
    
    var totalHtml = '<div class="total-summary">';
    totalHtml += '<div class="row align-items-center">';
    totalHtml += '<div class="col-8">';
    totalHtml += '<h5 class="mb-0">Total Amount</h5>';
    totalHtml += '<small>' + nights + ' nights in ' + roomType + '</small>';
    totalHtml += '</div>';
    totalHtml += '<div class="col-4 text-right">';
    totalHtml += '<h4 class="mb-0">' + formatCurrency(total) + '₫</h4>';
    totalHtml += '</div>';
    totalHtml += '</div>';
    totalHtml += '</div>';
    
    $('#bookingSummary').html(html + totalHtml);
}

function clearRoomSelection() {
    $('#selectedRoom').val('');
    $('#submitBtn').prop('disabled', true);
    $('#availableRooms').html('<div class="text-center py-4"><i class="fas fa-calendar-day fa-3x text-muted mb-3"></i><p class="text-muted">Please check availability to see available rooms</p></div>');
    $('#bookingSummary').html('<div class="text-center py-4"><i class="fas fa-hand-point-left fa-2x text-muted mb-3"></i><p class="text-muted">Select a room to see booking summary</p></div>');
}

function validateForm() {
    var guestType = $('#guestType').val();
    
    // Validate guest information
    if (guestType === 'existing') {
        if (!$('#guestSelect').val()) {
            alert('Please select a guest');
            $('#guestSelect').focus();
            return false;
        }
    } else {
        if (!$('#newGuestName').val().trim()) {
            alert('Please enter guest name');
            $('#newGuestName').focus();
            return false;
        }
        if (!$('#newGuestEmail').val().trim()) {
            alert('Please enter guest email');
            $('#newGuestEmail').focus();
            return false;
        }
        if (!$('#newGuestPhone').val().trim()) {
            alert('Please enter guest phone');
            $('#newGuestPhone').focus();
            return false;
        }
    }
    
    // Validate dates
    if (!$('#checkIn').val()) {
        alert('Please select check-in date');
        $('#checkIn').focus();
        return false;
    }
    
    if (!$('#checkOut').val()) {
        alert('Please select check-out date');
        $('#checkOut').focus();
        return false;
    }
    
    // Validate room selection
    if (!$('#selectedRoom').val()) {
        alert('Please select a room');
        return false;
    }
    
    return true;
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount);
}
</script>