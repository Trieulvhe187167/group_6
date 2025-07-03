<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .filter-form {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 15px;
    }
    
    .filter-group {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        align-items: center;
        flex: 1;
    }
    
    .form-group {
        margin-bottom: 0 !important;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .form-group label {
        margin-bottom: 0;
        white-space: nowrap;
    }
    
    .status-badge {
        font-size: 0.875rem;
        padding: 0.25rem 0.75rem;
        border-radius: 20px;
    }
    
    .stats-card {
        background: white;
        border-radius: 8px;
        padding: 20px;
        text-align: center;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .stats-card h3 {
        font-size: 2rem;
        margin: 10px 0;
    }
    
    @media (max-width: 768px) {
        .filter-form {
            flex-direction: column;
        }
        
        .filter-group {
            width: 100%;
        }
        
        .form-group {
            width: 100%;
            flex-direction: column;
            align-items: stretch;
        }
        
        .form-group label {
            text-align: left;
            margin-bottom: 5px;
        }
        
        .form-group input,
        .form-group select {
            width: 100% !important;
        }
        
        .btn-success {
            width: 100%;
            margin-top: 10px;
        }
    }
</style>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item active">Event Management</li>
        </ol>
    </nav>
    
    <!-- Alert Messages -->
    <c:if test="${not empty sessionScope.success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${sessionScope.success}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
        <c:remove var="success" scope="session"/>
    </c:if>
    
    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${sessionScope.error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>
    
    <!-- Statistics Cards -->
 
    
    <!-- Filter Section -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/events" class="filter-form">
                <div class="filter-group">
                    <div class="form-group">
                        <label>Search:</label>
                        <input type="text" name="search" class="form-control" 
                               placeholder="Title or description..." value="${search}">
                    </div>
                    
                    <div class="form-group">
                        <label>Status:</label>
                        <select name="status" class="form-control">
                            <option value="">All Status</option>
                            <option value="SCHEDULED" ${status == 'SCHEDULED' ? 'selected' : ''}>Scheduled</option>
                            <option value="ONGOING" ${status == 'ONGOING' ? 'selected' : ''}>Ongoing</option>
                            <option value="COMPLETED" ${status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                            <option value="CANCELLED" ${status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Location:</label>
                        <select name="location" class="form-control">
                            <option value="">All Locations</option>
                            <c:forEach var="loc" items="${locations}">
                                <option value="${loc}" ${location == loc ? 'selected' : ''}>${loc}</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Date:</label>
                        <select name="dateRange" class="form-control">
                            <option value="">All Time</option>
                            <option value="today" ${dateRange == 'today' ? 'selected' : ''}>Today</option>
                            <option value="thisWeek" ${dateRange == 'thisWeek' ? 'selected' : ''}>This Week</option>
                            <option value="thisMonth" ${dateRange == 'thisMonth' ? 'selected' : ''}>This Month</option>
                            <option value="upcoming" ${dateRange == 'upcoming' ? 'selected' : ''}>Upcoming</option>
                            <option value="past" ${dateRange == 'past' ? 'selected' : ''}>Past</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-filter"></i> Filter
                    </button>
                    
                    <c:if test="${not empty search || not empty status || not empty location || not empty dateRange}">
                        <a href="${pageContext.request.contextPath}/admin/events" 
                           class="btn btn-secondary">
                            <i class="fas fa-times"></i> Clear
                        </a>
                    </c:if>
                </div>
                
                <a href="${pageContext.request.contextPath}/admin/events?action=add" class="btn btn-success">
                    <i class="fas fa-plus"></i> Add New Event
                </a>
            </form>
        </div>
    </div>
    
    <!-- Events Table -->
    <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4>Event List</h4>
            <span class="pagination-info">
                <c:set var="startRecord" value="${(currentPage - 1) * recordsPerPage + 1}" />
                <c:set var="endRecord" value="${currentPage * recordsPerPage}" />
                <c:set var="actualEndRecord" value="${endRecord > totalRecords ? totalRecords : endRecord}" />
                Showing ${startRecord} - ${actualEndRecord} of ${totalRecords} events
            </span>
        </div>
        
        <c:choose>
            <c:when test="${not empty events}">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th width="5%">#</th>
                                <th width="25%">Title</th>
                                <th width="15%">Location</th>
                                <th width="15%">Start Time</th>
                                <th width="15%">End Time</th>
                                <th width="10%">Status</th>
                                <th width="15%">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="event" items="${events}" varStatus="status">
                                <tr>
                                    <td>${(currentPage - 1) * recordsPerPage + status.count}</td>
                                    <td>
                                        <strong>${event.title}</strong>
                                        <c:if test="${not empty event.description}">
                                            <br>
                                            <small class="text-muted">
                                                ${event.description.length() > 100 ? 
                                                  event.description.substring(0, 100).concat('...') : 
                                                  event.description}
                                            </small>
                                        </c:if>
                                    </td>
                                    <td>${event.location}</td>
                                    <td>
                                        <fmt:formatDate value="${event.startAt}" pattern="dd/MM/yyyy"/>
                                        <br>
                                        <small class="text-muted">
                                            <fmt:formatDate value="${event.startAt}" pattern="HH:mm"/>
                                        </small>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${event.endAt}" pattern="dd/MM/yyyy"/>
                                        <br>
                                        <small class="text-muted">
                                            <fmt:formatDate value="${event.endAt}" pattern="HH:mm"/>
                                        </small>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${event.status == 'SCHEDULED'}">
                                                <span class="badge badge-info status-badge">Scheduled</span>
                                            </c:when>
                                            <c:when test="${event.status == 'ONGOING'}">
                                                <span class="badge badge-warning status-badge">Ongoing</span>
                                            </c:when>
                                            <c:when test="${event.status == 'COMPLETED'}">
                                                <span class="badge badge-success status-badge">Completed</span>
                                            </c:when>
                                            <c:when test="${event.status == 'CANCELLED'}">
                                                <span class="badge badge-secondary status-badge">Cancelled</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/admin/events?action=view&id=${event.id}" 
                                               class="btn btn-info" title="View">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/events?action=edit&id=${event.id}" 
                                               class="btn btn-warning" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <button type="button" class="btn btn-danger" 
                                                    onclick="confirmDelete(${event.id}, '${event.title}')"
                                                    title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" 
                                   href="?page=${currentPage - 1}&search=${search}&status=${status}&location=${location}&dateRange=${dateRange}">
                                    Previous
                                </a>
                            </li>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" 
                                       href="?page=${i}&search=${search}&status=${status}&location=${location}&dateRange=${dateRange}">
                                        ${i}
                                    </a>
                                </li>
                            </c:forEach>
                            
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" 
                                   href="?page=${currentPage + 1}&search=${search}&status=${status}&location=${location}&dateRange=${dateRange}">
                                    Next
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <i class="fas fa-calendar-alt fa-4x text-muted mb-3"></i>
                    <h4 class="text-muted">No events found</h4>
                    <p class="text-muted">Try adjusting your search criteria or add a new event.</p>
                    <a href="${pageContext.request.contextPath}/admin/events?action=add" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Add New Event
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
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
                <p class="font-weight-bold" id="eventTitle"></p>
                <p class="text-danger">This action cannot be undone!</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/events" 
                      style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteId">
                    <button type="submit" class="btn btn-danger">Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function confirmDelete(id, title) {
    document.getElementById('deleteId').value = id;
    document.getElementById('eventTitle').textContent = title;
    $('#deleteModal').modal('show');
}
</script>