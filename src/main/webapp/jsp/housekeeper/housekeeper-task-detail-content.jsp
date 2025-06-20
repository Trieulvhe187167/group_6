<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
        background: #6c757d;
        border: 2px solid white;
        box-shadow: 0 0 0 3px #e9ecef;
    }
    
    .timeline-item.completed .timeline-marker {
        background: #28a745;
    }
    
    .timeline-content {
        background: white;
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
</style>
<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/housekeeper-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/housekeeper/tasks">My Tasks</a></li>
            <li class="breadcrumb-item active">Task Details</li>
        </ol>
    </nav>
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>Task Details</h1>
        <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to Tasks
        </a>
    </div>
    
    <div class="row">
        <!-- Task Information -->
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h4 class="mb-0">Task Information</h4>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-3 font-weight-bold">Task ID:</div>
                        <div class="col-md-9">#${task.id}</div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-3 font-weight-bold">Room Number:</div>
                        <div class="col-md-9">
                            <span class="h5">${task.roomNumber}</span>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-3 font-weight-bold">Room Type:</div>
                        <div class="col-md-9">${task.roomTypeName}</div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-3 font-weight-bold">Room Status:</div>
                        <div class="col-md-9">
                            <span class="badge badge-${task.roomStatus == 'AVAILABLE' ? 'success' : 
                                                      task.roomStatus == 'OCCUPIED' ? 'danger' : 
                                                      task.roomStatus == 'MAINTENANCE' ? 'warning' : 'secondary'}">
                                ${task.roomStatus}
                            </span>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-3 font-weight-bold">Task Status:</div>
                        <div class="col-md-9">
                            <span class="status-badge status-${task.status.toLowerCase().replace('_', '-')}">
                                ${task.statusDisplayName}
                            </span>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-3 font-weight-bold">Created:</div>
                        <div class="col-md-9">
                            <fmt:formatDate value="${task.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                        </div>
                    </div>
                    
                    <c:if test="${not empty task.updatedAt}">
                        <div class="row mb-3">
                            <div class="col-md-3 font-weight-bold">Last Updated:</div>
                            <div class="col-md-9">
                                <fmt:formatDate value="${task.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                            </div>
                        </div>
                    </c:if>
                    
                    <div class="row">
                        <div class="col-md-3 font-weight-bold">Instructions:</div>
                        <div class="col-md-9">
                            <c:choose>
                                <c:when test="${not empty task.notes}">
                                    <div class="bg-light p-3 rounded">
                                        ${task.notes}
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">No special instructions provided</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Progress Timeline -->
            <div class="card mt-3">
                <div class="card-header">
                    <h4 class="mb-0">Task Progress</h4>
                </div>
                <div class="card-body">
                    <div class="timeline">
                        <div class="timeline-item ${task.status != 'PENDING' ? 'completed' : ''}">
                            <div class="timeline-marker"></div>
                            <div class="timeline-content">
                                <h6 class="mb-1">Task Created</h6>
                                <small class="text-muted">
                                    <fmt:formatDate value="${task.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </small>
                            </div>
                        </div>
                        
                        <div class="timeline-item ${task.status == 'IN_PROGRESS' || task.status == 'DONE' ? 'completed' : ''}">
                            <div class="timeline-marker"></div>
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
                            <div class="timeline-marker"></div>
                            <div class="timeline-content">
                                <h6 class="mb-1">Completed</h6>
                                <small class="text-muted">
                                    <c:choose>
                                        <c:when test="${task.status == 'DONE' && not empty task.updatedAt}">
                                            <fmt:formatDate value="${task.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </c:when>
                                        <c:when test="${task.status == 'DONE'}">
                                            Completed
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
                    <h4 class="mb-0">Quick Actions</h4>
                </div>
                <div class="card-body">
                    <c:if test="${task.status != 'DONE'}">
                        <c:choose>
                            <c:when test="${task.status == 'PENDING'}">
                                <form method="post" action="${pageContext.request.contextPath}/housekeeper/tasks" class="mb-3">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="taskId" value="${task.id}">
                                    <input type="hidden" name="status" value="IN_PROGRESS">
                                    <button type="submit" class="btn btn-warning btn-block">
                                        <i class="fas fa-play"></i> Start Task
                                    </button>
                                </form>
                            </c:when>
                            <c:when test="${task.status == 'IN_PROGRESS'}">
                                <form method="post" action="${pageContext.request.contextPath}/housekeeper/tasks" class="mb-3">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="taskId" value="${task.id}">
                                    <input type="hidden" name="status" value="DONE">
                                    <button type="submit" class="btn btn-success btn-block">
                                        <i class="fas fa-check"></i> Complete Task
                                    </button>
                                </form>
                            </c:when>
                        </c:choose>
                    </c:if>
                    
                    <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="btn btn-secondary btn-block">
                        <i class="fas fa-list"></i> View All Tasks
                    </a>
                </div>
            </div>
            
            <!-- Room Information Card -->
            <div class="card mt-3">
                <div class="card-header">
                    <h5 class="mb-0">Room Information</h5>
                </div>
                <div class="card-body">
                    <div class="text-center mb-3">
                        <i class="fas fa-bed fa-3x text-muted"></i>
                    </div>
                    <p class="mb-2"><strong>Room:</strong> ${task.roomNumber}</p>
                    <p class="mb-2"><strong>Type:</strong> ${task.roomTypeName}</p>
                    <p class="mb-0">
                        <strong>Status:</strong> 
                        <span class="badge badge-${task.roomStatus == 'AVAILABLE' ? 'success' : 
                                                  task.roomStatus == 'OCCUPIED' ? 'danger' : 
                                                  task.roomStatus == 'MAINTENANCE' ? 'warning' : 'secondary'}">
                            ${task.roomStatus}
                        </span>
                    </p>
                </div>
            </div>
            
            <!-- Help Card -->
            <div class="card mt-3">
                <div class="card-header">
                    <h5 class="mb-0">Need Help?</h5>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-3">If you have any questions or issues with this task, please contact your supervisor.</p>
                    <a href="tel:+84123456789" class="btn btn-outline-primary btn-block">
                        <i class="fas fa-phone"></i> Call Supervisor
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
