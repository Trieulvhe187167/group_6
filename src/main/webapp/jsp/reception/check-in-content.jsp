<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h2>Check-In Management</h2>
            <p class="text-muted">Process guest check-ins quickly and efficiently</p>
        </div>
    </div>

    <!-- Calendar View -->
    <div id="calendarView" class="card mb-4">
        <div class="card-header bg-info text-white">
            <div class="d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="fas fa-calendar-alt mr-2"></i> Reservation Calendar
                </h5>
                <div class="btn-group">
                    <a href="?weekOffset=${prevWeekOffset}" class="btn btn-sm btn-light">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                    <div class="btn-group">
                        <button type="button" class="btn btn-sm btn-light dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                            ${startOfWeekFormatted} - ${endOfWeekFormatted}
                        </button>
                        <div class="dropdown-menu p-3">
                            <div class="form-group mb-0">
                                <label for="calendarDatePicker">Select a date:</label>
                                <input type="date" id="calendarDatePicker" class="form-control form-control-sm">
                                <div class="mt-2 text-right">
                                    <button type="button" class="btn btn-sm btn-info" onclick="goToSelectedDate()">Go</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <a href="?weekOffset=${nextWeekOffset}" class="btn btn-sm btn-light">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </div>
            </div>
        </div>
        <div class="card-body p-0">
            <div class="calendar-container" style="overflow-x: auto;">
                <c:if test="${empty rooms || empty calendarDates}">
                    <div class="alert alert-warning m-3">
                        <i class="fas fa-exclamation-triangle mr-2"></i>
                        Calendar data is not available. Please check server logs.
                    </div>
                </c:if>
                <c:if test="${not empty rooms && not empty calendarDates}">
                    <table class="table table-bordered calendar-table" style="min-width: 1500px;">
                        <thead>
                            <tr>
                                <th style="width: 120px; min-width: 120px;">Room</th>
                                <c:forEach var="date" items="${calendarDates}">
                                    <th class="text-center ${date.equals(today) ? 'bg-warning' : (date.getDayOfWeek().getValue() >= 6 ? 'bg-light' : '')}" 
                                        style="width: 40px; min-width: 40px;">
                                        <div class="small">${date.getDayOfMonth()}</div>
                                        <div class="small text-muted">${date.getDayOfWeek().toString().substring(0,3)}</div>
                                    </th>
                                </c:forEach>
                            </tr>
                        </thead>
                        <tbody>
                            <c:set var="currentRoomType" value="" />
                            <c:forEach var="room" items="${rooms}" varStatus="roomStatus">
                                <c:if test="${room.roomTypeName != currentRoomType}">
                                    <c:set var="currentRoomType" value="${room.roomTypeName}" />
                                    <c:set var="roomTypeId" value="${fn:replace(room.roomTypeName, ' ', '-')}" />
                                    <tr class="room-type-header" data-room-type="${roomTypeId}" id="header-${roomTypeId}">
                                        <td colspan="${calendarDates.size() + 1}" class="bg-secondary text-white">
                                            <div class="d-flex justify-content-between align-items-center" 
                                                 onclick="toggleRoomType('${roomTypeId}')">
                                                <strong>${room.roomTypeName}</strong>
                                                <i class="fas fa-chevron-down toggle-icon"></i>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                                <tr class="room-row" id="room-${room.id}" data-room-type="${fn:replace(room.roomTypeName, ' ', '-')}">
                                    <td class="align-middle">
                                        <div class="font-weight-bold">${room.roomNumber}</div>
                                        <span class="badge badge-${room.status == 'AVAILABLE' ? 'success' : (room.status == 'OCCUPIED' ? 'info' : (room.status == 'MAINTENANCE' ? 'danger' : 'warning'))}">${room.status}</span>
                                    </td>
                                    <c:forEach var="date" items="${calendarDates}" varStatus="dateStatus">
                                        <td class="p-0 position-relative ${date.equals(today) ? 'bg-warning-light' : ''}">
                                            <c:set var="hasReservation" value="false" />
                                            <c:forEach var="res" items="${calendarReservations}">
                                                <c:if test="${res.roomId == room.id && (res.checkIn.toLocalDate().compareTo(date) <= 0 && res.checkOut.toLocalDate().compareTo(date) >= 0)}">
                                                    <c:set var="hasReservation" value="true" />
                                                    <c:set var="isCheckIn" value="${res.checkIn.toLocalDate().equals(date)}" />
                                                    <c:set var="isCheckOut" value="${res.checkOut.toLocalDate().equals(date)}" />
                                                    <c:set var="reservationClass" value="${isCheckIn ? 'start' : (isCheckOut ? 'end' : 'middle')}" />
                                                    
                                                    <c:if test="${isCheckIn}">
                                                        <div data-reservation-id="${res.id}" 
                                                             class="reservation-bar reservation-${reservationClass}" 
                                                             style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; 
                                                                    background-color: #007bff; opacity: 0.8; 
                                                                    border-top-left-radius: 4px; border-bottom-left-radius: 4px; 
                                                                    overflow: hidden; cursor: pointer; z-index: 1;">
                                                            <div class="reservation-info p-1 text-white small">
                                                                <i class="fas fa-sign-in-alt"></i> ${res.customerName}
                                                            </div>
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${!isCheckIn && !isCheckOut}">
                                                        <div data-reservation-id="${res.id}" 
                                                             class="reservation-bar reservation-${reservationClass}" 
                                                             style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; 
                                                                    background-color: #007bff; opacity: 0.6; 
                                                                    overflow: hidden; cursor: pointer; z-index: 1;">
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${isCheckOut}">
                                                        <div data-reservation-id="${res.id}" 
                                                             class="reservation-bar reservation-${reservationClass}" 
                                                             style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; 
                                                                    background-color: #007bff; opacity: 0.8; 
                                                                    border-top-right-radius: 4px; border-bottom-right-radius: 4px; 
                                                                    overflow: hidden; cursor: pointer; z-index: 1;">
                                                            <div class="reservation-info p-1 text-white small">
                                                                <i class="fas fa-sign-out-alt"></i>
                                                            </div>
                                                        </div>
                                                    </c:if>
                                                </c:if>
                                            </c:forEach>
                                            <c:if test="${!hasReservation}">
                                                <div style="height: 30px;"></div>
                                            </c:if>
                                        </td>
                                    </c:forEach>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Quick Search -->
    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title">Quick Check-In Search</h5>
            <div class="row">
                <div class="col-md-8">
                    <div class="input-group">
                        <input type="text" class="form-control form-control-lg" id="searchInput" 
                               placeholder="Enter Booking ID, Guest Name, or Phone Number...">
                        <div class="input-group-append">
                            <button class="btn btn-info" type="button" onclick="searchReservation()">
                                <i class="fas fa-search"></i> Search
                            </button>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <button class="btn btn-success btn-lg btn-block" onclick="scanQRCode()">
                        <i class="fas fa-qrcode"></i> Scan QR Code
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Search Results -->
    <div id="searchResults" style="display: none;">
        <div class="card mb-4">
            <div class="card-body">
                <h5 class="card-title">Search Results</h5>
                <div id="resultsContainer">
                    <!-- Results will be loaded here -->
                </div>
            </div>
        </div>
    </div>

    <!-- Today's Expected Check-Ins -->
    <div class="card">
        <div class="card-body">
            <h5 class="card-title">
                Today's Expected Check-Ins 
                <span class="badge badge-info">${todayCheckIns.size()}</span>
            </h5>

            <c:choose>
                <c:when test="${not empty todayCheckIns}">
                    <div class="row">
                        <c:forEach var="reservation" items="${todayCheckIns}">
                            <div class="col-lg-6 mb-3">
                                <div class="card ${reservation.checkedIn ? 'border-success' : ''}">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-8">
                                                <h6>
                                                    <i class="fas fa-user mr-2"></i>
                                                    ${reservation.customerName}
                                                    <c:if test="${reservation.status eq 'PENDING'}">
                                                        <span class="badge badge-warning ml-2">Pending</span>
                                                    </c:if>
                                                    <c:if test="${reservation.checkedIn}">
                                                        <span class="badge badge-success ml-2">Checked In</span>
                                                    </c:if>
                                                </h6>
                                                <p class="mb-2">
                                                    <i class="fas fa-phone mr-2"></i>${reservation.customerPhone}
                                                    <i class="fas fa-envelope ml-3 mr-2"></i>${reservation.customerEmail}
                                                </p>
                                                <div class="bg-light p-2 rounded">
                                                    <strong>Booking ID:</strong> #${reservation.id} |
                                                    <strong>Room:</strong> ${reservation.roomNumber} |
                                                    <strong>Type:</strong> ${reservation.roomTypeName} |
                                                    <strong>Nights:</strong> ${reservation.nights}
                                                </div>
                                            </div>
                                            <div class="col-md-4 text-right">
                                                <h5 class="text-info mb-3">
                                                    <fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0"/>₫
                                                </h5>
                                                <c:choose>
                                                    <c:when test="${reservation.checkedIn}">
                                                        <button class="btn btn-secondary" disabled>
                                                            <i class="fas fa-check-circle"></i> Checked In
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="btn btn-info btn-lg" 
                                                                onclick="startCheckIn(${reservation.id})">
                                                            <i class="fas fa-sign-in-alt"></i> Check In
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <c:if test="${not empty reservation.specialRequests}">
                                            <div class="alert alert-info mt-3 mb-0">
                                                <i class="fas fa-info-circle"></i> 
                                                <strong>Special Requests:</strong> ${reservation.specialRequests}
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="fas fa-calendar-check fa-3x text-muted mb-3"></i>
                        <p class="text-muted">No check-ins scheduled for today</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Check-In Modal -->
<div class="modal fade" id="checkInModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title">Process Check-In</h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="checkInForm">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h6>Guest Information</h6>
                            <div class="card p-3 mb-3">
                                <p><strong>Name:</strong> <span id="modalGuestName"></span></p>
                                <p><strong>Phone:</strong> <span id="modalGuestPhone"></span></p>
                                <p><strong>Email:</strong> <span id="modalGuestEmail"></span></p>
                                <p class="mb-0"><strong>Booking ID:</strong> #<span id="modalBookingId"></span></p>
                            </div>

                            <h6>Room Information</h6>
                            <div class="card p-3 mb-3">
                                <p><strong>Room Number:</strong> <span id="modalRoomNumber"></span></p>
                                <p><strong>Room Type:</strong> <span id="modalRoomType"></span></p>
                                <p><strong>Check-in:</strong> <span id="modalCheckIn"></span></p>
                                <p class="mb-0"><strong>Check-out:</strong> <span id="modalCheckOut"></span></p>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <h6>Verification Details</h6>
                            <div class="btn-group btn-group-toggle d-flex mb-3" data-toggle="buttons">
                                <label class="btn btn-outline-info">
                                    <input type="radio" id="idTypePassport" name="idType" value="PASSPORT" required> 
                                    <i class="fas fa-passport"></i> Passport
                                </label>
                                <label class="btn btn-outline-info">
                                    <input type="radio" id="idTypeIdCard" name="idType" value="ID_CARD" required> 
                                    <i class="fas fa-id-card"></i> ID Card
                                </label>
                                <label class="btn btn-outline-info">
                                    <input type="radio" id="idTypeDriver" name="idType" value="DRIVER_LICENSE" required> 
                                    <i class="fas fa-car"></i> Driver License
                                </label>
                            </div>

                            <div class="form-group">
                                <label>ID Number <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="idNumber" name="idNumber" required>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Additional Guests</label>
                                        <input type="number" class="form-control" id="additionalGuests" name="additionalGuests"
                                               value="0" min="0" max="5">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Key Cards</label>
                                        <input type="number" class="form-control" id="keyCards" name="keyCards"
                                               value="2" min="1" max="4">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-info">
                        <i class="fas fa-check"></i> Complete Check-In
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
    .calendar-container {
        overflow-x: auto;
    }
    .calendar-table {
        border-collapse: separate;
        border-spacing: 0;
    }
    .calendar-table td, .calendar-table th {
        border: 1px solid #dee2e6;
        padding: 0.25rem;
        height: 30px;
    }
    .reservation-bar {
        transition: all 0.2s;
    }
    .reservation-bar:hover {
        opacity: 1 !important;
        z-index: 10 !important;
    }
    .bg-warning-light {
        background-color: rgba(255, 193, 7, 0.2);
    }
    .room-type-header {
        cursor: pointer;
        transition: background-color 0.2s;
    }
    .room-type-header:hover {
        background-color: #5a6268;
    }
    .room-type-header .toggle-icon {
        transition: transform 0.3s;
    }
    .room-type-header.collapsed .toggle-icon {
        transform: rotate(180deg);
    }
    .room-hidden {
        display: none !important;
    }
</style>

<script>
    let currentReservationId = null;
    
    // Execute when DOM is fully loaded
    document.addEventListener('DOMContentLoaded', function() {
        console.log("DOM loaded - initialization complete");
        // Set default date for calendar picker to today
        document.getElementById('calendarDatePicker').valueAsDate = new Date();
    });
    
    // Function to toggle room type visibility
    function toggleRoomType(roomTypeId) {
        console.log("Toggling room type: " + roomTypeId);
        
        // Get the header element
        const headerRow = document.getElementById('header-' + roomTypeId);
        if (!headerRow) {
            console.error("Header element not found for room type: " + roomTypeId);
            return;
        }
        
        // Get all room rows with this room type
        const roomRows = document.querySelectorAll('tr.room-row[data-room-type="' + roomTypeId + '"]');
        console.log("Found " + roomRows.length + " room rows to toggle");
        
        // Toggle collapsed class on the header
        headerRow.classList.toggle('collapsed');
        const isCollapsed = headerRow.classList.contains('collapsed');
        
        // Toggle visibility of room rows
        roomRows.forEach(row => {
            if (isCollapsed) {
                row.style.display = 'none';
                console.log("Hiding row: " + row.id);
            } else {
                row.style.display = '';
                console.log("Showing row: " + row.id);
            }
        });
        
        // Toggle icon direction
        const toggleIcon = headerRow.querySelector('.toggle-icon');
        if (toggleIcon) {
            if (isCollapsed) {
                toggleIcon.classList.remove('fa-chevron-down');
                toggleIcon.classList.add('fa-chevron-up');
            } else {
                toggleIcon.classList.remove('fa-chevron-up');
                toggleIcon.classList.add('fa-chevron-down');
            }
        }
        
        console.log(isCollapsed 
            ? "Collapsed room type: " + roomTypeId
            : "Expanded room type: " + roomTypeId);
    }
    
    function startCheckIn(reservationId) {
        currentReservationId = reservationId;
        
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-in',
            type: 'POST',
            data: {
                action: 'getReservation',
                id: reservationId
            },
            success: function(reservation) {
                // Fill modal with reservation data
                $('#modalGuestName').text(reservation.customerName);
                $('#modalGuestPhone').text(reservation.customerPhone);
                $('#modalGuestEmail').text(reservation.customerEmail);
                $('#modalBookingId').text(reservation.id);
                $('#modalRoomNumber').text(reservation.roomNumber);
                $('#modalRoomType').text(reservation.roomTypeName);
                $('#modalCheckIn').text(reservation.checkIn);
                $('#modalCheckOut').text(reservation.checkOut);
                
                // Clear previous values
                $('#idNumber').val('');
                $('#additionalGuests').val(0);
                $('#keyCards').val(2);
                
                // Uncheck all radio buttons
                $('input[name="idType"]').prop('checked', false);
                $('.btn-group-toggle label').removeClass('active');
                
                // Show the modal
                $('#checkInModal').modal('show');
            },
            error: function() {
                alert('Error loading reservation details');
            }
        });
    }
    
    function searchReservation() {
        const searchValue = $('#searchInput').val().trim();
        if (!searchValue) {
            alert('Please enter a search term');
            return;
        }

        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-in',
            type: 'POST',
            data: {
                action: 'searchReservation',
                query: searchValue
            },
            success: function(results) {
                displaySearchResults(results);
            },
            error: function() {
                alert('Error searching reservations');
            }
        });
    }
    
    function displaySearchResults(results) {
        let html = '';
        
        if (results.length === 0) {
            html = '<div class="alert alert-info"><i class="fas fa-info-circle"></i> No matching reservations found.</div>';
        } else {
            html = '<div class="row">';
            
            for (let i = 0; i < results.length; i++) {
                const reservation = results[i];
                html += '<div class="col-md-6 mb-3">' +
                    '<div class="card ' + (reservation.checkedIn ? 'border-success' : '') + '">' +
                    '<div class="card-body">' +
                    '<div class="row">' +
                    '<div class="col-md-8">' +
                    '<h6>' +
                    '<i class="fas fa-user mr-2"></i> ' +
                    reservation.customerName +
                    (reservation.status === 'PENDING' ? 
                      '<span class="badge badge-warning ml-2">Pending</span>' : '') +
                    (reservation.checkedIn ? 
                      '<span class="badge badge-success ml-2">Checked In</span>' : '') +
                    '</h6>' +
                    '<p class="mb-2">' +
                    '<i class="fas fa-phone mr-2"></i>' + reservation.customerPhone +
                    '<i class="fas fa-envelope ml-3 mr-2"></i>' + reservation.customerEmail +
                    '</p>' +
                    '<div class="bg-light p-2 rounded">' +
                    '<strong>Booking ID:</strong> #' + reservation.id + ' | ' +
                    '<strong>Room:</strong> ' + reservation.roomNumber + ' | ' +
                    '<strong>Type:</strong> ' + reservation.roomTypeName +
                    '</div>' +
                    '</div>' +
                    '<div class="col-md-4 text-right">' +
                    (reservation.checkedIn ? 
                      '<button class="btn btn-secondary" disabled>' +
                      '<i class="fas fa-check-circle"></i> Checked In' +
                      '</button>' : 
                      '<button class="btn btn-info" ' +
                      'onclick="startCheckIn(' + reservation.id + ')">' +
                      '<i class="fas fa-sign-in-alt"></i> Check In' +
                      '</button>'
                    ) +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            }
            
            html += '</div>';
        }
        
        $('#resultsContainer').html(html);
        $('#searchResults').show();
    }
    
    $('#checkInForm').submit(function(e) {
        e.preventDefault();
        
        // Validate form
        if (!$('input[name="idType"]:checked').val()) {
            alert('Please select an ID type');
            return;
        }
        
        if (!$('#idNumber').val().trim()) {
            alert('Please enter ID number');
            return;
        }
        
        const checkInData = {
            reservationId: currentReservationId,
            idType: $('input[name="idType"]:checked').val(),
            idNumber: $('#idNumber').val().trim(),
            additionalGuests: parseInt($('#additionalGuests').val()),
            keyCards: parseInt($('#keyCards').val()),
            keyCardNumbers: '',
            checkInNotes: '',
            securityDeposit: 0
        };
        
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-in',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(checkInData),
            dataType: 'json',
            beforeSend: function() {
                // Disable submit button
                $('#checkInForm button[type="submit"]').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Processing...');
            },
            success: function(response) {
                // Close modal
                $('#checkInModal').modal('hide');
                
                // Show success message
                alert('Check-in completed successfully!');
                
                // Reload the page to update the list
                location.reload();
            },
            error: function(xhr) {
                // Re-enable submit button
                $('#checkInForm button[type="submit"]').prop('disabled', false).html('<i class="fas fa-check"></i> Complete Check-In');
                
                // Show error message
                alert('Error during check-in: ' + (xhr.responseJSON ? xhr.responseJSON.error : 'Unknown error'));
            }
        });
    });
    
    function scanQRCode() {
        alert('QR Code scanning functionality not implemented yet.');
    }

    // Function to go to selected date
    function goToSelectedDate() {
        const selectedDate = document.getElementById('calendarDatePicker').value;
        if (selectedDate) {
            window.location.href = '?selectedDate=' + selectedDate;
        }
    }
</script>