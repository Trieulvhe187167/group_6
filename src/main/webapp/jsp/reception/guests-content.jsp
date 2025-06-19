<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h2>Guest Management</h2>
            <p class="text-muted">Manage guest information and history</p>
        </div>
        <div class="col-md-6 text-right">
            <button class="btn btn-primary" data-toggle="modal" data-target="#newGuestModal">
                <i class="fas fa-user-plus"></i> Add New Guest
            </button>
            <button class="btn btn-success" onclick="exportGuests()">
                <i class="fas fa-file-excel"></i> Export
            </button>
        </div>
    </div>
    
    <!-- Statistics -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-users stat-icon text-primary"></i>
                <div class="stat-number">${totalGuests != null ? totalGuests : 0}</div>
                <div class="stat-label">Total Guests</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-user-check stat-icon text-success"></i>
                <div class="stat-number">${activeGuests != null ? activeGuests : 0}</div>
                <div class="stat-label">Active Guests</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-star stat-icon text-warning"></i>
                <div class="stat-number">${vipGuests != null ? vipGuests : 0}</div>
                <div class="stat-label">VIP Members</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-calendar-plus stat-icon text-info"></i>
                <div class="stat-number">${newGuestsThisMonth != null ? newGuestsThisMonth : 0}</div>
                <div class="stat-label">New This Month</div>
            </div>
        </div>
    </div>
    
    <!-- Guest Table -->
    <div class="table-container">
        <h5 class="mb-3">Guest List</h5>
        
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Guest</th>
                        <th>Contact</th>
                        <th>Total Stays</th>
                        <th>Last Visit</th>
                        <th>Total Spent</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty guests}">
                            <c:forEach var="guest" items="${guests}" varStatus="status">
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle bg-info text-white p-2 mr-3" style="width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;">
                                                ${guest.initial}
                                            </div>
                                            <div>
                                                <strong>${guest.fullName}</strong>
                                                <c:if test="${not empty guest.loyaltyStatus}">
                                                    <span class="badge badge-warning ml-2">${guest.loyaltyStatus}</span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <small class="d-block">${guest.email}</small>
                                        <small class="text-muted">${guest.phone}</small>
                                    </td>
                                    <td>
                                        <span class="badge badge-primary">${guest.totalBookings}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${guest.lastVisit != null}">
                                                <fmt:formatDate value="${guest.lastVisit}" pattern="dd/MM/yyyy"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">No visits yet</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${guest.totalSpent}" pattern="#,##0"/>₫
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${guest.status}">
                                                <span class="badge badge-success">Active</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-secondary">Inactive</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/receptionist/guests?action=view&id=${guest.id}" 
                                           class="btn btn-sm btn-info" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <button class="btn btn-sm btn-primary" onclick="createBookingForGuest('${guest.id}')"
                                                title="New Booking">
                                            <i class="fas fa-calendar-plus"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" class="text-center text-muted py-4">
                                    <i class="fas fa-users fa-3x mb-3"></i>
                                    <br>No guests found. 
                                    <c:if test="${totalGuests == 0}">
                                        <br><small>Start by adding your first guest!</small>
                                    </c:if>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- New Guest Modal -->
<div class="modal fade" id="newGuestModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add New Guest</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="newGuestForm">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Full Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="fullName" required 
                               placeholder="Enter guest's full name">
                    </div>
                    <div class="form-group">
                        <label>Email <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="email" required
                               placeholder="Enter email address">
                    </div>
                    <div class="form-group">
                        <label>Phone <span class="text-danger">*</span></label>
                        <input type="tel" class="form-control" id="phone" required
                               placeholder="Enter phone number">
                    </div>
                    <div class="form-group">
                        <label>Notes</label>
                        <textarea class="form-control" id="notes" rows="2" 
                                  placeholder="Any special notes about this guest..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-user-plus"></i> Add Guest
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('#newGuestForm').submit(function(e) {
        e.preventDefault();
        createNewGuest();
    });
});

function createNewGuest() {
    // Validate form
    if (!$('#fullName').val().trim() || !$('#email').val().trim() || !$('#phone').val().trim()) {
        alert('Please fill in all required fields');
        return;
    }
    
    const guestData = {
        action: 'createGuest',
        fullName: $('#fullName').val().trim(),
        email: $('#email').val().trim(),
        phone: $('#phone').val().trim(),
        notes: $('#notes').val().trim()
    };
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/guests',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(guestData),
        success: function(response) {
            if (response.success) {
                alert('Guest added successfully!');
                $('#newGuestModal').modal('hide');
                $('#newGuestForm')[0].reset();
                location.reload();
            } else {
                alert('Error adding guest: ' + (response.message || 'Unknown error'));
            }
        },
        error: function(xhr) {
            if (xhr.status === 409) {
                alert('Guest with this email or phone already exists!');
            } else {
                alert('Error adding guest. Please try again.');
            }
        }
    });
}

function createBookingForGuest(guestId) {
    window.location.href = '${pageContext.request.contextPath}/receptionist/reservations?guestId=' + guestId;
}

function exportGuests() {
    window.location.href = '${pageContext.request.contextPath}/receptionist/guests?action=exportGuests';
}
</script>