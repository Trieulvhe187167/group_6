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

/* Services Section Styling */
.services-grid {
    max-height: 400px;
    overflow-y: auto;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    padding: 15px;
    background: #f8f9fa;
}

.services-grid::-webkit-scrollbar {
    width: 8px;
}

.services-grid::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
}

.services-grid::-webkit-scrollbar-thumb {
    background: #17a2b8;
    border-radius: 4px;
}

.service-item {
    background: white;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 10px;
    border: 1px solid #dee2e6;
    transition: all 0.3s;
}

.service-item:hover {
    border-color: #17a2b8;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.service-item.selected {
    background: #e7f8fa;
    border-color: #17a2b8;
}

.service-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 5px;
}

.service-price {
    color: #17a2b8;
    font-weight: bold;
    white-space: nowrap;
}

.custom-control-label {
    width: 100%;
    cursor: pointer;
}

/* Selected services counter */
.services-selected-count {
    float: right;
    background: #17a2b8;
    color: white;
    padding: 2px 10px;
    border-radius: 15px;
    font-size: 12px;
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
           <button type="button" class="close" data-bs-dismiss="modal" data-dismiss="modal">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="fas fa-check-circle mr-2"></i>
            ${success}
            <button type="button" class="close" data-bs-dismiss="modal" data-dismiss="modal">
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
                            <label>Select Customer <span class="text-danger">*</span></label>
                            <select name="customerId" class="form-control" id="customerSelect" required>
                                <option value="">-- Select Customer --</option>
                                <c:forEach var="customer" items="${customers}">
                                    <option value="${customer.id}" data-phone="${customer.phone}" data-email="${customer.email}">
                                        ${customer.fullName} - ${customer.phone}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <div id="selectedCustomerInfo" style="display: none;">
                            <div class="alert alert-info">
                                <div class="row">
                                    <div class="col-md-6">
                                        <strong>Name:</strong> <span id="customerInfoName"></span><br>
                                        <strong>Phone:</strong> <span id="customerInfoPhone"></span>
                                    </div>
                                    <div class="col-md-6">
                                        <strong>Email:</strong> <span id="customerInfoEmail"></span><br>
                                        <strong>Total Bookings:</strong> <span id="customerInfoBookings"></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- New Customer Form -->
                    <div id="newCustomerSection" style="display: none;">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Full Name <span class="text-danger">*</span></label>
                                    <input type="text" name="newCustomerName" class="form-control" id="newCustomerName"
                                           placeholder="Enter customer's full name">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Phone Number <span class="text-danger">*</span></label>
                                    <input type="tel" name="newCustomerPhone" class="form-control" id="newCustomerPhone"
                                           placeholder="Enter phone number" pattern="0[0-9]{9}">
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Email Address <span class="text-danger">*</span></label>
                            <input type="email" name="newCustomerEmail" class="form-control" id="newCustomerEmail"
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
                    <!-- Multiple room selection -->
                </div>
                
              <!-- Additional Services Section -->
<div class="booking-section">
    <h5><i class="fas fa-concierge-bell"></i> Additional Services <span class="text-muted" style="font-size: 14px; font-weight: normal;">Optional</span></h5>
    
    <!-- Search Box -->
    <div class="service-search-box mb-3">
        <div class="input-group">
            <div class="input-group-prepend">
                <span class="input-group-text bg-white border-right-0">
                    <i class="fas fa-search text-muted"></i>
                </span>
            </div>
            <input type="text" 
                   id="serviceSearch" 
                   class="form-control border-left-0" 
                   placeholder="Search services..."
                   onkeyup="searchServices()">
        </div>
    </div>
    
    <!-- Service Category Filters -->
    <div class="service-filters mb-3">
        <button type="button" class="btn btn-service-filter active" data-category="all" onclick="filterServices('all')">
            All Services
        </button>
        <button type="button" class="btn btn-service-filter" data-category="TRANSPORT" onclick="filterServices('TRANSPORT')">
            Transportation
        </button>
        <button type="button" class="btn btn-service-filter" data-category="DINING" onclick="filterServices('DINING')">
            Dining
        </button>
        <button type="button" class="btn btn-service-filter" data-category="SPA" onclick="filterServices('SPA')">
            Spa & Wellness
        </button>
        <button type="button" class="btn btn-service-filter" data-category="SPECIAL" onclick="filterServices('SPECIAL')">
            Special Services
        </button>
    </div>
    
    <!-- Services List -->
    <div id="servicesContainer" class="services-grid">
        <c:forEach var="service" items="${services}">
            <div class="service-item" data-category="${service.category}">
           <div class="service-header">
                    <div class="service-title-section">
                        <c:choose>
                            <c:when test="${service.category == 'TRANSPORT'}">
                                <i class="fas fa-car service-icon"></i>
                            </c:when>
                            <c:when test="${service.category == 'DINING'}">
                                <i class="fas fa-utensils service-icon"></i>
                            </c:when>
                            <c:when test="${service.category == 'SPA'}">
                                <i class="fas fa-spa service-icon"></i>
                            </c:when>
                            <c:when test="${service.category == 'SPECIAL'}">
                                <i class="fas fa-star service-icon"></i>
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-concierge-bell service-icon"></i>
                            </c:otherwise>
                        </c:choose>
                        <div>
                            <strong>${service.name}</strong>
                            <span class="service-category-badge">${service.category}</span>
                        </div>
                       
                    </div>
                    <span class="service-price">
                        <fmt:formatNumber value="${service.price}" pattern="#,###"/>₫
                    </span>
                </div>
                <small class="text-muted service-description">${service.description}</small>
                <div class="mt-2 d-flex align-items-center">
                    <input type="number" class="form-control service-qty-input" style="width:70px;" min="0" value="0"
                           name="service_${service.id}" data-price="${service.price}" data-name="${service.name}"
                           onchange="updateServicesSummary()" />
                    <div class="ml-2 service-room-options" data-service-id="${service.id}">
                        <!-- room checkboxes inserted via JS -->
                    </div>
                    </select>
                </div>  
            </div>
        </c:forEach>
        
        <!-- No results message -->
        <div id="noServicesMessage" class="text-center py-4" style="display: none;">
            <i class="fas fa-search fa-2x text-muted mb-2"></i>
            <p class="text-muted">No services found matching your search</p>
        </div>
    </div>
    
    <c:if test="${empty services}">
        <div class="text-center py-3 text-muted">
            No additional services available
        </div>
    </c:if>
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
                <div class="table-container sticky-top" style="top: 100px;">
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
    
    // Show customer info when selecting existing customer
    $('#customerSelect').change(function() {
        var selectedOption = $(this).find('option:selected');
        if (selectedOption.val()) {
            $('#customerInfoName').text(selectedOption.text().split(' - ')[0]);
            $('#customerInfoPhone').text(selectedOption.data('phone'));
            $('#customerInfoEmail').text(selectedOption.data('email'));
            $('#customerInfoBookings').text('N/A'); // This could be populated if available
            $('#selectedCustomerInfo').show();
        } else {
            $('#selectedCustomerInfo').hide();
        }
    });
    
    // Form validation
    $('#bookingForm').submit(function(e) {
        if (!validateForm()) {
            e.preventDefault();
        }
    });
    
    // Initialize services counter on page load
    updateServicesSummary();
      updateServiceRoomOptions();
});

function setGuestType(type) {
    $('#guestType').val(type);
    
    if (type === 'existing') {
        $('#existingGuestBtn').addClass('active');
        $('#newGuestBtn').removeClass('active');
        $('#existingGuestSection').show();
        $('#newCustomerSection').hide();
        
        // Set validation
        $('#customerSelect').prop('required', true);
        $('#newCustomerName, #newCustomerEmail, #newCustomerPhone').prop('required', false);
    } else {
        $('#newGuestBtn').addClass('active');
        $('#existingGuestBtn').removeClass('active');
        $('#newCustomerSection').show();
        $('#existingGuestSection').hide();
        $('#selectedCustomerInfo').hide();
        
        // Set validation
        $('#customerSelect').prop('required', false);
        $('#newCustomerName, #newCustomerEmail, #newCustomerPhone').prop('required', true);
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
            html += '<div class="room-selection-card">';
            html += '<label class="w-100">';
            html += '<div class="row align-items-center">';
            html += '<div class="col-md-1 text-center">';
            html += '<input type="checkbox" class="room-checkbox" name="roomIds" value="' + room.id + '" ' +
                    'data-number="' + room.roomNumber + '" data-price="' + room.price + '" data-type="' + room.roomType + '" ' +
                    'onchange="handleRoomSelectionChange()">';
            html += '</div>';
            html += '<div class="col-md-7">';
            html += '<h6 class="mb-1">Room ' + room.roomNumber + '</h6>';
            html += '<p class="mb-1 text-muted">Type: ' + room.roomType + '</p>';
            html += '<small class="text-muted">Perfect for your stay</small>';
            html += '</div>';
            html += '<div class="col-md-4 text-right">';
            html += '<div class="price-display">' + formatCurrency(room.price) + '₫</div>';
            html += '<small class="text-muted">per night</small>';
            html += '</div>';
            html += '</div>';
            html += '</label>';
            html += '</div>';
        });
    }

    $('#availableRooms').html(html);
    handleRoomSelectionChange();
}

// Update booking summary with room and services
function updateRoomSummary() {
    var checkIn = new Date($('#checkIn').val());
    var checkOut = new Date($('#checkOut').val());
    var nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
      var roomSubtotal = 0;
    var selectedRooms = [];
    $('input[name="roomIds"]').each(function(){
        if(this.checked){
            var price = parseFloat($(this).data('price'));
            roomSubtotal += price * nights;
            selectedRooms.push({
                id: $(this).val(),
                number: $(this).data('number'),
                type: $(this).data('type'),
                price: price
            });
            $(this).closest('.room-selection-card').addClass('selected');
        } else {
            $(this).closest('.room-selection-card').removeClass('selected');
        }
    });

var servicesTotal = 0;
var selectedServices = [];
 var servicesByRoom = {};
    document.querySelectorAll('.service-qty-input').forEach(function(input){
        var qty = parseInt(input.value) || 0;
        if(qty > 0){
            var price = parseFloat(input.getAttribute('data-price'));
            var name = input.getAttribute('data-name');
            var container = input.parentElement.querySelector('.service-room-options');
            var rooms = [];
            if(container){
                container.querySelectorAll('input.service-room-checkbox:checked').forEach(function(cb){
                    rooms.push(cb.value);
                });
            }
            if(rooms.length === 0 || rooms.includes('ALL')){
                rooms = selectedRooms.map(function(r){ return r.id; });
            }
            var roomCount = rooms.length;
            servicesTotal += price * qty * roomCount;
            selectedServices.push({name: name, qty: qty * roomCount, price: price * qty * roomCount});
            rooms.forEach(function(rid){
                if(!servicesByRoom[rid]) servicesByRoom[rid] = [];
                servicesByRoom[rid].push({name: name, qty: qty, price: price * qty});
            });
            input.closest('.service-item').classList.add('selected');
        } else {
            input.closest('.service-item').classList.remove('selected');
        }
});
    
    var subtotal = roomSubtotal + servicesTotal;
    var tax = subtotal * 0.1; // 10% tax
    var total = subtotal + tax;
    
    // Build HTML
    var html = '<div class="booking-summary-content">';
    
    // Room details
    html += '<div class="row mb-2">';
    html += '<div class="col-8"><strong>' + selectedRooms.length + ' room(s)</strong></div>';
    html += '<div class="col-4 text-right">' + formatCurrency(roomSubtotal) + '₫</div>';
    html += '</div>';
    html += '<div class="row mb-2">';
     html += '<div class="col-12 text-muted">× ' + nights + ' nights</div>';
    html += '</div>';
        selectedRooms.forEach(function(room){
        html += '<div class="row mb-1">';
        html += '<div class="col-8 text-muted"><small>Room ' + room.number + ' (' + room.type + ')</small></div>';
        html += '<div class="col-4 text-right text-muted"><small>' + formatCurrency(room.price * nights) + '₫</small></div>';
        html += '</div>';
        var list = servicesByRoom[room.id] || [];
        list.forEach(function(s){
            html += '<div class="row mb-1 pl-3">';
            html += '<div class="col-8 text-muted"><small>&mdash; ' + s.name + ' × ' + s.qty + '</small></div>';
            html += '<div class="col-4 text-right text-muted"><small>' + formatCurrency(s.price) + '₫</small></div>';
            html += '</div>';
        });
    });
    // Services details
    if (selectedServices.length > 0) {
        html += '<hr>';
        html += '<h6 class="mb-2"><i class="fas fa-concierge-bell mr-1"></i>Additional Services</h6>';
        
        selectedServices.forEach(function(service) {
            html += '<div class="row mb-1">';
            html += '<div class="col-8 text-muted"><small>' + service.name + '</small></div>';
            html += '<div class="col-4 text-right"><small>' + formatCurrency(service.price) + '₫</small></div>';
            html += '</div>';
        });
        
        html += '<div class="row mb-3">';
        html += '<div class="col-8">Services Total</div>';
        html += '<div class="col-4 text-right">' + formatCurrency(servicesTotal) + '₫</div>';
        html += '</div>';
    }
    
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
    
    // Total section
    var totalHtml = '<div class="total-summary">';
    totalHtml += '<div class="row align-items-center">';
    totalHtml += '<div class="col-8">';
    totalHtml += '<h5 class="mb-0">Total Amount</h5>';
    totalHtml += '<small>' + nights + ' nights';
    if (selectedServices.length > 0) {
        totalHtml += ' + ' + selectedServices.length + ' service(s)';
    }
    totalHtml += '</small>';
    totalHtml += '</div>';
    totalHtml += '<div class="col-4 text-right">';
    totalHtml += '<h4 class="mb-0">' + formatCurrency(total) + '₫</h4>';
    totalHtml += '</div>';
    totalHtml += '</div>';
    totalHtml += '</div>';
    
      $('#bookingSummary').html(html + totalHtml);

    // Enable submit button if at least one room is selected
    if (selectedRooms.length > 0) {
        $('#submitBtn').prop('disabled', false);
    } else {
        $('#submitBtn').prop('disabled', true);
    }

    // Keep service checkboxes up to date
    updateServiceRoomOptions();
}
// Handle room checkbox changes
function handleRoomSelectionChange() {
    updateRoomSummary();
    updateServiceRoomOptions();
}
// Update services summary when services are selected/deselected
function updateServicesSummary() {
    let selectedCount = 0;
    const totalRooms = $('input[name="roomIds"]:checked').length;
    document.querySelectorAll('.service-qty-input').forEach(input => {
        const qty = parseInt(input.value) || 0;
        if (qty > 0) {
            const select = input.parentElement.querySelector('.service-room-select');
            const rooms = $(select).val() || [];
            let roomCount = rooms.includes('ALL') ? totalRooms : rooms.length;
            if (roomCount === 0) {
                roomCount = totalRooms;
            }
            selectedCount += qty * roomCount;
            input.closest('.service-item').classList.add('selected');
        } else {
            input.closest('.service-item').classList.remove('selected');
        }
    });

    updateSelectedCount(selectedCount);
    updateRoomSummary();
}

// Update selected services counter
function updateSelectedCount(count) {
    const existingCounter = document.querySelector('.services-selected-count');
    if (existingCounter) {
        existingCounter.remove();
    }
    
    if (count > 0) {
        const servicesHeader = document.querySelector('.booking-section h5 i.fa-concierge-bell').parentElement;
        const counter = document.createElement('span');
        counter.className = 'services-selected-count';
        counter.textContent = count + ' selected';
        servicesHeader.appendChild(counter);
    }
}
// Populate room options for each service based on selected rooms
function updateServiceRoomOptions() {
    var selectedRooms = [];
    $('input[name="roomIds"]:checked').each(function(){
        selectedRooms.push({id: this.value, number: $(this).data('number')});
    });

    document.querySelectorAll('.service-room-options').forEach(function(container){
        var serviceId = container.getAttribute('data-service-id');
        var existing = Array.from(container.querySelectorAll('input.service-room-checkbox:checked')).map(c => c.value);
        container.innerHTML = '';

        if (selectedRooms.length > 1) {
            var labelAll = document.createElement('label');
            labelAll.className = 'mr-2';
            var cbAll = document.createElement('input');
            cbAll.type = 'checkbox';
            cbAll.className = 'service-room-checkbox';
            cbAll.name = 'serviceRooms_' + serviceId;
            cbAll.value = 'ALL';
            if (existing.includes('ALL')) cbAll.checked = true;
            labelAll.appendChild(cbAll);
            labelAll.appendChild(document.createTextNode('All Rooms'));
            container.appendChild(labelAll);
        }

        selectedRooms.forEach(function(room){
            var label = document.createElement('label');
            label.className = 'mr-2';
            var cb = document.createElement('input');
            cb.type = 'checkbox';
            cb.className = 'service-room-checkbox';
            cb.name = 'serviceRooms_' + serviceId;
            cb.value = room.id;
            if (existing.includes(String(room.id))) cb.checked = true;
            label.appendChild(cb);
            label.appendChild(document.createTextNode('Room ' + room.number));
            container.appendChild(label);
        });

        if (selectedRooms.length === 1 && existing.length === 0) {
            var single = container.querySelector('input[value="' + selectedRooms[0].id + '"]');
                 if (single) single.checked = true;
        }

        var allCb = container.querySelector('input[value="ALL"]');
        var roomCbs = container.querySelectorAll('input:not([value="ALL"])');
        if (allCb && Array.from(roomCbs).every(cb => cb.checked)) {
            allCb.checked = true;
        }
    });

    updateServicesSummary();
}

$(document).on('change', '.service-room-checkbox', function(){
    var container = $(this).closest('.service-room-options');
    if (this.value === 'ALL') {
        container.find('input.service-room-checkbox').prop('checked', this.checked);
    } else {
        var allCb = container.find('input.service-room-checkbox[value="ALL"]');
        if (!this.checked) {
            allCb.prop('checked', false);
        } else if (container.find('input.service-room-checkbox:not([value="ALL"])').length ===
                   container.find('input.service-room-checkbox:not([value="ALL"]):checked').length) {
            allCb.prop('checked', true);
        }
    }
    updateServicesSummary();
});
function clearRoomSelection() {
    $('input[name="roomIds"]').prop('checked', false);
    $('#submitBtn').prop('disabled', true);
    $('#availableRooms').html('<div class="text-center py-4"><i class="fas fa-calendar-day fa-3x text-muted mb-3"></i><p class="text-muted">Please check availability to see available rooms</p></div>');
    $('#bookingSummary').html('<div class="text-center py-4"><i class="fas fa-hand-point-left fa-2x text-muted mb-3"></i><p class="text-muted">Select a room to see booking summary</p></div>');
    updateServiceRoomOptions();
}

function validateForm() {
    var guestType = $('#guestType').val();
    
    // Validate customer information
    if (guestType === 'existing') {
        if (!$('#customerSelect').val()) {
            alert('Please select a customer');
            $('#customerSelect').focus();
            return false;
        }
    } else {
        if (!$('#newCustomerName').val().trim()) {
            alert('Please enter customer name');
            $('#newCustomerName').focus();
            return false;
        }
        if (!$('#newCustomerEmail').val().trim()) {
            alert('Please enter customer email');
            $('#newCustomerEmail').focus();
            return false;
        }
        if (!$('#newCustomerPhone').val().trim()) {
            alert('Please enter customer phone');
            $('#newCustomerPhone').focus();
            return false;
        }
        
        // Validate email format
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test($('#newCustomerEmail').val().trim())) {
            alert('Please enter a valid email address');
            $('#newCustomerEmail').focus();
            return false;
        }
        
        // Validate phone format (Vietnamese phone)
        var phoneRegex = /^0[0-9]{9}$/;
        if (!phoneRegex.test($('#newCustomerPhone').val().trim())) {
            alert('Please enter a valid Vietnamese phone number (10 digits starting with 0)');
            $('#newCustomerPhone').focus();
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
 if ($('input[name="roomIds"]:checked').length === 0) {
        alert('Please select at least one room');
        return false;
    }
    
    // Optional: Validate at least one service selected
    // Uncomment if services are required
    /*
    if ($('input[name="services"]:checked').length === 0) {
        alert('Please select at least one service');
        return false;
    }
    */
    
    return true;
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount);
}

// Search/Filter services by name (optional feature)
function searchServices() {
    const searchTerm = document.getElementById('serviceSearch').value.toLowerCase();
    const serviceItems = document.querySelectorAll('.service-item');
    
    serviceItems.forEach(item => {
        const serviceName = item.querySelector('strong').textContent.toLowerCase();
        const serviceDesc = item.querySelector('.text-muted').textContent.toLowerCase();
        
        if (serviceName.includes(searchTerm) || serviceDesc.includes(searchTerm)) {
            item.style.display = 'block';
        } else {
            item.style.display = 'none';
        }
    });
}
// Filter services by category
function filterServices(category) {
    // Update active button
    document.querySelectorAll('.btn-service-filter').forEach(btn => {
        btn.classList.remove('active');
    });
    event.currentTarget.classList.add('active');
    
    // Filter service items
    const serviceItems = document.querySelectorAll('.service-item');
    serviceItems.forEach(item => {
        if (category === 'all' || item.getAttribute('data-category') === category) {
            item.classList.remove('hidden');
            item.style.display = 'block';
        } else {
            item.classList.add('hidden');
            item.style.display = 'none';
        }
    });
    
    // Update scroll height if needed
    updateServicesContainerHeight();
}

// Update services container height based on visible items
function updateServicesContainerHeight() {
    const container = document.getElementById('servicesContainer');
    const visibleItems = container.querySelectorAll('.service-item:not(.hidden)');
    
    if (visibleItems.length === 0) {
        container.innerHTML = '<div class="text-center py-3 text-muted">No services available in this category</div>';
    }
}



// Initialize on page load
$(document).ready(function() {
    // ... existing code ...
    
    // Initialize service counts
    updateServicesSummary();
     updateServiceRoomOptions();
    // Add search functionality for services
    $('#serviceSearch').on('input', function() {
        const searchTerm = this.value.toLowerCase();
        const currentCategory = document.querySelector('.btn-service-filter.active').getAttribute('data-category');
        
        document.querySelectorAll('.service-item').forEach(item => {
            const serviceName = item.querySelector('strong').textContent.toLowerCase();
            const serviceDesc = item.querySelector('.service-description').textContent.toLowerCase();
            const itemCategory = item.getAttribute('data-category');
            
            const matchesSearch = serviceName.includes(searchTerm) || serviceDesc.includes(searchTerm);
            const matchesCategory = currentCategory === 'all' || itemCategory === currentCategory;
            
            if (matchesSearch && matchesCategory) {
                item.style.display = 'block';
                item.classList.remove('hidden');
            } else {
                item.style.display = 'none';
                item.classList.add('hidden');
            }
        });
        
        updateServicesContainerHeight();
    });
});
</script>