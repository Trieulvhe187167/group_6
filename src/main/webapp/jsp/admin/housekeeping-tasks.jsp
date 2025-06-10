<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Housekeeping Tasks</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">Housekeeping Tasks</h1>
        <c:if test="${currentUser.role == 'ADMIN' || currentUser.role == 'RECEPTIONIST'}">
            <a href="${pageContext.request.contextPath}/HouseKeeping?action=form" class="btn btn-success">
                <i class="fas fa-plus"></i> Create Task
            </a>
        </c:if>
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
    
    <!-- Statistics Cards -->
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="card bg-warning text-white">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="mb-0">Pending Tasks</h6>
                            <h2 class="mb-0">${pendingCount}</h2>
                        </div>
                        <i class="fas fa-clock fa-2x opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card bg-info text-white">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="mb-0">In Progress</h6>
                            <h2 class="mb-0">${inProgressCount}</h2>
                        </div>
                        <i class="fas fa-spinner fa-2x opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card bg-success text-white">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="mb-0">Completed</h6>
                            <h2 class="mb-0">${completedCount}</h2>
                        </div>
                        <i class="fas fa-check-circle fa-2x opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Filter Form -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/HouseKeeping" class="form-inline">
                <div class="form-group mr-3">
                    <label class="mr-2">Search:</label>
                    <input type="text" name="search" value="${search}" 
                           placeholder="Room number, notes..." class="form-control">
                </div>
                
                <div class="form-group mr-3">
                    <label class="mr-2">Status:</label>
                    <select name="status" class="form-control">
                        <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>All Status</option>
                        <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="IN_PROGRESS" ${status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                        <option value="DONE" ${status == 'DONE' ? 'selected' : ''}>Completed</option>
                    </select>
                </div>
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-filter"></i> Filter
                </button>
                <c:if test="${not empty search || status != 'ALL'}">
                    <a href="${pageContext.request.contextPath}/HouseKeeping" class="btn btn-secondary ml-2">
                        <i class="fas fa-times"></i> Clear
                    </a>
                </c:if>
            </form>
        </div>
    </div>
    
    <!-- Tasks Table -->
    <div class="table-container">
        <c:choose>
            <c:when test="${not empty tasks}">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Room</th>
                            <th>Room Type</th>
                            <th>Room Status</th>
                            <th>Task Status</th>
                            <th>Assigned To</th>
                            <th>Notes</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="task" items="${tasks}" varStatus="status">
                            <tr>
                                <td>${status.index + 1}</td>
                                <td>
                                    <strong>${task.roomNumber}</strong>
                                </td>
                                <td>${task.roomTypeName}</td>
                                <td>
                                    <span class="badge ${task.roomStatusBadgeClass}">
                                        ${task.roomStatus}
                                    </span>
                                </td>
                                <td>
                                    <span class="badge ${task.statusBadgeClass}">
                                        ${task.statusDisplayName}
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${task.assignedTo > 0}">
                                            ${task.assignedToName}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">Unassigned</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty task.notes}">
                                            <c:choose>
                                                <c:when test="${task.notes.length() > 50}">
                                                    ${task.notes.substring(0, 50)}...
                                                </c:when>
                                                <c:otherwise>
                                                    ${task.notes}
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">No notes</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatDate value="${task.createdAt}" pattern="dd/MM HH:mm"/>
                                </td>
                                <td>
                                    <div class="btn-group" role="group">
                                        <a href="${pageContext.request.contextPath}/HouseKeeping?action=detail&id=${task.id}" 
                                           class="btn btn-sm btn-info" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        
                                        <c:if test="${currentUser.role == 'ADMIN' || currentUser.role == 'RECEPTIONIST'}">
                                            <a href="${pageContext.request.contextPath}/HouseKeeping?action=form&id=${task.id}" 
                                               class="btn btn-sm btn-warning" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            
                                            <c:if test="${task.assignedTo == 0}">
                                                <button onclick="showAssignModal(${task.id}, '${task.roomNumber}')" 
                                                        class="btn btn-sm btn-primary" title="Assign">
                                                    <i class="fas fa-user-plus"></i>
                                                </button>
                                            </c:if>
                                        </c:if>
                                        
                                        <!-- Quick status update for assigned housekeeper or admin -->
                                        <c:if test="${task.status != 'DONE' && (currentUser.id == task.assignedTo || currentUser.role == 'ADMIN')}">
                                            <div class="btn-group" role="group">
                                                <button type="button" class="btn btn-sm btn-secondary dropdown-toggle" 
                                                        data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                    <i class="fas fa-tasks"></i>
                                                </button>
                                                <div class="dropdown-menu">
                                                    <c:if test="${task.status == 'PENDING'}">
                                                        <a class="dropdown-item" href="#" 
                                                           onclick="updateStatus(${task.id}, 'IN_PROGRESS')">
                                                            <i class="fas fa-play text-info"></i> Start Task
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${task.status == 'IN_PROGRESS'}">
                                                        <a class="dropdown-item" href="#" 
                                                           onclick="updateStatus(${task.id}, 'DONE')">
                                                            <i class="fas fa-check text-success"></i> Complete Task
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </c:if>
                                        
                                        <c:if test="${currentUser.role == 'ADMIN'}">
                                            <button onclick="confirmDelete(${task.id})" 
                                                    class="btn btn-sm btn-danger" title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <i class="fas fa-broom fa-3x text-muted mb-3"></i>
                    <p class="text-muted">No housekeeping tasks found</p>
                    <c:if test="${currentUser.role == 'ADMIN' || currentUser.role == 'RECEPTIONIST'}">
                        <a href="${pageContext.request.contextPath}/HouseKeeping?action=form" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Create First Task
                        </a>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <nav aria-label="Page navigation" class="mt-4">
            <ul class="pagination justify-content-center">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage - 1}&status=${status}&search=${search}">
                        Previous
                    </a>
                </li>
                
                <c:forEach begin="1" end="${totalPages}" var="i">
                    <c:if test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}&status=${status}&search=${search}">
                                ${i}
                            </a>
                        </li>
                    </c:if>
                    <c:if test="${i == currentPage - 3 || i == currentPage + 3}">
                        <li class="page-item disabled">
                            <span class="page-link">...</span>
                        </li>
                    </c:if>
                </c:forEach>
                
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage + 1}&status=${status}&search=${search}">
                        Next
                    </a>
                </li>
            </ul>
        </nav>
        
        <div class="text-center text-muted">
            <small>
                Showing ${(currentPage - 1) * 5 + 1} - 
                ${currentPage * 5 > totalRecords ? totalRecords : currentPage * 5} 
                of ${totalRecords} tasks
            </small>
        </div>
    </c:if>
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
                <form method="post" action="${pageContext.request.contextPath}/HouseKeeping" style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteTaskId">
                    <button type="submit" class="btn btn-danger">Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Hidden form for status update -->
<form id="statusUpdateForm" method="post" action="${pageContext.request.contextPath}/HouseKeeping" style="display: none;">
    <input type="hidden" name="action" value="updateStatus">
    <input type="hidden" name="taskId" id="statusTaskId">
    <input type="hidden" name="status" id="statusValue">
</form>

<script>
function showAssignModal(taskId, roomNumber) {
    document.getElementById('assignTaskId').value = taskId;
    document.getElementById('assignRoomNumber').textContent = roomNumber;
    $('#assignModal').modal('show');
}

function confirmDelete(taskId) {
    document.getElementById('deleteTaskId').value = taskId;
    $('#deleteModal').modal('show');
}

function updateStatus(taskId, newStatus) {
    if (confirm('Are you sure you want to update the task status?')) {
        document.getElementById('statusTaskId').value = taskId;
        document.getElementById('statusValue').value = newStatus;
        document.getElementById('statusUpdateForm').submit();
    }
}
</script>