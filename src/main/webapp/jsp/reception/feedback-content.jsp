<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- Statistics Cards -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card bg-primary text-white">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h4 class="card-title">${totalFeedbacks}</h4>
                        <p class="card-text">Total Feedbacks</p>
                    </div>
                    <div class="align-self-center">
                        <i class="fas fa-comments fa-2x"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-success text-white">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h4 class="card-title">${averageRating}</h4>
                        <p class="card-text">Average Rating</p>
                    </div>
                    <div class="align-self-center">
                        <i class="fas fa-star fa-2x"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-warning text-white">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h4 class="card-title">${recentFeedbacks}</h4>
                        <p class="card-text">Recent (7 days)</p>
                    </div>
                    <div class="align-self-center">
                        <i class="fas fa-clock fa-2x"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-info text-white">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h4 class="card-title">${pendingReplies}</h4>
                        <p class="card-text">Pending Replies</p>
                    </div>
                    <div class="align-self-center">
                        <i class="fas fa-reply fa-2x"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Filters -->
<div class="row mb-4">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-filter"></i> Filters</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3">
                        <label for="ratingFilter" class="form-label">Rating</label>
                        <select class="form-select" id="ratingFilter">
                            <option value="">All Ratings</option>
                            <option value="5">5 Stars</option>
                            <option value="4">4 Stars</option>
                            <option value="3">3 Stars</option>
                            <option value="2">2 Stars</option>
                            <option value="1">1 Star</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="dateFilter" class="form-label">Date</label>
                        <input type="date" class="form-control" id="dateFilter">
                    </div>
                    <div class="col-md-3">
                        <label for="statusFilter" class="form-label">Status</label>
                        <select class="form-select" id="statusFilter">
                            <option value="">All Status</option>
                            <option value="new">New</option>
                            <option value="replied">Replied</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">&nbsp;</label>
                        <div>
                            <button class="btn btn-primary" onclick="applyFilters()">
                                <i class="fas fa-search"></i> Apply Filters
                            </button>
                            <button class="btn btn-secondary" onclick="clearFilters()">
                                <i class="fas fa-times"></i> Clear
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Feedback List -->
<div class="row">
    <div class="col-md-12">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="fas fa-list"></i> Customer Feedbacks</h5>
                <div>
                    <button class="btn btn-success" onclick="exportFeedback()">
                        <i class="fas fa-download"></i> Export
                    </button>
                </div>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover" id="feedbackTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Customer</th>
                                <th>Rating</th>
                                <th>Comment</th>
                                <th>Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="feedback" items="${feedbacks}">
                                <tr>
                                    <td>
                                        <span class="badge bg-primary">#${feedback.id}</span>
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
                                            <span class="badge bg-warning text-dark">${feedback.rating}/5</span>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${feedback.disabled}">
                                                <span class="text-muted fst-italic">This feedback has been hidden by admin.</span>
                                            </c:when>
                                            <c:otherwise>
                                                ${feedback.comment}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="text-muted">
                                            <fmt:formatDate value="${feedback.createdAt}" pattern="MMM dd, yyyy"/>
                                            <br>
                                            <small><fmt:formatDate value="${feedback.createdAt}" pattern="HH:mm"/></small>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <button class="btn btn-sm btn-primary view-detail-btn" 
                                                    data-id="${feedback.id}"
                                                    data-name="${feedback.userFullName}"
                                                    data-rating="${feedback.rating}"
                                                    data-comment="${feedback.comment}"
                                                    data-created="${feedback.createdAt}"
                                                    data-userid="${feedback.userId}"
                                                    data-reservationid="${feedback.reservationId}"
                                                    data-disabled="${feedback.disabled}">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button class="btn btn-sm btn-success reply-btn"
                                                    data-id="${feedback.id}"
                                                    data-name="${feedback.userFullName}"
                                                    data-email="${feedback.userEmail}">
                                                <i class="fas fa-reply"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
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
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <c:if test="${feedback.disabled}">
                    <div class="alert alert-warning">
                        This feedback has been hidden by admin and cannot be viewed in detail.
                    </div>
                </c:if>
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
                                <span id="modalRatingBadge" class="badge bg-warning text-dark"></span>
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
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-success" onclick="showContactFormFromModal()">
                    <i class="fas fa-reply"></i> Reply
                </button>
                <button type="button" class="btn btn-info" onclick="exportFeedback()">
                    <i class="fas fa-download"></i> Export
                </button>
                <button type="button" class="btn btn-warning" onclick="printFeedback()">
                    <i class="fas fa-print"></i> Print
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Contact Form Modal -->
<div class="modal fade" id="contactFormModal" tabindex="-1" aria-labelledby="contactFormModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="contactFormModalLabel">
                    <i class="fas fa-envelope"></i> Send Message to Customer
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label"><strong>Customer:</strong></label>
                        <p id="contactCustomerName" class="mb-0"></p>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label"><strong>Email:</strong></label>
                        <p id="contactCustomerEmail" class="mb-0"></p>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label"><strong>Feedback ID:</strong></label>
                        <p id="contactFeedbackId" class="mb-0"></p>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label"><strong>Date:</strong></label>
                        <p id="contactCurrentDate" class="mb-0"></p>
                    </div>
                </div>
                <hr>
                <form id="contactForm">
                    <input type="hidden" id="contactFormFeedbackId" name="feedbackId">
                    <input type="hidden" id="contactFormCustomerEmail" name="customerEmail">
                    <input type="hidden" id="contactFormCustomerName" name="customerName">
                    <input type="hidden" name="action" value="sendMessage">
                    
                    <div class="mb-3">
                        <label for="contactSubject" class="form-label">Subject *</label>
                        <input type="text" class="form-control" id="contactSubject" name="subject" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="contactMessage" class="form-label">Message *</label>
                        <textarea class="form-control" id="contactMessage" name="message" rows="8" required 
                                  maxlength="1000" oninput="updateCharCount(this)" onkeydown="limitInput(event, this)"></textarea>
                        <div class="d-flex justify-content-between mt-2">
                            <small class="text-muted">
                                Characters: <span id="contactCharCount">0</span>/1000
                            </small>
                            <div class="progress" style="width: 60%; height: 20px;">
                                <div id="contactProgressBar" class="progress-bar bg-success" style="width: 0%"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Quick Templates:</label>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-outline-primary btn-sm" onclick="useTemplate('thank_you')">
                                Thank You
                            </button>
                            <button type="button" class="btn btn-outline-warning btn-sm" onclick="useTemplate('apology')">
                                Apology
                            </button>
                            <button type="button" class="btn btn-outline-info btn-sm" onclick="useTemplate('follow_up')">
                                Follow Up
                            </button>
                            <button type="button" class="btn btn-outline-success btn-sm" onclick="useTemplate('improvement')">
                                Improvement
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-info" onclick="previewContactMessage()">
                    <i class="fas fa-eye"></i> Preview
                </button>
                <button type="submit" form="contactForm" class="btn btn-primary">
                    <i class="fas fa-paper-plane"></i> Send Message
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Preview Modal -->
<div class="modal fade" id="previewModal" tabindex="-1" aria-labelledby="previewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="previewModalLabel">
                    <i class="fas fa-eye"></i> Message Preview
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label"><strong>To:</strong></label>
                    <p id="previewCustomerName" class="mb-0"></p>
                </div>
                <div class="mb-3">
                    <label class="form-label"><strong>Subject:</strong></label>
                    <p id="previewSubject" class="mb-0"></p>
                </div>
                <hr>
                <div class="mb-3">
                    <label class="form-label"><strong>Message:</strong></label>
                    <div id="previewMessage" class="border p-3 bg-light rounded"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="sendContactMessage()">
                    <i class="fas fa-paper-plane"></i> Send Message
                </button>
            </div>
        </div>
    </div>
</div>

<script>
let currentFeedbackId = null;
let currentCustomerName = null;

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM is ready, initializing feedback system...');
    initializeFeedbackSystem();
});

function initializeFeedbackSystem() {
    // Check if jQuery is available
    if (typeof $ === 'undefined') {
        console.error('jQuery is not available, using vanilla JavaScript');
        initializeWithVanillaJS();
        return;
    }
    
    console.log('jQuery is available, using jQuery');
    
    // Set filter values from URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const ratingFilter = urlParams.get('rating');
    const dateFilter = urlParams.get('date');
    
    if (ratingFilter) {
        $('#ratingFilter').val(ratingFilter);
    }
    if (dateFilter) {
        $('#dateFilter').val(dateFilter);
    }

    // Filter functionality
    $('#ratingFilter, #dateFilter').on('change', function() {
        applyFilters();
    });

    // Contact form submission
    $('#contactForm').on('submit', function(e) {
        e.preventDefault();
        sendContactMessage();
    });
    
    // Debug: Check if buttons exist
    console.log('View detail buttons found:', $('.view-detail-btn').length);
    console.log('Reply buttons found:', $('.reply-btn').length);
    console.log('Test view buttons found:', $('.test-view-btn').length);
    console.log('Test reply buttons found:', $('.test-reply-btn').length);
    
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
    
    $(document).on('click', '.reply-btn', function(e) {
        e.preventDefault();
        console.log('Reply button clicked');
        const btn = $(this);
        const id = btn.data('id');
        const name = btn.data('name');
        const email = btn.data('email');
        
        console.log('Data:', {id, name, email});
        
        showContactForm(id, name, email);
    });
    
    // Test button event listeners
    $(document).on('click', '.test-view-btn', function(e) {
        e.preventDefault();
        console.log('Test view button clicked');
        const btn = $(this);
        viewFeedbackDetail(
            btn.data('id'),
            btn.data('name'),
            btn.data('rating'),
            btn.data('comment'),
            btn.data('created'),
            btn.data('userid'),
            btn.data('reservationid')
        );
    });
    
    $(document).on('click', '.test-reply-btn', function(e) {
        e.preventDefault();
        console.log('Test reply button clicked');
        const btn = $(this);
        showContactForm(
            btn.data('id'),
            btn.data('name'),
            btn.data('email')
        );
    });
}

// Vanilla JavaScript initialization
function initializeWithVanillaJS() {
    console.log('Initializing with vanilla JavaScript...');
    
    // Debug: Check if buttons exist
    console.log('View detail buttons found:', document.querySelectorAll('.view-detail-btn').length);
    console.log('Reply buttons found:', document.querySelectorAll('.reply-btn').length);
    console.log('Test view buttons found:', document.querySelectorAll('.test-view-btn').length);
    console.log('Test reply buttons found:', document.querySelectorAll('.test-reply-btn').length);
    
    // Event listeners for buttons using vanilla JavaScript
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('view-detail-btn')) {
            e.preventDefault();
            console.log('View detail button clicked (vanilla JS)');
            const btn = e.target;
            const id = btn.dataset.id;
            const name = btn.dataset.name;
            const rating = btn.dataset.rating;
            const comment = btn.dataset.comment;
            const created = btn.dataset.created;
            const userid = btn.dataset.userid;
            const reservationid = btn.dataset.reservationid;
            const disabled = btn.dataset.disabled;
            
            console.log('Data:', {id, name, rating, comment, created, userid, reservationid, disabled});
            
            viewFeedbackDetail(id, name, rating, comment, created, userid, reservationid, disabled);
        }
        
        if (e.target.classList.contains('reply-btn')) {
            e.preventDefault();
            console.log('Reply button clicked (vanilla JS)');
            const btn = e.target;
            const id = btn.dataset.id;
            const name = btn.dataset.name;
            const email = btn.dataset.email;
            
            console.log('Data:', {id, name, email});
            
            showContactForm(id, name, email);
        }
        
        if (e.target.classList.contains('test-view-btn')) {
            e.preventDefault();
            console.log('Test view button clicked (vanilla JS)');
            const btn = e.target;
            viewFeedbackDetail(
                btn.dataset.id,
                btn.dataset.name,
                btn.dataset.rating,
                btn.dataset.comment,
                btn.dataset.created,
                btn.dataset.userid,
                btn.dataset.reservationid
            );
        }
        
        if (e.target.classList.contains('test-reply-btn')) {
            e.preventDefault();
            console.log('Test reply button clicked (vanilla JS)');
            const btn = e.target;
            showContactForm(
                btn.dataset.id,
                btn.dataset.name,
                btn.dataset.email
            );
        }
    });
    
    // Contact form submission
    const contactForm = document.getElementById('contactForm');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            sendContactMessage();
        });
    }
}

// View feedback detail
function viewFeedbackDetail(id, customerName, rating, comment, createdAt, userId, reservationId, disabled) {
    currentFeedbackId = id;
    currentCustomerName = customerName;
    
    // Set modal content
    document.getElementById('modalCustomerName').textContent = customerName;
    document.getElementById('modalUserId').textContent = userId;
    document.getElementById('modalReservationId').textContent = reservationId;
    if (disabled === true || disabled === 'true') {
        document.getElementById('modalComment').textContent = 'This feedback has been hidden by admin and cannot be viewed in detail.';
    } else {
        document.getElementById('modalComment').textContent = comment;
    }
    document.getElementById('modalRatingBadge').textContent = rating + '/5 Stars';
    document.getElementById('modalRatingNumber').textContent = rating;
    
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
        '${pageContext.request.contextPath}/receptionist/customers?action=view&id=' + userId;
    document.getElementById('modalReservation').href = 
        '${pageContext.request.contextPath}/receptionist/reservations?action=view&id=' + reservationId;
    
    // Show modal
    new bootstrap.Modal(document.getElementById('feedbackDetailModal')).show();
}

// Show contact form
function showContactForm(feedbackId, customerName, customerEmail) {
    currentFeedbackId = feedbackId;
    currentCustomerName = customerName;
    
    // Set form data
    document.getElementById('contactCustomerName').textContent = customerName;
    // Only show email if it's actually an email, otherwise show "No email available"
    const displayEmail = (customerEmail && customerEmail.includes('@')) ? customerEmail : 'No email available';
    document.getElementById('contactCustomerEmail').textContent = displayEmail;
    document.getElementById('contactFeedbackId').textContent = feedbackId;
    document.getElementById('contactCurrentDate').textContent = new Date().toLocaleDateString();
    
    document.getElementById('contactFormFeedbackId').value = feedbackId;
    document.getElementById('contactFormCustomerEmail').value = customerEmail || '';
    document.getElementById('contactFormCustomerName').value = customerName;
    
    // Reset form
    resetContactForm();
    
    // Show modal
    new bootstrap.Modal(document.getElementById('contactFormModal')).show();
}

// Show contact form from detail modal
function showContactFormFromModal() {
    bootstrap.Modal.getInstance(document.getElementById('feedbackDetailModal')).hide();
    // Get email from the current feedback data
    const currentEmail = document.getElementById('contactFormCustomerEmail').value || currentCustomerName;
    showContactForm(currentFeedbackId, currentCustomerName, currentEmail);
}

// Message templates
function getTemplateMessage(templateKey, customerName) {
    const messages = {
        thank_you: 'Dear ' + customerName + ',\n\nThank you for taking the time to share your feedback with us. We truly appreciate your input and value your experience at our hotel.\n\nYour feedback helps us improve our services and ensure that all our guests have the best possible stay.\n\nWe look forward to welcoming you back in the future.\n\nBest regards,\nLuxury Hotel Team',
        apology: 'Dear ' + customerName + ',\n\nWe sincerely apologize for the issues you experienced during your stay. Your feedback is important to us, and we take all concerns seriously.\n\nWe are reviewing your feedback and taking steps to address the issues you mentioned.\n\nPlease know that we value your business and hope to provide you with a much better experience in the future.\n\nBest regards,\nLuxury Hotel Team',
        follow_up: 'Dear ' + customerName + ',\n\nThank you for your recent feedback. We wanted to follow up and let you know that we have reviewed your comments and are taking action to address the concerns you raised.\n\nWe appreciate your patience and understanding as we work to improve our services.\n\nIf you have any additional questions, please don\'t hesitate to contact us.\n\nBest regards,\nLuxury Hotel Team',
        improvement: 'Dear ' + customerName + ',\n\nThank you for your valuable feedback. We are always looking for ways to improve our services, and your input helps us identify areas where we can do better.\n\nWe have shared your comments with our team and are implementing changes based on your suggestions.\n\nWe hope to see you again soon and provide you with an even better experience.\n\nBest regards,\nLuxury Hotel Team'
    };
    return messages[templateKey] || '';
}

function getTemplateSubject(templateKey) {
    const subjects = {
        thank_you: 'Thank You for Your Feedback',
        apology: 'We Apologize for Your Experience',
        follow_up: 'Follow-up on Your Feedback',
        improvement: 'Your Feedback Helps Us Improve'
    };
    return subjects[templateKey] || '';
}

function useTemplate(templateKey) {
    document.getElementById('contactSubject').value = getTemplateSubject(templateKey);
    document.getElementById('contactMessage').value = getTemplateMessage(templateKey, currentCustomerName);
    
    // Trigger character count update
    document.getElementById('contactMessage').dispatchEvent(new Event('input'));
}

function resetContactForm() {
    document.getElementById('contactForm').reset();
    document.getElementById('contactCharCount').textContent = '0';
    document.getElementById('contactProgressBar').style.width = '0%';
    document.getElementById('contactProgressBar').className = 'progress-bar bg-success';
}

function updateCharCount(textarea) {
    const count = textarea.value.length;
    const maxLength = 1000;
    document.getElementById('contactCharCount').textContent = count;
    
    const progressBar = document.getElementById('contactProgressBar');
    const percentage = Math.min((count / maxLength) * 100, 100);
    progressBar.style.width = percentage + '%';
    
    if (count > 800) {
        progressBar.className = 'progress-bar bg-danger';
    } else if (count > 600) {
        progressBar.className = 'progress-bar bg-warning';
    } else {
        progressBar.className = 'progress-bar bg-success';
    }
}

function limitInput(event, textarea) {
    const maxLength = 1000;
    const currentLength = textarea.value.length;
    
    // Allow backspace, delete, arrow keys, etc.
    const allowedKeys = [8, 9, 13, 16, 17, 18, 19, 20, 27, 33, 34, 35, 36, 37, 38, 39, 40, 45, 46];
    
    if (allowedKeys.includes(event.keyCode)) {
        return true;
    }
    
    // If we're at the limit and trying to type more, prevent it
    if (currentLength >= maxLength && event.keyCode !== 8) {
        event.preventDefault();
        return false;
    }
    
    return true;
}

function previewContactMessage() {
    const subject = document.getElementById('contactSubject').value;
    const message = document.getElementById('contactMessage').value;
    
    if (!subject || !message) {
        alert('Please fill in both subject and message before previewing.');
        return;
    }
    
    document.getElementById('previewCustomerName').textContent = currentCustomerName;
    document.getElementById('previewSubject').textContent = subject;
    document.getElementById('previewMessage').innerHTML = message.replace(/\n/g, '<br>');
    
    new bootstrap.Modal(document.getElementById('previewModal')).show();
}

function sendContactMessage() {
    const form = document.getElementById('contactForm');
    const formData = new FormData(form);
    // Debug: Log toàn bộ dữ liệu form trước khi gửi
    console.log('=== Dữ liệu gửi đi ===');
    for (let [key, value] of formData.entries()) {
        console.log(key + ':', value);
    }
    fetch('${pageContext.request.contextPath}/receptionist/feedback', {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (response.ok) {
            alert('Message sent successfully!');
            const contactModal = bootstrap.Modal.getInstance(document.getElementById('contactFormModal'));
            if (contactModal) contactModal.hide();
            const previewModal = bootstrap.Modal.getInstance(document.getElementById('previewModal'));
            if (previewModal) previewModal.hide();
        } else {
            alert('Failed to send message. Please try again.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred while sending the message.');
    });
}

function applyFilters() {
    const rating = document.getElementById('ratingFilter').value;
    const date = document.getElementById('dateFilter').value;
    const status = document.getElementById('statusFilter').value;
    
    let url = '${pageContext.request.contextPath}/receptionist/feedback?';
    if (rating) url += 'rating=' + rating + '&';
    if (date) url += 'date=' + date + '&';
    if (status) url += 'status=' + status + '&';
    
    window.location.href = url;
}

function clearFilters() {
    window.location.href = '${pageContext.request.contextPath}/receptionist/feedback';
}

function exportFeedback() {
    const feedbackData = {
        id: currentFeedbackId,
        customer: currentCustomerName,
        rating: document.getElementById('modalRatingNumber').textContent,
        comment: document.getElementById('modalComment').textContent,
        date: document.getElementById('modalDate').textContent
    };
    
    const dataStr = JSON.stringify(feedbackData, null, 2);
    const dataBlob = new Blob([dataStr], {type: 'application/json'});
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'feedback-' + currentFeedbackId + '.json';
    link.click();
}

function printFeedback() {
    window.print();
}
</script> 

<!-- Đặt đoạn này ở cuối file, sau khi đã import xong DataTables JS -->
<script>
$(document).ready(function() {
    initializeAdminFeedbackSystem();
});

function initializeAdminFeedbackSystem() {
    if (typeof $ === 'undefined') {
        console.error('jQuery is not loaded!');
        return;
    }
    if (!$.fn.DataTable) {
        console.error('DataTables plugin is not loaded!');
        return;
    }
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
}
</script> 
