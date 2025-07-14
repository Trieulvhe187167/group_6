<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/housekeeper-dashboard">Home</a></li>
            <li class="breadcrumb-item active">Dashboard</li>
        </ol>
    </nav>
    
    <!-- Welcome Section -->
    <div class="mb-4">
        <h1>Good ${greeting}, ${currentUser.fullName}!</h1>
        <p class="text-muted">Here's your work summary for today</p>
    </div>
    
    <!-- Statistics Cards -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-warning">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number">${stats.pendingCount}</div>
                <div class="stat-label">Pending Tasks</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-info">
                    <i class="fas fa-spinner"></i>
                </div>
                <div class="stat-number">${stats.inProgressCount}</div>
                <div class="stat-label">In Progress</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-success">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-number">${stats.todayCompletedCount}</div>
                <div class="stat-label">Completed Today</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-primary">
                    <i class="fas fa-tasks"></i>
                </div>
                <div class="stat-number">${stats.totalTasks}</div>
                <div class="stat-label">Total Tasks</div>
            </div>
        </div>
    </div>
    
    <!-- Quick Actions -->
    <h2 class="mb-3">Quick Actions</h2>
    <div class="row mb-4">
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="text-decoration-none">
                <div class="card text-center p-3">
                    <div class="text-primary mb-2">
                        <i class="fas fa-list-alt fa-3x"></i>
                    </div>
                    <h5>View All Tasks</h5>
                    <p class="text-muted mb-0">See all assigned tasks</p>
                </div>
            </a>
        </div>
        
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=PENDING" class="text-decoration-none">
                <div class="card text-center p-3">
                    <div class="text-warning mb-2">
                        <i class="fas fa-exclamation-circle fa-3x"></i>
                    </div>
                    <h5>Pending Tasks</h5>
                    <p class="text-muted mb-0">${stats.pendingCount} tasks waiting</p>
                </div>
            </a>
        </div>
        
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=IN_PROGRESS" class="text-decoration-none">
                <div class="card text-center p-3">
                    <div class="text-info mb-2">
                        <i class="fas fa-play-circle fa-3x"></i>
                    </div>
                    <h5>Active Tasks</h5>
                    <p class="text-muted mb-0">${stats.inProgressCount} in progress</p>
                </div>
            </a>
        </div>
        
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/housekeeper/reports" class="text-decoration-none">
                <div class="card text-center p-3">
                    <div class="text-success mb-2">
                        <i class="fas fa-chart-bar fa-3x"></i>
                    </div>
                    <h5>My Reports</h5>
                    <p class="text-muted mb-0">View work reports</p>
                </div>
            </a>
        </div>
    </div>
    
    <!-- Recent Tasks and Today's Summary -->
    <div class="row">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h4 class="mb-0">Recent Tasks</h4>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty recentTasks}">
                            <c:forEach var="task" items="${recentTasks}">
                                <div class="task-item border-bottom pb-3 mb-3">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h5 class="mb-1">Room ${task.roomNumber}</h5>
                                            <p class="mb-1 text-muted">${task.roomTypeName}</p>
                                            <p class="mb-0">
                                                <c:choose>
                                                    <c:when test="${not empty task.notes}">
                                                        ${task.notes.length() > 50 ? task.notes.substring(0, 50).concat('...') : task.notes}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">No special instructions</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                        <div class="text-right">
                                            <span class="status-badge status-${task.status.toLowerCase().replace('_', '-')}">
                                                ${task.statusDisplayName}
                                            </span>
                                            <p class="mb-0 mt-2">
                                                <a href="${pageContext.request.contextPath}/housekeeper/task-detail?id=${task.id}" 
                                                   class="btn btn-sm btn-outline-primary">
                                                    View Details
                                                </a>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            
                            <div class="text-center">
                                <a href="${pageContext.request.contextPath}/housekeeper/tasks" 
                                   class="btn btn-primary">
                                    View All Tasks
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5">
                                <i class="fas fa-clipboard-check fa-3x text-muted mb-3"></i>
                                <p class="text-muted">No tasks assigned yet</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <!-- Today's Summary -->
            <div class="card mb-3">
                <div class="card-header">
                    <h5 class="mb-0">Today's Summary</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <small class="text-muted">Date</small>
                        <p class="mb-0 font-weight-bold">
                            <fmt:formatDate value="<%=new java.util.Date()%>" pattern="EEEE, dd MMMM yyyy"/>
                        </p>
                    </div>
                    <div class="mb-3">
                        <small class="text-muted">Working Hours</small>
                        <p class="mb-0 font-weight-bold">8:00 AM - 5:00 PM</p>
                    </div>
                    <div>
                        <small class="text-muted">Completed Today</small>
                        <p class="mb-0 font-weight-bold">${stats.todayCompletedCount} tasks</p>
                    </div>
                </div>
            </div>
            
            <!-- Notifications -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Notifications</h5>
                </div>
                <div class="card-body">
                    <div class="text-center py-4">
                        <i class="fas fa-bell fa-2x text-muted mb-2"></i>
                        <p class="text-muted mb-0">No new notifications</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>