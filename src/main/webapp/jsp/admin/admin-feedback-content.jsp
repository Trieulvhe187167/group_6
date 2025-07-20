<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center">
                <h2><i class="fas fa-comments"></i> Feedback Management</h2>
                <div>
                    <a href="${pageContext.request.contextPath}/admin-dashboard" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-primary">
                    <i class="fas fa-comments"></i>
                </div>
                <div class="stat-number">${totalFeedbacks}</div>
                <div class="stat-label">Total Feedback</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-success">
                    <i class="fas fa-eye"></i>
                </div>
                <div class="stat-number">${activeFeedbacks}</div>
                <div class="stat-label">Active Feedback</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-warning">
                    <i class="fas fa-eye-slash"></i>
                </div>
                <div class="stat-number">${disabledFeedbacks}</div>
                <div class="stat-label">Disabled Feedback</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-info">
                    <i class="fas fa-star"></i>
                </div>
                <div class="stat-number">${averageRating}</div>
                <div class="stat-label">Average Rating</div>
            </div>
        </div>
    </div>

    <!-- Filter Section -->
    <div class="card mb-4">
        <div class="card-header">
            <h5 class="mb-0"><i class="fas fa-filter"></i> Filters</h5>
        </div>
        <div class="card-body">
            <form method="GET" action="${pageContext.request.contextPath}/admin/feedback">
                <div class="row">
                    <div class="col-md-3">
                        <label for="statusFilter" class="form-label">Status</label>
                        <select class="form-control" id="statusFilter" name="status">
                            <option value="">All Status</option>
                            <option value="active" ${param.status == 'active' ? 'selected' : ''}>Active</option>
                            <option value="disabled" ${param.status == 'disabled' ? 'selected' : ''}>Disabled</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="ratingFilter" class="form-label">Rating</label>
                        <select class="form-control" id="ratingFilter" name="rating">
                            <option value="">All Ratings</option>
                            <option value="5" ${param.rating == '5' ? 'selected' : ''}>5 Stars</option>
                            <option value="4" ${param.rating == '4' ? 'selected' : ''}>4 Stars</option>
                            <option value="3" ${param.rating == '3' ? 'selected' : ''}>3 Stars</option>
                            <option value="2" ${param.rating == '2' ? 'selected' : ''}>2 Stars</option>
                            <option value="1" ${param.rating == '1' ? 'selected' : ''}>1 Star</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="dateFrom" class="form-label">From Date</label>
                        <input type="date" class="form-control" id="dateFrom" name="dateFrom" value="${param.dateFrom}">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">&nbsp;</label>
                        <div>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search"></i> Filter
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/feedback" class="btn btn-outline-secondary">
                                <i class="fas fa-times"></i> Clear
                            </a>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Feedback Table -->
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="fas fa-list"></i> Customer Feedbacks</h5>
            <div>
                <button class="btn btn-success" onclick="exportFeedbacks()">
                    <i class="fas fa-download"></i> Export
                </button>
            </div>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${empty feedbacks}">
                    <div class="text-center py-5">
                        <i class="fas fa-comments fa-3x text-muted mb-3"></i>
                        <h4 class="text-muted">No Feedback Found</h4>
                        <p class="text-muted">There are no feedback submissions to display.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover" id="feedbackTable">
                            <thead class="thead-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Customer</th>
                                    <th>Rating</th>
                                    <th>Comment</th>
                                    <th>Reservation</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="feedback" items="${feedbacks}">
                                    <tr class="${feedback.disabled ? 'table-secondary' : ''}">
                                        <td>
                                            <span class="badge badge-primary">#${feedback.id}</span>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="avatar-sm me-2">
                                                    <i class="fas fa-user-circle fa-2x text-muted"></i>
                                                </div>
                                                <div>
                                                    <strong>${feedback.userFullName}</strong>
                                                    <br>
                                                    <small class="text-muted">ID: ${feedback.userId}</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="me-2">
                                                    <c:forEach begin="1" end="5" var="i">
                                                        <i class="fas fa-star ${i <= feedback.rating ? 'text-warning' : 'text-muted'}"></i>
                                                    </c:forEach>
                                                </div>
                                                <span class="badge badge-warning text-dark">${feedback.rating}/5</span>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="feedback-comment">
                                                <div class="text-truncate" style="max-width: 200px;" title="${feedback.comment}">
                                                    ${feedback.comment}
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge badge-info">#${feedback.reservationId}</span>
                                        </td>
                                        <td>
                                            <div class="text-muted">
                                                <fmt:formatDate value="${feedback.createdAt}" pattern="MMM dd, yyyy"/>
                                                <br>
                                                <small><fmt:formatDate value="${feedback.createdAt}" pattern="HH:mm"/></small>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge badge-success">
                                                <i class="fas fa-eye"></i> Active
                                            </span>
                                        </td>
                                        <td>
                                            <div class="btn-group" role="group">
                                                <button class="btn btn-sm btn-outline-primary view-detail-btn" 
                                                        data-id="${feedback.id}"
                                                        data-name="${feedback.userFullName}"
                                                        data-rating="${feedback.rating}"
                                                        data-comment="${feedback.comment}"
                                                        data-created="${feedback.createdAt}"
                                                        data-userid="${feedback.userId}"
                                                        data-reservationid="${feedback.reservationId}"
                                                        data-disabled="${feedback.disabled}"
                                                        title="View Details">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <!-- Enable/Disable buttons removed since no Disabled column in database -->
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Feedback Detail Modal -->
<div class="modal fade" id="feedbackDetailModal" tabindex="-1" aria-labelledby="feedbackDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="feedbackDetailModalLabel">
                    <i class="fas fa-comment-dots"></i> Feedback Details
                </h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-8">
                        <div class="mb-3">
                            <label class="form-label"><strong>Customer:</strong></label>
                            <p id="modalCustomerName" class="mb-0"></p>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><strong>Rating:</strong></label>
                            <div class="d-flex align-items-center">
                                <div id="modalRatingStars" class="me-2"></div>
                                <span id="modalRatingBadge" class="badge badge-warning text-dark"></span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><strong>Comment:</strong></label>
                            <p id="modalComment" class="mb-0"></p>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><strong>Date:</strong></label>
                            <p id="modalDate" class="mb-0"></p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-light">
                            <div class="card-body text-center">
                                <div class="mb-3">
                                    <div class="display-4 text-primary" id="modalDateNumber"></div>
                                    <div class="text-muted" id="modalDateMonth"></div>
                                </div>
                                <div class="mb-3">
                                    <div class="h4 text-warning" id="modalRatingNumber"></div>
                                    <div class="text-muted">Stars</div>
                                </div>
                                <div class="mb-3">
                                    <a href="#" id="modalCustomerProfile" class="btn btn-outline-primary btn-sm">
                                        <i class="fas fa-user"></i> View Profile
                                    </a>
                                </div>
                                <div>
                                    <a href="#" id="modalReservation" class="btn btn-outline-info btn-sm">
                                        <i class="fas fa-calendar"></i> View Reservation
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <hr>
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-2">
                            <label class="form-label"><strong>User ID:</strong></label>
                            <span id="modalUserId"></span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-2">
                            <label class="form-label"><strong>Reservation ID:</strong></label>
                            <span id="modalReservationId"></span>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-2">
                            <label class="form-label"><strong>Status:</strong></label>
                            <span id="modalStatus"></span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-info" onclick="exportFeedback()">
                    <i class="fas fa-download"></i> Export
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Confirmation Modal -->
<div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="confirmModalLabel">Confirm Action</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p id="confirmMessage"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="confirmActionBtn">Confirm</button>
            </div>
        </div>
    </div>
</div>

<script>
let currentFeedbackId = null;
let currentFeedbackDisabled = false;

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM is ready, initializing admin feedback system...');
    initializeAdminFeedbackSystem();
});

function initializeAdminFeedbackSystem() {
    // Check if jQuery is available
    if (typeof $ === 'undefined') {
        console.error('jQuery is not available, using vanilla JavaScript');
        initializeWithVanillaJS();
        return;
    }
    
    console.log('jQuery is available, using jQuery');
    
    // Initialize DataTable
    $('#feedbackTable').DataTable({
        responsive: true,
        order: [[0, 'desc']],
        pageLength: 10,
        language: {
            search: "Search feedbacks:",
            lengthMenu: "Show _MENU_ feedbacks per page",
            info: "Showing _START_ to _END_ of _TOTAL_ feedbacks",
            paginate: {
                first: "First",
                last: "Last",
                next: "Next",
                previous: "Previous"
            }
        }
    });

    // Event listeners for buttons
    $(document).on('click', '.view-detail-btn', function(e) {
        e.preventDefault();
        console.log('View detail button clicked');
        const btn = $(this);
        const id = btn.data('id');
        const name = btn.data('name');
        const rating = btn.data('rating');
        const comment = btn.data('comment');
        const created = btn.data('created');
        const userid = btn.data('userid');
        const reservationid = btn.data('reservationid');
        const disabled = btn.data('disabled');
        
        console.log('Data:', {id, name, rating, comment, created, userid, reservationid, disabled});
        
        viewFeedbackDetail(id, name, rating, comment, created, userid, reservationid, disabled);
    });
    
    $(document).on('click', '.disable-btn', function(e) {
        e.preventDefault();
        console.log('Disable button clicked');
        const btn = $(this);
        const id = btn.data('id');
        const name = btn.data('name');
        
        showConfirmModal('disable', id, name);
    });
    
    $(document).on('click', '.enable-btn', function(e) {
        e.preventDefault();
        console.log('Enable button clicked');
        const btn = $(this);
        const id = btn.data('id');
        const name = btn.data('name');
        
        showConfirmModal('enable', id, name);
    });
}

function initializeWithVanillaJS() {
    console.log('Initializing with vanilla JavaScript');
    
    // Add event listeners for buttons
    document.addEventListener('click', function(e) {
        if (e.target.closest('.view-detail-btn')) {
            e.preventDefault();
            console.log('View detail button clicked (vanilla JS)');
            const btn = e.target.closest('.view-detail-btn');
            const id = btn.dataset.id;
            const name = btn.dataset.name;
            const rating = btn.dataset.rating;
            const comment = btn.dataset.comment;
            const created = btn.dataset.created;
            const userid = btn.dataset.userid;
            const reservationid = btn.dataset.reservationid;
            const disabled = btn.dataset.disabled;
            
            viewFeedbackDetail(id, name, rating, comment, created, userid, reservationid, disabled);
        }
        
        // Enable/Disable buttons removed since no Disabled column in database
    });
}

// View feedback detail
function viewFeedbackDetail(id, customerName, rating, comment, createdAt, userId, reservationId, disabled) {
    currentFeedbackId = id;
    currentFeedbackDisabled = false; // Always false since no Disabled column
    
    // Set modal content
    document.getElementById('modalCustomerName').textContent = customerName;
    document.getElementById('modalUserId').textContent = userId;
    document.getElementById('modalReservationId').textContent = reservationId;
    document.getElementById('modalComment').textContent = comment;
    document.getElementById('modalRatingBadge').textContent = rating + '/5 Stars';
    document.getElementById('modalRatingNumber').textContent = rating;
    
    // Set status (always active)
    const statusElement = document.getElementById('modalStatus');
    statusElement.innerHTML = '<span class="badge badge-success"><i class="fas fa-eye"></i> Active</span>';
    
    // Set rating stars
    const starsContainer = document.getElementById('modalRatingStars');
    starsContainer.innerHTML = '';
    for (let i = 1; i <= 5; i++) {
        const star = document.createElement('i');
        star.className = i <= rating ? 'fas fa-star' : 'far fa-star';
        star.style.color = '#ffc107';
        star.style.fontSize = '1.5rem';
        starsContainer.appendChild(star);
    }
    
    // Set date
    const date = new Date(createdAt);
    document.getElementById('modalDate').textContent = date.toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
    document.getElementById('modalDateNumber').textContent = date.getDate();
    document.getElementById('modalDateMonth').textContent = date.toLocaleDateString('en-US', { month: 'short' });
    
    // Set quick action links
    document.getElementById('modalCustomerProfile').href = 
        '${pageContext.request.contextPath}/admin/customers?action=view&id=' + userId;
    document.getElementById('modalReservation').href = 
        '${pageContext.request.contextPath}/admin/bookings?action=view&id=' + reservationId;
    
    // Show modal
    $('#feedbackDetailModal').modal('show');
}

// Enable/Disable functions removed since no Disabled column in database

// Export feedbacks
function exportFeedbacks() {
    const table = document.getElementById('feedbackTable');
    const rows = table.querySelectorAll('tbody tr');
    
    let csv = 'ID,Customer,Rating,Comment,Reservation,Date,Status\n';
    
    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        const id = cells[0].textContent.trim();
        const customer = cells[1].querySelector('strong').textContent.trim();
        const rating = cells[2].querySelector('.badge').textContent.trim();
        const comment = cells[3].querySelector('.text-truncate').textContent.trim();
        const reservation = cells[4].textContent.trim();
        const date = cells[5].textContent.trim();
        const status = cells[6].textContent.trim();
        
        csv += `"${id}","${customer}","${rating}","${comment}","${reservation}","${date}","${status}"\n`;
    });
    
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'feedbacks-export.csv';
    a.click();
    window.URL.revokeObjectURL(url);
}

// Export single feedback
function exportFeedback() {
    const feedbackData = {
        id: currentFeedbackId,
        customer: document.getElementById('modalCustomerName').textContent,
        rating: document.getElementById('modalRatingNumber').textContent,
        comment: document.getElementById('modalComment').textContent,
        date: document.getElementById('modalDate').textContent,
        status: 'Active' // Always active since no Disabled column
    };
    
    const dataStr = JSON.stringify(feedbackData, null, 2);
    const dataBlob = new Blob([dataStr], {type: 'application/json'});
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'feedback-' + currentFeedbackId + '.json';
    link.click();
}
</script> 