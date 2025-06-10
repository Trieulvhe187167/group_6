<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Task Detail - Housekeeper Portal</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f8f9fa;
        }
        
        .header {
            background: #2c3e50;
            color: white;
            padding: 20px 0;
            margin-bottom: 30px;
        }
        
        .container-custom {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .detail-card {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .info-row {
            padding: 15px 0;
            border-bottom: 1px solid #e9ecef;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            font-weight: 600;
            color: #495057;
            min-width: 150px;
            display: inline-block;
        }
        
        .status-badge {
            padding: 8px 20px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: 500;
            text-transform: uppercase;
            display: inline-block;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-in-progress {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .status-done {
            background: #d4edda;
            color: #155724;
        }
        
        .room-status-available {
            background: #d4edda;
            color: #155724;
        }
        
        .room-status-occupied {
            background: #f8d7da;
            color: #721c24;
        }
        
        .room-status-maintenance {
            background: #fff3cd;
            color: #856404;
        }
        
        .room-status-dirty {
            background: #e2e3e5;
            color: #383d41;
        }
        
        .action-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }
        
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
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container-custom">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h3 class="mb-0">Task Details</h3>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb mb-0 bg-transparent p-0">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/housekeeper-dashboard" class="text-white">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/housekeeper/tasks" class="text-white">My Tasks</a></li>
                            <li class="breadcrumb-item active text-white-50">Task Details</li>
                        </ol>
                    </nav>
                </div>
                <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="btn btn-outline-light">
                    <i class="fas fa-arrow-left"></i> Back to Tasks
                </a>
            </div>
        </div>
    </header>
    
    <div class="container-custom">
        <div class="row">
            <!-- Task Information -->
            <div class="col-md-8">
                <div class="detail-card">
                    <h4 class="mb-4">Task Information</h4>
                    
                    <div class="info-row">
                        <span class="info-label">Task ID:</span>
                        <span>#${task.id}</span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">Room Number:</span>
                        <span class="font-weight-bold">${task.roomNumber}</span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">Room Type:</span>
                        <span>${task.roomTypeName}</span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">Room Status:</span>
                        <span class="status-badge room-status-${task.roomStatus.toLowerCase()}">
                            ${task.roomStatus}
                        </span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">Task Status:</span>
                        <span class="status-badge status-${task.status.toLowerCase().replace('_', '-')}">
                            ${task.statusDisplayName}
                        </span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">Created:</span>
                        <span><fmt:formatDate value="${task.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/></span>
                    </div>
                    
                    <c:if test="${not empty task.updatedAt}">
                        <div class="info-row">
                            <span class="info-label">Last Updated:</span>
                            <span><fmt:formatDate value="${task.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/></span>
                        </div>
                    </c:if>
                    
                    <div class="info-row">
                        <span class="info-label">Instructions:</span>
                        <div class="mt-2">
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
                
                <!-- Progress Timeline -->
                <div class="detail-card mt-3">
                    <h4 class="mb-4">Task Progress</h4>
                    <div class="timeline">
                        <div class="timeline-item ${task.status == 'PENDING' || task.status == 'IN_PROGRESS' || task.status == 'DONE' ? 'completed' : ''}">
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
            
            <!-- Quick Actions -->
            <div class="col-md-4">
                <div class="detail-card">
                    <h4 class="mb-4">Quick Actions</h4>
                    
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
                
                <!-- Room Information Card -->
                <div class="detail-card mt-3">
                    <h5 class="mb-3">Room Information</h5>
                    <div class="text-center mb-3">
                        <i class="fas fa-bed fa-3x text-muted"></i>
                    </div>
                    <p class="mb-2"><strong>Room:</strong> ${task.roomNumber}</p>
                    <p class="mb-2"><strong>Type:</strong> ${task.roomTypeName}</p>
                    <p class="mb-0">
                        <strong>Status:</strong> 
                        <span class="status-badge room-status-${task.roomStatus.toLowerCase()}">
                            ${task.roomStatus}
                        </span>
                    </p>
                </div>
                
                <!-- Help Card -->
                <div class="detail-card mt-3">
                    <h5 class="mb-3">Need Help?</h5>
                    <p class="text-muted mb-3">If you have any questions or issues with this task, please contact your supervisor.</p>
                    <a href="tel:+84123456789" class="btn btn-outline-primary btn-block">
                        <i class="fas fa-phone"></i> Call Supervisor
                    </a>
                </div>
            </div>
        </div>
    </div>  
    
    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>