<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h2>Check-In Management</h2>
            <p class="text-muted">Process guest check-ins quickly and efficiently</p>
        </div>
    </div>

    <!-- Quick Search -->
    <div class="table-container mb-4">
        <h5 class="mb-3">Quick Check-In Search</h5>
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

    <!-- Search Results -->
    <div id="searchResults" style="display: none;">
        <div class="table-container mb-4">
            <h5 class="mb-3">Search Results</h5>
            <div id="resultsContainer">
                <!-- Results will be loaded here -->
            </div>
        </div>
    </div>

    <!-- Today's Expected Check-Ins -->
    <div class="table-container">
        <h5 class="mb-3">
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

                            <!-- Xóa hoàn toàn cái hidden input -->

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

        <script>
            let currentReservationId = null;

            // ID Type selection
            $('input[name="idType"]').change(function () {
                $('#idType').val($(this).val());
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
                    success: function (results) {
                        displaySearchResults(results);
                    },
                    error: function () {
                        alert('Error searching reservations');
                    }
                });
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
                    success: function (reservation) {
                        $('#modalGuestName').text(reservation.customerName);
                        $('#modalGuestPhone').text(reservation.customerPhone);
                        $('#modalGuestEmail').text(reservation.customerEmail);
                        $('#modalBookingId').text(reservation.id);
                        $('#modalRoomNumber').text(reservation.roomNumber);
                        $('#modalRoomType').text(reservation.roomTypeName);
                        $('#modalCheckIn').text(formatDate(reservation.checkIn));
                        $('#modalCheckOut').text(formatDate(reservation.checkOut));

                        $('#checkInModal').modal('show');
                    }
                });
            }

            $('#checkInForm').submit(function (e) {
                e.preventDefault();

                if (!$('#idType').val()) {
                    alert('Please select ID type');
                    return;
                }

                const checkInData = {
                    reservationId: currentReservationId,
                    idType: $('#idType').val(),
                    idNumber: $('#idNumber').val(),
                    additionalGuests: $('#additionalGuests').val(),
                    securityDeposit: $('#securityDeposit').val(),
                    keyCards: $('#keyCards').val(),
                    checkInNotes: $('#checkInNotes').val()
                };

                $.ajax({
                    url: '${pageContext.request.contextPath}/receptionist/check-in',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify({
                        action: 'processCheckIn',
                        ...checkInData
                    }),
                    success: function (response) {
                        alert('Check-in completed successfully!');
                        $('#checkInModal').modal('hide');
                        location.reload();
                    },
                    error: function () {
                        alert('Error processing check-in. Please try again.');
                    }
                });
            });

            function formatDate(dateString) {
                const date = new Date(dateString);
                return date.toLocaleDateString('vi-VN');
            }

            function scanQRCode() {
                alert('QR Code scanner feature coming soon!');
            }

            // Enter key to search
            $('#searchInput').keypress(function (e) {
                if (e.which === 13) {
                    searchReservation();
                }
            });
        </script>