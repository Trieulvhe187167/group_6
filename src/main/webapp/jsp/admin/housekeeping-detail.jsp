<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/HouseKeeping">Housekeeping Tasks</a></li>
            <li class="breadcrumb-item active">Task Details</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">Task Details</h1>
        <div>
            <c:if test="${sessionScope.user.role == 'ADMIN' || sessionScope.user.role == 'RECEPTIONIST'}">
                <a href="${pageContext.request.contextPath}/HouseKeeping?action=form&id=${task.id}" 
                   class="btn btn-warning">
                    <i class="fas fa-edit"></i> Edit
                </a>
            </c:if>
            <a href="${pageContext.request.contextPath}/HouseKeeping" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to List
            </a>
        </div>
    </div>
    
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
    
    <div class="row">
        <!-- Task Information -->
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Task Information</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <table class="table table-borderless">
                                <tr>
                                    <th width="40%">Task ID:</th>
                                    <td>#${task.id}</td>
                                </tr>
                                <tr>
                                    <th>Room:</th>
                                    <td>
                                        <strong>${task.roomNumber}</strong>
                                        <c:if test="${not empty task.roomStatus}">
                                            <span class="ml-2 badge ${task.roomStatusBadgeClass}">
                                                ${task.roomStatus}
                                            </span>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Room Type:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty task.roomTypeName}">
                                                ${task.roomTypeName}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Unknown</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Status:</th>
                                    <td>
                                        <span class="badge ${task.statusBadgeClass}">
                                            ${task.statusDisplayName}
                                        </span>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6">
                            <table class="table table-borderless">
                                <tr>
                                    <th width="40%">Assigned To:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${task.assignedTo > 0 && not empty task.assignedToName}">
                                                <i class="fas fa-user text-primary"></i> ${task.assignedToName}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Unassigned</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Created:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty task.createdAt}">
                                                <fmt:formatDate value="${task.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Unknown</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Last Updated:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty task.updatedAt}">
                                                <fmt:formatDate value="${task.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not updated</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Duration:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty task.createdAt && not empty task.updatedAt}">
                                                <c:set var="duration" value="${(task.updatedAt.time - task.createdAt.time) / (1000 * 60)}" />
                                                <c:choose>
                                                    <c:when test="${duration < 60}">
                                                        <fmt:formatNumber value="${duration}" maxFractionDigits="0"/> minutes
                                                    </c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${duration / 60}" maxFractionDigits="1"/> hours
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">N/A</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <h6>Task Notes</h6>
                    <div class="bg-light p-3 rounded">
                        <c:choose>
                            <c:when test="${not empty task.notes}">
                                <p class="mb-0">${task.notes}</p>
                            </c:when>
                            <c:otherwise>
                                <p class="text-muted mb-0">No notes provided for this task.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            
            <!-- Task Progress Timeline -->
            <div class="card mt-4">
                <div class="card-header">
                    <h5 class="mb-0">Task Progress</h5>
                </div>
                <div class="card-body">
                    <div class="timeline">
                        <div class="timeline-item ${task.status == 'PENDING' || task.status == 'IN_PROGRESS' || task.status == 'DONE' ? 'completed' : ''}">
                            <div class="timeline-marker bg-warning"></div>
                            <div class="timeline-content">
                                <h6 class="mb-1">Task Created</h6>
                                <small class="text-muted">
                                    <c:choose>
                                        <c:when test="${not empty task.createdAt}">
                                            <fmt:formatDate value="${task.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </c:when>
                                        <c:otherwise>Unknown time</c:otherwise>
                                    </c:choose>
                                </small>
                            </div>
                        </div>
                        
                        <div class="timeline-item ${task.status == 'IN_PROGRESS' || task.status == 'DONE' ? 'completed' : ''}">
                            <div class="timeline-marker bg-info"></div>
                            <div class="timeline-content">
                                <h6 class="mb-1">In Progress</h6>
                                <small class="text-muted">
                                    <c:choose>
                                        <c:when test="${task.status == 'IN_PROGRESS' || task.status == 'DONE'}">
                                            Task started
                                        </c:when>
                                        <c:otherwise>
                                            Not started yet
                                        </c:otherwise>
                                    </c:choose>
                                </small>
                            </div>
                        </div>
                        
                        <div class="timeline-item ${task.status == 'DONE' ? 'completed' : ''}">
                            <div class="timeline-marker bg-success"></div>
                            <div class="timeline-content">
                                <h6 class="mb-1">Completed</h6>
                                <small class="text-muted">
                                    <c:choose>
                                        <c:when test="${task.status == 'DONE'}">
                                            <c:choose>
                                                <c:when test="${not empty task.updatedAt}">
                                                    <fmt:formatDate value="${task.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:when>
                                                <c:otherwise>Completed</c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            Not completed yet
                                        </c:otherwise>
                                    </c:choose>
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Quick Actions</h5>
                </div>
                <div class="card-body">
                    <c:if test="${sessionScope.user.role == 'ADMIN' || sessionScope.user.role == 'RECEPTIONIST'}">
                        <a href="${pageContext.request.contextPath}/HouseKeeping?action=form&id=${task.id}" 
                           class="btn btn-warning btn-block mb-2">
                            <i class="fas fa-edit"></i> Edit Task
                        </a>
                        
                        <c:if test="${task.assignedTo == 0}">
                            <button onclick="showAssignModal(${task.id}, '${task.roomNumber}')" 
                                    class="btn btn-primary btn-block mb-2">
                                <i class="fas fa-user-plus"></i> Assign Task
                            </button>
                        </c:if>
                    </c:if>
                    
                    <!-- Status Update Buttons -->
                    <c:if test="${task.status != 'DONE' && (sessionScope.user.id == task.assignedTo || sessionScope.user.role == 'ADMIN')}">
                        <hr>
                        <h6>Update Status</h6>
                        <c:if test="${task.status == 'PENDING'}">
                            <button onclick="updateStatus(${task.id}, 'IN_PROGRESS')" 
                                    class="btn btn-info btn-block mb-2">
                                <i class="fas fa-play"></i> Start Task
                            </button>
                        </c:if>
                        <c:if test="${task.status == 'IN_PROGRESS'}">
                            <button onclick="updateStatus(${task.id}, 'DONE')" 
                                    class="btn btn-success btn-block mb-2">
                                <i class="fas fa-check"></i> Complete Task
                            </button>
                        </c:if>
                    </c:if>
                    
                    <c:if test="${sessionScope.user.role == 'ADMIN'}">
                        <hr>
                        <button onclick="confirmDelete(${task.id})" 
                                class="btn btn-danger btn-block">
                            <i class="fas fa-trash"></i> Delete Task
                        </button>
                    </c:if>
                </div>
            </div>
            
            <!-- Room Information -->
            <div class="card mt-3">
                <div class="card-header">
                    <h5 class="mb-0">Room Information</h5>
                </div>
                <div class="card-body">
                    <p class="mb-2"><strong>Room:</strong> 
                        <c:choose>
                            <c:when test="${not empty task.roomNumber}">
                                ${task.roomNumber}
                            </c:when>
                            <c:otherwise>Unknown</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="mb-2"><strong>Type:</strong> 
                        <c:choose>
                            <c:when test="${not empty task.roomTypeName}">
                                ${task.roomTypeName}
                            </c:when>
                            <c:otherwise>Unknown</c:otherwise>
                        </c:choose>
                    </p>
                    <p class="mb-0">
                        <strong>Status:</strong> 
                        <c:choose>
                            <c:when test="${not empty task.roomStatus}">
                                <span class="badge ${task.roomStatusBadgeClass}">
                                    ${task.roomStatus}
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-secondary">Unknown</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>
            
            <!-- Debug Information (Remove this in production) -->
            <c:if test="${param.debug == 'true'}">
                <div class="card mt-3 border-danger">
                    <div class="card-header bg-danger text-white">
                        <h6 class="mb-0">Debug Info</h6>
                    </div>
                    <div class="card-body">
                        <small>
                            Task ID: ${task.id}<br>
                            Room ID: ${task.roomId}<br>
                            Assigned To ID: ${task.assignedTo}<br>
                            Status: ${task.status}<br>
                            Created At: ${task.createdAt}<br>
                            Updated At: ${task.updatedAt}
                        </small>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Assign Task Modal -->
<div class="modal fade" id="assignModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/HouseKeeping">
                <input type="hidden" name="action" value="assign">
                <input type="hidden" name="taskId" id="assignTaskId">
                
                <div class="modal-header">
                    <h5 class="modal-title">Assign Task</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>Assign task for room <strong id="assignRoomNumber"></strong> to:</p>
                    <div class="form-group">
                        <select name="userId" class="form-control" required>
                            <option value="">Select Housekeeper</option>
                            <c:forEach var="housekeeper" items="${housekeepers}">
                                <option value="${housekeeper.id}">${housekeeper.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Assign</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this task?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button onclick="deleteTask(${task.id})" class="btn btn-danger">Delete</button>
            </div>
        </div>
    </div>
</div>

<style>
.timeline {
    position: relative;
    padding: 20px 0;
}

.timeline-item {
    position: relative;
    padding-left: 40px;
    margin-bottom: 20px;
}

.timeline-item:before {
    content: '';
    position: absolute;
    left: 15px;
    top: 25px;
    bottom: -20px;
    width: 2px;
    background: #e9ecef;
}

.timeline-item:last-child:before {
    display: none;
}

.timeline-marker {
    position: absolute;
    left: 10px;
    top: 5px;
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: #e9ecef;
}

.timeline-item.completed .timeline-marker {
    box-shadow: 0 0 0 3px rgba(40, 167, 69, 0.2);
}

.timeline-content {
    background: #f8f9fa;
    padding: 10px 15px;
    border-radius: 5px;
}
</style>

<script>
function updateStatus(taskId, newStatus) {
    if (confirm('Are you sure you want to update the task status?')) {
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/HouseKeeping';
        
        var actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'updateStatus';
        
        var taskIdInput = document.createElement('input');
        taskIdInput.type = 'hidden';
        taskIdInput.name = 'taskId';
        taskIdInput.value = taskId;
        
        var statusInput = document.createElement('input');
        statusInput.type = 'hidden';
        statusInput.name = 'status';
        statusInput.value = newStatus;
        
        form.appendChild(actionInput);
        form.appendChild(taskIdInput);
        form.appendChild(statusInput);
        document.body.appendChild(form);
        form.submit();
    }
}

function confirmDelete(taskId) {
    $('#deleteModal').modal('show');
}

function deleteTask(taskId) {
    $('#deleteModal').modal('hide');
    
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/HouseKeeping';
    
    var actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'delete';
    
    var idInput = document.createElement('input');
    idInput.type = 'hidden';
    idInput.name = 'id';
    idInput.value = taskId;
    
    form.appendChild(actionInput);
    form.appendChild(idInput);
    document.body.appendChild(form);
    form.submit();
}

function showAssignModal(taskId, roomNumber) {
    document.getElementById('assignTaskId').value = taskId;
    document.getElementById('assignRoomNumber').textContent = roomNumber;
    $('#assignModal').modal('show');
}
</script>