<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
        .profile-content-bx {
            background: #fff;
            border: 1px solid #e9e9e9;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .profile-head {
            background: #17a2b8;
            color: white;
            padding: 30px;
            text-align: center;
        }
        .profile-bx {
            padding: 30px;
        }
        .guest-avatar {
            width: 100px;
            height: 100px;
            background: white;
            color: #17a2b8;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: bold;
            margin: 0 auto 20px;
        }
        .stat-box {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin-bottom: 20px;
        }
        .stat-box h3 {
            color: #17a2b8;
            margin-bottom: 10px;
        }
        .badge {
            display: inline-block;
            padding: .25em .4em;
            font-size: 75%;
            font-weight: 700;
            line-height: 1;
            text-align: center;
            white-space: nowrap;
            vertical-align: baseline;
            border-radius: .25rem;
        }
        .badge-info {
            color: #fff;
            background-color: #17a2b8;
        }
        .badge-success {
            color: #fff;
            background-color: #28a745;
        }
        .badge-warning {
            color: #212529;
            background-color: #ffc107;
        }
        .booking-history-item {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            transition: all 0.3s;
        }
        .booking-history-item:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .form-group label {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        .form-control-static {
            font-size: 16px;
            color: #666;
        }
        .section-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #17a2b8;
        }
    </style>

<div class="container-fluid">
    <!-- Back button and title -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <a href="${pageContext.request.contextPath}/receptionist/guests" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> Back to Guest List
        </a>
        <h2>Guest Details</h2>
    </div>
                            <div class="profile-content-bx">
                                <div class="profile-head">
                                    <div class="guest-avatar">
                                        ${guest.fullName.substring(0,1).toUpperCase()}
                                    </div>
                                    <h3>${guest.fullName}</h3>
                                    <c:if test="${guest.loyaltyStatus eq 'VIP'}">
                                        <span class="badge badge-warning">VIP Member</span>
                                    </c:if>
                                </div>
                                
                                <div class="profile-bx">
                                    <!-- Basic Information -->
                                    <h4 class="section-title">
                                        <i class="fa fa-user"></i> Basic Information
                                    </h4>
                                    <div class="row mb-4">
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Guest ID</label>
                                                <p class="form-control-static">#${guest.id}</p>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Full Name</label>
                                                <p class="form-control-static">${guest.fullName}</p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row mb-4">
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Email</label>
                                                <p class="form-control-static">
                                                    <a href="mailto:${guest.email}">
                                                        <i class="fa fa-envelope"></i> ${guest.email}
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Phone</label>
                                                <p class="form-control-static">
                                                    <a href="tel:${guest.phone}">
                                                        <i class="fa fa-phone"></i> ${guest.phone}
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row mb-4">
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Member Since</label>
                                                <p class="form-control-static">
                                                    <i class="fa fa-calendar"></i> 
                                                    <fmt:formatDate value="${guest.createdAt}" 
                                                                    pattern="dd/MM/yyyy"/>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Last Visit</label>
                                                <p class="form-control-static">
                                                    <c:choose>
                                                        <c:when test="${guest.lastVisit != null}">
                                                            <i class="fa fa-clock"></i> 
                                                            <fmt:formatDate value="${guest.lastVisit}" 
                                                                            pattern="dd/MM/yyyy"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">No visits yet</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Statistics -->
                                    <h4 class="section-title">
                                        <i class="fa fa-chart-bar"></i> Guest Statistics
                                    </h4>
                                    <div class="row mb-4">
                                        <div class="col-md-3">
                                            <div class="stat-box">
                                                <h3>${guest.totalBookings}</h3>
                                                <p class="mb-0">Total Bookings</p>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="stat-box">
                                                <h3>${guest.completedBookings}</h3>
                                                <p class="mb-0">Completed Stays</p>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="stat-box">
                                                <h3>${guest.avgNights}</h3>
                                                <p class="mb-0">Avg. Nights/Stay</p>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="stat-box">
                                                <h3><fmt:formatNumber value="${guest.totalSpent}" pattern="#,##0"/>₫</h3>
                                                <p class="mb-0">Total Spent</p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Booking History -->
                                    <h4 class="section-title">
                                        <i class="fa fa-history"></i> Booking History
                                    </h4>
                                    <div class="booking-history">
                                        <c:choose>
                                            <c:when test="${not empty guest.bookingHistory}">
                                                <c:forEach var="booking" items="${guest.bookingHistory}">
                                                    <div class="booking-history-item">
                                                        <div class="row">
                                                            <div class="col-md-3">
                                                                <strong>Booking #${booking.id}</strong>
                                                                <br>
                                                                <small class="text-muted">
                                                                    <fmt:formatDate value="${booking.createdAt}" 
                                                                                    pattern="dd/MM/yyyy"/>
                                                                </small>
                                                            </div>
                                                            <div class="col-md-3">
                                                                <strong>Room ${booking.roomNumber}</strong>
                                                                <br>
                                                                <small>${booking.roomTypeName}</small>
                                                            </div>
                                                            <div class="col-md-3">
                                                                <i class="fa fa-calendar-check"></i> 
                                                                <fmt:formatDate value="${booking.checkIn}" pattern="dd/MM/yyyy"/>
                                                                <br>
                                                                <i class="fa fa-calendar-times"></i> 
                                                                <fmt:formatDate value="${booking.checkOut}" pattern="dd/MM/yyyy"/>
                                                            </div>
                                                            <div class="col-md-2">
                                                                <strong class="text-primary">
                                                                    <fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0"/>₫
                                                                </strong>
                                                            </div>
                                                            <div class="col-md-1 text-right">
                                                                <c:choose>
                                                                    <c:when test="${booking.status eq 'CONFIRMED'}">
                                                                        <span class="badge badge-info">Confirmed</span>
                                                                    </c:when>
                                                                    <c:when test="${booking.status eq 'COMPLETED'}">
                                                                        <span class="badge badge-success">Completed</span>
                                                                    </c:when>
                                                                    <c:when test="${booking.status eq 'CANCELLED'}">
                                                                        <span class="badge badge-danger">Cancelled</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge badge-secondary">${booking.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="text-center text-muted py-4">
                                                    <i class="fas fa-calendar-times fa-3x mb-3"></i>
                                                    <p>No booking history found</p>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <hr class="my-4"/>
                                    
                                    <!-- Action Buttons -->
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <a href="${pageContext.request.contextPath}/receptionist/reservations?guestId=${guest.id}" 
                                               class="btn btn-primary">
                                                <i class="fa fa-calendar-plus"></i> New Booking
                                            </a>
                                            <button class="btn btn-warning" data-toggle="modal" data-target="#editGuestModal">
                                                <i class="fa fa-edit"></i> Edit Guest
                                            </button>
                                            <a href="${pageContext.request.contextPath}/receptionist/guests" 
                                               class="btn btn-secondary">
                                                <i class="fa fa-arrow-left"></i> Back to List
                                            </a>
                                            <c:if test="${!isReceptionist}">
                                                <a href="${pageContext.request.contextPath}/admin/customers?action=edit&id=${guest.id}" 
                                                   class="btn btn-warning">
                                                    <i class="fa fa-edit"></i> Edit User
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/customers" 
                                                   class="btn btn-secondary">
                                                    <i class="fa fa-arrow-left"></i> Back to List
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Edit Guest Modal -->
    <div class="modal fade" id="editGuestModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Guest Information</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="editGuestForm">
                    <div class="modal-body">
                        <input type="hidden" id="guestId" value="${guest.id}">
                        
                        <div class="form-group">
                            <label>Full Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="editFullName" 
                                   value="${guest.fullName}" required>
                        </div>
                        
                        <div class="form-group">
                            <label>Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="editEmail" 
                                   value="${guest.email}" required>
                        </div>
                        
                        <div class="form-group">
                            <label>Phone <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control" id="editPhone" 
                                   value="${guest.phone}" required>
                        </div>
                        
                        <div class="form-group">
                            <label>Notes</label>
                            <textarea class="form-control" id="editNotes" rows="3">${guest.notes}</textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
    $(document).ready(function() {
        $('#editGuestForm').submit(function(e) {
            e.preventDefault();
            updateGuestInfo();
        });
    });
    
    function updateGuestInfo() {
        const guestData = {
            id: $('#guestId').val(),
            fullName: $('#editFullName').val(),
            email: $('#editEmail').val(),
            phone: $('#editPhone').val(),
            notes: $('#editNotes').val()
        };
        
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/guests',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                action: 'updateGuest',
                ...guestData
            }),
            success: function(response) {
                if (response.success) {
                    alert('Guest information updated successfully!');
                    $('#editGuestModal').modal('hide');
                    location.reload();
                } else {
                    alert('Error updating guest: ' + (response.message || 'Unknown error'));
                }
            },
            error: function() {
                alert('Error updating guest information. Please try again.');
            }
        });
    }
    </script>