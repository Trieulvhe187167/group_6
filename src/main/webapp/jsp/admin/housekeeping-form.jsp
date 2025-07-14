<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/HouseKeeping">Housekeeping Tasks</a></li>
            <li class="breadcrumb-item active">${isEdit ? 'Edit Task' : 'Create Task'}</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">${isEdit ? 'Edit Housekeeping Task' : 'Create New Task'}</h1>
    </div>
    
    <!-- Alert Messages -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <!-- Task Form -->
    <div class="row">
        <div class="col-md-8">
            <div class="card">
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/HouseKeeping" method="post" id="taskForm">
                        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                        <c:if test="${isEdit}">
                            <input type="hidden" name="id" value="${task.id}">
                        </c:if>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="roomId">Room <span class="text-danger">*</span></label>
                                    <select class="form-control" id="roomId" name="roomId" required>
                                        <option value="">Select Room</option>
                                        <c:forEach var="room" items="${rooms}">
                                            <option value="${room.id}" 
                                                    ${task.roomId == room.id ? 'selected' : ''}>
                                                ${room.roomNumber} - ${room.roomTypeName} 
                                                <c:if test="${room.status != 'AVAILABLE'}">
                                                    (${room.statusDisplayName})
                                                </c:if>
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="assignedTo">Assign To</label>
                                    <select class="form-control" id="assignedTo" name="assignedTo">
                                        <option value="">Unassigned</option>
                                        <c:forEach var="housekeeper" items="${housekeepers}">
                                            <option value="${housekeeper.id}" 
                                                    ${task.assignedTo == housekeeper.id ? 'selected' : ''}>
                                                ${housekeeper.fullName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="status">Status <span class="text-danger">*</span></label>
                            <select class="form-control" id="status" name="status" required>
                                <option value="PENDING" ${task.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                                <option value="IN_PROGRESS" ${task.status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                                <option value="DONE" ${task.status == 'DONE' ? 'selected' : ''}>Completed</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="notes">Notes</label>
                            <textarea class="form-control" id="notes" name="notes" rows="4" 
                                      placeholder="Enter any special instructions or notes...">${task.notes}</textarea>
                        </div>
                        
                        <hr>
                        
                        <div class="form-group d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/HouseKeeping" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Cancel
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> ${isEdit ? 'Update Task' : 'Create Task'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="card bg-light">
                <div class="card-body">
                    <h5 class="card-title">Task Guidelines</h5>
                    <p class="card-text">
                        <strong>Status Guide:</strong><br>
                        • <span class="badge badge-warning">Pending</span> - Task created, waiting to start<br>
                        • <span class="badge badge-info">In Progress</span> - Currently being worked on<br>
                        • <span class="badge badge-success">Completed</span> - Task finished<br><br>
                        
                        <strong>Priority Tasks:</strong><br>
                        • Occupied rooms need daily cleaning<br>
                        • Dirty rooms should be cleaned ASAP<br>
                        • Maintenance rooms need special attention
                    </p>
                    
                    <c:if test="${isEdit}">
                        <hr>
                        <h6>Task Information</h6>
                        <small class="text-muted">
                            Created: <fmt:formatDate value="${task.createdAt}" pattern="dd/MM/yyyy HH:mm"/><br>
                            Last Updated: <fmt:formatDate value="${task.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </small>
                    </c:if>
                </div>
            </div>
            
            <div class="card mt-3">
                <div class="card-header">
                    <h6 class="mb-0">Room Status Legend</h6>
                </div>
                <div class="card-body">
                    <span class="badge badge-success">Available</span> - Ready for guests<br>
                    <span class="badge badge-danger">Occupied</span> - Guest in room<br>
                    <span class="badge badge-warning">Dirty</span> - Needs cleaning<br>
                    <span class="badge badge-warning">Maintenance</span> - Under repair
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Form validation
    $('#taskForm').on('submit', function(e) {
        var isValid = true;
        
        // Check required fields
        $(this).find('[required]').each(function() {
            if (!$(this).val()) {
                $(this).addClass('is-invalid');
                isValid = false;
            } else {
                $(this).removeClass('is-invalid');
            }
        });
        
        if (!isValid) {
            e.preventDefault();
            alert('Please fill in all required fields');
        }
    });
    
    // Remove invalid class on change
    $('select, textarea').on('change input', function() {
        $(this).removeClass('is-invalid');
    });
});
</script>