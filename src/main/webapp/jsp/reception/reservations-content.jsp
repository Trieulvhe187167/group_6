<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!-- Bootstrap CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
<!-- Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

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
                        <option value="PENDING" ${filterStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="CONFIRMED" ${filterStatus == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                        <option value="CANCELLED" ${filterStatus == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                        <option value="COMPLETED" ${filterStatus == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                    </select>
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>Check-in Date</label>
                    <input type="date" class="form-control" name="checkInDate" id="checkInDate"
                           value="${filterCheckInDate != null ? filterCheckInDate : ''}" />
                </div>
            </div>
            <div class="col-md-2">
                <div class="form-group">
                    <label>Check-out Date</label>
                    <input type="date" class="form-control" name="checkOutDate" id="checkOutDate"
                           value="${filterCheckOutDate != null ? filterCheckOutDate : ''}" />
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label>Search</label>
                    <input type="text" class="form-control" name="search" id="searchInput" 
                           placeholder="Customer name, room, booking ID..." value="${filterSearch != null ? filterSearch : ''}">
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
                <div class="stat-number">${totalReservations != null ? totalReservations : 0}</div>
                <div class="stat-label">Total Reservations</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-clock stat-icon text-warning"></i>
                <div class="stat-number">${pendingReservations != null ? pendingReservations : 0}</div>
                <div class="stat-label">Pending</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-check-circle stat-icon text-success"></i>
                <div class="stat-number">${confirmedReservations != null ? confirmedReservations : 0}</div>
                <div class="stat-label">Confirmed</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-sign-in-alt stat-icon text-primary"></i>
                <div class="stat-number">${todayCheckIns != null ? todayCheckIns : 0}</div>
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
                        <th>Customer Name</th>
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
                                        <fmt:parseNumber var="nights" value="${(reservation.checkOut.time - reservation.checkIn.time) / (1000 * 60 * 60 * 24)}" integerOnly="true"/>
                                        <span class="badge badge-secondary">${nights} nights</span>
                                    </td>
                                   <td>
    <c:choose>
        <c:when test="${reservation.status == 'CONFIRMED'}">
            <span class="badge bg-success">Confirmed</span>
        </c:when>
        <c:when test="${reservation.status == 'PENDING'}">
            <span class="badge bg-warning text-dark">Pending</span>
        </c:when>
        <c:when test="${reservation.status == 'CANCELLED'}">
            <span class="badge bg-danger">Cancelled</span>
        </c:when>
        <c:when test="${reservation.status == 'COMPLETED'}">
            <span class="badge bg-primary">Completed</span>
        </c:when>
        <c:otherwise>
            <span class="badge bg-secondary">${reservation.status}</span>
        </c:otherwise>
    </c:choose>
<!--</td>-->
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
                                           <c:if test="${reservation.status eq 'PENDING' || reservation.status eq 'CONFIRMED'}">
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
                                <label>Customer <span class="text-danger">*</span></label>
                                <select class="form-control" id="customerSelect" required>
                                    <option value="">Select existing customer or add new</option>
                                    <option value="new">+ Add New Customer</option>
                                    <c:forEach var="customer" items="${customers}">
                                        <option value="${customer.id}">${customer.fullName} - ${customer.phone}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- New Customer Fields (hidden by default) -->
                            <div id="newCustomerFields" style="display: none;">
                                <div class="form-group">
                                    <label>Full Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="customerName" 
                                           placeholder="Enter customer name">
                                </div>
                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="email" class="form-control" id="customerEmail" 
                                           placeholder="Enter email address">
                                </div>
                                <div class="form-group">
                                    <label>Phone <span class="text-danger">*</span></label>
                                    <input type="tel" class="form-control" id="customerPhone" 
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
                                <label>Number of Customers</label>
                                <input type="number" class="form-control" id="numberOfCustomers" 
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
        <div class="col-md-12">
            <strong>Nights:</strong> <span id="nightsDisplay">0</span>
        </div>
        <div class="col-md-12">
            <strong>Total Amount:</strong> <span id="totalAmountDisplay">0₫</span>
        </div>
        <div class="col-md-12">
            <strong>Deposit (10%):</strong> <span id="depositAmountDisplay">0₫</span>
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
            </div>
            <div class="modal-body" id="reservationDetails">
                <!-- Details will be loaded here -->
            </div>
            <div class="modal-footer">
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
            </div>
            <form id="editReservationForm">
                <div class="modal-body" style="max-height: 70vh; overflow-y: auto;">
                    <input type="hidden" id="editReservationId">

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Customer Name</label>
                                <input type="text" class="form-control" id="editCustomerName" readonly>
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

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Room</label>
                                <input type="text" class="form-control" id="editRoomInfo" readonly>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Number of Customers</label>
                                <input type="number" class="form-control" id="editNumberOfCustomers" readonly
                                       min="1" max="10">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Check-in Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="editCheckIn" required>

                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Check-out Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="editCheckOut" required>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Special Requests</label>
                        <textarea class="form-control" id="editSpecialRequests" rows="2"></textarea>
                    </div>

                    <div class="alert alert-info mt-3">
                        <div class="row text-center">
                            <div class="col-md-4">
                                <strong>Nights:</strong> <span id="editNightsDisplay">0</span>
                            </div>
                            <div class="col-md-4">
                                <strong>Total Amount:</strong> <span id="editTotalAmountDisplay">0₫</span>
                            </div>
                            <div class="col-md-4">
                                <strong>Deposit (10%):</strong> <span id="editDepositAmountDisplay">0₫</span>
                            </div>
                        </div>
                    </div>

                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Update Reservation</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
    // SỬA: Thêm event listener riêng cho edit modal
    $('#editCheckIn, #editCheckOut').change(function () {
    updateEditTotalAmountDisplay();


        
        // Validate ngày
        const checkIn = new Date($('#editCheckIn').val());
        const checkOut = new Date($('#editCheckOut').val());
        
        if (checkIn && checkOut && checkOut <= checkIn) {
            alert('Check-out date must be after check-in date');
            $(this).focus();
        }
        });

        // Room type change - load available rooms
        $('#roomTypeSelect').change(function () {
            const roomTypeId = $(this).val();
            if (roomTypeId) {
                loadAvailableRooms(roomTypeId);
                calculateTotal();
            }
        });

        // Date change - recalculate total
        $('#newCheckIn, #newCheckOut, #editCheckIn, #editCheckOut').change(function () {
            calculateTotal();
        });

        // Form submissions
        $('#newReservationForm').submit(function (e) {
            e.preventDefault();
            createReservation();
        });

        $('#editReservationForm').submit(function (e) {
            e.preventDefault();
            updateReservation();
        });

        $('#filterForm').submit(function (e) {
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
            success: function (rooms) {
                $('#roomSelect').prop('disabled', false).empty();
                $('#roomSelect').append('<option value="">Select a room</option>');
                rooms.forEach(room => {
                    $('#roomSelect').append(`<option value="\${room.id}">Room \${room.roomNumber}</option>`);
                });
            },
            error: function () {
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

    // ✅ SỬA: Tính cho edit reservation
    const editCheckIn = new Date($('#editCheckIn').val());
    const editCheckOut = new Date($('#editCheckOut').val());
    const editPrice = parseFloat($('#editReservationModal').data('price')) || 0;

    if (editCheckIn && editCheckOut && editCheckOut > editCheckIn) {
        const editNights = Math.ceil((editCheckOut - editCheckIn) / (1000 * 60 * 60 * 24));
        const editTotal = editNights * editPrice;
        const editDeposit = editTotal * 0.1;

        $('#editNightsDisplay').text(editNights);
        $('#editTotalAmountDisplay').text(formatCurrency(editTotal));
        $('#editDepositAmountDisplay').text(formatCurrency(editDeposit));
    } else {
        $('#editNightsDisplay').text('0');
        $('#editTotalAmountDisplay').text('0₫');
        $('#editDepositAmountDisplay').text('0₫');
    }
}


    function createReservation() {
        const formData = {
            customerId: $('#customerSelect').val() !== 'new' ? $('#customerSelect').val() : null,
            newCustomer: $('#customerSelect').val() === 'new' ? {
                fullName: $('#customerName').val(),
                email: $('#customerEmail').val(),
                phone: $('#customerPhone').val()
            } : null,
            roomId: $('#roomSelect').val(),
            checkIn: $('#newCheckIn').val(),
            checkOut: $('#newCheckOut').val(),
            numberOfCustomers: $('#numberOfCustomers').val(),
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
            success: function (response) {
                if (response.success) {
                    alert('Reservation created successfully!');
                    $('#newReservationModal').modal('hide');
                    location.reload();
                } else {
                    alert('Error creating reservation: ' + (response.message || 'Unknown error'));
                }
            },
            error: function () {
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
                success: function (response) {
                    if (response.success) {
                        alert('Reservation confirmed successfully!');
                        location.reload();
                    } else {
                        alert('Error confirming reservation');
                    }
                },
                error: function () {
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
                success: function (response) {
                    if (response.success) {
                        alert('Reservation cancelled successfully!');
                        location.reload();
                    } else {
                        alert('Error cancelling reservation');
                    }
                },
                error: function () {
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
            success: function (data) {
                // Function to get badge class based on status
                function getStatusBadgeClass(status) {
                    switch(status) {
                        case 'CONFIRMED': return 'success';
                        case 'PENDING': return 'warning';
                        case 'CANCELLED': return 'danger';
                        case 'COMPLETED': return 'info';
                        default: return 'secondary';
                    }
                }
                
                let html = `
                <div class="row">
                    <div class="col-md-6">
                        <h6>Customer Information</h6>
                        <table class="table table-sm">
                            <tr><th>Name:</th><td>\${data.customerName || '-'}</td></tr>
                            <tr><th>Phone:</th><td>\${data.customerPhone || '-'}</td></tr>
                            <tr><th>Email:</th><td>\${data.customerEmail || '-'}</td></tr>
                        </table>
                        
                        <h6>Booking Information</h6>
                        <table class="table table-sm">
                            <tr><th>Booking ID:</th><td>#\${data.id}</td></tr>
                            <tr><th>Status:</th><td><span class="badge badge-\${getStatusBadgeClass(data.status)}">\${data.status}</span></td></tr>
                            <tr><th>Created:</th><td>\${formatDate(data.createdAt)}</td></tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h6>Room Information</h6>
                        <table class="table table-sm">
                            <tr><th>Room:</th><td>\${data.roomNumber || '-'}</td></tr>
                            <tr><th>Type:</th><td>\${data.roomTypeName || '-'}</td></tr>
                            <tr><th>Check-in:</th><td>\${formatDate(data.checkIn)}</td></tr>
                            <tr><th>Check-out:</th><td>\${formatDate(data.checkOut)}</td></tr>
                            <tr><th>Nights:</th><td>\${data.nights || '-'}</td></tr>
                        </table>
                        
                        <h6>Payment Information</h6>
                        <table class="table table-sm">
                            <tr><th>Total:</th><td><strong>\${formatCurrency(data.totalAmount)}</strong></td></tr>
                            <tr><th>Payment Status:</th><td><span class="badge badge-\${data.paymentStatus === 'PAID' ? 'success' : 'warning'}">\${data.paymentStatus || 'Pending'}</span></td></tr>
                        </table>
                    </div>
                </div>
                `;

                if (data.specialRequests) {
                    html += `
                    <div class="mt-3">
                        <h6>Special Requests</h6>
                        <div class="alert alert-info">\${data.specialRequests}</div>
                    </div>
                    `;
                }

                $('#reservationDetails').html(html);
                $('#reservationDetails').html(html).css('color', '#000'); // Màu đen
                $('#editReservationModal').modal('hide');

                $('#viewDetailsModal').modal('show');
            },
            error: function () {
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
        success: function (data) {
            // Format date to YYYY-MM-DD for input date fields
            function formatDateForInput(dateStr) {
                if (!dateStr) return '';
                try {
                    const date = new Date(dateStr);
                    if (isNaN(date.getTime())) return '';
                    
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, '0');
                    const day = String(date.getDate()).padStart(2, '0');
                    return year + '-' + month + '-' + day; // SỬA: Thay template literal bằng phép nối chuỗi
                } catch (e) {
                    console.error('Date formatting error:', e);
                    return '';
                }
            }
            
            $('#editReservationId').val(data.id);
            $('#editCustomerName').val(data.customerName);
            $('#editRoomInfo').val('Room ' + data.roomNumber + ' (' + data.roomTypeName + ')'); // SỬA: Thay template literal
            $('#editCheckIn').val(formatDateForInput(data.checkIn));
            $('#editCheckOut').val(formatDateForInput(data.checkOut));
            $('#editNumberOfCustomers').val(data.numberOfCustomers || 1);
            $('#editStatus').val(data.status);
            $('#editSpecialRequests').val(data.specialRequests || '');

            // Khoá input nếu đã CONFIRMED
if (data.status === 'CONFIRMED') {
    $('#editStatus').prop('disabled', true);
    

    // Hiển thị cảnh báo
    if ($('#editStatusAlert').length === 0) {
        $('#editReservationForm .modal-body').prepend(`
            <div id="editStatusAlert" class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i>
                This reservation is <strong>already confirmed</strong>. Only dates and special requests can be edited.
            </div>
        `);
    }
} else {
    $('#editStatus').prop('disabled', false);
    
    $('#editStatusAlert').remove();
}

            const pricePerNight = data.totalAmount / data.nights;
            $('#editReservationModal').data('price', pricePerNight || 0);
               const originalNights = data.nights || 0;
$('#editReservationModal')
  .data('price', pricePerNight || 0)
  .data('originalNights', originalNights);



updateEditTotalAmountDisplay();
$('#editReservationModal').modal('show');
        console.log('Loaded data:', data); // Kiểm tra dữ liệu
console.log('Full data:', data);

        },
        error: function(xhr, status, error) {
            console.error('Error loading reservation details:', error);
            alert('Error loading reservation details: ' + error);
        }
    });
}

   
function updateReservation() {
    const checkInDate = new Date($('#editCheckIn').val());
    const checkOutDate = new Date($('#editCheckOut').val());
    const today = new Date().setHours(0, 0, 0, 0);

    if (checkOutDate <= checkInDate) {
        alert('Check-out date must be after check-in date');
        return;
    }

    if (checkInDate < today) {
        alert('Check-in date cannot be in the past');
        return;
    }

    // ✅ Thêm kiểm tra: không được giảm số đêm
    const newNights = Math.floor((checkOutDate - checkInDate) / (1000 * 60 * 60 * 24));
    const originalNights = $('#editReservationModal').data('originalNights');

    if (originalNights && newNights < originalNights) {
        alert(`⚠️ You cannot reduce the number of nights. Original: ${originalNights}, New: ${newNights}`);
        return;
    }

    const formData = {
        action: 'updateReservation',
        id: $('#editReservationId').val(),
        checkIn: $('#editCheckIn').val(),
        checkOut: $('#editCheckOut').val(),
        numberOfCustomers: $('#editNumberOfCustomers').val(),
        status: $('#editStatus').val(),
        specialRequests: $('#editSpecialRequests').val()
    };

    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/reservations',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(formData),
        success: function (response) {
            console.log('Update response:', response);
            if (response && (response.success === true || response.success === 'true')) {
                alert('Reservation updated successfully!');
                $('#editReservationModal').modal('hide');
                location.reload();
            } else {
                const errorMsg = response.message || 'Could not update reservation due to an unknown error.';
                alert('⚠️ ' + errorMsg);
            }
        },



        error: function (xhr, status, error) {
            let errorMessage = 'Error updating reservation: ';
            try {
                const json = JSON.parse(xhr.responseText);
                errorMessage += json.message || error;
            } catch (e) {
                errorMessage += error;
            }

            console.error('AJAX Error:', { xhr, status, error });
            alert('⚠️ ' + errorMessage);
        }

    });
}


    function filterReservations() {
        const params = new URLSearchParams();

        const status = $('#statusFilter').val();
        const checkInDate = $('#checkInDate').val();
        const checkOutDate = $('#checkOutDate').val();
        const search = $('#searchInput').val();

        if (status)
            params.append('status', status);
        if (checkInDate)
            params.append('checkInDate', checkInDate);
        if (checkOutDate)
            params.append('checkOutDate', checkOutDate);
        if (search)
            params.append('search', search);

        const url = '${pageContext.request.contextPath}/receptionist/reservations' +
                (params.toString() ? '?' + params.toString() : '');
        window.location.href = url;
    }

    function clearFilters() {
        window.location.href = '${pageContext.request.contextPath}/receptionist/reservations';
    }

    function printReservation(id) {
        window.open(`${pageContext.request.contextPath}/receptionist/reservations?action=print&id=\${id}`, '_blank');
    }

    function printReservationDetails() {
        window.print();
    }

    function sendConfirmation(id) {
        if (confirm('Send confirmation email to customer?')) {
            $.ajax({
                url: '${pageContext.request.contextPath}/receptionist/reservations',
                type: 'POST',
                data: {
                    action: 'sendConfirmation',
                    id: id
                },
                success: function (response) {
                    if (response.success) {
                        alert('Confirmation email sent successfully!');
                    } else {
                        alert('Error sending email');
                    }
                },
                error: function () {
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

    // Enhanced formatDate function with better error handling
    function formatDate(dateString) {
        if (!dateString) return '-';
        
        try {
            let date;
            if (dateString.includes('T')) {
                // ISO format
                date = new Date(dateString);
            } else if (dateString.includes('-')) {
                // yyyy-mm-dd format
                date = new Date(dateString + 'T00:00:00');
            } else {
                // Try parsing as is
                date = new Date(dateString);
            }
            
            if (isNaN(date.getTime())) {
                return dateString; // Return original if parsing fails
            }
            
            return date.toLocaleDateString('vi-VN', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'
            });
        } catch (e) {
            console.error('Date formatting error:', e);
            return dateString || '-';
        }
    }

    function formatCurrency(amount) {
        if (amount === null || amount === undefined)
            return '0₫';
        return new Intl.NumberFormat('vi-VN').format(amount) + '₫';
    }
    function showEditModal() {
    $('#editReservationModal').modal('show');
}
function updateTotalAmountDisplay() {
    const checkIn = new Date($('#newCheckIn').val());
    const checkOut = new Date($('#newCheckOut').val());
    const roomPrice = parseFloat($('#roomTypeSelect option:selected').data('price'));

    if (!isNaN(checkIn) && !isNaN(checkOut) && !isNaN(roomPrice)) {
        const nights = Math.floor((checkOut - checkIn) / (1000 * 60 * 60 * 24));
        const totalAmount = nights * roomPrice;
        const deposit = totalAmount * 0.1;

        $('#nightsDisplay').text(nights);
        $('#totalAmountDisplay').text(totalAmount.toLocaleString() + '₫');
        $('#depositAmountDisplay').text(deposit.toLocaleString() + '₫');
    }
}
function updateEditTotalAmountDisplay() {
    const checkIn = new Date($('#editCheckIn').val());
    const checkOut = new Date($('#editCheckOut').val());
    const roomPrice = parseFloat($('#editReservationModal').data('price')) || 0;

    if (!isNaN(checkIn) && !isNaN(checkOut) && !isNaN(roomPrice) && checkOut > checkIn) {
        const nights = Math.floor((checkOut - checkIn) / (1000 * 60 * 60 * 24));
        const totalAmount = nights * roomPrice;
        const deposit = totalAmount * 0.1;

        $('#editNightsDisplay').text(nights);
        $('#editTotalAmountDisplay').text(formatCurrency(totalAmount));
        $('#editDepositAmountDisplay').text(formatCurrency(deposit));
    } else {
        $('#editNightsDisplay').text('0');
        $('#editTotalAmountDisplay').text('0₫');
        $('#editDepositAmountDisplay').text('0₫');
    }
}



</script>
<style>
  #reservationDetails, #reservationDetails * {
    color: #212529 !important;
  }
</style>

<!-- Cuối file reservations-content.jsp -->
<!-- View Details Modal -->
<div class="modal fade" id="viewDetailsModal" tabindex="-1">...</div>

<!-- Edit Reservation Modal -->
<div class="modal fade" id="editReservationModal" tabindex="-1">...</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

