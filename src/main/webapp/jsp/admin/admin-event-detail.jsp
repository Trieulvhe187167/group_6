<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .event-details {
        font-size: 1.1rem;
        line-height: 1.8;
    }
    
    .event-details p {
        margin-bottom: 1rem;
    }
    
    .detail-item {
        margin-bottom: 1.5rem;
    }
    
    .detail-label {
        font-weight: 600;
        color: #495057;
        margin-bottom: 0.5rem;
    }
    
    .status-badge-large {
        font-size: 1rem;
        padding: 0.5rem 1rem;
        border-radius: 25px;
    }
    
    .event-image {
        width: 100%;
        max-height: 400px;
        object-fit: cover;
        border-radius: 8px;
    }
</style>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/events">Event Management</a></li>
            <li class="breadcrumb-item active">Event Details</li>
        </ol>
    </nav>
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>Event Details</h1>
       
            <a href="${pageContext.request.contextPath}/admin/events" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to List
            </a>
        </div>
    </div>
    
    <div class="row">
        <!-- Event Content -->
        <div class="col-md-8">
            <div class="card">
                <div class="card-body">
                    <!-- Title and Status -->
                    <div class="d-flex justify-content-between align-items-start mb-4">
                        <h2 class="mb-0">${event.title}</h2>
                        <div>
                            <c:choose>
                                <c:when test="${event.status == 'SCHEDULED'}">
                                    <span class="badge badge-info status-badge-large">Scheduled</span>
                                </c:when>
                                <c:when test="${event.status == 'ONGOING'}">
                                    <span class="badge badge-warning status-badge-large">Ongoing</span>
                                </c:when>
                                <c:when test="${event.status == 'COMPLETED'}">
                                    <span class="badge badge-success status-badge-large">Completed</span>
                                </c:when>
                                <c:when test="${event.status == 'CANCELLED'}">
                                    <span class="badge badge-secondary status-badge-large">Cancelled</span>
                                </c:when>
                            </c:choose>
                        </div>
                    </div>
                    
                    <!-- Event Image -->
                    <c:if test="${not empty event.imageUrl}">
                        <div class="mb-4">
                            <img src="${pageContext.request.contextPath}/assets/images/uploads/events/${event.imageUrl}" 
                                 alt="${event.title}" class="event-image">
                        </div>
                    </c:if>
                    
                    <!-- Event Details -->
                    <div class="event-details">
                        <!-- Date and Time -->
                        <div class="detail-item">
                            <div class="detail-label">
                                <i class="fas fa-calendar-alt"></i> Date & Time
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <strong>Start:</strong><br>
                                    <fmt:formatDate value="${event.startAt}" pattern="EEEE, dd MMMM yyyy"/><br>
                                    <fmt:formatDate value="${event.startAt}" pattern="HH:mm"/>
                                </div>
                                <div class="col-md-6">
                                    <strong>End:</strong><br>
                                    <fmt:formatDate value="${event.endAt}" pattern="EEEE, dd MMMM yyyy"/><br>
                                    <fmt:formatDate value="${event.endAt}" pattern="HH:mm"/>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Duration -->
                        <div class="detail-item">
                            <div class="detail-label">
                                <i class="fas fa-clock"></i> Duration
                            </div>
                            <div>
                                <c:set var="duration" value="${(event.endAt.time - event.startAt.time) / (1000 * 60)}" />
                                <c:choose>
                                    <c:when test="${duration < 60}">
                                        ${duration} minutes
                                    </c:when>
                                    <c:when test="${duration < 1440}">
                                        <fmt:formatNumber value="${duration / 60}" maxFractionDigits="1"/> hours
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${duration / 1440}" maxFractionDigits="1"/> days
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <!-- Location -->
                        <c:if test="${not empty event.location}">
                            <div class="detail-item">
                                <div class="detail-label">
                                    <i class="fas fa-map-marker-alt"></i> Location
                                </div>
                                <div>${event.location}</div>
                            </div>
                        </c:if>
                        
                        <!-- Description -->
                        <c:if test="${not empty event.description}">
                            <div class="detail-item">
                                <div class="detail-label">
                                    <i class="fas fa-info-circle"></i> Description
                                </div>
                                <div class="text-justify">${event.description}</div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Sidebar -->
        <div class="col-md-4">
            <!-- Event Information -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Event Information</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>ID:</strong> #${event.id}
                    </div>
                    <div class="mb-3">
                        <strong>Status:</strong><br>
                        <c:choose>
                            <c:when test="${event.status == 'SCHEDULED'}">
                                <span class="badge badge-info">Scheduled</span>
                            </c:when>
                            <c:when test="${event.status == 'ONGOING'}">
                                <span class="badge badge-warning">Ongoing</span>
                            </c:when>
                            <c:when test="${event.status == 'COMPLETED'}">
                                <span class="badge badge-success">Completed</span>
                            </c:when>
                            <c:when test="${event.status == 'CANCELLED'}">
                                <span class="badge badge-secondary">Cancelled</span>
                            </c:when>
                        </c:choose>
                    </div>
                    <div class="mb-3">
                        <strong>Created:</strong><br>
                        <fmt:formatDate value="${event.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                    </div>
                    <div class="mb-3">
                        <strong>Updated:</strong><br>
                        <fmt:formatDate value="${event.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                    </div>
                    <c:if test="${not empty event.createdBy}">
                        <div class="mb-3">
                            <strong>Created By:</strong><br>
                            User #${event.createdBy}
                        </div>
                    </c:if>
                </div>
            </div>
            
            <!-- Quick Actions -->
            <div class="card mt-3">
                <div class="card-header">
                    <h5 class="mb-0">Quick Actions</h5>
                </div>
                <div class="card-body">
                    <a href="${pageContext.request.contextPath}/admin/events?action=edit&id=${event.id}" 
                       class="btn btn-warning btn-block">
                        <i class="fas fa-edit"></i> Edit Event
                    </a>
                    
                    <c:choose>
                        <c:when test="${event.status == 'SCHEDULED'}">
                            <form method="post" action="${pageContext.request.contextPath}/admin/events" 
                                  class="mt-2">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="id" value="${event.id}">
                                <button type="submit" class="btn btn-danger btn-block"
                                        onclick="return confirm('Are you sure you want to cancel this event?')">
                                    <i class="fas fa-times-circle"></i> Cancel Event
                                </button>
                            </form>
                        </c:when>
                        <c:when test="${event.status == 'ONGOING'}">
                            <form method="post" action="${pageContext.request.contextPath}/admin/events" 
                                  class="mt-2">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="id" value="${event.id}">
                                <button type="submit" class="btn btn-success btn-block">
                                    <i class="fas fa-check-circle"></i> Mark as Completed
                                </button>
                            </form>
                        </c:when>
                    </c:choose>
                    
                    <button type="button" class="btn btn-danger btn-block mt-2"
                            onclick="confirmDelete()">
                        <i class="fas fa-trash"></i> Delete Event
                    </button>
                    
                    <!-- You can add more actions like duplicate event, send notifications, etc. -->
                </div>
            </div>
            
            <!-- Event Statistics (if applicable) -->
            <!-- <div class="card mt-3">
                <div class="card-header">
                    <h5 class="mb-0">Statistics</h5>
                </div>
                <div class="card-body">
                    <div class="text-center">
                        <h3 class="mb-1">${attendeeCount}</h3>
                        <p class="text-muted mb-0">Registered Attendees</p>
                    </div>
                </div>
            </div> -->
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this event?</p>
                <p class="font-weight-bold">${event.title}</p>
                <p class="text-danger">This action cannot be undone!</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/events" 
                      style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="${event.id}">
                    <button type="submit" class="btn btn-danger">Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function confirmDelete() {
    $('#deleteModal').modal('show');
}

// Auto-update status based on time
$(document).ready(function() {
    var startTime = new Date('${event.startAt}');
    var endTime = new Date('${event.endAt}');
    var currentTime = new Date();
    
    // Show time until event starts/ends
    if ('${event.status}' === 'SCHEDULED' && startTime > currentTime) {
        var timeDiff = startTime - currentTime;
        var days = Math.floor(timeDiff / (1000 * 60 * 60 * 24));
        var hours = Math.floor((timeDiff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        
        if (days > 0) {
            console.log('Event starts in ' + days + ' days and ' + hours + ' hours');
        } else if (hours > 0) {
            console.log('Event starts in ' + hours + ' hours');
        } else {
            console.log('Event starts soon');
        }
    }
});
</script>