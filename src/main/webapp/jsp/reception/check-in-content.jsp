<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Calendar View -->
    <div id="calendarView" class="card mb-4">
        <div class="card-header bg-info text-white">
            <div class="d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="fas fa-calendar-alt mr-2"></i> Reservation Calendar
                </h5>
                                    <div class="d-flex align-items-center">
                        <div class="mr-3 d-flex align-items-center">
                            <div style="width: 15px; height: 15px; background-color: #17a2b8; margin-right: 5px; border: 1px solid black;"></div>
                            <span class="small">Booking</span>
                        </div>
                        <div class="mr-3 d-flex align-items-center">
                            <div style="width: 15px; height: 15px; background-color: #dc3545; margin-right: 5px; border: 1px solid black;"></div>
                            <span class="small">Occupied</span>
                        </div>
                        <div class="mr-3 d-flex align-items-center">
                            <div style="width: 15px; height: 15px; background-color: #28a745; margin-right: 5px; border: 1px solid black;"></div>
                            <span class="small">Free</span>
                        </div>
                        <div class="mr-4 d-flex align-items-center">
                            <button id="toggleAllRoomTypes" class="btn btn-sm btn-outline-light" title="Expand/Collapse All Room Types">
                                <i class="fas fa-expand-alt"></i> <span id="toggleAllRoomTypesText">Show All</span>
                            </button>
                        </div>
                    </div>
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
                                    <button type="button" class="btn btn-sm btn-secondary mr-1" onclick="goToToday()">Today</button>
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
            <div class="calendar-container">
                <c:if test="${empty rooms || empty calendarDates}">
                    <div class="alert alert-warning m-3">
                        <i class="fas fa-exclamation-triangle mr-2"></i>
                        Calendar data is not available. Please check server logs.
                    </div>
                </c:if>
                <c:if test="${not empty rooms && not empty calendarDates}">
                    <table class="table table-bordered calendar-table">
                        <thead>
                            <tr>
                                <th style="width: 130px; min-width: 130px;">Room</th>
                                <c:forEach var="date" items="${calendarDates}">
                                    <th class="text-center ${date.equals(today) ? 'bg-warning' : (date.getDayOfWeek().getValue() >= 6 ? 'bg-light' : '')}" 
                                        style="width: 12%; min-width: 12%;">
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
                                        <div class="font-weight-bold text-center">${room.roomNumber}</div>
                                        <div class="text-center mt-1">
                                            <span class="badge badge-${room.status == 'AVAILABLE' ? 'success' : (room.status == 'OCCUPIED' ? 'info' : (room.status == 'MAINTENANCE' ? 'danger' : 'warning'))}" style="width: 100%; padding: 8px 0; font-size: 14px;">${room.status}</span>
                                        </div>
                                    </td>
                                    <c:forEach var="date" items="${calendarDates}" varStatus="dateStatus">
                                        <td class="p-0 position-relative ${date.equals(today) ? 'bg-warning-light' : ''}">
                                            <c:set var="hasReservation" value="false" />
                                            
                                            <c:if test="${room.status == 'OCCUPIED'}">
                                                <c:forEach var="checkIn" items="${activeCheckIns}">
                                                    <c:if test="${checkIn.roomId == room.id}">
                                                        <c:set var="hasReservation" value="true" />
                                                        
                                                        <%-- Check if this date is the check-in date --%>
                                                        <c:set var="isCheckInDate" value="${checkIn.checkInTime.toLocalDate().equals(date)}" />
                                                        
                                                        <%-- Check if this date is the check-out date --%>
                                                        <c:set var="isCheckOutDate" value="${checkIn.estimatedCheckOutTime != null && checkIn.estimatedCheckOutTime.toLocalDate().equals(date)}" />
                                                        
                                                        <%-- Set class based on whether it's check-in, check-out, or middle date --%>
                                                        <c:set var="reservationClass" value="${isCheckInDate ? 'start' : (isCheckOutDate ? 'end' : 'middle')}" />
                                                        
                                                        <c:choose>
                                                            <%-- Check-in date --%>
                                                            <c:when test="${isCheckInDate}">
                                                                <c:set var="topPosition" value="${checkIn.getCheckInHour() < 12 ? '0' : '50'}" />
                                                                <div data-check-in-id="${checkIn.id}" 
                                                                     class="reservation-bar reservation-${reservationClass}" 
                                                                     style="position: absolute; top: ${topPosition}%; left: 0; right: 0; height: 50%; 
                                                                            overflow: hidden; cursor: pointer; z-index: 1;">
                                                                    <div class="reservation-info-occupied">
                                                                        <fmt:formatNumber value="${checkIn.getCheckInHour()}" pattern="0" var="checkInHour" />
                                                                        ${checkInHour}h-24h:${checkIn.customerName}
                                                                        <br/><small>(ID: ${checkIn.idType}-${checkIn.idNumber})</small>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                            
                                                            <%-- Middle date --%>
                                                            <c:when test="${!isCheckInDate && !isCheckOutDate && (checkIn.checkInTime.toLocalDate().isBefore(date) && (checkIn.estimatedCheckOutTime == null || checkIn.estimatedCheckOutTime.toLocalDate().isAfter(date)))}">
                                                                <div data-check-in-id="${checkIn.id}" 
                                                                     class="reservation-bar reservation-${reservationClass}" 
                                                                     style="position: absolute; top: 0; left: 0; right: 0; height: 100%;  
                                                                            overflow: hidden; cursor: pointer; z-index: 1;">
                                                                    <div class="reservation-info-occupied">
                                                                        00h-24h:${checkIn.customerName}
                                                                        <br/><small>(ID: ${checkIn.idType}-${checkIn.idNumber})</small>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                            
                                                            <%-- Check-out date --%>
                                                            <c:when test="${isCheckOutDate}">
                                                                <c:set var="topPosition" value="${checkIn.getCheckOutHour() > 12 ? '50' : '0'}" />
                                                                <div data-check-in-id="${checkIn.id}" 
                                                                     class="reservation-bar reservation-${reservationClass}" 
                                                                     style="position: absolute; top: ${topPosition}%; left: 0; right: 0; height: 50%; 
                                                                            overflow: hidden; cursor: pointer; z-index: 1;">
                                                                    <div class="reservation-info-occupied">
                                                                        <fmt:formatNumber value="${checkIn.getCheckOutHour()}" pattern="0" var="checkOutHour" />
                                                                        00h-${checkOutHour}h:${checkIn.customerName}
                                                                        <br/><small>(ID: ${checkIn.idType}-${checkIn.idNumber})</small>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                        </c:choose>
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                            
                                            <c:if test="${room.status != 'OCCUPIED'}">
                                                <c:forEach var="res" items="${calendarReservations}">
                                                    <c:if test="${res.roomId == room.id && res.status == 'CONFIRMED' && (res.checkIn.toLocalDate().compareTo(date) <= 0 && res.checkOut.toLocalDate().compareTo(date) >= 0)}">
                                                        <c:set var="hasReservation" value="true" />
                                                        <c:set var="isCheckIn" value="${res.checkIn.toLocalDate().equals(date)}" />
                                                        <c:set var="isCheckOut" value="${res.checkOut.toLocalDate().equals(date)}" />
                                                        <c:set var="reservationClass" value="${isCheckIn ? 'start' : (isCheckOut ? 'end' : 'middle')}" />
                                                        
                                                        <c:if test="${isCheckIn}">
                                                            <c:set var="topPosition" value="${res.getCheckInHour() < 12 ? '0' : '50'}" />
                                                            <div data-reservation-id="${res.id}" 
                                                                 class="reservation-bar reservation-${reservationClass}" 
                                                                 style="position: absolute; top: ${topPosition}%; left: 0; right: 0; height: 50%; 
                                                                        overflow: hidden; cursor: pointer; z-index: 1;">
                                                                <div class="reservation-info">
                                                                    <fmt:formatNumber value="${res.getCheckInHour()}" pattern="0" var="checkInHour" />
                                                                    ${checkInHour}h-24h:${res.customerName}
                                                                </div>
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${!isCheckIn && !isCheckOut}">
                                                            <div data-reservation-id="${res.id}" 
                                                                 class="reservation-bar reservation-${reservationClass}" 
                                                                 style="position: absolute; top: 0; left: 0; right: 0; height: 100%;  
                                                                        overflow: hidden; cursor: pointer; z-index: 1;">
                                                                <div class="reservation-info">
                                                                    00h-24h:${res.customerName}
                                                                </div>
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${isCheckOut}">
                                                            <c:set var="topPosition" value="${res.getCheckOutHour() > 12 ? '50' : '0'}" />
                                                            <div data-reservation-id="${res.id}" 
                                                                 class="reservation-bar reservation-${reservationClass}" 
                                                                 style="position: absolute; top: ${topPosition}%; left: 0; right: 0; height: 50%; 
                                                                        overflow: hidden; cursor: pointer; z-index: 1;">
                                                                <div class="reservation-info">
                                                                    <fmt:formatNumber value="${res.getCheckOutHour()}" pattern="0" var="checkOutHour" />
                                                                    00h-${checkOutHour}h:${res.customerName}
                                                                </div>
                                                            </div>
                                                        </c:if>
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                            
                                            <c:if test="${!hasReservation}">
                                                <div style="height: 60px;"></div>
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
                            <c:if test="${reservation.status eq 'CONFIRMED'}">
                                <div class="col-lg-6 mb-3">
                                    <div class="card ${reservation.checkedIn ? 'border-success' : ''}">
                                        <div class="card-body">
                                            <div class="row">
                                                <div class="col-md-8">
                                                    <h6>
                                                        <i class="fas fa-user mr-2"></i>
                                                        ${reservation.customerName}
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
                            </c:if>
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
                            
                            <!-- Thêm trường Key Card Numbers -->
                            <div class="form-group">
                                <label>Key Card Numbers</label>
                                <input type="text" class="form-control" id="keyCardNumbers" name="keyCardNumbers" 
                                       placeholder="Eg: C1001, C1002">
                            </div>
                            
                            <!-- Thêm trường Security Deposit -->
                            <div class="form-group">
                                <label>Security Deposit <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">₫</span>
                                    </div>
                                    <input type="number" id="securityDeposit" name="securityDeposit" 
                                           class="form-control" value="500000" min="0" required>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mt-3">
                        <!-- Thêm trường Special Requests -->
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Special Requests</label>
                                <textarea id="specialRequests" name="specialRequests" 
                                          class="form-control" rows="3" 
                                          placeholder="Enter any special guest requests..."></textarea>
                            </div>
                        </div>
                        
                        <!-- Thêm trường Check-In Notes -->
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Check-In Notes</label>
                                <textarea id="checkInNotes" name="checkInNotes" 
                                          class="form-control" rows="3" 
                                          placeholder="Enter any notes about the check-in..."></textarea>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Thêm trường Estimated Check-Out Time -->
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Estimated Check-Out Time</label>
                                <input type="datetime-local" id="estimatedCheckOutTime" name="estimatedCheckOutTime" 
                                       class="form-control">
                                <small class="text-muted">Default: 12:00 PM on check-out day</small>
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

<!-- Check-Out Modal -->
<div class="modal fade" id="checkOutModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Process Check-Out</h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="checkOutForm">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h6>Guest Information</h6>
                            <div class="card p-3 mb-3">
                                <p><strong>Name:</strong> <span id="checkoutGuestName"></span></p>
                                <p><strong>Phone:</strong> <span id="checkoutGuestPhone"></span></p>
                                <p><strong>Email:</strong> <span id="checkoutGuestEmail"></span></p>
                                <p class="mb-0"><strong>Booking ID:</strong> #<span id="checkoutBookingId"></span></p>
                            </div>

                            <h6>Room Information</h6>
                            <div class="card p-3 mb-3">
                                <p><strong>Room Number:</strong> <span id="checkoutRoomNumber"></span></p>
                                <p><strong>Room Type:</strong> <span id="checkoutRoomType"></span></p>
                                <p><strong>Check-in:</strong> <span id="checkoutCheckIn"></span></p>
                                <p><strong>Check-out:</strong> <span id="checkoutCheckOut"></span></p>
                                <p class="mb-0"><strong>Total Nights:</strong> <span id="checkoutNights"></span></p>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <h6>Payment Summary</h6>
                            <div class="card p-3 mb-3">
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Room Charges:</span>
                                    <span id="checkoutRoomCharges">0₫</span>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Additional Services:</span>
                                    <span id="checkoutAdditionalServices">0₫</span>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Taxes & Fees:</span>
                                    <span id="checkoutTaxes">0₫</span>
                                </div>
                                <hr>
                                <div class="d-flex justify-content-between font-weight-bold">
                                    <span>Total Amount:</span>
                                    <span id="checkoutTotalAmount">0₫</span>
                                </div>
                                <div class="d-flex justify-content-between text-success mt-2">
                                    <span>Amount Paid:</span>
                                    <span id="checkoutAmountPaid">0₫</span>
                                </div>
                                <div class="d-flex justify-content-between text-danger mt-2 font-weight-bold">
                                    <span>Balance Due:</span>
                                    <span id="checkoutBalanceDue">0₫</span>
                                </div>
                            </div>
                            
                            <h6>Room Status</h6>
                            <div class="form-group">
                                <select class="form-control" id="checkoutRoomStatus">
                                    <option value="AVAILABLE">Available (Clean)</option>
                                    <option value="CLEANING">Needs Cleaning</option>
                                    <option value="MAINTENANCE">Needs Maintenance</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label>Notes</label>
                                <textarea class="form-control" id="checkoutNotes" rows="3" 
                                          placeholder="Enter any notes about the check-out or room condition..."></textarea>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-info" id="btnPrintInvoice">
                        <i class="fas fa-print"></i> Print Invoice
                    </button>
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-door-open"></i> Complete Check-Out
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
    .calendar-container {
        width: 100%;
        overflow-x: hidden;
    }
    .calendar-table {
        width: 100%;
        table-layout: fixed;
        border-collapse: separate;
        border-spacing: 0;
    }
    .calendar-table td, .calendar-table th {
        border: 1px solid #dee2e6;
        padding: 0.25rem;
        height: 60px;
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
    }
    .calendar-table td .badge {
        display: inline-block;
        width: auto;
        min-width: 80px;
        text-align: center;
        font-size: 90%;
    }
    .reservation-bar {
        transition: all 0.2s;
        background-color: transparent !important; /* Changed from colored background to transparent */
    }
    .reservation-bar:hover {
        opacity: 1 !important;
        z-index: 10 !important;
    }
    .reservation-info {
        font-size: 12px !important;
        font-weight: bold;
        padding: 4px !important;
        color: #17a2b8 !important; /* Text color instead of background color */
    }
    /* Màu cho phòng đang sử dụng */
    .reservation-info-occupied {
        font-size: 12px !important;
        font-weight: bold;
        padding: 4px !important;
        color: #dc3545 !important; /* Màu đỏ cho phòng đang sử dụng */
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
    let allRoomsExpanded = false; // Set default to collapsed
    
    // Execute when DOM is fully loaded
    document.addEventListener('DOMContentLoaded', function() {
        console.log("DOM loaded - initialization complete");
        // Set default date for calendar picker to today
        document.getElementById('calendarDatePicker').valueAsDate = new Date();
        
        // Add event listener for the toggle all button
        document.getElementById('toggleAllRoomTypes').addEventListener('click', toggleAllRoomTypes);
        
        // Add event listeners for reservation cells
        addReservationClickHandlers();
        
        // Load saved room type states or hide all by default
        setTimeout(function() {
            loadRoomTypeStates();
        }, 200); // Small delay to ensure DOM is fully processed
    });
    
    // Function to save room type states to localStorage
    function saveRoomTypeStates() {
        const roomTypeStates = {};
        const roomTypeHeaders = document.querySelectorAll('tr.room-type-header');
        
        roomTypeHeaders.forEach(header => {
            const roomTypeId = header.getAttribute('data-room-type');
            if (roomTypeId) {
                roomTypeStates[roomTypeId] = header.classList.contains('collapsed');
            }
        });
        
        localStorage.setItem('roomTypeStates', JSON.stringify(roomTypeStates));
        console.log("Room type states saved:", roomTypeStates);
    }
    
    // Function to load room type states from localStorage
    function loadRoomTypeStates() {
        try {
            const savedStates = localStorage.getItem('roomTypeStates');
            
            if (savedStates) {
                const roomTypeStates = JSON.parse(savedStates);
                console.log("Loading saved room type states:", roomTypeStates);
                
                // Apply saved states to room types
                const roomTypeHeaders = document.querySelectorAll('tr.room-type-header');
                let allCollapsed = true;
                
                roomTypeHeaders.forEach(header => {
                    const roomTypeId = header.getAttribute('data-room-type');
                    if (roomTypeId && roomTypeStates.hasOwnProperty(roomTypeId)) {
                        const shouldBeCollapsed = roomTypeStates[roomTypeId];
                        
                        // If current state doesn't match saved state, toggle it
                        const isCurrentlyCollapsed = header.classList.contains('collapsed');
                        if (shouldBeCollapsed !== isCurrentlyCollapsed) {
                            toggleRoomType(roomTypeId);
                        }
                        
                        if (!shouldBeCollapsed) {
                            allCollapsed = false;
                        }
                    } else {
                        // Default to collapsed for any new room types
                        if (!header.classList.contains('collapsed')) {
                            toggleRoomType(roomTypeId);
                        }
                    }
                });
                
                // Update the toggle all button state
                updateToggleAllButton(!allCollapsed);
                return;
            }
        } catch (error) {
            console.error("Error loading room type states:", error);
        }
        
        // If no saved states or error, default to hiding all
        hideAllRoomTypes();
    }
    
    // Function to update the toggle all button appearance
    function updateToggleAllButton(expanded) {
        const toggleBtn = document.getElementById('toggleAllRoomTypes');
        const toggleText = document.getElementById('toggleAllRoomTypesText');
        const toggleIcon = toggleBtn.querySelector('i');
        
        if (expanded) {
            toggleText.textContent = "Hide All";
            toggleIcon.classList.remove('fa-expand-alt');
            toggleIcon.classList.add('fa-compress-alt');
            allRoomsExpanded = true;
        } else {
            toggleText.textContent = "Show All";
            toggleIcon.classList.remove('fa-compress-alt');
            toggleIcon.classList.add('fa-expand-alt');
            allRoomsExpanded = false;
        }
    }
    
    // Function to toggle all room types visibility
    function toggleAllRoomTypes() {
        console.log("Toggling all room types");
        
        // Get all room type headers
        const roomTypeHeaders = document.querySelectorAll('tr.room-type-header');
        
        if (allRoomsExpanded) {
            // Hide all room types
            roomTypeHeaders.forEach(header => {
                const roomTypeId = header.getAttribute('data-room-type');
                if (roomTypeId) {
                    // Only toggle if not already collapsed
                    if (!header.classList.contains('collapsed')) {
                        toggleRoomType(roomTypeId);
                    }
                }
            });
            
            // Update button appearance
            updateToggleAllButton(false);
        } else {
            // Show all room types
            roomTypeHeaders.forEach(header => {
                const roomTypeId = header.getAttribute('data-room-type');
                if (roomTypeId) {
                    // Only toggle if already collapsed
                    if (header.classList.contains('collapsed')) {
                        toggleRoomType(roomTypeId);
                    }
                }
            });
            
            // Update button appearance
            updateToggleAllButton(true);
        }
        
        // Note: We don't need to call saveRoomTypeStates() here
        // because each toggleRoomType() call already saves the state
    }
    
    // Function to hide all room types (used at page load)
    function hideAllRoomTypes() {
        console.log("Hiding all room types on page load");
        
        // Get all room type headers
        const roomTypeHeaders = document.querySelectorAll('tr.room-type-header');
        
        // Force all rooms to be hidden
        roomTypeHeaders.forEach(header => {
            const roomTypeId = header.getAttribute('data-room-type');
            if (roomTypeId) {
                // Add collapsed class to the header
                header.classList.add('collapsed');
                
                // Hide all room rows for this type
                const roomRows = document.querySelectorAll('tr.room-row[data-room-type="' + roomTypeId + '"]');
                roomRows.forEach(row => {
                    row.style.display = 'none';
                });
                
                // Update the toggle icon
                const toggleIcon = header.querySelector('.toggle-icon');
                if (toggleIcon) {
                    toggleIcon.classList.remove('fa-chevron-down');
                    toggleIcon.classList.add('fa-chevron-up');
                }
            }
        });
    }
    
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
            
        // Save the current state to localStorage
        saveRoomTypeStates();
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
    
    function startCheckOut(reservationId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-out',
            type: 'POST',
            data: {
                action: 'getReservation',
                id: reservationId
            },
            success: function(data) {
                // Fill modal with reservation data
                $('#checkoutGuestName').text(data.customerName);
                $('#checkoutGuestPhone').text(data.customerPhone);
                $('#checkoutGuestEmail').text(data.customerEmail);
                $('#checkoutBookingId').text(data.id);
                $('#checkoutRoomNumber').text(data.roomNumber);
                $('#checkoutRoomType').text(data.roomTypeName);
                $('#checkoutCheckIn').text(data.checkIn);
                $('#checkoutCheckOut').text(data.checkOut);
                $('#checkoutNights').text(data.nights);
                
                // Format currency values
                const formatter = new Intl.NumberFormat('vi-VN', {
                    style: 'currency',
                    currency: 'VND',
                    minimumFractionDigits: 0
                });
                
                // Fill payment details
                $('#checkoutRoomCharges').text(formatter.format(data.roomCharges));
                $('#checkoutAdditionalServices').text(formatter.format(data.additionalServices || 0));
                $('#checkoutTaxes').text(formatter.format(data.taxes || 0));
                $('#checkoutTotalAmount').text(formatter.format(data.totalAmount));
                $('#checkoutAmountPaid').text(formatter.format(data.amountPaid || 0));
                
                // Calculate balance due
                const balanceDue = data.totalAmount - (data.amountPaid || 0);
                $('#checkoutBalanceDue').text(formatter.format(balanceDue));
                
                // Set default room status
                $('#checkoutRoomStatus').val('CLEANING');
                $('#checkoutNotes').val('');
                
                // Show the modal
                $('#checkOutModal').modal('show');
            },
            error: function() {
                alert('Error loading check-out details');
            }
        });
    }
    
    $('#checkOutForm').submit(function(e) {
        e.preventDefault();
        
        const checkOutData = {
            reservationId: $('#checkoutBookingId').text(),
            roomStatus: $('#checkoutRoomStatus').val(),
            notes: $('#checkoutNotes').val(),
            balancePaid: true // Assuming balance is paid at check-out
        };
        
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-out',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(checkOutData),
            dataType: 'json',
            beforeSend: function() {
                // Disable submit button
                $('#checkOutForm button[type="submit"]').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Processing...');
            },
            success: function(response) {
                // Close modal
                $('#checkOutModal').modal('hide');
                
                // Show success message
                alert('Check-out completed successfully!');
                
                // Reload the page to update the list
                location.reload();
            },
            error: function(xhr) {
                // Re-enable submit button
                $('#checkOutForm button[type="submit"]').prop('disabled', false).html('<i class="fas fa-door-open"></i> Complete Check-Out');
                
                // Show error message
                alert('Error during check-out: ' + (xhr.responseJSON ? xhr.responseJSON.error : 'Unknown error'));
            }
        });
    });
    
    // Handle print invoice button click
    $('#btnPrintInvoice').click(function() {
        const reservationId = $('#checkoutBookingId').text();
        
        // Open invoice in a new window/tab
        window.open('${pageContext.request.contextPath}/receptionist/invoice?id=' + reservationId, '_blank');
    });
    
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
        
        // Get form values
        var formData = {
            reservationId: parseInt($('#modalBookingId').text()),
            idType: $('input[name="idType"]:checked').val(),
            idNumber: $('#idNumber').val(),
            additionalGuests: parseInt($('#additionalGuests').val()),
            keyCards: parseInt($('#keyCards').val()),
            keyCardNumbers: $('#keyCardNumbers').val(),
            checkInNotes: $('#checkInNotes').val(),
            specialRequests: $('#specialRequests').val(),
            securityDeposit: parseFloat($('#securityDeposit').val()),
            estimatedCheckOutTime: $('#estimatedCheckOutTime').val(),
            amenities: []
        };
        
        // Validate required fields
        if (!formData.idType || !formData.idNumber || !formData.keyCards || !formData.keyCardNumbers) {
            toastr.error('Please fill in all required fields');
            return;
        }

        // Collect amenity data if available
        $('.amenity-check').each(function() {
            var amenityId = $(this).data('amenity-id');
            var isPresent = $(this).prop('checked');
            formData.amenities.push({
                amenityId: amenityId,
                present: isPresent
            });
        });
        
        // Submit check-in
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-in',
            type: 'POST',
            data: JSON.stringify(formData),
            contentType: 'application/json',
            dataType: 'json',
            success: function(response) {
                if (response.success) {
                    toastr.success('Check-in completed successfully');
                    $('#checkInModal').modal('hide');
                    // Reload page after a short delay
                    setTimeout(function() {
                        window.location.reload();
                    }, 1500);
                } else {
                    toastr.error('Error processing check-in');
                }
            },
            error: function(xhr) {
                try {
                    var errorMsg = JSON.parse(xhr.responseText).error;
                    toastr.error(errorMsg || 'Error processing check-in');
                } catch(e) {
                    toastr.error('Error processing check-in');
                }
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
    
    // Function to go to today
    function goToToday() {
        window.location.href = '?weekOffset=0';
    }

    // Function to add click handlers to reservation cells
    function addReservationClickHandlers() {
        // Get all reservation bars
        const reservationBars = document.querySelectorAll('.reservation-bar');
        
        // Add click event to each reservation bar
        reservationBars.forEach(bar => {
            bar.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                const reservationId = this.getAttribute('data-reservation-id');
                
                // Check if this is an occupied room (has occupied class)
                if (this.querySelector('.reservation-info-occupied')) {
                    // This is an occupied room - show check-out modal
                    startCheckOut(reservationId);
                } else {
                    // This is a booking - show check-in modal
                    startCheckIn(reservationId);
                }
            });
        });
    }
</script>