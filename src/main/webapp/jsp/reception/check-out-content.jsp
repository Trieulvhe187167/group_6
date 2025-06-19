<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h2>Check-Out Management</h2>
            <p class="text-muted">Process guest check-outs and handle final payments</p>
        </div>
    </div>

    <!-- Quick Search -->
    <div class="table-container mb-4">
        <h5 class="mb-3">Quick Check-Out Search</h5>
        <div class="row">
            <div class="col-md-9">
                <div class="input-group">
                    <input type="text" class="form-control form-control-lg" id="searchInput" 
                           placeholder="Enter Room Number, Booking ID, or Guest Name...">
                    <div class="input-group-append">
                        <button class="btn btn-danger" type="button" onclick="searchCheckOut()">
                            <i class="fas fa-search"></i> Search
                        </button>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <button class="btn btn-warning btn-lg btn-block" onclick="showLateCheckouts()">
                    <i class="fas fa-clock"></i> Late Check-outs
                </button>
            </div>
        </div>
    </div>

    <!-- Today's Expected Check-Outs -->
    <div class="table-container">
        <h5 class="mb-3">
            Today's Expected Check-Outs
            <span class="badge badge-danger">${todayCheckOuts.size()}</span>
        </h5>

        <c:choose>
            <c:when test="${not empty todayCheckOuts}">
                <div class="row">
                    <c:forEach var="reservation" items="${todayCheckOuts}">
                        <div class="col-lg-6 mb-3">
                            <div class="card ${reservation.isLate ? 'border-warning' : ''} ${reservation.checkedOut ? 'border-success' : ''}">
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-8">
                                            <h6>
                                                <i class="fas fa-user mr-2"></i>
                                                ${reservation.customerName}
                                                <c:if test="${reservation.isLate}">
                                                    <span class="badge badge-warning ml-2">
                                                        <i class="fas fa-clock"></i> Late
                                                    </span>
                                                </c:if>
                                                <c:if test="${reservation.checkedOut}">
                                                    <span class="badge badge-success ml-2">Checked Out</span>
                                                </c:if>
                                            </h6>
                                            <p class="mb-2">
                                                <strong>Room:</strong> ${reservation.roomNumber} |
                                                <strong>Booking ID:</strong> #${reservation.id}
                                            </p>
                                            <div class="bg-light p-2 rounded">
                                                <strong>Check-in:</strong> <fmt:formatDate value="${reservation.checkIn}" pattern="dd/MM"/> |
                                                <strong>Nights:</strong> ${reservation.nights} |
                                                <strong>Room Charges:</strong> <fmt:formatNumber value="${reservation.totalAmount}" pattern="#,##0"/>₫
                                            </div>
                                            <p class="mb-0 mt-2">
                                                <strong>Payment Status:</strong>
                                                <c:choose>
                                                    <c:when test="${reservation.paymentStatus eq 'PAID'}">
                                                        <span class="badge badge-success">Paid</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-warning">Pending</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                        <div class="col-md-4 text-right">
                                            <c:choose>
                                                <c:when test="${reservation.checkedOut}">
                                                    <button class="btn btn-secondary" disabled>
                                                        <i class="fas fa-check-circle"></i> Checked Out
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="btn btn-danger btn-lg" 
                                                            onclick="startCheckOut(${reservation.id})">
                                                        <i class="fas fa-sign-out-alt"></i> Check Out
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
                    <i class="fas fa-calendar-times fa-3x text-muted mb-3"></i>
                    <p class="text-muted">No check-outs scheduled for today</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Check-Out Modal -->
<div class="modal fade" id="checkOutModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Process Check-Out - Room <span id="modalRoomNumber"></span></h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="checkOutForm">
                <div class="modal-body">
                    <div class="row">
                        <!-- Left Column -->
                        <div class="col-md-6">
                            <h6>Guest Information</h6>
                            <div class="card p-3 mb-3">
                                <p><strong>Name:</strong> <span id="modalGuestName"></span></p>
                                <p><strong>Booking ID:</strong> #<span id="modalBookingId"></span></p>
                                <p><strong>Check-in:</strong> <span id="modalCheckIn"></span></p>
                                <p class="mb-0"><strong>Check-out:</strong> <span id="modalCheckOut"></span> (Today)</p>
                            </div>

                            <h6>Room Condition Assessment</h6>
                            <div class="form-group">
                                <label>Room Condition <span class="text-danger">*</span></label>
                                <select class="form-control" id="roomCondition" required>
                                    <option value="GOOD">Good - No issues</option>
                                    <option value="MINOR_DAMAGE">Minor Damage</option>
                                    <option value="MAJOR_DAMAGE">Major Damage</option>
                                </select>
                            </div>

                            <div id="damageSection" style="display: none;">
                                <div class="alert alert-warning">
                                    <div class="form-group">
                                        <label>Damage Description</label>
                                        <textarea class="form-control" id="damageDescription" rows="3"></textarea>
                                    </div>
                                    <div class="form-group">
                                        <label>Damage Charges (₫)</label>
                                        <input type="number" class="form-control" id="damageCharges" 
                                               value="0" min="0">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Right Column -->
                        <div class="col-md-6">
                            <h6>Billing Summary</h6>
                            <div class="card p-3">
                                <table class="table table-sm mb-0">
                                    <tr>
                                        <td>Room Charges (<span id="nights"></span> nights)</td>
                                        <td class="text-right"><span id="roomCharges">0</span>₫</td>
                                    </tr>
                                    <tr>
                                        <td>Additional Services</td>
                                        <td class="text-right"><span id="serviceCharges">0</span>₫</td>
                                    </tr>
                                    <tr>
                                        <td>Minibar & Amenities</td>
                                        <td class="text-right"><span id="amenityCharges">0</span>₫</td>
                                    </tr>
                                    <tr>
                                        <td>Damage Charges</td>
                                        <td class="text-right text-danger"><span id="damageChargesDisplay">0</span>₫</td>
                                    </tr>
                                    <tr class="border-top">
                                        <td><strong>Subtotal</strong></td>
                                        <td class="text-right"><strong><span id="subtotal">0</span>₫</strong></td>
                                    </tr>
                                    <tr>
                                        <td class="text-success">Amount Paid</td>
                                        <td class="text-right text-success">-<span id="amountPaid">0</span>₫</td>
                                    </tr>
                                    <tr>
                                        <td>Security Deposit</td>
                                        <td class="text-right"><span id="securityDeposit">0</span>₫</td>
                                    </tr>
                                    <tr class="table-info">
                                        <th>Final Amount</th>
                                        <th class="text-right"><span id="finalAmount">0</span>₫</th>
                                    </tr>
                                </table>

                                <div id="refundSection" style="display: none;" class="mt-2">
                                    <div class="alert alert-success mb-0">
                                        <strong>Refund Amount:</strong> <span id="refundAmount">0</span>₫
                                    </div>
                                </div>
                            </div>

                            <h6 class="mt-3">Payment Method</h6>
                            <div class="btn-group btn-group-toggle d-flex" data-toggle="buttons">
                                <label class="btn btn-outline-danger">
                                    <input type="radio" name="paymentMethod" id="pmCash" value="CASH" required> 
                                    <i class="fas fa-money-bill-wave"></i> Cash
                                </label>
                                <label class="btn btn-outline-danger">
                                    <input type="radio" name="paymentMethod" id="pmCard" value="CREDIT_CARD" required> 
                                    <i class="fas fa-credit-card"></i> Card
                                </label>
                                <label class="btn btn-outline-danger">
                                    <input type="radio" name="paymentMethod" id="pmTransfer" value="BANK_TRANSFER" required> 
                                    <i class="fas fa-university"></i> Transfer
                                </label>
                            </div>

                            <div class="form-group mt-3">
                                <label>Check-out Notes</label>
                                <textarea class="form-control" id="checkOutNotes" name="checkOutNotes" rows="2"></textarea>
                            </div>

                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-info" onclick="printInvoice()">
                        <i class="fas fa-print"></i> Print Invoice
                    </button>
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-check"></i> Complete Check-Out
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    let currentReservationId = null;
    let currentReservationData = null;

    $(document).ready(function () {
        $('#roomCondition').change(function () {
            if ($(this).val() !== 'GOOD') {
                $('#damageSection').show();
            } else {
                $('#damageSection').hide();
                $('#damageCharges').val(0);
                updateTotals();
            }
        });

        $('#damageCharges').on('input', function () {
            updateTotals();
        });

        $('input[name="paymentMethod"]').change(function () {
            $('#paymentMethod').val($(this).val());
        });

        $('#checkOutForm').submit(function (e) {
            e.preventDefault();
            processCheckOut();
        });
    });

    function startCheckOut(reservationId) {
        currentReservationId = reservationId;

        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-out',
            type: 'POST',
            data: {
                action: 'getCheckOutDetails',
                id: reservationId
            },
            success: function (data) {
                currentReservationData = data;
                populateCheckOutModal(data);
                $('#checkOutModal').modal('show');
            }
        });
    }

    function populateCheckOutModal(data) {
        $('#modalRoomNumber').text(data.roomNumber);
        $('#modalGuestName').text(data.customerName);
        $('#modalBookingId').text(data.id);
        $('#modalCheckIn').text(formatDate(data.checkIn));
        $('#modalCheckOut').text(formatDate(data.checkOut));

        $('#nights').text(data.nights);
        $('#roomCharges').text(formatCurrency(data.roomCharges));
        $('#serviceCharges').text(formatCurrency(data.serviceCharges));
        $('#amountPaid').text(formatCurrency(data.amountPaid));
        $('#securityDeposit').text(formatCurrency(data.securityDeposit));

        updateTotals();
    }

    function updateTotals() {
        const damageCharges = parseFloat($('#damageCharges').val()) || 0;
        $('#damageChargesDisplay').text(formatCurrency(damageCharges));

        const roomCharges = currentReservationData ? currentReservationData.roomCharges : 0;
        const serviceCharges = currentReservationData ? currentReservationData.serviceCharges : 0;
        const amenityCharges = 0; // This would be calculated based on minibar usage
        const amountPaid = currentReservationData ? currentReservationData.amountPaid : 0;
        const securityDeposit = currentReservationData ? currentReservationData.securityDeposit : 0;

        const subtotal = roomCharges + serviceCharges + amenityCharges + damageCharges;
        $('#subtotal').text(formatCurrency(subtotal));

        const finalAmount = subtotal - amountPaid;
        const refundAmount = securityDeposit - damageCharges;

        if (finalAmount > 0) {
            $('#finalAmount').text(formatCurrency(finalAmount));
            $('#refundSection').hide();
        } else {
            $('#finalAmount').text(formatCurrency(0));
            if (refundAmount > 0) {
                $('#refundAmount').text(formatCurrency(refundAmount));
                $('#refundSection').show();
            }
        }
    }

    function processCheckOut() {
        if (!$('#paymentMethod').val()) {
            alert('Please select a payment method');
            return;
        }

        const checkOutData = {
            reservationId: currentReservationId,
            roomCondition: $('#roomCondition').val(),
            damageDescription: $('#damageDescription').val(),
            damageCharges: $('#damageCharges').val() || 0,
            paymentMethod: $('#paymentMethod').val(),
            checkOutNotes: $('#checkOutNotes').val()
        };

        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/check-out',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                action: 'processCheckOut',
                ...checkOutData
            }),
            success: function (response) {
                alert('Check-out completed successfully!');
                $('#checkOutModal').modal('hide');
                location.reload();
            },
            error: function () {
                alert('Error processing check-out. Please try again.');
            }
        });
    }

    function formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('vi-VN');
    }

    function formatCurrency(amount) {
        return new Intl.NumberFormat('vi-VN').format(amount);
    }

    function printInvoice() {
        window.print();
    }

    function showLateCheckouts() {
        alert('Late check-out filter coming soon!');
    }
</script>