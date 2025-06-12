<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h2>Reservations Management</h2>
            <p class="text-muted">Manage all hotel reservations</p>
        </div>
        <div class="col-md-6 text-right">
            <button class="btn btn-primary" data-toggle="modal" data-target="#newReservationModal">
                <i class="fas fa-plus-circle"></i> New Reservation
            </button>
            <button class="btn btn-success" onclick="exportReservations()">
                <i class="fas fa-file-excel"></i> Export
            </button>
            <button class="btn btn-info" onclick="refreshReservations()">
                <i class="fas fa-sync"></i> Refresh
            </button>
        </div>
    </div>
    
    <!-- Filter Section -->
    <div class="table-container mb-4">
        <h5 class="mb-3">Filter Reservations</h5>
        <form id="filterForm" class="row">
            <div class="col-md-2">
                <div class="form-group">
                    <label>Status</label>
                    <select class="form-control" name="status" id="statusFilter">
                        <option value="">All Status</option>
                        <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="CONFIRMED" ${param.status == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                        <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                        <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                    </select>
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>Check-in Date</label>
                    <input type="date" class="form-control" name="checkInDate" id="checkInDate" 
                           value="${param.checkInDate}">
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>Check-out Date</label>
                    <input type="date" class="form-control" name="checkOutDate" id="checkOutDate" 
                           value="${param.checkOutDate}">
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label>Search</label>
                    <input type="text" class="form-control" name="search" id="searchInput" 
                           placeholder="Guest name, room, booking ID..." value="${param.search}">
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label>&nbsp;</label>
                    <div>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-filter"></i> Apply Filter
                        </button>
                        <button type="button" class="btn btn-secondary" onclick="clearFilters()">
                            <i class="fas fa-times"></i> Clear
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
    
    <!-- Quick Stats -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-calendar-plus stat-icon text-info"></i>
                <div class="stat-number">${totalReservations}</div>
                <div class="stat-label">Total Reservations</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-clock stat-icon text-warning"></i>
                <div class="stat-number">${pendingReservations}</div>
                <div class="stat-label">Pending</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-check-circle stat-icon text-success"></i>
                <div class="stat-number">${confirmedReservations}</div>
                <div class="stat-label">Confirmed</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-sign-in-alt stat-icon text-primary"></i>
                <div class="stat-number">${todayCheckIns}</div>
                <div class="stat-label">Today's Check-ins</div>
            </div>
        </div>
    </div>
    
    <!-- Reservations Table -->
    <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5>Reservation List</h5>
            <small class="text-muted">
                Showing ${not empty reservations ? reservations.size() : 0} reservations
            </small>
        </div>
        
        <div class="table-responsive">
            <table class="table table-hover" id="reservationsTable">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Guest Name</th>
                        <th>Room</th>
                        <th>Check-in</th>
                        <th>Check-out</th>
                        <th>Nights</th>
                        <th>Status</th>
                        <th>Total Amount</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty reservations}">
                            <c:forEach var="reservation" items="${reservations}">
                                <tr>
                                    <td>
                                        <strong>#${reservation.id}</strong>
                                        <br><small class="text-muted">
                                            <fmt:formatDate value="${reservation.createdAt}" pattern="dd/MM/yyyy"/>
                                        </small>
                                    </td>
                                    <td>
                                        <strong>${reservation.customerName}</strong>
                                        <br><small class="text-muted">${reservation.customerPhone}</small>
                                    </td>
                                    <td>
                                        <span class="badge badge-info">Room ${reservation.roomNumber}</span>
                                        <br><small class="text-muted">${reservation.roomTypeName}</small>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${reservation.checkIn}" pattern="dd/MM/yyyy"/>
                                        <br><small class="text-muted">
                                            <fmt:formatDate value="${reservation.checkIn}" pattern="EEE"/>
                                        </small>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${reservation.checkOut}" pattern="dd/MM/yyyy"/>
                                        <br><small class="text-muted">
                                            <fmt:formatDate value="${reservation.checkOut}" pattern="EEE"/>
                                        </small>
                                    </td>
                                    <td>
                                        <c:set var="checkInTime" value="${reservation.checkIn.time}" />
                                        <c:set var="checkOutTime" value="${reservation.checkOut.time}" />
                                        <c:set var="nights" value="${(checkOutTime - checkInTime) / (1000 * 60 * 60 * 24)}" />
                                        <span class="badge badge-secondary">${nights} nights</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${reservation.status eq 'PENDING'}">
                                                <span class="badge badge-warning">Pending</span>
                                            </c:when>
                                            <c:when test="${reservation.status eq 'CONFIRMED'}">
                                                <span class="badge badge-success">Confirmed</span>
                                            </c:when>
                                            <c:when test="${reservation.status eq 'CANCELLED'}">
                                                <span class="badge badge-danger">Cancelled</span>
                                            </c:when>
                                            <c:when test="${reservation.status eq 'COMPLETED'}">
                                                <span class="badge badge-info">Completed</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-secondary">${reservation.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <strong class="text-primary">
                                            <fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0"/>₫
                                        </strong>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <button class="btn btn-sm btn-info" onclick="viewDetails(${reservation.id})" 
                                                    title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <c:if test="${reservation.status eq 'PENDING'}">
                                                <button class="btn btn-sm btn-success" onclick="confirmReservation(${reservation.id})"
                                                        title="Confirm">
                                                    <i class="fas fa-check"></i>
                                                </button>
                                                <button class="btn btn-sm btn-danger" onclick="cancelReservation(${reservation.id})"
                                                        title="Cancel">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </c:if>
                                            <c:if test="${reservation.status eq 'CONFIRMED'}">
                                                <button class="btn btn-sm btn-warning" onclick="editReservation(${reservation.id})"
                                                        title="Edit">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                            </c:if>
                                            <button class="btn btn-sm btn-secondary dropdown-toggle" data-toggle="dropdown"
                                                    title="More Actions">
                                                <i class="fas fa-ellipsis-v"></i>
                                            </button>
                                            <div class="dropdown-menu">
                                                <a class="dropdown-item" href="#" onclick="printReservation(${reservation.id})">
                                                    <i class="fas fa-print"></i> Print
                                                </a>
                                                <a class="dropdown-item" href="#" onclick="sendConfirmation(${reservation.id})">
                                                    <i class="fas fa-envelope"></i> Send Email
                                                </a>
                                                <c:if test="${reservation.status eq 'CONFIRMED'}">
                                                    <div class="dropdown-divider"></div>
                                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/receptionist/check-in?id=${reservation.id}">
                                                        <i class="fas fa-sign-in-alt"></i> Check-in
                                                    </a>
                                                </c:if>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9" class="text-center text-muted py-4">
                                    <i class="fas fa-calendar-times fa-3x mb-3"></i>
                                    <br>No reservations found
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- New Reservation Modal -->
<div class="modal fade" id="newReservationModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">New Reservation</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="newReservationForm">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Guest <span class="text-danger">*</span></label>
                                <select class="form-control" id="guestSelect" required>
                                    <option value="">Select existing guest or add new</option>
                                    <option value="new">+ Add New Guest</option>
                                    <c:forEach var="guest" items="${guests}">
                                        <option value="${guest.id}">${guest.fullName} - ${guest.phone}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <!-- New Guest Fields (hidden by default) -->
                            <div id="newGuestFields" style="display: none;">
                                <div class="form-group">
                                    <label>Full Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="guestName" 
                                           placeholder="Enter guest name">
                                </div>
                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="email" class="form-control" id="guestEmail" 
                                           placeholder="Enter email address">
                                </div>
                                <div class="form-group">
                                    <label>Phone <span class="text-danger">*</span></label>
                                    <input type="tel" class="form-control" id="guestPhone" 
                                           placeholder="Enter phone number">
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Check-in Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="newCheckIn" required>
                            </div>
                            <div class="form-group">
                                <label>Check-out Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="newCheckOut" required>
                            </div>
                            <div class="form-group">
                                <label>Room Type <span class="text-danger">*</span></label>
                                <select class="form-control" id="roomTypeSelect" required>
                                    <option value="">Select room type</option>
                                    <c:forEach var="roomType" items="${roomTypes}">
                                        <option value="${roomType.id}" data-price="${roomType.basePrice}">
                                            ${roomType.name} - <fmt:formatNumber value="${roomType.basePrice}" pattern="#,##0"/>₫/night
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Available Rooms</label>
                                <select class="form-control" id="roomSelect" required disabled>
                                    <option value="">Select room type first</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Number of Guests</label>
                                <input type="number" class="form-control" id="numberOfGuests" 
                                       value="1" min="1" max="10">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Special Requests</label>
                                <textarea class="form-control" id="specialRequests" rows="2" 
                                          placeholder="Any special requests..."></textarea>
                            </div>
                        </div>
                    </div>
                    
                    <div class="alert alert-info">
                        <div class="row">
                            <div class="col-md-6">
                                <strong>Nights:</strong> <span id="nightsDisplay">0</span>
                            </div>
                            <div class="col-md-6">
                                <strong>Total Amount:</strong> <span id="totalAmountDisplay">0₫</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create Reservation</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- View Details Modal -->
<div class="modal fade" id="viewDetailsModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Reservation Details</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" id="reservationDetails">
                <!-- Details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="printReservationDetails()">
                    <i class="fas fa-print"></i> Print
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Edit Reservation Modal -->
<div class="modal fade" id="editReservationModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Edit Reservation</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="editReservationForm">
                <div class="modal-body">
                    <input type="hidden" id="editReservationId">
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Guest Name</label>
                                <input type="text" class="form-control" id="editGuestName" readonly>
                            </div>
                            <div class="form-group">
                                <label>Room</label>
                                <input type="text" class="form-control" id="editRoomInfo" readonly>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Check-in Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="editCheckIn" required>
                            </div>
                            <div class="form-group">
                                <label>Check-out Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="editCheckOut" required>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Number of Guests</label>
                                <input type="number" class="form-control" id="editNumberOfGuests" 
                                       min="1" max="10">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Status</label>
                                <select class="form-control" id="editStatus">
                                    <option value="PENDING">Pending</option>
                                    <option value="CONFIRMED">Confirmed</option>
                                    <option value="CANCELLED">Cancelled</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Special Requests</label>
                        <textarea class="form-control" id="editSpecialRequests" rows="3"></textarea>
                    </div>
                    
                    <div class="alert alert-info">
                        <div class="row">
                            <div class="col-md-6">
                                <strong>Nights:</strong> <span id="editNightsDisplay">0</span>
                            </div>
                            <div class="col-md-6">
                                <strong>Total Amount:</strong> <span id="editTotalAmountDisplay">0₫</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Reservation</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Guest select change
    $('#guestSelect').change(function() {
        if ($(this).val() === 'new') {
            $('#newGuestFields').show();
            $('#guestName, #guestPhone').attr('required', true);
        } else {
            $('#newGuestFields').hide();
            $('#guestName, #guestPhone').attr('required', false);
        }
    });
    
    // Room type change - load available rooms
    $('#roomTypeSelect').change(function() {
        const roomTypeId = $(this).val();
        if (roomTypeId) {
            loadAvailableRooms(roomTypeId);
            calculateTotal();
        }
    });
    
    // Date change - recalculate total
    $('#newCheckIn, #newCheckOut, #editCheckIn, #editCheckOut').change(function() {
        calculateTotal();
    });
    
    // Form submissions
    $('#newReservationForm').submit(function(e) {
        e.preventDefault();
        createReservation();
    });
    
    $('#editReservationForm').submit(function(e) {
        e.preventDefault();
        updateReservation();
    });
    
    $('#filterForm').submit(function(e) {
        e.preventDefault();
        filterReservations();
    });
    
    // Set minimum date to today
    const today = new Date().toISOString().split('T')[0];
    $('#newCheckIn, #editCheckIn').attr('min', today);
});

function loadAvailableRooms(roomTypeId) {
    const checkIn = $('#newCheckIn').val();
    const checkOut = $('#newCheckOut').val();
    
    if (!checkIn || !checkOut) {
        $('#roomSelect').prop('disabled', true).html('<option value="">Select dates first</option>');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/reservations',
        type: 'POST',
        data: {
            action: 'getAvailableRooms',
            roomTypeId: roomTypeId,
            checkIn: checkIn,
            checkOut: checkOut
        },
        success: function(rooms) {
            $('#roomSelect').prop('disabled', false).empty();
            $('#roomSelect').append('<option value="">Select a room</option>');
            rooms.forEach(room => {
                $('#roomSelect').append(`<option value="${room.id}">Room ${room.roomNumber}</option>`);
            });
        },
        error: function() {
            alert('Error loading available rooms');
        }
    });
}

function calculateTotal() {
    // For new reservation
    const checkIn = new Date($('#newCheckIn').val());
    const checkOut = new Date($('#newCheckOut').val());
    const roomType = $('#roomTypeSelect option:selected');
    
    if (checkIn && checkOut && roomType.val() && checkOut > checkIn) {
        const nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
        const pricePerNight = parseFloat(roomType.data('price')) || 0;
        const total = nights * pricePerNight;
        
        $('#nightsDisplay').text(nights);
        $('#totalAmountDisplay').text(formatCurrency(total));
    } else {
        $('#nightsDisplay').text('0');
        $('#totalAmountDisplay').text('0₫');
    }
    
    // For edit reservation
    const editCheckIn = new Date($('#editCheckIn').val());
    const editCheckOut = new Date($('#editCheckOut').val());
    
    if (editCheckIn && editCheckOut && editCheckOut > editCheckIn) {
        const editNights = Math.ceil((editCheckOut - editCheckIn) / (1000 * 60 * 60 * 24));
        $('#editNightsDisplay').text(editNights);
        // You can add price calculation for edit modal if needed
    }
}

function createReservation() {
    const formData = {
        guestId: $('#guestSelect').val() !== 'new' ? $('#guestSelect').val() : null,
        newGuest: $('#guestSelect').val() === 'new' ? {
            fullName: $('#guestName').val(),
            email: $('#guestEmail').val(),
            phone: $('#guestPhone').val()
        } : null,
        roomId: $('#roomSelect').val(),
        checkIn: $('#newCheckIn').val(),
        checkOut: $('#newCheckOut').val(),
        numberOfGuests: $('#numberOfGuests').val(),
        specialRequests: $('#specialRequests').val()
    };
    
    if (!formData.roomId) {
        alert('Please select a room');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/reservations',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            action: 'createReservation',
            ...formData
        }),
        success: function(response) {
            if (response.success) {
                alert('Reservation created successfully!');
                $('#newReservationModal').modal('hide');
                location.reload();
            } else {
                alert('Error creating reservation: ' + (response.message || 'Unknown error'));
            }
        },
        error: function() {
            alert('Error creating reservation. Please try again.');
        }
    });
}

function confirmReservation(id) {
    if (confirm('Are you sure you want to confirm this reservation?')) {
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/reservations',
            type: 'POST',
            data: {
                action: 'confirmReservation',
                reservationId: id
            },
            success: function(response) {
                if (response.success) {
                    alert('Reservation confirmed successfully!');
                    location.reload();
                } else {
                    alert('Error confirming reservation');
                }
            },
            error: function() {
                alert('Error confirming reservation. Please try again.');
            }
        });
    }
}

function cancelReservation(id) {
    if (confirm('Are you sure you want to cancel this reservation?')) {
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/reservations',
            type: 'POST',
            data: {
                action: 'cancelReservation',
                reservationId: id
            },
            success: function(response) {
                if (response.success) {
                    alert('Reservation cancelled successfully!');
                    location.reload();
                } else {
                    alert('Error cancelling reservation');
                }
            },
            error: function() {
                alert('Error cancelling reservation. Please try again.');
            }
        });
    }
}

function viewDetails(id) {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/reservations',
        type: 'POST',
        data: {
            action: 'getReservationDetails',
            id: id
        },
        success: function(data) {
            let html = `
                <div class="row">
                    <div class="col-md-6">
                        <h6>Guest Information</h6>
                        <table class="table table-sm">
                            <tr><th>Name:</th><td>${data.customerName}</td></tr>
                            <tr><th>Phone:</th><td>${data.customerPhone}</td></tr>
                            <tr><th>Email:</th><td>${data.customerEmail}</td></tr>
                        </table>
                        
                        <h6>Booking Information</h6>
                        <table class="table table-sm">
                            <tr><th>Booking ID:</th><td>#${data.id}</td></tr>
                            <tr><th>Status:</th><td><span class="badge badge-success">${data.status}</span></td></tr>
                            <tr><th>Created:</th><td>${formatDate(data.createdAt)}</td></tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h6>Room Information</h6>
                        <table class="table table-sm">
                            <tr><th>Room:</th><td>${data.roomNumber}</td></tr>
                            <tr><th>Type:</th><td>${data.roomTypeName}</td></tr>
                            <tr><th>Check-in:</th><td>${formatDate(data.checkIn)}</td></tr>
                            <tr><th>Check-out:</th><td>${formatDate(data.checkOut)}</td></tr>
                            <tr><th>Nights:</th><td>${data.nights}</td></tr>
                        </table>
                        
                        <h6>Payment Information</h6>
                        <table class="table table-sm">
                            <tr><th>Total:</th><td><strong>${formatCurrency(data.totalAmount)}</strong></td></tr>
                            <tr><th>Payment Status:</th><td><span class="badge badge-warning">Pending</span></td></tr>
                        </table>
                    </div>
                </div>
            `;
            
            if (data.specialRequests) {
                html += `
                    <div class="mt-3">
                        <h6>Special Requests</h6>
                        <div class="alert alert-info">${data.specialRequests}</div>
                    </div>
                `;
            }
            
            $('#reservationDetails').html(html);
            $('#viewDetailsModal').modal('show');
        },
        error: function() {
            alert('Error loading reservation details');
        }
    });
}

function editReservation(id) {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/reservations',
        type: 'POST',
        data: {
            action: 'getReservationDetails',
            id: id
        },
        success: function(data) {
            $('#editReservationId').val(data.id);
            $('#editGuestName').val(data.customerName);
            $('#editRoomInfo').val(`Room ${data.roomNumber} (${data.roomTypeName})`);
            $('#editCheckIn').val(data.checkIn);
            $('#editCheckOut').val(data.checkOut);
            $('#editNumberOfGuests').val(data.numberOfGuests || 1);
            $('#editStatus').val(data.status);
            $('#editSpecialRequests').val(data.specialRequests || '');
            
            calculateTotal();
            $('#editReservationModal').modal('show');
        },
        error: function() {
            alert('Error loading reservation details');
        }
    });
}

function updateReservation() {
    const formData = {
        id: $('#editReservationId').val(),
        checkIn: $('#editCheckIn').val(),
        checkOut: $('#editCheckOut').val(),
        numberOfGuests: $('#editNumberOfGuests').val(),
        status: $('#editStatus').val(),
        specialRequests: $('#editSpecialRequests').val()
    };
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/reservations',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            action: 'updateReservation',
            ...formData
        }),
        success: function(response) {
            if (response.success) {
                alert('Reservation updated successfully!');
                $('#editReservationModal').modal('hide');
                location.reload();
            } else {
                alert('Error updating reservation: ' + (response.message || 'Unknown error'));
            }
        },
        error: function() {
            alert('Error updating reservation. Please try again.');
        }
    });
}

function filterReservations() {
    const params = new URLSearchParams();
    
    const status = $('#statusFilter').val();
    const checkInDate = $('#checkInDate').val();
    const checkOutDate = $('#checkOutDate').val();
    const search = $('#searchInput').val();
    
    if (status) params.append('status', status);
    if (checkInDate) params.append('checkInDate', checkInDate);
    if (checkOutDate) params.append('checkOutDate', checkOutDate);
    if (search) params.append('search', search);
    
    const url = '${pageContext.request.contextPath}/receptionist/reservations' + 
                (params.toString() ? '?' + params.toString() : '');
    window.location.href = url;
}

function clearFilters() {
    window.location.href = '${pageContext.request.contextPath}/receptionist/reservations';
}

function printReservation(id) {
    window.open(`${pageContext.request.contextPath}/receptionist/reservations?action=print&id=${id}`, '_blank');
}

function printReservationDetails() {
    window.print();
}

function sendConfirmation(id) {
    if (confirm('Send confirmation email to guest?')) {
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/reservations',
            type: 'POST',
            data: {
                action: 'sendConfirmation',
                id: id
            },
            success: function(response) {
                if (response.success) {
                    alert('Confirmation email sent successfully!');
                } else {
                    alert('Error sending email');
                }
            },
            error: function() {
                alert('Error sending confirmation email');
            }
        });
    }
}

function exportReservations() {
    const params = new URLSearchParams(window.location.search);
    params.append('action', 'export');
    window.location.href = '${pageContext.request.contextPath}/receptionist/reservations?' + params.toString();
}

function refreshReservations() {
    location.reload();
}

function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
}

function formatCurrency(amount) {
    if (amount === null || amount === undefined) return '0₫';
    return new Intl.NumberFormat('vi-VN').format(amount) + '₫';
}
</script>